import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app.dart';
import '../../../settings/providers/settings_provider.dart';
import '../../../pos/providers/pos_provider.dart';
import '../../../pos/domain/product_model.dart';
import '../../providers/inventory_transfer_provider.dart';

class _TransferLocationOption {
  final String id;
  final String name;
  final String type; // 'WAREHOUSE' or 'BRANCH'
  final String? subtitle;

  const _TransferLocationOption({
    required this.id,
    required this.name,
    required this.type,
    this.subtitle,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _TransferLocationOption &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class _TransferLineItem {
  final ProductModel product;
  double quantity;
  double unitPrice;

  _TransferLineItem({
    required this.product,
    this.quantity = 1.0,
    required this.unitPrice,
  });

  double get subtotal => quantity * unitPrice;
}

class CreateInventoryTransferScreen extends ConsumerStatefulWidget {
  const CreateInventoryTransferScreen({super.key});

  @override
  ConsumerState<CreateInventoryTransferScreen> createState() => _CreateInventoryTransferScreenState();
}

class _CreateInventoryTransferScreenState extends ConsumerState<CreateInventoryTransferScreen> {
  final _formKey = GlobalKey<FormState>();

  _TransferLocationOption? _sourceLocation;
  _TransferLocationOption? _destinationLocation;

  late final TextEditingController _transferNoController;
  DateTime _transferDate = DateTime.now();
  String _status = 'COMPLETED'; // 'COMPLETED', 'IN_TRANSIT', 'PENDING'

  final TextEditingController _driverNameController = TextEditingController();
  final TextEditingController _vehicleNoController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  final List<_TransferLineItem> _items = [];
  bool _isSubmitting = false;

  // Search & Quick Add
  ProductModel? _selectedProductToAdd;
  final TextEditingController _quickQtyController = TextEditingController(text: '1');
  final TextEditingController _productSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final randomSuffix = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
    _transferNoController = TextEditingController(text: 'TRF-$randomSuffix');
  }

  @override
  void dispose() {
    _transferNoController.dispose();
    _driverNameController.dispose();
    _vehicleNoController.dispose();
    _remarksController.dispose();
    _quickQtyController.dispose();
    _productSearchController.dispose();
    super.dispose();
  }

  List<_TransferLocationOption> _extractLocations(
    List<dynamic> warehousesRaw,
    List<dynamic> branchesRaw,
    bool isArabic,
  ) {
    final List<_TransferLocationOption> result = [];

    // 1. Warehouses from settings
    for (final w in warehousesRaw) {
      if (w is Map && w['name'] != null && w['name'].toString().trim().isNotEmpty) {
        final id = (w['id'] ?? w['name']).toString();
        final name = w['name'].toString().trim();
        final loc = (w['location'] ?? '').toString().trim();
        result.add(_TransferLocationOption(
          id: id,
          name: name,
          type: 'WAREHOUSE',
          subtitle: loc.isNotEmpty ? loc : (isArabic ? 'مستودع تخزين' : 'Storage Warehouse'),
        ));
      }
    }

    // 2. Branches from settings
    for (final b in branchesRaw) {
      if (b is Map && b['name'] != null && b['name'].toString().trim().isNotEmpty) {
        final id = (b['id'] ?? b['name']).toString();
        final name = b['name'].toString().trim();
        final code = (b['code'] ?? b['city'] ?? '').toString().trim();
        if (!result.any((item) => item.name == name)) {
          result.add(_TransferLocationOption(
            id: id,
            name: name,
            type: 'BRANCH',
            subtitle: code.isNotEmpty ? code : (isArabic ? 'فرع تجزئة / نقطة بيع' : 'Retail Branch / POS Outlet'),
          ));
        }
      }
    }

    // Fallbacks if system doesn't have custom locations configured yet
    if (result.isEmpty) {
      result.addAll([
        _TransferLocationOption(
          id: 'WH-MAIN',
          name: isArabic ? 'المستودع الرئيسي (الرياض)' : 'Main Central Warehouse (Riyadh)',
          type: 'WAREHOUSE',
          subtitle: isArabic ? 'مستودع التوزيع المركزي' : 'Primary Distribution Depot',
        ),
        _TransferLocationOption(
          id: 'WH-LOGISTICS',
          name: isArabic ? 'مستودع جدة اللوجستي' : 'Jeddah Logistics Hub',
          type: 'WAREHOUSE',
          subtitle: isArabic ? 'شحن ومستودع ثانوي' : 'Regional Transit Warehouse',
        ),
        _TransferLocationOption(
          id: 'BR-RETAIL-01',
          name: isArabic ? 'فرع التجزئة الرئيسي #1' : 'Main Retail Store #1',
          type: 'BRANCH',
          subtitle: isArabic ? 'نقطة بيع نشطة' : 'Direct POS Counter',
        ),
        _TransferLocationOption(
          id: 'BR-RETAIL-02',
          name: isArabic ? 'فرع الدمام #2' : 'Dammam Branch Outlet #2',
          type: 'BRANCH',
          subtitle: isArabic ? 'فرع بيع بالتجزئة' : 'East Province Outlet',
        ),
      ]);
    }

    return result;
  }

  void _swapLocations() {
    setState(() {
      final temp = _sourceLocation;
      _sourceLocation = _destinationLocation;
      _destinationLocation = temp;
    });
  }

  void _addItemToTransfer(ProductModel product, double qty) {
    if (qty <= 0) return;

    final existingIndex = _items.indexWhere((i) => i.product.id == product.id);
    final price = double.tryParse(product.costPrice ?? product.price) ?? 0.0;

    setState(() {
      if (existingIndex >= 0) {
        _items[existingIndex].quantity += qty;
      } else {
        _items.add(_TransferLineItem(
          product: product,
          quantity: qty,
          unitPrice: price,
        ));
      }
      _selectedProductToAdd = null;
      _productSearchController.clear();
      _quickQtyController.text = '1';
    });
  }

  Future<void> _pickTransferDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _transferDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _transferDate = picked);
    }
  }

  Future<void> _submitTransfer(bool isArabic) async {
    if (!_formKey.currentState!.validate()) return;

    if (_sourceLocation == null) {
      _showToast(isArabic ? 'يرجى تحديد موقع المصدر (من)' : 'Please select the source location (From)', isError: true);
      return;
    }

    if (_destinationLocation == null) {
      _showToast(isArabic ? 'يرجى تحديد موقع الوجهة (إلى)' : 'Please select the destination location (To)', isError: true);
      return;
    }

    if (_sourceLocation!.id == _destinationLocation!.id) {
      _showToast(
        isArabic
            ? 'لا يمكن أن يكون موقع المصدر والوجهة متطابقين!'
            : 'Source and destination locations cannot be identical!',
        isError: true,
      );
      return;
    }

    if (_items.isEmpty) {
      _showToast(
        isArabic
            ? 'يرجى إضافة صنف واحد على الأقل للتحويل!'
            : 'Please add at least one line item to transfer!',
        isError: true,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final remarksList = <String>[];
      if (_driverNameController.text.trim().isNotEmpty) {
        remarksList.add('${isArabic ? "السائق: " : "Driver: "}${_driverNameController.text.trim()}');
      }
      if (_vehicleNoController.text.trim().isNotEmpty) {
        remarksList.add('${isArabic ? "المركبة/التتبع: " : "Vehicle/Tracking: "}${_vehicleNoController.text.trim()}');
      }
      if (_remarksController.text.trim().isNotEmpty) {
        remarksList.add(_remarksController.text.trim());
      }

      final payload = {
        'transferNumber': _transferNoController.text.trim(),
        'fromWarehouseId': _sourceLocation!.id,
        'fromWarehouseName': _sourceLocation!.name,
        'toWarehouseId': _destinationLocation!.id,
        'toWarehouseName': _destinationLocation!.name,
        'status': _status,
        'transferDate': _transferDate.toIso8601String(),
        'remarks': remarksList.join(' | '),
        'items': _items.map((i) => {
          'productId': i.product.id,
          'productName': i.product.name,
          'quantity': i.quantity,
          'unitPrice': i.unitPrice,
          'sku': i.product.sku ?? '',
        }).toList(),
      };

      await ref.read(inventoryTransferServiceProvider).createTransfer(payload);
      ref.invalidate(inventoryTransfersProvider);
      ref.invalidate(productsProvider);

      if (mounted) {
        _showToast(
          isArabic
              ? '✅ تم إنشاء وتأكيد تحويل المخزون رقم ${_transferNoController.text} بنجاح!'
              : '✅ Stock transfer #${_transferNoController.text} created and confirmed successfully!',
          isError: false,
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        _showToast(
          '${isArabic ? "فشل إنشاء التحويل: " : "Failed to create transfer: "}$e',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final currency = isArabic ? 'ر.س ' : 'SAR ';

    final warehousesAsync = ref.watch(warehousesProvider);
    final branchesAsync = ref.watch(branchesProvider);
    final productsAsync = ref.watch(productsProvider);

    final locations = _extractLocations(
      warehousesAsync.valueOrNull ?? [],
      branchesAsync.valueOrNull ?? [],
      isArabic,
    );

    // Initial default locations if none selected yet
    if (_sourceLocation == null && locations.isNotEmpty) {
      _sourceLocation = locations.first;
    }
    if (_destinationLocation == null && locations.length > 1) {
      _destinationLocation = locations[1];
    }

    final totalLineCount = _items.length;
    final totalUnits = _items.fold<double>(0.0, (sum, i) => sum + i.quantity);
    final totalValuation = _items.fold<double>(0.0, (sum, i) => sum + i.subtotal);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: isArabic ? 'رجوع' : 'Back',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  isArabic ? 'إنشاء تحويل مخزون جديد' : 'New Multi-Location Transfer',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isArabic ? 'بين الفروع والمستودعات' : 'Inter-Branch & Depot',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              isArabic
                  ? 'نقل البضائع والمخزون بين المواقع مع فحص فوري للأرصدة وتتبع الشحنة'
                  : 'Transfer merchandise between hubs with real-time stock balances & logistics tracking',
              style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
          ],
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, size: 18),
            label: Text(isArabic ? 'إلغاء' : 'Cancel'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton.icon(
            onPressed: _isSubmitting ? null : () => _submitTransfer(isArabic),
            icon: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.send_rounded, size: 18),
            label: Text(
              _status == 'IN_TRANSIT'
                  ? (isArabic ? 'تأكيد وشحن (قيد النقل)' : 'Confirm & Dispatch')
                  : (_status == 'PENDING'
                      ? (isArabic ? 'حفظ كمسودة معلقة' : 'Save as Draft')
                      : (isArabic ? 'تنفيذ التحويل الفوري' : 'Complete Transfer')),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. SMART ROUTE VISUALIZER & LOCATIONS PICKER CARD
              _buildRouteSelectorCard(context, theme, locations, isArabic),
              const SizedBox(height: 16),

              // 2. LOGISTICS & TRANSFER DETAILS CARD
              _buildLogisticsCard(context, theme, isArabic),
              const SizedBox(height: 16),

              // 3. PRODUCT SEARCH & SELECTION BAR
              _buildProductSearchDropdown(context, theme, productsAsync, isArabic),
              const SizedBox(height: 16),

              // 4. ITEMS BATCH TABLE & SUMMARY
              _buildTransferItemsTable(context, theme, currency, isArabic),
              const SizedBox(height: 16),

              // 5. KPI SUMMARY & CONFIRMATION ACTION
              _buildBottomSummaryCard(context, theme, currency, totalLineCount, totalUnits, totalValuation, isArabic),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 1. ROUTE VISUALIZER & LOCATION DROPDOWNS
  // ==========================================
  Widget _buildRouteSelectorCard(
    BuildContext context,
    ThemeData theme,
    List<_TransferLocationOption> locations,
    bool isArabic,
  ) {
    final isSourceAndDestSame = _sourceLocation != null &&
        _destinationLocation != null &&
        _sourceLocation!.id == _destinationLocation!.id;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSourceAndDestSame ? Colors.red.shade400 : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: isSourceAndDestSame ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.alt_route_rounded, color: theme.colorScheme.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  isArabic ? 'مسار التحويل والمواقع (المصدر ➔ الوجهة)' : 'Transfer Route & Locations (Origin ➔ Destination)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              isArabic
                  ? 'اختر الموقع المصدر الذي ستخصم منه البضائع، وموقع الوجهة الذي سيستلم الشحنة'
                  : 'Select the origin location where stock will be deducted, and the destination warehouse or branch',
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 20),

            // Responsive Origin / Arrow / Destination layout
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;

                final sourceDropdown = _buildLocationDropdown(
                  title: isArabic ? 'من: موقع المصدر *' : 'From: Source Origin *',
                  icon: Icons.store_mall_directory_rounded,
                  iconColor: Colors.blue.shade700,
                  value: _sourceLocation,
                  locations: locations,
                  excludeId: _destinationLocation?.id,
                  onChanged: (val) => setState(() => _sourceLocation = val),
                  isArabic: isArabic,
                );

                final swapBtn = Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      tooltip: isArabic ? 'عكس المصدر والوجهة' : 'Swap Origin & Destination',
                      icon: const Icon(Icons.swap_horiz_rounded),
                      color: theme.colorScheme.primary,
                      onPressed: _swapLocations,
                    ),
                  ),
                );

                final destDropdown = _buildLocationDropdown(
                  title: isArabic ? 'إلى: موقع الوجهة المستلمة *' : 'To: Destination Location *',
                  icon: Icons.warehouse_rounded,
                  iconColor: Colors.teal.shade700,
                  value: _destinationLocation,
                  locations: locations,
                  excludeId: _sourceLocation?.id,
                  onChanged: (val) => setState(() => _destinationLocation = val),
                  isArabic: isArabic,
                );

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: sourceDropdown),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: swapBtn,
                      ),
                      Expanded(child: destDropdown),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      sourceDropdown,
                      const SizedBox(height: 10),
                      swapBtn,
                      const SizedBox(height: 10),
                      destDropdown,
                    ],
                  );
                }
              },
            ),

            if (isSourceAndDestSame) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isArabic
                            ? 'تنبيه: لا يمكن اختيار نفس المستودع كمصدر ووجهة لنفس عملية التحويل.'
                            : 'Warning: Origin and destination location cannot be the same for an inventory transfer.',
                        style: TextStyle(color: Colors.red.shade800, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDropdown({
    required String title,
    required IconData icon,
    required Color iconColor,
    required _TransferLocationOption? value,
    required List<_TransferLocationOption> locations,
    required String? excludeId,
    required ValueChanged<_TransferLocationOption?> onChanged,
    required bool isArabic,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<_TransferLocationOption>(
              isExpanded: true,
              value: locations.contains(value) ? value : (locations.isNotEmpty ? locations.first : null),
              icon: const Icon(Icons.arrow_drop_down_circle_outlined),
              items: locations.map((loc) {
                final isExcluded = loc.id == excludeId;
                return DropdownMenuItem<_TransferLocationOption>(
                  value: loc,
                  enabled: !isExcluded,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: loc.type == 'WAREHOUSE'
                              ? Colors.indigo.withValues(alpha: 0.12)
                              : Colors.teal.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          loc.type == 'WAREHOUSE'
                              ? (isArabic ? 'مستودع' : 'Warehouse')
                              : (isArabic ? 'فرع' : 'Branch'),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: loc.type == 'WAREHOUSE' ? Colors.indigo : Colors.teal,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          loc.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isExcluded ? Colors.grey : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (loc.subtitle != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          loc.subtitle!,
                          style: TextStyle(fontSize: 11, color: theme.colorScheme.outline),
                        ),
                      ],
                      if (isExcluded) ...[
                        const SizedBox(width: 6),
                        Text(
                          isArabic ? '(محدد حالياً)' : '(Current)',
                          style: const TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. LOGISTICS, DATE & STATUS CARD
  // ==========================================
  Widget _buildLogisticsCard(BuildContext context, ThemeData theme, bool isArabic) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_shipping_outlined, color: theme.colorScheme.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  isArabic ? 'تفاصيل النقل والشحنة والتوثيق' : 'Logistics, Shipping & Transfer Details',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),

            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;

                final transferNoField = TextFormField(
                  controller: _transferNoController,
                  decoration: InputDecoration(
                    labelText: isArabic ? 'رقم وثيقة التحويل *' : 'Transfer Document # *',
                    prefixIcon: const Icon(Icons.tag),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? (isArabic ? 'يرجى إدخال رقم التحويل' : 'Transfer # is required')
                      : null,
                );

                final dateField = InkWell(
                  onTap: _pickTransferDate,
                  borderRadius: BorderRadius.circular(10),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: isArabic ? 'تاريخ التحويل *' : 'Transfer Date *',
                      prefixIcon: const Icon(Icons.calendar_today_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      DateFormat('yyyy-MM-dd').format(_transferDate),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                );

                final statusField = DropdownButtonFormField<String>(
                  value: _status,
                  decoration: InputDecoration(
                    labelText: isArabic ? 'حالة التحويل *' : 'Transfer Status *',
                    prefixIcon: const Icon(Icons.donut_large_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'COMPLETED',
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                          const SizedBox(width: 8),
                          Text(isArabic ? 'مكتمل ومستلم فوري' : 'Completed (Direct Transfer)'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'IN_TRANSIT',
                      child: Row(
                        children: [
                          const Icon(Icons.directions_boat_filled_rounded, color: Colors.blue, size: 18),
                          const SizedBox(width: 8),
                          Text(isArabic ? 'قيد النقل بالطريق' : 'In Transit (En Route)'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'PENDING',
                      child: Row(
                        children: [
                          const Icon(Icons.hourglass_top_rounded, color: Colors.amber, size: 18),
                          const SizedBox(width: 8),
                          Text(isArabic ? 'معلق / بانتظار الموافقة' : 'Pending Approval / Draft'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _status = val);
                  },
                );

                if (isWide) {
                  return Row(
                    children: [
                      Expanded(child: transferNoField),
                      const SizedBox(width: 14),
                      Expanded(child: dateField),
                      const SizedBox(width: 14),
                      Expanded(child: statusField),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      transferNoField,
                      const SizedBox(height: 12),
                      dateField,
                      const SizedBox(height: 12),
                      statusField,
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 14),

            // Driver / Courier & Vehicle info
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;

                final driverField = TextField(
                  controller: _driverNameController,
                  decoration: InputDecoration(
                    labelText: isArabic ? 'اسم السائق / شركة الشحن' : 'Driver / Carrier Name',
                    prefixIcon: const Icon(Icons.person_pin_circle_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );

                final vehicleField = TextField(
                  controller: _vehicleNoController,
                  decoration: InputDecoration(
                    labelText: isArabic ? 'رقم اللوحة / بوليصة الشحن (Waybill)' : 'Vehicle Plate / Waybill #',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );

                if (isWide) {
                  return Row(
                    children: [
                      Expanded(child: driverField),
                      const SizedBox(width: 14),
                      Expanded(child: vehicleField),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      driverField,
                      const SizedBox(height: 12),
                      vehicleField,
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 14),

            TextField(
              controller: _remarksController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: isArabic ? 'ملاحظات وتوجيهات الشحنة / سبب التحويل' : 'Transfer Notes / Shipping Reason / Remarks',
                prefixIcon: const Icon(Icons.notes_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 3. PRODUCT DROPDOWN & LIVE STOCK SEARCH
  // ==========================================
  Widget _buildProductSearchDropdown(
    BuildContext context,
    ThemeData theme,
    AsyncValue<List<ProductModel>> productsAsync,
    bool isArabic,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.add_shopping_cart_rounded, color: theme.colorScheme.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  isArabic ? 'إضافة أصناف إلى شحنة التحويل' : 'Add Items to Transfer Batch',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                productsAsync.maybeWhen(
                  data: (catalog) => Text(
                    '${catalog.length} ${isArabic ? "صنف متاح" : "items loaded"}',
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              isArabic
                  ? 'ابحث بالاسم، رمز SKU أو الباركود؛ يتم جلب تفاصيل المخزون الفعلي تلقائياً'
                  : 'Search by product name, SKU, or barcode; live stock balances will be verified',
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 16),

            productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.amber),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isArabic
                                ? 'لا توجد منتجات مسجلة في الكتالوج. يمكنك إضافة منتجات من قسم المخزون أولاً.'
                                : 'No products found in the catalog. Please add inventory products first.',
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 700;

                    final productDropdown = Autocomplete<ProductModel>(
                      displayStringForOption: (option) => '${option.name} (${option.sku ?? ""})',
                      optionsBuilder: (textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return products.take(15);
                        }
                        final q = textEditingValue.text.toLowerCase();
                        return products.where((p) {
                          final nameMatch = p.name.toLowerCase().contains(q);
                          final skuMatch = p.sku?.toLowerCase().contains(q) ?? false;
                          final barcodeMatch = p.barcode?.toLowerCase().contains(q) ?? false;
                          return nameMatch || skuMatch || barcodeMatch;
                        }).take(20);
                      },
                      onSelected: (ProductModel selected) {
                        setState(() {
                          _selectedProductToAdd = selected;
                        });
                      },
                      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          onEditingComplete: onEditingComplete,
                          decoration: InputDecoration(
                            hintText: isArabic
                                ? '🔍 ابحث عن الصنف بالاسم أو الرمز...'
                                : '🔍 Search product name, SKU or barcode...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: controller.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      controller.clear();
                                      setState(() => _selectedProductToAdd = null);
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 6,
                            borderRadius: BorderRadius.circular(12),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: constraints.maxWidth,
                                maxHeight: 300,
                              ),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  final option = options.elementAt(index);
                                  final stock = option.stockQuantity > 0 ? option.stockQuantity : option.stockInHand;
                                  final isLowStock = stock <= 0;

                                  return ListTile(
                                    dense: true,
                                    leading: CircleAvatar(
                                      radius: 16,
                                      backgroundColor: isLowStock
                                          ? Colors.red.withValues(alpha: 0.15)
                                          : Colors.green.withValues(alpha: 0.15),
                                      child: Icon(
                                        Icons.inventory_2_outlined,
                                        size: 16,
                                        color: isLowStock ? Colors.red : Colors.green,
                                      ),
                                    ),
                                    title: Text(option.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text(
                                      'SKU: ${option.sku ?? "N/A"}${option.barcode != null ? " | Barcode: ${option.barcode}" : ""}',
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isLowStock
                                            ? Colors.red.withValues(alpha: 0.1)
                                            : Colors.green.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${isArabic ? "المخزون: " : "Stock: "}$stock',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: isLowStock ? Colors.red.shade800 : Colors.green.shade800,
                                        ),
                                      ),
                                    ),
                                    onTap: () => onSelected(option),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    );

                    final qtyField = SizedBox(
                      width: isWide ? 120 : double.infinity,
                      child: TextField(
                        controller: _quickQtyController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: isArabic ? 'الكمية' : 'Quantity',
                          prefixIcon: const Icon(Icons.numbers, size: 18),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    );

                    final addBtn = FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.add, size: 20),
                      label: Text(isArabic ? 'إضافة للتحويل' : 'Add to Transfer'),
                      onPressed: () {
                        if (_selectedProductToAdd == null) {
                          _showToast(
                            isArabic ? 'يرجى اختيار منتج من القائمة أولاً' : 'Please select a product from search first',
                            isError: true,
                          );
                          return;
                        }
                        final q = double.tryParse(_quickQtyController.text) ?? 1.0;
                        _addItemToTransfer(_selectedProductToAdd!, q);
                      },
                    );

                    if (isWide) {
                      return Row(
                        children: [
                          Expanded(child: productDropdown),
                          const SizedBox(width: 12),
                          qtyField,
                          const SizedBox(width: 12),
                          addBtn,
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          productDropdown,
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(child: qtyField),
                              const SizedBox(width: 10),
                              addBtn,
                            ],
                          ),
                        ],
                      );
                    }
                  },
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, stack) => Text('Error loading products catalog: $err'),
            ),

            if (_selectedProductToAdd != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: theme.colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${isArabic ? "تم اختيار: " : "Selected: "}${_selectedProductToAdd!.name} | SKU: ${_selectedProductToAdd!.sku ?? "-"} | '
                        '${isArabic ? "المخزون الحالي: " : "Current Stock: "}${_selectedProductToAdd!.stockQuantity > 0 ? _selectedProductToAdd!.stockQuantity : _selectedProductToAdd!.stockInHand}',
                        style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onPrimaryContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 4. ITEMS BATCH TABLE & CARD
  // ==========================================
  Widget _buildTransferItemsTable(
    BuildContext context,
    ThemeData theme,
    String currency,
    bool isArabic,
  ) {
    if (_items.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6)),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          alignment: Alignment.center,
          child: Column(
            children: [
              Icon(Icons.inventory_outlined, size: 54, color: theme.colorScheme.outline.withValues(alpha: 0.6)),
              const SizedBox(height: 12),
              Text(
                isArabic ? 'لم تتم إضافة أي أصناف بعد' : 'No Items Added to This Transfer',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                isArabic
                    ? 'استخدم شريط البحث بالأعلى لاختيار المنتجات وإدراجها في قائمة التحويل'
                    : 'Use the product search bar above to add items to your transfer manifest',
                style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.list_alt_rounded, color: theme.colorScheme.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  isArabic ? 'قائمة الأصناف المحولة (${_items.length})' : 'Transfer Line Items (${_items.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => setState(() => _items.clear()),
                  icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red, size: 18),
                  label: Text(
                    isArabic ? 'مسح الكل' : 'Clear All',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              separatorBuilder: (context, index) => const Divider(height: 20),
              itemBuilder: (context, index) {
                final item = _items[index];
                final p = item.product;
                final availableStock = p.stockQuantity > 0 ? p.stockQuantity : p.stockInHand;
                final isExceedingStock = item.quantity > availableStock && availableStock > 0;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Item index pill
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Product details
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                'SKU: ${p.sku ?? "N/A"}',
                                style: TextStyle(fontSize: 11, color: theme.colorScheme.outline),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: isExceedingStock
                                      ? Colors.red.withValues(alpha: 0.15)
                                      : Colors.green.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${isArabic ? "المتوفر: " : "Available: "}$availableStock',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isExceedingStock ? Colors.red.shade800 : Colors.green.shade800,
                                  ),
                                ),
                              ),
                              if (isExceedingStock) ...[
                                const SizedBox(width: 6),
                                Text(
                                  isArabic ? '⚠️ يتجاوز المخزون' : '⚠️ Exceeds stock',
                                  style: const TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Stepper Quantity Control
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.outlineVariant),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 16),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            onPressed: () {
                              setState(() {
                                if (item.quantity > 1) {
                                  item.quantity -= 1;
                                } else {
                                  _items.removeAt(index);
                                }
                              });
                            },
                          ),
                          Container(
                            constraints: const BoxConstraints(minWidth: 40),
                            alignment: Alignment.center,
                            child: Text(
                              item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 2),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 16),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            onPressed: () {
                              setState(() {
                                item.quantity += 1;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Valuation
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$currency${item.subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            '${item.quantity} × $currency${item.unitPrice.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 11, color: theme.colorScheme.outline),
                          ),
                        ],
                      ),
                    ),

                    // Delete item
                    IconButton(
                      icon: const Icon(Icons.close, size: 18, color: Colors.redAccent),
                      tooltip: isArabic ? 'حذف' : 'Remove',
                      onPressed: () => setState(() => _items.removeAt(index)),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 5. BOTTOM SUMMARY & ACTIONS
  // ==========================================
  Widget _buildBottomSummaryCard(
    BuildContext context,
    ThemeData theme,
    String currency,
    int count,
    double units,
    double valuation,
    bool isArabic,
  ) {
    return Card(
      elevation: 2,
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                _buildKpiCell(
                  theme: theme,
                  label: isArabic ? 'إجمالي الأصناف' : 'Total Items',
                  value: '$count',
                  icon: Icons.category_outlined,
                ),
                _buildDivider(theme),
                _buildKpiCell(
                  theme: theme,
                  label: isArabic ? 'إجمالي الوحدات' : 'Total Units',
                  value: units.toStringAsFixed(units.truncateToDouble() == units ? 0 : 2),
                  icon: Icons.numbers_outlined,
                ),
                _buildDivider(theme),
                _buildKpiCell(
                  theme: theme,
                  label: isArabic ? 'القيمة التقديرية' : 'Est. Total Value',
                  value: '$currency${valuation.toStringAsFixed(2)}',
                  icon: Icons.monetization_on_outlined,
                  highlight: true,
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(isArabic ? 'إلغاء' : 'Cancel'),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _isSubmitting ? null : () => _submitTransfer(isArabic),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    isArabic ? 'تأكيد وإصدار إذن التحويل' : 'Confirm & Dispatch Transfer',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCell({
    required ThemeData theme,
    required String label,
    required String value,
    required IconData icon,
    bool highlight = false,
  }) {
    return Expanded(
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: highlight
                ? theme.colorScheme.primary.withValues(alpha: 0.15)
                : theme.colorScheme.surfaceContainerHighest,
            child: Icon(
              icon,
              size: 18,
              color: highlight ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: theme.colorScheme.outline),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: highlight ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Container(
      height: 36,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
    );
  }
}
