// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_responses.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_InvoiceListResponse _$$_InvoiceListResponseFromJson(
        Map<String, dynamic> json) =>
    _$_InvoiceListResponse(
      success: json['success'] as bool,
      invoices: (json['invoices'] as List<dynamic>)
          .map((e) => InvoiceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$_InvoiceListResponseToJson(
        _$_InvoiceListResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'invoices': instance.invoices,
    };

_$_InvoiceDetailResponse _$$_InvoiceDetailResponseFromJson(
        Map<String, dynamic> json) =>
    _$_InvoiceDetailResponse(
      success: json['success'] as bool,
      invoice: InvoiceDetail.fromJson(json['invoice'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_InvoiceDetailResponseToJson(
        _$_InvoiceDetailResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'invoice': instance.invoice,
    };

_$_CreateInvoiceResponse _$$_CreateInvoiceResponseFromJson(
        Map<String, dynamic> json) =>
    _$_CreateInvoiceResponse(
      success: json['success'] as bool,
      invoiceId: json['invoiceId'] as String,
      invoiceNumber: json['invoiceNumber'] as String,
      zatca: json['zatca'],
      whatsapp: json['whatsapp'],
    );

Map<String, dynamic> _$$_CreateInvoiceResponseToJson(
        _$_CreateInvoiceResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'invoiceId': instance.invoiceId,
      'invoiceNumber': instance.invoiceNumber,
      'zatca': instance.zatca,
      'whatsapp': instance.whatsapp,
    };

_$_InvoiceDetail _$$_InvoiceDetailFromJson(Map<String, dynamic> json) =>
    _$_InvoiceDetail(
      id: _stringFromJson(json['id']),
      invoiceNumber: _stringFromJson(json['invoiceNumber']),
      sellerName: _sellerNameFromJson(json['sellerName']),
      sellerVat: json['sellerVat'] as String?,
      buyerName: _buyerNameFromJson(json['buyerName']),
      buyerVat: json['buyerVat'] as String?,
      buyerPhone: json['buyerPhone'] as String?,
      paymentStatus: json['paymentStatus'] as String? ?? 'UNPAID',
      totalAmount: _amountFromJson(json['totalAmount']),
      totalVatAmount: _amountFromJson(json['totalVatAmount']),
      subtotalAmount: _amountFromJson(json['subtotalAmount']),
      zatcaStatus: _statusFromJson(json['zatcaStatus']),
      issueDatetime: _dateTimeFromJson(json['issueDatetime']),
      qrCodeBase64: json['qrCodeBase64'] as String?,
      lineItems: (json['lineItems'] as List<dynamic>)
          .map((e) => InvoiceLineItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$_InvoiceDetailToJson(_$_InvoiceDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'invoiceNumber': instance.invoiceNumber,
      'sellerName': instance.sellerName,
      'sellerVat': instance.sellerVat,
      'buyerName': instance.buyerName,
      'buyerVat': instance.buyerVat,
      'buyerPhone': instance.buyerPhone,
      'paymentStatus': instance.paymentStatus,
      'totalAmount': instance.totalAmount,
      'totalVatAmount': instance.totalVatAmount,
      'subtotalAmount': instance.subtotalAmount,
      'zatcaStatus': instance.zatcaStatus,
      'issueDatetime': instance.issueDatetime.toIso8601String(),
      'qrCodeBase64': instance.qrCodeBase64,
      'lineItems': instance.lineItems,
    };

_$_InvoiceLineItem _$$_InvoiceLineItemFromJson(Map<String, dynamic> json) =>
    _$_InvoiceLineItem(
      id: _stringFromJson(json['id']),
      lineNumber: _intFromJson(json['lineNumber']),
      description: _stringFromJson(json['description']),
      quantity: _qtyFromJson(json['quantity']),
      unitPrice: _amountFromJson(json['unitPrice']),
      taxPercent: _amountFromJson(json['taxPercent']),
      taxAmount: _amountFromJson(json['taxAmount']),
      lineTotal: _amountFromJson(json['lineTotal']),
    );

Map<String, dynamic> _$$_InvoiceLineItemToJson(_$_InvoiceLineItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'lineNumber': instance.lineNumber,
      'description': instance.description,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'taxPercent': instance.taxPercent,
      'taxAmount': instance.taxAmount,
      'lineTotal': instance.lineTotal,
    };
