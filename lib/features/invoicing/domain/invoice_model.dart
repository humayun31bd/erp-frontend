import 'package:freezed_annotation/freezed_annotation.dart';

part 'invoice_model.freezed.dart';
part 'invoice_model.g.dart';

double _parseDouble(dynamic val) {
  if (val == null) return 0.0;
  if (val is num) return val.toDouble();
  return double.tryParse(val.toString()) ?? 0.0;
}

DateTime _parseDateTime(dynamic val) {
  if (val == null) return DateTime.now();
  if (val is DateTime) return val;
  if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
  return DateTime.tryParse(val.toString()) ?? DateTime.now();
}

String _parseClientName(dynamic val) {
  if (val == null || val.toString().trim().isEmpty) return 'Walk-in Customer';
  return val.toString();
}

String _parseStatus(dynamic val) {
  if (val == null || val.toString().trim().isEmpty) return 'PENDING';
  return val.toString();
}

String _parsePaymentStatus(dynamic val) {
  if (val == null || val.toString().trim().isEmpty) return 'UNPAID';
  return val.toString().toUpperCase();
}

String _parseString(dynamic val) => val?.toString() ?? '';

@freezed
class InvoiceModel with _$InvoiceModel {
  const factory InvoiceModel({
    @JsonKey(fromJson: _parseString) required String id,
    @JsonKey(fromJson: _parseString) required String invoiceNumber,
    @JsonKey(name: 'buyerName', fromJson: _parseClientName) required String clientName,
    @JsonKey(fromJson: _parseDouble) required double totalAmount,
    @JsonKey(name: 'totalVatAmount', fromJson: _parseDouble) required double vatAmount,
    @JsonKey(name: 'zatcaStatus', fromJson: _parseStatus) required String status,
    @JsonKey(name: 'paymentStatus', fromJson: _parsePaymentStatus) @Default('UNPAID') String paymentStatus,
    @JsonKey(name: 'issueDatetime', fromJson: _parseDateTime) required DateTime issueDate,
    @JsonKey(name: 'qrCodeBase64') String? zatcaQrBase64,
    String? counterId,
  }) = _InvoiceModel;

  factory InvoiceModel.fromJson(Map<String, dynamic> json) => _$InvoiceModelFromJson(json);
}
