// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_TaxModel _$$_TaxModelFromJson(Map<String, dynamic> json) => _$_TaxModel(
      id: json['id'] as String,
      categoryName: json['categoryName'] as String,
      taxRate: (json['taxRate'] as num).toDouble(),
    );

Map<String, dynamic> _$$_TaxModelToJson(_$_TaxModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'categoryName': instance.categoryName,
      'taxRate': instance.taxRate,
    };
