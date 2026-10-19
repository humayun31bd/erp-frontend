import 'package:freezed_annotation/freezed_annotation.dart';

part 'overtime_model.freezed.dart';
part 'overtime_model.g.dart';

@freezed
class OvertimeRecord with _$OvertimeRecord {
  const factory OvertimeRecord({
    required String id,
    @JsonKey(name: 'employeeId') required String employeeId,
    required String date,
    required String hours,
    required String status,
    String? reason,
    String? firstName,
    String? lastName,
  }) = _OvertimeRecord;

  factory OvertimeRecord.fromJson(Map<String, dynamic> json) =>
      _$OvertimeRecordFromJson(json);
}
