import 'package:flutter_riverpod/flutter_riverpod.dart';

// Mock models for Refunds
class InvoiceItem {
  final String productId;
  final String productName;
  final double price;
  final int originalQuantity;
  final int alreadyReturnedQuantity;

  InvoiceItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.originalQuantity,
    this.alreadyReturnedQuantity = 0,
  });

  int get maxReturnable => originalQuantity - alreadyReturnedQuantity;
}

class Invoice {
  final String id;
  final String invoiceNumber;
  final List<InvoiceItem> items;
  final double totalAmount;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.items,
    required this.totalAmount,
  });
}

class RefundState {
  final bool isLoading;
  final String? errorMessage;
  final Invoice? currentInvoice;
  // Map of productId to quantity selected for return
  final Map<String, int> selectedReturns;

  RefundState({
    this.isLoading = false,
    this.errorMessage,
    this.currentInvoice,
    this.selectedReturns = const {},
  });

  RefundState copyWith({
    bool? isLoading,
    String? errorMessage,
    Invoice? currentInvoice,
    Map<String, int>? selectedReturns,
  }) {
    return RefundState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      currentInvoice: currentInvoice ?? this.currentInvoice,
      selectedReturns: selectedReturns ?? this.selectedReturns,
    );
  }

  double get totalRefundAmount {
    if (currentInvoice == null) return 0.0;
    double total = 0.0;
    for (var item in currentInvoice!.items) {
      int qty = selectedReturns[item.productId] ?? 0;
      total += (item.price * qty);
    }
    return total;
  }
}

class RefundNotifier extends StateNotifier<RefundState> {
  RefundNotifier() : super(RefundState());

  Future<void> fetchInvoice(String invoiceNumber) async {
    state = state.copyWith(isLoading: true, errorMessage: null, currentInvoice: null, selectedReturns: {});
    
    try {
      // TODO: Replace with real API call
      await Future.delayed(const Duration(seconds: 1)); // Mock network delay
      
      if (invoiceNumber.isEmpty) {
        throw Exception("Invoice number cannot be empty.");
      }
      
      // Mock Data
      final mockInvoice = Invoice(
        id: 'inv_123',
        invoiceNumber: invoiceNumber,
        totalAmount: 150.0,
        items: [
          InvoiceItem(productId: 'p1', productName: 'Wireless Mouse', price: 50.0, originalQuantity: 2, alreadyReturnedQuantity: 0),
          InvoiceItem(productId: 'p2', productName: 'Mechanical Keyboard', price: 100.0, originalQuantity: 1, alreadyReturnedQuantity: 1), // Fully returned
        ],
      );

      state = state.copyWith(isLoading: false, currentInvoice: mockInvoice);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void updateReturnQuantity(String productId, int quantity) {
    if (state.currentInvoice == null) return;
    
    final item = state.currentInvoice!.items.firstWhere((i) => i.productId == productId);
    
    if (quantity > item.maxReturnable) {
      // Prevent returning more than possible
      quantity = item.maxReturnable;
    }
    if (quantity < 0) quantity = 0;

    final newSelected = Map<String, int>.from(state.selectedReturns);
    if (quantity == 0) {
      newSelected.remove(productId);
    } else {
      newSelected[productId] = quantity;
    }

    state = state.copyWith(selectedReturns: newSelected);
  }

  Future<bool> processRefund(String reason, String refundMethod) async {
    if (state.selectedReturns.isEmpty) return false;
    
    state = state.copyWith(isLoading: true);
    try {
      // TODO: Call API to process refund
      // API Payload would include: state.currentInvoice.id, state.selectedReturns, reason, refundMethod
      await Future.delayed(const Duration(seconds: 1)); // Mock API
      
      // Reset after success
      state = RefundState(); 
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Refund failed: $e');
      return false;
    }
  }
}

final refundProvider = StateNotifierProvider<RefundNotifier, RefundState>((ref) {
  return RefundNotifier();
});
