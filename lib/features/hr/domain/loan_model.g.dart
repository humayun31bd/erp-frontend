// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_LoanRecord _$$_LoanRecordFromJson(Map<String, dynamic> json) =>
    _$_LoanRecord(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      amount: json['amount'] as String,
      monthlyInstallment: json['monthlyInstallment'] as String,
      remainingAmount: json['remainingAmount'] as String,
      status: json['status'] as String,
      reason: json['reason'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
    );

Map<String, dynamic> _$$_LoanRecordToJson(_$_LoanRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employeeId': instance.employeeId,
      'amount': instance.amount,
      'monthlyInstallment': instance.monthlyInstallment,
      'remainingAmount': instance.remainingAmount,
      'status': instance.status,
      'reason': instance.reason,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
    };
