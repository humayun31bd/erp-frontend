import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/reports_provider.dart';
import 'package:erp_frontend/features/accounting/providers/accounting_providers.dart' hide ledgerProvider;
import 'package:erp_frontend/app.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  // Input parameters
  String? selectedFinancialYearId;
  String? startDate;
  String? endDate;

  // Executed parameters (Report will NOT start or execute until Show Report is pressed)
  bool hasExecuted = false;
  String? executedFinancialYearId;
  String? executedStartDate;
  String? executedEndDate;

  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;

  @override
  void initState() {
    super.initState();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  void _onShowReportPressed(bool isArabic) {
    // 1. Validate Fiscal Year
    if (selectedFinancialYearId == null || selectedFinancialYearId!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.amber.shade900,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isArabic
                      ? 'يرجى اختيار السنة المالية أولاً لتشغيل التقرير'
                      : 'Please select a Fiscal Year before running the report',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
      return;
    }

    // 2. Validate Date Range
    if (startDate == null || startDate!.trim().isEmpty || endDate == null || endDate!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.amber.shade900,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: Row(
            children: [
              const Icon(Icons.date_range_outlined, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isArabic
                      ? 'يرجى تحديد نطاق التاريخ (من تاريخ وإلى تاريخ)'
                      : 'Please select both From Date and To Date',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
      return;
    }

    // 3. Validate Date Order
    final sDate = DateTime.tryParse(startDate!);
    final eDate = DateTime.tryParse(endDate!);
    if (sDate != null && eDate != null && sDate.isAfter(eDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isArabic
                      ? 'تاريخ البداية لا يمكن أن يكون بعد تاريخ النهاية'
                      : 'From Date cannot be after To Date',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
      return;
    }

    // 4. Execute program
    setState(() {
      hasExecuted = true;
      executedFinancialYearId = selectedFinancialYearId;
      executedStartDate = startDate;
      executedEndDate = endDate;
    });

    // Invalidate report providers so fresh data is fetched for the new execution
    ref.invalidate(vatReportProvider);
    ref.invalidate(profitLossProvider);
    ref.invalidate(customerBalancesProvider);
    ref.invalidate(ledgerProvider);
    ref.invalidate(detailedLedgerProvider);
    ref.invalidate(trialBalanceProvider);
    ref.invalidate(balanceSheetProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.teal.shade800,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isArabic
                    ? 'تم تشغيل التقرير المالي للفترة المحددة'
                    : 'Financial report generated successfully for the selected period',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onResetPressed(bool isArabic) {
    setState(() {
      selectedFinancialYearId = null;
      startDate = null;
      endDate = null;
      _startDateController.clear();
      _endDateController.clear();
      hasExecuted = false;
      executedFinancialYearId = null;
      executedStartDate = null;
      executedEndDate = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: Text(isArabic ? 'تمت إعادة ضبط معايير التقرير' : 'Report filters reset'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final financialYearsAsync = ref.watch(financialYearsProvider);
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    final bool isModifiedAfterExecution = hasExecuted &&
        (selectedFinancialYearId != executedFinancialYearId ||
            startDate != executedStartDate ||
            endDate != executedEndDate);

    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isArabic ? 'التقارير والقوائم المالية' : 'Financial Reports & Statements'),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: isArabic ? 'إقرارات الضريبة' : 'VAT Returns'),
              Tab(text: isArabic ? 'الأرباح والخسائر' : 'Profit & Loss'),
              Tab(text: isArabic ? 'أرصدة العملاء' : 'Customer Balances'),
              Tab(text: isArabic ? 'دفتر الأستاذ' : 'Ledger'),
              Tab(text: isArabic ? 'سجل النقدية' : 'Cash Book'),
              Tab(text: isArabic ? 'ميزان المراجعة' : 'Trial Balance'),
              Tab(text: isArabic ? 'الميزانية العمومية' : 'Balance Sheet'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.language),
              tooltip: isArabic ? 'Switch to English' : 'التحويل للعربية',
              onPressed: () {
                ref.read(localeProvider.notifier).state =
                    isArabic ? const Locale('en') : const Locale('ar');
              },
            ),
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: isArabic ? 'تصدير إلى PDF' : 'Export to PDF',
              onPressed: () {
                if (!hasExecuted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        isArabic
                            ? 'يرجى تشغيل التقرير أولاً قبل التصدير إلى PDF'
                            : 'Please show the report before exporting to PDF',
                      ),
                    ),
                  );
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text(isArabic ? 'جاري تصدير التقرير إلى PDF...' : 'Exporting report to PDF...'),
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Filter Bar Card
            Card(
              margin: const EdgeInsets.fromLTRB(12, 12, 12, 6),
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 800;

                    final fiscalYearDropdown = financialYearsAsync.when(
                      data: (years) => DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: isArabic ? 'السنة المالية *' : 'Fiscal Year *',
                          hintText: isArabic ? 'اختر السنة المالية' : 'Select Fiscal Year',
                          prefixIcon: const Icon(Icons.calendar_month, size: 20),
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        initialValue: selectedFinancialYearId,
                        items: years
                            .map((y) => DropdownMenuItem(
                                  value: y.id,
                                  child: Text(
                                    y.yearName,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          final year = years.firstWhere((y) => y.id == v);
                          setState(() {
                            selectedFinancialYearId = v;
                            final s = year.startDate.split('T')[0];
                            final e = year.endDate.split('T')[0];
                            startDate = s;
                            endDate = e;
                            _startDateController.text = s;
                            _endDateController.text = e;
                          });
                        },
                      ),
                      loading: () => const SizedBox(
                        height: 48,
                        child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
                      ),
                      error: (e, _) => Text(
                        isArabic ? 'خطأ في تحميل السنوات المالية' : 'Error loading years',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );

                    final fromDateField = TextFormField(
                      controller: _startDateController,
                      decoration: InputDecoration(
                        labelText: isArabic ? 'من تاريخ *' : 'From Date *',
                        hintText: 'YYYY-MM-DD',
                        prefixIcon: const Icon(Icons.date_range, size: 20),
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      readOnly: true,
                      onTap: () async {
                        DateTime init = DateTime.now();
                        if (startDate != null && startDate!.isNotEmpty) {
                          init = DateTime.tryParse(startDate!) ?? DateTime.now();
                        }
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: init,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          final formatted = picked.toIso8601String().split('T')[0];
                          setState(() {
                            startDate = formatted;
                            _startDateController.text = formatted;
                          });
                        }
                      },
                    );

                    final toDateField = TextFormField(
                      controller: _endDateController,
                      decoration: InputDecoration(
                        labelText: isArabic ? 'إلى تاريخ *' : 'To Date *',
                        hintText: 'YYYY-MM-DD',
                        prefixIcon: const Icon(Icons.event, size: 20),
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      readOnly: true,
                      onTap: () async {
                        DateTime init = DateTime.now();
                        if (endDate != null && endDate!.isNotEmpty) {
                          init = DateTime.tryParse(endDate!) ?? DateTime.now();
                        }
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: init,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          final formatted = picked.toIso8601String().split('T')[0];
                          setState(() {
                            endDate = formatted;
                            _endDateController.text = formatted;
                          });
                        }
                      },
                    );

                    final showReportButton = FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: isModifiedAfterExecution
                            ? Colors.amber.shade800
                            : Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: Icon(
                        isModifiedAfterExecution ? Icons.refresh_rounded : Icons.play_arrow_rounded,
                        size: 20,
                      ),
                      label: Text(
                        isModifiedAfterExecution
                            ? (isArabic ? 'تحديث التقرير' : 'Update Report')
                            : (isArabic ? 'عرض التقرير' : 'Show Report'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      onPressed: () => _onShowReportPressed(isArabic),
                    );

                    final resetButton = OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.clear_all, size: 18),
                      label: Text(isArabic ? 'مسح' : 'Reset'),
                      onPressed: () => _onResetPressed(isArabic),
                    );

                    if (isNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          fiscalYearDropdown,
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: fromDateField),
                              const SizedBox(width: 12),
                              Expanded(child: toDateField),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: showReportButton),
                              const SizedBox(width: 8),
                              resetButton,
                            ],
                          ),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 3, child: fiscalYearDropdown),
                        const SizedBox(width: 12),
                        Expanded(flex: 2, child: fromDateField),
                        const SizedBox(width: 12),
                        Expanded(flex: 2, child: toDateField),
                        const SizedBox(width: 16),
                        showReportButton,
                        const SizedBox(width: 8),
                        resetButton,
                      ],
                    );
                  },
                ),
              ),
            ),

            // Execution / Modification Status Info Banner
            if (isModifiedAfterExecution)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: Colors.amber.shade900),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isArabic
                            ? 'تم تعديل المعايير أعلاه. انقر على "تحديث التقرير" لعرض البيانات المحدثة.'
                            : 'Parameters modified. Click "Update Report" to refresh the data.',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.amber.shade900),
                      ),
                    ),
                  ],
                ),
              )
            else if (hasExecuted)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, size: 16, color: Colors.teal.shade800),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isArabic
                            ? 'الفترة المعروضة: من $executedStartDate إلى $executedEndDate'
                            : 'Active Reporting Period: $executedStartDate to $executedEndDate',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.teal.shade900),
                      ),
                    ),
                  ],
                ),
              ),

            // Report Views
            Expanded(
              child: TabBarView(
                children: [
                  VatReportTab(
                    hasExecuted: hasExecuted,
                    startDate: executedStartDate,
                    endDate: executedEndDate,
                    onShowReport: () => _onShowReportPressed(isArabic),
                  ),
                  ProfitLossTab(
                    hasExecuted: hasExecuted,
                    startDate: executedStartDate,
                    endDate: executedEndDate,
                    onShowReport: () => _onShowReportPressed(isArabic),
                  ),
                  CustomerBalancesTab(
                    hasExecuted: hasExecuted,
                    onShowReport: () => _onShowReportPressed(isArabic),
                  ),
                  LedgerTab(
                    hasExecuted: hasExecuted,
                    onShowReport: () => _onShowReportPressed(isArabic),
                  ),
                  CashBookTab(
                    hasExecuted: hasExecuted,
                    onShowReport: () => _onShowReportPressed(isArabic),
                  ),
                  TrialBalanceTab(
                    hasExecuted: hasExecuted,
                    startDate: executedStartDate,
                    endDate: executedEndDate,
                    onShowReport: () => _onShowReportPressed(isArabic),
                  ),
                  BalanceSheetTab(
                    hasExecuted: hasExecuted,
                    asOfDate: executedEndDate,
                    onShowReport: () => _onShowReportPressed(isArabic),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder displayed before the user clicks 'Show Report'
class ReportExecutionPlaceholder extends StatelessWidget {
  final VoidCallback onShowReport;
  final bool isArabic;

  const ReportExecutionPlaceholder({
    super.key,
    required this.onShowReport,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 580),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withAlpha(30),
                      theme.colorScheme.primary.withAlpha(10),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.assessment_outlined,
                  size: 44,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isArabic ? 'التقرير المالي جاهز للإنشاء' : 'Financial Report Ready to Generate',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isArabic
                    ? 'لضمان دقة الحسابات، لا يتم تشغيل أو استخراج التقارير المالية إلا بعد تحديد السنة المالية وتحديد نطاق التاريخ، ثم النقر على زر "عرض التقرير".'
                    : 'To ensure financial accuracy, reports will not execute without selecting a Fiscal Year and Date Range. Please configure your parameters above and click "Show Report".',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: onShowReport,
                icon: const Icon(Icons.play_arrow_rounded, size: 22),
                label: Text(
                  isArabic ? 'عرض التقرير الآن' : 'Show Report Now',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VatReportTab extends ConsumerWidget {
  final bool hasExecuted;
  final String? startDate;
  final String? endDate;
  final VoidCallback onShowReport;

  const VatReportTab({
    super.key,
    required this.hasExecuted,
    this.startDate,
    this.endDate,
    required this.onShowReport,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    if (!hasExecuted) {
      return ReportExecutionPlaceholder(onShowReport: onShowReport, isArabic: isArabic);
    }

    final reportState = ref.watch(vatReportProvider({'startDate': startDate, 'endDate': endDate}));
    return reportState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (report) {
        if (report.error != null) {
          return Center(child: Text('Error: ${report.error}'));
        }

        final summary = report.summary;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat('Total Sales', summary['totalSales'] ?? 0),
                      _buildStat('Total VAT', summary['totalVat'] ?? 0),
                      _buildStat('Net Revenue', summary['netRevenue'] ?? 0),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: report.invoices.length,
                  itemBuilder: (context, index) {
                    final inv = report.invoices[index];
                    return ListTile(
                      leading: const Icon(Icons.receipt),
                      title: Text('Invoice ${inv['invoiceNumber']}'),
                      subtitle: Text('${inv['buyerName']} - ${inv['status']}'),
                      trailing: Text('SAR ${inv['totalAmount']}'),
                    );
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildStat(String label, dynamic value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Text('SAR $value', style: const TextStyle(fontSize: 18, color: Colors.green)),
      ],
    );
  }
}

class ProfitLossTab extends ConsumerWidget {
  final bool hasExecuted;
  final String? startDate;
  final String? endDate;
  final VoidCallback onShowReport;

  const ProfitLossTab({
    super.key,
    required this.hasExecuted,
    this.startDate,
    this.endDate,
    required this.onShowReport,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    if (!hasExecuted) {
      return ReportExecutionPlaceholder(onShowReport: onShowReport, isArabic: isArabic);
    }

    final plState = ref.watch(profitLossProvider({'startDate': startDate, 'endDate': endDate}));
    return plState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text(isArabic ? 'خطأ في تحميل البيانات: $err' : 'Error: $err')),
      data: (response) {
        final data = response.data;
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            ListTile(
              title: Text(isArabic ? 'إجمالي المبيعات' : 'Gross Sales'),
              trailing: Text('SAR ${data['totalSales']}'),
            ),
            ListTile(
              title: Text(isArabic ? 'المرتجعات (الإشعارات الدائنة)' : 'Returns (Credit Notes)'),
              trailing: Text('SAR ${data['totalReturns']}'),
            ),
            const Divider(),
            ListTile(
              title: Text(isArabic ? 'صافي المبيعات' : 'Net Sales', style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: Text('SAR ${data['netSales']}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
            ListTile(
              title: Text(isArabic ? 'إجمالي المصروفات (سجل النقدية)' : 'Total Expenses (Cash Book)'),
              trailing: Text('SAR ${data['totalExpenses']}'),
            ),
            const Divider(),
            ListTile(
              title: Text(isArabic ? 'صافي الربح' : 'Net Profit', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              trailing: Text(
                'SAR ${data['netProfit']}', 
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 18, 
                  color: (data['netProfit'] as num) >= 0 ? Colors.green : Colors.red
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class CustomerBalancesTab extends ConsumerWidget {
  final bool hasExecuted;
  final VoidCallback onShowReport;

  const CustomerBalancesTab({
    super.key,
    required this.hasExecuted,
    required this.onShowReport,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    if (!hasExecuted) {
      return ReportExecutionPlaceholder(onShowReport: onShowReport, isArabic: isArabic);
    }

    final cbState = ref.watch(customerBalancesProvider);
    return cbState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (response) {
        if (response.data.isEmpty) {
          return const Center(child: Text('No customer balances found.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: response.data.length,
          itemBuilder: (context, i) {
            final customer = response.data[i];
            return Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(customer['customerName'] ?? 'Unknown'),
                subtitle: Text('Total Invoiced: SAR ${customer['totalInvoiced']}'),
                trailing: Text(
                  'Unpaid: SAR ${customer['totalUnpaid']}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class LedgerTab extends ConsumerWidget {
  final bool hasExecuted;
  final VoidCallback onShowReport;

  const LedgerTab({
    super.key,
    required this.hasExecuted,
    required this.onShowReport,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    if (!hasExecuted) {
      return ReportExecutionPlaceholder(onShowReport: onShowReport, isArabic: isArabic);
    }

    final ledgerState = ref.watch(ledgerProvider);
    
    return ledgerState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (response) {
        if (response.error != null) {
          return Center(child: Text('Error: ${response.error}'));
        }
        
        final ledgerItems = response.ledger;
        
        if (ledgerItems.isEmpty) {
          return const Center(child: Text('No ledger entries found.'));
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: ledgerItems.length,
          itemBuilder: (context, i) {
            final entry = ledgerItems[i];
            final totalDebit = double.tryParse(entry['totalDebit'].toString()) ?? 0;
            final totalCredit = double.tryParse(entry['totalCredit'].toString()) ?? 0;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: const Icon(Icons.account_balance_wallet),
                ),
                title: Text('${entry['accountCode']} - ${entry['accountName']}'),
                subtitle: Text('Type: ${entry['accountType']}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('DR: $totalDebit', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                    Text('CR: $totalCredit', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                  ],
                ),
                children: [
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Net Balance:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          'SAR ${(totalDebit - totalCredit).toStringAsFixed(2)}', 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class CashBookTab extends ConsumerWidget {
  final bool hasExecuted;
  final VoidCallback onShowReport;

  const CashBookTab({
    super.key,
    required this.hasExecuted,
    required this.onShowReport,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    if (!hasExecuted) {
      return ReportExecutionPlaceholder(onShowReport: onShowReport, isArabic: isArabic);
    }

    final state = ref.watch(detailedLedgerProvider);
    
    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (response) {
        if (response.error != null) {
          return Center(child: Text('Error: ${response.error}'));
        }
        
        final data = response.data;
        if (data.isEmpty) {
          return const Center(child: Text('No cash book entries found.'));
        }
        
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
              columns: const [
                DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Voucher No.', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Particulars', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Receipts (Dr)', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                DataColumn(label: Text('Payments (Cr)', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                DataColumn(label: Text('Balance', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
              ],
              rows: data.map((row) {
                final dateStr = row['tranDate'] != null 
                  ? DateTime.parse(row['tranDate']).toLocal().toString().split(' ')[0] 
                  : '';
                final dr = (row['debit'] as num? ?? 0) > 0 ? row['debit'].toString() : '';
                final cr = (row['credit'] as num? ?? 0) > 0 ? row['credit'].toString() : '';
                
                return DataRow(
                  cells: [
                    DataCell(Text(dateStr)),
                    DataCell(Text(row['voucherNo'] ?? '–')),
                    DataCell(Text(row['particulars'] ?? '')),
                    DataCell(Text(dr)),
                    DataCell(Text(cr)),
                    DataCell(Text(row['balance'].toString())),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class TrialBalanceTab extends ConsumerWidget {
  final bool hasExecuted;
  final String? startDate;
  final String? endDate;
  final VoidCallback onShowReport;

  const TrialBalanceTab({
    super.key,
    required this.hasExecuted,
    this.startDate,
    this.endDate,
    required this.onShowReport,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    if (!hasExecuted) {
      return ReportExecutionPlaceholder(onShowReport: onShowReport, isArabic: isArabic);
    }

    final state = ref.watch(trialBalanceProvider({'startDate': startDate, 'endDate': endDate}));
    
    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (response) {
        if (response.error != null) {
          return Center(child: Text('Error: ${response.error}'));
        }
        
        final data = response.data;
        final lines = data['lines'] as List<dynamic>? ?? [];
        
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Total Debit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text(data['totalDebit']?.toString() ?? '0', style: const TextStyle(fontSize: 18, color: Colors.blue)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Total Credit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text(data['totalCredit']?.toString() ?? '0', style: const TextStyle(fontSize: 18, color: Colors.orange)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
                    columns: const [
                      DataColumn(label: Text('Code', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Account Name', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Debit', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                      DataColumn(label: Text('Credit', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                    ],
                    rows: lines.map((row) {
                      return DataRow(
                        cells: [
                          DataCell(Text(row['code'] ?? '')),
                          DataCell(Text(row['name'] ?? '')),
                          DataCell(Text(row['type'] ?? '')),
                          DataCell(Text(row['debit']?.toString() ?? '0')),
                          DataCell(Text(row['credit']?.toString() ?? '0')),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class BalanceSheetTab extends ConsumerWidget {
  final bool hasExecuted;
  final String? asOfDate;
  final VoidCallback onShowReport;

  const BalanceSheetTab({
    super.key,
    required this.hasExecuted,
    this.asOfDate,
    required this.onShowReport,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    if (!hasExecuted) {
      return ReportExecutionPlaceholder(onShowReport: onShowReport, isArabic: isArabic);
    }

    final state = ref.watch(balanceSheetProvider(asOfDate));
    
    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (response) {
        if (response.error != null) {
          return Center(child: Text('Error: ${response.error}'));
        }
        
        final data = response.data;
        final assets = data['assets'] as List<dynamic>? ?? [];
        final liabilities = data['liabilities'] as List<dynamic>? ?? [];
        final equity = data['equity'] as List<dynamic>? ?? [];
        final isBalanced = data['isBalanced'] ?? false;
        
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              color: isBalanced ? Colors.green.shade50 : Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(isBalanced ? Icons.check_circle : Icons.warning, color: isBalanced ? Colors.green : Colors.red),
                    const SizedBox(width: 16),
                    Text(
                      isBalanced ? 'Balance Sheet is Balanced' : 'Out of Balance!',
                      style: TextStyle(fontWeight: FontWeight.bold, color: isBalanced ? Colors.green : Colors.red),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Assets', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            ...assets.map((a) => ListTile(
              title: Text('${a['code']} - ${a['name']}'),
              trailing: Text(a['balance']?.toString() ?? '0'),
            )),
            ListTile(
              title: const Text('Total Assets', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: Text(data['totalAssets']?.toString() ?? '0', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
            
            const Text('Liabilities', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            ...liabilities.map((l) => ListTile(
              title: Text('${l['code']} - ${l['name']}'),
              trailing: Text(l['balance']?.toString() ?? '0'),
            )),
            ListTile(
              title: const Text('Total Liabilities', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: Text(data['totalLiabilities']?.toString() ?? '0', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
            
            const Text('Equity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            ...equity.map((e) => ListTile(
              title: Text('${e['code']} - ${e['name']}'),
              trailing: Text(e['balance']?.toString() ?? '0'),
            )),
            ListTile(
              title: const Text('Total Equity', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: Text(data['totalEquity']?.toString() ?? '0', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
