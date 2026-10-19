import 'package:freezed_annotation/freezed_annotation.dart';

part 'supplier_model.freezed.dart';
part 'supplier_model.g.dart';

@freezed
class SupplierModel with _$SupplierModel {
  const factory SupplierModel({
    required String id,
    required String name,
    String? vatNumber,
    String? crNumber,
    String? address,
    String? email,
    String? phoneNumber,
    String? bankDetails,
    @Default('MERCHANDISE') String category,
    @Default('TIER_2_STANDARD') String supplierTier,
    @Default('NET_30') String paymentTerms,
    required DateTime createdAt,
  }) = _SupplierModel;

  factory SupplierModel.fromJson(Map<String, dynamic> json) => _$SupplierModelFromJson(json);
}
