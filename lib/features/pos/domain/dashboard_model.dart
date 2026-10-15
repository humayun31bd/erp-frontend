import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_model.freezed.dart';
part 'dashboard_model.g.dart';

@freezed
class PosDashboardResponse with _$PosDashboardResponse {
  const factory PosDashboardResponse({
    required bool success,
    required PosDashboardData data,
  }) = _PosDashboardResponse;

  factory PosDashboardResponse.fromJson(Map<String, dynamic> json) => _$PosDashboardResponseFromJson(json);
}

@freezed
class PosDashboardData with _$PosDashboardData {
  const factory PosDashboardData({
    required double totalRevenue,
    required List<TopProduct> topProducts,
    required List<LowStockProduct> lowStock,
  }) = _PosDashboardData;

  factory PosDashboardData.fromJson(Map<String, dynamic> json) => _$PosDashboardDataFromJson(json);
}

@freezed
class TopProduct with _$TopProduct {
  const factory TopProduct({
    required String productId,
    required String name,
    required int totalQuantitySold,
    required double totalRevenue,
  }) = _TopProduct;

  factory TopProduct.fromJson(Map<String, dynamic> json) => _$TopProductFromJson(json);
}

@freezed
class LowStockProduct with _$LowStockProduct {
  const factory LowStockProduct({
    required String id,
    required String name,
    required int stockQuantity,
    required int minStockLevel,
  }) = _LowStockProduct;

  factory LowStockProduct.fromJson(Map<String, dynamic> json) => _$LowStockProductFromJson(json);
}
