import 'package:freezed_annotation/freezed_annotation.dart';

part 'counter_session_model.freezed.dart';
part 'counter_session_model.g.dart';

String _stringFromJson(dynamic value) => value?.toString() ?? '0.0';
String? _nullableStringFromJson(dynamic value) => value?.toString();

@freezed
class CounterSessionModel with _$CounterSessionModel {
  const factory CounterSessionModel({
    required String id,
    required String tenantId,
    required String counterId,
    required String userId,
    required DateTime openedAt,
    DateTime? closedAt,
    @JsonKey(fromJson: _stringFromJson) required String openingBalance,
    @JsonKey(fromJson: _nullableStringFromJson) String? closingBalance,
    @JsonKey(fromJson: _stringFromJson) required String cashSales,
    @JsonKey(fromJson: _stringFromJson) required String transferAmount,
    required String status,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CounterSessionModel;

  factory CounterSessionModel.fromJson(Map<String, dynamic> json) => _$CounterSessionModelFromJson(json);
}

@freezed
class CounterSessionResponse with _$CounterSessionResponse {
  const factory CounterSessionResponse({
    required bool success,
    CounterSessionModel? session,
  }) = _CounterSessionResponse;

  factory CounterSessionResponse.fromJson(Map<String, dynamic> json) => _$CounterSessionResponseFromJson(json);
}
