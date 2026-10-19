import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../pos/providers/pos_provider.dart';


class OpeningStockEntry {
  final String openingStockId;
  final String productId;
  final String productName;
  final String? sku;
  final String? barcode;
  final String? price;
  final String? costPrice;
  final int quantity;
  final int currentStock;
  final String? warehouseId;
  final String? locationBin;
  final DateTime? createdAt;

  OpeningStockEntry({
    required this.openingStockId,
    required this.productId,
    required this.productName,
    this.sku,
    this.barcode,
    this.price,
    this.costPrice,
    required this.quantity,
    this.currentStock = 0,
    this.warehouseId,
    this.locationBin,
    this.createdAt,
  });

  factory OpeningStockEntry.fromJson(Map<String, dynamic> json) {
    return OpeningStockEntry(
      openingStockId: (json['openingStockId'] ?? '').toString(),
      productId: (json['productId'] ?? '').toString(),
      productName: (json['productName'] ?? 'Untitled Product').toString(),
      sku: json['sku']?.toString(),
      barcode: json['barcode']?.toString(),
      price: json['price']?.toString(),
      costPrice: json['costPrice']?.toString(),
      quantity: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      currentStock: int.tryParse(json['currentStock']?.toString() ?? '0') ?? 0,
      warehouseId: json['warehouseId']?.toString(),
      locationBin: json['locationBin']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'productId': productId,
      'quantity': quantity,
      'warehouseId': warehouseId,
      'locationBin': locationBin,
      'costPrice': costPrice,
    };
  }
}

class OpeningStockNotifier extends StateNotifier<AsyncValue<List<OpeningStockEntry>>> {
  final Ref ref;

  OpeningStockNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchOpeningStock();
  }

  Future<void> fetchOpeningStock() async {
    try {
      state = const AsyncValue.loading();
      final dio = ref.read(dioProvider);
      final tenantId = ref.read(tenantIdProvider);

      final response = await dio.get(
        '/inventory/opening-stock',
        options: Options(headers: {'x-tenant-id': tenantId}),
      );

      final List rawList = response.data is List ? response.data as List : [];
      final List<OpeningStockEntry> entries = rawList
          .whereType<Map<String, dynamic>>()
          .map((json) => OpeningStockEntry.fromJson(json))
          .toList();

      state = AsyncValue.data(entries);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> saveOpeningStock(List<Map<String, dynamic>> payload) async {
    try {
      final dio = ref.read(dioProvider);
      final tenantId = ref.read(tenantIdProvider);

      await dio.post(
        '/inventory/opening-stock',
        data: payload,
        options: Options(headers: {'x-tenant-id': tenantId}),
      );

      await fetchOpeningStock();
      ref.invalidate(productsProvider);
      return true;
    } catch (e) {
      print('Error saving opening stock: $e');
      return false;
    }
  }

  Future<bool> saveSingleOpeningStock(Map<String, dynamic> item) async {
    return saveOpeningStock([item]);
  }

  Future<bool> deleteOpeningStock(String id) async {
    try {
      final dio = ref.read(dioProvider);
      final tenantId = ref.read(tenantIdProvider);

      await dio.delete(
        '/inventory/opening-stock',
        queryParameters: {'id': id},
        options: Options(headers: {'x-tenant-id': tenantId}),
      );

      await fetchOpeningStock();
      ref.invalidate(productsProvider);
      return true;
    } catch (e) {
      print('Error deleting opening stock: $e');
      return false;
    }
  }
}

final openingStockProvider = StateNotifierProvider<OpeningStockNotifier, AsyncValue<List<OpeningStockEntry>>>((ref) {
  return OpeningStockNotifier(ref);
});
