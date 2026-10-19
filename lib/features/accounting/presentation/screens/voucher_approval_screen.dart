import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erp_frontend/app.dart';
import 'package:erp_frontend/features/accounting/providers/accounting_providers.dart';
import 'package:erp_frontend/features/accounting/utils/voucher_pdf_exporter.dart';
import 'package:erp_frontend/features/accounting/utils/number_to_words_converter.dart';

class VoucherApprovalScreen extends ConsumerStatefulWidget {
  const VoucherApprovalScreen({super.key});

  @override
  ConsumerState<VoucherApprovalScreen> createState() => _VoucherApprovalScreenState();
}

class _VoucherApprovalScreenState extends ConsumerState<VoucherApprovalScreen> {
  bool _isProcessing = false;

  // View & Control States
  String _viewMode = 'TABLE'; // 'TABLE' | 'CARD' | 'GRID'
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String _selectedTypeFilter = 'ALL'; // 'ALL' | 'PAYMENT_VOUCHER' | 'RECEIPT_VOUCHER' | 'CONTRA_VOUCHER' | 'JOURNAL_VOUCHER'
  String _selectedStatusFilter = 'ALL'; // 'ALL' | 'PENDING' | 'APPROVED' | 'REJECTED'
  String _sortBy = 'DATE'; // 'DATE' | 'AMOUNT' | 'NUMBER' | 'MAKER'
  bool _sortAscending = false;

  // Table Column Visibility Toggle State
  final Map<String, bool> _visibleColumns = {
    'voucherNo': true,
    'type': true,
    'date': true,
    'maker': true,
    'narration': true,
    'amount': true,
    'status': true,
    'actions': true,
  };

  // Static sample vouchers for demonstration when DB is empty
  final List<Map<String, dynamic>> _sampleVouchers = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredAndSortedVouchers(List<Map<String, dynamic>> rawList) {
    var list = List<Map<String, dynamic>>.from(rawList);

    // 1. Search Query Filter
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((v) {
        final no = (v['voucherNumber'] ?? '').toString().toLowerCase();
        final maker = (v['makerName'] ?? '').toString().toLowerCase();
        final narration = (v['narration'] ?? '').toString().toLowerCase();
        return no.contains(q) || maker.contains(q) || narration.contains(q);
      }).toList();
    }

    // 2. Voucher Type Filter
    if (_selectedTypeFilter != 'ALL') {
      list = list.where((v) {
        final t = (v['voucherType'] ?? '').toString().toUpperCase();
        return t == _selectedTypeFilter;
      }).toList();
    }

    // 3. Status Filter
    if (_selectedStatusFilter != 'ALL') {
      if (_selectedStatusFilter == 'PENDING') {
        list = list.where((v) {
          final s = (v['status'] ?? '').toString().toUpperCase();
          return s == 'DRAFT' || s == 'SUBMITTED' || s == 'PENDING';
        }).toList();
      } else {
        list = list.where((v) {
          final s = (v['status'] ?? '').toString().toUpperCase();
          return s == _selectedStatusFilter;
        }).toList();
      }
    }

    // 4. Sorting Logic
    list.sort((a, b) {
      int cmp = 0;
      switch (_sortBy) {
        case 'DATE':
          final da = a['voucherDate'] ?? '';
          final db = b['voucherDate'] ?? '';
          cmp = da.compareTo(db);
          break;
        case 'AMOUNT':
          final amta = (a['totalAmount'] as num? ?? 0).toDouble();
          final amtb = (b['totalAmount'] as num? ?? 0).toDouble();
          cmp = amta.compareTo(amtb);
          break;
        case 'NUMBER':
          final na = a['voucherNumber'] ?? '';
          final nb = b['voucherNumber'] ?? '';
          cmp = na.compareTo(nb);
          break;
        case 'MAKER':
          final ma = a['makerName'] ?? '';
          final mb = b['makerName'] ?? '';
          cmp = ma.compareTo(mb);
          break;
      }
      return _sortAscending ? cmp : -cmp;
    });

    return list;
  }

  Future<void> _approveVoucher(Map<String, dynamic> voucher, bool isArabic) async {
    final voucherId = voucher['id']?.toString() ?? '';
    final voucherNo = voucher['voucherNumber'] ?? 'Voucher';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.green),
            const SizedBox(width: 10),
            Text(isArabic ? 'تأكيد اعتماد السند' : 'Confirm Voucher Approval'),
          ],
        ),
        content: Text(
          isArabic
              ? 'هل أنت تأكد من اعتماد السند رقم ($voucherNo) وتأثيره المباشر على الأستاذ العام؟'
              : 'Are you sure you want to approve voucher ($voucherNo)? Ledger balances will immediately update upon approval.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(isArabic ? 'إلغاء' : 'Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: Text(isArabic ? 'اعتماد ونشر' : 'Approve & Post'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);
    try {
      final api = ref.read(accountingApiProvider);
      await api.updateVoucherStatus({
        'id': voucherId,
        'status': 'APPROVED',
      });

      ref.invalidate(pendingVouchersProvider);
      ref.invalidate(vouchersProvider(null));
      ref.invalidate(ledgerProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isArabic ? 'تم اعتماد السند بنجاح وتحديث الأستاذ العام!' : 'Voucher $voucherNo approved successfully! General Ledger updated.'),
            backgroundColor: Colors.green.shade800,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error approving voucher: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _rejectVoucher(Map<String, dynamic> voucher, bool isArabic) async {
    final voucherId = voucher['id']?.toString() ?? '';
    final voucherNo = voucher['voucherNumber'] ?? 'Voucher';
    final reasonController = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.cancel_rounded, color: Colors.red),
            const SizedBox(width: 10),
            Text(isArabic ? 'رفض السند المالي' : 'Reject Voucher'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic
                  ? 'يرجى إدخال سبب رفض السند ($voucherNo) لإرسال التنبيه للكاشير:'
                  : 'Please enter the rejection reason for voucher ($voucherNo):',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: isArabic ? 'سبب الرفض (مثال: عدم توازن الخزينة، خطأ في الحساب)' : 'Reason (e.g., incorrect account, missing attachment)',
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(isArabic ? 'إلغاء' : 'Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: Text(isArabic ? 'تأكيد الرفض' : 'Reject Voucher'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);
    try {
      final api = ref.read(accountingApiProvider);
      await api.updateVoucherStatus({
        'id': voucherId,
        'status': 'REJECTED',
        'remarks': reasonController.text.isNotEmpty ? reasonController.text : 'Rejected by Accountant',
      });

      ref.invalidate(pendingVouchersProvider);
      ref.invalidate(vouchersProvider(null));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isArabic ? 'تم رفض السند وتوجيهه للإعادة إلى الكاشير.' : 'Voucher $voucherNo rejected.'),
            backgroundColor: Colors.orange.shade800,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rejecting voucher: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showVoucherDetailsModal(Map<String, dynamic> voucher, bool isArabic) {
    showDialog(
      context: context,
      builder: (context) {
        final lines = List<Map<String, dynamic>>.from(voucher['lines'] ?? []);
        double totalDebit = 0;
        double totalCredit = 0;
        for (var l in lines) {
          totalDebit += (l['debit'] as num? ?? 0).toDouble();
          totalCredit += (l['credit'] as num? ?? 0).toDouble();
        }

        final statusStr = (voucher['status'] ?? 'DRAFT').toString().toUpperCase();
        final isPending = statusStr == 'DRAFT' || statusStr == 'SUBMITTED' || statusStr == 'PENDING';

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 720),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.rule_folder_rounded, color: Colors.amber.shade900, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              voucher['voucherNumber'] ?? 'Voucher Detail',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text(
                              '${voucher['voucherType']} • Created by: ${voucher['makerName'] ?? "Cashier"}',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  isArabic ? 'تفاصيل الحركة والقيد المزدوج:' : 'Transaction & Double-Entry Line Items:',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1.2),
                      1: FlexColumnWidth(2.5),
                      2: FlexColumnWidth(1.2),
                      3: FlexColumnWidth(1.2),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: Colors.grey.shade100),
                        children: [
                          Padding(padding: const EdgeInsets.all(8), child: Text(isArabic ? 'كود الحساب' : 'Code', style: const TextStyle(fontWeight: FontWeight.bold))),
                          Padding(padding: const EdgeInsets.all(8), child: Text(isArabic ? 'اسم الحساب' : 'Account Name', style: const TextStyle(fontWeight: FontWeight.bold))),
                          Padding(padding: const EdgeInsets.all(8), child: Text(isArabic ? 'مدين (Dr)' : 'Debit (৳)', style: const TextStyle(fontWeight: FontWeight.bold))),
                          Padding(padding: const EdgeInsets.all(8), child: Text(isArabic ? 'دائن (Cr)' : 'Credit (৳)', style: const TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                      ...lines.map((l) => TableRow(
                            children: [
                              Padding(padding: const EdgeInsets.all(8), child: Text(l['code'] ?? 'N/A')),
                              Padding(padding: const EdgeInsets.all(8), child: Text(l['accountName'] ?? '')),
                              Padding(padding: const EdgeInsets.all(8), child: Text(((l['debit'] as num? ?? 0) > 0) ? '৳${l['debit']}' : '-')),
                              Padding(padding: const EdgeInsets.all(8), child: Text(((l['credit'] as num? ?? 0) > 0) ? '৳${l['credit']}' : '-')),
                            ],
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.verified_user_rounded, color: Colors.green.shade800, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            isArabic ? 'معادلة القيد متوازنة:' : 'Double-Entry Invariant Status:',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade900, fontSize: 13),
                          ),
                        ],
                      ),
                      Text(
                        'Total Dr ৳${totalDebit.toStringAsFixed(2)} == Total Cr ৳${totalCredit.toStringAsFixed(2)}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade900, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.currency_exchange, color: Colors.blue.shade800, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic ? 'المبلغ بالكلمات:' : 'Amount in Words:',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900, fontSize: 11),
                            ),
                            Text(
                              NumberToWordsConverter.convert(totalDebit),
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade900, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        VoucherPdfExporter.printOrSaveVoucher(
                          context,
                          voucherNumber: voucher['voucherNumber'] ?? 'V-001',
                          voucherType: voucher['voucherType'] ?? 'VOUCHER',
                          dateStr: voucher['voucherDate'] ?? '',
                          fiscalYear: voucher['fiscalYear'] ?? '2026-2027',
                          periodNumber: (voucher['periodNumber'] as int?) ?? 4,
                          narration: voucher['narration'] ?? '',
                          totalAmount: totalDebit,
                          lines: lines,
                          status: voucher['status'] ?? 'PENDING',
                          chequeNumber: voucher['chequeNumber'],
                          payeeName: voucher['payeeName'],
                        );
                      },
                      icon: const Icon(Icons.print),
                      label: Text(isArabic ? 'طباعة / PDF' : 'Print PDF'),
                    ),
                    if (isPending) const SizedBox(width: 12),
                    if (isPending)
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                        onPressed: () {
                          Navigator.pop(context);
                          _rejectVoucher(voucher, isArabic);
                        },
                        icon: const Icon(Icons.close),
                        label: Text(isArabic ? 'رفض السند' : 'Reject Voucher'),
                      ),
                    if (isPending) const SizedBox(width: 12),
                    if (isPending)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                          _approveVoucher(voucher, isArabic);
                        },
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text(isArabic ? 'اعتماد ونشر في الأستاذ' : 'Approve & Post to GL'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showColumnVisibilityDialog(bool isArabic) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.view_column_rounded, color: Colors.indigo),
                  const SizedBox(width: 10),
                  Text(isArabic ? 'تحديد الأعمدة الظاهرة' : 'Configure Column Visibility'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildColumnToggleTile('voucherNo', isArabic ? 'رقم السند' : 'Voucher No', setModalState),
                    _buildColumnToggleTile('type', isArabic ? 'نوع السند' : 'Voucher Type', setModalState),
                    _buildColumnToggleTile('date', isArabic ? 'التاريخ' : 'Date', setModalState),
                    _buildColumnToggleTile('maker', isArabic ? 'الكاشير / المدخل' : 'Maker / Cashier', setModalState),
                    _buildColumnToggleTile('narration', isArabic ? 'البيان' : 'Particulars / Narration', setModalState),
                    _buildColumnToggleTile('amount', isArabic ? 'المبلغ (৳)' : 'Total Amount', setModalState),
                    _buildColumnToggleTile('status', isArabic ? 'الحالة' : 'Approval Status', setModalState),
                    _buildColumnToggleTile('actions', isArabic ? 'زر الإجراءات' : 'Actions Button', setModalState),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(isArabic ? 'إغلاق' : 'Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildColumnToggleTile(String key, String title, StateSetter setModalState) {
    return CheckboxListTile(
      value: _visibleColumns[key] ?? true,
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      dense: true,
      activeColor: Colors.indigo.shade700,
      onChanged: (val) {
        if (val != null) {
          setState(() => _visibleColumns[key] = val);
          setModalState(() {});
        }
      },
    );
  }

  Widget _buildStatusChip(String status, bool isArabic) {
    Color bg;
    Color fg;
    String label;

    final s = status.toUpperCase();
    if (s == 'APPROVED' || s == 'POSTED') {
      bg = Colors.green.shade50;
      fg = Colors.green.shade800;
      label = isArabic ? 'معتمد ومرحل' : 'POSTED / APPROVED';
    } else if (s == 'REJECTED') {
      bg = Colors.red.shade50;
      fg = Colors.red.shade800;
      label = isArabic ? 'مرفوض' : 'REJECTED';
    } else {
      bg = Colors.amber.shade50;
      fg = Colors.amber.shade900;
      label = isArabic ? 'بانتظار الاعتماد' : 'PENDING APPROVAL';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    Color bg;
    Color fg;

    final t = type.toUpperCase();
    if (t.contains('PAYMENT') || t == 'PV') {
      bg = Colors.red.shade50;
      fg = Colors.red.shade700;
    } else if (t.contains('RECEIPT') || t == 'RV') {
      bg = Colors.green.shade50;
      fg = Colors.green.shade700;
    } else if (t.contains('CONTRA') || t == 'CV') {
      bg = Colors.purple.shade50;
      fg = Colors.purple.shade700;
    } else {
      bg = Colors.amber.shade50;
      fg = Colors.amber.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type.replaceAll('_', ' '),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final vouchersAsync = ref.watch(vouchersProvider(null));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(isArabic ? 'مركز اعتماد السندات المالية (Maker-Checker)' : 'Voucher Approval Center'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Queue',
            onPressed: () {
              ref.invalidate(vouchersProvider(null));
              ref.invalidate(pendingVouchersProvider);
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isProcessing) const LinearProgressIndicator(),
            if (_isProcessing) const SizedBox(height: 12),

            // Governance Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade900, Colors.orange.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.amber.shade900.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic ? 'مركز اعتماد السندات والتفتيش المحاسبي' : 'Voucher Approval & Governance Center',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isArabic
                              ? ' مراجعة واعتماد سندات الكاشير ومبيعات POS قبل ترحيل التأثير المالي النهائي في الأستاذ العام (Maker-Checker Control).'
                              : 'Review and approve cashier manual entries & POS Day-End vouchers before final General Ledger balance posting.',
                          style: TextStyle(color: Colors.amber.shade100, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Queue Statistics Cards
            vouchersAsync.when(
              data: (dbList) {
                final allList = dbList.isNotEmpty ? dbList : _sampleVouchers;
                final pendingList = allList.where((v) {
                  final s = (v['status'] ?? '').toString().toUpperCase();
                  return s == 'DRAFT' || s == 'SUBMITTED' || s == 'PENDING';
                }).toList();

                final approvedList = allList.where((v) {
                  final s = (v['status'] ?? '').toString().toUpperCase();
                  return s == 'APPROVED' || s == 'POSTED';
                }).toList();

                double pendingAmt = 0;
                for (var v in pendingList) {
                  pendingAmt += (v['totalAmount'] as num? ?? 0).toDouble();
                }

                double approvedAmt = 0;
                for (var v in approvedList) {
                  approvedAmt += (v['totalAmount'] as num? ?? 0).toDouble();
                }

                return Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: isArabic ? 'السندات بانتظار الاعتماد' : 'Pending Approval Queue',
                        value: '${pendingList.length} Vouchers (৳${pendingAmt.toStringAsFixed(0)})',
                        icon: Icons.hourglass_top_rounded,
                        color: Colors.amber.shade800,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricCard(
                        title: isArabic ? 'السندات المعتمدة والمرحلة' : 'Total Approved & Posted',
                        value: '${approvedList.length} Vouchers (৳${approvedAmt.toStringAsFixed(0)})',
                        icon: Icons.check_circle_rounded,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricCard(
                        title: isArabic ? 'وضع الضوابط المالي' : 'Control Governance Mode',
                        value: isArabic ? 'مراجعة ثنائية نشطة' : 'Maker-Checker Active',
                        icon: Icons.security_rounded,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error loading stats: $e'),
            ),
            const SizedBox(height: 24),

            // Powerful Control Toolbar (Search, Filter, Sorting, Column Visibility, View Mode Toggle)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Search Bar
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) => setState(() => _searchQuery = val),
                            decoration: InputDecoration(
                              hintText: isArabic ? 'بحث برقم السند، البيان، أو اسم المدخل...' : 'Search by Voucher No, Narration, or Maker...',
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Voucher Type Filter
                        DropdownButtonHideUnderline(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DropdownButton<String>(
                              value: _selectedTypeFilter,
                              icon: const Icon(Icons.arrow_drop_down),
                              items: [
                                DropdownMenuItem(value: 'ALL', child: Text(isArabic ? 'جميع أنواع السندات' : 'All Voucher Types')),
                                DropdownMenuItem(value: 'PAYMENT_VOUCHER', child: Text(isArabic ? 'سندات صرف (PV)' : 'Payment Vouchers (PV)')),
                                DropdownMenuItem(value: 'RECEIPT_VOUCHER', child: Text(isArabic ? 'سندات قبض (RV)' : 'Receipt Vouchers (RV)')),
                                DropdownMenuItem(value: 'CONTRA_VOUCHER', child: Text(isArabic ? 'سندات تحويل (CV)' : 'Contra Vouchers (CV)')),
                                DropdownMenuItem(value: 'JOURNAL_VOUCHER', child: Text(isArabic ? 'قيود يومية (JV)' : 'Journal Vouchers (JV)')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedTypeFilter = val);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Sort By Dropdown
                        DropdownButtonHideUnderline(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DropdownButton<String>(
                              value: _sortBy,
                              icon: const Icon(Icons.sort_rounded),
                              items: [
                                DropdownMenuItem(value: 'DATE', child: Text(isArabic ? 'ترتيب: التاريخ' : 'Sort by: Date')),
                                DropdownMenuItem(value: 'AMOUNT', child: Text(isArabic ? 'ترتيب: المبلغ' : 'Sort by: Amount')),
                                DropdownMenuItem(value: 'NUMBER', child: Text(isArabic ? 'ترتيب: رقم السند' : 'Sort by: Voucher No')),
                                DropdownMenuItem(value: 'MAKER', child: Text(isArabic ? 'ترتيب: اسم المدخل' : 'Sort by: Maker')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _sortBy = val);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),

                        // Ascending / Descending Toggle
                        IconButton(
                          icon: Icon(_sortAscending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded),
                          tooltip: _sortAscending ? 'Sort Ascending' : 'Sort Descending',
                          onPressed: () => setState(() => _sortAscending = !_sortAscending),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Status Chips & View Mode Controls Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Status Filter Chips
                        Wrap(
                          spacing: 8,
                          children: [
                            ChoiceChip(
                              label: Text(isArabic ? 'الكل' : 'All Vouchers'),
                              selected: _selectedStatusFilter == 'ALL',
                              onSelected: (_) => setState(() => _selectedStatusFilter = 'ALL'),
                              selectedColor: Colors.indigo.shade100,
                            ),
                            ChoiceChip(
                              label: Text(isArabic ? 'بانتظار الاعتماد' : 'Pending Approval'),
                              selected: _selectedStatusFilter == 'PENDING',
                              onSelected: (_) => setState(() => _selectedStatusFilter = 'PENDING'),
                              selectedColor: Colors.amber.shade100,
                            ),
                            ChoiceChip(
                              label: Text(isArabic ? 'المعتمدة والمرحلة' : 'Approved & Posted'),
                              selected: _selectedStatusFilter == 'APPROVED',
                              onSelected: (_) => setState(() => _selectedStatusFilter = 'APPROVED'),
                              selectedColor: Colors.green.shade100,
                            ),
                            ChoiceChip(
                              label: Text(isArabic ? 'المرفوضة' : 'Rejected'),
                              selected: _selectedStatusFilter == 'REJECTED',
                              onSelected: (_) => setState(() => _selectedStatusFilter = 'REJECTED'),
                              selectedColor: Colors.red.shade100,
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            // Column Visibility Button (Only active for Table view)
                            if (_viewMode == 'TABLE')
                              OutlinedButton.icon(
                                onPressed: () => _showColumnVisibilityDialog(isArabic),
                                icon: const Icon(Icons.view_column_rounded, size: 18),
                                label: Text(isArabic ? 'الأعمدة' : 'Columns'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            if (_viewMode == 'TABLE') const SizedBox(width: 12),

                            // View Mode Segmented Buttons (Table / Card / Grid)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.table_chart_rounded),
                                    tooltip: isArabic ? 'عرض كجدول' : 'Table View',
                                    color: _viewMode == 'TABLE' ? Colors.indigo.shade800 : Colors.grey.shade700,
                                    onPressed: () => setState(() => _viewMode = 'TABLE'),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.view_agenda_rounded),
                                    tooltip: isArabic ? 'عرض كبطاقات' : 'Card View',
                                    color: _viewMode == 'CARD' ? Colors.indigo.shade800 : Colors.grey.shade700,
                                    onPressed: () => setState(() => _viewMode = 'CARD'),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.grid_view_rounded),
                                    tooltip: isArabic ? 'عرض كشبكة' : 'Grid View',
                                    color: _viewMode == 'GRID' ? Colors.indigo.shade800 : Colors.grey.shade700,
                                    onPressed: () => setState(() => _viewMode = 'GRID'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Main Vouchers Rendering (Table / Card / Grid)
            vouchersAsync.when(
              data: (dbList) {
                final rawList = dbList;
                final filteredList = _getFilteredAndSortedVouchers(rawList);

                if (filteredList.isEmpty) {
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(48.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.search_off_rounded, size: 56, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              isArabic ? 'لا توجد سندات تطابق خيارات البحث والتصفية المختارة.' : 'No vouchers found matching the selected filter criteria.',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                if (_viewMode == 'CARD') {
                  return _buildCardView(filteredList, isArabic);
                } else if (_viewMode == 'GRID') {
                  return _buildGridView(filteredList, isArabic);
                } else {
                  return _buildTableView(filteredList, isArabic);
                }
              },
              loading: () => const Padding(padding: EdgeInsets.all(40.0), child: Center(child: CircularProgressIndicator())),
              error: (e, _) => Text('Error loading vouchers: $e', style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  // --- 1. TABLE VIEW ---
  Widget _buildTableView(List<Map<String, dynamic>> vouchers, bool isArabic) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
            columns: [
              if (_visibleColumns['voucherNo'] == true)
                DataColumn(label: Text(isArabic ? 'رقم السند' : 'Voucher No', style: const TextStyle(fontWeight: FontWeight.bold))),
              if (_visibleColumns['type'] == true)
                DataColumn(label: Text(isArabic ? 'النوع' : 'Type', style: const TextStyle(fontWeight: FontWeight.bold))),
              if (_visibleColumns['date'] == true)
                DataColumn(label: Text(isArabic ? 'التاريخ' : 'Date', style: const TextStyle(fontWeight: FontWeight.bold))),
              if (_visibleColumns['maker'] == true)
                DataColumn(label: Text(isArabic ? 'الكاشير / المدخل' : 'Maker / Cashier', style: const TextStyle(fontWeight: FontWeight.bold))),
              if (_visibleColumns['narration'] == true)
                DataColumn(label: Text(isArabic ? 'البيان' : 'Particulars', style: const TextStyle(fontWeight: FontWeight.bold))),
              if (_visibleColumns['amount'] == true)
                DataColumn(numeric: true, label: Text(isArabic ? 'المبلغ (৳)' : 'Amount (৳)', style: const TextStyle(fontWeight: FontWeight.bold))),
              if (_visibleColumns['status'] == true)
                DataColumn(label: Text(isArabic ? 'الحالة' : 'Status', style: const TextStyle(fontWeight: FontWeight.bold))),
              if (_visibleColumns['actions'] == true)
                DataColumn(label: Text(isArabic ? 'الإجراءات' : 'Actions', style: const TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: vouchers.map((v) {
              final amt = (v['totalAmount'] as num? ?? 0).toDouble();
              final statusStr = (v['status'] ?? 'DRAFT').toString().toUpperCase();
              final isPending = statusStr == 'DRAFT' || statusStr == 'SUBMITTED' || statusStr == 'PENDING';

              return DataRow(cells: [
                if (_visibleColumns['voucherNo'] == true)
                  DataCell(Text(v['voucherNumber'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace'))),
                if (_visibleColumns['type'] == true)
                  DataCell(_buildTypeChip((v['voucherType'] ?? 'PV').toString())),
                if (_visibleColumns['date'] == true)
                  DataCell(Text(v['voucherDate'] ?? '')),
                if (_visibleColumns['maker'] == true)
                  DataCell(Text(v['makerName'] ?? 'Cashier User')),
                if (_visibleColumns['narration'] == true)
                  DataCell(Text(v['narration'] ?? '')),
                if (_visibleColumns['amount'] == true)
                  DataCell(Text('৳${amt.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold))),
                if (_visibleColumns['status'] == true)
                  DataCell(_buildStatusChip(statusStr, isArabic)),
                if (_visibleColumns['actions'] == true)
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility_rounded, color: Colors.blue),
                          tooltip: isArabic ? 'معاينة القيد' : 'Review Details',
                          onPressed: () => _showVoucherDetailsModal(v, isArabic),
                        ),
                        if (isPending)
                          IconButton(
                            icon: const Icon(Icons.check_circle_rounded, color: Colors.green),
                            tooltip: isArabic ? 'اعتماد وتأكيد' : 'Approve & Post',
                            onPressed: () => _approveVoucher(v, isArabic),
                          ),
                        if (isPending)
                          IconButton(
                            icon: const Icon(Icons.cancel_rounded, color: Colors.red),
                            tooltip: isArabic ? 'رفض' : 'Reject Voucher',
                            onPressed: () => _rejectVoucher(v, isArabic),
                          ),
                      ],
                    ),
                  ),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  // --- 2. CARD VIEW ---
  Widget _buildCardView(List<Map<String, dynamic>> vouchers, bool isArabic) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: vouchers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final v = vouchers[index];
        final amt = (v['totalAmount'] as num? ?? 0).toDouble();
        final statusStr = (v['status'] ?? 'DRAFT').toString().toUpperCase();
        final isPending = statusStr == 'DRAFT' || statusStr == 'SUBMITTED' || statusStr == 'PENDING';

        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          v['voucherNumber'] ?? 'N/A',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'monospace'),
                        ),
                        const SizedBox(width: 10),
                        _buildTypeChip((v['voucherType'] ?? 'PV').toString()),
                        const SizedBox(width: 8),
                        _buildStatusChip(statusStr, isArabic),
                      ],
                    ),
                    Text(
                      '৳${amt.toStringAsFixed(2)} BDT',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.indigo.shade800),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.person_outline_rounded, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text('${isArabic ? "المدخل:" : "Maker:"} ${v['makerName'] ?? "Cashier"}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                    const SizedBox(width: 20),
                    Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text('${v['voucherDate'] ?? ""}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  v['narration'] ?? 'No narration provided',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _showVoucherDetailsModal(v, isArabic),
                      icon: const Icon(Icons.visibility_rounded, size: 16),
                      label: Text(isArabic ? 'معاينة القيد' : 'Review Details'),
                    ),
                    if (isPending) const SizedBox(width: 10),
                    if (isPending)
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                        onPressed: () => _rejectVoucher(v, isArabic),
                        icon: const Icon(Icons.cancel_outlined, size: 16),
                        label: Text(isArabic ? 'رفض' : 'Reject'),
                      ),
                    if (isPending) const SizedBox(width: 10),
                    if (isPending)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                        onPressed: () => _approveVoucher(v, isArabic),
                        icon: const Icon(Icons.check_circle_outline, size: 16),
                        label: Text(isArabic ? 'اعتماد ونشر' : 'Approve & Post'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- 3. GRID VIEW ---
  Widget _buildGridView(List<Map<String, dynamic>> vouchers, bool isArabic) {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 1200 ? 3 : (screenWidth > 750 ? 2 : 1);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.45,
      ),
      itemCount: vouchers.length,
      itemBuilder: (context, index) {
        final v = vouchers[index];
        final amt = (v['totalAmount'] as num? ?? 0).toDouble();
        final statusStr = (v['status'] ?? 'DRAFT').toString().toUpperCase();
        final isPending = statusStr == 'DRAFT' || statusStr == 'SUBMITTED' || statusStr == 'PENDING';

        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          v['voucherNumber'] ?? 'N/A',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'monospace'),
                        ),
                        _buildStatusChip(statusStr, isArabic),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTypeChip((v['voucherType'] ?? 'PV').toString()),
                        Text(
                          '৳${amt.toStringAsFixed(2)}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo.shade800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    Text(
                      v['narration'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${v['makerName'] ?? "Cashier"} • ${v['voucherDate'] ?? ""}',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility_rounded, color: Colors.blue, size: 20),
                      tooltip: isArabic ? 'معاينة القيد' : 'Review Details',
                      onPressed: () => _showVoucherDetailsModal(v, isArabic),
                    ),
                    if (isPending)
                      IconButton(
                        icon: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
                        tooltip: isArabic ? 'اعتماد' : 'Approve',
                        onPressed: () => _approveVoucher(v, isArabic),
                      ),
                    if (isPending)
                      IconButton(
                        icon: const Icon(Icons.cancel_rounded, color: Colors.red, size: 20),
                        tooltip: isArabic ? 'رفض' : 'Reject',
                        onPressed: () => _rejectVoucher(v, isArabic),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
