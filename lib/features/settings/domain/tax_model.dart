import 'package:freezed_annotation/freezed_annotation.dart';

part 'tax_model.freezed.dart';
part 'tax_model.g.dart';

@freezed
class TaxModel with _$TaxModel {
  const factory TaxModel({
    required String id,
    required String categoryName,
    required double taxRate,
  }) = _TaxModel;

  factory TaxModel.fromJson(Map<String, dynamic> json) => _$TaxModelFromJson(json);
}
