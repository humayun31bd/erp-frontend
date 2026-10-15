import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/routing/route_names.dart';
import '../../providers/pos_provider.dart';
import '../../../inventory/providers/category_provider.dart';
import 'product_form_screen.dart';
import '../../domain/product_model.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Control & Panel Flags
  bool _showTopPanel = true;
  bool _isTableView = true; // Default Data Table Grid View

  // Filters
  String _selectedProductTypeFilter = 'All'; // All, Standard, Electronics, Pharmacy, Apparel
  String? _selectedCategoryFilter;
  String? _selectedBrandFilter;
  String _statusFilter = 'All'; // All, Active, Inactive
  bool _notForSellFilter = false;
  bool _isWebFilter = false;

  // Sorting
  int _sortColumnIndex = 2; // Default to Product Name
  bool _sortAscending = true;

  // Column Visibility Flags (Requested 10 columns)
  final Map<String, bool> _columnVisibility = {
    'Image': true,
    'Actions': true,
    'Product Name': true,
    'Purchase Price': true,
    'Selling Price': true,
    'Current Stock': true,
    'Product Type': true,
    'Tax': true,
    'Brand': true,
    'SKU': true,
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        
        if (fields.isEmpty || fields.length == 1) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV file is empty or invalid.')));
          return;
        }
        
        final dataRows = fields.skip(1);
        final api = ref.read(posApiProvider);
        
        int successCount = 0;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Importing products... Please wait.')));
        }

        for (var row in dataRows) {
          if (row.length >= 2) {
             final payload = {
               'productName': row[0].toString(),
               'price': row[1].toString(),
               'sku': row.length > 2 ? row[2].toString() : null,
               'barcode': row.length > 3 ? row[3].toString() : null,
             };
             try {
               await api.createProduct(payload);
               successCount++;
             } catch(e) {
               print('Error importing row: $e');
             }
          }
        }
        
        ref.refresh(productsProvider);
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully imported $successCount products!')));
        }
      }
    } catch(e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error parsing CSV: $e')));
      }
    }
  }

  Future<void> _deleteProduct(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this product? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(posApiProvider).deleteProduct(id);
        ref.refresh(productsProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product deleted successfully.')));
        }
      } catch(e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete product: $e')));
        }
      }
    }
  }

  String _getProductTypeLabel(ProductModel p) {
    if (p.isElectronics) return 'Electronics';
    if (p.isMedicine) return 'Pharmacy';
    if (p.isApparel) return 'Apparel';
    return 'Standard';
  }

  List<ProductModel> _applyFiltersAndSort(List<ProductModel> products) {
    final q = searchQuery.toLowerCase().trim();
    final filtered = products.where((p) {
      // Search by Name, Barcode, Brand, or SKU
      final matchesSearch = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          (p.barcode != null && p.barcode!.toLowerCase().contains(q)) ||
          (p.brandId != null && p.brandId!.toLowerCase().contains(q)) ||
          (p.sku != null && p.sku!.toLowerCase().contains(q));
      if (!matchesSearch) return false;

      // Status
      if (_statusFilter == 'Active' && !p.isActive) return false;
      if (_statusFilter == 'Inactive' && p.isActive) return false;

      // Product Type
      if (_selectedProductTypeFilter == 'Electronics' && !p.isElectronics) return false;
      if (_selectedProductTypeFilter == 'Pharmacy' && !p.isMedicine) return false;
      if (_selectedProductTypeFilter == 'Apparel' && !p.isApparel) return false;
      if (_selectedProductTypeFilter == 'Standard' && (p.isElectronics || p.isMedicine || p.isApparel)) return false;

      // Category
      if (_selectedCategoryFilter != null && p.categoryId != _selectedCategoryFilter) return false;

      // Brand
      if (_selectedBrandFilter != null && _selectedBrandFilter!.isNotEmpty &&
          (p.brandId == null || !p.brandId!.toLowerCase().contains(_selectedBrandFilter!.toLowerCase()))) {
        return false;
      }

      // Special Flags
      if (_notForSellFilter && p.isProductDisplayPosApp) return false;
      if (_isWebFilter && !p.isProductDisplayWebsiteApp) return false;

      return true;
    }).toList();

    filtered.sort((a, b) {
      int cmp = 0;
      switch (_sortColumnIndex) {
        case 2: // Name
          cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          break;
        case 3: // Purchase Price
          cmp = (double.tryParse(a.costPrice ?? '0') ?? 0).compareTo(double.tryParse(b.costPrice ?? '0') ?? 0);
          break;
        case 4: // Selling Price
          cmp = (double.tryParse(a.price) ?? 0).compareTo(double.tryParse(b.price) ?? 0);
          break;
        case 5: // Stock
          cmp = a.stockQuantity.compareTo(b.stockQuantity);
          break;
        case 6: // Product Type
          cmp = _getProductTypeLabel(a).compareTo(_getProductTypeLabel(b));
          break;
        case 7: // Tax
          cmp = a.isTaxExempt.toString().compareTo(b.isTaxExempt.toString());
          break;
        case 8: // Brand
          cmp = (a.brandId ?? '').compareTo(b.brandId ?? '');
          break;
        case 9: // SKU
          cmp = (a.sku ?? '').compareTo(b.sku ?? '');
          break;
        default:
          cmp = a.name.compareTo(b.name);
      }
      return _sortAscending ? cmp : -cmp;
    });

    return filtered;
  }

  void _showColumnVisibilityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Customize Table Columns', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 320,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _columnVisibility.keys.map((colName) {
                      return CheckboxListTile(
                        dense: true,
                        title: Text(colName),
                        value: _columnVisibility[colName],
                        onChanged: (val) {
                          setDlgState(() => _columnVisibility[colName] = val ?? true);
                          setState(() {});
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedProductTypeFilter = 'All';
      _selectedCategoryFilter = null;
      _selectedBrandFilter = null;
      _statusFilter = 'All';
      _notForSellFilter = false;
      _isWebFilter = false;
      _searchController.clear();
      searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final productsState = ref.watch(productsProvider);
    final categoryState = ref.watch(categoryProvider);
    final theme = Theme.of(context);

    List<DropdownMenuItem<String?>> categoryDropdownItems = [
      const DropdownMenuItem<String?>(value: null, child: Text('All Categories')),
    ];
    categoryState.whenData((categories) {
      categoryDropdownItems.addAll(categories.map((c) => DropdownMenuItem<String?>(
        value: c.id,
        child: Text(c.name),
      )));
    });

    List<DropdownMenuItem<String?>> brandDropdownItems = [
      const DropdownMenuItem<String?>(value: null, child: Text('All Brands')),
    ];
    productsState.whenData((products) {
      final brands = products
          .map((p) => p.brandId?.trim())
          .whereType<String>()
          .where((b) => b.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      brandDropdownItems.addAll(brands.map((b) => DropdownMenuItem<String?>(
        value: b,
        child: Text(b),
      )));
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.inventory, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: ElevatedButton.icon(
              onPressed: () => context.goNamed(RouteNames.openingStock),
              icon: const Icon(Icons.inventory_2_outlined, size: 18),
              label: const Text('Opening Stock'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          IconButton(
            icon: Icon(_showTopPanel ? Icons.filter_alt : Icons.filter_alt_outlined),
            tooltip: _showTopPanel ? 'Hide Filter Panel' : 'Show Filter Panel',
            onPressed: () => setState(() => _showTopPanel = !_showTopPanel),
          ),
          IconButton(
            icon: const Icon(Icons.view_column_rounded),
            tooltip: 'Column Visibility',
            onPressed: () => _showColumnVisibilityDialog(context),
          ),
          IconButton(
            icon: Icon(_isTableView ? Icons.grid_view_rounded : Icons.table_chart_rounded),
            tooltip: _isTableView ? 'Switch to Card Grid View' : 'Switch to Data Table View',
            onPressed: () => setState(() => _isTableView = !_isTableView),
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Download Template',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('CSV Format: Name, Price, SKU, Barcode')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined),
            tooltip: 'Import from CSV',
            onPressed: _importCsv,
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_2),
            tooltip: 'Print Product Labels',
            onPressed: () => context.goNamed(RouteNames.printLabels),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Inventory',
            onPressed: () => ref.refresh(productsProvider),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Top Control & Filter Panel (Show/Hide)
          if (_showTopPanel)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedProductTypeFilter,
                              decoration: const InputDecoration(labelText: 'Product Type', border: OutlineInputBorder(), isDense: true),
                              items: const [
                                DropdownMenuItem(value: 'All', child: Text('All Types')),
                                DropdownMenuItem(value: 'Standard', child: Text('Standard')),
                                DropdownMenuItem(value: 'Electronics', child: Text('Electronics')),
                                DropdownMenuItem(value: 'Pharmacy', child: Text('Pharmacy')),
                                DropdownMenuItem(value: 'Apparel', child: Text('Apparel')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedProductTypeFilter = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String?>(
                              value: _selectedCategoryFilter,
                              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder(), isDense: true),
                              items: categoryDropdownItems,
                              onChanged: (val) => setState(() => _selectedCategoryFilter = val),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String?>(
                              value: _selectedBrandFilter,
                              decoration: const InputDecoration(labelText: 'Brand', border: OutlineInputBorder(), isDense: true),
                              items: brandDropdownItems,
                              onChanged: (val) => setState(() => _selectedBrandFilter = val),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _statusFilter,
                              decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder(), isDense: true),
                              items: const [
                                DropdownMenuItem(value: 'All', child: Text('All Status')),
                                DropdownMenuItem(value: 'Active', child: Text('Active Only')),
                                DropdownMenuItem(value: 'Inactive', child: Text('Inactive Only')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _statusFilter = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          FilterChip(
                            label: const Text('Not for Sell'),
                            selected: _notForSellFilter,
                            onSelected: (val) => setState(() => _notForSellFilter = val),
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Is Web Display'),
                            selected: _isWebFilter,
                            onSelected: (val) => setState(() => _isWebFilter = val),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _resetFilters,
                            icon: const Icon(Icons.clear_all, size: 18),
                            label: const Text('Clear Filters'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Search Bar (Name, Barcode, Brand, SKU)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search products by Name, Barcode, Brand, or SKU...',
                  hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF1A237E)),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),
          ),
          
          // Data View (Table Grid vs Card Grid)
          Expanded(
            child: productsState.when(
              data: (products) {
                final filteredProducts = _applyFiltersAndSort(products);

                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isEmpty ? 'No products matching filters.' : 'No results for "$searchQuery"',
                          style: const TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                }

                if (_isTableView) {
                  return Card(
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
                            sortColumnIndex: _sortColumnIndex,
                            sortAscending: _sortAscending,
                            headingRowColor: WidgetStateProperty.all(theme.primaryColor.withValues(alpha: 0.06)),
                            columns: [
                              if (_columnVisibility['Image'] ?? true)
                                const DataColumn(label: Text('Image', style: TextStyle(fontWeight: FontWeight.bold))),
                              if (_columnVisibility['Actions'] ?? true)
                                const DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                              if (_columnVisibility['Product Name'] ?? true)
                                DataColumn(
                                  label: const Text('Product Name', style: TextStyle(fontWeight: FontWeight.bold)),
                                  onSort: (index, asc) => setState(() {
                                    _sortColumnIndex = index;
                                    _sortAscending = asc;
                                  }),
                                ),
                              if (_columnVisibility['Purchase Price'] ?? true)
                                DataColumn(
                                  label: const Text('Purchase Price', style: TextStyle(fontWeight: FontWeight.bold)),
                                  numeric: true,
                                  onSort: (index, asc) => setState(() {
                                    _sortColumnIndex = index;
                                    _sortAscending = asc;
                                  }),
                                ),
                              if (_columnVisibility['Selling Price'] ?? true)
                                DataColumn(
                                  label: const Text('Selling Price', style: TextStyle(fontWeight: FontWeight.bold)),
                                  numeric: true,
                                  onSort: (index, asc) => setState(() {
                                    _sortColumnIndex = index;
                                    _sortAscending = asc;
                                  }),
                                ),
                              if (_columnVisibility['Current Stock'] ?? true)
                                DataColumn(
                                  label: const Text('Current Stock', style: TextStyle(fontWeight: FontWeight.bold)),
                                  numeric: true,
                                  onSort: (index, asc) => setState(() {
                                    _sortColumnIndex = index;
                                    _sortAscending = asc;
                                  }),
                                ),
                              if (_columnVisibility['Product Type'] ?? true)
                                DataColumn(
                                  label: const Text('Product Type', style: TextStyle(fontWeight: FontWeight.bold)),
                                  onSort: (index, asc) => setState(() {
                                    _sortColumnIndex = index;
                                    _sortAscending = asc;
                                  }),
                                ),
                              if (_columnVisibility['Tax'] ?? true)
                                DataColumn(
                                  label: const Text('Tax', style: TextStyle(fontWeight: FontWeight.bold)),
                                  onSort: (index, asc) => setState(() {
                                    _sortColumnIndex = index;
                                    _sortAscending = asc;
                                  }),
                                ),
                              if (_columnVisibility['Brand'] ?? true)
                                DataColumn(
                                  label: const Text('Brand', style: TextStyle(fontWeight: FontWeight.bold)),
                                  onSort: (index, asc) => setState(() {
                                    _sortColumnIndex = index;
                                    _sortAscending = asc;
                                  }),
                                ),
                              if (_columnVisibility['SKU'] ?? true)
                                DataColumn(
                                  label: const Text('SKU', style: TextStyle(fontWeight: FontWeight.bold)),
                                  onSort: (index, asc) => setState(() {
                                    _sortColumnIndex = index;
                                    _sortAscending = asc;
                                  }),
                                ),
                            ],
                            rows: filteredProducts.map((product) {
                              final primaryImg = product.images.firstWhere((img) => img.isPrimary, orElse: () => product.images.isNotEmpty ? product.images.first : ProductImageModel(id: '', productId: '', imageUrl: ''));
                              final isLowStock = product.stockQuantity <= product.minStockLevel;

                              return DataRow(
                                onSelectChanged: (_) => _showProductDetails(context, product, ref),
                                cells: [
                                  if (_columnVisibility['Image'] ?? true)
                                    DataCell(
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: theme.primaryColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: primaryImg.imageUrl.isNotEmpty
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Image.network(primaryImg.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.inventory_2, color: theme.primaryColor, size: 18)),
                                              )
                                            : Icon(Icons.inventory_2, color: theme.primaryColor, size: 18),
                                      ),
                                    ),
                                  if (_columnVisibility['Actions'] ?? true)
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
                                            onPressed: () async {
                                              final result = await Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (ctx) => ProductFormScreen(product: product)),
                                              );
                                              if (result == true) ref.refresh(productsProvider);
                                            },
                                            tooltip: 'Edit Product',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                            onPressed: () => _deleteProduct(context, product.id),
                                            tooltip: 'Delete Product',
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (_columnVisibility['Product Name'] ?? true)
                                    DataCell(
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          if (!product.isActive)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
                                              child: const Text('Inactive', style: TextStyle(fontSize: 10, color: Colors.black54)),
                                            ),
                                        ],
                                      ),
                                    ),
                                  if (_columnVisibility['Purchase Price'] ?? true)
                                    DataCell(Text(product.costPrice != null && product.costPrice!.isNotEmpty ? 'SAR ${product.costPrice}' : 'N/A')),
                                  if (_columnVisibility['Selling Price'] ?? true)
                                    DataCell(Text('SAR ${product.price}', style: const TextStyle(fontWeight: FontWeight.bold))),
                                  if (_columnVisibility['Current Stock'] ?? true)
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isLowStock ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${product.stockQuantity}',
                                          style: TextStyle(
                                            color: isLowStock ? Colors.red : Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (_columnVisibility['Product Type'] ?? true)
                                    DataCell(
                                      Chip(
                                        label: Text(_getProductTypeLabel(product), style: const TextStyle(fontSize: 11)),
                                        visualDensity: VisualDensity.compact,
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                  if (_columnVisibility['Tax'] ?? true)
                                    DataCell(Text(product.isTaxExempt ? 'Exempt' : '15% VAT')),
                                  if (_columnVisibility['Brand'] ?? true)
                                    DataCell(Text(product.brandId ?? 'N/A')),
                                  if (_columnVisibility['SKU'] ?? true)
                                    DataCell(Text(product.sku ?? 'N/A')),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 2;
                    if (constraints.maxWidth > 1200) crossAxisCount = 5;
                    else if (constraints.maxWidth > 900) crossAxisCount = 4;
                    else if (constraints.maxWidth > 600) crossAxisCount = 3;

                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.75, 
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        final isLowStock = product.stockQuantity <= product.minStockLevel;

                        return GestureDetector(
                          onTap: () => _showProductDetails(context, product, ref),
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor.withValues(alpha: 0.05),
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.inventory_2_rounded,
                                        size: 48,
                                        color: theme.primaryColor.withValues(alpha: 0.4),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, height: 1.2),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          product.barcode ?? product.sku ?? 'No SKU',
                                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const Spacer(),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              'SAR ${product.price}',
                                              style: TextStyle(
                                                color: theme.primaryColor,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: isLowStock ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '${product.stockQuantity}',
                                                style: TextStyle(
                                                  color: isLowStock ? Colors.red : Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProductFormScreen()),
          );
          if (result == true) {
            ref.refresh(productsProvider);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Product', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showProductDetails(BuildContext context, ProductModel product, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)],
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(24.0),
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(Icons.inventory_2_rounded, size: 40, color: Theme.of(context).primaryColor),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.2)),
                                  const SizedBox(height: 8),
                                  Text('SAR ${product.price}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              style: IconButton.styleFrom(backgroundColor: Colors.blue.withValues(alpha: 0.1)),
                              onPressed: () async {
                                Navigator.pop(sheetContext);
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (ctx) => ProductFormScreen(product: product)),
                                );
                                if (result == true) {
                                  ref.refresh(productsProvider);
                                }
                              },
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              style: IconButton.styleFrom(backgroundColor: Colors.red.withValues(alpha: 0.1)),
                              onPressed: () {
                                Navigator.pop(sheetContext);
                                _deleteProduct(context, product.id);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        _buildSectionHeader('Details'),
                        _buildDetailRow('SKU', product.sku ?? 'N/A'),
                        _buildDetailRow('Barcode', product.barcode ?? 'N/A'),
                        _buildDetailRow('Category', product.categoryId ?? 'Uncategorized'),
                        _buildDetailRow('Description', product.description ?? 'No description available.'),
                        if (product.isElectronics) ...[
                          const SizedBox(height: 16),
                          _buildSectionHeader('Electronics Specifications'),
                          if (product.isModelNumber && product.modelNumber != null) _buildDetailRow('Model Number', product.modelNumber!),
                          if (product.isStorageCapacityApplicable && product.storageCapacity != null) _buildDetailRow('Storage Capacity', product.storageCapacity!),
                          if (product.isRamApplicable && product.ram != null) _buildDetailRow('RAM', product.ram!),
                          if (product.isWarrantyApplicable) _buildDetailRow('Warranty', '${product.warrantyMonths} Months (${product.warrantyPeriodsDays} Days)'),
                          _buildDetailRow('Serial Tracking', product.requiresSerialTracking ? 'Required' : 'Disabled'),
                        ],
                        if (product.isMedicine) ...[
                          const SizedBox(height: 16),
                          _buildSectionHeader('Pharmacy Specifications'),
                          if (product.isGenericNameApplicable && product.genericName != null) _buildDetailRow('Generic Name', product.genericName!),
                          if (product.isActiveIngredientApplicable && product.activeIngredient != null) _buildDetailRow('Active Ingredient', product.activeIngredient!),
                          _buildDetailRow('Prescription Required', product.isPrescriptionRequired ? 'Yes' : 'No'),
                          _buildDetailRow('Batch Tracking', product.requiresBatchTracking ? 'Required' : 'Disabled'),
                        ],
                        if (product.isApparel) ...[
                          const SizedBox(height: 16),
                          _buildSectionHeader('Apparel Specifications'),
                          if (product.fiberComposition != null) _buildDetailRow('Fiber Composition', product.fiberComposition!),
                          _buildDetailRow('Underwear Item', product.isUnderwear ? 'Yes' : 'No'),
                          _buildDetailRow('Tax Exempt', product.isTaxExempt ? 'Yes' : 'No'),
                        ],
                        const SizedBox(height: 32),
                        _buildSectionHeader('Units of Measure'),
                        if (product.units.isEmpty) const Text('No additional units defined.', style: TextStyle(color: Colors.grey)),
                        ...product.units.map<Widget>((unit) => Card(
                          elevation: 0,
                          color: Theme.of(context).cardColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
                          child: ListTile(
                            title: Text(unit.unitCode, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Conversion: ${unit.conversionFactor}'),
                            trailing: unit.barcode != null ? Text(unit.barcode!) : null,
                          ),
                        )),
                        const SizedBox(height: 32),
                        _buildSectionHeader('Branch Inventory'),
                        if (product.branchInventory.isEmpty) const Text('No branch inventory records.', style: TextStyle(color: Colors.grey)),
                        ...product.branchInventory.map<Widget>((inv) => Card(
                          elevation: 0,
                          color: Theme.of(context).cardColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
                          child: ListTile(
                            title: Text('Branch ID: ${inv.branchId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Shelf: ${inv.shelfLocation ?? "N/A"}'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Stock: ${inv.stockQuantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text('Min: ${inv.minStockLevel}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                        )),
                        const SizedBox(height: 40),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
