// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accounting_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Account _$$_AccountFromJson(Map<String, dynamic> json) => _$_Account(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      level: json['level'] as int,
      parentId: json['parentId'] as String?,
      accountSubtype: json['accountSubtype'] as String?,
      isControl: json['isControl'] as bool? ?? false,
      isTransaction: json['isTransaction'] as bool? ?? false,
      isCashNature: json['isCashNature'] as bool? ?? false,
      isBankNature: json['isBankNature'] as bool? ?? false,
      hasCostCenter: json['hasCostCenter'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$_AccountToJson(_$_Account instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'type': instance.type,
      'level': instance.level,
      'parentId': instance.parentId,
      'accountSubtype': instance.accountSubtype,
      'isControl': instance.isControl,
      'isTransaction': instance.isTransaction,
      'isCashNature': instance.isCashNature,
      'isBankNature': instance.isBankNature,
      'hasCostCenter': instance.hasCostCenter,
      'isActive': instance.isActive,
    };

_$_JournalEntryLine _$$_JournalEntryLineFromJson(Map<String, dynamic> json) =>
    _$_JournalEntryLine(
      id: json['id'] as String?,
      accountId: json['accountId'] as String,
      debit: json['debit'] as String? ?? '0.00',
      credit: json['credit'] as String? ?? '0.00',
      description: json['description'] as String?,
      branchId: json['branchId'] as String?,
      costCenterId: json['costCenterId'] as String?,
    );

Map<String, dynamic> _$$_JournalEntryLineToJson(_$_JournalEntryLine instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accountId': instance.accountId,
      'debit': instance.debit,
      'credit': instance.credit,
      'description': instance.description,
      'branchId': instance.branchId,
      'costCenterId': instance.costCenterId,
    };

_$_JournalEntry _$$_JournalEntryFromJson(Map<String, dynamic> json) =>
    _$_JournalEntry(
      id: json['id'] as String,
      entryNumber: json['entryNumber'] as String,
      entryDate: json['entryDate'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      lines: (json['lines'] as List<dynamic>?)
              ?.map((e) => JournalEntryLine.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$_JournalEntryToJson(_$_JournalEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'entryNumber': instance.entryNumber,
      'entryDate': instance.entryDate,
      'description': instance.description,
      'status': instance.status,
      'lines': instance.lines,
    };

_$_Branch _$$_BranchFromJson(Map<String, dynamic> json) => _$_Branch(
      id: json['id'] as String,
      name: json['name'] as String,
      isMainBranch: json['is_main_branch'] as bool? ?? false,
    );

Map<String, dynamic> _$$_BranchToJson(_$_Branch instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'is_main_branch': instance.isMainBranch,
    };

_$_CostCenter _$$_CostCenterFromJson(Map<String, dynamic> json) =>
    _$_CostCenter(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String? ?? '',
      sourceType: json['sourceType'] as String? ?? 'GENERAL',
      sourceId: json['sourceId'] as String?,
      category: json['category'] as String?,
      monthlyBudget: (json['monthlyBudget'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] as bool? ?? true,
    );

Map<String, dynamic> _$$_CostCenterToJson(_$_CostCenter instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'sourceType': instance.sourceType,
      'sourceId': instance.sourceId,
      'category': instance.category,
      'monthlyBudget': instance.monthlyBudget,
      'is_active': instance.isActive,
    };
