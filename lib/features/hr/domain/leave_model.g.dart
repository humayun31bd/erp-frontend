// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_LeaveRecord _$$_LeaveRecordFromJson(Map<String, dynamic> json) =>
    _$_LeaveRecord(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      leaveType: json['leaveType'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      durationDays: json['durationDays'] as String,
      status: json['status'] as String,
      reason: json['reason'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
    );

Map<String, dynamic> _$$_LeaveRecordToJson(_$_LeaveRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employeeId': instance.employeeId,
      'leaveType': instance.leaveType,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'durationDays': instance.durationDays,
      'status': instance.status,
      'reason': instance.reason,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
    };
