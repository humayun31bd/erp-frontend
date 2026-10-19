import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:erp_frontend/app.dart';
import '../../../../core/widgets/feature_guard.dart';
import '../domain/procurement_models.dart';
import '../providers/procurement_provider.dart';
import '../utils/grn_pdf_printer.dart';
import '../utils/procurement_document_formatter.dart';
import 'widgets/grn_details_dialog.dart';
import 'widgets/receive_goods_dialog.dart';

enum GrnViewMode { cards, grid, table }

enum GrnSortBy {
  dateDesc,
  dateAsc,
  grnNumberAsc,
  supplierAsc,
  receivedQtyDesc,
  valueDesc,
}

class GoodsReceivedScreen extends ConsumerStatefulWidget {
  const GoodsReceivedScreen({super.key});

  @override
  ConsumerState<GoodsReceivedScreen> createState() => _GoodsReceivedScreenState();
}

class _GoodsReceivedScreenState extends ConsumerState<GoodsReceivedScreen> {
  GrnViewMode _viewMode = GrnViewMode.cards;
  String _searchQuery = '';
  String _statusFilter = 'ALL';
  String _supplierFilter = 'ALL';
  String _dateFilter = 'ALL';
  GrnSortBy _sortBy = GrnSortBy.dateDesc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grnAsync = ref.watch(goodsReceivedNotesProvider);
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.inventory_2_rounded, color: Colors.teal, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? 'إذن استلام البضائع (GRN)' : 'Goods Received Notes (GRN)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  isArabic ? 'إدارة الواردات المخزنية ومطابقة الاستلام' : 'Inbound Consignments & Warehouse Verification',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: isArabic ? 'تحديث' : 'Refresh',
            onPressed: () => ref.invalidate(goodsReceivedNotesProvider),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.move_to_inbox_rounded, size: 20),
            label: Text(
              isArabic ? 'تسجيل استلام بضائع' : 'Receive Goods',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () => _openReceiveGoodsDialog(context),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: FeatureGuard(
        featureKey: 'batchExpiry',
        featureTitle: 'Goods Received Notes & Receiving',
        child: grnAsync.when(
          data: (allGrns) {
            final suppliers = {'ALL', ...allGrns.map((g) => g.supplierName).toSet()};

            // Filter
            final filtered = allGrns.where((grn) {
              final query = _searchQuery.toLowerCase().trim();
              if (query.isNotEmpty) {
                final matchNumber = grn.grnNumber.toLowerCase().contains(query);
                final matchPo = (grn.poNumber ?? '').toLowerCase().contains(query);
                final matchSupplier = grn.supplierName.toLowerCase().contains(query);
                final matchDeliveryNote = (grn.deliveryNoteNumber ?? '').toLowerCase().contains(query);
                final matchRemarks = (grn.remarks ?? '').toLowerCase().contains(query);
                final matchItems = grn.items.any((i) => i.description.toLowerCase().contains(query));

                if (!matchNumber && !matchPo && !matchSupplier && !matchDeliveryNote && !matchRemarks && !matchItems) {
                  return false;
                }
              }

              if (_statusFilter != 'ALL' && grn.status.toUpperCase() != _statusFilter) {
                return false;
              }

              if (_supplierFilter != 'ALL' && grn.supplierName != _supplierFilter) {
                return false;
              }

              if (_dateFilter != 'ALL') {
                final now = DateTime.now();
                if (_dateFilter == 'TODAY') {
                  if (grn.receivedDate.year != now.year ||
                      grn.receivedDate.month != now.month ||
                      grn.receivedDate.day != now.day) {
                    return false;
                  }
                } else if (_dateFilter == '7DAYS') {
                  if (now.difference(grn.receivedDate).inDays > 7) {
                    return false;
                  }
                } else if (_dateFilter == 'MONTH') {
                  if (grn.receivedDate.year != now.year || grn.receivedDate.month != now.month) {
                    return false;
                  }
                }
              }

              return true;
            }).toList();

            // Sort
            filtered.sort((a, b) {
              switch (_sortBy) {
                case GrnSortBy.dateDesc:
                  return b.receivedDate.compareTo(a.receivedDate);
                case GrnSortBy.dateAsc:
                  return a.receivedDate.compareTo(b.receivedDate);
                case GrnSortBy.grnNumberAsc:
                  return a.grnNumber.compareTo(b.grnNumber);
                case GrnSortBy.supplierAsc:
                  return a.supplierName.compareTo(b.supplierName);
                case GrnSortBy.receivedQtyDesc:
                  return b.totalReceivedQuantity.compareTo(a.totalReceivedQuantity);
                case GrnSortBy.valueDesc:
                  return b.totalValue.compareTo(a.totalValue);
              }
            });

            return Column(
              children: [
                // KPI Metrics Bar
                _buildKpiMetrics(allGrns, isArabic),

                // Search & Filter Toolbar
                _buildToolbar(suppliers, isArabic),

                // Active View Mode (Cards, Grid, or Table)
                Expanded(
                  child: filtered.isEmpty
                      ? _buildEmptyState(isArabic)
                      : switch (_viewMode) {
                          GrnViewMode.cards => _buildCardsView(filtered, isArabic),
                          GrnViewMode.grid => _buildGridView(filtered, isArabic),
                          GrnViewMode.table => _buildTableView(filtered, isArabic),
                        },
                ),
              ],
            );
          },
          loading: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.teal),
                SizedBox(height: 16),
                Text('Loading Goods Received Notes...'),
              ],
            ),
          ),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text('Error loading GRNs: $err', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(goodsReceivedNotesProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // KPI Metrics Row
  Widget _buildKpiMetrics(List<GoodsReceivedNoteModel> grns, bool isArabic) {
    final totalCount = grns.length;
    final totalUnits = grns.fold(0.0, (acc, g) => acc + g.totalReceivedQuantity);
    final totalValue = grns.fold(0.0, (acc, g) => acc + g.totalValue);
    final qcCompleted = grns.where((g) => g.status.toUpperCase() == 'QC_COMPLETED' || g.status.toUpperCase() == 'ACCEPTED').length;
    final receivedCount = grns.where((g) => g.status.toUpperCase() == 'RECEIVED').length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          _buildKpiCard(
            label: isArabic ? 'إجمالي الأذونات' : 'Total GRNs',
            value: '$totalCount',
            subtitle: isArabic ? 'إذن مسجل' : 'Consignments',
            icon: Icons.inventory_2_rounded,
            color: Colors.blue,
          ),
          const SizedBox(width: 12),
          _buildKpiCard(
            label: isArabic ? 'واردات جديدة' : 'Newly Received',
            value: '$receivedCount',
            subtitle: isArabic ? 'بانتظار الفحص' : 'Pending Review',
            icon: Icons.inbox_rounded,
            color: Colors.amber.shade800,
          ),
          const SizedBox(width: 12),
          _buildKpiCard(
            label: isArabic ? 'مكتمل الفحص (QC)' : 'QC Approved',
            value: '$qcCompleted',
            subtitle: isArabic ? 'مقبول بالمستودع' : 'Stock Verified',
            icon: Icons.verified_rounded,
            color: Colors.green,
          ),
          const SizedBox(width: 12),
          _buildKpiCard(
            label: isArabic ? 'الوحدات المستلمة' : 'Received Units',
            value: totalUnits.toStringAsFixed(0),
            subtitle: isArabic ? 'قطعة فعلية' : 'Physical Units',
            icon: Icons.check_circle_outline_rounded,
            color: Colors.teal,
          ),
          const SizedBox(width: 12),
          _buildKpiCard(
            label: isArabic ? 'القيمة التقديرية' : 'Est. Received Value',
            value: 'SAR ${totalValue.toStringAsFixed(0)}',
            subtitle: isArabic ? 'ريال سعودي' : 'In SAR',
            icon: Icons.monetization_on_outlined,
            color: Colors.indigo,
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String label,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
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
                  Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  Text(
                    value,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Search & Filter Toolbar
  Widget _buildToolbar(Set<String> suppliers, bool isArabic) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Search Input
          Expanded(
            flex: 3,
            child: TextField(
              decoration: InputDecoration(
                hintText: isArabic
                    ? 'بحث برقم الإذن، أمر الشراء، المورد، رقم البوليصة...'
                    : 'Search GRN #, PO #, supplier, waybill, or item...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          const SizedBox(width: 10),

          // Status Filter
          DropdownButton<String>(
            value: _statusFilter,
            underline: const SizedBox(),
            items: [
              DropdownMenuItem(value: 'ALL', child: Text(isArabic ? 'كافة الحالات' : 'All Statuses')),
              const DropdownMenuItem(value: 'RECEIVED', child: Text('RECEIVED (استلام جديد)')),
              const DropdownMenuItem(value: 'QC_PENDING', child: Text('QC_PENDING (قيد الفحص)')),
              const DropdownMenuItem(value: 'QC_COMPLETED', child: Text('QC_COMPLETED (مجتاز الفحص)')),
              const DropdownMenuItem(value: 'ACCEPTED', child: Text('ACCEPTED (مقبول بالمستودع)')),
              const DropdownMenuItem(value: 'REJECTED', child: Text('REJECTED (مرفوض)')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _statusFilter = val);
            },
          ),
          const SizedBox(width: 10),

          // Supplier Filter
          if (suppliers.length > 2) ...[
            DropdownButton<String>(
              value: _supplierFilter,
              underline: const SizedBox(),
              items: suppliers.map((sup) {
                return DropdownMenuItem<String>(
                  value: sup,
                  child: Text(
                    sup == 'ALL' ? (isArabic ? 'كافة الموردين' : 'All Suppliers') : sup,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _supplierFilter = val);
              },
            ),
            const SizedBox(width: 10),
          ],

          // Date Filter
          DropdownButton<String>(
            value: _dateFilter,
            underline: const SizedBox(),
            items: [
              DropdownMenuItem(value: 'ALL', child: Text(isArabic ? 'كل الأوقات' : 'All Time')),
              DropdownMenuItem(value: 'TODAY', child: Text(isArabic ? 'اليوم' : 'Today')),
              DropdownMenuItem(value: '7DAYS', child: Text(isArabic ? 'آخر 7 أيام' : 'Last 7 Days')),
              DropdownMenuItem(value: 'MONTH', child: Text(isArabic ? 'هذا الشهر' : 'This Month')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _dateFilter = val);
            },
          ),
          const SizedBox(width: 10),

          // Sort Mode
          DropdownButton<GrnSortBy>(
            value: _sortBy,
            underline: const SizedBox(),
            items: [
              DropdownMenuItem(value: GrnSortBy.dateDesc, child: Text(isArabic ? 'التاريخ: الأحدث أولاً' : 'Date: Newest')),
              DropdownMenuItem(value: GrnSortBy.dateAsc, child: Text(isArabic ? 'التاريخ: الأقدم أولاً' : 'Date: Oldest')),
              DropdownMenuItem(value: GrnSortBy.grnNumberAsc, child: Text(isArabic ? 'رقم الإذن: تصاعدي' : 'GRN #: A-Z')),
              DropdownMenuItem(value: GrnSortBy.supplierAsc, child: Text(isArabic ? 'المورد: أ - ي' : 'Supplier: A-Z')),
              DropdownMenuItem(value: GrnSortBy.receivedQtyDesc, child: Text(isArabic ? 'الكمية المستلمة: الأعلى' : 'Qty: High-Low')),
              DropdownMenuItem(value: GrnSortBy.valueDesc, child: Text(isArabic ? 'القيمة: الأعلى أولاً' : 'Value: High-Low')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _sortBy = val);
            },
          ),
          const SizedBox(width: 14),

          // View Mode Selector (SegmentedButton)
          SegmentedButton<GrnViewMode>(
            segments: [
              ButtonSegment(
                value: GrnViewMode.cards,
                icon: const Icon(Icons.view_agenda_outlined, size: 18),
                tooltip: isArabic ? 'عرض البطاقات' : 'Cards View',
              ),
              ButtonSegment(
                value: GrnViewMode.grid,
                icon: const Icon(Icons.grid_view_rounded, size: 18),
                tooltip: isArabic ? 'عرض الشبكة' : 'Grid View',
              ),
              ButtonSegment(
                value: GrnViewMode.table,
                icon: const Icon(Icons.table_rows_rounded, size: 18),
                tooltip: isArabic ? 'عرض الجدول' : 'Table View',
              ),
            ],
            selected: {_viewMode},
            onSelectionChanged: (set) => setState(() => _viewMode = set.first),
          ),
        ],
      ),
    );
  }

  // 1. CARDS VIEW
  Widget _buildCardsView(List<GoodsReceivedNoteModel> grns, bool isArabic) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: grns.length,
      itemBuilder: (context, index) {
        final grn = grns[index];
        final statusColor = _getStatusColor(grn.status);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _openDetailsDialog(context, grn),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Avatar + Title + Status + Action Buttons
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.teal.withValues(alpha: 0.15),
                        child: const Icon(Icons.move_to_inbox_rounded, color: Colors.teal, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  grn.grnNumber,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(width: 10),
                                _buildStatusBadge(grn.status, statusColor),
                                if (grn.poNumber != null && grn.poNumber!.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.link_rounded, size: 14, color: Colors.blue),
                                        const SizedBox(width: 4),
                                        Text(
                                          'PO: ${ProcurementDocumentFormatter.formatPoNumber(grn.poNumber, grn.poId)}',
                                          style: const TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${grn.supplierName} (${ProcurementDocumentFormatter.formatSupplierCode(grn.supplierId)}) • ${DateFormat('yyyy-MM-dd HH:mm').format(grn.receivedDate)} • ${grn.warehouseName ?? "Central Warehouse"}',
                              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      // Actions: Print Voucher & Open Details
                      IconButton(
                        icon: const Icon(Icons.print_outlined),
                        tooltip: isArabic ? 'طباعة إذن الاستلام' : 'Print GRN Voucher',
                        onPressed: () => GrnPdfPrinter.printGrn(grn),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        tooltip: isArabic ? 'عرض التفاصيل' : 'View Details',
                        onPressed: () => _openDetailsDialog(context, grn),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // Middle Row: Metrics & Fulfillment Progress
                  Row(
                    children: [
                      // Items count
                      _buildMiniMetric(
                        label: isArabic ? 'الأصناف' : 'Items',
                        value: '${grn.items.length}',
                        icon: Icons.category_outlined,
                      ),
                      const SizedBox(width: 20),
                      // Ordered Qty
                      _buildMiniMetric(
                        label: isArabic ? 'المطلوب' : 'Ordered',
                        value: grn.totalOrderedQuantity.toStringAsFixed(1),
                        icon: Icons.shopping_bag_outlined,
                      ),
                      const SizedBox(width: 20),
                      // Received Qty
                      _buildMiniMetric(
                        label: isArabic ? 'المستلم' : 'Received',
                        value: grn.totalReceivedQuantity.toStringAsFixed(1),
                        icon: Icons.check_circle_outline_rounded,
                        color: Colors.teal.shade800,
                      ),
                      const SizedBox(width: 20),
                      // Est. Value
                      _buildMiniMetric(
                        label: isArabic ? 'القيمة' : 'Est. Value',
                        value: 'SAR ${grn.totalValue.toStringAsFixed(2)}',
                        icon: Icons.payments_outlined,
                        color: Colors.indigo.shade800,
                      ),
                      const Spacer(),

                      // Delivery Note Number
                      if (grn.deliveryNoteNumber != null && grn.deliveryNoteNumber!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.local_shipping_outlined, size: 14, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(
                                'Note: ${grn.deliveryNoteNumber}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  // Fulfillment rate bar if ordered > 0
                  if (grn.totalOrderedQuantity > 0) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          '${isArabic ? "نسبة الاستيفاء:" : "Fulfillment:"} ${grn.fulfillmentRate.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: grn.fulfillmentRate >= 100 ? Colors.green.shade800 : Colors.amber.shade900,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (grn.fulfillmentRate / 100).clamp(0.0, 1.0),
                              backgroundColor: Colors.grey.withValues(alpha: 0.2),
                              color: grn.fulfillmentRate >= 100 ? Colors.green : Colors.amber.shade800,
                              minHeight: 6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Item description previews
                  if (grn.items.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: grn.items.take(3).map((item) {
                        return Chip(
                          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                          visualDensity: VisualDensity.compact,
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
                          label: Text(
                            '${item.description} (Rec: ${item.receivedQuantity})',
                            style: const TextStyle(fontSize: 11),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 2. GRID VIEW
  Widget _buildGridView(List<GoodsReceivedNoteModel> grns, bool isArabic) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200
            ? 3
            : (constraints.maxWidth > 750 ? 2 : 1);

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.45,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemCount: grns.length,
          itemBuilder: (context, index) {
            final grn = grns[index];
            final statusColor = _getStatusColor(grn.status);

            return Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _openDetailsDialog(context, grn),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.teal.withValues(alpha: 0.15),
                                child: const Icon(Icons.inventory_2_rounded, color: Colors.teal, size: 16),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                grn.grnNumber,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                          _buildStatusBadge(grn.status, statusColor),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        grn.supplierName,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${DateFormat('yyyy-MM-dd').format(grn.receivedDate)} • ${ProcurementDocumentFormatter.formatPoNumber(grn.poNumber, grn.poId)} • ${ProcurementDocumentFormatter.formatSupplierCode(grn.supplierId)}',
                        style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color),
                      ),
                      const Spacer(),

                      // Key Figures
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(isArabic ? 'المستلم' : 'Received Qty', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                Text(
                                  '${grn.totalReceivedQuantity.toStringAsFixed(1)} Units',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.teal),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(isArabic ? 'القيمة' : 'Est. Value', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                Text(
                                  'SAR ${grn.totalValue.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Card Footer Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${grn.items.length} ${isArabic ? "أصناف" : "Items"}',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.print_outlined, size: 18),
                                tooltip: isArabic ? 'طباعة السند' : 'Print Voucher',
                                onPressed: () => GrnPdfPrinter.printGrn(grn),
                              ),
                              IconButton(
                                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                                tooltip: isArabic ? 'عرض التفاصيل' : 'View Details',
                                onPressed: () => _openDetailsDialog(context, grn),
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
          },
        );
      },
    );
  }

  // 3. TABLE VIEW
  Widget _buildTableView(List<GoodsReceivedNoteModel> grns, bool isArabic) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
            ),
            columnSpacing: 24,
            columns: [
              DataColumn(label: Text(isArabic ? 'رقم الإذن' : 'GRN #', style: const TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text(isArabic ? 'أمر الشراء' : 'PO Ref', style: const TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text(isArabic ? 'المورد' : 'Supplier', style: const TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text(isArabic ? 'تاريخ الاستلام' : 'Received Date', style: const TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text(isArabic ? 'عدد الأصناف' : 'Items', style: const TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text(isArabic ? 'المستلم' : 'Received Qty', style: const TextStyle(fontWeight: FontWeight.bold)), numeric: true),
              DataColumn(label: Text(isArabic ? 'الاستيفاء' : 'Fulfillment', style: const TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text(isArabic ? 'القيمة (ر.س)' : 'Value (SAR)', style: const TextStyle(fontWeight: FontWeight.bold)), numeric: true),
              DataColumn(label: Text(isArabic ? 'الحالة' : 'Status', style: const TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text(isArabic ? 'إجراءات' : 'Actions', style: const TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: grns.map((grn) {
              final statusColor = _getStatusColor(grn.status);
              return DataRow(
                onSelectChanged: (_) => _openDetailsDialog(context, grn),
                cells: [
                  DataCell(
                    Text(grn.grnNumber, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                  ),
                  DataCell(
                    Text(ProcurementDocumentFormatter.formatPoNumber(grn.poNumber, grn.poId)),
                  ),
                  DataCell(
                    Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(grn.supplierName, style: const TextStyle(fontWeight: FontWeight.w500)), Text(ProcurementDocumentFormatter.formatSupplierCode(grn.supplierId), style: const TextStyle(fontSize: 10, color: Colors.grey))]),
                  ),
                  DataCell(
                    Text(DateFormat('yyyy-MM-dd').format(grn.receivedDate)),
                  ),
                  DataCell(
                    Text('${grn.items.length}'),
                  ),
                  DataCell(
                    Text(
                      grn.totalReceivedQuantity.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataCell(
                    Text(
                      '${grn.fulfillmentRate.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: grn.fulfillmentRate >= 100 ? Colors.green : Colors.amber.shade900,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(grn.totalValue.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataCell(
                    _buildStatusBadge(grn.status, statusColor),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.print_outlined, size: 18),
                          tooltip: isArabic ? 'طباعة السند' : 'Print Voucher',
                          onPressed: () => GrnPdfPrinter.printGrn(grn),
                        ),
                        IconButton(
                          icon: const Icon(Icons.visibility_outlined, size: 18),
                          tooltip: isArabic ? 'عرض التفاصيل' : 'View Details',
                          onPressed: () => _openDetailsDialog(context, grn),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // Helpers
  Widget _buildEmptyState(bool isArabic) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            isArabic ? 'لم يتم العثور على أذونات استلام مطابقة' : 'No Goods Received Notes found',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            isArabic ? 'جرب تغيير معايير البحث أو تسجيل إذن استلام جديد' : 'Try adjusting your filters or record a new GRN',
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
            icon: const Icon(Icons.add_rounded),
            label: Text(isArabic ? 'تسجيل استلام بضائع الآن' : 'Record Received Goods Now'),
            onPressed: () => _openReceiveGoodsDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  Widget _buildMiniMetric({
    required String label,
    required String value,
    required IconData icon,
    Color? color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color ?? Colors.grey),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            Text(
              value,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'RECEIVED':
        return Colors.blue;
      case 'QC_PENDING':
        return Colors.amber.shade800;
      case 'QC_COMPLETED':
      case 'ACCEPTED':
        return Colors.green.shade700;
      case 'REJECTED':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  void _openDetailsDialog(BuildContext context, GoodsReceivedNoteModel grn) {
    final isArabic = ref.read(localeProvider).languageCode == 'ar';
    showDialog(
      context: context,
      builder: (ctx) => GrnDetailsDialog(grn: grn, isArabic: isArabic),
    );
  }

  void _openReceiveGoodsDialog(BuildContext context) {
    final isArabic = ref.read(localeProvider).languageCode == 'ar';
    showDialog(
      context: context,
      builder: (ctx) => ReceiveGoodsDialog(isArabic: isArabic),
    );
  }
}
