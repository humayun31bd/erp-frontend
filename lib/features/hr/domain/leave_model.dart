import 'package:freezed_annotation/freezed_annotation.dart';

part 'leave_model.freezed.dart';
part 'leave_model.g.dart';

@freezed
class LeaveRecord with _$LeaveRecord {
  const factory LeaveRecord({
    required String id,
    @JsonKey(name: 'employeeId') required String employeeId,
    @JsonKey(name: 'leaveType') required String leaveType,
    @JsonKey(name: 'startDate') required String startDate,
    @JsonKey(name: 'endDate') required String endDate,
    @JsonKey(name: 'durationDays') required String durationDays,
    required String status,
    String? reason,
    String? firstName,
    String? lastName,
  }) = _LeaveRecord;

  factory LeaveRecord.fromJson(Map<String, dynamic> json) =>
      _$LeaveRecordFromJson(json);
}
