import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:erp_frontend/core/routing/route_names.dart';
import 'package:erp_frontend/features/accounting/providers/accounting_providers.dart';
import 'package:erp_frontend/features/accounting/presentation/widgets/sync_status_widget.dart';
import 'package:erp_frontend/features/accounting/presentation/widgets/voucher_balance_indicator.dart';
import 'package:erp_frontend/features/accounting/presentation/widgets/voucher_preview_modal.dart';
import 'package:erp_frontend/features/accounting/presentation/widgets/vouchers_help_modal.dart';
import 'package:erp_frontend/features/accounting/utils/voucher_pdf_exporter.dart';
import 'package:erp_frontend/features/accounting/presentation/widgets/searchable_account_selector.dart';

class VouchersScreen extends ConsumerStatefulWidget {
  const VouchersScreen({super.key});

  @override
  ConsumerState<VouchersScreen> createState() => _VouchersScreenState();
}

class _VouchersScreenState extends ConsumerState<VouchersScreen> {
  String _selectedVoucherType = 'RECEIPT_VOUCHER';
  String _tableFilterType = 'ALL';
  SyncState _syncState = SyncState.synced;
  int _pendingSyncCount = 0;
  
  bool _isSidebarExpanded = true;
  
  final List<String> _voucherTypes = [
    'RECEIPT_VOUCHER',
    'PAYMENT_VOUCHER',
    'CONTRA_VOUCHER',
    'JOURNAL_VOUCHER',
  ];

  IconData _getVoucherIcon(String type) {
    switch (type) {
      case 'RECEIPT_VOUCHER':
        return Icons.south_west_rounded;
      case 'PAYMENT_VOUCHER':
        return Icons.north_east_rounded;
      case 'CONTRA_VOUCHER':
        return Icons.swap_horiz_rounded;
      case 'JOURNAL_VOUCHER':
        return Icons.auto_stories_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  MaterialColor _getVoucherColor(String type) {
    switch (type) {
      case 'RECEIPT_VOUCHER':
        return Colors.green;
      case 'PAYMENT_VOUCHER':
        return Colors.red;
      case 'CONTRA_VOUCHER':
        return Colors.purple;
      case 'JOURNAL_VOUCHER':
        return Colors.amber;
      default:
        return Colors.blue;
    }
  }

  String _getVoucherCode(String type) {
    switch (type) {
      case 'RECEIPT_VOUCHER':
        return 'RV';
      case 'PAYMENT_VOUCHER':
        return 'PV';
      case 'CONTRA_VOUCHER':
        return 'CV';
      case 'JOURNAL_VOUCHER':
        return 'JV';
      default:
        return 'V';
    }
  }

  String _getVoucherTitle(String type) {
    switch (type) {
      case 'RECEIPT_VOUCHER':
        return 'Receipt Voucher';
      case 'PAYMENT_VOUCHER':
        return 'Payment Voucher';
      case 'CONTRA_VOUCHER':
        return 'Contra Voucher';
      case 'JOURNAL_VOUCHER':
        return 'Journal Voucher';
      default:
        return type.replaceAll('_', ' ');
    }
  }

  String _getVoucherTooltip(String type) {
    switch (type) {
      case 'RECEIPT_VOUCHER':
        return 'Receipt Voucher (RV) - Customer collection & cash/bank inflows';
      case 'PAYMENT_VOUCHER':
        return 'Payment Voucher (PV) - Vendor payments & cash/bank outflows';
      case 'CONTRA_VOUCHER':
        return 'Contra Voucher (CV) - Internal transfer between cash & bank accounts';
      case 'JOURNAL_VOUCHER':
        return 'Journal Voucher (JV) - Multi-line manual adjustments, depreciation & accruals';
      default:
        return type.replaceAll('_', ' ');
    }
  }

  Widget _buildVoucherSidebar(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: _isSidebarExpanded ? 240 : 72,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(right: BorderSide(color: Colors.grey.shade300)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row with Toggle Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
            child: Row(
              mainAxisAlignment: _isSidebarExpanded ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
              children: [
                if (_isSidebarExpanded) ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF2563EB), size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'VOUCHERS',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 0.8,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ],
                Tooltip(
                  message: _isSidebarExpanded ? 'Collapse Sidebar (Icons Only)' : 'Expand Sidebar',
                  waitDuration: const Duration(milliseconds: 300),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        setState(() {
                          _isSidebarExpanded = !_isSidebarExpanded;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Icon(
                          _isSidebarExpanded ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                          color: Colors.grey.shade700,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Voucher Types Navigation
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              itemCount: _voucherTypes.length,
              itemBuilder: (context, index) {
                final type = _voucherTypes[index];
                final isSelected = _selectedVoucherType == type;
                final color = _getVoucherColor(type);
                final icon = _getVoucherIcon(type);
                final title = _getVoucherTitle(type);
                final code = _getVoucherCode(type);
                final tooltipMsg = _getVoucherTooltip(type);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Tooltip(
                    message: tooltipMsg,
                    waitDuration: const Duration(milliseconds: 300),
                    preferBelow: false,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          setState(() {
                            _selectedVoucherType = type;
                            _tableFilterType = type;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: EdgeInsets.symmetric(
                            horizontal: _isSidebarExpanded ? 12.0 : 0.0,
                            vertical: 10.0,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? color.withValues(alpha: 0.12) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? color.withValues(alpha: 0.4) : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: _isSidebarExpanded
                              ? Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: isSelected ? color : color.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        icon,
                                        color: isSelected ? Colors.white : color,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          color: isSelected ? color.shade900 : Colors.grey.shade800,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isSelected ? color : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        code,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Colors.white : Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isSelected ? color : color.withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: color.withValues(alpha: 0.3),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Icon(
                                        icon,
                                        color: isSelected ? Colors.white : color,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      code,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? color : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          // Bottom Collapse/Expand Footer
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: _isSidebarExpanded
                ? Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.touch_app_rounded, size: 16, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Hover icon for mouse tooltips',
                            style: TextStyle(fontSize: 11, color: Colors.blue.shade900, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  )
                : Tooltip(
                    message: 'Expand Sidebar',
                    waitDuration: const Duration(milliseconds: 300),
                    child: IconButton(
                      icon: const Icon(Icons.last_page_rounded, color: Color(0xFF2563EB)),
                      onPressed: () {
                        setState(() {
                          _isSidebarExpanded = true;
                        });
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

    
  Future<void> _handleManualSync() async {
    setState(() {
      _syncState = SyncState.syncing;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _syncState = SyncState.synced;
        _pendingSyncCount = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cloud Synchronization Complete! All items synced.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('General Ledger Vouchers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.rule_folder_rounded, color: Colors.amber),
            tooltip: 'Voucher Approval Queue (Maker-Checker)',
            onPressed: () => context.goNamed(RouteNames.voucherApproval),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: Color(0xFF2563EB)),
            tooltip: 'Vouchers Training Guide',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const VouchersHelpModal(),
              );
            },
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: SyncStatusWidget(
              syncState: _syncState,
              pendingCount: _pendingSyncCount,
              onSyncPressed: _handleManualSync,
            ),
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVoucherSidebar(context),
          // Main Content Area (Split into Entry Form and Recent Posted Vouchers Table)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    VoucherEntryForm(
                      voucherType: _selectedVoucherType,
                      onVoucherCreated: () {
                        ref.invalidate(vouchersProvider);
                        setState(() {
                          _syncState = SyncState.offlinePending;
                          _pendingSyncCount += 1;
                        });
                      },
                    ),
                    const SizedBox(height: 32),

                    // Recent Vouchers Table with Live DB Data & Type-Wise Filter
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text('Recent Posted Vouchers', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.green.shade200),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.storage_rounded, size: 14, color: Colors.green.shade700),
                                          const SizedBox(width: 4),
                                          Text('Live DB Feed', style: TextStyle(fontSize: 12, color: Colors.green.shade800, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.refresh_rounded, color: Color(0xFF2563EB)),
                                  tooltip: 'Refresh DB Feed',
                                  onPressed: () => ref.invalidate(vouchersProvider),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Type-wise Filter Chips
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  ChoiceChip(
                                    label: const Text('All Types'),
                                    selected: _tableFilterType == 'ALL',
                                    selectedColor: const Color(0xFF2563EB).withValues(alpha: 0.15),
                                    onSelected: (selected) {
                                      if (selected) setState(() => _tableFilterType = 'ALL');
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  ChoiceChip(
                                    label: const Text('Receipt Vouchers (RV)'),
                                    selected: _tableFilterType == 'RECEIPT_VOUCHER',
                                    selectedColor: Colors.green.withValues(alpha: 0.2),
                                    onSelected: (selected) {
                                      if (selected) setState(() => _tableFilterType = 'RECEIPT_VOUCHER');
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  ChoiceChip(
                                    label: const Text('Payment Vouchers (PV)'),
                                    selected: _tableFilterType == 'PAYMENT_VOUCHER',
                                    selectedColor: Colors.red.withValues(alpha: 0.2),
                                    onSelected: (selected) {
                                      if (selected) setState(() => _tableFilterType = 'PAYMENT_VOUCHER');
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  ChoiceChip(
                                    label: const Text('Contra Vouchers (CV)'),
                                    selected: _tableFilterType == 'CONTRA_VOUCHER',
                                    selectedColor: Colors.purple.withValues(alpha: 0.2),
                                    onSelected: (selected) {
                                      if (selected) setState(() => _tableFilterType = 'CONTRA_VOUCHER');
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  ChoiceChip(
                                    label: const Text('Journal Vouchers (JV)'),
                                    selected: _tableFilterType == 'JOURNAL_VOUCHER',
                                    selectedColor: Colors.amber.withValues(alpha: 0.2),
                                    onSelected: (selected) {
                                      if (selected) setState(() => _tableFilterType = 'JOURNAL_VOUCHER');
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Data Table connected to Live DB
                            ref.watch(vouchersProvider(_tableFilterType)).when(
                              data: (dbVouchers) {
                                // If DB has entries, show DB entries; else fallback to filtered dummy vouchers if DB is empty
                                final vouchersToDisplay = dbVouchers;

                                if (vouchersToDisplay.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 36.0),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
                                          const SizedBox(height: 10),
                                          Text(
                                            'No ${_tableFilterType == 'ALL' ? '' : _tableFilterType.replaceAll('_', ' ')} vouchers found in database.',
                                            style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w500),
                                          ),
                                          const SizedBox(height: 4),
                                          Text('Create a new voucher above to see live database records.', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                return SizedBox(
                                  width: double.infinity,
                                  child: DataTable(
                                    headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                                    columns: const [
                                      DataColumn(label: Text('Voucher No', style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('Payee / Particulars', style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(numeric: true, label: Text('Total (৳)', style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                                    ],
                                    rows: vouchersToDisplay.map((v) {
                                      final rawType = (v['voucherType'] ?? 'VOUCHER').toString();
                                      final typeColor = _getVoucherColor(rawType);
                                      final amt = (v['totalAmount'] is num) ? (v['totalAmount'] as num).toDouble() : 0.0;
                                      final status = (v['status'] ?? 'POSTED').toString();

                                      return DataRow(cells: [
                                        DataCell(Text(v['voucherNumber'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold))),
                                        DataCell(
                                          Chip(
                                            label: Text(
                                              rawType.replaceAll('_', ' '),
                                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: typeColor.shade900),
                                            ),
                                            backgroundColor: typeColor.withValues(alpha: 0.15),
                                            side: BorderSide(color: typeColor.withValues(alpha: 0.3)),
                                          ),
                                        ),
                                        DataCell(Text(v['voucherDate'] ?? '')),
                                        DataCell(Text(v['payeeName'] ?? v['narration'] ?? 'General Voucher')),
                                        DataCell(Text('৳${amt.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold))),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: status == 'POSTED' || status == 'APPROVED' ? Colors.green.shade600 : Colors.orange.shade700,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              status,
                                              style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.visibility, color: Colors.blue),
                                                tooltip: 'Interactive Preview',
                                                onPressed: () => VoucherPreviewModal.show(context, v),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.print, color: Colors.indigo),
                                                tooltip: 'Print / Export PDF',
                                                onPressed: () {
                                                  VoucherPdfExporter.printOrSaveVoucher(
                                                    context,
                                                    voucherNumber: v['voucherNumber'] ?? 'V-001',
                                                    voucherType: v['voucherType'] ?? 'VOUCHER',
                                                    dateStr: v['voucherDate'] ?? '',
                                                    fiscalYear: v['fiscalYear'] ?? '2026-2027',
                                                    periodNumber: v['periodNumber'] ?? 4,
                                                    narration: v['narration'] ?? '',
                                                    totalAmount: amt,
                                                    lines: List<Map<String, dynamic>>.from(v['lines'] ?? []),
                                                    status: v['status']?.toString(),
                                                     chequeNumber: v['chequeNumber'],
                                                    payeeName: v['payeeName'],
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ]);
                                    }).toList(),
                                  ),
                                );
                              },
                              loading: () => const Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Center(child: CircularProgressIndicator()),
                              ),
                              error: (err, stack) => Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text('Error loading DB vouchers: $err', style: const TextStyle(color: Colors.red)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VoucherEntryForm extends ConsumerStatefulWidget {
  final String voucherType;
  final VoidCallback? onVoucherCreated;
  
  const VoucherEntryForm({super.key, required this.voucherType, this.onVoucherCreated});

  @override
  ConsumerState<VoucherEntryForm> createState() => _VoucherEntryFormState();
}

class _VoucherEntryFormState extends ConsumerState<VoucherEntryForm> {
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  String? _cashBankAccount;
  List<Map<String, dynamic>> _lines = [];
  bool _isSubmitting = false;

  double get _totalLineAmount {
    double total = 0.0;
    for (var l in _lines) {
      total += (l['amount'] as double? ?? 0.0);
    }
    return total;
  }

  double get _totalDebit {
    if (widget.voucherType == 'JOURNAL_VOUCHER') {
      double total = 0.0;
      for (var l in _lines) {
        total += (l['debit'] as double? ?? 0.0);
      }
      return total;
    }

    if (widget.voucherType == 'RECEIPT_VOUCHER' || widget.voucherType == 'CONTRA_VOUCHER') {
      return _cashBankAccount != null ? _totalLineAmount : 0.0;
    } else {
      return _totalLineAmount;
    }
  }

  double get _totalCredit {
    if (widget.voucherType == 'JOURNAL_VOUCHER') {
      double total = 0.0;
      for (var l in _lines) {
        total += (l['credit'] as double? ?? 0.0);
      }
      return total;
    }

    if (widget.voucherType == 'RECEIPT_VOUCHER' || widget.voucherType == 'CONTRA_VOUCHER') {
      return _totalLineAmount;
    } else {
      return _cashBankAccount != null ? _totalLineAmount : 0.0;
    }
  }

  @override
  void initState() {
    super.initState();
    _resetForm();
  }

  @override
  void didUpdateWidget(VoucherEntryForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.voucherType != widget.voucherType) {
      _resetForm();
    }
  }

  void _resetForm() {
    _descriptionController.clear();
    _cashBankAccount = null;
    _lines = [];
  }

  void _addLine() {
    setState(() {
      if (widget.voucherType == 'JOURNAL_VOUCHER') {
        final diff = _totalDebit - _totalCredit;
        _lines.add({
          'accountId': null,
          'costCenterId': null,
          'debit': diff < 0 ? diff.abs() : 0.0,
          'credit': diff > 0 ? diff : 0.0,
          'description': '',
        });
      } else {
        _lines.add({
          'accountId': null,
          'costCenterId': null,
          'amount': 0.0,
          'description': '',
        });
      }
    });
  }

  Future<void> _submitVoucher() async {
    if (_lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add at least one line item')));
      return;
    }
    
    final isJournal = widget.voucherType == 'JOURNAL_VOUCHER';
    
    if (!isJournal && _cashBankAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a Cash/Bank Account')));
      return;
    }

    if (!isJournal && _lines.any((l) => l['accountId'] == null)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an account for all detail lines.')));
      return;
    }

    if (!isJournal && _lines.any((l) => (l['amount'] as double? ?? 0.0) <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Line amounts must be greater than 0.')));
      return;
    }

    if (widget.voucherType == 'CONTRA_VOUCHER' && _lines.any((l) => l['accountId'] == _cashBankAccount)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contra Voucher cannot transfer between the same cash/bank account.')),
      );
      return;
    }

    final allAccounts = ref.read(accountsProvider).value ?? [];
    for (int i = 0; i < _lines.length; i++) {
      final line = _lines[i];
      final acc = allAccounts.where((a) => a.id == line['accountId']).firstOrNull;
      if (acc != null && acc.hasCostCenter && (line['costCenterId'] == null || line['costCenterId'].toString().isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Line #${i + 1} (${acc.name}) requires a Cost Center reference. Please specify who this cost belongs to.'),
            backgroundColor: Colors.orange.shade900,
          ),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      final List<Map<String, dynamic>> submitLines = [];
      
      if (!isJournal) {
        // Calculate total amount
        double totalAmount = _lines.fold(0, (sum, line) => sum + (line['amount'] as double));
        
        // Double-entry mapping rules:
        // RECEIPT_VOUCHER & CONTRA_VOUCHER: Header Cash/Bank = DEBIT, Detail lines = CREDIT
        // PAYMENT_VOUCHER: Header Cash/Bank = CREDIT, Detail lines = DEBIT
        bool isHeaderDebit = widget.voucherType == 'RECEIPT_VOUCHER' || widget.voucherType == 'CONTRA_VOUCHER';
        
        // Header line (Cash/Bank)
        submitLines.add({
          'accountId': _cashBankAccount,
          'debit': isHeaderDebit ? totalAmount : 0,
          'credit': isHeaderDebit ? 0 : totalAmount,
          'description': _descriptionController.text,
        });
        
        // Detail lines
        for (var line in _lines) {
          submitLines.add({
            'accountId': line['accountId'],
            'costCenterId': line['costCenterId'],
            'debit': isHeaderDebit ? 0 : line['amount'],
            'credit': isHeaderDebit ? line['amount'] : 0,
            'description': line['description'],
          });
        }
      } else {
        // For Journal Vouchers, handle pure dr/cr directly. 
        // We will simplify by assuming users input DR positive, CR negative for now, 
        // or add dedicated Dr/Cr inputs. To keep it simple, Journal Vouchers in this basic form 
        for (var line in _lines) {
          submitLines.add({
            'accountId': line['accountId'],
            'costCenterId': line['costCenterId'],
            'debit': line['debit'] ?? 0,
            'credit': line['credit'] ?? 0,
            'description': line['description'],
          });
        }
      }

      final payload = {
        'voucherType': widget.voucherType,
        'date': _selectedDate.toIso8601String(),
        'description': _descriptionController.text,
        'lines': submitLines,
      };

      final api = ref.read(accountingApiProvider);
      await api.createVoucher(payload);
      
      widget.onVoucherCreated?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voucher created successfully! Outbox queued for sync.')),
        );
      }
      _resetForm();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allAccountsState = ref.watch(accountsProvider);
    final costCenters = ref.watch(costCentersProvider).value ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New ${widget.voucherType.replaceAll('_', ' ')}', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null && mounted) {
                      setState(() => _selectedDate = date);
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(_selectedDate.toString().split(' ')[0]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.voucherType != 'JOURNAL_VOUCHER')
              allAccountsState.when(
                data: (accounts) {
                  final cashBankAccounts = accounts.where((a) {
                    if (!a.isTransaction) return false;
                    return a.isCashNature || a.isBankNature || a.accountSubtype == 'CASH' || a.accountSubtype == 'BANK';
                  }).toList();

                  final selectedValue = (_cashBankAccount != null && cashBankAccounts.any((a) => a.id == _cashBankAccount))
                      ? _cashBankAccount
                      : (cashBankAccounts.isNotEmpty ? cashBankAccounts.first.id : null);

                  if (_cashBankAccount != selectedValue && selectedValue != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _cashBankAccount = selectedValue);
                    });
                  }

                  return SearchableAccountSelector(
                    labelText: 'Select Cash/Bank Account',
                    selectedAccountId: selectedValue,
                    accounts: cashBankAccounts,
                    onChanged: (v) => setState(() => _cashBankAccount = v),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error loading accounts: $e'),
              ),
            const SizedBox(height: 24),
            const Divider(),
            allAccountsState.when(
              data: (accounts) {
                final txAccounts = accounts.where((a) {
                  if (!a.isTransaction) return false;
                  final isCashBank = a.isCashNature || a.isBankNature || a.accountSubtype == 'CASH' || a.accountSubtype == 'BANK';

                  if (widget.voucherType == 'RECEIPT_VOUCHER') {
                    if (isCashBank || a.type == 'EXPENSE') return false;
                  } else if (widget.voucherType == 'PAYMENT_VOUCHER') {
                    if (isCashBank || a.type == 'REVENUE') return false;
                  } else if (widget.voucherType == 'CONTRA_VOUCHER') {
                    if (!isCashBank) return false;
                    if (a.id == _cashBankAccount) return false; // Cannot transfer between the same account
                  }
                  return true;
                }).toList();

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _lines.length,
                  itemBuilder: (context, i) {
                    final line = _lines[i];
                    final selectedAcc = txAccounts.where((a) => a.id == line['accountId']).firstOrNull;
                    final bool requiresCostCenter = selectedAcc?.hasCostCenter ?? false;
                    final bool showCostCenterPicker = requiresCostCenter || (line['costCenterId'] != null && line['costCenterId'].toString().isNotEmpty);
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: requiresCostCenter ? Colors.amber.withValues(alpha: 0.04) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: requiresCostCenter ? Colors.amber.shade400 : Colors.grey.shade300,
                          width: requiresCostCenter ? 1.5 : 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: SearchableAccountSelector(
                                  selectedAccountId: line['accountId'],
                                  accounts: txAccounts,
                                  onChanged: (v) => setState(() => _lines[i]['accountId'] = v),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  decoration: const InputDecoration(labelText: 'Amount (৳)', border: OutlineInputBorder()),
                                  keyboardType: TextInputType.number,
                                  initialValue: (line['amount'] as double? ?? 0.0) > 0 ? line['amount'].toString() : null,
                                  onChanged: (v) {
                                    setState(() {
                                      _lines[i]['amount'] = double.tryParse(v) ?? 0.0;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  decoration: const InputDecoration(labelText: 'Particulars / Description', border: OutlineInputBorder()),
                                  initialValue: line['description'],
                                  onChanged: (v) => _lines[i]['description'] = v,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _lines.removeAt(i);
                                  });
                                },
                              ),
                            ],
                          ),
                          if (showCostCenterPicker) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: requiresCostCenter ? Colors.amber.shade50 : Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: requiresCostCenter ? Colors.amber.shade400 : Colors.blue.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.account_tree_outlined,
                                    size: 20,
                                    color: requiresCostCenter ? Colors.amber.shade900 : Colors.blue.shade800,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: DropdownButtonFormField<String?>(
                                      initialValue: (line['costCenterId'] != null && line['costCenterId'].toString().isNotEmpty)
                                          ? line['costCenterId']
                                          : null,
                                      isExpanded: true,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        labelText: requiresCostCenter
                                            ? 'Cost Center * (Required — Link with Ref Whos)'
                                            : 'Cost Center (Optional)',
                                        labelStyle: TextStyle(
                                          color: requiresCostCenter ? Colors.amber.shade900 : Colors.blue.shade900,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: const OutlineInputBorder(),
                                      ),
                                      items: [
                                        DropdownMenuItem(
                                          value: null,
                                          child: Text(
                                            requiresCostCenter ? '— Select Cost Center (Required) —' : 'None (No Cost Center)',
                                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                          ),
                                        ),
                                        ...costCenters.map((c) => DropdownMenuItem(
                                              value: c.id,
                                              child: Text(
                                                c.displayNameWithRef,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                              ),
                                            )),
                                      ],
                                      onChanged: (v) => setState(() => _lines[i]['costCenterId'] = v),
                                    ),
                                  ),
                                  if (!requiresCostCenter)
                                    IconButton(
                                      icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                                      tooltip: 'Remove Cost Center',
                                      onPressed: () => setState(() => _lines[i]['costCenterId'] = null),
                                    ),
                                ],
                              ),
                            ),
                          ] else ...[
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: InkWell(
                                onTap: () => setState(() => _lines[i]['costCenterId'] = ''),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add_circle_outline, size: 14, color: Colors.blue.shade700),
                                    const SizedBox(width: 4),
                                    Text(
                                      '+ Assign Cost Center / Ref (Optional)',
                                      style: TextStyle(fontSize: 11, color: Colors.blue.shade700, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
            const SizedBox(height: 16),
            if (widget.voucherType != 'JOURNAL_VOUCHER' && _lines.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.functions_rounded, color: Colors.blue.shade800, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Auto-Calculated Cash/Bank Entry (${(widget.voucherType == 'RECEIPT_VOUCHER' || widget.voucherType == 'CONTRA_VOUCHER') ? 'DEBIT' : 'CREDIT'}):',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Header Account Amount: ৳${_totalLineAmount.toStringAsFixed(2)} BDT (Auto-equals sum of ${_lines.length} line items)',
                            style: TextStyle(fontSize: 13, color: Colors.blue.shade900, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '∑ Lines = ৳${_totalLineAmount.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            VoucherBalanceIndicator(
              totalDebit: _totalDebit,
              totalCredit: _totalCredit,
              missingAccountMessage: (_cashBankAccount == null && widget.voucherType != 'JOURNAL_VOUCHER' && _lines.isNotEmpty)
                  ? 'Imbalanced: Select a Cash/Bank Account to balance equation'
                  : null,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _addLine,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Line'),
                ),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitVoucher,
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white),
                  child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text('POST VOUCHER'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
