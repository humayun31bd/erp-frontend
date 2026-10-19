import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app.dart';
import '../../providers/inventory_transfer_provider.dart';

class InventoryReportScreen extends ConsumerStatefulWidget {
  const InventoryReportScreen({super.key});

  @override
  ConsumerState<InventoryReportScreen> createState() => _InventoryReportScreenState();
}

class _InventoryReportScreenState extends ConsumerState<InventoryReportScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(inventoryReportProvider);
    final theme = Theme.of(context);
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'تقرير تقييم وجرد المخزون' : 'Inventory Stock & Audit Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              final current = ref.read(localeProvider);
              ref.read(localeProvider.notifier).state =
                  current.languageCode == 'en' ? const Locale('ar') : const Locale('en');
            },
            tooltip: isArabic ? 'تغيير اللغة' : 'Switch Language',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(inventoryReportProvider),
            tooltip: isArabic ? 'تحديث' : 'Refresh',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: reportAsync.when(
        data: (data) {
          final summary = data['summary'] as Map<String, dynamic>? ?? {};
          final products = (data['products'] as List?) ?? [];
          final movements = data['recentMovements'] as Map<String, dynamic>? ?? {};

          final filteredProducts = products.where((p) {
            final name = (p['name'] ?? '').toString().toLowerCase();
            final sku = (p['sku'] ?? '').toString().toLowerCase();
            final cat = (p['category'] ?? '').toString().toLowerCase();
            return name.contains(_searchQuery) || sku.contains(_searchQuery) || cat.contains(_searchQuery);
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KPI Header Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildKpiCard(
                        theme,
                        title: isArabic ? 'إجمالي الأصناف النشطة' : 'Total Active SKUs',
                        value: '${summary['totalSkus'] ?? 0}',
                        icon: Icons.inventory_2,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildKpiCard(
                        theme,
                        title: isArabic ? 'تقييم المخزون (ر.س)' : 'Stock Valuation (SAR)',
                        value: '${isArabic ? 'ر.س ' : 'SAR '}${summary['totalStockValue'] ?? '0.00'}',
                        icon: Icons.payments,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildKpiCard(
                        theme,
                        title: isArabic ? 'تنبيهات المخزون المنخفض' : 'Low Stock Alerts',
                        value: '${summary['lowStockCount'] ?? 0}',
                        icon: Icons.warning_amber,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildKpiCard(
                        theme,
                        title: isArabic ? 'المستودعات / الفروع' : 'Warehouses / Outlets',
                        value: '${summary['totalLocations'] ?? 1}',
                        icon: Icons.store,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Search Bar & Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isArabic ? 'تقييم المخزون وأرصدة المنتجات' : 'Stock Valuation & Inventory Balances', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(
                      width: 320,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: isArabic ? 'تصفية حسب المنتج، SKU، أو الفئة...' : 'Filter by product, SKU, or category...',
                          prefixIcon: const Icon(Icons.search),
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Products Valuation Table
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Table(
                      border: TableBorder.all(color: Colors.grey.shade300, width: 1),
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(1.2),
                        2: FlexColumnWidth(1.5),
                        3: FlexColumnWidth(1.2),
                        4: FlexColumnWidth(1.2),
                        5: FlexColumnWidth(1.5),
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(color: Colors.grey.shade100),
                          children: [
                            Padding(padding: const EdgeInsets.all(10), child: Text(isArabic ? 'اسم المنتج' : 'Product Name', style: const TextStyle(fontWeight: FontWeight.bold))),
                            Padding(padding: const EdgeInsets.all(10), child: Text(isArabic ? 'رمز SKU' : 'SKU', style: const TextStyle(fontWeight: FontWeight.bold))),
                            Padding(padding: const EdgeInsets.all(10), child: Text(isArabic ? 'الفئة' : 'Category', style: const TextStyle(fontWeight: FontWeight.bold))),
                            Padding(padding: const EdgeInsets.all(10), child: Text(isArabic ? 'المخزون المتوفر' : 'On-Hand Stock', style: const TextStyle(fontWeight: FontWeight.bold))),
                            Padding(padding: const EdgeInsets.all(10), child: Text(isArabic ? 'تكلفة الوحدة (ر.س)' : 'Unit Cost (SAR)', style: const TextStyle(fontWeight: FontWeight.bold))),
                            Padding(padding: const EdgeInsets.all(10), child: Text(isArabic ? 'إجمالي التقييم (ر.س)' : 'Total Valuation (SAR)', style: const TextStyle(fontWeight: FontWeight.bold))),
                          ],
                        ),
                        if (filteredProducts.isEmpty)
                          TableRow(
                            children: [
                              Padding(padding: const EdgeInsets.all(16), child: Text(isArabic ? 'لا توجد منتجات تطابق معايير البحث.' : 'No products matched search criteria.')),
                              const SizedBox(),
                              const SizedBox(),
                              const SizedBox(),
                              const SizedBox(),
                              const SizedBox(),
                            ],
                          )
                        else
                          ...filteredProducts.map((p) {
                            final isLow = p['isLowStock'] == true;
                            return TableRow(
                              decoration: BoxDecoration(color: isLow ? Colors.red.withValues(alpha: 0.05) : null),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Text(p['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                                      if (isLow) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(4)),
                                          child: Text(isArabic ? 'مخزون منخفض' : 'LOW STOCK', style: TextStyle(color: Colors.red.shade900, fontSize: 9, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Padding(padding: const EdgeInsets.all(10), child: Text(p['sku'] ?? 'N/A')),
                                Padding(padding: const EdgeInsets.all(10), child: Text(p['category'] ?? (isArabic ? 'عام' : 'General'))),
                                Padding(padding: const EdgeInsets.all(10), child: Text('${p['stockQuantity'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold))),
                                Padding(padding: const EdgeInsets.all(10), child: Text('${isArabic ? "ر.س " : "SAR "}${p['unitPrice'] ?? "0.00"}')),
                                Padding(padding: const EdgeInsets.all(10), child: Text('${isArabic ? "ر.س " : "SAR "}${p['totalValuation'] ?? "0.00"}', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary))),
                              ],
                            );
                          }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Audit Movement Log Section
                Text(isArabic ? 'سجل تدقيق وتنقلات المخزون' : 'Stock Audit & Movement Logs', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.swap_horiz, color: theme.colorScheme.primary),
                                  const SizedBox(width: 8),
                                  Text(isArabic ? 'سجل تحويلات المواقع' : 'Location Transfers Log', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                              const Divider(height: 20),
                              ...((movements['transfers'] as List?) ?? []).map((t) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('${t['number']} (${t['from']} ➔ ${t['to']})', style: const TextStyle(fontWeight: FontWeight.w500)),
                                        Text('${t['date'] != null ? t['date'].toString().split('T').first : ""}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                  )),
                              if (((movements['transfers'] as List?) ?? []).isEmpty)
                                Text(isArabic ? 'لا توجد تحويلات مخزون حديثة.' : 'No recent stock transfers.', style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.tune, color: theme.colorScheme.secondary),
                                  const SizedBox(width: 8),
                                  Text(isArabic ? 'سجل تعديلات المخزون' : 'Stock Adjustments Log', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                              const Divider(height: 20),
                              ...((movements['adjustments'] as List?) ?? []).map((a) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('${a['number']} | ${a['location']} (${a['reason']})', style: const TextStyle(fontWeight: FontWeight.w500)),
                                        Text('${a['date'] != null ? a['date'].toString().split('T').first : ""}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                  )),
                              if (((movements['adjustments'] as List?) ?? []).isEmpty)
                                Text(isArabic ? 'لا توجد تعديلات مخزون حديثة.' : 'No recent stock adjustments.', style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('${isArabic ? "خطأ في تحميل تقرير المخزون: " : "Error loading inventory report: "}$err')),
      ),
    );
  }

  Widget _buildKpiCard(ThemeData theme, {required String title, required String value, required IconData icon, required Color color}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.outline)),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
