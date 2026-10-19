import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:erp_frontend/app.dart';
import '../domain/procurement_models.dart';
import '../providers/procurement_provider.dart';
import '../utils/po_pdf_printer.dart';
import '../utils/procurement_document_formatter.dart';
import 'widgets/purchase_order_details_dialog.dart';
import 'widgets/issue_purchase_order_dialog.dart';
import 'widgets/receive_goods_dialog.dart';

enum PoViewMode { cards, grid, table }

enum PoSortField { dateDesc, dateAsc, amountDesc, amountAsc, poNumberAsc, supplierAsc }

class PurchaseOrdersScreen extends ConsumerStatefulWidget {
  const PurchaseOrdersScreen({super.key});

  @override
  ConsumerState<PurchaseOrdersScreen> createState() => _PurchaseOrdersScreenState();
}

class _PurchaseOrdersScreenState extends ConsumerState<PurchaseOrdersScreen> {
  String _searchQuery = '';
  String _selectedStatus = 'ALL';
  String _selectedSupplier = 'ALL';
  String _selectedDateRange = 'ALL'; // ALL, TODAY, WEEK, MONTH
  PoViewMode _viewMode = PoViewMode.cards;
  PoSortField _sortField = PoSortField.dateDesc;

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(purchaseOrdersProvider);
    final theme = Theme.of(context);
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.assignment_outlined, color: theme.colorScheme.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              isArabic ? 'أوامر الشراء الرسمية (POs)' : 'Purchase Orders (POs)',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          // Language toggle
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: isArabic ? 'تغيير اللغة' : 'Switch Language',
            onPressed: () {
              final current = ref.read(localeProvider);
              ref.read(localeProvider.notifier).state =
                  current.languageCode == 'en' ? const Locale('ar') : const Locale('en');
            },
          ),
          // Refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: isArabic ? 'تحديث' : 'Refresh',
            onPressed: () => ref.invalidate(purchaseOrdersProvider),
          ),
          const SizedBox(width: 8),
          // Issue PO Button
          FilledButton.icon(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.add_shopping_cart, size: 18),
            label: Text(
              isArabic ? 'إصدار أمر شراء (Issue PO)' : 'Issue Purchase Order',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () => _openIssuePoDialog(context, isArabic),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ordersAsync.when(
        data: (orders) => _buildContent(context, orders, isArabic, theme),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(
                '${isArabic ? "فشل تحميل أوامر الشراء:" : "Failed to load Purchase Orders:"} $err',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
                onPressed: () => ref.invalidate(purchaseOrdersProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<PurchaseOrderModel> allOrders,
    bool isArabic,
    ThemeData theme,
  ) {
    // 1. Gather all suppliers for the filter dropdown
    final supplierSet = <String>{};
    for (final po in allOrders) {
      if (po.supplierName.isNotEmpty) supplierSet.add(po.supplierName);
    }
    final supplierList = supplierSet.toList()..sort();

    // 2. Filter orders
    final filtered = allOrders.where((po) {
      // Query search
      final q = _searchQuery.toLowerCase();
      final matchQuery = q.isEmpty ||
          po.poNumber.toLowerCase().contains(q) ||
          po.supplierName.toLowerCase().contains(q) ||
          (po.notes ?? '').toLowerCase().contains(q) ||
          po.items.any((i) => i.description.toLowerCase().contains(q) || (i.productId ?? '').toLowerCase().contains(q));

      // Status filter
      final matchStatus = _selectedStatus == 'ALL' || po.status.toUpperCase() == _selectedStatus.toUpperCase();

      // Supplier filter
      final matchSupplier = _selectedSupplier == 'ALL' || po.supplierName == _selectedSupplier;

      // Date range filter
      bool matchDate = true;
      if (_selectedDateRange != 'ALL') {
        final now = DateTime.now();
        final startOfToday = DateTime(now.year, now.month, now.day);
        if (_selectedDateRange == 'TODAY') {
          matchDate = po.issueDate.isAfter(startOfToday);
        } else if (_selectedDateRange == 'WEEK') {
          final weekAgo = startOfToday.subtract(const Duration(days: 7));
          matchDate = po.issueDate.isAfter(weekAgo);
        } else if (_selectedDateRange == 'MONTH') {
          final monthAgo = startOfToday.subtract(const Duration(days: 30));
          matchDate = po.issueDate.isAfter(monthAgo);
        }
      }

      return matchQuery && matchStatus && matchSupplier && matchDate;
    }).toList();

    // 3. Sort orders
    filtered.sort((a, b) {
      switch (_sortField) {
        case PoSortField.dateDesc:
          return b.issueDate.compareTo(a.issueDate);
        case PoSortField.dateAsc:
          return a.issueDate.compareTo(b.issueDate);
        case PoSortField.amountDesc:
          final aAmt = double.tryParse(a.totalAmount) ?? 0.0;
          final bAmt = double.tryParse(b.totalAmount) ?? 0.0;
          return bAmt.compareTo(aAmt);
        case PoSortField.amountAsc:
          final aAmt = double.tryParse(a.totalAmount) ?? 0.0;
          final bAmt = double.tryParse(b.totalAmount) ?? 0.0;
          return aAmt.compareTo(bAmt);
        case PoSortField.poNumberAsc:
          return a.poNumber.compareTo(b.poNumber);
        case PoSortField.supplierAsc:
          return a.supplierName.compareTo(b.supplierName);
      }
    });

    // 4. Compute metrics summary
    final totalPoCount = allOrders.length;
    final issuedCount = allOrders.where((o) => o.status == 'ISSUED').length;
    final receivedCount = allOrders.where((o) => o.status == 'RECEIVED' || o.status == 'COMPLETED').length;
    final totalSum = allOrders.fold(0.0, (acc, o) => acc + (double.tryParse(o.totalAmount) ?? 0.0));

    return Column(
      children: [
        // Top KPI Cards
        _buildKpiBanner(theme, isArabic, totalPoCount, issuedCount, receivedCount, totalSum),

        // Filter & Sorting Control Bar
        _buildControlBar(theme, isArabic, supplierList, filtered.length, allOrders.length),

        // Main Display (Cards / Grid / Table)
        Expanded(
          child: filtered.isEmpty
              ? _buildEmptyState(theme, isArabic)
              : _buildViewContent(context, filtered, isArabic, theme),
        ),
      ],
    );
  }

  Widget _buildKpiBanner(
    ThemeData theme,
    bool isArabic,
    int totalCount,
    int issuedCount,
    int receivedCount,
    double totalSum,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          _buildKpiItem(
            theme,
            title: isArabic ? 'إجمالي الأوامر' : 'Total POs',
            value: '$totalCount',
            icon: Icons.list_alt,
            color: Colors.blue.shade700,
          ),
          const VerticalDivider(width: 24),
          _buildKpiItem(
            theme,
            title: isArabic ? 'قيد التوريد (Issued)' : 'Issued / Pending',
            value: '$issuedCount',
            icon: Icons.pending_actions,
            color: Colors.amber.shade800,
          ),
          const VerticalDivider(width: 24),
          _buildKpiItem(
            theme,
            title: isArabic ? 'مكتمل التوريد' : 'Received / Complete',
            value: '$receivedCount',
            icon: Icons.check_circle_outline,
            color: Colors.green.shade700,
          ),
          const VerticalDivider(width: 24),
          _buildKpiItem(
            theme,
            title: isArabic ? 'إجمالي المشتريات' : 'Total PO Value',
            value: 'SAR ${totalSum.toStringAsFixed(2)}',
            icon: Icons.account_balance_wallet_outlined,
            color: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildKpiItem(
    ThemeData theme, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBar(
    ThemeData theme,
    bool isArabic,
    List<String> suppliers,
    int showingCount,
    int totalCount,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          // Row 1: Search, Status, Supplier, Dates
          Row(
            children: [
              // Search input
              Expanded(
                flex: 3,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: isArabic
                        ? 'بحث برقم الأمر، اسم المورد، الصنف...'
                        : 'Search PO #, supplier, SKU, description...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    isDense: true,
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              const SizedBox(width: 10),

              // Status Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedStatus,
                    items: [
                      DropdownMenuItem(value: 'ALL', child: Text(isArabic ? 'كل الحالات' : 'All Statuses')),
                      const DropdownMenuItem(value: 'ISSUED', child: Text('ISSUED')),
                      const DropdownMenuItem(value: 'PARTIAL_RECEIVED', child: Text('PARTIAL_RECEIVED')),
                      const DropdownMenuItem(value: 'RECEIVED', child: Text('RECEIVED')),
                      const DropdownMenuItem(value: 'COMPLETED', child: Text('COMPLETED')),
                      const DropdownMenuItem(value: 'CANCELLED', child: Text('CANCELLED')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedStatus = val);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Supplier Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedSupplier,
                    items: [
                      DropdownMenuItem(value: 'ALL', child: Text(isArabic ? 'جميع الموردين' : 'All Suppliers')),
                      ...suppliers.map((s) => DropdownMenuItem(value: s, child: Text(s))),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedSupplier = val);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Date Filter Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDateRange,
                    items: [
                      DropdownMenuItem(value: 'ALL', child: Text(isArabic ? 'كل الفترات' : 'All Dates')),
                      DropdownMenuItem(value: 'TODAY', child: Text(isArabic ? 'اليوم' : 'Today')),
                      DropdownMenuItem(value: 'WEEK', child: Text(isArabic ? 'آخر 7 أيام' : 'Last 7 Days')),
                      DropdownMenuItem(value: 'MONTH', child: Text(isArabic ? 'آخر 30 يوم' : 'Last 30 Days')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedDateRange = val);
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Row 2: Active count, Sorting dropdown, View mode switcher
          Row(
            children: [
              Text(
                '${isArabic ? "عرض" : "Showing"} $showingCount ${isArabic ? "من" : "of"} $totalCount',
                style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color, fontWeight: FontWeight.w600),
              ),
              if (_hasActiveFilters) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: _resetFilters,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.close, size: 14, color: Colors.red),
                        const SizedBox(width: 4),
                        Text(
                          isArabic ? 'إلغاء التصفية' : 'Clear Filters',
                          style: const TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const Spacer(),

              // Sort dropdown
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sort, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(isArabic ? 'ترتيب حسب:' : 'Sort by:', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 6),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<PoSortField>(
                      value: _sortField,
                      isDense: true,
                      items: [
                        DropdownMenuItem(value: PoSortField.dateDesc, child: Text(isArabic ? 'التاريخ (الأحدث)' : 'Date (Newest)')),
                        DropdownMenuItem(value: PoSortField.dateAsc, child: Text(isArabic ? 'التاريخ (الأقدم)' : 'Date (Oldest)')),
                        DropdownMenuItem(value: PoSortField.amountDesc, child: Text(isArabic ? 'المبلغ (الأعلى)' : 'Amount (High-Low)')),
                        DropdownMenuItem(value: PoSortField.amountAsc, child: Text(isArabic ? 'المبلغ (الأقل)' : 'Amount (Low-High)')),
                        DropdownMenuItem(value: PoSortField.poNumberAsc, child: Text(isArabic ? 'رقم الأمر (تصاعدي)' : 'PO # (A-Z)')),
                        DropdownMenuItem(value: PoSortField.supplierAsc, child: Text(isArabic ? 'المورد (أ-ي)' : 'Supplier (A-Z)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _sortField = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // View Mode Toggle (Cards / Grid / Table)
              SegmentedButton<PoViewMode>(
                segments: [
                  ButtonSegment(
                    value: PoViewMode.cards,
                    icon: const Icon(Icons.view_agenda_outlined, size: 18),
                    tooltip: isArabic ? 'عرض البطاقات' : 'Card View',
                  ),
                  ButtonSegment(
                    value: PoViewMode.grid,
                    icon: const Icon(Icons.grid_view_rounded, size: 18),
                    tooltip: isArabic ? 'عرض الشبكة' : 'Grid View',
                  ),
                  ButtonSegment(
                    value: PoViewMode.table,
                    icon: const Icon(Icons.table_rows_outlined, size: 18),
                    tooltip: isArabic ? 'عرض الجدول' : 'Table View',
                  ),
                ],
                selected: {_viewMode},
                onSelectionChanged: (set) => setState(() => _viewMode = set.first),
                style: const ButtonStyle(visualDensity: VisualDensity.compact),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool get _hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _selectedStatus != 'ALL' ||
      _selectedSupplier != 'ALL' ||
      _selectedDateRange != 'ALL';

  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _selectedStatus = 'ALL';
      _selectedSupplier = 'ALL';
      _selectedDateRange = 'ALL';
    });
  }

  Widget _buildEmptyState(ThemeData theme, bool isArabic) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: theme.dividerColor),
          const SizedBox(height: 16),
          Text(
            isArabic ? 'لم يتم العثور على أوامر شراء مطابقة' : 'No Purchase Orders match your filters',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            isArabic ? 'جرّب تغيير كلمات البحث أو إعادة ضبط خيارات التصفية.' : 'Try adjusting your search criteria or resetting filters.',
            style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 13),
          ),
          if (_hasActiveFilters) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              icon: const Icon(Icons.filter_alt_off),
              label: Text(isArabic ? 'إعادة ضبط التصفية' : 'Reset Filters'),
              onPressed: _resetFilters,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildViewContent(
    BuildContext context,
    List<PurchaseOrderModel> orders,
    bool isArabic,
    ThemeData theme,
  ) {
    switch (_viewMode) {
      case PoViewMode.cards:
        return _buildCardsView(context, orders, isArabic, theme);
      case PoViewMode.grid:
        return _buildGridView(context, orders, isArabic, theme);
      case PoViewMode.table:
        return _buildTableView(context, orders, isArabic, theme);
    }
  }

  // ──────────────────────────────────────────────
  // 1. CARDS VIEW (Expandable Rich Cards)
  // ──────────────────────────────────────────────
  Widget _buildCardsView(
    BuildContext context,
    List<PurchaseOrderModel> orders,
    bool isArabic,
    ThemeData theme,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final po = orders[index];
        final subtotal = double.tryParse(po.subtotalAmount) ?? 0.0;
        final vat = double.tryParse(po.vatAmount) ?? 0.0;
        final total = double.tryParse(po.totalAmount) ?? 0.0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.4)),
          ),
          child: ExpansionTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(Icons.receipt, color: theme.colorScheme.primary, size: 20),
            ),
            title: Row(
              children: [
                Text(po.poNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(width: 10),
                _buildStatusBadge(po.status),
                const SizedBox(width: 8),
                Text(
                  '• ${po.items.length} ${isArabic ? "أصناف" : "items"}',
                  style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(Icons.business, size: 14, color: theme.textTheme.bodySmall?.color),
                  const SizedBox(width: 4),
                  Text(
                    '${po.supplierName} (${ProcurementDocumentFormatter.formatSupplierCode(po.supplierId)})',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.textTheme.bodyMedium?.color),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.calendar_today, size: 13, color: theme.textTheme.bodySmall?.color),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('yyyy-MM-dd').format(po.issueDate),
                    style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                  ),
                  if (po.expectedDeliveryDate != null) ...[
                    const SizedBox(width: 12),
                    Icon(Icons.local_shipping_outlined, size: 14, color: Colors.blue.shade700),
                    const SizedBox(width: 4),
                    Text(
                      '${isArabic ? "التسليم:" : "Delivery:"} ${DateFormat('yyyy-MM-dd').format(po.expectedDeliveryDate!)}',
                      style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                    ),
                  ],
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'SAR ${total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      'VAT: SAR ${vat.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 10, color: theme.textTheme.bodySmall?.color),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.move_to_inbox_rounded, color: Colors.teal, size: 20),
                  tooltip: isArabic ? 'استلام البضائع (GRN)' : 'Receive Goods (GRN)',
                  onPressed: () => _openReceiveGoodsForPo(context, po, isArabic),
                ),
                IconButton(
                  icon: const Icon(Icons.print_outlined, size: 20),
                  tooltip: isArabic ? 'طباعة / PDF' : 'Print PO / PDF',
                  onPressed: () => PoPdfPrinter.printPo(po),
                ),
                IconButton(
                  icon: const Icon(Icons.visibility_outlined, size: 20),
                  tooltip: isArabic ? 'عرض التفاصيل الكاملة' : 'View Formatted Order',
                  onPressed: () => _openDetailsDialog(context, po, isArabic),
                ),
              ],
            ),
            children: [
              const Divider(height: 1),
              Container(
                padding: const EdgeInsets.all(16),
                color: theme.colorScheme.surfaceContainerLow,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Line items list
                    Text(
                      isArabic ? 'تفاصيل بنود أمر الشراء:' : 'Purchase Order Line Items:',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        children: po.items.asMap().entries.map((entry) {
                          final i = entry.value;
                          final idx = entry.key + 1;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              border: entry.key > 0
                                  ? Border(top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)))
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Text('$idx.', style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color)),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(i.description, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                      if (i.productId != null && i.productId!.isNotEmpty)
                                        Text('SKU: ${i.productId}', style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color)),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${i.quantity} x SAR ${i.unitPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                Text(
                                  'SAR ${i.totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Notes & Financial strip
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            (po.notes != null && po.notes!.isNotEmpty)
                                ? '${isArabic ? "ملاحظات:" : "Notes:"} ${po.notes}'
                                : '',
                            style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '${isArabic ? "المجموع الفرعي:" : "Subtotal:"} SAR ${subtotal.toStringAsFixed(2)}  |  ${isArabic ? "الضريبة:" : "VAT:"} SAR ${vat.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                            ),
                            const SizedBox(width: 14),
                            TextButton.icon(
                              icon: const Icon(Icons.edit_note, size: 16),
                              label: Text(isArabic ? 'تحديث الحالة / تفاصيل' : 'Manage / Details'),
                              onPressed: () => _openDetailsDialog(context, po, isArabic),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ──────────────────────────────────────────────
  // 2. GRID VIEW (Modern Responsive Tiles)
  // ──────────────────────────────────────────────
  Widget _buildGridView(
    BuildContext context,
    List<PurchaseOrderModel> orders,
    bool isArabic,
    ThemeData theme,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 3;
        if (constraints.maxWidth < 750) {
          crossAxisCount = 1;
        } else if (constraints.maxWidth < 1150) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: 220,
          ),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final po = orders[index];
            final total = double.tryParse(po.totalAmount) ?? 0.0;
            final vat = double.tryParse(po.vatAmount) ?? 0.0;

            return Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.4)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: PO Number & Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          po.poNumber,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        _buildStatusBadge(po.status),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Supplier Name
                    Row(
                      children: [
                        Icon(Icons.storefront, size: 16, color: theme.colorScheme.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(po.supplierName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
                              Text(ProcurementDocumentFormatter.formatSupplierCode(po.supplierId), style: TextStyle(fontSize: 10, color: theme.textTheme.bodySmall?.color)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Dates
                    Text(
                      '${isArabic ? "التاريخ:" : "Issued:"} ${DateFormat('yyyy-MM-dd').format(po.issueDate)}'
                      '${po.expectedDeliveryDate != null ? " • ${isArabic ? "التسليم:" : "Due:"} ${DateFormat('MM-dd').format(po.expectedDeliveryDate!)}" : ""}',
                      style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color),
                    ),

                    const Spacer(),

                    // Items summary preview
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${po.items.length} ${isArabic ? "أصناف مطلوبة" : "Line items"}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'SAR ${total.toStringAsFixed(2)}',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: theme.colorScheme.primary),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'VAT: SAR ${vat.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 10, color: theme.textTheme.bodySmall?.color),
                        ),
                        Row(
                          children: [
                            IconButton.filledTonal(
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.print_outlined, size: 16),
                              tooltip: isArabic ? 'طباعة / PDF' : 'Print PO',
                              onPressed: () => PoPdfPrinter.printPo(po),
                            ),
                            const SizedBox(width: 6),
                            FilledButton.tonal(
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: () => _openDetailsDialog(context, po, isArabic),
                              child: Text(isArabic ? 'تفاصيل' : 'Details', style: const TextStyle(fontSize: 11)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ──────────────────────────────────────────────
  // 3. TABLE VIEW (Dense Column View)
  // ──────────────────────────────────────────────
  Widget _buildTableView(
    BuildContext context,
    List<PurchaseOrderModel> orders,
    bool isArabic,
    ThemeData theme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
        ),
        clipBehavior: Clip.antiAlias,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)),
          columns: [
            DataColumn(label: Text(isArabic ? 'رقم الأمر' : 'PO Number', style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text(isArabic ? 'المورد' : 'Supplier', style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text(isArabic ? 'تاريخ الإصدار' : 'Issue Date', style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text(isArabic ? 'تاريخ التوريد' : 'Delivery Due', style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text(isArabic ? 'عدد الأصناف' : 'Items', style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text(isArabic ? 'المجموع الفرعي' : 'Subtotal', style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text(isArabic ? 'الضريبة' : 'VAT (15%)', style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text(isArabic ? 'الإجمالي (SAR)' : 'Total (SAR)', style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text(isArabic ? 'الحالة' : 'Status', style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text(isArabic ? 'الإجراءات' : 'Actions', style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: orders.map((po) {
            final subtotal = double.tryParse(po.subtotalAmount) ?? 0.0;
            final vat = double.tryParse(po.vatAmount) ?? 0.0;
            final total = double.tryParse(po.totalAmount) ?? 0.0;

            return DataRow(
              cells: [
                DataCell(Text(po.poNumber, style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(po.supplierName, style: const TextStyle(fontWeight: FontWeight.w600)), Text(ProcurementDocumentFormatter.formatSupplierCode(po.supplierId), style: TextStyle(fontSize: 10, color: theme.textTheme.bodySmall?.color))])),
                DataCell(Text(DateFormat('yyyy-MM-dd').format(po.issueDate))),
                DataCell(Text(po.expectedDeliveryDate != null ? DateFormat('yyyy-MM-dd').format(po.expectedDeliveryDate!) : '-')),
                DataCell(Center(child: Text('${po.items.length}'))),
                DataCell(Text('SAR ${subtotal.toStringAsFixed(2)}')),
                DataCell(Text('SAR ${vat.toStringAsFixed(2)}')),
                DataCell(Text('SAR ${total.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary))),
                DataCell(_buildStatusBadge(po.status)),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.move_to_inbox_rounded, color: Colors.teal, size: 18),
                        tooltip: isArabic ? 'استلام البضائع (GRN)' : 'Receive Goods (GRN)',
                        onPressed: () => _openReceiveGoodsForPo(context, po, isArabic),
                      ),
                      IconButton(
                        icon: const Icon(Icons.print_outlined, size: 18),
                        tooltip: isArabic ? 'طباعة' : 'Print',
                        onPressed: () => PoPdfPrinter.printPo(po),
                      ),
                      IconButton(
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                        tooltip: isArabic ? 'التفاصيل' : 'Details',
                        onPressed: () => _openDetailsDialog(context, po, isArabic),
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

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    switch (status.toUpperCase()) {
      case 'ISSUED':
        bg = Colors.blue.withValues(alpha: 0.15);
        fg = Colors.blue.shade800;
        break;
      case 'PARTIAL_RECEIVED':
        bg = Colors.amber.withValues(alpha: 0.15);
        fg = Colors.amber.shade900;
        break;
      case 'RECEIVED':
      case 'COMPLETED':
        bg = Colors.green.withValues(alpha: 0.15);
        fg = Colors.green.shade800;
        break;
      case 'CANCELLED':
        bg = Colors.red.withValues(alpha: 0.15);
        fg = Colors.red.shade800;
        break;
      default:
        bg = Colors.grey.withValues(alpha: 0.2);
        fg = Colors.grey.shade800;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Text(
        status,
        style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  void _openDetailsDialog(BuildContext context, PurchaseOrderModel po, bool isArabic) {
    showDialog(
      context: context,
      builder: (ctx) => PurchaseOrderDetailsDialog(po: po, isArabic: isArabic),
    );
  }

  void _openIssuePoDialog(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (ctx) => IssuePurchaseOrderDialog(isArabic: isArabic),
    );
  }

  void _openReceiveGoodsForPo(BuildContext context, PurchaseOrderModel po, bool isArabic) {
    showDialog(
      context: context,
      builder: (ctx) => ReceiveGoodsDialog(preselectedPo: po, isArabic: isArabic),
    );
  }
}
