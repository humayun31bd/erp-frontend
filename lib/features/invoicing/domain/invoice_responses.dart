import 'package:freezed_annotation/freezed_annotation.dart';
import 'invoice_model.dart';

part 'invoice_responses.freezed.dart';
part 'invoice_responses.g.dart';

@freezed
class InvoiceListResponse with _$InvoiceListResponse {
  const factory InvoiceListResponse({
    required bool success,
    required List<InvoiceModel> invoices,
  }) = _InvoiceListResponse;

  factory InvoiceListResponse.fromJson(Map<String, dynamic> json) => _$InvoiceListResponseFromJson(json);
}

@freezed
class InvoiceDetailResponse with _$InvoiceDetailResponse {
  const factory InvoiceDetailResponse({
    required bool success,
    required InvoiceDetail invoice,
  }) = _InvoiceDetailResponse;

  factory InvoiceDetailResponse.fromJson(Map<String, dynamic> json) => _$InvoiceDetailResponseFromJson(json);
}

@freezed
class CreateInvoiceResponse with _$CreateInvoiceResponse {
  const factory CreateInvoiceResponse({
    required bool success,
    required String invoiceId,
    required String invoiceNumber,
    dynamic zatca,
    dynamic whatsapp,
  }) = _CreateInvoiceResponse;

  factory CreateInvoiceResponse.fromJson(Map<String, dynamic> json) => _$CreateInvoiceResponseFromJson(json);
}

String _stringFromJson(dynamic val) => val?.toString() ?? '';

String _buyerNameFromJson(dynamic val) {
  if (val == null || val.toString().trim().isEmpty) return 'Walk-in Customer';
  return val.toString();
}

String _sellerNameFromJson(dynamic val) {
  if (val == null || val.toString().trim().isEmpty) return 'Intelligent ERP';
  return val.toString();
}

String _statusFromJson(dynamic val) {
  if (val == null || val.toString().trim().isEmpty) return 'PENDING';
  return val.toString();
}

String _amountFromJson(dynamic val) {
  if (val == null) return '0.00';
  if (val is double) return val.toStringAsFixed(2);
  if (val is int) return val.toString();
  final d = double.tryParse(val.toString());
  if (d != null) return d.toStringAsFixed(2);
  return val.toString();
}

String _qtyFromJson(dynamic val) {
  if (val == null) return '1';
  if (val is int) return val.toString();
  if (val is double) return val % 1 == 0 ? val.toInt().toString() : val.toString();
  final d = double.tryParse(val.toString());
  if (d != null) return d % 1 == 0 ? d.toInt().toString() : d.toString();
  return val.toString();
}

int _intFromJson(dynamic val) {
  if (val == null) return 0;
  if (val is num) return val.toInt();
  return int.tryParse(val.toString()) ?? 0;
}

DateTime _dateTimeFromJson(dynamic val) {
  if (val == null) return DateTime.now();
  if (val is DateTime) return val;
  if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
  return DateTime.tryParse(val.toString()) ?? DateTime.now();
}

@freezed
class InvoiceDetail with _$InvoiceDetail {
  const factory InvoiceDetail({
    @JsonKey(fromJson: _stringFromJson) required String id,
    @JsonKey(fromJson: _stringFromJson) required String invoiceNumber,
    @JsonKey(fromJson: _sellerNameFromJson) required String sellerName,
    String? sellerVat,
    @JsonKey(fromJson: _buyerNameFromJson) required String buyerName,
    String? buyerVat,
    String? buyerPhone,
    @Default('UNPAID') String paymentStatus,
    @JsonKey(fromJson: _amountFromJson) required String totalAmount,
    @JsonKey(fromJson: _amountFromJson) required String totalVatAmount,
    @JsonKey(fromJson: _amountFromJson) required String subtotalAmount,
    @JsonKey(fromJson: _statusFromJson) required String zatcaStatus,
    @JsonKey(fromJson: _dateTimeFromJson) required DateTime issueDatetime,
    String? qrCodeBase64,
    required List<InvoiceLineItem> lineItems,
  }) = _InvoiceDetail;

  factory InvoiceDetail.fromJson(Map<String, dynamic> json) => _$InvoiceDetailFromJson(json);
}

@freezed
class InvoiceLineItem with _$InvoiceLineItem {
  const factory InvoiceLineItem({
    @JsonKey(fromJson: _stringFromJson) required String id,
    @JsonKey(fromJson: _intFromJson) required int lineNumber,
    @JsonKey(fromJson: _stringFromJson) required String description,
    @JsonKey(fromJson: _qtyFromJson) required String quantity,
    @JsonKey(fromJson: _amountFromJson) required String unitPrice,
    @JsonKey(fromJson: _amountFromJson) required String taxPercent,
    @JsonKey(fromJson: _amountFromJson) required String taxAmount,
    @JsonKey(fromJson: _amountFromJson) required String lineTotal,
  }) = _InvoiceLineItem;

  factory InvoiceLineItem.fromJson(Map<String, dynamic> json) => _$InvoiceLineItemFromJson(json);
}
