import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/pos_provider.dart';
import '../../../inventory/providers/category_provider.dart';
import '../../domain/product_model.dart';
import 'product_selection_modal.dart';
import 'product_selection_helper.dart';
import 'add_product_dialog.dart';
import '../../../../core/providers/tenant_settings_provider.dart';

class PosProductGridPanel extends ConsumerWidget {
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final ValueNotifier<String> searchQueryNotifier;
  final ValueNotifier<String?> selectedCategoryNotifier;
  final void Function(String) onSearchSubmitted;
  final void Function(String) onSearchChanged;
  final void Function(BuildContext, WidgetRef) onHeldCartsTap;

  const PosProductGridPanel({
    super.key,
    required this.searchController,
    required this.searchFocusNode,
    required this.searchQueryNotifier,
    required this.selectedCategoryNotifier,
    required this.onSearchSubmitted,
    required this.onSearchChanged,
    required this.onHeldCartsTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(categoryProvider);
    final productsState = ref.watch(productsProvider);
    
    return Container(
              color: const Color(0xFFF8FAFC),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            focusNode: searchFocusNode,
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: 'Search Product by Name, Barcode, Brand, or SKU',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              prefixIcon: const Icon(Icons.search, color: Colors.blue),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey[200]!)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey[200]!)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.blue, width: 2)),
                            ),
                            onChanged: (val) {
                              onSearchChanged(val);
                              searchQueryNotifier.value = val.toLowerCase();
                            },
                            onSubmitted: (val) => onSearchSubmitted(val),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.search),
                          label: const Text('Advanced Search'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: BorderSide(color: Colors.grey[200]!)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          ),
                          onPressed: () => showDialog(context: context, builder: (ctx) => const ProductSelectionModal()),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Add Product'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[50],
                            foregroundColor: Colors.blue[800],
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                          onPressed: () => showDialog(context: context, builder: (ctx) => const AddProductDialog()),
                        ),
                        const SizedBox(width: 12),
                        Consumer(
                          builder: (context, ref, child) {
                            final heldCartsAsync = ref.watch(heldCartsProvider);
                            final heldCarts = heldCartsAsync.value ?? [];
                            if (heldCarts.isEmpty) return const SizedBox.shrink();
                            return ElevatedButton.icon(
                              icon: const Icon(Icons.pause_circle_filled, color: Colors.orange),
                              label: Text('Held (${heldCarts.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange[50],
                                foregroundColor: Colors.orange[800],
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              ),
                              onPressed: () => onHeldCartsTap(context, ref),
                            );
                          }
                        ),
                      ],
                    ),
                  ),
                  // Quick Categories & Product Grid
                  Expanded(
                    child: AnimatedBuilder(
                      animation: Listenable.merge([searchQueryNotifier, selectedCategoryNotifier]),
                      builder: (context, _) {
                        final selectedCat = selectedCategoryNotifier.value;
                        final query = searchQueryNotifier.value;
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: ChoiceChip(
                                        label: const Text('All Items'),
                                        selected: selectedCat == null,
                                        onSelected: (val) => selectedCategoryNotifier.value = null,
                                        selectedColor: Colors.blue[600],
                                        labelStyle: TextStyle(color: selectedCat == null ? Colors.white : Colors.black87, fontWeight: selectedCat == null ? FontWeight.bold : FontWeight.normal),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: selectedCat == null ? Colors.blue[600]! : Colors.grey[200]!)),
                                        backgroundColor: Colors.white,
                                      ),
                                    ),
                                    ...categoriesState.maybeWhen(
                                      data: (categories) => categories.map((cat) {
                                        final isSelected = selectedCat == cat.id;
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 8.0),
                                          child: ChoiceChip(
                                            label: Text(cat.name),
                                            selected: isSelected,
                                            onSelected: (val) => selectedCategoryNotifier.value = val ? cat.id : null,
                                            selectedColor: Colors.blue[600],
                                            labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? Colors.blue[600]! : Colors.grey[200]!)),
                                            backgroundColor: Colors.white,
                                          ),
                                        );
                                      }).toList(),
                                      orElse: () => [],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: productsState.when(
                                  data: (products) {
                                    final filtered = products.where((p) {
                                      final matchesSearch = p.name.toLowerCase().contains(query) ||
                                          (p.barcode != null && p.barcode!.toLowerCase().contains(query)) ||
                                          (p.brandId != null && p.brandId!.toLowerCase().contains(query)) ||
                                          (p.sku != null && p.sku!.toLowerCase().contains(query));
                                      final matchesCategory = selectedCat == null || p.categoryId == selectedCat;
                                      return matchesSearch && matchesCategory;
                                    }).toList();
                                    if (filtered.isEmpty) {
                                      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.search_off, size: 64, color: Colors.grey[300]), const SizedBox(height: 16), Text('No products found', style: TextStyle(color: Colors.grey[500], fontSize: 18))]));
                                    }
                                    return GridView.builder(
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        childAspectRatio: 0.78,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                      ),
                                      itemCount: filtered.length,
                                      itemBuilder: (context, index) {
                                        final product = filtered[index];
                                        return _ProductGridItem(product: product);
                                      },
                                    );
                                  },
                                  loading: () => const Center(child: CircularProgressIndicator()),
                                  error: (e, st) => Center(child: Text('Error: $e')),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
  }
}

class _ProductGridItem extends ConsumerStatefulWidget {
  final ProductModel product;

  const _ProductGridItem({required this.product});

  @override
  ConsumerState<_ProductGridItem> createState() => _ProductGridItemState();
}

class _ProductGridItemState extends ConsumerState<_ProductGridItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final cartItems = ref.watch(cartProvider);
    final inCartCount = cartItems
        .where((item) => item.product.id == product.id)
        .fold<int>(0, (sum, item) => sum + item.quantity);
    final isOutOfStock = product.stockQuantity <= 0;

    final primaryColor = Theme.of(context).primaryColor;
    final priceVal = double.tryParse(product.price) ?? 0.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: isOutOfStock ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered && !isOutOfStock
                ? primaryColor.withValues(alpha: 0.6)
                : (inCartCount > 0 ? primaryColor.withValues(alpha: 0.3) : Colors.grey.shade200),
            width: (inCartCount > 0 || _isHovered) ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered && !isOutOfStock
                  ? primaryColor.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: _isHovered ? 12 : 6,
              offset: Offset(0, _isHovered ? 4 : 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isOutOfStock
                ? null
                : () => ProductSelectionHelper.handleProductSelection(context, ref, product),
            splashColor: primaryColor.withValues(alpha: 0.1),
            highlightColor: primaryColor.withValues(alpha: 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top image area with in-cart badge & stock tag
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildImageArea(product),
                      if (inCartCount > 0)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.shopping_cart, size: 12, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  '$inCartCount in cart',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Tooltip(
                                  message: 'Remove from cart',
                                  child: InkWell(
                                    onTap: () {
                                      ref.read(cartProvider.notifier).removeProduct(product.id);
                                    },
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade600,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close, size: 11, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: _buildStockBadge(product),
                      ),
                    ],
                  ),
                ),

                // Bottom Content
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          height: 1.25,
                        ),
                      ),
                      Row(
                        children: [
                          if (product.barcode != null && product.barcode!.isNotEmpty)
                            Expanded(
                              child: Text(
                                product.barcode!,
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          else
                            const Spacer(),
                          if (product.isMedicine) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade50,
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(color: Colors.purple.shade200, width: 0.5),
                              ),
                              child: Text(
                                product.isPrescriptionRequired ? 'Rx' : 'OTC',
                                style: TextStyle(fontSize: 8.5, color: Colors.purple.shade800, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ] else if (product.isWeightBased) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(color: Colors.green.shade200, width: 0.5),
                              ),
                              child: Text(
                                'SCALE',
                                style: TextStyle(fontSize: 8.5, color: Colors.green.shade800, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              ref.watch(tenantSettingsProvider).formatCurrency(priceVal),
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (inCartCount > 0) ...[
                            Tooltip(
                              message: 'Remove 1 from cart',
                              child: InkWell(
                                onTap: () {
                                  final matching = cartItems.where((i) => i.product.id == product.id).toList();
                                  if (matching.isNotEmpty) {
                                    final last = matching.last;
                                    if (last.quantity > 1) {
                                      ref.read(cartProvider.notifier).updateQuantity(product.id, last.quantity - 1, unit: last.selectedUnit);
                                    } else {
                                      ref.read(cartProvider.notifier).removeProduct(product.id, unit: last.selectedUnit);
                                    }
                                  }
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red.shade200),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.remove, size: 14, color: Colors.red.shade700),
                                      const SizedBox(width: 2),
                                      Text(
                                        'Del',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          // Dedicated Add to Cart Button
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isOutOfStock
                                  ? Colors.grey.shade200
                                  : (_isHovered ? const Color(0xFF1D4ED8) : const Color(0xFF2563EB)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add_shopping_cart,
                                  size: 14,
                                  color: isOutOfStock ? Colors.grey.shade500 : Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isOutOfStock ? 'Sold Out' : 'Add',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isOutOfStock ? Colors.grey.shade500 : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStockBadge(ProductModel product) {
    Color badgeColor;
    Color textColor;
    String text;

    if (product.stockQuantity <= 0) {
      badgeColor = Colors.red.shade50;
      textColor = Colors.red.shade700;
      text = 'Out of Stock';
    } else if (product.stockQuantity <= product.minStockLevel) {
      badgeColor = Colors.orange.shade50;
      textColor = Colors.orange.shade800;
      text = 'Low: ${product.stockQuantity}';
    } else {
      badgeColor = Colors.green.shade50;
      textColor = Colors.green.shade700;
      text = '${product.stockQuantity} left';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildImageArea(ProductModel product) {
    String? imageUrl;
    if (product.images.isNotEmpty) {
      final primary = product.images.where((img) => img.isPrimary).toList();
      imageUrl = primary.isNotEmpty ? primary.first.imageUrl : product.images.first.imageUrl;
    }

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
      ),
      child: Center(
        child: Icon(Icons.inventory_2_outlined, size: 40, color: Colors.grey.shade300),
      ),
    );
  }
}
