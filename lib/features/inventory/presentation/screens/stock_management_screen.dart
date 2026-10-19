import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app.dart';
import '../../providers/stock_provider.dart';

enum StockViewMode { card, grid, table }
enum StockSortOption { nameAsc, stockAsc, stockDesc, minLevel }

class StockManagementScreen extends ConsumerStatefulWidget {
  const StockManagementScreen({super.key});

  @override
  ConsumerState<StockManagementScreen> createState() => _StockManagementScreenState();
}

class _StockManagementScreenState extends ConsumerState<StockManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'all'; // 'all', 'in', 'low', 'out'
  StockViewMode _viewMode = StockViewMode.grid;
  StockSortOption _sortOption = StockSortOption.nameAsc;
  bool _isArabic = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StockItem> _getFilteredAndSortedItems(List<StockItem> items) {
    final q = _searchQuery.toLowerCase().trim();
    var filtered = items.where((item) {
      final matchesSearch = q.isEmpty ||
          item.name.toLowerCase().contains(q) ||
          (item.barcode?.toLowerCase().contains(q) ?? false) ||
          (item.brand?.toLowerCase().contains(q) ?? false);
      if (!matchesSearch) return false;

      if (_filterStatus == 'low' && (item.stockQuantity > item.minStockLevel || item.stockQuantity <= 0)) {
        return false;
      }
      if (_filterStatus == 'out' && item.stockQuantity > 0) return false;
      if (_filterStatus == 'in' && item.stockQuantity <= 0) return false;

      return true;
    }).toList();

    // Apply Sorting
    switch (_sortOption) {
      case StockSortOption.nameAsc:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case StockSortOption.stockAsc:
        filtered.sort((a, b) => a.stockQuantity.compareTo(b.stockQuantity));
        break;
      case StockSortOption.stockDesc:
        filtered.sort((a, b) => b.stockQuantity.compareTo(a.stockQuantity));
        break;
      case StockSortOption.minLevel:
        filtered.sort((a, b) {
          final diffA = a.stockQuantity - a.minStockLevel;
          final diffB = b.stockQuantity - b.minStockLevel;
          return diffA.compareTo(diffB);
        });
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final stockState = ref.watch(stockProvider);
    final currentLocale = ref.watch(localeProvider);
    _isArabic = currentLocale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4361EE).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.inventory_2_rounded, color: Color(0xFF4361EE)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isArabic ? 'إدارة المخزون والتخزين' : 'Stock & Inventory Management',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
                ),
                Text(
                  _isArabic ? 'متابعة كميات الأصناف، مستويات التنبيه، وضبط الرصيد' : 'Monitor SKU counts, low stock alerts & stock adjustments',
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isArabic ? Icons.language : Icons.g_translate, color: const Color(0xFF4361EE)),
            tooltip: _isArabic ? 'Switch to English' : 'التحويل للعربية',
            onPressed: () {
              ref.read(localeProvider.notifier).state =
                  _isArabic ? const Locale('en') : const Locale('ar');
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF4361EE)),
            tooltip: _isArabic ? 'تحديث المخزون' : 'Refresh Stock',
            onPressed: () => ref.read(stockProvider.notifier).fetchStock(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: stockState.when(
        data: (stockItems) {
          if (stockItems.isEmpty) {
            return _buildEmptyInventoryState();
          }

          final filteredItems = _getFilteredAndSortedItems(stockItems);
          final inStockCount = stockItems.where((i) => i.stockQuantity > 0).length;
          final lowStockCount = stockItems.where((i) => i.stockQuantity > 0 && i.stockQuantity <= i.minStockLevel).length;
          final outOfStockCount = stockItems.where((i) => i.stockQuantity <= 0).length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KPI Metrics Header Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: _isArabic ? 'إجمالي المنتجات' : 'Total SKUs',
                        value: '${stockItems.length}',
                        icon: Icons.widgets_rounded,
                        color: const Color(0xFF4361EE),
                        subtitle: _isArabic ? 'جميع الأصناف المسجلة' : 'Registered Catalog',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        title: _isArabic ? 'متاح بالمخزون' : 'In Stock',
                        value: '$inStockCount',
                        icon: Icons.check_circle_rounded,
                        color: const Color(0xFF10B981),
                        subtitle: _isArabic ? 'مخزون طبيعي' : 'Healthy Levels',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        title: _isArabic ? 'مخزون منخفض' : 'Low Stock Warning',
                        value: '$lowStockCount',
                        icon: Icons.warning_amber_rounded,
                        color: const Color(0xFFF59E0B),
                        subtitle: _isArabic ? 'تجاوز الحد الأدنى' : 'Near Reorder Level',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        title: _isArabic ? 'نفد من المخزن' : 'Out of Stock',
                        value: '$outOfStockCount',
                        icon: Icons.error_rounded,
                        color: const Color(0xFFEF4444),
                        subtitle: _isArabic ? 'يتطلب إعادة طلب' : 'Reorder Immediately',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Control Bar: Search, Status Filters, View Mode Toggle & Sorting
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Search Box
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) => setState(() => _searchQuery = val),
                              decoration: InputDecoration(
                                hintText: _isArabic
                                    ? 'بحث بالاسم، الباركود SKU، أو الماركة التجارية...'
                                    : 'Search by Product Name, Barcode / SKU, or Brand...',
                                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
                                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF4361EE)),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear_rounded, size: 18),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() => _searchQuery = '');
                                        },
                                      )
                                    : null,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                filled: true,
                                fillColor: const Color(0xFFF1F5F9),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Sort Dropdown
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<StockSortOption>(
                              value: _sortOption,
                              onChanged: (val) => setState(() => _sortOption = val!),
                              underline: const SizedBox(),
                              icon: const Icon(Icons.sort_rounded, color: Color(0xFF4361EE), size: 20),
                              items: [
                                DropdownMenuItem(value: StockSortOption.nameAsc, child: Text(_isArabic ? 'الاسم (أ-ي)' : 'Name (A-Z)')),
                                DropdownMenuItem(value: StockSortOption.stockAsc, child: Text(_isArabic ? 'المخزون: الأدنى أولاً' : 'Stock: Low to High')),
                                DropdownMenuItem(value: StockSortOption.stockDesc, child: Text(_isArabic ? 'المخزون: الأعلى أولاً' : 'Stock: High to Low')),
                                DropdownMenuItem(value: StockSortOption.minLevel, child: Text(_isArabic ? 'تنبيه الحد الأدنى' : 'Critical Reorder')),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),

                          // View Switcher Segmented Button
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                _buildViewIconButton(StockViewMode.card, Icons.view_agenda_rounded, _isArabic ? 'قائمة بطاقات' : 'Card View'),
                                _buildViewIconButton(StockViewMode.grid, Icons.grid_view_rounded, _isArabic ? 'شبكة مربعات' : 'Grid View'),
                                _buildViewIconButton(StockViewMode.table, Icons.table_chart_rounded, _isArabic ? 'جدول بيانات' : 'Table View'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Filter Choice Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ChoiceChip(
                              label: Text('${_isArabic ? "الكل" : "All"} (${stockItems.length})'),
                              selected: _filterStatus == 'all',
                              selectedColor: const Color(0xFF4361EE).withValues(alpha: 0.15),
                              labelStyle: TextStyle(
                                color: _filterStatus == 'all' ? const Color(0xFF4361EE) : const Color(0xFF475569),
                                fontWeight: _filterStatus == 'all' ? FontWeight.bold : FontWeight.normal,
                              ),
                              onSelected: (sel) {
                                if (sel) setState(() => _filterStatus = 'all');
                              },
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              avatar: const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF10B981)),
                              label: Text('${_isArabic ? "متوفر" : "In Stock"} ($inStockCount)'),
                              selected: _filterStatus == 'in',
                              selectedColor: const Color(0xFF10B981).withValues(alpha: 0.15),
                              labelStyle: TextStyle(
                                color: _filterStatus == 'in' ? const Color(0xFF10B981) : const Color(0xFF475569),
                                fontWeight: _filterStatus == 'in' ? FontWeight.bold : FontWeight.normal,
                              ),
                              onSelected: (sel) {
                                if (sel) setState(() => _filterStatus = 'in');
                              },
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              avatar: const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFF59E0B)),
                              label: Text('${_isArabic ? "مخزون منخفض" : "Low Stock"} ($lowStockCount)'),
                              selected: _filterStatus == 'low',
                              selectedColor: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                              labelStyle: TextStyle(
                                color: _filterStatus == 'low' ? const Color(0xFFB45309) : const Color(0xFF475569),
                                fontWeight: _filterStatus == 'low' ? FontWeight.bold : FontWeight.normal,
                              ),
                              onSelected: (sel) {
                                if (sel) setState(() => _filterStatus = 'low');
                              },
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              avatar: const Icon(Icons.error_outline_rounded, size: 16, color: Color(0xFFEF4444)),
                              label: Text('${_isArabic ? "نفذ بالكامل" : "Out of Stock"} ($outOfStockCount)'),
                              selected: _filterStatus == 'out',
                              selectedColor: const Color(0xFFEF4444).withValues(alpha: 0.15),
                              labelStyle: TextStyle(
                                color: _filterStatus == 'out' ? const Color(0xFFDC2626) : const Color(0xFF475569),
                                fontWeight: _filterStatus == 'out' ? FontWeight.bold : FontWeight.normal,
                              ),
                              onSelected: (sel) {
                                if (sel) setState(() => _filterStatus = 'out');
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Main Content View Body
                filteredItems.isEmpty
                    ? _buildNoResultsState()
                    : _viewMode == StockViewMode.grid
                        ? _buildGridView(filteredItems)
                        : _viewMode == StockViewMode.card
                            ? _buildCardView(filteredItems)
                            : _buildTableView(filteredItems),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text('Error loading stock inventory: $err'),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => ref.read(stockProvider.notifier).fetchStock(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewIconButton(StockViewMode mode, IconData icon, String tooltip) {
    final isSelected = _viewMode == mode;
    return IconButton(
      icon: Icon(icon, color: isSelected ? const Color(0xFF4361EE) : const Color(0xFF64748B), size: 20),
      tooltip: tooltip,
      onPressed: () => setState(() => _viewMode = mode),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              Text(subtitle, style: TextStyle(fontSize: 10.5, color: color, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyInventoryState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            _isArabic ? 'لم يتم العثور على منتجات في المخزون' : 'No products found to manage stock.',
            style: const TextStyle(fontSize: 18, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            _isArabic ? 'لا توجد أصناف مطابقة للبحث أو التصفية' : 'No products match your search or filter category',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
                _filterStatus = 'all';
              });
            },
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: Text(_isArabic ? 'إعادة ضبط تصفية البحث' : 'Reset search & filters'),
          ),
        ],
      ),
    );
  }

  // 1. Grid View Implementation
  Widget _buildGridView(List<StockItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.45,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isOut = item.stockQuantity <= 0;
        final isLowStock = !isOut && item.stockQuantity <= item.minStockLevel;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: isOut
                  ? const Color(0xFFEF4444).withValues(alpha: 0.5)
                  : (isLowStock ? const Color(0xFFF59E0B).withValues(alpha: 0.5) : const Color(0xFFE2E8F0)),
              width: (isOut || isLowStock) ? 1.5 : 1.0,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Header & Status Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStockBadge(isOut, isLowStock, item.stockQuantity),
                  ],
                ),
                const SizedBox(height: 8),

                // Tags: Barcode & Brand
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (item.barcode != null && item.barcode!.isNotEmpty)
                      _buildTagChip(Icons.qr_code_rounded, item.barcode!, const Color(0xFF2563EB)),
                    if (item.brand != null && item.brand!.isNotEmpty)
                      _buildTagChip(Icons.branding_watermark_rounded, item.brand!, const Color(0xFF7C3AED)),
                  ],
                ),

                const Spacer(),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 8),

                // Min Level & Quick +/- Controls
                Row(
                  children: [
                    Text(
                      '${_isArabic ? 'الحد الأدنى:' : 'Min Threshold:'} ${item.minStockLevel}',
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                    ),
                    const Spacer(),
                    // Quick Action Buttons
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_rounded, size: 16, color: Color(0xFFDC2626)),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                            tooltip: _isArabic ? 'خصم 1' : 'Subtract 1',
                            onPressed: () => _quickAdjustStock(item, -1),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              '${item.stockQuantity}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_rounded, size: 16, color: Color(0xFF16A34A)),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                            tooltip: _isArabic ? 'إضافة 1' : 'Add 1',
                            onPressed: () => _quickAdjustStock(item, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Color(0xFF4361EE), size: 18),
                      tooltip: _isArabic ? 'تعديل المخزون' : 'Edit Stock',
                      onPressed: () => _showStockDialog(context, ref, item),
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

  // 2. Card View / List View Implementation
  Widget _buildCardView(List<StockItem> items) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = items[index];
        final isOut = item.stockQuantity <= 0;
        final isLowStock = !isOut && item.stockQuantity <= item.minStockLevel;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: isOut
                  ? const Color(0xFFEF4444).withValues(alpha: 0.5)
                  : (isLowStock ? const Color(0xFFF59E0B).withValues(alpha: 0.5) : const Color(0xFFE2E8F0)),
              width: (isOut || isLowStock) ? 1.5 : 1.0,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (item.barcode != null && item.barcode!.isNotEmpty)
                            _buildTagChip(Icons.qr_code_rounded, item.barcode!, const Color(0xFF2563EB)),
                          if (item.brand != null && item.brand!.isNotEmpty)
                            _buildTagChip(Icons.branding_watermark_rounded, item.brand!, const Color(0xFF7C3AED)),
                          Text(
                            '${_isArabic ? 'الحد الأدنى للمخزون:' : 'Min Level:'} ${item.minStockLevel}',
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _buildStockBadge(isOut, isLowStock, item.stockQuantity),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Color(0xFF4361EE), size: 20),
                  tooltip: _isArabic ? 'تعديل الرصيد' : 'Edit Stock',
                  onPressed: () => _showStockDialog(context, ref, item),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 3. Table View / Data Table Implementation
  Widget _buildTableView(List<StockItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
        horizontalMargin: 20,
        columnSpacing: 24,
        columns: [
          DataColumn(label: Text(_isArabic ? 'اسم المنتج' : 'Product Name', style: _tableHeaderStyle)),
          DataColumn(label: Text(_isArabic ? 'الباركود / SKU' : 'Barcode / SKU', style: _tableHeaderStyle)),
          DataColumn(label: Text(_isArabic ? 'العلامة التجارية' : 'Brand', style: _tableHeaderStyle)),
          DataColumn(label: Text(_isArabic ? 'رصيد المخزون' : 'Current Stock', style: _tableHeaderStyle)),
          DataColumn(label: Text(_isArabic ? 'الحد الأدنى' : 'Min Level', style: _tableHeaderStyle)),
          DataColumn(label: Text(_isArabic ? 'الحالة' : 'Status', style: _tableHeaderStyle)),
          DataColumn(label: Text(_isArabic ? 'إجراءات' : 'Actions', style: _tableHeaderStyle)),
        ],
        rows: items.map((item) {
          final isOut = item.stockQuantity <= 0;
          final isLowStock = !isOut && item.stockQuantity <= item.minStockLevel;

          return DataRow(
            cells: [
              DataCell(Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)))),
              DataCell(Text(item.barcode ?? '-', style: const TextStyle(fontSize: 12, color: Color(0xFF2563EB)))),
              DataCell(Text(item.brand ?? '-', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)))),
              DataCell(Text('${item.stockQuantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataCell(Text('${item.minStockLevel}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)))),
              DataCell(_buildStockBadge(isOut, isLowStock, item.stockQuantity)),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Color(0xFF4361EE), size: 18),
                  tooltip: _isArabic ? 'تعديل' : 'Edit Stock',
                  onPressed: () => _showStockDialog(context, ref, item),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  TextStyle get _tableHeaderStyle => const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF475569));

  Widget _buildTagChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildStockBadge(bool isOut, bool isLowStock, int qty) {
    Color bg = const Color(0xFF10B981).withValues(alpha: 0.1);
    Color fg = const Color(0xFF10B981);
    String label = _isArabic ? '$qty متاح' : '$qty in stock';

    if (isOut) {
      bg = const Color(0xFFEF4444).withValues(alpha: 0.1);
      fg = const Color(0xFFEF4444);
      label = _isArabic ? 'نفذ بالكامل' : 'Out of Stock';
    } else if (isLowStock) {
      bg = const Color(0xFFF59E0B).withValues(alpha: 0.1);
      fg = const Color(0xFFB45309);
      label = _isArabic ? 'منخفض ($qty)' : 'Low Stock ($qty)';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  Future<void> _quickAdjustStock(StockItem item, int delta) async {
    final newQty = item.stockQuantity + delta;
    if (newQty < 0) return;
    await ref.read(stockProvider.notifier).updateStock(item.id, newQty, item.minStockLevel);
  }

  void _showStockDialog(BuildContext context, WidgetRef ref, StockItem item) {
    final quantityController = TextEditingController(text: item.stockQuantity.toString());
    final minLevelController = TextEditingController(text: item.minStockLevel.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(_isArabic ? 'تعديل مخزون: ${item.name}' : 'Manage Stock: ${item.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _isArabic ? 'كمية المخزون الحالية' : 'Current Stock Quantity',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: minLevelController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _isArabic ? 'حد إعادة الطلب الأدنى' : 'Minimum Reorder Level',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(_isArabic ? 'إلغاء' : 'Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4361EE), foregroundColor: Colors.white),
              onPressed: () async {
                final qtyStr = quantityController.text.trim().replaceAll(',', '.');
                final minStr = minLevelController.text.trim().replaceAll(',', '.');

                final qty = int.tryParse(qtyStr) ?? double.tryParse(qtyStr)?.toInt();
                final min = int.tryParse(minStr) ?? double.tryParse(minStr)?.toInt();

                if (qty == null || min == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_isArabic ? 'يرجى إدخال قيم عددية صحيحة' : 'Please enter valid numeric stock values')),
                  );
                  return;
                }

                final success = await ref.read(stockProvider.notifier).updateStock(item.id, qty, min);

                if (success && context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_isArabic ? 'تم تحديث رصيد المخزون بنجاح' : 'Stock level updated successfully!')),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_isArabic ? 'فشل تحديث المخزون' : 'Failed to update stock')),
                  );
                }
              },
              child: Text(_isArabic ? 'حفظ التغييرات' : 'Save Changes'),
            ),
          ],
        );
      },
    );
  }
}
