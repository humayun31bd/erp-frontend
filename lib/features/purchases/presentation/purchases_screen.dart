import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:erp_frontend/app.dart';
import 'package:erp_frontend/core/routing/route_names.dart';
import '../domain/purchase_model.dart';
import '../providers/purchases_provider.dart';
import '../utils/purchase_invoice_pdf_printer.dart';
import '../utils/procurement_document_formatter.dart';
import 'widgets/purchase_details_dialog.dart';
import 'widgets/purchase_csv_import_dialog.dart';

enum PurchaseViewMode { card, grid, list }

const _kPrimary = Color(0xFF2563EB);
const _kSurface = Color(0xFFF8F9FE);
const _kCardBg = Colors.white;
const _kDivider = Color(0xFFE2E8F0);
const _kTextPrimary = Color(0xFF0F172A);
const _kTextSecondary = Color(0xFF64748B);

class PurchasesScreen extends ConsumerStatefulWidget {
  const PurchasesScreen({super.key});

  @override
  ConsumerState<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends ConsumerState<PurchasesScreen> {
  PurchaseViewMode _viewMode = PurchaseViewMode.card;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'ALL'; // ALL, PAID, UNPAID, PARTIAL, OVERDUE
  String _filterValue = 'ALL';  // ALL, HIGH_VALUE, THIS_MONTH
  String _sortBy = 'NEWEST';     // NEWEST, OLDEST, AMOUNT_HIGH, AMOUNT_LOW, INVOICE_ASC

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetails(PurchaseModel purchase, bool isArabic) {
    showDialog(
      context: context,
      builder: (ctx) => PurchaseDetailsDialog(
        purchase: purchase,
        isArabic: isArabic,
      ),
    );
  }

  void _openCsvImport(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (ctx) => PurchaseCsvImportDialog(isArabic: isArabic),
    );
  }

  void _printSingleInvoice(PurchaseModel purchase) {
    PurchaseInvoicePdfPrinter.printPurchaseInvoice(purchase);
  }

  void _printPurchasesRegister(List<PurchaseModel> filtered, bool isArabic) {
    if (filtered.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic ? 'لا توجد فواتير مشتريات لطباعتها' : 'No purchase invoices available to print'),
          backgroundColor: Colors.amber.shade800,
        ),
      );
      return;
    }
    final title = isArabic
        ? 'سجل فواتير المشتريات والضريبة (Purchases Register)'
        : 'Purchases & AP Invoices Audit Register';
    PurchaseInvoicePdfPrinter.printPurchasesRegister(purchases: filtered, title: title);
  }

  List<PurchaseModel> _applyFilters(List<PurchaseModel> purchases) {
    var filtered = purchases.where((p) {
      // Search text filter
      final q = _searchQuery.trim().toLowerCase();
      if (q.isNotEmpty) {
        final invMatch = p.invoiceNumber.toLowerCase().contains(q);
        final supMatch = p.supplierId.toLowerCase().contains(q) || (p.supplierName ?? '').toLowerCase().contains(q);
        final amtMatch = p.totalAmount.toLowerCase().contains(q);
        final itemMatch = p.lineItems.any((li) => li.description.toLowerCase().contains(q));
        if (!invMatch && !supMatch && !amtMatch && !itemMatch) {
          return false;
        }
      }

      // Status filter
      if (_filterStatus != 'ALL') {
        if (_filterStatus == 'OVERDUE') {
          final isOverdue = p.dueDate != null && p.dueDate!.isBefore(DateTime.now()) && p.paymentStatus.toUpperCase() != 'PAID';
          if (!isOverdue) return false;
        } else if (p.paymentStatus.toUpperCase() != _filterStatus) {
          return false;
        }
      }

      // Value / Date Filter
      if (_filterValue == 'HIGH_VALUE') {
        final amt = double.tryParse(p.totalAmount) ?? 0.0;
        if (amt < 5000) return false;
      } else if (_filterValue == 'THIS_MONTH') {
        final now = DateTime.now();
        if (p.issueDate.month != now.month || p.issueDate.year != now.year) return false;
      }

      return true;
    }).toList();

    // Sort
    if (_sortBy == 'NEWEST') {
      filtered.sort((a, b) => b.issueDate.compareTo(a.issueDate));
    } else if (_sortBy == 'OLDEST') {
      filtered.sort((a, b) => a.issueDate.compareTo(b.issueDate));
    } else if (_sortBy == 'AMOUNT_HIGH') {
      filtered.sort((a, b) => (double.tryParse(b.totalAmount) ?? 0).compareTo(double.tryParse(a.totalAmount) ?? 0));
    } else if (_sortBy == 'AMOUNT_LOW') {
      filtered.sort((a, b) => (double.tryParse(a.totalAmount) ?? 0).compareTo(double.tryParse(b.totalAmount) ?? 0));
    } else if (_sortBy == 'INVOICE_ASC') {
      filtered.sort((a, b) => a.invoiceNumber.compareTo(b.invoiceNumber));
    }

    return filtered;
  }

  void _showGuideModal(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.help_center_rounded, color: _kPrimary, size: 28),
            const SizedBox(width: 10),
            Text(
              isArabic ? 'دليل إدارة فواتير المشتريات والضريبة' : 'Purchase Bills & ZATCA Tax Compliance Guide',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SizedBox(
          width: 540,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGuideSection(
                  title: isArabic ? '١. الامتثال لضريبة القيمة المضافة لـ ZATCA' : '1. ZATCA VAT Input Tax Credit Rules',
                  content: isArabic
                      ? '• يلزم وجود رقم ضريبي صحيح للمورد (15 رقم) لاسترداد ضريبة مدخلات المشتريات.\n'
                        '• يجب أن تطابق فواتير الشراء المبالغ الصافية، نسبة الضريبة (15%)، والمبلغ الإجمالي.\n'
                        '• حفظ الأرقام المرجعية للفواتير يسهل الإقرار الضريبي للزكاة والضريبة.'
                      : '• Valid Supplier VAT Number (15 digits) is required for input tax credit claims.\n'
                        '• Ensure purchase invoices reflect Net Amount, 15% VAT, and Total Amount correctly.\n'
                        '• Keep supplier invoice references for seamless monthly/quarterly ZATCA tax filings.',
                  icon: Icons.verified_user_rounded,
                  color: Colors.green,
                ),
                const SizedBox(height: 14),
                _buildGuideSection(
                  title: isArabic ? '٢. العرض، التصدير، والطباعة' : '2. Views, Export & PDF Printing',
                  content: isArabic
                      ? '• يمكنك التبديل بين عرض الكروت (Card View)، الشبكي (Grid)، والجدول المدمج (List View).\n'
                        '• استخدم زر استيراد CSV لرفع فواتير وبنود الشراء دفعة واحدة.\n'
                        '• اطبع فواتير الشراء الضريبية المفردة أو سجل المشتريات الكامل بصيغة PDF.'
                      : '• Switch smoothly between Card View, Responsive Grid, and Data Table List.\n'
                        '• Use CSV Import to batch upload multi-line purchase invoices directly.\n'
                        '• Generate official bilingual ZATCA-compliant Tax Purchase Invoices and Audit Registers.',
                  icon: Icons.print_rounded,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(isArabic ? 'إغلاق' : 'Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideSection({required String title, required String content, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
                const SizedBox(height: 4),
                Text(content, style: const TextStyle(fontSize: 12.5, color: _kTextPrimary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final purchasesState = ref.watch(purchasesProvider);
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final currency = isArabic ? 'ر.س ' : 'SAR ';

    return Scaffold(
      backgroundColor: _kSurface,
      appBar: AppBar(
        backgroundColor: _kCardBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _kPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shopping_bag_outlined, color: _kPrimary, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              isArabic ? 'فواتير المشتريات (Purchase Bills)' : 'Purchase Bills & Invoices',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _kTextPrimary, letterSpacing: -0.3),
            ),
          ],
        ),
        actions: [
          // Print Register Report Button
          IconButton(
            icon: const Icon(Icons.print_outlined, color: _kTextPrimary),
            tooltip: isArabic ? 'طباعة سجل المشتريات' : 'Print Purchase Register',
            onPressed: () {
              final purchases = purchasesState.value ?? [];
              final filtered = _applyFilters(purchases);
              _printPurchasesRegister(filtered, isArabic);
            },
          ),

          // Import CSV Button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              side: const BorderSide(color: _kDivider),
            ),
            onPressed: () => _openCsvImport(context, isArabic),
            icon: const Icon(Icons.file_upload_outlined, size: 18),
            label: Text(isArabic ? 'استيراد CSV' : 'Import CSV'),
          ),
          const SizedBox(width: 8),

          // Returns Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade800,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => context.push('/suppliers/returns'),
            icon: const Icon(Icons.assignment_return_outlined, size: 16),
            label: Text(isArabic ? 'مرتجعات الموردين' : 'Supplier Returns'),
          ),
          const SizedBox(width: 8),

          // New Purchase Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => context.goNamed(RouteNames.createPurchase),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(isArabic ? 'إضافة فاتورة شراء' : 'New Purchase'),
          ),
          const SizedBox(width: 8),

          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh, color: _kTextPrimary),
            tooltip: isArabic ? 'تحديث' : 'Refresh',
            onPressed: () => ref.invalidate(purchasesProvider),
          ),
          const SizedBox(width: 8),

          // Guide Button
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: _kPrimary),
            onPressed: () => _showGuideModal(context, isArabic),
            tooltip: isArabic ? 'دليل المشتريات والضريبة' : 'Purchase Guide',
          ),
          const SizedBox(width: 12),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _kDivider),
        ),
      ),
      body: purchasesState.when(
        data: (purchases) {
          final filteredList = _applyFilters(purchases);

          // Calculate KPI metrics
          double totalAmountSum = 0;
          double totalVatSum = 0;
          double unpaidSum = 0;

          for (final p in purchases) {
            final amt = double.tryParse(p.totalAmount) ?? 0;
            final vat = double.tryParse(p.totalVatAmount) ?? 0;
            totalAmountSum += amt;
            totalVatSum += vat;
            if (p.paymentStatus.toUpperCase() != 'PAID') {
              unpaidSum += amt;
            }
          }

          final hasActiveFilters = _searchQuery.isNotEmpty ||
              _filterStatus != 'ALL' ||
              _filterValue != 'ALL' ||
              _sortBy != 'NEWEST';

          return CustomScrollView(
            slivers: [
              // 1. KPI Financial Header Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade600.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.shopping_cart_rounded, color: Colors.blue, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isArabic ? 'ملخص فواتير المشتريات والحسابات الدائنة' : 'Purchases & Accounts Payable Summary',
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isArabic
                                    ? 'نظرة عامة على إجمالي المشتريات، الضريبة المستردة (15%)، والمستحقات المعلقة للموردين.'
                                    : 'Real-time overview of purchase bills, 15% input VAT claims, and outstanding supplier liabilities.',
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 12.5),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        _buildHeaderKpi(
                          label: isArabic ? 'إجمالي الفواتير' : 'Total Invoices',
                          value: '${purchases.length}',
                          icon: Icons.receipt_long_rounded,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        _buildHeaderKpi(
                          label: isArabic ? 'إجمالي المشتريات' : 'Total Invoiced',
                          value: '$currency${totalAmountSum.toStringAsFixed(0)}',
                          icon: Icons.payments_rounded,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 12),
                        _buildHeaderKpi(
                          label: isArabic ? 'ضريبة المشتريات (15%)' : 'Input VAT (15%)',
                          value: '$currency${totalVatSum.toStringAsFixed(0)}',
                          icon: Icons.receipt_rounded,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 12),
                        _buildHeaderKpi(
                          label: isArabic ? 'المبالغ غير المسددة' : 'Unpaid Payables',
                          value: '$currency${unpaidSum.toStringAsFixed(0)}',
                          icon: Icons.pending_actions_rounded,
                          color: Colors.redAccent,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Toolbar (Search, Filter Chips, View Modes & Sort)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _kCardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _kDivider),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Live Search Bar
                            Expanded(
                              child: SizedBox(
                                height: 40,
                                child: TextField(
                                  controller: _searchController,
                                  style: const TextStyle(fontSize: 13),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: isArabic
                                        ? 'البحث برقم الفاتورة، اسم المورد، الصنف، أو المبلغ...'
                                        : 'Search invoice #, supplier, line item, or amount...',
                                    prefixIcon: const Icon(Icons.search_rounded, size: 20, color: _kPrimary),
                                    suffixIcon: _searchController.text.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.clear_rounded, size: 18),
                                            onPressed: () {
                                              _searchController.clear();
                                              setState(() => _searchQuery = '');
                                            },
                                          )
                                        : null,
                                    filled: true,
                                    fillColor: _kSurface,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kDivider)),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kDivider)),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kPrimary, width: 1.5)),
                                  ),
                                  onChanged: (v) => setState(() => _searchQuery = v),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Sort Dropdown
                            Container(
                              height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: _kSurface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: _kDivider),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _sortBy,
                                  icon: const Icon(Icons.sort_rounded, color: _kTextSecondary, size: 20),
                                  style: const TextStyle(fontSize: 13, color: _kTextPrimary, fontWeight: FontWeight.w500),
                                  items: [
                                    DropdownMenuItem(value: 'NEWEST', child: Text(isArabic ? 'الأحدث أولاً' : 'Newest First')),
                                    DropdownMenuItem(value: 'OLDEST', child: Text(isArabic ? 'الأقدم أولاً' : 'Oldest First')),
                                    DropdownMenuItem(value: 'AMOUNT_HIGH', child: Text(isArabic ? 'الأعلى مبلغاً' : 'Highest Amount')),
                                    DropdownMenuItem(value: 'AMOUNT_LOW', child: Text(isArabic ? 'الأقل مبلغاً' : 'Lowest Amount')),
                                    DropdownMenuItem(value: 'INVOICE_ASC', child: Text(isArabic ? 'رقم الفاتورة (أ-ي)' : 'Invoice # (A-Z)')),
                                  ],
                                  onChanged: (v) => setState(() => _sortBy = v!),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // View Mode Toggle (Card, Grid, List)
                            Container(
                              height: 40,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: _kSurface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: _kDivider),
                              ),
                              child: Row(
                                children: [
                                  _buildViewModeBtn(
                                    mode: PurchaseViewMode.card,
                                    icon: Icons.view_agenda_rounded,
                                    tooltip: isArabic ? 'عرض الكروت' : 'Card View',
                                  ),
                                  _buildViewModeBtn(
                                    mode: PurchaseViewMode.grid,
                                    icon: Icons.grid_view_rounded,
                                    tooltip: isArabic ? 'عرض شبكي' : 'Grid View',
                                  ),
                                  _buildViewModeBtn(
                                    mode: PurchaseViewMode.list,
                                    icon: Icons.table_chart_rounded,
                                    tooltip: isArabic ? 'عرض الجدول' : 'Table / List View',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Filter Chips
                        Row(
                          children: [
                            Text(
                              isArabic ? 'حالة الدفع:' : 'Payment Status:',
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: _kTextSecondary),
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip('ALL', isArabic ? 'الكل' : 'All', _filterStatus == 'ALL', (selected) {
                              if (selected) setState(() => _filterStatus = 'ALL');
                            }),
                            const SizedBox(width: 6),
                            _buildFilterChip('PAID', isArabic ? 'مدفوع' : 'Paid', _filterStatus == 'PAID', (selected) {
                              if (selected) setState(() => _filterStatus = 'PAID');
                            }, color: Colors.green),
                            const SizedBox(width: 6),
                            _buildFilterChip('UNPAID', isArabic ? 'غير مدفوع' : 'Unpaid', _filterStatus == 'UNPAID', (selected) {
                              if (selected) setState(() => _filterStatus = 'UNPAID');
                            }, color: Colors.red),
                            const SizedBox(width: 6),
                            _buildFilterChip('PARTIAL', isArabic ? 'جزئي' : 'Partial', _filterStatus == 'PARTIAL', (selected) {
                              if (selected) setState(() => _filterStatus = 'PARTIAL');
                            }, color: Colors.amber),
                            const SizedBox(width: 6),
                            _buildFilterChip('OVERDUE', isArabic ? 'متأخر' : 'Overdue', _filterStatus == 'OVERDUE', (selected) {
                              if (selected) setState(() => _filterStatus = 'OVERDUE');
                            }, color: Colors.purple),

                            const Spacer(),
                            Text(
                              isArabic ? 'تصفية إضافية:' : 'Quick Filters:',
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: _kTextSecondary),
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip('ALL', isArabic ? 'الكل' : 'All Values', _filterValue == 'ALL', (selected) {
                              if (selected) setState(() => _filterValue = 'ALL');
                            }),
                            const SizedBox(width: 6),
                            _buildFilterChip('HIGH_VALUE', isArabic ? 'مبالغ عالية (+5000)' : 'High Value (>5k)', _filterValue == 'HIGH_VALUE', (selected) {
                              if (selected) setState(() => _filterValue = 'HIGH_VALUE');
                            }, color: Colors.blue),
                            const SizedBox(width: 6),
                            _buildFilterChip('THIS_MONTH', isArabic ? 'هذا الشهر' : 'This Month', _filterValue == 'THIS_MONTH', (selected) {
                              if (selected) setState(() => _filterValue = 'THIS_MONTH');
                            }, color: Colors.teal),

                            if (hasActiveFilters) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.filter_alt_off, size: 18),
                                tooltip: isArabic ? 'إعادة ضبط الفلاتر' : 'Reset Filters',
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                    _filterStatus = 'ALL';
                                    _filterValue = 'ALL';
                                    _sortBy = 'NEWEST';
                                  });
                                },
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Body View Content based on View Mode
              if (filteredList.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_rounded, size: 56, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          isArabic ? 'لم يتم العثور على فواتير شراء تطابق البحث' : 'No purchase invoices found matching criteria',
                          style: const TextStyle(fontSize: 16, color: _kTextSecondary, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 16),
                        if (hasActiveFilters)
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                                _filterStatus = 'ALL';
                                _filterValue = 'ALL';
                                _sortBy = 'NEWEST';
                              });
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: Text(isArabic ? 'إعادة ضبط التصفية' : 'Reset Filters'),
                          )
                        else
                          ElevatedButton.icon(
                            onPressed: () => context.goNamed(RouteNames.createPurchase),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: Text(isArabic ? 'إضافة أول فاتورة شراء' : 'Create First Purchase Invoice'),
                          ),
                      ],
                    ),
                  ),
                )
              else if (_viewMode == PurchaseViewMode.card)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildCardItem(filteredList[index], isArabic),
                      childCount: filteredList.length,
                    ),
                  ),
                )
              else if (_viewMode == PurchaseViewMode.grid)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 420,
                      mainAxisExtent: 290,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildGridItem(filteredList[index], isArabic),
                      childCount: filteredList.length,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  sliver: SliverToBoxAdapter(
                    child: _buildListViewTable(filteredList, isArabic),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
              const SizedBox(height: 10),
              Text(
                isArabic ? 'خطأ في تحميل المشتريات: $error' : 'Error loading purchases: $error',
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: () => ref.invalidate(purchasesProvider),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _kPrimary,
        onPressed: () => context.goNamed(RouteNames.createPurchase),
        tooltip: isArabic ? 'إضافة فاتورة شراء' : 'New Purchase Invoice',
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildHeaderKpi({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeBtn({
    required PurchaseViewMode mode,
    required IconData icon,
    required String tooltip,
  }) {
    final isSelected = _viewMode == mode;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => setState(() => _viewMode = mode),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isSelected ? _kCardBg : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : null,
          ),
          child: Icon(
            icon,
            size: 18,
            color: isSelected ? _kPrimary : _kTextSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String key,
    String label,
    bool isSelected,
    ValueChanged<bool> onSelected, {
    Color color = _kPrimary,
  }) {
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 11.5,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? Colors.white : _kTextPrimary,
      ),
      selectedColor: color,
      backgroundColor: _kSurface,
      checkmarkColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: isSelected ? color : _kDivider),
      ),
      onSelected: onSelected,
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // 1. CARD VIEW ITEM
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildCardItem(PurchaseModel item, bool isArabic) {
    final currency = isArabic ? 'ر.س ' : 'SAR ';
    final subtotal = double.tryParse(item.subtotalAmount) ?? 0.0;
    final vat = double.tryParse(item.totalVatAmount) ?? 0.0;
    final total = double.tryParse(item.totalAmount) ?? 0.0;
    final isOverdue = item.dueDate != null && item.dueDate!.isBefore(DateTime.now()) && item.paymentStatus.toUpperCase() != 'PAID';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isOverdue ? Colors.red.shade200 : _kDivider),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: InkWell(
        onTap: () => _openDetails(item, isArabic),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _kPrimary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: _kPrimary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              item.invoiceNumber,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _kTextPrimary),
                            ),
                            const SizedBox(width: 8),
                            _buildStatusBadge(item.paymentStatus, isArabic),
                            if (isOverdue) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isArabic ? 'متأخر' : 'OVERDUE',
                                  style: TextStyle(color: Colors.red.shade900, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${isArabic ? "المورد" : "Supplier"}: ${item.supplierName ?? ProcurementDocumentFormatter.formatSupplierCode(item.supplierId)} (${ProcurementDocumentFormatter.formatSupplierCode(item.supplierId)})  •  ${isArabic ? "التاريخ" : "Date"}: ${_formatDate(item.issueDate)}',
                          style: const TextStyle(fontSize: 12.5, color: _kTextSecondary),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$currency${total.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _kPrimary),
                      ),
                      Text(
                        '${isArabic ? "الصافي" : "Net"}: $currency${subtotal.toStringAsFixed(2)}  |  ${isArabic ? "الضريبة" : "VAT"}: $currency${vat.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 11, color: _kTextSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              if (item.lineItems.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(height: 1, color: _kDivider),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.format_list_bulleted_rounded, size: 14, color: _kTextSecondary),
                    const SizedBox(width: 6),
                    Text(
                      '${item.lineItems.length} ${isArabic ? "أصناف في الفاتورة" : "Line items"}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _kTextSecondary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.lineItems.first.description,
                        style: const TextStyle(fontSize: 12, color: _kTextPrimary, fontStyle: FontStyle.italic),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Tooltip(
                          message: isArabic ? 'طباعة الفاتورة' : 'Print Invoice PDF',
                          child: IconButton(
                            icon: const Icon(Icons.print, size: 18, color: _kTextSecondary),
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _printSingleInvoice(item),
                          ),
                        ),

                        TextButton(
                          onPressed: () => _openDetails(item, isArabic),
                          style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                          child: Text(isArabic ? 'عرض التفاصيل' : 'View Details', style: const TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // 2. GRID VIEW ITEM
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildGridItem(PurchaseModel item, bool isArabic) {
    final currency = isArabic ? 'ر.س ' : 'SAR ';
    final total = double.tryParse(item.totalAmount) ?? 0.0;
    final subtotal = double.tryParse(item.subtotalAmount) ?? 0.0;
    final vat = double.tryParse(item.totalVatAmount) ?? 0.0;
    final isOverdue = item.dueDate != null && item.dueDate!.isBefore(DateTime.now()) && item.paymentStatus.toUpperCase() != 'PAID';

    return Container(
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isOverdue ? Colors.red.shade200 : _kDivider),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: InkWell(
        onTap: () => _openDetails(item, isArabic),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _kPrimary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: _kPrimary, size: 20),
                  ),
                  Row(
                    children: [
                      if (isOverdue) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isArabic ? 'متأخر' : 'OVERDUE',
                            style: TextStyle(color: Colors.red.shade900, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      _buildStatusBadge(item.paymentStatus, isArabic),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item.invoiceNumber,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _kTextPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${isArabic ? "المورد" : "Supplier"}: ${item.supplierName ?? ProcurementDocumentFormatter.formatSupplierCode(item.supplierId)} (${ProcurementDocumentFormatter.formatSupplierCode(item.supplierId)})',
                style: const TextStyle(fontSize: 12, color: _kTextSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${item.lineItems.length} ${isArabic ? "أصناف" : "Items"}',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _kTextSecondary),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(item.issueDate),
                    style: const TextStyle(fontSize: 11, color: _kTextSecondary),
                  ),
                ],
              ),
              const Spacer(),
              const Divider(height: 12, color: _kDivider),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$currency${total.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _kPrimary),
                      ),
                      Text(
                        '${isArabic ? "صافي" : "Net"}: $currency${subtotal.toStringAsFixed(0)} | ${isArabic ? "ضريبة" : "VAT"}: $currency${vat.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 10, color: _kTextSecondary),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.print, size: 16, color: _kTextSecondary),
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _printSingleInvoice(item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.visibility, size: 16, color: _kPrimary),
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _openDetails(item, isArabic),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // 3. LIST VIEW TABLE ITEM
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildListViewTable(List<PurchaseModel> items, bool isArabic) {
    final currency = isArabic ? 'ر.س ' : 'SAR ';
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kDivider),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 46,
          headingRowColor: WidgetStateProperty.all(_kSurface),
          columnSpacing: 18,
          columns: [
            DataColumn(label: Text(isArabic ? 'رقم الفاتورة' : 'Invoice Number', style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text(isArabic ? 'المورد' : 'Supplier', style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text(isArabic ? 'تاريخ الإصدار' : 'Issue Date', style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text(isArabic ? 'تاريخ الاستحقاق' : 'Due Date', style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text(isArabic ? 'الأصناف' : 'Items', style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text(isArabic ? 'المبلغ الصافي' : 'Subtotal', style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text(isArabic ? 'الضريبة (15%)' : 'VAT (15%)', style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text(isArabic ? 'الإجمالي' : 'Total Amount', style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text(isArabic ? 'حالة الدفع' : 'Payment Status', style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text(isArabic ? 'إجراءات' : 'Actions', style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: items.map((p) {
            final subtotal = double.tryParse(p.subtotalAmount) ?? 0.0;
            final vat = double.tryParse(p.totalVatAmount) ?? 0.0;
            final total = double.tryParse(p.totalAmount) ?? 0.0;

            return DataRow(
              cells: [
                DataCell(
                  InkWell(
                    onTap: () => _openDetails(p, isArabic),
                    child: Text(
                      p.invoiceNumber,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: _kPrimary, decoration: TextDecoration.underline),
                    ),
                  ),
                ),
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(p.supplierName ?? ProcurementDocumentFormatter.formatSupplierCode(p.supplierId), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                      Text(ProcurementDocumentFormatter.formatSupplierCode(p.supplierId), style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                DataCell(Text(dateFormat.format(p.issueDate), style: const TextStyle(fontSize: 12))),
                DataCell(Text(p.dueDate != null ? dateFormat.format(p.dueDate!) : '-', style: const TextStyle(fontSize: 12))),
                DataCell(Text('${p.lineItems.length}', style: const TextStyle(fontSize: 12))),
                DataCell(Text('$currency${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12))),
                DataCell(Text('$currency${vat.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12))),
                DataCell(Text('$currency${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                DataCell(_buildStatusBadge(p.paymentStatus, isArabic)),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Tooltip(
                        message: isArabic ? 'طباعة الفاتورة' : 'Print Invoice PDF',
                        child: IconButton(
                          icon: const Icon(Icons.print, size: 16),
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _printSingleInvoice(p),
                        ),
                      ),
                      Tooltip(
                        message: isArabic ? 'عرض التفاصيل' : 'View Details',
                        child: IconButton(
                          icon: const Icon(Icons.visibility, size: 16),
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _openDetails(p, isArabic),
                        ),
                      ),

                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool isArabic) {
    Color bg;
    Color fg;
    String label;

    switch (status.toUpperCase()) {
      case 'PAID':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        label = isArabic ? 'مدفوع' : 'PAID';
        break;
      case 'PARTIAL':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        label = isArabic ? 'جزئي' : 'PARTIAL';
        break;
      case 'UNPAID':
      default:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFB91C1C);
        label = isArabic ? 'غير مدفوع' : 'UNPAID';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
