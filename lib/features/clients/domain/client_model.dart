import 'package:freezed_annotation/freezed_annotation.dart';

part 'client_model.freezed.dart';
part 'client_model.g.dart';

@freezed
class ClientModel with _$ClientModel {
  const factory ClientModel({
    required String id,
    required String name,
    required String email,
    required String phone,
    required String crNumber,
    required String vatNumber,
    required String address,
  }) = _ClientModel;

  factory ClientModel.fromJson(Map<String, dynamic> json) => _$ClientModelFromJson(json);
}
