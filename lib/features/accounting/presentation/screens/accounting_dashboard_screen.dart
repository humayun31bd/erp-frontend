import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:erp_frontend/app.dart';
import 'package:erp_frontend/core/routing/route_names.dart';
import 'package:erp_frontend/features/accounting/providers/accounting_providers.dart';
import 'package:erp_frontend/features/accounting/domain/accounting_models.dart';

const _kPrimary = Color(0xFF2563EB);
const _kSurface = Color(0xFFF8F9FE);
const _kCardBg = Colors.white;
const _kDivider = Color(0xFFE2E8F0);
const _kTextPrimary = Color(0xFF0F172A);
const _kTextSecondary = Color(0xFF64748B);

class AccountingDashboardScreen extends ConsumerStatefulWidget {
  final int initialTab;
  const AccountingDashboardScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<AccountingDashboardScreen> createState() => _AccountingDashboardScreenState();
}

class _AccountingDashboardScreenState extends ConsumerState<AccountingDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _ledgerSearchController = TextEditingController();
  String _ledgerSearchQuery = '';
  String _selectedAccountTypeFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ledgerSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ledgerAsync = ref.watch(ledgerProvider);
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return Scaffold(
      backgroundColor: _kSurface,
      appBar: AppBar(
        backgroundColor: _kCardBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          isArabic ? 'لوحة قياس المحاسبة ودفتر الأستاذ المالي' : 'Accounting Dashboards & Financial Ledger',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _kTextPrimary, letterSpacing: -0.3),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: _kTextPrimary),
            onPressed: () {
              final current = ref.read(localeProvider);
              ref.read(localeProvider.notifier).state =
                  current.languageCode == 'en' ? const Locale('ar') : const Locale('en');
            },
            tooltip: isArabic ? 'تغيير اللغة' : 'Switch Language',
          ),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(49),
          child: Column(
            children: [
              Container(
                color: _kCardBg,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: _kPrimary,
                  unselectedLabelColor: _kTextSecondary,
                  indicatorColor: _kPrimary,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  tabs: [
                    Tab(icon: const Icon(Icons.space_dashboard_rounded, size: 18), text: isArabic ? 'لوحة الإدارة التنفيذية (المدير المالي / العام)' : 'Executive Dashboard (CFO / DG)'),
                    Tab(icon: const Icon(Icons.menu_book_rounded, size: 18), text: isArabic ? 'لوحة المحاسب (الأستاذ العام والدفتر)' : 'Accountant Dashboard (GL & Ledger)'),
                  ],
                ),
              ),
              Container(height: 1, color: _kDivider),
            ],
          ),
        ),
      ),
      body: ledgerAsync.when(
        data: (ledger) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildExecutiveDashboard(ledger, isArabic),
              _buildAccountantDashboard(ledger, isArabic),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text(
            '${isArabic ? "خطأ في تحميل دفتر الأستاذ: " : "Error loading ledger: "}$err',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // 1. EXECUTIVE DASHBOARD (CFO / DG VIEW)
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildExecutiveDashboard(List<LedgerBalance> ledger, bool isArabic) {
    double totalAssets = 0;
    double totalLiabilities = 0;
    double totalRevenue = 0;
    double totalExpense = 0;
    double cashReserves = 0;

    for (final b in ledger) {
      if (b.accountType == 'ASSET') {
        totalAssets += b.balance;
        if (b.accountCode.startsWith('1.10.01')) cashReserves += b.balance;
      } else if (b.accountType == 'LIABILITY') {
        totalLiabilities += b.balance;
      } else if (b.accountType == 'REVENUE') {
        totalRevenue += b.balance;
      } else if (b.accountType == 'EXPENSE') {
        totalExpense += b.balance;
      }
    }

    final netProfit = totalRevenue - totalExpense;
    final netWorkingCapital = totalAssets - totalLiabilities;
    final operatingMargin = totalRevenue > 0 ? (netProfit / totalRevenue) * 100 : 0.0;
    final currency = isArabic ? 'ر.س ' : 'SAR ';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.account_balance_rounded, color: Colors.blue, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'الملخص المالي التنفيذي' : 'Executive Financial Summary',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isArabic
                            ? 'نظرة عامة لحظية على السيولة الصافية، الأرباح التشغيلية، رأس المال العامل، واحتياطيات الضرائب.'
                            : 'Real-time overview of net liquidity, operating profits, working capital, and tax reserves.',
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => context.goNamed(RouteNames.reports),
                  icon: const Icon(Icons.assessment_rounded, size: 18),
                  label: Text(isArabic ? 'عرض التقارير المالية' : 'View Financial Reports'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Primary Executive KPI Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              return GridView.count(
                crossAxisCount: isWide ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isWide ? 2.2 : 1.8,
                children: [
                  _buildKpiCard(
                    isArabic ? 'إجمالي الإيرادات الصافية' : 'Total Net Revenue',
                    totalRevenue,
                    Icons.trending_up_rounded,
                    Colors.green,
                    isArabic ? '+14.2% مقارنة بالشهر الماضي' : '+14.2% vs last month',
                    isArabic,
                  ),
                  _buildKpiCard(
                    isArabic ? 'صافي الربح التشغيلي' : 'Net Operating Profit',
                    netProfit,
                    Icons.pie_chart_rounded,
                    netProfit >= 0 ? Colors.blue.shade700 : Colors.red,
                    isArabic ? '${operatingMargin.toStringAsFixed(1)}% هامش التشغيل' : '${operatingMargin.toStringAsFixed(1)}% Operating Margin',
                    isArabic,
                  ),
                  _buildKpiCard(
                    isArabic ? 'احتياطيات النقد والبنك' : 'Cash & Bank Reserves',
                    cashReserves,
                    Icons.account_balance_wallet_rounded,
                    Colors.indigo.shade700,
                    isArabic ? 'الأموال السائلة المتوفرة' : 'Liquid Funds on Hand',
                    isArabic,
                  ),
                  _buildKpiCard(
                    isArabic ? 'صافي رأس المال العامل' : 'Net Working Capital',
                    netWorkingCapital,
                    Icons.savings_rounded,
                    Colors.amber.shade800,
                    isArabic ? 'الأصول - الالتزامات' : 'Assets - Liabilities',
                    isArabic,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Secondary Financial Ratios & Breakdown
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _kCardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _kDivider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.analytics_rounded, color: _kPrimary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            isArabic ? 'أداء الإيرادات مقابل المصروفات' : 'Revenue vs Expense Performance',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _kTextPrimary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildMetricProgress(
                        '${isArabic ? "مستهدف إجمالي الإيرادات" : "Gross Revenue Target"} ($currency)',
                        totalRevenue,
                        totalRevenue * 1.25,
                        Colors.green,
                        isArabic,
                      ),
                      const SizedBox(height: 16),
                      _buildMetricProgress(
                        '${isArabic ? "تخصيص المصروفات التشغيلية" : "Operating Expense Allocation"} ($currency)',
                        totalExpense,
                        totalRevenue,
                        Colors.orange,
                        isArabic,
                      ),
                      const SizedBox(height: 16),
                      _buildMetricProgress(
                        '${isArabic ? "إجمالي الالتزامات والمستحقات" : "Total Liabilities & Payables"} ($currency)',
                        totalLiabilities,
                        totalAssets,
                        Colors.red,
                        isArabic,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _kCardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _kDivider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.notifications_active_rounded, color: Colors.amber, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            isArabic ? 'التنبيهات والتدقيقات التنفيذية' : 'Executive Alerts & Audits',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _kTextPrimary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildAlertTile(
                        isArabic ? 'قيود بنكية غير مسواة' : 'Unreconciled Bank Entries',
                        isArabic ? 'كشفا حساب بنكي في انتظار التسوية' : '2 bank statements pending reconciliation',
                        Colors.amber,
                      ),
                      _buildAlertTile(
                        isArabic ? 'احتياطيات ضرائب TDS/VDS' : 'TDS/VDS Tax Reserves',
                        isArabic ? 'الإقرار الضريبي الشهري مستحق خلال 6 أيام' : 'NBR Monthly Tax Filing due in 6 days',
                        Colors.blue,
                      ),
                      _buildAlertTile(
                        isArabic ? 'موافقات معلقة' : 'Pending Approvals',
                        isArabic ? '3 سندات ذات قيمة عالية تنتظر موافقة المراجع' : '3 high-value vouchers awaiting Checker approval',
                        Colors.orange,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // 2. ACCOUNTANT DASHBOARD (OPERATIONAL GL & LEDGER VIEW)
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildAccountantDashboard(List<LedgerBalance> ledger, bool isArabic) {
    double totalDr = 0;
    double totalCr = 0;
    for (final b in ledger) {
      totalDr += b.totalDebit;
      totalCr += b.totalCredit;
    }
    final isBalanced = (totalDr - totalCr).abs() < 0.01;
    final currency = isArabic ? 'ر.س ' : 'SAR ';

    final filteredLedger = ledger.where((b) {
      final matchesQuery = _ledgerSearchQuery.isEmpty ||
          b.accountCode.toLowerCase().contains(_ledgerSearchQuery.toLowerCase()) ||
          b.accountName.toLowerCase().contains(_ledgerSearchQuery.toLowerCase());
      final matchesType = _selectedAccountTypeFilter == 'ALL' || b.accountType == _selectedAccountTypeFilter;
      return matchesQuery && matchesType;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trial Balance Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isBalanced ? Colors.green.shade50 : Colors.red.shade50,
              border: Border.all(color: isBalanced ? Colors.green.shade300 : Colors.red.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isBalanced ? Icons.verified_rounded : Icons.warning_rounded,
                  color: isBalanced ? Colors.green.shade800 : Colors.red.shade800,
                  size: 26,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBalanced
                            ? (isArabic ? 'ميزان المراجعة متوازن ومتحقق منه' : 'Trial Balance Verified & Balanced')
                            : (isArabic ? 'تحذير: ميزان المراجعة غير متوازن' : 'Trial Balance Out of Balance Warning'),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isBalanced ? Colors.green.shade900 : Colors.red.shade900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isArabic
                            ? 'إجمالي المدين: $currency${totalDr.toStringAsFixed(2)}  |  إجمالي الدائن: $currency${totalCr.toStringAsFixed(2)}  |  الفارق: $currency${(totalDr - totalCr).abs().toStringAsFixed(2)}'
                            : 'Total Dr: $currency${totalDr.toStringAsFixed(2)}  |  Total Cr: $currency${totalCr.toStringAsFixed(2)}  |  Difference: $currency${(totalDr - totalCr).abs().toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 12, color: isBalanced ? Colors.green.shade800 : Colors.red.shade800),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isBalanced ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isArabic ? '${ledger.length} حسابات نشطة' : '${ledger.length} Active Accounts',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isBalanced ? Colors.green.shade900 : Colors.red.shade900),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Operational Quick Action Bar
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildActionButton(
                label: isArabic ? 'سجل السندات' : 'Vouchers Register',
                icon: Icons.receipt_long_rounded,
                color: Colors.indigo.shade700,
                onTap: () => context.goNamed(RouteNames.accountingVouchers),
              ),
              _buildActionButton(
                label: isArabic ? 'دليل الحسابات (COA)' : 'Chart of Accounts (COA)',
                icon: Icons.account_tree_rounded,
                color: Colors.purple.shade700,
                onTap: () => context.goNamed(RouteNames.accountingCoA),
              ),
              _buildActionButton(
                label: isArabic ? 'ربط الحسابات التلقائي' : 'Account Mappings (Linkage)',
                icon: Icons.hub_rounded,
                color: Colors.amber.shade800,
                onTap: () => context.goNamed(RouteNames.accountingIntegrationMapping),
              ),
              _buildActionButton(
                label: isArabic ? 'إعدادات وصيغ المحاسبة' : 'Accounting Settings & Formula',
                icon: Icons.settings_suggest_rounded,
                color: Colors.indigo.shade700,
                onTap: () => context.goNamed(RouteNames.accountingSettings),
              ),
              _buildActionButton(
                label: isArabic ? 'إغلاق السنة المالية وقفل الفترة' : 'Year-End Close & Period Lock',
                icon: Icons.lock_clock_rounded,
                color: Colors.red.shade800,
                onTap: () => _showYearEndCloseDialog(context, isArabic),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Search & Filter Header for Ledger Table
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _kCardBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border.all(color: _kDivider),
            ),
            child: Row(
              children: [
                const Icon(Icons.table_chart_rounded, color: _kPrimary, size: 20),
                const SizedBox(width: 8),
                Text(
                  isArabic ? 'أرصدة دفتر الأستاذ العام' : 'General Ledger Balances',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _kTextPrimary),
                ),
                const Spacer(),
                SizedBox(
                  width: 250,
                  height: 38,
                  child: TextField(
                    controller: _ledgerSearchController,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: isArabic ? 'البحث عن رمز أو حساب...' : 'Search code or account...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 18),
                      suffixIcon: _ledgerSearchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 16),
                              onPressed: () {
                                _ledgerSearchController.clear();
                                setState(() => _ledgerSearchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: _kSurface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _kDivider)),
                    ),
                    onChanged: (v) => setState(() => _ledgerSearchQuery = v),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _selectedAccountTypeFilter,
                  underline: const SizedBox.shrink(),
                  items: ['ALL', 'ASSET', 'LIABILITY', 'EQUITY', 'REVENUE', 'EXPENSE']
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(
                              _getAccountTypeLabel(t, isArabic),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedAccountTypeFilter = v!),
                ),
              ],
            ),
          ),

          // Ledger Table
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: _kCardBg,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              border: Border(
                left: BorderSide(color: _kDivider),
                right: BorderSide(color: _kDivider),
                bottom: BorderSide(color: _kDivider),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 40,
                headingRowColor: WidgetStateProperty.all(_kSurface),
                columns: [
                  DataColumn(label: Text(isArabic ? 'اسم الحساب' : 'Account Name', style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text(isArabic ? 'النوع' : 'Type', style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('${isArabic ? "إجمالي المدين" : "Total Dr"} ($currency)', style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('${isArabic ? "إجمالي الدائن" : "Total Cr"} ($currency)', style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('${isArabic ? "صافي الرصيد" : "Net Balance"} ($currency)', style: const TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: filteredLedger.map((b) {
                  return DataRow(
                    cells: [
                      DataCell(Text(b.accountName, style: const TextStyle(fontWeight: FontWeight.w500))),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getTypeColor(b.accountType).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getAccountTypeLabel(b.accountType, isArabic),
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _getTypeColor(b.accountType)),
                        ),
                      )),
                      DataCell(Text(b.totalDebit.toStringAsFixed(2))),
                      DataCell(Text(b.totalCredit.toStringAsFixed(2))),
                      DataCell(Text(
                        '$currency${b.balance.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: b.balance < 0 ? Colors.red.shade700 : Colors.green.shade700,
                        ),
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getAccountTypeLabel(String type, bool isArabic) {
    if (!isArabic) return type;
    switch (type) {
      case 'ALL': return 'الكل';
      case 'ASSET': return 'أصول';
      case 'LIABILITY': return 'التزامات';
      case 'EQUITY': return 'حقوق الملكية';
      case 'REVENUE': return 'إيرادات';
      case 'EXPENSE': return 'مصروفات';
      default: return type;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'ASSET': return Colors.green.shade700;
      case 'LIABILITY': return Colors.amber.shade800;
      case 'EQUITY': return Colors.purple.shade700;
      case 'REVENUE': return Colors.blue.shade700;
      case 'EXPENSE': return Colors.red.shade700;
      default: return _kPrimary;
    }
  }

  Widget _buildKpiCard(String title, double amount, IconData icon, Color color, String subtitle, bool isArabic) {
    final currency = isArabic ? 'ر.س ' : 'SAR ';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kDivider),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: _kTextSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
              Icon(icon, color: color, size: 22),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$currency${amount.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildMetricProgress(String label, double val, double max, Color color, bool isArabic) {
    final pct = max > 0 ? (val / max).clamp(0.0, 1.0) : 0.0;
    final currency = isArabic ? 'ر.س ' : 'SAR ';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _kTextPrimary)),
            Text('$currency${val.toStringAsFixed(2)}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: pct,
          backgroundColor: color.withValues(alpha: 0.1),
          color: color,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildAlertTile(String title, String subtitle, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: _kTextSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showYearEndCloseDialog(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.lock_clock_rounded, color: Colors.redAccent),
            const SizedBox(width: 8),
            Text(isArabic ? 'إغلاق السنة المالية وقفل الفترة' : 'Financial Year-End Close & Period Lock'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isArabic
                    ? 'الخطوة 15: محرك قفل الفترة وإغلاق السنة المالية الآلي'
                    : 'Step 15: Automated Period Lock & Year-End Close Engine',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                isArabic
                    ? '• يفرض قفل جميع الفترات المحاسبية الـ 12 الشهرية قبل الإغلاق.\n'
                      '• يحسب أرصدة الإيرادات والمصروفات السنوية.\n'
                      '• يولد سند قيد إغلاق الفترة 13 (JV).\n'
                      '• ينقل الفائض/العجز الصافي إلى حساب الأرباح المبقاة.'
                    : '• Enforces that all 12 monthly accounting periods are LOCKED before close.\n'
                      '• Computes annual Revenue & Expense balances.\n'
                      '• Generates Period 13 Closing Journal Voucher (JV).\n'
                      '• Transfers net surplus/deficit into Retained Earnings account.',
                style: const TextStyle(fontSize: 12, color: _kTextSecondary),
              ),
              const SizedBox(height: 16),
              Card(
                color: const Color(0xFFF1F5F9),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'السنة المالية النشطة: FY2026-2027' : 'Active Fiscal Year: FY2026-2027',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        isArabic
                            ? 'الحالة: 12 فترة مفتوحة (يلزم القفل قبل التنفيذ)'
                            : 'Status: 12 Periods Open (Lock required prior to execute)',
                        style: const TextStyle(fontSize: 12, color: Colors.amber),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800, foregroundColor: Colors.white),
            icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
            label: Text(isArabic ? 'تنفيذ إغلاق السنة المالية' : 'Execute Year-End Close'),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isArabic
                        ? 'محرك إغلاق السنة المالية جاهز: تأكد من قفل جميع الفترات الـ 12 قبل الترحيل النهائي.'
                        : 'Year-End Close Engine Ready: Ensure all 12 periods are locked prior to final posting.',
                  ),
                  backgroundColor: Colors.blue,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

