// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cash_book_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_CashBookModel _$$_CashBookModelFromJson(Map<String, dynamic> json) =>
    _$_CashBookModel(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: _amountToString(json['amount']),
      category: json['category'] as String?,
      description: json['description'] as String?,
      referenceId: json['referenceId'] as String?,
      entryDate: DateTime.parse(json['entryDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$_CashBookModelToJson(_$_CashBookModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'amount': instance.amount,
      'category': instance.category,
      'description': instance.description,
      'referenceId': instance.referenceId,
      'entryDate': instance.entryDate.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$_CashBookSummary _$$_CashBookSummaryFromJson(Map<String, dynamic> json) =>
    _$_CashBookSummary(
      totalIn: (json['totalIn'] as num).toDouble(),
      totalOut: (json['totalOut'] as num).toDouble(),
      closingBalance: (json['closingBalance'] as num).toDouble(),
    );

Map<String, dynamic> _$$_CashBookSummaryToJson(_$_CashBookSummary instance) =>
    <String, dynamic>{
      'totalIn': instance.totalIn,
      'totalOut': instance.totalOut,
      'closingBalance': instance.closingBalance,
    };
