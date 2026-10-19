// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_AttendanceRecord _$$_AttendanceRecordFromJson(Map<String, dynamic> json) =>
    _$_AttendanceRecord(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      employeeId: json['employee_id'] as String,
      date: json['date'] as String,
      checkIn: json['check_in'] as String?,
      checkOut: json['check_out'] as String?,
      status: json['status'] as String? ?? 'PRESENT',
      notes: json['notes'] as String?,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$$_AttendanceRecordToJson(_$_AttendanceRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenant_id': instance.tenantId,
      'employee_id': instance.employeeId,
      'date': instance.date,
      'check_in': instance.checkIn,
      'check_out': instance.checkOut,
      'status': instance.status,
      'notes': instance.notes,
      'created_at': instance.createdAt,
    };
