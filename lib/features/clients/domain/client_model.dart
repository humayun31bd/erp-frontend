import 'package:freezed_annotation/freezed_annotation.dart';

part 'client_model.freezed.dart';
part 'client_model.g.dart';

double _parseDouble(dynamic val) {
  if (val == null) return 0.0;
  if (val is num) return val.toDouble();
  return double.tryParse(val.toString()) ?? 0.0;
}

bool _parseBool(dynamic val) {
  if (val == null) return false;
  if (val is bool) return val;
  if (val is num) return val != 0;
  return val.toString().toLowerCase() == 'true' || val.toString() == '1';
}

DateTime _parseDateTime(dynamic val) {
  if (val == null) return DateTime.now();
  if (val is DateTime) return val;
  if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
  return DateTime.tryParse(val.toString()) ?? DateTime.now();
}

@freezed
class ClientModel with _$ClientModel {
  const factory ClientModel({
    required String id,
    required String name,
    String? vatNumber,
    String? address,
    String? email,
    String? phoneNumber,
    String? country,
    String? state,
    String? city,
    String? customerType,
    @JsonKey(fromJson: _parseDouble) @Default(0.0) double? funds,
    @JsonKey(fromJson: _parseDouble) @Default(0.0) double? dues,
    @JsonKey(fromJson: _parseBool) @Default(false) bool permitCredit,
    @JsonKey(fromJson: _parseDouble) @Default(0.0) double creditLimit,
    @JsonKey(fromJson: _parseDateTime) required DateTime createdAt,
  }) = _ClientModel;

  factory ClientModel.fromJson(Map<String, dynamic> json) => _$ClientModelFromJson(json);
}
