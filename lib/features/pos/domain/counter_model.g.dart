// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'counter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_CounterModel _$$_CounterModelFromJson(Map<String, dynamic> json) =>
    _$_CounterModel(
      id: json['id'] as String,
      name: json['name'] as String,
      branchId: json['branchId'] as String,
      branchName: json['branchName'] as String,
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$$_CounterModelToJson(_$_CounterModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'branchId': instance.branchId,
      'branchName': instance.branchName,
      'isActive': instance.isActive,
    };

_$_CounterListResponse _$$_CounterListResponseFromJson(
        Map<String, dynamic> json) =>
    _$_CounterListResponse(
      success: json['success'] as bool,
      counters: (json['counters'] as List<dynamic>?)
              ?.map((e) => CounterModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$_CounterListResponseToJson(
        _$_CounterListResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'counters': instance.counters,
    };
