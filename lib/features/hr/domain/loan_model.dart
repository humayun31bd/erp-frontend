import 'package:freezed_annotation/freezed_annotation.dart';

part 'loan_model.freezed.dart';
part 'loan_model.g.dart';

@freezed
class LoanRecord with _$LoanRecord {
  const factory LoanRecord({
    required String id,
    @JsonKey(name: 'employeeId') required String employeeId,
    required String amount,
    @JsonKey(name: 'monthlyInstallment') required String monthlyInstallment,
    @JsonKey(name: 'remainingAmount') required String remainingAmount,
    required String status,
    String? reason,
    String? firstName,
    String? lastName,
  }) = _LoanRecord;

  factory LoanRecord.fromJson(Map<String, dynamic> json) =>
      _$LoanRecordFromJson(json);
}
