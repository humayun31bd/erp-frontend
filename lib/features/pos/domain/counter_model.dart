import 'package:freezed_annotation/freezed_annotation.dart';

part 'counter_model.freezed.dart';
part 'counter_model.g.dart';

@freezed
class CounterModel with _$CounterModel {
  const factory CounterModel({
    required String id,
    required String name,
    required String branchId,
    required String branchName,
    required bool isActive,
  }) = _CounterModel;

  factory CounterModel.fromJson(Map<String, dynamic> json) => _$CounterModelFromJson(json);
}

@freezed
class CounterListResponse with _$CounterListResponse {
  const factory CounterListResponse({
    required bool success,
    @Default([]) List<CounterModel> counters,
  }) = _CounterListResponse;

  factory CounterListResponse.fromJson(Map<String, dynamic> json) => _$CounterListResponseFromJson(json);
}
