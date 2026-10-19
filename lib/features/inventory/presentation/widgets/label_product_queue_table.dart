import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../pos/providers/pos_provider.dart';
import '../../domain/label_print_model.dart';
import '../../providers/label_printer_provider.dart';

class LabelProductQueueTable extends ConsumerWidget {
  const LabelProductQueueTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(labelQueueProvider);
    final totalCount = ref.watch(totalLabelsCountProvider);
    final settings = ref.watch(labelSettingsProvider);
    final queueNotifier = ref.read(labelQueueProvider.notifier);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                const Icon(Icons.format_list_numbered, color: Colors.indigo, size: 22),
                const SizedBox(width: 10),
                const Text(
                  'Products to Generate Labels',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.indigo.shade200),
                  ),
                  child: Text(
                    '$totalCount labels (${queue.length} items)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo.shade800),
                  ),
                ),
                const Spacer(),
                if (queue.isNotEmpty)
                  TextButton.icon(
                    icon: const Icon(Icons.delete_sweep_outlined, size: 18, color: Colors.red),
                    label: const Text('Clear All', style: TextStyle(color: Colors.red)),
                    onPressed: () => queueNotifier.clearQueue(),
                  ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 18, color: Colors.white),
                  label: const Text('Add Products', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                  onPressed: () => _showProductSelectionModal(context, ref),
                ),
              ],
            ),
            const Divider(height: 24),

            // Queue List or Empty State
            if (queue.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 36.0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.qr_code_2_outlined, size: 54, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      const Text(
                        'No products added for label printing',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Click "+ Add Products" to select items from your inventory catalog.',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Select Products Now'),
                        onPressed: () => _showProductSelectionModal(context, ref),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.indigo),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: queue.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = queue[index];
                  return _buildQueueItemRow(context, ref, item, settings, queueNotifier);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueItemRow(
    BuildContext context,
    WidgetRef ref,
    LabelItem item,
    LabelDisplaySettings settings,
    LabelQueueNotifier queueNotifier,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Product Info
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text('Barcode: ${item.barcode}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        const SizedBox(width: 12),
                        Text('Price: SAR ${item.retailPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.indigo.shade800)),
                      ],
                    ),
                  ],
                ),
              ),

              // Quantity / Copies Stepper
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Labels: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      color: Colors.grey.shade700,
                      onPressed: () {
                        if (item.copiesCount > 1) {
                          queueNotifier.updateCopies(item.productId, item.copiesCount - 1);
                        } else {
                          queueNotifier.removeProduct(item.productId);
                        }
                      },
                    ),
                    SizedBox(
                      width: 48,
                      child: Text(
                        '${item.copiesCount}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      color: Colors.indigo,
                      onPressed: () => queueNotifier.updateCopies(item.productId, item.copiesCount + 1),
                    ),
                  ],
                ),
              ),

              // Remove Button
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: 'Remove product from queue',
                onPressed: () => queueNotifier.removeProduct(item.productId),
              ),
            ],
          ),

          // Contextual Tracking Inputs (Batch, Expiry, Serial, Packing Date)
          if (settings.requireBatchNumber || settings.requireExpiryDate || settings.requireSerialNumber || settings.showPackingDate)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (settings.requireBatchNumber)
                    SizedBox(
                      width: 150,
                      height: 34,
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Batch No.',
                          isDense: true,
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        ),
                        controller: TextEditingController(text: item.batchNumber ?? '')
                          ..selection = TextSelection.collapsed(offset: (item.batchNumber ?? '').length),
                        onChanged: (val) => queueNotifier.updateBatch(item.productId, val),
                      ),
                    ),
                  if (settings.requireExpiryDate)
                    OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_month, size: 14),
                      label: Text(
                        item.expiryDate != null
                            ? 'Exp: ${item.expiryDate!.toIso8601String().split('T')[0]}'
                            : 'Set Expiry',
                        style: const TextStyle(fontSize: 12),
                      ),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: item.expiryDate ?? DateTime.now().add(const Duration(days: 365)),
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now().add(const Duration(days: 3650)),
                        );
                        if (picked != null) {
                          queueNotifier.updateExpiry(item.productId, picked);
                        }
                      },
                    ),
                  if (settings.showPackingDate)
                    OutlinedButton.icon(
                      icon: const Icon(Icons.event, size: 14),
                      label: Text(
                        item.packingDate != null
                            ? 'Pkd: ${item.packingDate!.toIso8601String().split('T')[0]}'
                            : 'Set Packing Date',
                        style: const TextStyle(fontSize: 12),
                      ),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: item.packingDate ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          queueNotifier.updatePackingDate(item.productId, picked);
                        }
                      },
                    ),
                  if (settings.requireSerialNumber)
                    SizedBox(
                      width: 140,
                      height: 34,
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Serial No.',
                          isDense: true,
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        ),
                        controller: TextEditingController(text: item.serialNumber ?? '')
                          ..selection = TextSelection.collapsed(offset: (item.serialNumber ?? '').length),
                        onChanged: (val) => queueNotifier.updateSerial(item.productId, val),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showProductSelectionModal(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => const _ProductPickerModal(),
    );
  }
}

/// Modal dialog allowing multi-select and fast addition of catalog products.
class _ProductPickerModal extends ConsumerStatefulWidget {
  const _ProductPickerModal();

  @override
  ConsumerState<_ProductPickerModal> createState() => _ProductPickerModalState();
}

class _ProductPickerModalState extends ConsumerState<_ProductPickerModal> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _search = '';
  final Set<String> _selectedProductIds = {};

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsProvider);
    final queueNotifier = ref.read(labelQueueProvider.notifier);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 600),
        child: Column(
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
              decoration: const BoxDecoration(
                color: Color(0xFF1A237E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add_shopping_cart, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  const Text(
                    'Select Products for Label Generation',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Search products by name, barcode, or SKU...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _search.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _search = '');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  isDense: true,
                ),
                onChanged: (val) => setState(() => _search = val.trim().toLowerCase()),
              ),
            ),

            // Product List
            Expanded(
              child: productsState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error loading products: $e')),
                data: (products) {
                  final filtered = products.where((p) {
                    if (_search.isEmpty) return true;
                    return p.name.toLowerCase().contains(_search) ||
                        (p.barcode?.toLowerCase().contains(_search) ?? false) ||
                        (p.sku?.toLowerCase().contains(_search) ?? false);
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('No matching products found'));
                  }

                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final p = filtered[index];
                      final isSelected = _selectedProductIds.contains(p.id);

                      return CheckboxListTile(
                        value: isSelected,
                        activeColor: Colors.indigo,
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              _selectedProductIds.add(p.id);
                            } else {
                              _selectedProductIds.remove(p.id);
                            }
                          });
                        },
                        title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text(
                          'Barcode: ${p.barcode ?? 'N/A'} • SKU: ${p.sku ?? 'N/A'} • SAR ${p.price}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        secondary: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            foregroundColor: Colors.indigo,
                          ),
                          onPressed: () {
                            queueNotifier.addProduct(p, copies: 1);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Added "${p.name}" to print queue!'), duration: const Duration(seconds: 1)),
                            );
                          },
                          child: const Text('Add 1', style: TextStyle(fontSize: 12)),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Modal Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_selectedProductIds.length} products selected',
                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check, color: Colors.white, size: 18),
                    label: const Text('Add Selected to Queue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E)),
                    onPressed: _selectedProductIds.isEmpty
                        ? null
                        : () {
                            productsState.whenData((allProducts) {
                              final selected = allProducts.where((p) => _selectedProductIds.contains(p.id)).toList();
                              queueNotifier.addMultipleProducts(selected);
                              Navigator.pop(context);
                            });
                          },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
