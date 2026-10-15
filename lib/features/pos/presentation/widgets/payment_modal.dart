import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../clients/domain/client_model.dart';
import '../../../payments/providers/payment_method_provider.dart';
import '../../providers/pos_provider.dart';
import 'customer_selection_modal.dart';

class PaymentLine {
  final PaymentMethod method;
  final double amountTendered;
  final double change;
  final String? reference;

  const PaymentLine({
    required this.method,
    required this.amountTendered,
    this.change = 0.0,
    this.reference,
  });
}

/// Payment result returned when the user confirms a payment.
class PaymentResult {
  final List<PaymentLine> lines;
  final double change; // Total change back

  const PaymentResult({
    required this.lines,
    this.change = 0.0,
  });
  
  // Helper for single method for backward compatibility
  PaymentMethod get method => lines.first.method;
}

Future<PaymentResult?> showPaymentModal(
  BuildContext context,
  WidgetRef ref,
  double totalAmount,
) {
  return showDialog<PaymentResult>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _PaymentModalDialog(totalAmount: totalAmount),
  );
}

class _PaymentModalDialog extends ConsumerStatefulWidget {
  final double totalAmount;
  const _PaymentModalDialog({required this.totalAmount});

  @override
  ConsumerState<_PaymentModalDialog> createState() => _PaymentModalDialogState();
}

class _PaymentModalDialogState extends ConsumerState<_PaymentModalDialog> {
  final List<PaymentLine> _lines = [];
  PaymentMethod? _selectedMethod;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  String _selectedCurrency = 'SAR';
  final List<String> _currencies = ['SAR', 'USD', 'EUR', 'AED'];

  double _round2(double val) => (val * 100).roundToDouble() / 100.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(paymentMethodProvider.notifier);
      setState(() {
        _selectedMethod = notifier.defaultMethod;
        _amountController.text = _round2(widget.totalAmount).toStringAsFixed(2);
      });
      // Automatically select the text so the user can just start typing the received amount
      _amountController.selection = TextSelection(baseOffset: 0, extentOffset: _amountController.text.length);
      _amountFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  bool get _isCash => _selectedMethod?.id == 'cash';
  bool get _isCredit => _selectedMethod?.id == 'credit';

  double get _creditLinesTotal => _round2(_lines.where((l) => l.method.id == 'credit').fold(0.0, (sum, l) => sum + l.amountTendered));

  bool _isCreditPermittedForCustomer(ClientModel? customer) {
    if (customer == null) return false;
    if (!customer.permitCredit) return false;
    if (customer.creditLimit <= 0) return false;
    final currentDues = customer.dues ?? 0.0;
    return (customer.creditLimit - currentDues) > 0.009;
  }

  String _getCreditDisabledReason(ClientModel? customer) {
    if (customer == null) return 'Customer required';
    if (!customer.permitCredit) return 'Credit not permitted';
    if (customer.creditLimit <= 0) return 'Credit limit is 0.00';
    final currentDues = customer.dues ?? 0.0;
    final available = (customer.creditLimit - currentDues).clamp(0.0, double.infinity);
    if (available <= 0.009) {
      return 'Credit limit reached';
    }
    return '';
  }

  // Total applied net payment toward the bill so far
  double get _totalApplied => _round2(_lines.fold(0.0, (sum, l) => sum + (l.amountTendered - l.change)));
  
  // Remaining amount on the bill before considering the current text field input
  double get _remaining => _round2((widget.totalAmount - _totalApplied).clamp(0.0, double.infinity));

  // Current amount in SAR parsed from the text input
  double get _currentInputAmount {
    final text = _amountController.text.trim();
    if (text.isEmpty) return 0.0;
    double val = double.tryParse(text) ?? 0.0;
    if (_selectedCurrency == 'USD') return _round2(val * 3.75);
    if (_selectedCurrency == 'EUR') return _round2(val * 4.10);
    if (_selectedCurrency == 'AED') return _round2(val * 1.02);
    return _round2(val);
  }

  // Change to give for current input if cash
  double get _currentChange {
    if (_isCash && _currentInputAmount > _remaining) {
      return _round2(_currentInputAmount - _remaining);
    }
    return 0.0;
  }

  // How much the current input will reduce the remaining balance
  double get _pendingNetApplied {
    if (_currentInputAmount <= 0) return 0.0;
    if (_isCash) {
      return _currentInputAmount > _remaining ? _remaining : _currentInputAmount;
    }
    return _currentInputAmount;
  }

  // Remaining balance after the current pending input would be applied
  double get _effectiveRemaining => _round2((_remaining - _pendingNetApplied).clamp(0.0, double.infinity));

  // True if payment fully covers the total amount without requiring customer credit
  bool get _isFullyCovered {
    if (_remaining <= 0.009) return true;
    if (!_isCredit && (_currentInputAmount >= _remaining - 0.009) && _currentInputAmount > 0) {
      return true;
    }
    return false;
  }

  void _addLine() {
    if (_selectedMethod == null || _currentInputAmount <= 0) return;
    
    if (_isCredit) {
      final customer = ref.read(selectedCustomerProvider);
      if (customer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a customer first to use Credit / On Account.'), backgroundColor: Color(0xFFEF5350)),
        );
        return;
      }
      if (!customer.permitCredit) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Credit is not permitted for customer "${customer.name}".'), backgroundColor: const Color(0xFFEF5350)),
        );
        return;
      }
      if (customer.creditLimit <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Customer "${customer.name}" credit limit is SAR 0.00. Credit payment is disabled.'), backgroundColor: const Color(0xFFEF5350)),
        );
        return;
      }
      final currentDues = customer.dues ?? 0.0;
      final available = (customer.creditLimit - currentDues).clamp(0.0, double.infinity);
      final totalCreditAttempted = _creditLinesTotal + _currentInputAmount;
      if (totalCreditAttempted > available + 0.009) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Credit limit exceeded! Available: SAR ${available.toStringAsFixed(2)}. Cannot charge SAR ${_currentInputAmount.toStringAsFixed(2)}.'),
            backgroundColor: const Color(0xFFEF5350),
          ),
        );
        return;
      }
    }

    final change = _currentChange;
    
    setState(() {
      _lines.add(PaymentLine(
        method: _selectedMethod!,
        amountTendered: _currentInputAmount,
        change: change,
        reference: _referenceController.text.trim().isEmpty ? null : _referenceController.text.trim(),
      ));
      _referenceController.clear();
      final newRemaining = _round2((widget.totalAmount - _totalApplied).clamp(0.0, double.infinity));
      _amountController.text = newRemaining > 0.009 ? newRemaining.toStringAsFixed(2) : '0.00';
    });
  }

  void _confirm() {
    // 1. If user hasn't explicitly clicked "ADD PARTIAL PAYMENT", automatically commit current input as line
    if (_remaining > 0.009 && _currentInputAmount > 0 && _selectedMethod != null) {
      if (_isCredit) {
        final customer = ref.read(selectedCustomerProvider);
        if (customer == null || !customer.permitCredit || customer.creditLimit <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(customer == null ? 'Please select a customer first to use Credit.' : 'Credit is not permitted or limit is 0 for "${customer.name}".'),
              backgroundColor: const Color(0xFFEF5350),
            ),
          );
          return;
        }
        final currentDues = customer.dues ?? 0.0;
        final available = (customer.creditLimit - currentDues).clamp(0.0, double.infinity);
        if (_creditLinesTotal + _currentInputAmount > available + 0.009) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Credit limit exceeded! Available: SAR ${available.toStringAsFixed(2)}.'),
              backgroundColor: const Color(0xFFEF5350),
            ),
          );
          return;
        }
      }
      final change = _currentChange;
      _lines.add(PaymentLine(
        method: _selectedMethod!,
        amountTendered: _currentInputAmount,
        change: change,
        reference: _referenceController.text.trim().isEmpty ? null : _referenceController.text.trim(),
      ));
    }
    
    if (_lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount or select a payment method.')),
      );
      return;
    }

    // 2. Check remaining unpaid balance
    final unpaidBalance = _round2((widget.totalAmount - _totalApplied).clamp(0.0, double.infinity));
    final hasCreditLine = _lines.any((l) => l.method.id == 'credit');

    // 3. If there is an unpaid balance or explicit Credit method, require customer assignment & check credit permit and limits
    if (unpaidBalance > 0.009 || hasCreditLine) {
      final customer = ref.read(selectedCustomerProvider);
      if (customer == null) {
        final reason = hasCreditLine
            ? 'Please select a customer first to use Credit / On Account.'
            : 'Unpaid balance of SAR ${unpaidBalance.toStringAsFixed(2)} remaining. Please select a customer first to add to credit.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(reason),
            backgroundColor: const Color(0xFFEF5350),
          ),
        );
        return;
      }
      if (!customer.permitCredit) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Credit / On Account is not permitted for customer "${customer.name}".'),
            backgroundColor: const Color(0xFFEF5350),
          ),
        );
        return;
      }
      if (customer.creditLimit <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Customer "${customer.name}" has a credit limit of SAR 0.00. Credit option is disabled.'),
            backgroundColor: const Color(0xFFEF5350),
          ),
        );
        return;
      }
      final currentDues = customer.dues ?? 0.0;
      final available = (customer.creditLimit - currentDues).clamp(0.0, double.infinity);
      final totalNewCredit = _creditLinesTotal + unpaidBalance;
      if (totalNewCredit > available + 0.009) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Credit limit exceeded! Customer limit: SAR ${customer.creditLimit.toStringAsFixed(2)}, Current Dues: SAR ${currentDues.toStringAsFixed(2)}, Available: SAR ${available.toStringAsFixed(2)}. Cannot charge SAR ${totalNewCredit.toStringAsFixed(2)} to credit.'),
            backgroundColor: const Color(0xFFEF5350),
          ),
        );
        return;
      }
    }

    // 4. Return result with total change
    final totalChange = _round2(_lines.fold(0.0, (sum, l) => sum + l.change));

    Navigator.of(context).pop(PaymentResult(
      lines: List.from(_lines),
      change: totalChange,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final activeMethods = ref.watch(paymentMethodProvider.notifier).activeMethods;
    final selectedCustomer = ref.watch(selectedCustomerProvider);

    final bool isCreditAllowed = _isCreditPermittedForCustomer(selectedCustomer);
    final String creditDisabledReason = _getCreditDisabledReason(selectedCustomer);
    final double customerCreditLimit = selectedCustomer?.creditLimit ?? 0.0;
    final double customerDues = selectedCustomer?.dues ?? 0.0;
    final double customerAvailableCredit = (customerCreditLimit - customerDues).clamp(0.0, double.infinity);

    final bool isCreditMethodSelected = _selectedMethod?.id == 'credit';
    final double creditAttemptedForInput = isCreditMethodSelected ? _currentInputAmount : 0.0;
    final bool creditExceedsLimit = isCreditMethodSelected && (_creditLinesTotal + creditAttemptedForInput > customerAvailableCredit + 0.009);

    final bool unpaidCreditExceedsLimit = !_isFullyCovered && (_creditLinesTotal + _effectiveRemaining > customerAvailableCredit + 0.009);
    final bool canPutRemainingOnCredit = !_isFullyCovered && isCreditAllowed && !unpaidCreditExceedsLimit;

    final bool canConfirm = (_lines.isNotEmpty || _currentInputAmount > 0) && (
      _isFullyCovered 
      || (isCreditMethodSelected && isCreditAllowed && !creditExceedsLimit)
      || (!isCreditMethodSelected && canPutRemainingOnCredit)
    );

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Focus(
        autofocus: true,
        onKeyEvent: (FocusNode node, KeyEvent event) {
          if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
            if (canConfirm) {
              _confirm();
            }
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, minWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF1A237E), // Deep Navy
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.payments_outlined, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Payment Processing', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Total: SAR ${_round2(widget.totalAmount).toStringAsFixed(2)}',
                              style: const TextStyle(color: Color(0xFF00BFA5), fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 12),
                            // Quick customer selector/indicator chip
                            InkWell(
                              onTap: () => showDialog(
                                context: context,
                                builder: (_) => const CustomerSelectionModal(),
                              ),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      selectedCustomer != null ? Icons.person : Icons.person_outline,
                                      color: Colors.white70,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      selectedCustomer != null
                                          ? '${selectedCustomer.name} (${selectedCustomer.permitCredit && selectedCustomer.creditLimit > 0 ? "Credit SAR ${customerAvailableCredit.toStringAsFixed(2)}" : "No Credit"})'
                                          : 'Walk-in Customer',
                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Added Lines
                  if (_lines.isNotEmpty) ...[
                    const Text('Payments Added', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: _lines.asMap().entries.map((entry) {
                          final i = entry.key;
                          final line = entry.value;
                          return ListTile(
                            dense: true,
                            leading: Icon(line.method.icon, color: line.method.color),
                            title: Text(line.method.name),
                            subtitle: line.reference != null ? Text('Ref: ${line.reference}') : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('SAR ${line.amountTendered.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red, size: 18),
                                  onPressed: () {
                                    setState(() {
                                      _lines.removeAt(i);
                                      final newRemaining = _round2((widget.totalAmount - _totalApplied).clamp(0.0, double.infinity));
                                      _amountController.text = newRemaining.toStringAsFixed(2);
                                    });
                                  },
                                )
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (_remaining > 0.009) ...[
                    // Amount Due / Remaining Balance Display
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: _lines.isEmpty 
                            ? const Color(0xFF1A237E).withValues(alpha: 0.05)
                            : const Color(0xFFE65100).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _lines.isEmpty
                              ? const Color(0xFF1A237E).withValues(alpha: 0.2)
                              : const Color(0xFFE65100).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _lines.isEmpty ? 'Amount Due' : 'Remaining Balance',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _lines.isEmpty ? const Color(0xFF1A237E) : const Color(0xFFE65100),
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'SAR ${_remaining.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              color: _lines.isEmpty ? const Color(0xFF1A237E) : const Color(0xFFE65100),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Method Selection
                    const Text('Select Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: activeMethods.map((method) {
                        final isCreditOption = method.id == 'credit';
                        final isOptionDisabled = isCreditOption && !isCreditAllowed;
                        final isSelected = _selectedMethod?.id == method.id && !isOptionDisabled;

                        return GestureDetector(
                          onTap: () {
                            if (isOptionDisabled) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Credit payment disabled: $creditDisabledReason'),
                                  backgroundColor: const Color(0xFFEF5350),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                              return;
                            }
                            setState(() {
                              _selectedMethod = method;
                              if (method.id != 'cash') {
                                _amountController.text = _remaining.toStringAsFixed(2);
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isOptionDisabled
                                  ? Colors.grey.shade100
                                  : (isSelected ? const Color(0xFF1A237E).withValues(alpha: 0.06) : Colors.white),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isOptionDisabled
                                    ? Colors.grey.shade300
                                    : (isSelected ? const Color(0xFF1A237E) : Colors.grey.shade300),
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF1A237E).withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))] : [],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isOptionDisabled ? Icons.block : method.icon,
                                  color: isOptionDisabled 
                                      ? Colors.grey.shade400 
                                      : (isSelected ? const Color(0xFF1A237E) : Colors.grey.shade600),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      method.name,
                                      style: TextStyle(
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: isOptionDisabled 
                                            ? Colors.grey.shade400 
                                            : (isSelected ? const Color(0xFF1A237E) : Colors.grey.shade800),
                                        fontSize: 14,
                                        decoration: isOptionDisabled ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                    if (isOptionDisabled)
                                      Text(
                                        creditDisabledReason,
                                        style: TextStyle(fontSize: 10, color: Colors.red.shade400, fontWeight: FontWeight.bold),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Credit Information Card if Credit is selected
                    if (isCreditMethodSelected) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: creditExceedsLimit 
                              ? const Color(0xFFEF5350).withValues(alpha: 0.08)
                              : const Color(0xFF1A237E).withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: creditExceedsLimit ? const Color(0xFFEF5350) : const Color(0xFF1A237E).withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Customer: ${selectedCustomer?.name ?? "Unknown"}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Text('Credit Limit: SAR ${customerCreditLimit.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Current Dues: SAR ${customerDues.toStringAsFixed(2)}', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                                Text('Available Credit: SAR ${customerAvailableCredit.toStringAsFixed(2)}', 
                                  style: TextStyle(
                                    color: customerAvailableCredit > 0 ? const Color(0xFF00BFA5) : Colors.red, 
                                    fontWeight: FontWeight.bold, 
                                    fontSize: 12
                                  )
                                ),
                              ],
                            ),
                            if (creditExceedsLimit) ...[
                              const SizedBox(height: 6),
                              Text(
                                '⚠️ Credit limit exceeded! Available: SAR ${customerAvailableCredit.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],

                    // Input
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Amount Tendered', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        if (_isCash)
                          DropdownButton<String>(
                            value: _selectedCurrency,
                            items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
                            onChanged: (val) => setState(() => _selectedCurrency = val!),
                            isDense: true,
                            underline: const SizedBox(),
                            icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF1A237E)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _amountController,
                      focusNode: _amountFocusNode,
                      autofocus: true,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
                      decoration: InputDecoration(
                        prefixText: '$_selectedCurrency  ',
                        prefixStyle: TextStyle(color: Colors.grey.shade500, fontSize: 18),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2)),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    if (_isCash && _selectedCurrency != 'SAR')
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('Converted to: SAR ${_currentInputAmount.toStringAsFixed(2)}', style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic), textAlign: TextAlign.right),
                      ),
                    
                    if (_isCash && _currentChange > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Change to give: SAR ${_currentChange.toStringAsFixed(2)}', 
                          style: const TextStyle(color: Color(0xFF00BFA5), fontWeight: FontWeight.bold, fontSize: 16),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      
                    if (!_isCash) ...[
                      const SizedBox(height: 14),
                      TextField(
                        controller: _referenceController,
                        decoration: InputDecoration(
                          hintText: 'Reference / Approval No. (optional)',
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2)),
                          prefixIcon: const Icon(Icons.receipt_long, color: Colors.grey),
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('ADD PARTIAL PAYMENT', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: const Color(0xFF1A237E),
                        side: const BorderSide(color: Color(0xFF1A237E)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: (_currentInputAmount > 0 && _selectedMethod != null && (!isCreditMethodSelected || (isCreditAllowed && !creditExceedsLimit))) ? _addLine : null,
                    ),
                  ] else ...[
                    // Fully paid
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00BFA5).withValues(alpha: 0.1), 
                        borderRadius: BorderRadius.circular(12), 
                        border: Border.all(color: const Color(0xFF00BFA5).withValues(alpha: 0.3))
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.check_circle, color: Color(0xFF00BFA5), size: 24),
                              SizedBox(width: 8),
                              Text('Payment Settled', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00BFA5))),
                            ],
                          ),
                          if (_lines.any((l) => l.change > 0))
                            Text(
                              'Change: SAR ${_round2(_lines.fold(0.0, (s, l) => s + l.change)).toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF00BFA5)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Notice if remaining unpaid balance cannot be put on credit
            if (!_isFullyCovered && !canPutRemainingOnCredit && _remaining > 0.009)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF5350).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFEF5350).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFFEF5350), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          selectedCustomer == null
                              ? 'Unpaid balance cannot be saved on credit without selecting a customer.'
                              : (!selectedCustomer.permitCredit
                                  ? 'Credit is disabled for ${selectedCustomer.name}. Full payment required.'
                                  : (customerCreditLimit <= 0
                                      ? 'Credit limit is 0.00 for ${selectedCustomer.name}. Full payment required.'
                                      : 'Remaining balance of SAR ${_effectiveRemaining.toStringAsFixed(2)} exceeds customer available credit (SAR ${customerAvailableCredit.toStringAsFixed(2)}).')),
                          style: const TextStyle(color: Color(0xFFD32F2F), fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      icon: Icon(
                        isCreditMethodSelected
                            ? Icons.receipt_long
                            : (_isFullyCovered ? Icons.check_circle : Icons.credit_score),
                        color: Colors.white,
                      ),
                      label: Text(
                        isCreditMethodSelected
                            ? (creditExceedsLimit 
                                ? 'CREDIT LIMIT EXCEEDED' 
                                : (!isCreditAllowed ? 'CREDIT DISABLED' : 'CHARGE TO CREDIT'))
                            : (_isFullyCovered
                                ? 'CONFIRM PAYMENT'
                                : (selectedCustomer == null
                                    ? 'ASSIGN CUSTOMER FOR CREDIT'
                                    : (!selectedCustomer.permitCredit
                                        ? 'CREDIT NOT PERMITTED'
                                        : (customerCreditLimit <= 0
                                            ? 'CREDIT LIMIT ZERO'
                                            : (unpaidCreditExceedsLimit
                                                ? 'CREDIT LIMIT EXCEEDED'
                                                : 'ADD TO CREDIT (SAR ${_effectiveRemaining.toStringAsFixed(2)})'))))),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canConfirm
                            ? (isCreditMethodSelected
                                ? const Color(0xFF1A237E)
                                : (_isFullyCovered
                                    ? const Color(0xFF00BFA5)
                                    : const Color(0xFFEF5350)))
                            : Colors.grey.shade400,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: canConfirm ? _confirm : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
