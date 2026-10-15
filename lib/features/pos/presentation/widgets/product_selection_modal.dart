import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/pos_provider.dart';
import 'product_selection_helper.dart';
import 'dart:async';

class ProductSelectionModal extends ConsumerStatefulWidget {
  final String initialQuery;
  const ProductSelectionModal({super.key, this.initialQuery = ''});

  @override
  ConsumerState<ProductSelectionModal> createState() => _ProductSelectionModalState();
}

class _ProductSelectionModalState extends ConsumerState<ProductSelectionModal> {
  late ValueNotifier<String> _searchQueryNotifier;
  late TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchQueryNotifier = ValueNotifier(widget.initialQuery.toLowerCase());
    _searchController = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchQueryNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 1000,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Select Product', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by Name, Barcode, Brand, or SKU...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (val) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 300), () {
                  _searchQueryNotifier.value = val.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: productsState.when(
                data: (products) {
                  return ValueListenableBuilder<String>(
                    valueListenable: _searchQueryNotifier,
                    builder: (context, query, child) {
                      final filteredProducts = products.where((p) {
                        return p.name.toLowerCase().contains(query) ||
                            (p.barcode != null && p.barcode!.toLowerCase().contains(query)) ||
                            (p.brandId != null && p.brandId!.toLowerCase().contains(query)) ||
                            (p.sku != null && p.sku!.toLowerCase().contains(query));
                      }).toList();

                      return ListView.separated(
                        itemCount: filteredProducts.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return InkWell(
                            autofocus: index == 0,
                            onTap: () {
                              Navigator.pop(context);
                              ProductSelectionHelper.handleProductSelection(context, ref, product);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)),
                                    child: const Icon(Icons.image, color: Colors.grey),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 2,
                                    child: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  Expanded(
                                    child: Text(product.barcode ?? 'N/A', style: TextStyle(color: Colors.grey[600])),
                                  ),
                                  Expanded(
                                    child: Text('SAR ${double.parse(product.price).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                  ),
                                  Expanded(
                                    child: Text('${product.stockQuantity} in stock', style: TextStyle(color: product.stockQuantity > 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
