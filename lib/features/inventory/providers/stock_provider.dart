import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../features/auth/providers/auth_provider.dart';

class StockItem {
  final String id;
  final String name;
  final String? barcode;
  final String? brand;
  final int stockQuantity;
  final int minStockLevel;

  StockItem({
    required this.id, 
    required this.name, 
    this.barcode, 
    this.brand,
    required this.stockQuantity, 
    required this.minStockLevel,
  });

  factory StockItem.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }
    final rawName = (json['name'] ?? json['productName'] ?? json['product_name'] ?? 'Unnamed Product').toString();
    return StockItem(
      id: (json['id'] ?? '').toString(),
      name: rawName.isEmpty ? 'Unnamed Product' : rawName,
      barcode: json['barcode']?.toString() ?? json['sku']?.toString(),
      brand: json['brand']?.toString() ?? json['brandId']?.toString(),
      stockQuantity: toInt(json['stockQuantity'] ?? json['stock_quantity'] ?? json['stockInHand']),
      minStockLevel: toInt(json['minStockLevel'] ?? json['min_stock_level'] ?? json['minOrderQty']),
    );
  }
}

class StockNotifier extends StateNotifier<AsyncValue<List<StockItem>>> {
  final Ref ref;

  StockNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchStock();
  }

  Future<void> fetchStock() async {
    try {
      state = const AsyncValue.loading();
      final dio = ref.read(dioProvider);
      final tenantId = ref.read(tenantIdProvider);

      final response = await dio.get(
        '/inventory/stock',
        options: Options(headers: {'x-tenant-id': tenantId}),
      );

      final dynamic data = response.data;
      final List rawList = data is List
          ? data
          : (data is Map && data['data'] is List ? data['data'] as List : []);

      final List<StockItem> stock = rawList
          .whereType<Map<String, dynamic>>()
          .map((json) => StockItem.fromJson(json))
          .toList();

      state = AsyncValue.data(stock);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> updateStock(String id, int quantity, int minLevel) async {
    try {
      final dio = ref.read(dioProvider);
      final tenantId = ref.read(tenantIdProvider);
      
      await dio.put(
        '/inventory/stock/$id',
        data: {'stockQuantity': quantity, 'minStockLevel': minLevel},
        options: Options(headers: {'x-tenant-id': tenantId}),
      );
      
      await fetchStock();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final stockProvider = StateNotifierProvider<StockNotifier, AsyncValue<List<StockItem>>>((ref) {
  return StockNotifier(ref);
});
