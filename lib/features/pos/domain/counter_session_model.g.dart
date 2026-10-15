// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'counter_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_CounterSessionModel _$$_CounterSessionModelFromJson(
        Map<String, dynamic> json) =>
    _$_CounterSessionModel(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      counterId: json['counterId'] as String,
      userId: json['userId'] as String,
      openedAt: DateTime.parse(json['openedAt'] as String),
      closedAt: json['closedAt'] == null
          ? null
          : DateTime.parse(json['closedAt'] as String),
      openingBalance: _stringFromJson(json['openingBalance']),
      closingBalance: _nullableStringFromJson(json['closingBalance']),
      cashSales: _stringFromJson(json['cashSales']),
      transferAmount: _stringFromJson(json['transferAmount']),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$_CounterSessionModelToJson(
        _$_CounterSessionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'counterId': instance.counterId,
      'userId': instance.userId,
      'openedAt': instance.openedAt.toIso8601String(),
      'closedAt': instance.closedAt?.toIso8601String(),
      'openingBalance': instance.openingBalance,
      'closingBalance': instance.closingBalance,
      'cashSales': instance.cashSales,
      'transferAmount': instance.transferAmount,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$_CounterSessionResponse _$$_CounterSessionResponseFromJson(
        Map<String, dynamic> json) =>
    _$_CounterSessionResponse(
      success: json['success'] as bool,
      session: json['session'] == null
          ? null
          : CounterSessionModel.fromJson(
              json['session'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_CounterSessionResponseToJson(
        _$_CounterSessionResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'session': instance.session,
    };
