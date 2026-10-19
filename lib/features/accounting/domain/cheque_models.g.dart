// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cheque_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ChequeBookModel _$$_ChequeBookModelFromJson(Map<String, dynamic> json) =>
    _$_ChequeBookModel(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      bankAccountId: json['bankAccountId'] as String,
      chequeBookNumber: json['chequeBookNumber'] as String,
      startLeafNumber: json['startLeafNumber'] as int,
      endLeafNumber: json['endLeafNumber'] as int,
      totalLeaves: json['totalLeaves'] as int,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      bankAccountName: json['bankAccountName'] as String?,
      bankAccountCode: json['bankAccountCode'] as String?,
      availableLeavesCount: json['availableLeavesCount'] as int? ?? 0,
      usedLeavesCount: json['usedLeavesCount'] as int? ?? 0,
      issuedLeavesCount: json['issuedLeavesCount'] as int? ?? 0,
      clearedLeavesCount: json['clearedLeavesCount'] as int? ?? 0,
      bouncedLeavesCount: json['bouncedLeavesCount'] as int? ?? 0,
    );

Map<String, dynamic> _$$_ChequeBookModelToJson(_$_ChequeBookModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'bankAccountId': instance.bankAccountId,
      'chequeBookNumber': instance.chequeBookNumber,
      'startLeafNumber': instance.startLeafNumber,
      'endLeafNumber': instance.endLeafNumber,
      'totalLeaves': instance.totalLeaves,
      'status': instance.status,
      'createdAt': instance.createdAt,
      'bankAccountName': instance.bankAccountName,
      'bankAccountCode': instance.bankAccountCode,
      'availableLeavesCount': instance.availableLeavesCount,
      'usedLeavesCount': instance.usedLeavesCount,
      'issuedLeavesCount': instance.issuedLeavesCount,
      'clearedLeavesCount': instance.clearedLeavesCount,
      'bouncedLeavesCount': instance.bouncedLeavesCount,
    };

_$_ChequeLeafModel _$$_ChequeLeafModelFromJson(Map<String, dynamic> json) =>
    _$_ChequeLeafModel(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      chequeBookId: json['chequeBookId'] as String?,
      bankAccountId: json['bankAccountId'] as String,
      leafNumber: json['leafNumber'] as String,
      status: json['status'] as String,
      voucherId: json['voucherId'] as String?,
      payeeName: json['payeeName'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      issuedDate: json['issuedDate'] as String?,
      clearedDate: json['clearedDate'] as String?,
      bouncedDate: json['bouncedDate'] as String?,
      remarks: json['remarks'] as String?,
      createdAt: json['createdAt'] as String,
      bankAccountName: json['bankAccountName'] as String?,
      chequeBookNumber: json['chequeBookNumber'] as String?,
      pdcCategory: json['pdcCategory'] as String?,
      maturityAlert: json['maturityAlert'] as String?,
    );

Map<String, dynamic> _$$_ChequeLeafModelToJson(_$_ChequeLeafModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'chequeBookId': instance.chequeBookId,
      'bankAccountId': instance.bankAccountId,
      'leafNumber': instance.leafNumber,
      'status': instance.status,
      'voucherId': instance.voucherId,
      'payeeName': instance.payeeName,
      'amount': instance.amount,
      'issuedDate': instance.issuedDate,
      'clearedDate': instance.clearedDate,
      'bouncedDate': instance.bouncedDate,
      'remarks': instance.remarks,
      'createdAt': instance.createdAt,
      'bankAccountName': instance.bankAccountName,
      'chequeBookNumber': instance.chequeBookNumber,
      'pdcCategory': instance.pdcCategory,
      'maturityAlert': instance.maturityAlert,
    };

_$_PdcSummaryModel _$$_PdcSummaryModelFromJson(Map<String, dynamic> json) =>
    _$_PdcSummaryModel(
      totalReceivedCount: json['totalReceivedCount'] as int? ?? 0,
      totalIssuedCount: json['totalIssuedCount'] as int? ?? 0,
      overdueCount: json['overdueCount'] as int? ?? 0,
      dueTodayCount: json['dueTodayCount'] as int? ?? 0,
      dueThisWeekCount: json['dueThisWeekCount'] as int? ?? 0,
    );

Map<String, dynamic> _$$_PdcSummaryModelToJson(_$_PdcSummaryModel instance) =>
    <String, dynamic>{
      'totalReceivedCount': instance.totalReceivedCount,
      'totalIssuedCount': instance.totalIssuedCount,
      'overdueCount': instance.overdueCount,
      'dueTodayCount': instance.dueTodayCount,
      'dueThisWeekCount': instance.dueThisWeekCount,
    };

_$_ChequeAuditLogModel _$$_ChequeAuditLogModelFromJson(
        Map<String, dynamic> json) =>
    _$_ChequeAuditLogModel(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      chequeLeafId: json['chequeLeafId'] as String,
      actionType: json['actionType'] as String,
      previousStatus: json['previousStatus'] as String?,
      newStatus: json['newStatus'] as String,
      performedBy: json['performedBy'] as String,
      remarks: json['remarks'] as String?,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$$_ChequeAuditLogModelToJson(
        _$_ChequeAuditLogModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'chequeLeafId': instance.chequeLeafId,
      'actionType': instance.actionType,
      'previousStatus': instance.previousStatus,
      'newStatus': instance.newStatus,
      'performedBy': instance.performedBy,
      'remarks': instance.remarks,
      'createdAt': instance.createdAt,
    };
