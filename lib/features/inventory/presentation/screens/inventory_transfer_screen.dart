import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app.dart';
import '../../domain/transfer_models.dart';
import '../../providers/inventory_transfer_provider.dart';
import 'create_inventory_transfer_screen.dart';

class InventoryTransferScreen extends ConsumerStatefulWidget {
  const InventoryTransferScreen({super.key});

  @override
  ConsumerState<InventoryTransferScreen> createState() => _InventoryTransferScreenState();
}

class _InventoryTransferScreenState extends ConsumerState<InventoryTransferScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'تحويلات وتعديلات المخزون' : 'Inventory Transfers & Adjustments'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: const Icon(Icons.swap_horiz), text: isArabic ? 'التحويلات بين الفروع' : 'Multi-Location Transfers'),
            Tab(icon: const Icon(Icons.tune), text: isArabic ? 'تعديلات المخزون للمدير' : 'Manager Stock Adjustments'),
          ],
        ),
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
            onPressed: () {
              ref.invalidate(inventoryTransfersProvider);
              ref.invalidate(inventoryAdjustmentsProvider);
            },
            tooltip: isArabic ? 'تحديث' : 'Refresh',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransfersTab(context, theme, isArabic),
          _buildAdjustmentsTab(context, theme, isArabic),
        ],
      ),
    );
  }

  Widget _buildTransfersTab(BuildContext context, ThemeData theme, bool isArabic) {
    final transfersAsync = ref.watch(inventoryTransfersProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: isArabic ? 'بحث برقم التحويل، المصدر، أو الوجهة...' : 'Search transfer #, source, or destination...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.add_shopping_cart),
                label: Text(isArabic ? 'تحويل جديد' : 'New Transfer', style: const TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreateInventoryTransferScreen(),
                    ),
                  ).then((_) {
                    ref.invalidate(inventoryTransfersProvider);
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: transfersAsync.when(
            data: (transfers) {
              final filtered = transfers.where((t) {
                return t.transferNumber.toLowerCase().contains(_searchQuery) ||
                    t.fromWarehouseName.toLowerCase().contains(_searchQuery) ||
                    t.toWarehouseName.toLowerCase().contains(_searchQuery);
              }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.swap_horiz, size: 64, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      Text(
                        isArabic ? 'لم يتم العثور على تحويلات مخزون.' : 'No stock transfers found.',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: Text(isArabic ? 'إنشاء أول تحويل بين الفروع' : 'Create First Transfer'),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const CreateInventoryTransferScreen(),
                            ),
                          ).then((_) {
                            ref.invalidate(inventoryTransfersProvider);
                          });
                        },
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final t = filtered[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
                    ),
                    elevation: 1,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _showTransferDetailsDialog(context, t, isArabic),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: theme.colorScheme.primaryContainer,
                                  child: Icon(Icons.alt_route, color: theme.colorScheme.primary, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Text(t.transferNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                const SizedBox(width: 10),
                                _buildStatusBadge(t.status, isArabic),
                                const Spacer(),
                                Text(
                                  DateFormat('yyyy-MM-dd').format(t.transferDate),
                                  style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.storefront_rounded, size: 16, color: Colors.blue.shade700),
                                  const SizedBox(width: 6),
                                  Text(t.fromWarehouseName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Icon(Icons.warehouse_rounded, size: 16, color: Colors.teal.shade700),
                                  const SizedBox(width: 6),
                                  Text(t.toWarehouseName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            if (t.remarks != null && t.remarks!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                t.remarks!,
                                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                              ),
                            ],
                            if (t.items.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                '${isArabic ? "الأصناف المحولة: " : "Transferred Items: "}${t.items.map((i) => "${i.productName} (${i.quantity})").join(", ")}',
                                style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('${isArabic ? "خطأ في تحميل التحويلات: " : "Error loading transfers: "}$err')),
          ),
        ),
      ],
    );
  }

  Widget _buildAdjustmentsTab(BuildContext context, ThemeData theme, bool isArabic) {
    final adjustmentsAsync = ref.watch(inventoryAdjustmentsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: isArabic ? 'بحث برقم التعديل، المستودع، أو السبب...' : 'Search adjustment #, warehouse, or reason...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: theme.colorScheme.onSecondary,
                ),
                icon: const Icon(Icons.build),
                label: Text(isArabic ? 'تعديل جديد' : 'New Adjustment'),
                onPressed: () => _showCreateAdjustmentDialog(context, isArabic),
              ),
            ],
          ),
        ),
        Expanded(
          child: adjustmentsAsync.when(
            data: (adjustments) {
              final filtered = adjustments.where((a) {
                return a.adjustmentNumber.toLowerCase().contains(_searchQuery) ||
                    a.warehouseName.toLowerCase().contains(_searchQuery) ||
                    a.reason.toLowerCase().contains(_searchQuery);
              }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Text(isArabic ? 'لم يتم العثور على تعديلات مخزون.' : 'No stock adjustments found.'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final a = filtered[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.secondaryContainer,
                        child: Icon(Icons.edit_attributes, color: theme.colorScheme.secondary),
                      ),
                      title: Row(
                        children: [
                          Text(a.adjustmentNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                            child: Text('${isArabic ? "السبب: " : "Reason: "}${a.reason}', style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${isArabic ? "الموقع: " : "Location: "}${a.warehouseName} | ${isArabic ? "المدير: " : "Manager: "}${a.adjustedBy} | ${isArabic ? "التاريخ: " : "Date: "}${DateFormat('yyyy-MM-dd').format(a.adjustmentDate)}'),
                            if (a.items.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                '${isArabic ? "العناصر المعدلة: " : "Adjusted Items: "}${a.items.map((i) => "${i.productName} (${i.adjustmentType == 'ADD' ? '+' : '-'}${i.quantity})").join(", ")}',
                                style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('${isArabic ? "خطأ في تحميل التعديلات: " : "Error loading adjustments: "}$err')),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status, bool isArabic) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    switch (status.toUpperCase()) {
      case 'COMPLETED':
        bg = Colors.green.withValues(alpha: 0.15);
        fg = Colors.green.shade800;
        label = isArabic ? 'مكتمل' : 'Completed';
        icon = Icons.check_circle_outline;
        break;
      case 'IN_TRANSIT':
        bg = Colors.blue.withValues(alpha: 0.15);
        fg = Colors.blue.shade800;
        label = isArabic ? 'قيد النقل' : 'In Transit';
        icon = Icons.local_shipping_outlined;
        break;
      case 'PENDING':
      default:
        bg = Colors.amber.withValues(alpha: 0.15);
        fg = Colors.amber.shade900;
        label = isArabic ? 'معلق' : 'Pending';
        icon = Icons.schedule;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 11)),
        ],
      ),
    );
  }

  void _showTransferDetailsDialog(BuildContext context, InventoryTransferModel t, bool isArabic) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.alt_route_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${isArabic ? "تفاصيل التحويل: " : "Transfer Details: "}${t.transferNumber}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            _buildStatusBadge(t.status, isArabic),
          ],
        ),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Route info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(isArabic ? 'المصدر (من)' : 'Origin (From)', style: TextStyle(fontSize: 11, color: theme.colorScheme.outline)),
                            Text(t.fromWarehouseName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.grey),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(isArabic ? 'الوجهة (إلى)' : 'Destination (To)', style: TextStyle(fontSize: 11, color: theme.colorScheme.outline)),
                            Text(t.toWarehouseName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${isArabic ? "تاريخ التحويل: " : "Date: "}${DateFormat('yyyy-MM-dd').format(t.transferDate)}'
                  '${t.remarks != null && t.remarks!.isNotEmpty ? "\n${isArabic ? "ملاحظات: " : "Remarks: "}${t.remarks}" : ""}',
                  style: const TextStyle(fontSize: 13),
                ),
                const Divider(height: 24),
                Text(
                  isArabic ? 'الأصناف المحولة في الشحنة:' : 'Items Included in Transfer:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (t.items.isEmpty)
                  Text(isArabic ? 'لا توجد عناصر مسجلة.' : 'No line items recorded.')
                else
                  ...t.items.map((i) => Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.inventory_2_outlined, size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(i.productName, style: const TextStyle(fontWeight: FontWeight.w600))),
                            Text(
                              '${i.quantity} ${isArabic ? "وحدة" : "units"}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )),
              ],
            ),
          ),
        ),
        actions: [
          if (t.status != 'COMPLETED') ...[
            FilledButton.icon(
              icon: const Icon(Icons.done_all_rounded, size: 16),
              label: Text(isArabic ? 'تأكيد الاستلام كـ مكتمل' : 'Mark as Completed / Received'),
              onPressed: () async {
                try {
                  await ref.read(inventoryTransferServiceProvider).updateTransferStatus(t.id, 'COMPLETED');
                  ref.invalidate(inventoryTransfersProvider);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isArabic ? 'تم تحديث حالة التحويل إلى مكتمل بنجاح!' : 'Transfer marked as completed!')),
                    );
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
            ),
          ],
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(isArabic ? 'إغلاق' : 'Close'),
          ),
        ],
      ),
    );
  }

  void _showCreateAdjustmentDialog(BuildContext context, bool isArabic) {
    final warehouseController = TextEditingController(text: isArabic ? 'المستودع الرئيسي' : 'Main Warehouse');
    String reason = 'AUDIT_CORRECTION';
    String adjType = 'SUBTRACT';
    final productController = TextEditingController(text: isArabic ? 'صنف SKU-001' : 'Item SKU-001');
    final qtyController = TextEditingController(text: '2');
    final remarksController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text(isArabic ? 'تسجيل تعديل مخزون بواسطة المدير' : 'Record Manager Stock Adjustment'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 450,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: warehouseController,
                    decoration: InputDecoration(labelText: isArabic ? 'المستودع / الموقع *' : 'Warehouse / Location *'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: reason,
                    decoration: InputDecoration(labelText: isArabic ? 'سبب التعديل' : 'Adjustment Reason'),
                    items: [
                      DropdownMenuItem(value: 'AUDIT_CORRECTION', child: Text(isArabic ? 'تصحيح الجرد' : 'Audit Correction')),
                      DropdownMenuItem(value: 'DAMAGED', child: Text(isArabic ? 'بضائع تالفة' : 'Damaged Goods')),
                      DropdownMenuItem(value: 'EXPIRED', child: Text(isArabic ? 'بضائع منتهية الصلاحية' : 'Expired Goods')),
                      DropdownMenuItem(value: 'THEFT', child: Text(isArabic ? 'عجز / سرقة' : 'Shrinkage / Theft')),
                      DropdownMenuItem(value: 'OTHER', child: Text(isArabic ? 'أخرى' : 'Other')),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => reason = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: adjType,
                    decoration: InputDecoration(labelText: isArabic ? 'نوع التعديل' : 'Adjustment Type'),
                    items: [
                      DropdownMenuItem(value: 'SUBTRACT', child: Text(isArabic ? 'خصم / تقليل المخزون (-)' : 'Subtract / Reduce Stock (-)')),
                      DropdownMenuItem(value: 'ADD', child: Text(isArabic ? 'إضافة / زيادة المخزون (+)' : 'Add / Increase Stock (+)')),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => adjType = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: productController,
                          decoration: InputDecoration(labelText: isArabic ? 'اسم المنتج / رمز SKU *' : 'Product Name / SKU *'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 90,
                        child: TextField(
                          controller: qtyController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: isArabic ? 'الكمية' : 'Qty'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: remarksController,
                    decoration: InputDecoration(labelText: isArabic ? 'ملاحظات موافقة المدير' : 'Manager Approval Notes'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(isArabic ? 'إلغاء' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final qty = double.tryParse(qtyController.text) ?? 1.0;
                final payload = {
                  'warehouseId': warehouseController.text.trim(),
                  'warehouseName': warehouseController.text.trim(),
                  'reason': reason,
                  'adjustedBy': isArabic ? 'المدير' : 'Manager',
                  'adjustmentDate': DateTime.now().toIso8601String(),
                  'remarks': remarksController.text.trim(),
                  'items': [
                    {
                      'productName': productController.text.trim().isEmpty ? (isArabic ? 'مخزون بضائع' : 'Goods Stock') : productController.text.trim(),
                      'adjustmentType': adjType,
                      'quantity': qty,
                    }
                  ],
                };

                try {
                  await ref.read(inventoryTransferServiceProvider).createAdjustment(payload);
                  ref.invalidate(inventoryAdjustmentsProvider);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isArabic ? 'تم تسجيل تعديل المخزون بنجاح!' : 'Stock adjustment recorded successfully!')),
                    );
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('${isArabic ? "فشل تسجيل التعديل: " : "Failed to record adjustment: "}$e')),
                    );
                  }
                }
              },
              child: Text(isArabic ? 'حفظ التعديل' : 'Save Adjustment'),
            ),
          ],
        ),
      ),
    );
  }
}
