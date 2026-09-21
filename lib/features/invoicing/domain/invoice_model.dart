import 'package:freezed_annotation/freezed_annotation.dart';

part 'invoice_model.freezed.dart';
part 'invoice_model.g.dart';

@freezed
class InvoiceModel with _$InvoiceModel {
  const factory InvoiceModel({
    required String id,
    required String invoiceNumber,
    required String clientName,
    required double totalAmount,
    required double vatAmount,
    required String status,
    required DateTime issueDate,
    String? zatcaQrBase64,
  }) = _InvoiceModel;

  factory InvoiceModel.fromJson(Map<String, dynamic> json) => _$InvoiceModelFromJson(json);
}
