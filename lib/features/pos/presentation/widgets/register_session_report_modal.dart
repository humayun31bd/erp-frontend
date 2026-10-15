import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/counter_session_model.dart';
import '../../providers/counter_session_provider.dart';
import '../../providers/receipt_printer_service.dart';
import '../../../../features/settings/providers/hardware_provider.dart';

class RegisterSessionReportModal extends ConsumerStatefulWidget {
  final CounterSessionModel? session;
  final String counterName;
  final String cashierName;

  const RegisterSessionReportModal({
    super.key,
    this.session,
    this.counterName = 'Main Checkout Counter #1',
    this.cashierName = 'Lead Operator',
  });

  @override
  ConsumerState<RegisterSessionReportModal> createState() => _RegisterSessionReportModalState();
}

class _RegisterSessionReportModalState extends ConsumerState<RegisterSessionReportModal> {
  final TextEditingController _actualCashController = TextEditingController();
  final TextEditingController _dueCollectionController = TextEditingController(text: '0.00');
  final TextEditingController _cashExpenseController = TextEditingController(text: '0.00');
  bool _isArabic = false;

  @override
  void initState() {
    super.initState();
    // Default actual cash counted to expected cash if session available
    if (widget.session != null) {
      final opening = double.tryParse(widget.session!.openingBalance) ?? 0.0;
      final sales = double.tryParse(widget.session!.cashSales) ?? 0.0;
      _actualCashController.text = (opening + sales).toStringAsFixed(2);
    } else {
      _actualCashController.text = '500.00';
    }
  }

  @override
  void dispose() {
    _actualCashController.dispose();
    _dueCollectionController.dispose();
    _cashExpenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final openedAt = widget.session?.openedAt.toLocal() ?? now.subtract(const Duration(hours: 7, minutes: 30));
    final closedAt = now;
    final duration = closedAt.difference(openedAt);

    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    // Financial Metrics Calculation
    final openingBalance = double.tryParse(widget.session?.openingBalance ?? '500.00') ?? 500.00;
    final cashSales = double.tryParse(widget.session?.cashSales ?? '1450.00') ?? 1450.00;
    final cardSales = 1200.00;
    final creditSales = 400.00;
    final dueCollection = double.tryParse(_dueCollectionController.text) ?? 0.0;
    final cashRefund = 120.00;
    final cashExpense = double.tryParse(_cashExpenseController.text) ?? 0.0;

    // 1. Cash Drawer Calculations
    final expectedCashInDrawer = openingBalance + cashSales + dueCollection - cashRefund - cashExpense;
    final actualCash = double.tryParse(_actualCashController.text) ?? expectedCashInDrawer;
    final cashVariance = actualCash - expectedCashInDrawer;

    // 2. Sales Summary
    final grossSales = cashSales + cardSales + creditSales; // Total Invoiced
    final totalRefund = cashRefund;
    final netSales = grossSales - totalRefund;

    // 3. Payment Collected
    final totalCollected = cashSales + cardSales + dueCollection;

    // 4. Outstanding Receivables
    final pendingFromCustomers = grossSales - totalCollected - dueCollection;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: 780,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header & Language Switcher
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isArabic ? 'تقرير إغلاق الوردية والحسابات (Z-Report)' : 'Terminal Session Closing & Register Audit',
                        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isArabic ? 'ملخص الصندوق، المبيعات، والتحصيلات المستحقة' : 'Cash drawer reconciliation, sales summary & customer receivables',
                        style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(_isArabic ? Icons.language : Icons.g_translate, color: const Color(0xFF2563EB)),
                    tooltip: _isArabic ? 'Switch to English' : 'التحويل للعربية',
                    onPressed: () => setState(() => _isArabic = !_isArabic),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Register Details Box (Date & Time Display)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMetaDetail(Icons.point_of_sale_rounded, _isArabic ? 'المنصة / الصندوق:' : 'Register:', widget.counterName),
                            _buildMetaDetail(Icons.person_outline_rounded, _isArabic ? 'أمين الصندوق:' : 'Cashier:', widget.cashierName),
                            _buildMetaDetail(Icons.event_available_rounded, _isArabic ? 'وقت الفتح:' : 'Opened:', dateFormat.format(openedAt)),
                            _buildMetaDetail(Icons.event_busy_rounded, _isArabic ? 'وقت الإغلاق:' : 'Closed:', dateFormat.format(closedAt)),
                            _buildMetaDetail(Icons.timer_outlined, _isArabic ? 'المدة:' : 'Duration:', '${duration.inHours}h ${duration.inMinutes % 60}m'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 2-Column Financial Grid
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Column: Cash Drawer Summary & Actual Count
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF2563EB), size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        _isArabic ? 'ملخص الصندوق النقدي (Cash Drawer Summary)' : 'Cash Drawer Summary',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 20),

                                  _buildFinanceRow(_isArabic ? 'الرصيد الافتتاحي (Opening Balance)' : 'Opening Balance', '+ SAR ${openingBalance.toStringAsFixed(2)}', isBold: true),
                                  _buildFinanceRow(_isArabic ? '+ مبيعات نقدية مستلمة (Sales)' : '+ Cash Received (Sales)', '+ SAR ${cashSales.toStringAsFixed(2)}', color: const Color(0xFF16A34A)),
                                  
                                  // Interactive Due Collection Input
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(_isArabic ? '+ تحصيل ديون سابقة (Due Payment)' : '+ Cash Received from (Due Payment)', style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155))),
                                      SizedBox(
                                        width: 90,
                                        height: 32,
                                        child: TextField(
                                          controller: _dueCollectionController,
                                          keyboardType: TextInputType.number,
                                          onChanged: (_) => setState(() {}),
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                          decoration: InputDecoration(
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                            fillColor: const Color(0xFFF1F5F9),
                                            filled: true,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),

                                  _buildFinanceRow(_isArabic ? '- مرتجعات نقدية (Cash Refund)' : '- Cash Refund', '- SAR ${cashRefund.toStringAsFixed(2)}', color: const Color(0xFFDC2626)),
                                  
                                  // Interactive Expense Input
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(_isArabic ? '- مصاريف نقدية (Cash Expense)' : '- Cash Expense', style: const TextStyle(fontSize: 12.5, color: Color(0xFFDC2626))),
                                      SizedBox(
                                        width: 90,
                                        height: 32,
                                        child: TextField(
                                          controller: _cashExpenseController,
                                          keyboardType: TextInputType.number,
                                          onChanged: (_) => setState(() {}),
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                                          decoration: InputDecoration(
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                            fillColor: const Color(0xFFFEF2F2),
                                            filled: true,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 20),

                                  _buildFinanceRow(_isArabic ? 'المبلغ المتوقع بالصندوق (Expected Cash)' : 'Expected Cash in Drawer', 'SAR ${expectedCashInDrawer.toStringAsFixed(2)}', isTotal: true, color: const Color(0xFF2563EB)),
                                  const SizedBox(height: 12),

                                  // Actual Cash Count Input
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFCBD5E1)),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _isArabic ? 'المكتشف فعلياً بالصندوق:' : 'Actual Cash Counted:',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 120,
                                          height: 36,
                                          child: TextField(
                                            controller: _actualCashController,
                                            keyboardType: TextInputType.number,
                                            onChanged: (_) => setState(() {}),
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                            decoration: InputDecoration(
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                              fillColor: Colors.white,
                                              filled: true,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Cash Variance Display
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _isArabic ? 'الفارق النردي (Over / Short):' : 'Cash Variance (Diff):',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: cashVariance >= 0 ? const Color(0xFF16A34A) : const Color(0xFFDC2626)),
                                      ),
                                      Text(
                                        'SAR ${cashVariance.toStringAsFixed(2)}',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: cashVariance >= 0 ? const Color(0xFF16A34A) : const Color(0xFFDC2626)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Right Column: Sales Summary, Payment Collected & Outstanding Receivables
                          Expanded(
                            child: Column(
                              children: [
                                // Sales Summary Card
                                Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.analytics_rounded, color: Color(0xFF7C3AED), size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            _isArabic ? 'ملخص المبيعات (Sales Summary)' : 'Sales Summary',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 16),
                                      _buildFinanceRow(_isArabic ? 'إجمالي المبيعات (Gross Sales)' : 'Gross Sales (Total Invoiced)', 'SAR ${grossSales.toStringAsFixed(2)}'),
                                      _buildFinanceRow(_isArabic ? '- إجمالي المرتجعات (Total Refund)' : '- Total Refund', '- SAR ${totalRefund.toStringAsFixed(2)}', color: const Color(0xFFDC2626)),
                                      const Divider(height: 12),
                                      _buildFinanceRow(_isArabic ? 'صافي المبيعات (Net Sales)' : 'Net Sales', 'SAR ${netSales.toStringAsFixed(2)}', isBold: true, color: const Color(0xFF7C3AED)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Outstanding Receivables Card
                                Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.pending_actions_rounded, color: Color(0xFFF59E0B), size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            _isArabic ? 'الذمم والتحصيلات المستحقة (Outstanding Receivables)' : 'Outstanding Receivables',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 16),
                                      _buildFinanceRow(_isArabic ? 'إجمالي الفواتير (Gross Sales)' : 'Gross Sales (Total Invoiced)', 'SAR ${grossSales.toStringAsFixed(2)}'),
                                      _buildFinanceRow(_isArabic ? '- المحصل المقبوض (Total Collected)' : '- Total Collected', '- SAR ${totalCollected.toStringAsFixed(2)}', color: const Color(0xFF16A34A)),
                                      _buildFinanceRow(_isArabic ? '- تحصيل ديون سابقة (Due Collection)' : '- Due Collection (for this sales)', '- SAR ${dueCollection.toStringAsFixed(2)}'),
                                      const Divider(height: 12),
                                      _buildFinanceRow(_isArabic ? 'المتبقي ذمم على العملاء' : 'Pending from Customers', 'SAR ${pendingFromCustomers.toStringAsFixed(2)}', isBold: true, color: const Color(0xFFB45309)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Action Footer (Print Summary / Cancel / Close Register)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: Text(_isArabic ? 'إلغاء' : 'Cancel'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final printer = await ref.read(defaultPrinterProvider.future);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(_isArabic ? 'جاري طباعة تقرير إغلاق الوردية Z-Report...' : 'Printing Register Z-Report summary...')),
                      );
                    },
                    icon: const Icon(Icons.print_rounded, size: 18),
                    label: Text(_isArabic ? 'طباعة الملخص Z-Report' : 'Print Summary'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      side: const BorderSide(color: Color(0xFF2563EB)),
                      foregroundColor: const Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (widget.session != null) {
                        final transfer = double.tryParse(_cashExpenseController.text) ?? 0.0;
                        await ref.read(sessionControllerProvider.notifier).closeSession(
                          sessionId: widget.session!.id,
                          transferAmount: transfer,
                          cashSales: cashSales,
                        );
                      }
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(_isArabic ? 'تم إغلاق الوردية وحفظ التقرير بنجاح' : 'Register session closed & report recorded successfully')),
                      );
                    },
                    icon: const Icon(Icons.lock_rounded, size: 18),
                    label: Text(_isArabic ? 'إغلاق الوردية والصندوق' : 'Close Register Session'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaDetail(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          ],
        ),
      ],
    );
  }

  Widget _buildFinanceRow(String title, String value, {bool isBold = false, bool isTotal = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 13.5 : 12.5,
              fontWeight: (isBold || isTotal) ? FontWeight.bold : FontWeight.normal,
              color: const Color(0xFF334155),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 14 : 12.5,
              fontWeight: (isBold || isTotal) ? FontWeight.bold : FontWeight.w600,
              color: color ?? const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

void showRegisterSessionReportModal(BuildContext context, {CounterSessionModel? session}) {
  showDialog(
    context: context,
    builder: (context) => RegisterSessionReportModal(session: session),
  );
}
