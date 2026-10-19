// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_InvoiceModel _$$_InvoiceModelFromJson(Map<String, dynamic> json) =>
    _$_InvoiceModel(
      id: _parseString(json['id']),
      invoiceNumber: _parseString(json['invoiceNumber']),
      clientName: _parseClientName(json['buyerName']),
      totalAmount: _parseDouble(json['totalAmount']),
      vatAmount: _parseDouble(json['totalVatAmount']),
      status: _parseStatus(json['zatcaStatus']),
      paymentStatus: json['paymentStatus'] == null
          ? 'UNPAID'
          : _parsePaymentStatus(json['paymentStatus']),
      issueDate: _parseDateTime(json['issueDatetime']),
      zatcaQrBase64: json['qrCodeBase64'] as String?,
      counterId: json['counterId'] as String?,
    );

Map<String, dynamic> _$$_InvoiceModelToJson(_$_InvoiceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'invoiceNumber': instance.invoiceNumber,
      'buyerName': instance.clientName,
      'totalAmount': instance.totalAmount,
      'totalVatAmount': instance.vatAmount,
      'zatcaStatus': instance.status,
      'paymentStatus': instance.paymentStatus,
      'issueDatetime': instance.issueDate.toIso8601String(),
      'qrCodeBase64': instance.zatcaQrBase64,
      'counterId': instance.counterId,
    };
