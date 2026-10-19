// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_SupplierModel _$$_SupplierModelFromJson(Map<String, dynamic> json) =>
    _$_SupplierModel(
      id: json['id'] as String,
      name: json['name'] as String,
      vatNumber: json['vatNumber'] as String?,
      crNumber: json['crNumber'] as String?,
      address: json['address'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      bankDetails: json['bankDetails'] as String?,
      category: json['category'] as String? ?? 'MERCHANDISE',
      supplierTier: json['supplierTier'] as String? ?? 'TIER_2_STANDARD',
      paymentTerms: json['paymentTerms'] as String? ?? 'NET_30',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$_SupplierModelToJson(_$_SupplierModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'vatNumber': instance.vatNumber,
      'crNumber': instance.crNumber,
      'address': instance.address,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'bankDetails': instance.bankDetails,
      'category': instance.category,
      'supplierTier': instance.supplierTier,
      'paymentTerms': instance.paymentTerms,
      'createdAt': instance.createdAt.toIso8601String(),
    };
