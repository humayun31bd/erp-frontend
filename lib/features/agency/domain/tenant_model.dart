import 'package:freezed_annotation/freezed_annotation.dart';

part 'tenant_model.freezed.dart';
part 'tenant_model.g.dart';

@freezed
class TenantModel with _$TenantModel {
  const factory TenantModel({
    required String id,
    required String name,
    required String vatNumber,
    required String email,
    String? subdomain,
    required String status,
    required DateTime createdAt,
    @Default('Basic') String marketingPlan,
    @Default([]) List<String> branches,
  }) = _TenantModel;

  factory TenantModel.fromJson(Map<String, dynamic> json) => _$TenantModelFromJson(json);
}
