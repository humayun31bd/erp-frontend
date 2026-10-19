import 'package:freezed_annotation/freezed_annotation.dart';

part 'cheque_models.freezed.dart';
part 'cheque_models.g.dart';

@freezed
class ChequeBookModel with _$ChequeBookModel {
  const factory ChequeBookModel({
    required String id,
    required String tenantId,
    required String bankAccountId,
    required String chequeBookNumber,
    required int startLeafNumber,
    required int endLeafNumber,
    required int totalLeaves,
    required String status, // ACTIVE, EXHAUSTED, CANCELLED
    required String createdAt,
    String? bankAccountName,
    String? bankAccountCode,
    @Default(0) int availableLeavesCount,
    @Default(0) int usedLeavesCount,
    @Default(0) int issuedLeavesCount,
    @Default(0) int clearedLeavesCount,
    @Default(0) int bouncedLeavesCount,
  }) = _ChequeBookModel;

  factory ChequeBookModel.fromJson(Map<String, dynamic> json) => _$ChequeBookModelFromJson(json);
}

@freezed
class ChequeLeafModel with _$ChequeLeafModel {
  const factory ChequeLeafModel({
    required String id,
    required String tenantId,
    String? chequeBookId,
    required String bankAccountId,
    required String leafNumber,
    required String status, // AVAILABLE, ISSUED, RECEIVED, PRESENTED, CLEARED, CANCELLED, BOUNCED
    String? voucherId,
    String? payeeName,
    @Default(0.0) double amount,
    String? issuedDate,
    String? clearedDate,
    String? bouncedDate,
    String? remarks,
    required String createdAt,
    String? bankAccountName,
    String? chequeBookNumber,
    String? pdcCategory, // RECEIVED_PDC, ISSUED_PDC
    String? maturityAlert, // OVERDUE, DUE_TODAY, DUE_THIS_WEEK, FUTURE
  }) = _ChequeLeafModel;

  factory ChequeLeafModel.fromJson(Map<String, dynamic> json) => _$ChequeLeafModelFromJson(json);
}

extension ChequeLeafModelX on ChequeLeafModel {
  String get chequeNumber => leafNumber;
}

@freezed
class PdcSummaryModel with _$PdcSummaryModel {
  const factory PdcSummaryModel({
    @Default(0) int totalReceivedCount,
    @Default(0) int totalIssuedCount,
    @Default(0) int overdueCount,
    @Default(0) int dueTodayCount,
    @Default(0) int dueThisWeekCount,
  }) = _PdcSummaryModel;

  factory PdcSummaryModel.fromJson(Map<String, dynamic> json) => _$PdcSummaryModelFromJson(json);
}

@freezed
class ChequeAuditLogModel with _$ChequeAuditLogModel {
  const factory ChequeAuditLogModel({
    required String id,
    required String tenantId,
    required String chequeLeafId,
    required String actionType, // CREATED, ISSUED, PDC_RECEIVED, DEPOSITED, CLEARED, BOUNCED, CANCELLED
    String? previousStatus,
    required String newStatus,
    required String performedBy,
    String? remarks,
    required String createdAt,
  }) = _ChequeAuditLogModel;

  factory ChequeAuditLogModel.fromJson(Map<String, dynamic> json) => _$ChequeAuditLogModelFromJson(json);
}
