import 'package:freezed_annotation/freezed_annotation.dart';

part 'cash_book_model.freezed.dart';
part 'cash_book_model.g.dart';

String _amountToString(dynamic val) => val?.toString() ?? '0.00';

@freezed
class CashBookModel with _$CashBookModel {
  const factory CashBookModel({
    required String id,
    required String type,
    @JsonKey(fromJson: _amountToString) required String amount,
    String? category,
    String? description,
    String? referenceId,
    required DateTime entryDate,
    required DateTime createdAt,
  }) = _CashBookModel;

  factory CashBookModel.fromJson(Map<String, dynamic> json) => _$CashBookModelFromJson(json);
}

@freezed
class CashBookSummary with _$CashBookSummary {
  const factory CashBookSummary({
    required double totalIn,
    required double totalOut,
    required double closingBalance,
  }) = _CashBookSummary;

  factory CashBookSummary.fromJson(Map<String, dynamic> json) => _$CashBookSummaryFromJson(json);
}
