import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/refund_provider.dart';

class RefundModal extends ConsumerWidget {
  const RefundModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refundState = ref.watch(refundProvider);
    final searchController = TextEditingController();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 800,
        height: 650,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: const Color(0xFF1A237E), // Deep Navy
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.assignment_return_outlined, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Process Return / Refund',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              labelText: 'Scan Receipt Barcode or Enter Invoice #',
                              labelStyle: TextStyle(color: Colors.grey.shade600),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              prefixIcon: Icon(Icons.receipt_long, color: Colors.grey.shade600),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF1A237E))),
                            ),
                            onSubmitted: (val) => ref.read(refundProvider.notifier).fetchInvoice(val),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () => ref.read(refundProvider.notifier).fetchInvoice(searchController.text),
                          icon: const Icon(Icons.search, color: Colors.white),
                          label: const Text('FETCH', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00BFA5), // Vibrant Teal
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                        )
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    if (refundState.errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF5350).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFEF5350).withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Color(0xFFEF5350)),
                            const SizedBox(width: 8),
                            Expanded(child: Text(refundState.errorMessage!, style: const TextStyle(color: Color(0xFFEF5350), fontWeight: FontWeight.w600))),
                          ],
                        ),
                      ),
                      
                    const SizedBox(height: 16),
        
                    // Invoice Details & Items
                    if (refundState.isLoading)
                      const Expanded(child: Center(child: CircularProgressIndicator(color: Color(0xFF1A237E))))
                    else if (refundState.currentInvoice != null)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Invoice: #${refundState.currentInvoice!.invoiceNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text('Orig Total: SAR ${refundState.currentInvoice!.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: ListView.separated(
                                itemCount: refundState.currentInvoice!.items.length,
                                separatorBuilder: (context, index) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final item = refundState.currentInvoice!.items[index];
                                  final returnQty = refundState.selectedReturns[item.productId] ?? 0;
                                  final isReturnable = item.maxReturnable > 0;
        
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                              const SizedBox(height: 4),
                                              Text('SAR ${item.price.toStringAsFixed(2)} | Qty: ${item.originalQuantity} | Returned: ${item.alreadyReturnedQuantity}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                            ],
                                          ),
                                        ),
                                        if (isReturnable)
                                          Container(
                                            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.remove, size: 20),
                                                  color: returnQty > 0 ? Colors.black87 : Colors.grey,
                                                  onPressed: returnQty > 0 ? () => ref.read(refundProvider.notifier).updateReturnQuantity(item.productId, returnQty - 1) : null,
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                                  child: Text('$returnQty', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.add, size: 20),
                                                  color: returnQty < item.maxReturnable ? Colors.black87 : Colors.grey,
                                                  onPressed: returnQty < item.maxReturnable ? () => ref.read(refundProvider.notifier).updateReturnQuantity(item.productId, returnQty + 1) : null,
                                                ),
                                              ],
                                            ),
                                          )
                                        else
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                                            child: const Text('Fully Returned', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search, size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text('Scan or enter an invoice number to begin', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Footer Action
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Total Refund Amount', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                      Text('SAR ${refundState.totalRefundAmount.toStringAsFixed(2)}', 
                           style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFFEF5350))), // Coral Red
                    ],
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: refundState.totalRefundAmount > 0 
                          ? () async {
                              bool success = await ref.read(refundProvider.notifier).processRefund('Customer Requested', 'Original Method');
                              if (success && context.mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                  content: Text('Refund Processed Successfully!'),
                                  backgroundColor: Color(0xFF00BFA5),
                                ));
                              }
                            }
                          : null,
                        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                        label: const Text('PROCESS REFUND', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF5350), // Coral
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
