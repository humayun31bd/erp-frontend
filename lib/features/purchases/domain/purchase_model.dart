import 'package:freezed_annotation/freezed_annotation.dart';

part 'purchase_model.freezed.dart';
part 'purchase_model.g.dart';

@freezed
class PurchaseModel with _$PurchaseModel {
  const factory PurchaseModel({
    required String id,
    required String supplierId,
    String? supplierName,
    required String invoiceNumber,
    required DateTime issueDate,
    DateTime? dueDate,
    required String subtotalAmount,
    required String totalVatAmount,
    required String totalAmount,
    required String paymentStatus,
    required DateTime createdAt,
    @Default([]) List<PurchaseLineItemModel> lineItems,
  }) = _PurchaseModel;

  factory PurchaseModel.fromJson(Map<String, dynamic> json) => _$PurchaseModelFromJson(json);
}

@freezed
class PurchaseLineItemModel with _$PurchaseLineItemModel {
  const factory PurchaseLineItemModel({
    String? id,
    String? productId,
    required String description,
    required double quantity,
    required double unitPrice,
    @Default(15.0) double vatRate,
    required double subtotalAmount,
    required double vatAmount,
    required double totalAmount,
  }) = _PurchaseLineItemModel;

  factory PurchaseLineItemModel.fromJson(Map<String, dynamic> json) => _$PurchaseLineItemModelFromJson(json);
}
