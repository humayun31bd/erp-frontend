import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/invoice_provider.dart';
import '../../../clients/domain/client_model.dart';
import '../../../pos/providers/pos_provider.dart';
import '../../../pos/domain/product_model.dart';
import '../../../pos/providers/counter_provider.dart';
import '../../../pos/domain/counter_model.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../accounting/providers/accounting_providers.dart';
import '../../../../app.dart';

class CreateInvoiceScreen extends ConsumerStatefulWidget {
  final String? originalInvoiceId;
  final String? noteType;

  const CreateInvoiceScreen({
    super.key, 
    this.originalInvoiceId, 
    this.noteType
  });

  @override
  ConsumerState<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends ConsumerState<CreateInvoiceScreen> {
  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  final _buyerNameCtrl = TextEditingController(text: 'Walk-in Customer');
  final _buyerVatCtrl = TextEditingController();
  final _buyerPhoneCtrl = TextEditingController();

  ClientModel? _selectedClient;
  CounterModel? _selectedCounter;
  String? _selectedBranchId;
  String? _selectedCostCenterId;

  final List<Map<String, dynamic>> _items = [];

  void _addProduct(ProductModel product) {
    setState(() {
      final existingIdx = _items.indexWhere((item) => item['id'] == product.id);
      if (existingIdx >= 0) {
        final currentQty = (_items[existingIdx]['quantity'] as num?)?.toInt() ?? 1;
        _items[existingIdx]['quantity'] = currentQty + 1;
      } else {
        _items.add({
          'id': product.id,
          'name': product.name,
          'quantity': 1,
          'price': double.tryParse(product.price.toString()) ?? 0.0,
          'discount': 0.0
        });
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  double get _subtotal {
    return _items.fold<double>(
      0.0,
      (sum, item) {
        final qty = (item['quantity'] as num?)?.toDouble() ?? 0.0;
        final price = (item['price'] as num?)?.toDouble() ?? 0.0;
        return sum + (qty * price);
      },
    );
  }

  double get _vat {
    return _subtotal * 0.15; // 15% VAT for KSA
  }

  double get _total => _subtotal + _vat;

  void _submit(List<Map<String, dynamic>> payments) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = ref.read(localeProvider).languageCode == 'ar';
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isArabic ? 'يرجى إضافة عنصر واحد على الأقل' : l10n.addAtLeastOneItem)));
      return;
    }
    if (_formKey.currentState?.validate() ?? true) {
      final payload = {
        "invoiceType": widget.noteType ?? "TAX",
        "typeCode": widget.noteType ?? "388",
        "originalInvoiceId": widget.originalInvoiceId,
        "issueDate": DateTime.now().toIso8601String(),
        "buyer": {
          "name": _buyerNameCtrl.text,
          "vatNumber": _buyerVatCtrl.text.isNotEmpty ? _buyerVatCtrl.text : null,
          "phone": _buyerPhoneCtrl.text.isNotEmpty ? _buyerPhoneCtrl.text : null,
        },
        "clientId": _selectedClient?.id,
        "counterId": _selectedCounter?.id,
        "branchId": _selectedBranchId,
        "costCenterId": _selectedCostCenterId,
        "lineItems": _items.asMap().entries.map((entry) {
          final idx = entry.key + 1;
          final item = entry.value;
          final qty = (item['quantity'] as num?)?.toInt() ?? 1;
          final price = (item['price'] as num?)?.toDouble() ?? 0.0;
          final lineTotal = qty * price;
          final taxAmount = lineTotal * 0.15;
          return {
            "lineNumber": idx,
            "description": item['name']?.toString() ?? '',
            "quantity": qty,
            "unitPrice": price,
            "taxPercent": 15,
            "taxAmount": taxAmount,
            "lineTotal": lineTotal + taxAmount
          };
        }).toList(),
        "subtotalAmount": _subtotal,
        "totalVatAmount": _vat,
        "totalAmount": _total,
        "payments": payments
      };

      ref.read(createInvoiceProvider.notifier).submitInvoice(payload);
    }
  }

  Widget _actionButton(IconData icon, String label, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: OutlinedButton.icon(
        icon: Icon(icon, size: 18, color: color ?? Colors.grey[700]),
        label: Text(label, style: TextStyle(color: color ?? Colors.grey[800])),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          side: BorderSide(color: Colors.grey[300]!),
          backgroundColor: Colors.white,
        ),
        onPressed: () {},
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.w500, color: color)),
      ],
    );
  }

  Widget _paymentButton(IconData icon, String label, Color color, String method) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final isCredit = method == 'CREDIT';
    final hasPermit = _selectedClient != null && _selectedClient!.permitCredit;
    final hasLimit = _selectedClient != null && _selectedClient!.creditLimit > 0;
    final currentDues = _selectedClient?.dues ?? 0.0;
    final limitNotExceeded = _selectedClient != null && ((_selectedClient!.creditLimit - currentDues) >= _total - 0.009);
    final isCreditDisabled = isCredit && (_selectedClient == null || !hasPermit || !hasLimit || !limitNotExceeded);

    return ElevatedButton.icon(
      icon: Icon(isCreditDisabled ? Icons.block : icon, color: Colors.white, size: 18),
      label: Text(
        isCreditDisabled ? '$label (${isArabic ? "معطل" : "Disabled"})' : label, 
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isCreditDisabled ? Colors.grey : color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        elevation: 0,
      ),
      onPressed: _items.isEmpty
          ? null
          : (isCreditDisabled
              ? () {
                  String reason = '';
                  if (_selectedClient == null) {
                    reason = isArabic
                        ? 'يرجى اختيار عميل أولاً لاستخدام الدفع الآجل / الذمم.'
                        : 'Please select a customer first to use Credit / On Account.';
                  } else if (!hasPermit) {
                    reason = isArabic
                        ? 'الدفع الآجل غير مسموح للعميل "${_selectedClient!.name}".'
                        : 'Credit is not permitted for customer "${_selectedClient!.name}".';
                  } else if (!hasLimit) {
                    reason = isArabic
                        ? 'حد الائتمان للعميل "${_selectedClient!.name}" هو 0.00 ر.س.'
                        : 'Customer "${_selectedClient!.name}" credit limit is SAR 0.00.';
                  } else {
                    final available = (_selectedClient!.creditLimit - currentDues).clamp(0.0, double.infinity);
                    reason = isArabic
                        ? 'تم تجاوز حد الائتمان! المتاح: ${available.toStringAsFixed(2)} ر.س، إجمالي الفاتورة: ${_total.toStringAsFixed(2)} ر.س.'
                        : 'Credit limit exceeded! Available credit: SAR ${available.toStringAsFixed(2)}, Invoice total: SAR ${_total.toStringAsFixed(2)}.';
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(reason), backgroundColor: Colors.red),
                  );
                }
              : () {
                  _submit([{"method": method, "amount": _total}]);
                }),
    );
  }

  void _showCounterDialog() {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = ref.read(localeProvider).languageCode == 'ar';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isArabic ? 'اختر الكاونتر' : l10n.selectCounter),
          content: Consumer(
            builder: (context, ref, child) {
              final countersState = ref.watch(countersProvider);
              return countersState.when(
                data: (counters) {
                  if (counters.isEmpty) {
                    return Text(isArabic ? 'لا توجد كاونترات متاحة' : l10n.noCountersFound);
                  }
                  return SizedBox(
                    width: double.maxFinite,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: counters.length,
                      itemBuilder: (context, index) {
                        final counter = counters[index];
                        return ListTile(
                          title: Text(counter.name),
                          subtitle: Text(isArabic ? 'الفرع: ${counter.branchName}' : '${l10n.branch}: ${counter.branchName}'),
                          onTap: () {
                            setState(() {
                              _selectedCounter = counter;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (e, st) => Text(isArabic ? 'خطأ في تحميل الكاونترات: $e' : 'Error loading counters: $e'),
              );
            }
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isArabic ? 'إغلاق' : l10n.close),
            ),
          ],
        );
      }
    );
  }

  void _showCustomerDialog() {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = ref.read(localeProvider).languageCode == 'ar';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isArabic ? 'تعيين بيانات العميل' : l10n.assignCustomer),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _buyerNameCtrl,
                    decoration: InputDecoration(
                      labelText: isArabic ? 'اسم العميل' : l10n.customerName,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? (isArabic ? 'اسم العميل مطلوب' : l10n.requiredText) : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _buyerVatCtrl,
                    decoration: InputDecoration(
                      labelText: isArabic ? 'الرقم الضريبي (15 رقم)' : l10n.vatNumber,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _buyerPhoneCtrl,
                    decoration: InputDecoration(
                      labelText: isArabic ? 'رقم الهاتف / واتساب' : l10n.phoneWhatsapp,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isArabic ? 'إغلاق' : l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() {});
                  Navigator.pop(context);
                }
              },
              child: Text(isArabic ? 'حفظ' : l10n.save),
            ),
          ],
        );
      }
    );
  }

  void _showSplitPaymentDialog() {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = ref.read(localeProvider).languageCode == 'ar';
    final cashCtrl = TextEditingController(text: _total.toStringAsFixed(2));
    final cardCtrl = TextEditingController(text: '0.00');
    final bankCtrl = TextEditingController(text: '0.00');
    final creditCtrl = TextEditingController(text: '0.00'); // the remaining dues

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            final cash = double.tryParse(cashCtrl.text) ?? 0.0;
            final card = double.tryParse(cardCtrl.text) ?? 0.0;
            final bank = double.tryParse(bankCtrl.text) ?? 0.0;
            final credit = double.tryParse(creditCtrl.text) ?? 0.0;
            final sum = cash + card + bank + credit;
            final remaining = _total - sum;

            return AlertDialog(
              title: Text(isArabic ? 'تقسيم الدفع / الذمم' : l10n.splitPaymentCredit),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isArabic ? 'المبلغ المستحق: ${_total.toStringAsFixed(2)} ر.س' : l10n.totalDue(_total.toStringAsFixed(2)),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: cashCtrl,
                      decoration: InputDecoration(labelText: isArabic ? 'المبلغ النقدي' : l10n.cashAmount, border: const OutlineInputBorder()),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (v) => setStateSB(() {}),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: cardCtrl,
                      decoration: InputDecoration(labelText: isArabic ? 'مبلغ البطاقة' : l10n.cardAmount, border: const OutlineInputBorder()),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (v) => setStateSB(() {}),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: bankCtrl,
                      decoration: InputDecoration(labelText: isArabic ? 'المبلغ البنكي' : l10n.bankAmount, border: const OutlineInputBorder()),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (v) => setStateSB(() {}),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: creditCtrl,
                      decoration: InputDecoration(labelText: isArabic ? 'المبلغ الآجل (على الحساب)' : l10n.creditDues, border: const OutlineInputBorder()),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (v) => setStateSB(() {}),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      remaining.abs() < 0.01
                          ? (isArabic ? 'تم توزيع المبلغ بالكامل' : l10n.fullyAllocated)
                          : (remaining > 0
                              ? (isArabic ? 'المبلغ المتبقي: ${remaining.toStringAsFixed(2)} ر.س' : l10n.remainingAmount(remaining.toStringAsFixed(2)))
                              : (isArabic ? 'المبلغ الزائد: ${remaining.abs().toStringAsFixed(2)} ر.س' : l10n.overpaidAmount(remaining.abs().toStringAsFixed(2)))),
                      style: TextStyle(color: remaining.abs() < 0.01 ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                    ),
                    if (credit > 0.009) ...[
                      const SizedBox(height: 8),
                      Builder(builder: (_) {
                        final currentDues = _selectedClient?.dues ?? 0.0;
                        final limit = _selectedClient?.creditLimit ?? 0.0;
                        final available = (limit - currentDues).clamp(0.0, double.infinity);
                        final isClientPermitted = _selectedClient != null && _selectedClient!.permitCredit;
                        final isLimitOk = _selectedClient != null && limit > 0 && (credit <= available + 0.009);

                        if (_selectedClient == null) {
                          return Text(isArabic ? '⚠️ يجب تحديد عميل لاستخدام الذمم الآجلة.' : '⚠️ Customer must be assigned to use credit dues.', style: const TextStyle(color: Colors.red, fontSize: 12));
                        }
                        if (!isClientPermitted) {
                          return Text(isArabic ? '⚠️ الدفع الآجل غير مسموح للعميل "${_selectedClient!.name}".' : '⚠️ Credit not permitted for "${_selectedClient!.name}".', style: const TextStyle(color: Colors.red, fontSize: 12));
                        }
                        if (limit <= 0) {
                          return Text(isArabic ? '⚠️ حد الائتمان هو 0.00 ر.س للعميل "${_selectedClient!.name}".' : '⚠️ Credit limit is SAR 0.00 for "${_selectedClient!.name}".', style: const TextStyle(color: Colors.red, fontSize: 12));
                        }
                        if (!isLimitOk) {
                          return Text(isArabic ? '⚠️ تجاوز حد الائتمان! المتاح: ${available.toStringAsFixed(2)} ر.س.' : '⚠️ Credit exceeds limit! Available: SAR ${available.toStringAsFixed(2)}.', style: const TextStyle(color: Colors.red, fontSize: 12));
                        }
                        return Text(isArabic ? '✓ الائتمان المتاح: ${available.toStringAsFixed(2)} ر.س' : '✓ Available credit: SAR ${available.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontSize: 12));
                      }),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(isArabic ? 'إغلاق' : l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (remaining.abs() >= 0.01) return null;
                    if (credit > 0.009) {
                      if (_selectedClient == null || !_selectedClient!.permitCredit || _selectedClient!.creditLimit <= 0) {
                        return null;
                      }
                      final available = ((_selectedClient!.creditLimit) - (_selectedClient!.dues ?? 0)).clamp(0.0, double.infinity);
                      if (credit > available + 0.009) return null;
                    }
                    return () {
                      final payments = <Map<String, dynamic>>[];
                      if (cash > 0) payments.add({'method': 'CASH', 'amount': cash});
                      if (card > 0) payments.add({'method': 'CARD', 'amount': card});
                      if (bank > 0) payments.add({'method': 'BANK', 'amount': bank});
                      if (credit > 0) payments.add({'method': 'CREDIT', 'amount': credit});
                      Navigator.pop(context);
                      _submit(payments);
                    };
                  }(),
                  child: Text(isArabic ? 'تأكيد ودفع' : l10n.confirmAndPay),
                ),
              ],
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsProvider);
    final l10n = AppLocalizations.of(context)!;
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final createState = ref.watch(createInvoiceProvider);
    final branchesAsync = ref.watch(branchesProvider);
    final costCentersAsync = ref.watch(costCentersProvider);

    ref.listen<CreateInvoiceState>(createInvoiceProvider, (prev, next) {
      if (next.successInvoiceId != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isArabic ? 'تم إنشاء الفاتورة بنجاح' : l10n.invoiceCreatedSuccessfully)));
        context.pop();
      } else if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    String titleText;
    if (widget.noteType == '381') {
      titleText = isArabic ? 'إنشاء إشعار دائن (381)' : 'Create Credit Note (381)';
    } else if (widget.noteType == '383') {
      titleText = isArabic ? 'إنشاء إشعار مدين (383)' : 'Create Debit Note (383)';
    } else {
      titleText = isArabic ? 'إنشاء فاتورة مبيعات جديدة' : l10n.createInvoice;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Icon(Icons.receipt_long, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(titleText, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.wifi, color: Colors.green[700], size: 16),
                  const SizedBox(width: 6),
                  Text(isArabic ? 'متصل ومباشر' : l10n.onlineSyncing, style: TextStyle(color: Colors.green[700], fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isArabic ? Icons.language : Icons.g_translate),
            tooltip: isArabic ? 'Switch to English' : 'التحويل للعربية',
            onPressed: () {
              ref.read(localeProvider.notifier).state =
                  isArabic ? const Locale('en') : const Locale('ar');
            },
          ),
          const SizedBox(width: 8),
        ],
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Row(
        children: [
          // LEFT/CENTER PANEL: Top Bar, Cart, Side Actions
          Expanded(
            flex: 3,
            child: Column(
              children: [
                // Top bar: Search / Barcode
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.grey[50],
                  child: Row(
                    children: [
                      Expanded(
                        child: productsState.when(
                          data: (products) {
                            return Autocomplete<ProductModel>(
                              optionsBuilder: (TextEditingValue textEditingValue) {
                                if (textEditingValue.text.isEmpty) {
                                  return const Iterable<ProductModel>.empty();
                                }
                                return products.where((ProductModel product) {
                                  return product.name.toLowerCase().contains(textEditingValue.text.toLowerCase()) || 
                                         (product.barcode != null && product.barcode!.contains(textEditingValue.text));
                                });
                              },
                              displayStringForOption: (ProductModel option) => option.name,
                              onSelected: (ProductModel selection) {
                                _addProduct(selection);
                                _searchController.clear();
                              },
                              fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                                return TextField(
                                  controller: textEditingController,
                                  focusNode: focusNode,
                                  decoration: InputDecoration(
                                    hintText: isArabic ? 'البحث عن منتج أو المسح بالباركود...' : l10n.searchProductHint,
                                    prefixIcon: const Icon(Icons.search),
                                    suffixIcon: const Icon(Icons.qr_code_scanner),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: Colors.grey[300]!),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: Colors.grey[300]!),
                                    ),
                                  ),
                                  onSubmitted: (String value) {
                                    onFieldSubmitted();
                                  },
                                );
                              },
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, st) => Text(isArabic ? 'خطأ في تحميل المنتجات: $e' : 'Error loading products: $e'),
                        ),
                      ),
                    ],
                  ),
                ),
                // Cart Headers
                Container(
                  color: Colors.grey[200],
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text(isArabic ? 'الصنف' : l10n.item, style: const TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(flex: 1, child: Text(isArabic ? 'الكمية' : l10n.qty, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                      Expanded(flex: 1, child: Text(isArabic ? 'السعر' : l10n.price, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                      Expanded(flex: 1, child: Text(isArabic ? 'الخصم' : l10n.discount, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                      Expanded(flex: 1, child: Text(isArabic ? 'الإجمالي' : l10n.total, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                      const SizedBox(width: 48), // Spacer for delete button
                    ],
                  ),
                ),
                // Cart Items List
                Expanded(
                  child: _items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text(isArabic ? 'لا توجد أصناف في الفاتورة' : l10n.noItemsInInvoice, style: TextStyle(color: Colors.grey[500], fontSize: 18)),
                              const SizedBox(height: 8),
                              Text(isArabic ? 'امسح الباركود أو ابحث لإضافة منتجات' : l10n.scanToAdd, style: TextStyle(color: Colors.grey[400])),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: _items.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            final price = (item['price'] as num?)?.toDouble() ?? 0.0;
                            final qty = (item['quantity'] as num?)?.toInt() ?? 1;
                            final lineTotal = price * qty;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle_outline, size: 20),
                                          onPressed: qty > 1 ? () => setState(() => _items[index]['quantity'] = qty - 1) : null,
                                        ),
                                        Text('$qty', style: const TextStyle(fontSize: 16)),
                                        IconButton(
                                          icon: const Icon(Icons.add_circle_outline, size: 20),
                                          onPressed: () => setState(() => _items[index]['quantity'] = qty + 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(price.toStringAsFixed(2), textAlign: TextAlign.right, style: const TextStyle(fontSize: 16)),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text('0.00', textAlign: TextAlign.right, style: TextStyle(fontSize: 16, color: Colors.grey[400])),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(lineTotal.toStringAsFixed(2), textAlign: TextAlign.right, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ),
                                  SizedBox(
                                    width: 48,
                                    child: IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      onPressed: () => _removeItem(index),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                // Bottom Side Actions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.grey[200]!)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), offset: const Offset(0, -2), blurRadius: 4),
                    ],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _actionButton(Icons.pause_circle_outline, isArabic ? 'تعليق' : l10n.holdBtn),
                        _actionButton(Icons.history, isArabic ? 'استرجاع' : l10n.recallBtn),
                        _actionButton(Icons.cancel_outlined, isArabic ? 'إلغاء' : l10n.voidBtn, color: Colors.red),
                        _actionButton(Icons.keyboard_return, isArabic ? 'مرتجع / تبديل' : l10n.returnExchangeBtn),
                        _actionButton(Icons.print_outlined, isArabic ? 'طباعة' : l10n.printBtn),
                        _actionButton(Icons.chat_outlined, isArabic ? 'واتساب' : l10n.whatsappBtn, color: Colors.green[600]),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          
          // RIGHT PANEL: Customer, Tax, Totals, Payments
          Container(
            width: 380,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(left: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              children: [
                // Customer Selection
                InkWell(
                  onTap: _showCustomerDialog,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue[100],
                          child: Icon(Icons.person, color: Colors.blue[700]),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_buyerNameCtrl.text.isEmpty
                                  ? (isArabic ? 'عميل نقدي (عام)' : l10n.walkInCustomer)
                                  : _buyerNameCtrl.text, 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text(isArabic ? 'اضغط لتحديد العميل وبيانات الضريبة' : l10n.tapToAssignCustomer, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey[400]),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),
                
                // Counter Selection
                InkWell(
                  onTap: _showCounterDialog,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    child: Row(
                      children: [
                        Icon(Icons.storefront, color: Colors.blueGrey[700]),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(_selectedCounter?.name ?? (isArabic ? 'لم يتم تحديد كاونتر' : l10n.noCounterSelected), 
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey[400]),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),
                
                // Totals Area
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        branchesAsync.when(
                          data: (branches) => DropdownButtonFormField<String>(
                            initialValue: _selectedBranchId,
                            decoration: InputDecoration(
                              labelText: isArabic ? 'الفرع' : 'Branch',
                              border: const OutlineInputBorder(),
                            ),
                            items: branches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
                            onChanged: (v) => setState(() => _selectedBranchId = v),
                          ),
                          loading: () => const CircularProgressIndicator(),
                          error: (e, st) => Text(isArabic ? 'خطأ في تحميل الفروع' : 'Error loading branches'),
                        ),
                        const SizedBox(height: 12),
                        costCentersAsync.when(
                          data: (costCenters) => DropdownButtonFormField<String>(
                            initialValue: _selectedCostCenterId,
                            decoration: InputDecoration(
                              labelText: isArabic ? 'مركز التكلفة' : 'Cost Center',
                              border: const OutlineInputBorder(),
                            ),
                            items: costCenters.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                            onChanged: (v) => setState(() => _selectedCostCenterId = v),
                          ),
                          loading: () => const CircularProgressIndicator(),
                          error: (e, st) => Text(isArabic ? 'خطأ في تحميل مراكز التكلفة' : 'Error loading cost centers'),
                        ),
                        const SizedBox(height: 16),
                        _summaryRow(isArabic ? 'المجموع الفرعي' : l10n.subtotal, isArabic ? '${_subtotal.toStringAsFixed(2)} ر.س' : 'SAR ${_subtotal.toStringAsFixed(2)}'),
                        const SizedBox(height: 16),
                        _summaryRow(isArabic ? 'الخصم' : l10n.discountText, isArabic ? '0.00 ر.س' : 'SAR 0.00', color: Colors.red),
                        const SizedBox(height: 16),
                        _summaryRow(isArabic ? 'ضريبة القيمة المضافة 15%' : l10n.vat15, isArabic ? '${_vat.toStringAsFixed(2)} ر.س' : 'SAR ${_vat.toStringAsFixed(2)}'),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Divider(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(isArabic ? 'الإجمالي الكلي' : l10n.totalText, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            Text(
                              isArabic ? '${_total.toStringAsFixed(2)} ر.س' : 'SAR ${_total.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green[700]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                ),
                
                // Payments Area
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.grey[200]!)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _paymentButton(Icons.money, isArabic ? 'نقدًا' : l10n.cash, Colors.green[600]!, 'CASH')),
                          const SizedBox(width: 8),
                          Expanded(child: _paymentButton(Icons.credit_card, isArabic ? 'بطاقة' : l10n.card, Colors.blue[600]!, 'CARD')),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _paymentButton(Icons.account_balance, isArabic ? 'بنك' : l10n.bank, Colors.orange[600]!, 'BANK')),
                          const SizedBox(width: 8),
                          Expanded(child: _paymentButton(Icons.wallet, isArabic ? 'آجل / ذمم' : l10n.wallet, Colors.purple[600]!, 'CREDIT')),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.indigo[300]!),
                          ),
                          onPressed: _items.isEmpty ? null : _showSplitPaymentDialog,
                          child: Text(isArabic ? 'دفع متعدد / آجل' : l10n.splitPaymentBtn, style: TextStyle(color: Colors.indigo[700], fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                          onPressed: _items.isEmpty || createState.isLoading ? null : () {
                            _submit([{"method": "CASH", "amount": _total}]); // Default to Cash if Save & Pay is pressed
                          },
                          child: createState.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  isArabic
                                      ? 'حفظ وتأكيد الدفع (${_total.toStringAsFixed(2)} ر.س)'
                                      : l10n.saveAndPay(_total.toStringAsFixed(2)),
                                  style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

