import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../data/pos_api.dart';
import '../domain/product_model.dart';
import 'package:uuid/uuid.dart';
import '../../clients/domain/client_model.dart';
import 'package:flutter/material.dart';
import 'offline_sync_service.dart';
import 'manager_override_service.dart';
import '../../../core/providers/tenant_settings_provider.dart';
final posApiProvider = Provider<PosApi>((ref) {
  final dio = ref.watch(dioProvider);
  return PosApi(dio);
});

final productsProvider = FutureProvider.autoDispose<List<ProductModel>>((ref) async {
  final api = ref.watch(posApiProvider);
  return api.getProducts();
});

final posDashboardProvider = FutureProvider.autoDispose((ref) async {
  final api = ref.watch(posApiProvider);
  final response = await api.getDashboard();
  return response.data;
});

class CartItem {
  final ProductModel product;
  int quantity;
  ProductUnitModel? selectedUnit;
  String? batchNumber;
  String? expiryDate;
  String? modifiers;
  double? measuredWeightKg;
  String? assignedStaff;
  
  CartItem({
    required this.product,
    this.quantity = 1,
    this.selectedUnit,
    this.batchNumber,
    this.expiryDate,
    this.modifiers,
    this.measuredWeightKg,
    this.assignedStaff,
  });
  
  double get effectivePrice {
    final basePrice = double.parse(product.price);
    if (measuredWeightKg != null && measuredWeightKg! > 0) {
      return (basePrice * measuredWeightKg! * 100).roundToDouble() / 100.0;
    }
    if (selectedUnit != null) {
      if (selectedUnit!.price != null && selectedUnit!.price!.isNotEmpty) {
        return double.parse(selectedUnit!.price!);
      }
      final factor = double.parse(selectedUnit!.conversionFactor);
      return basePrice * factor;
    }
    return basePrice;
  }
  
  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'selectedUnit': selectedUnit?.toJson(),
      'batchNumber': batchNumber,
      'expiryDate': expiryDate,
      'modifiers': modifiers,
      'measuredWeightKg': measuredWeightKg,
      'assignedStaff': assignedStaff,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: ProductModel.fromJson(json['product']),
      quantity: json['quantity'] as int? ?? 1,
      selectedUnit: json['selectedUnit'] != null ? ProductUnitModel.fromJson(json['selectedUnit']) : null,
      batchNumber: json['batchNumber'] as String?,
      expiryDate: json['expiryDate'] as String?,
      modifiers: json['modifiers'] as String?,
      measuredWeightKg: (json['measuredWeightKg'] as num?)?.toDouble(),
      assignedStaff: json['assignedStaff'] as String?,
    );
  }
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addProduct(
    ProductModel product, {
    ProductUnitModel? unit,
    String? batchNumber,
    String? expiryDate,
    String? modifiers,
    double? measuredWeightKg,
    String? assignedStaff,
  }) {
    final index = state.indexWhere((item) =>
        item.product.id == product.id &&
        item.selectedUnit?.id == unit?.id &&
        item.batchNumber == batchNumber &&
        item.modifiers == modifiers &&
        item.measuredWeightKg == measuredWeightKg);
    if (index >= 0) {
      final updated = List<CartItem>.from(state);
      final existing = updated.removeAt(index);
      existing.quantity++;
      // Move to top on re-add for descending sort (latest on top)
      state = [existing, ...updated];
    } else {
      // New items placed at the top (descending order)
      state = [
        CartItem(
          product: product,
          selectedUnit: unit,
          batchNumber: batchNumber,
          expiryDate: expiryDate,
          modifiers: modifiers,
          measuredWeightKg: measuredWeightKg,
          assignedStaff: assignedStaff,
        ),
        ...state
      ];
    }
  }

  void updateUnit(String productId, ProductUnitModel? newUnit) {
    final index = state.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      final updated = List<CartItem>.from(state);
      // Check if another line item exists with same unit
      final existingUnitIndex = state.indexWhere((item) => item.product.id == productId && item.selectedUnit?.id == newUnit?.id && item != updated[index]);
      
      if (existingUnitIndex >= 0) {
        // Merge quantities if same unit is selected
        updated[existingUnitIndex].quantity += updated[index].quantity;
        updated.removeAt(index);
      } else {
        updated[index].selectedUnit = newUnit;
      }
      state = updated;
    }
  }

  void removeProduct(String productId, {ProductUnitModel? unit}) {
    state = state.where((item) => !(item.product.id == productId && item.selectedUnit?.id == unit?.id)).toList();
  }

  Future<bool> removeProductWithAuth(
    BuildContext context, 
    String productId, 
    ManagerOverrideService overrideService, 
    {ProductUnitModel? unit}
  ) async {
    // Determine if override is needed (e.g. item already sent to kitchen/saved)
    // For now, always require manager override to void an item from the cart
    bool isAuthorized = await overrideService.requestOverride(
      context: context,
      actionType: OverrideActionType.voidItem,
      reason: 'Cashier requested item void',
      metadata: {'product_id': productId},
    );

    if (isAuthorized) {
      removeProduct(productId, unit: unit);
      return true;
    }
    return false;
  }

  void updateQuantity(String productId, int newQty, {ProductUnitModel? unit}) {
    if (newQty <= 0) {
      removeProduct(productId, unit: unit);
      return;
    }
    final updated = List<CartItem>.from(state);
    final index = updated.indexWhere(
        (item) => item.product.id == productId && item.selectedUnit?.id == unit?.id);
    if (index >= 0) {
      updated[index].quantity = newQty;
      state = updated;
    }
  }

  void clearCart() {
    state = [];
  }

  void setCart(List<CartItem> items) {
    state = List<CartItem>.from(items);
  }

  double get grossTotal {
    return state.fold(0, (sum, item) => sum + (item.effectivePrice * item.quantity));
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class CartDiscountNotifier extends StateNotifier<double> {
  CartDiscountNotifier() : super(0.0);

  Future<bool> applyDiscountWithAuth(
    BuildContext context, 
    double amount, 
    ManagerOverrideService overrideService
  ) async {
    const double maxAllowedByCashier = 50.0; // 50 SAR limit
    
    if (amount > maxAllowedByCashier) {
      bool isAuthorized = await overrideService.requestOverride(
        context: context,
        actionType: OverrideActionType.highDiscount,
        reason: 'Manual high discount requested',
        metadata: {'requested_discount': amount},
      );
      
      if (!isAuthorized) return false;
    }
    
    state = amount;
    return true;
  }

  void setDiscount(double amount) {
    state = amount;
  }

  void clearDiscount() {
    state = 0.0;
  }
}

final cartDiscountProvider = StateNotifierProvider<CartDiscountNotifier, double>((ref) {
  return CartDiscountNotifier();
});

class CartTotals {
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double grandTotal;

  CartTotals({
    required this.subtotal,
    required this.discountAmount,
    required this.taxAmount,
    required this.grandTotal,
  });
}

final cartTotalsProvider = Provider<CartTotals>((ref) {
  final cartItems = ref.watch(cartProvider);
  final manualDiscountAmount = ref.watch(cartDiscountProvider);
  final tenantSettings = ref.watch(tenantSettingsProvider);
  
  // 1. Calculate Gross Subtotal and Item Discounts
  double subtotal = 0.0;
  double itemDiscounts = 0.0;
  for (var item in cartItems) {
    subtotal += (item.effectivePrice * item.quantity);
    double itemDiscount = double.tryParse(item.product.discountAmount) ?? 0.0;
    itemDiscounts += (itemDiscount * item.quantity);
  }
  
  // 2. Calculate Cart-level Discount
  double discountAmount = manualDiscountAmount + itemDiscounts;
  if (discountAmount > subtotal) {
    discountAmount = subtotal; // Don't let discount exceed subtotal
  }
  double netAmount = subtotal - discountAmount;
  
  // 3. Calculate Tax dynamically from Tenant Setup
  final double vatRate = tenantSettings.taxRate / 100.0;
  final int decimals = tenantSettings.decimalPlaces;
  double factor = (decimals == 3) ? 1000.0 : 100.0;
  
  double taxAmount = (netAmount * vatRate * factor).roundToDouble() / factor;
  
  // 4. Calculate Grand Total
  double grandTotal = ((netAmount + taxAmount) * factor).roundToDouble() / factor;
  
  return CartTotals(
    subtotal: (subtotal * factor).roundToDouble() / factor,
    discountAmount: (discountAmount * factor).roundToDouble() / factor,
    taxAmount: taxAmount,
    grandTotal: grandTotal,
  );
});

/// Delivery / Order Type supported by POS cashier
enum PosDeliveryType {
  takeAway('take_away', 'Take Away', Icons.takeout_dining_outlined, Icons.takeout_dining),
  delivery('delivery', 'Delivery', Icons.delivery_dining_outlined, Icons.delivery_dining),
  dineIn('dine_in', 'Dine In', Icons.restaurant_outlined, Icons.restaurant);

  final String code;
  final String label;
  final IconData icon;
  final IconData activeIcon;
  const PosDeliveryType(this.code, this.label, this.icon, this.activeIcon);

  static PosDeliveryType fromCode(String? code) {
    if (code == null) return PosDeliveryType.takeAway;
    return PosDeliveryType.values.firstWhere(
      (e) => e.code == code || e.name == code,
      orElse: () => PosDeliveryType.takeAway,
    );
  }

  String get arabicLabel {
    switch (this) {
      case PosDeliveryType.takeAway:
        return 'سفري';
      case PosDeliveryType.delivery:
        return 'توصيل';
      case PosDeliveryType.dineIn:
        return 'محلي';
    }
  }

  String get bilingualLabel => '$label / $arabicLabel';
}

/// Active delivery/order type provider with Take Away as default
final posDeliveryTypeProvider = StateProvider<PosDeliveryType>((ref) => PosDeliveryType.takeAway);

class PosDeliveryOrderDetails {
  final String? tableNumber;
  final String? waiterName;
  final String? deliveryAddress;
  final double deliveryFee;
  final String? aggregator; // 'Jahez', 'HungerStation', 'Marsool', etc.
  final String? aggregatorReference;
  final String? deliveryNote;

  const PosDeliveryOrderDetails({
    this.tableNumber,
    this.waiterName,
    this.deliveryAddress,
    this.deliveryFee = 0.0,
    this.aggregator,
    this.aggregatorReference,
    this.deliveryNote,
  });

  PosDeliveryOrderDetails copyWith({
    String? tableNumber,
    String? waiterName,
    String? deliveryAddress,
    double? deliveryFee,
    String? aggregator,
    String? aggregatorReference,
    String? deliveryNote,
  }) {
    return PosDeliveryOrderDetails(
      tableNumber: tableNumber ?? this.tableNumber,
      waiterName: waiterName ?? this.waiterName,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      aggregator: aggregator ?? this.aggregator,
      aggregatorReference: aggregatorReference ?? this.aggregatorReference,
      deliveryNote: deliveryNote ?? this.deliveryNote,
    );
  }

  Map<String, dynamic> toJson() => {
    if (tableNumber != null && tableNumber!.isNotEmpty) 'tableNumber': tableNumber,
    if (waiterName != null && waiterName!.isNotEmpty) 'waiterName': waiterName,
    if (deliveryAddress != null && deliveryAddress!.isNotEmpty) 'deliveryAddress': deliveryAddress,
    if (deliveryFee > 0) 'deliveryFee': deliveryFee,
    if (aggregator != null && aggregator!.isNotEmpty) 'aggregator': aggregator,
    if (aggregatorReference != null && aggregatorReference!.isNotEmpty) 'aggregatorReference': aggregatorReference,
    if (deliveryNote != null && deliveryNote!.isNotEmpty) 'note': deliveryNote,
  };
}

final posDeliveryDetailsProvider = StateProvider<PosDeliveryOrderDetails>((ref) => const PosDeliveryOrderDetails());

class HeldCart {
  final String id;
  final List<CartItem> items;
  final ClientModel? customer;
  final double discount;
  final double totalAmount;
  final PosDeliveryType deliveryType;
  final DateTime heldAt;

  HeldCart({
    required this.id,
    required this.items,
    this.customer,
    this.discount = 0.0,
    this.totalAmount = 0.0,
    this.deliveryType = PosDeliveryType.takeAway,
    required this.heldAt,
  });
}

class HeldCartsNotifier extends StateNotifier<AsyncValue<List<HeldCart>>> {
  final PosApi _api;
  final Ref _ref;

  HeldCartsNotifier(this._api, this._ref) : super(const AsyncValue.loading()) {
    fetchHeldCarts();
  }

  Future<void> fetchHeldCarts() async {
    state = const AsyncValue.loading();
    try {
      final rawCarts = await _api.getHeldCarts();
      final List<HeldCart> carts = [];

      for (var data in List<dynamic>.from(rawCarts)) {
        if (data is! Map<String, dynamic>) continue;

        // Parse Items
        final List<CartItem> parsedItems = [];
        final rawItems = data['items'];
        final dynamic itemsList = (rawItems is String) ? jsonDecode(rawItems) : rawItems;

        if (itemsList is List) {
          for (var itemJson in itemsList) {
            if (itemJson is Map<String, dynamic>) {
              if (itemJson['product'] != null) {
                try {
                  parsedItems.add(CartItem.fromJson(Map<String, dynamic>.from(itemJson)));
                } catch (e) {
                  print('Error deserializing cart item: $e');
                }
              } else if (itemJson['productId'] != null) {
                final pId = itemJson['productId'].toString();
                ProductModel? matched;
                try {
                  final catalog = _ref.read(productsProvider).asData?.value;
                  matched = catalog?.firstWhere((p) => p.id == pId);
                } catch (_) {}
                final product = matched ?? ProductModel(
                  id: pId,
                  name: itemJson['productName']?.toString() ?? 'Product $pId',
                  price: (itemJson['price'] ?? 0).toString(),
                );
                parsedItems.add(CartItem(
                  product: product,
                  quantity: (itemJson['quantity'] as num?)?.toInt() ?? 1,
                ));
              }
            }
          }
        }

        // Parse Customer
        ClientModel? parsedCustomer;
        final rawCustomer = data['customerData'] ?? data['customer'];
        if (rawCustomer != null) {
          final custMap = (rawCustomer is String) ? jsonDecode(rawCustomer) : rawCustomer;
          if (custMap is Map<String, dynamic>) {
            try {
              parsedCustomer = ClientModel.fromJson(Map<String, dynamic>.from(custMap));
            } catch (_) {}
          }
        }
        if (parsedCustomer == null && data['customerName'] != null) {
          final name = data['customerName'].toString().trim();
          if (name.isNotEmpty && name.toLowerCase() != 'walk-in customer') {
            parsedCustomer = ClientModel(
              id: 'held_${data['id']}',
              name: name,
              createdAt: DateTime.now(),
            );
          }
        }

        // Parse Date safely
        DateTime heldAt = DateTime.now();
        final rawDate = data['createdAt'];
        if (rawDate != null) {
          if (rawDate is int) {
            heldAt = DateTime.fromMillisecondsSinceEpoch(rawDate);
          } else if (rawDate is String) {
            final parsed = DateTime.tryParse(rawDate);
            if (parsed != null) {
              heldAt = parsed;
            } else {
              final intVal = int.tryParse(rawDate);
              if (intVal != null) {
                heldAt = DateTime.fromMillisecondsSinceEpoch(intVal);
              }
            }
          }
        }

        final deliveryType = PosDeliveryType.fromCode(data['deliveryType']?.toString());

        carts.add(HeldCart(
          id: data['id']?.toString() ?? '',
          items: parsedItems,
          customer: parsedCustomer,
          discount: (data['discount'] as num?)?.toDouble() ?? 0.0,
          totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
          deliveryType: deliveryType,
          heldAt: heldAt,
        ));
      }

      state = AsyncValue.data(carts);
    } catch (e, st) {
      print('fetchHeldCarts error: $e');
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> holdCart(List<CartItem> items, ClientModel? customer, double discount, double total, {PosDeliveryType deliveryType = PosDeliveryType.takeAway}) async {
    if (items.isEmpty) return false;
    try {
      final payload = {
        'customerName': customer?.name,
        'customerData': customer?.toJson(),
        'discount': discount,
        'totalAmount': total,
        'deliveryType': deliveryType.code,
        'items': items.map((i) => i.toJson()).toList(),
      };
      await _api.holdCart(payload);
      await fetchHeldCarts();
      return true;
    } catch (e) {
      print('Error holding cart: $e');
      return false;
    }
  }

  Future<bool> deleteHeldCart(String id) async {
    try {
      await _api.deleteHeldCart(id);
      await fetchHeldCarts();
      return true;
    } catch (e) {
      print('Error deleting held cart: $e');
      return false;
    }
  }
}

final heldCartsProvider = StateNotifierProvider<HeldCartsNotifier, AsyncValue<List<HeldCart>>>((ref) {
  final api = ref.watch(posApiProvider);
  return HeldCartsNotifier(api, ref);
});

final selectedCustomerProvider = StateProvider<ClientModel?>((ref) => null);


class CheckoutNotifier extends StateNotifier<AsyncValue<dynamic>> {
  final PosApi _api;
  final Ref _ref;

  CheckoutNotifier(this._api, this._ref) : super(const AsyncValue.data(null));

  Future<Map<String, dynamic>?> checkout(
    String? buyerName, 
    String? paymentMethod, 
    {String? clientId, 
     String? buyerPhone, 
     PosDeliveryType deliveryType = PosDeliveryType.takeAway,
     PosDeliveryOrderDetails? deliveryDetails,
    }
  ) async {
    final cart = _ref.read(cartProvider);
    if (cart.isEmpty) return null;

    state = const AsyncValue.loading();
    try {
      final payload = {
        'idempotencyKey': const Uuid().v4(),
        'items': cart.map((i) => {
          'productId': i.product.id,
          'quantity': i.quantity,
        }).toList(),
        'totalDiscount': _ref.read(cartTotalsProvider).discountAmount,
        'deliveryType': deliveryType.code,
        if (deliveryDetails != null) 'deliveryDetails': deliveryDetails.toJson(),
        if (buyerName != null && buyerName.isNotEmpty) 'buyerName': buyerName,
        if (buyerPhone != null && buyerPhone.isNotEmpty) 'buyerPhone': buyerPhone,
        if (clientId != null && clientId.isNotEmpty) 'clientId': clientId,
        if (paymentMethod != null && paymentMethod.isNotEmpty) 'paymentMethod': paymentMethod,
      };

      final response = await _api.checkout(payload);
      _ref.read(cartProvider.notifier).clearCart();
      _ref.invalidate(productsProvider);
      final respData = (response is Map<String, dynamic>) 
          ? response 
          : {'invoiceNumber': 'INV-OK'};
      state = AsyncValue.data(respData);
      return respData;
    } catch (e, st) {
      bool isNetworkError = false;
      if (e is DioException) {
        isNetworkError = e.type == DioExceptionType.connectionTimeout ||
                         e.type == DioExceptionType.sendTimeout ||
                         e.type == DioExceptionType.receiveTimeout ||
                         e.type == DioExceptionType.connectionError;
      } else {
        isNetworkError = e.toString().contains('SocketException') || e.toString().contains('Failed host lookup');
      }

      if (isNetworkError) {
        try {
          final payload = {
            'idempotencyKey': const Uuid().v4(),
            'items': cart.map((i) => {
              'productId': i.product.id,
              'quantity': i.quantity,
            }).toList(),
            if (buyerName != null && buyerName.isNotEmpty) 'buyerName': buyerName,
            if (buyerPhone != null && buyerPhone.isNotEmpty) 'buyerPhone': buyerPhone,
            if (clientId != null && clientId.isNotEmpty) 'clientId': clientId,
            if (paymentMethod != null && paymentMethod.isNotEmpty) 'paymentMethod': paymentMethod,
          };
          
          await _ref.read(offlineSyncServiceProvider).saveCheckout(payload);
          _ref.read(cartProvider.notifier).clearCart();
          _ref.invalidate(offlineCheckoutsCountProvider);
          const offlineResp = {'invoiceNumber': 'OFFLINE-SAVED', 'offline': true};
          state = const AsyncValue.data(offlineResp);
          return offlineResp;
        } catch (offlineErr) {
          state = AsyncValue.error(offlineErr, st);
          return null;
        }
      } else {
        state = AsyncValue.error(e, st);
        return null;
      }
    }
  }

  Future<void> syncOfflineCheckouts() async {
    final syncService = _ref.read(offlineSyncServiceProvider);
    
    // Day-wise grouped checkouts
    final groupedCheckouts = await syncService.getUnsyncedCheckoutsGroupedByDay();
    if (groupedCheckouts.isEmpty) return;

    state = const AsyncValue.loading();
    int successCount = 0;
    
    // Step by step day-wise sync
    for (var dateKey in groupedCheckouts.keys) {
      print('Syncing offline checkouts for day: $dateKey');
      final dayCheckouts = groupedCheckouts[dateKey]!;
      
      for (var c in dayCheckouts) {
        try {
          final localId = c['_localId'];
          final payload = Map<String, dynamic>.from(c);
          payload.remove('_localId');
          payload.remove('_savedAt');
          
          await _api.checkout(payload);
          await syncService.clearSyncedCheckout(localId);
          successCount++;
        } catch (e) {
          print('Failed to sync offline checkout ${c['_localId']} on $dateKey: $e');
        }
      }
    }
    
    _ref.invalidate(offlineCheckoutsCountProvider);
    state = AsyncValue.data({'syncedCount': successCount});
  }
}

final checkoutProvider = StateNotifierProvider<CheckoutNotifier, AsyncValue<dynamic>>((ref) {
  final api = ref.watch(posApiProvider);
  return CheckoutNotifier(api, ref);
});
