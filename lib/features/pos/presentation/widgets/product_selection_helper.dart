import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/product_model.dart';
import '../../providers/pos_provider.dart';

class ProductSelectionHelper {
  static Future<void> handleProductSelection(
    BuildContext context, 
    WidgetRef ref, 
    ProductModel product, {
    ProductUnitModel? unit,
    String? batchNumber,
    String? expiryDate,
    String? modifiers,
    double? measuredWeightKg,
    String? assignedStaff,
  }) async {
    // Modals for variants or other features could be triggered here if the backend provided these properties.
    // For now, we proceed directly to stock validation.

    // Stock Validation
    final int currentCartQty = ref.read(cartProvider).where((item) => item.product.id == product.id).fold(0, (sum, item) => sum + item.quantity);
    final int requestedQty = currentCartQty + 1;
    final int resultingStock = product.stockQuantity - requestedQty;

    if (product.stockQuantity <= 0 || resultingStock < 0) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot add item. "${product.name}" is out of stock! (Available: ${product.stockQuantity})'), 
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Resolve specialized business metadata
    final resolvedBatch = batchNumber ??
        ((product.requiresBatchTracking || product.isMedicine)
            ? 'LOT-${(DateTime.now().millisecondsSinceEpoch % 90000) + 10000}'
            : null);
    final resolvedExpiry = expiryDate ?? (product.isMedicine ? '12/28' : null);
    final resolvedWeight = measuredWeightKg ?? (product.isWeightBased ? (product.weight > 0 ? product.weight : 1.0) : null);

    // Add to cart with specialized tracking metadata
    ref.read(cartProvider.notifier).addProduct(
      product,
      unit: unit,
      batchNumber: resolvedBatch,
      expiryDate: resolvedExpiry,
      modifiers: modifiers,
      measuredWeightKg: resolvedWeight,
      assignedStaff: assignedStaff,
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (resultingStock <= product.minStockLevel) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text('Added "${product.name}" (Low stock: $resultingStock left)')),
            ],
          ),
          duration: const Duration(milliseconds: 1500),
          backgroundColor: Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text('Added "${product.name}" to cart')),
            ],
          ), 
          duration: const Duration(milliseconds: 900),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

