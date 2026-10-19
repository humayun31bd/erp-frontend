// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tenant_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_TenantModel _$$_TenantModelFromJson(Map<String, dynamic> json) =>
    _$_TenantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      vatNumber: json['vatNumber'] as String,
      email: json['email'] as String,
      subdomain: json['subdomain'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      marketingPlan: json['marketingPlan'] as String? ?? 'Basic',
      branches: (json['branches'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$_TenantModelToJson(_$_TenantModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'vatNumber': instance.vatNumber,
      'email': instance.email,
      'subdomain': instance.subdomain,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
      'marketingPlan': instance.marketingPlan,
      'branches': instance.branches,
    };
