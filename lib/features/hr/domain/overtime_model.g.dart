// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'overtime_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_OvertimeRecord _$$_OvertimeRecordFromJson(Map<String, dynamic> json) =>
    _$_OvertimeRecord(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      date: json['date'] as String,
      hours: json['hours'] as String,
      status: json['status'] as String,
      reason: json['reason'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
    );

Map<String, dynamic> _$$_OvertimeRecordToJson(_$_OvertimeRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employeeId': instance.employeeId,
      'date': instance.date,
      'hours': instance.hours,
      'status': instance.status,
      'reason': instance.reason,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
    };
