// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_PosDashboardResponse _$$_PosDashboardResponseFromJson(
        Map<String, dynamic> json) =>
    _$_PosDashboardResponse(
      success: json['success'] as bool,
      data: PosDashboardData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_PosDashboardResponseToJson(
        _$_PosDashboardResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
    };

_$_PosDashboardData _$$_PosDashboardDataFromJson(Map<String, dynamic> json) =>
    _$_PosDashboardData(
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      topProducts: (json['topProducts'] as List<dynamic>)
          .map((e) => TopProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
      lowStock: (json['lowStock'] as List<dynamic>)
          .map((e) => LowStockProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$_PosDashboardDataToJson(_$_PosDashboardData instance) =>
    <String, dynamic>{
      'totalRevenue': instance.totalRevenue,
      'topProducts': instance.topProducts,
      'lowStock': instance.lowStock,
    };

_$_TopProduct _$$_TopProductFromJson(Map<String, dynamic> json) =>
    _$_TopProduct(
      productId: json['productId'] as String,
      name: json['name'] as String,
      totalQuantitySold: json['totalQuantitySold'] as int,
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
    );

Map<String, dynamic> _$$_TopProductToJson(_$_TopProduct instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'name': instance.name,
      'totalQuantitySold': instance.totalQuantitySold,
      'totalRevenue': instance.totalRevenue,
    };

_$_LowStockProduct _$$_LowStockProductFromJson(Map<String, dynamic> json) =>
    _$_LowStockProduct(
      id: json['id'] as String,
      name: json['name'] as String,
      stockQuantity: json['stockQuantity'] as int,
      minStockLevel: json['minStockLevel'] as int,
    );

Map<String, dynamic> _$$_LowStockProductToJson(_$_LowStockProduct instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'stockQuantity': instance.stockQuantity,
      'minStockLevel': instance.minStockLevel,
    };
