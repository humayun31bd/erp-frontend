import 'package:freezed_annotation/freezed_annotation.dart';

part 'accounting_models.freezed.dart';
part 'accounting_models.g.dart';

@freezed
class Account with _$Account {
  const factory Account({
    required String id,
    required String code,
    required String name,
    required String type,
    required int level,
    String? parentId,
    String? accountSubtype,
    @Default(false) bool isControl,
    @Default(false) bool isTransaction,
    @Default(false) bool isCashNature,
    @Default(false) bool isBankNature,
    @Default(false) bool hasCostCenter,
    @Default(true) bool isActive,
  }) = _Account;

  factory Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);
}

@freezed
class JournalEntryLine with _$JournalEntryLine {
  const factory JournalEntryLine({
    String? id,
    required String accountId,
    @Default('0.00') String debit,
    @Default('0.00') String credit,
    String? description,
    String? branchId,
    String? costCenterId,
  }) = _JournalEntryLine;

  factory JournalEntryLine.fromJson(Map<String, dynamic> json) => _$JournalEntryLineFromJson(json);
}

@freezed
class JournalEntry with _$JournalEntry {
  const factory JournalEntry({
    required String id,
    required String entryNumber,
    required String entryDate,
    String? description,
    required String status,
    @Default([]) List<JournalEntryLine> lines,
  }) = _JournalEntry;

  factory JournalEntry.fromJson(Map<String, dynamic> json) => _$JournalEntryFromJson(json);
}

@freezed
class LedgerBalance with _$LedgerBalance {
  const factory LedgerBalance({
    required String accountId,
    required String accountCode,
    required String accountName,
    required String accountType,
    required double totalDebit,
    required double totalCredit,
    required double balance,
  }) = _LedgerBalance;

  factory LedgerBalance.fromJson(Map<String, dynamic> json) {
    return LedgerBalance(
      accountId: json['accountId']?.toString() ?? '',
      accountCode: (json['accountCode'] ?? json['account_code'])?.toString() ?? '',
      accountName: (json['accountName'] ?? json['account_name'])?.toString() ?? '',
      accountType: (json['accountType'] ?? json['account_type'])?.toString() ?? 'ASSET',
      totalDebit: (json['totalDebit'] ?? json['total_debit'] as num?)?.toDouble() ?? 0.0,
      totalCredit: (json['totalCredit'] ?? json['total_credit'] as num?)?.toDouble() ?? 0.0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

@freezed
class Branch with _$Branch {
  const factory Branch({
    required String id,
    required String name,
    @JsonKey(name: 'is_main_branch') @Default(false) bool isMainBranch,
  }) = _Branch;

  factory Branch.fromJson(Map<String, dynamic> json) => _$BranchFromJson(json);
}

@freezed
class CostCenter with _$CostCenter {
  const factory CostCenter({
    required String id,
    required String name,
    @Default('') String code,
    @Default('GENERAL') String sourceType,
    String? sourceId,
    String? category,
    @Default(0.0) double monthlyBudget,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _CostCenter;

  factory CostCenter.fromJson(Map<String, dynamic> json) => _$CostCenterFromJson(json);
}

extension CostCenterX on CostCenter {
  String get refTypeLabel {
    switch (sourceType.toUpperCase()) {
      case 'EMPLOYEE':
        return 'Employee';
      case 'CAR_VEHICLE':
        return 'Vehicle/Driver';
      case 'BRANCH':
        return 'Branch';
      case 'SUPPLIER':
        return 'Supplier';
      case 'CUSTOMER':
        return 'Customer';
      case 'PROJECT':
        return 'Project';
      case 'DEALER':
        return 'Dealer';
      default:
        return 'General';
    }
  }

  String get refWhosLabel {
    if (sourceId != null && sourceId!.isNotEmpty) {
      return '$refTypeLabel: $sourceId';
    }
    return refTypeLabel;
  }

  String get displayNameWithRef {
    final codePrefix = code.isNotEmpty ? '[$code] ' : '';
    return '$codePrefix$name (Ref: $refWhosLabel)';
  }
}
