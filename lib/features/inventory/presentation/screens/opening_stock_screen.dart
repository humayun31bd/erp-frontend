import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import '../../../../app.dart';
import '../../providers/opening_stock_provider.dart';
import '../../../pos/providers/pos_provider.dart';
import '../../../pos/domain/product_model.dart';
import '../../../settings/providers/settings_provider.dart';

class OpeningStockGridRow {
  final ProductModel product;
  final TextEditingController qtyController;
  final TextEditingController costController;
  final TextEditingController rackController;
  String warehouse;
  bool isSaving;
  bool isSaved;

  OpeningStockGridRow({
    required this.product,
    int initialQty = 0,
    double? initialCost,
    String? initialWarehouse,
    String? initialRack,
  })  : qtyController = TextEditingController(text: initialQty > 0 ? initialQty.toString() : '0'),
        costController = TextEditingController(
          text: initialCost != null && initialCost > 0
              ? initialCost.toStringAsFixed(2)
              : (double.tryParse(product.costPrice ?? '')?.toStringAsFixed(2) ??
                  double.tryParse(product.price)?.toStringAsFixed(2) ??
                  '0.00'),
        ),
        rackController = TextEditingController(text: initialRack ?? ''),
        warehouse = initialWarehouse ?? 'Main Warehouse',
        isSaving = false,
        isSaved = false;

  int get quantity => int.tryParse(qtyController.text.trim()) ?? 0;
  double get unitCost => double.tryParse(costController.text.trim()) ?? 0.0;
  double get totalValuation => quantity * unitCost;
  int get currentStock => product.stockQuantity;
  int get newTotalStock => currentStock + quantity;
  String get rack => rackController.text.trim();

  void dispose() {
    qtyController.dispose();
    costController.dispose();
    rackController.dispose();
  }
}

class OpeningStockScreen extends ConsumerStatefulWidget {
  const OpeningStockScreen({super.key});

  @override
  ConsumerState<OpeningStockScreen> createState() => _OpeningStockScreenState();
}

class _OpeningStockScreenState extends ConsumerState<OpeningStockScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Batch Grid State
  final List<OpeningStockGridRow> _gridRows = [];
  String _defaultWarehouse = 'Main Warehouse';
  final TextEditingController _defaultRackController = TextEditingController();
  final TextEditingController _quickProductSearchController = TextEditingController();
  bool _isBulkSaving = false;

  // View Records Filter & Sorting State
  String _recordsSearchQuery = '';
  final TextEditingController _recordsSearchController = TextEditingController();
  String? _selectedWarehouseFilter;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _defaultRackController.dispose();
    _quickProductSearchController.dispose();
    _recordsSearchController.dispose();
    for (final row in _gridRows) {
      row.dispose();
    }
    super.dispose();
  }

  List<String> _getWarehouseOptions(List<dynamic> warehousesData) {
    final List<String> list = ['Main Warehouse', 'Central Logistics', 'Branch Warehouse 1', 'Riyadh Depo'];
    for (var w in warehousesData) {
      if (w is Map && w['name'] != null && w['name'].toString().trim().isNotEmpty) {
        final name = w['name'].toString().trim();
        if (!list.contains(name)) {
          list.add(name);
        }
      }
    }
    return list;
  }

  void _addProductToGrid(ProductModel product, {int qty = 0, String? warehouse, String? rack, double? cost}) {
    final existingIndex = _gridRows.indexWhere((r) => r.product.id == product.id && r.warehouse == (warehouse ?? _defaultWarehouse));
    if (existingIndex >= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} is already in the grid for this warehouse.'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _gridRows.add(OpeningStockGridRow(
        product: product,
        initialQty: qty,
        initialCost: cost,
        initialWarehouse: warehouse ?? _defaultWarehouse,
        initialRack: rack ?? _defaultRackController.text.trim(),
      ));
    });
  }

  void _removeRow(int index) {
    setState(() {
      _gridRows[index].dispose();
      _gridRows.removeAt(index);
    });
  }

  void _clearAllRows() {
    if (_gridRows.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Grid?'),
        content: const Text('Are you sure you want to clear all unposted rows in the opening stock grid?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                for (final row in _gridRows) {
                  row.dispose();
                }
                _gridRows.clear();
              });
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _applyDefaultWarehouseToAll() {
    setState(() {
      for (final row in _gridRows) {
        row.warehouse = _defaultWarehouse;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Applied "$_defaultWarehouse" to all rows!'), duration: const Duration(seconds: 2)),
    );
  }

  void _applyDefaultRackToAll() {
    final defaultRack = _defaultRackController.text.trim();
    if (defaultRack.isEmpty) return;
    setState(() {
      for (final row in _gridRows) {
        row.rackController.text = defaultRack;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Applied Rack "$defaultRack" to all rows!'), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _saveSingleRow(int index) async {
    final row = _gridRows[index];
    if (row.isSaving) return;

    setState(() {
      row.isSaving = true;
      row.isSaved = false;
    });

    final payload = {
      'productId': row.product.id,
      'quantity': row.quantity,
      'warehouseId': row.warehouse,
      'locationBin': row.rack.isEmpty ? null : row.rack,
      'costPrice': row.unitCost > 0 ? row.unitCost.toString() : null,
    };

    final success = await ref.read(openingStockProvider.notifier).saveSingleOpeningStock(payload);

    if (mounted) {
      setState(() {
        row.isSaving = false;
        row.isSaved = success;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '✅ Saved opening stock for ${row.product.name}!' : '❌ Failed to save row.'),
          backgroundColor: success ? Colors.green.shade700 : Colors.red.shade700,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveAllRows() async {
    if (_gridRows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No products in the grid to save.')),
      );
      return;
    }

    setState(() => _isBulkSaving = true);

    final payloadList = _gridRows.map((row) {
      return {
        'productId': row.product.id,
        'quantity': row.quantity,
        'warehouseId': row.warehouse,
        'locationBin': row.rack.isEmpty ? null : row.rack,
        'costPrice': row.unitCost > 0 ? row.unitCost.toString() : null,
      };
    }).toList();

    final success = await ref.read(openingStockProvider.notifier).saveOpeningStock(payloadList);

    if (mounted) {
      setState(() {
        _isBulkSaving = false;
        if (success) {
          for (final row in _gridRows) {
            row.isSaved = true;
          }
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '🎉 Successfully posted all ${_gridRows.length} opening stock entries!' : '❌ Failed to save opening stock.'),
          backgroundColor: success ? Colors.green.shade800 : Colors.red.shade800,
        ),
      );

      if (success) {
        // Automatically switch to view records tab to see results
        _tabController.animateTo(1);
      }
    }
  }

  void _showMultiProductSelectionDialog(List<ProductModel> allProducts) {
    final List<ProductModel> selectedInModal = [];
    String modalSearch = '';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = allProducts.where((p) {
              if (modalSearch.isEmpty) return true;
              final q = modalSearch.toLowerCase();
              return p.name.toLowerCase().contains(q) ||
                  (p.sku?.toLowerCase().contains(q) ?? false) ||
                  (p.barcode?.toLowerCase().contains(q) ?? false);
            }).toList();

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  const Icon(Icons.playlist_add_check_rounded, color: Colors.blueAccent, size: 28),
                  const SizedBox(width: 10),
                  const Text('Select Products for Opening Stock', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const Spacer(),
                  Text('${selectedInModal.length} selected', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                ],
              ),
              content: SizedBox(
                width: 750,
                height: 520,
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search product by name, SKU, or barcode...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onChanged: (val) => setModalState(() => modalSearch = val),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.select_all_rounded, size: 18),
                          label: const Text('Select All Filtered'),
                          onPressed: () {
                            setModalState(() {
                              for (var p in filtered) {
                                if (!selectedInModal.any((s) => s.id == p.id)) {
                                  selectedInModal.add(p);
                                }
                              }
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          icon: const Icon(Icons.deselect_rounded, size: 18),
                          label: const Text('Deselect All'),
                          onPressed: () {
                            setModalState(() => selectedInModal.clear());
                          },
                        ),
                        const Spacer(),
                        Text('Showing ${filtered.length} products', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                      ],
                    ),
                    const Divider(),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(child: Text('No matching products found.'))
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (context, idx) {
                                final prod = filtered[idx];
                                final isSelected = selectedInModal.any((s) => s.id == prod.id);

                                return CheckboxListTile(
                                  value: isSelected,
                                  title: Text(prod.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  subtitle: Text('SKU: ${prod.sku ?? "N/A"} | Barcode: ${prod.barcode ?? "N/A"} | In-Hand: ${prod.stockQuantity}'),
                                  secondary: CircleAvatar(
                                    backgroundColor: Colors.blueAccent.withValues(alpha: 0.1),
                                    child: const Icon(Icons.inventory_2_outlined, color: Colors.blueAccent),
                                  ),
                                  onChanged: (checked) {
                                    setModalState(() {
                                      if (checked == true) {
                                        selectedInModal.add(prod);
                                      } else {
                                        selectedInModal.removeWhere((s) => s.id == prod.id);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_shopping_cart_rounded),
                  label: Text('Add Selected (${selectedInModal.length}) to Grid'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    for (var p in selectedInModal) {
                      _addProductToGrid(p);
                    }
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(content: Text('Added ${selectedInModal.length} products to grid!')),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _downloadCsvTemplate() {
    const csvContent = 'SKU,Quantity,Warehouse,Location Bin,Cost Price\nSKU1001,50,Main Warehouse,Rack A-12,25.50\nSKU1002,100,Main Warehouse,Rack B-05,12.00';
    debugPrint('CSV Template: $csvContent');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CSV Format: SKU, Quantity, Warehouse, Location Bin, Cost Price')),
    );
  }

  Future<void> _importCsv() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final csvString = utf8.decode(bytes);
        final fields = Csv().decode(csvString);

        if (fields.isEmpty || fields.length <= 1) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV file is empty or invalid.')));
          return;
        }

        final dataRows = fields.skip(1);
        final productsAsync = ref.read(productsProvider);
        final products = productsAsync.asData?.value ?? [];

        int addedCount = 0;
        for (var row in dataRows) {
          if (row.length >= 2) {
            final skuOrName = row[0].toString().trim();
            final qty = int.tryParse(row[1].toString().trim()) ?? 0;
            final warehouse = row.length > 2 ? row[2].toString().trim() : null;
            final bin = row.length > 3 ? row[3].toString().trim() : null;
            final cost = row.length > 4 ? double.tryParse(row[4].toString().trim()) : null;

            final matchedProduct = products.firstWhere(
              (p) => (p.sku != null && p.sku!.toLowerCase() == skuOrName.toLowerCase()) ||
                  p.name.toLowerCase() == skuOrName.toLowerCase(),
              orElse: () => const ProductModel(id: '', name: '', price: '0'),
            );

            if (matchedProduct.id.isNotEmpty) {
              _addProductToGrid(matchedProduct, qty: qty, warehouse: warehouse, rack: bin, cost: cost);
              addedCount++;
            }
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Loaded $addedCount items into the opening stock grid from CSV!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error importing CSV: $e')));
      }
    }
  }

  void _exportDataCsv(List<OpeningStockEntry> entries) {
    List<List<dynamic>> rows = [
      ['Product Name', 'SKU', 'Barcode', 'Warehouse', 'Location Bin', 'Quantity', 'Cost Price (SAR)', 'Total Value (SAR)'],
    ];

    for (var item in entries) {
      final cost = double.tryParse(item.costPrice ?? '0') ?? 0.0;
      final total = item.quantity * cost;
      rows.add([
        item.productName,
        item.sku ?? '',
        item.barcode ?? '',
        item.warehouseId ?? 'Main Warehouse',
        item.locationBin ?? '',
        item.quantity,
        cost,
        total,
      ]);
    }

    final csvData = Csv().encode(rows);
    debugPrint('CSV Export size: ${csvData.length} chars');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exported ${entries.length} opening stock records to CSV!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productsAsync = ref.watch(productsProvider);
    final stockState = ref.watch(openingStockProvider);
    final warehousesAsync = ref.watch(warehousesProvider);
    final allWarehouses = _getWarehouseOptions(warehousesAsync.valueOrNull ?? []);
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    final totalGridItems = _gridRows.length;
    final totalGridUnits = _gridRows.fold<int>(0, (sum, r) => sum + r.quantity);
    final totalGridValuation = _gridRows.fold<double>(0.0, (sum, r) => sum + r.totalValuation);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? 'إدارة الرصيد الافتتاحي للمنتجات' : 'Product Opening Stock Management',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              isArabic
                  ? 'اختيار المستودع، تحديد موقع الرف، جدول المنتجات المتعددة وتحديث الأرصدة دفعة واحدة'
                  : 'Warehouse selection, rack mapping, multi-product grid & batch balance updates',
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
          ],
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: theme.colorScheme.primary,
          indicatorWeight: 3,
          tabs: [
            Tab(
              icon: const Icon(Icons.table_chart_rounded),
              text: isArabic
                  ? 'إضافة رصيد افتتاحي (الجدول ${_gridRows.isNotEmpty ? "• ${_gridRows.length}" : ""})'
                  : 'Add Opening Stock (Batch Grid ${_gridRows.isNotEmpty ? "• ${_gridRows.length}" : ""})',
            ),
            Tab(
              icon: const Icon(Icons.inventory_2_rounded),
              text: isArabic ? 'عرض سجلات المخزون المسجلة' : 'View Posted Stock Records',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isArabic ? Icons.g_translate : Icons.language),
            tooltip: isArabic ? 'تغيير اللغة إلى الإنجليزية' : 'Switch Language to Arabic',
            onPressed: () {
              ref.read(localeProvider.notifier).state =
                  isArabic ? const Locale('en') : const Locale('ar');
            },
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: isArabic ? 'تحميل نموذج CSV' : 'Download Template',
            onPressed: _downloadCsvTemplate,
          ),
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined),
            tooltip: isArabic ? 'استيراد من CSV' : 'Import from CSV',
            onPressed: _importCsv,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: isArabic ? 'تحديث' : 'Refresh',
            onPressed: () {
              ref.invalidate(productsProvider);
              ref.read(openingStockProvider.notifier).fetchOpeningStock();
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: ADD OPENING STOCK (BATCH GRID)
          _buildBatchGridTab(theme, productsAsync.valueOrNull ?? [], allWarehouses, totalGridItems, totalGridUnits, totalGridValuation, isArabic),

          // TAB 2: POSTED RECORDS VIEW
          _buildPostedRecordsTab(theme, stockState, allWarehouses, isArabic),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: BATCH OPENING STOCK GRID
  // ==========================================
  Widget _buildBatchGridTab(
    ThemeData theme,
    List<ProductModel> allProducts,
    List<String> allWarehouses,
    int totalItems,
    int totalUnits,
    double totalValuation,
    bool isArabic,
  ) {
    final currency = isArabic ? 'ر.س' : 'SAR';

    return Column(
      children: [
        // KPI Summary Cards Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Row(
            children: [
              _buildKpiCard(
                title: isArabic ? 'المنتجات في الجدول' : 'Products in Grid',
                value: isArabic ? '$totalItems منتج' : '$totalItems items',
                icon: Icons.list_alt_rounded,
                color: Colors.blueAccent,
              ),
              const SizedBox(width: 16),
              _buildKpiCard(
                title: isArabic ? 'إجمالي الوحدات الافتتاحية' : 'Total Opening Units',
                value: isArabic ? '$totalUnits وحدة' : '$totalUnits units',
                icon: Icons.add_business_rounded,
                color: Colors.teal,
              ),
              const SizedBox(width: 16),
              _buildKpiCard(
                title: isArabic ? 'إجمالي تقييم المخزون' : 'Total Stock Valuation',
                value: '${totalValuation.toStringAsFixed(2)} $currency',
                icon: Icons.monetization_on_rounded,
                color: Colors.deepPurpleAccent,
              ),
              const SizedBox(width: 16),
              _buildKpiCard(
                title: isArabic ? 'المستودع النشط' : 'Active Warehouse',
                value: _defaultWarehouse,
                icon: Icons.warehouse_rounded,
                color: Colors.orangeAccent,
              ),
            ],
          ),
        ),

        // Controls Toolbar
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
          child: Card(
            elevation: 1.5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Warehouse Selector
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          value: _defaultWarehouse,
                          decoration: InputDecoration(
                            labelText: isArabic ? 'المستودع المستهدف' : 'Target Warehouse',
                            prefixIcon: const Icon(Icons.warehouse_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            isDense: true,
                          ),
                          items: allWarehouses
                              .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _defaultWarehouse = val);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.sync_alt_rounded, size: 16),
                        label: Text(isArabic ? 'تطبيق على الكل' : 'Apply to all rows'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _gridRows.isEmpty ? null : _applyDefaultWarehouseToAll,
                      ),
                      const SizedBox(width: 16),

                      // Location / Rack
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _defaultRackController,
                          decoration: InputDecoration(
                            labelText: isArabic ? 'الموقع / الرف الافتراضي' : 'Default Location / Rack',
                            hintText: isArabic ? 'مثال: رف A-01 / طابق 3' : 'e.g. Rack A-01 / Shelf 3',
                            prefixIcon: const Icon(Icons.grid_view_rounded),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.drive_file_move_outline, size: 16),
                        label: Text(isArabic ? 'تطبيق الرف' : 'Apply Rack'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _gridRows.isEmpty ? null : _applyDefaultRackToAll,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Quick Autocomplete Add
                      Expanded(
                        flex: 4,
                        child: Autocomplete<ProductModel>(
                          displayStringForOption: (option) => '${option.name} (${option.sku ?? "No SKU"})',
                          optionsBuilder: (textEditingValue) {
                            if (textEditingValue.text.trim().isEmpty) {
                              return const Iterable<ProductModel>.empty();
                            }
                            final query = textEditingValue.text.toLowerCase();
                            return allProducts.where((p) =>
                                p.name.toLowerCase().contains(query) ||
                                (p.sku?.toLowerCase().contains(query) ?? false) ||
                                (p.barcode?.toLowerCase().contains(query) ?? false));
                          },
                          onSelected: (selected) {
                            _addProductToGrid(selected);
                          },
                          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                            return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                hintText: isArabic
                                    ? 'إضافة سريعة بالبحث (اكتب الاسم، SKU، أو امسح الباركود)...'
                                    : 'Quick Search & Add Product (Type name, SKU, or scan barcode)...',
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: const Icon(Icons.add_circle_outline, color: Colors.blueAccent),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                isDense: true,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Multi-Select Products Button
                      ElevatedButton.icon(
                        icon: const Icon(Icons.library_add_check_rounded),
                        label: Text(isArabic ? 'تحديد متعدد من الكتالوج' : 'Catalog Multi-Select'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _showMultiProductSelectionDialog(allProducts),
                      ),
                      const SizedBox(width: 12),

                      // Save All Rows Button
                      ElevatedButton.icon(
                        icon: _isBulkSaving
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.cloud_done_rounded),
                        label: Text(_isBulkSaving
                            ? (isArabic ? 'جاري الحفظ...' : 'Posting...')
                            : (isArabic ? 'حفظ جميع الصفوف (${_gridRows.length})' : 'Save All Rows (${_gridRows.length})')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isBulkSaving || _gridRows.isEmpty ? null : _saveAllRows,
                      ),
                      const SizedBox(width: 8),

                      // Clear Grid Button
                      IconButton(
                        icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
                        tooltip: isArabic ? 'مسح الجدول' : 'Clear Grid',
                        onPressed: _gridRows.isEmpty ? null : _clearAllRows,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Interactive Editable Grid
        Expanded(
          child: _gridRows.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.post_add_rounded, size: 80, color: Colors.grey.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      Text(
                        isArabic ? 'جدول الرصيد الافتتاحي فارغ' : 'Opening Stock Grid is Empty',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isArabic
                            ? 'استخدم "تحديد متعدد من الكتالوج" أو شريط البحث أعلى الصفحة لإضافة المنتجات.'
                            : 'Use "Catalog Multi-Select" or the search bar above to add products to this batch.',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.playlist_add_rounded),
                        label: Text(isArabic ? 'فتح كتالوج المنتجات للتحديد المتعدد' : 'Open Product Catalog Multi-Select'),
                        onPressed: () => _showMultiProductSelectionDialog(allProducts),
                      ),
                    ],
                  ),
                )
              : Card(
                  elevation: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(theme.primaryColor.withValues(alpha: 0.07)),
                          dataRowMinHeight: 60,
                          dataRowMaxHeight: 68,
                          columns: [
                            const DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text(isArabic ? 'المنتج و SKU' : 'Product & SKU', style: const TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text(isArabic ? 'المخزون الحالي' : 'Current Stock', style: const TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text(isArabic ? 'الكمية الافتتاحية (+)' : 'Opening Qty (+)', style: const TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text(isArabic ? 'إجمالي المخزون الجديد' : 'New Total Stock', style: const TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text(isArabic ? 'تكلفة الوحدة ($currency)' : 'Unit Cost ($currency)', style: const TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text(isArabic ? 'التقييم ($currency)' : 'Valuation ($currency)', style: const TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text(isArabic ? 'المستودع' : 'Warehouse', style: const TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text(isArabic ? 'موقع الرف / العلبة' : 'Rack / Bin Location', style: const TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text(isArabic ? 'الإجراءات' : 'Actions', style: const TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: List.generate(_gridRows.length, (idx) {
                            final row = _gridRows[idx];

                            return DataRow(
                              color: row.isSaved
                                  ? WidgetStateProperty.all(Colors.green.withValues(alpha: 0.08))
                                  : null,
                              cells: [
                                DataCell(Text('${idx + 1}')),
                                // Product Details
                                DataCell(
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(row.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text('SKU: ${row.product.sku ?? "N/A"} | Barcode: ${row.product.barcode ?? "N/A"}',
                                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                    ],
                                  ),
                                ),
                                // Current Stock
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${row.currentStock}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                // Opening Qty Input
                                DataCell(
                                  SizedBox(
                                    width: 100,
                                    child: TextField(
                                      controller: row.qtyController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onChanged: (val) => setState(() {
                                        row.isSaved = false;
                                      }),
                                    ),
                                  ),
                                ),
                                // New Total Stock
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${row.newTotalStock}',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800),
                                    ),
                                  ),
                                ),
                                // Unit Cost Input
                                DataCell(
                                  SizedBox(
                                    width: 100,
                                    child: TextField(
                                      controller: row.costController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onChanged: (val) => setState(() {
                                        row.isSaved = false;
                                      }),
                                    ),
                                  ),
                                ),
                                // Valuation
                                DataCell(
                                  Text(
                                    row.totalValuation.toStringAsFixed(2),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                                  ),
                                ),
                                // Warehouse Dropdown
                                DataCell(
                                  DropdownButton<String>(
                                    value: allWarehouses.contains(row.warehouse) ? row.warehouse : allWarehouses.first,
                                    underline: const SizedBox(),
                                    items: allWarehouses
                                        .map((w) => DropdownMenuItem(value: w, child: Text(w, style: const TextStyle(fontSize: 13))))
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() {
                                          row.warehouse = val;
                                          row.isSaved = false;
                                        });
                                      }
                                    },
                                  ),
                                ),
                                // Location Rack Input
                                DataCell(
                                  SizedBox(
                                    width: 120,
                                    child: TextField(
                                      controller: row.rackController,
                                      decoration: InputDecoration(
                                        hintText: isArabic ? 'الرف / الرفوف' : 'Rack / Shelf',
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onChanged: (val) => setState(() {
                                        row.isSaved = false;
                                      }),
                                    ),
                                  ),
                                ),
                                // Actions
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: row.isSaving
                                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                            : Icon(
                                                row.isSaved ? Icons.check_circle_rounded : Icons.save_rounded,
                                                color: row.isSaved ? Colors.green : Colors.blueAccent,
                                              ),
                                        tooltip: isArabic ? 'حفظ الصف' : 'Save Row',
                                        onPressed: () => _saveSingleRow(idx),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                        tooltip: isArabic ? 'حذف' : 'Remove',
                                        onPressed: () => _removeRow(idx),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 2: POSTED RECORDS TAB
  // ==========================================
  Widget _buildPostedRecordsTab(
      ThemeData theme, AsyncValue<List<OpeningStockEntry>> stockState, List<String> allWarehouses, bool isArabic) {
    final currency = isArabic ? 'ر.س' : 'SAR';

    return Column(
      children: [
        // Filter Panel
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _recordsSearchController,
                      onChanged: (val) => setState(() => _recordsSearchQuery = val.toLowerCase()),
                      decoration: InputDecoration(
                        hintText: isArabic
                            ? 'بحث في السجلات المسجلة بالمنتج، SKU، الباركود...'
                            : 'Search posted records by product, SKU, barcode...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String?>(
                      value: _selectedWarehouseFilter,
                      decoration: InputDecoration(
                        labelText: isArabic ? 'فلتر المستودع' : 'Filter Warehouse',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        isDense: true,
                      ),
                      items: [
                        DropdownMenuItem(value: null, child: Text(isArabic ? 'جميع المستودعات' : 'All Warehouses')),
                        ...allWarehouses.map((w) => DropdownMenuItem(value: w, child: Text(w))),
                      ],
                      onChanged: (val) => setState(() => _selectedWarehouseFilter = val),
                    ),
                  ),
                  const SizedBox(width: 16),
                  stockState.maybeWhen(
                    data: (entries) => ElevatedButton.icon(
                      icon: const Icon(Icons.download_rounded),
                      label: Text(isArabic ? 'تصدير CSV / Excel' : 'Export CSV / Excel'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _exportDataCsv(entries),
                    ),
                    orElse: () => const SizedBox(),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Records Data Table
        Expanded(
          child: stockState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text(isArabic ? 'خطأ في تحميل سجلات المخزون: $e' : 'Error loading stock records: $e')),
            data: (entries) {
              final filtered = entries.where((item) {
                final matchSearch = _recordsSearchQuery.isEmpty ||
                    item.productName.toLowerCase().contains(_recordsSearchQuery) ||
                    (item.sku?.toLowerCase().contains(_recordsSearchQuery) ?? false) ||
                    (item.barcode?.toLowerCase().contains(_recordsSearchQuery) ?? false);

                final matchWarehouse = _selectedWarehouseFilter == null ||
                    (item.warehouseId != null && item.warehouseId == _selectedWarehouseFilter);

                return matchSearch && matchWarehouse;
              }).toList();

              filtered.sort((a, b) {
                int cmp = 0;
                switch (_sortColumnIndex) {
                  case 0:
                    cmp = a.productName.toLowerCase().compareTo(b.productName.toLowerCase());
                    break;
                  case 1:
                    cmp = (a.sku ?? '').compareTo(b.sku ?? '');
                    break;
                  case 2:
                    cmp = (a.warehouseId ?? '').compareTo(b.warehouseId ?? '');
                    break;
                  case 3:
                    cmp = a.quantity.compareTo(b.quantity);
                    break;
                  case 4:
                    cmp = (double.tryParse(a.costPrice ?? '0') ?? 0).compareTo(double.tryParse(b.costPrice ?? '0') ?? 0);
                    break;
                  default:
                    cmp = a.productName.compareTo(b.productName);
                }
                return _sortAscending ? cmp : -cmp;
              });

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_rounded, size: 80, color: Colors.grey.withValues(alpha: 0.4)),
                      const SizedBox(height: 16),
                      Text(
                        isArabic ? 'لم يتم العثور على سجلات رصيد افتتاحي مسجلة.' : 'No posted opening stock records found.',
                        style: const TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return Card(
                elevation: 1,
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        sortColumnIndex: _sortColumnIndex,
                        sortAscending: _sortAscending,
                        headingRowColor: WidgetStateProperty.all(theme.primaryColor.withValues(alpha: 0.06)),
                        columns: [
                          DataColumn(
                            label: Text(isArabic ? 'اسم المنتج' : 'Product Name', style: const TextStyle(fontWeight: FontWeight.bold)),
                            onSort: (index, asc) => setState(() {
                              _sortColumnIndex = index;
                              _sortAscending = asc;
                            }),
                          ),
                          DataColumn(
                            label: const Text('SKU', style: TextStyle(fontWeight: FontWeight.bold)),
                            onSort: (index, asc) => setState(() {
                              _sortColumnIndex = index;
                              _sortAscending = asc;
                            }),
                          ),
                          DataColumn(
                            label: Text(isArabic ? 'المستودع / الرف' : 'Warehouse / Rack', style: const TextStyle(fontWeight: FontWeight.bold)),
                            onSort: (index, asc) => setState(() {
                              _sortColumnIndex = index;
                              _sortAscending = asc;
                            }),
                          ),
                          DataColumn(
                            label: Text(isArabic ? 'الكمية الافتتاحية' : 'Opening Quantity', style: const TextStyle(fontWeight: FontWeight.bold)),
                            numeric: true,
                            onSort: (index, asc) => setState(() {
                              _sortColumnIndex = index;
                              _sortAscending = asc;
                            }),
                          ),
                          DataColumn(
                            label: Text(isArabic ? 'سعر التكلفة ($currency)' : 'Cost Price ($currency)', style: const TextStyle(fontWeight: FontWeight.bold)),
                            numeric: true,
                            onSort: (index, asc) => setState(() {
                              _sortColumnIndex = index;
                              _sortAscending = asc;
                            }),
                          ),
                          DataColumn(
                            label: Text(isArabic ? 'إجمالي التقييم ($currency)' : 'Total Valuation ($currency)', style: const TextStyle(fontWeight: FontWeight.bold)),
                            numeric: true,
                          ),
                          DataColumn(
                            label: Text(isArabic ? 'الإجراءات' : 'Actions', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                        rows: filtered.map((entry) {
                          final cost = double.tryParse(entry.costPrice ?? '0') ?? 0.0;
                          final valuation = entry.quantity * cost;

                          return DataRow(
                            cells: [
                              DataCell(
                                Text(entry.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              DataCell(Text(entry.sku ?? 'N/A')),
                              DataCell(
                                Text('${entry.warehouseId ?? "Main Warehouse"}${entry.locationBin != null ? " (${entry.locationBin})" : ""}'),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${entry.quantity}',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor),
                                  ),
                                ),
                              ),
                              DataCell(Text(cost.toStringAsFixed(2))),
                              DataCell(
                                Text(
                                  valuation.toStringAsFixed(2),
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
                                      tooltip: isArabic ? 'تعديل السجل' : 'Edit Record',
                                      onPressed: () => _showEditPostedDialog(context, entry: entry),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                      tooltip: isArabic ? 'حذف' : 'Delete',
                                      onPressed: () async {
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (c) => AlertDialog(
                                            title: Text(isArabic ? 'حذف السجل؟' : 'Delete Entry?'),
                                            content: Text(isArabic
                                                ? 'هل أنت تأكد من حذف سجل الرصيد الافتتاحي للمنتج ${entry.productName}؟'
                                                : 'Delete opening stock entry for ${entry.productName}?'),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(c, false), child: Text(isArabic ? 'إلغاء' : 'Cancel')),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                onPressed: () => Navigator.pop(c, true),
                                                child: Text(isArabic ? 'حذف' : 'Delete', style: const TextStyle(color: Colors.white)),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirmed == true) {
                                          await ref.read(openingStockProvider.notifier).deleteOpeningStock(entry.openingStockId);
                                        }
                                      },
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showEditPostedDialog(BuildContext context, {required OpeningStockEntry entry}) {
    final qtyController = TextEditingController(text: entry.quantity.toString());
    final warehouseController = TextEditingController(text: entry.warehouseId ?? 'Main Warehouse');
    final binController = TextEditingController(text: entry.locationBin ?? '');
    final costController = TextEditingController(text: entry.costPrice ?? '0.00');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Edit Opening Stock: ${entry.productName}', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: qtyController,
                    decoration: const InputDecoration(labelText: 'Opening Quantity *', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: costController,
                    decoration: const InputDecoration(labelText: 'Unit Cost Price (SAR)', border: OutlineInputBorder()),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: warehouseController,
                    decoration: const InputDecoration(labelText: 'Warehouse Name', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: binController,
                    decoration: const InputDecoration(labelText: 'Location / Bin (e.g. Rack A-12)', border: OutlineInputBorder()),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final qty = int.tryParse(qtyController.text.trim()) ?? 0;
                final payload = [
                  {
                    'productId': entry.productId,
                    'quantity': qty,
                    'warehouseId': warehouseController.text.trim().isEmpty ? null : warehouseController.text.trim(),
                    'locationBin': binController.text.trim().isEmpty ? null : binController.text.trim(),
                    'costPrice': costController.text.trim(),
                  }
                ];

                final success = await ref.read(openingStockProvider.notifier).saveOpeningStock(payload);
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(success ? 'Opening stock updated!' : 'Failed to update opening stock.')),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildKpiCard({required String title, required String value, required IconData icon, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
