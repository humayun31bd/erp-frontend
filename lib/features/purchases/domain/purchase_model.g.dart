// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_PurchaseModel _$$_PurchaseModelFromJson(Map<String, dynamic> json) =>
    _$_PurchaseModel(
      id: json['id'] as String,
      supplierId: json['supplierId'] as String,
      supplierName: json['supplierName'] as String?,
      invoiceNumber: json['invoiceNumber'] as String,
      issueDate: DateTime.parse(json['issueDate'] as String),
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      subtotalAmount: json['subtotalAmount'] as String,
      totalVatAmount: json['totalVatAmount'] as String,
      totalAmount: json['totalAmount'] as String,
      paymentStatus: json['paymentStatus'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lineItems: (json['lineItems'] as List<dynamic>?)
              ?.map((e) =>
                  PurchaseLineItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$_PurchaseModelToJson(_$_PurchaseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'supplierId': instance.supplierId,
      'supplierName': instance.supplierName,
      'invoiceNumber': instance.invoiceNumber,
      'issueDate': instance.issueDate.toIso8601String(),
      'dueDate': instance.dueDate?.toIso8601String(),
      'subtotalAmount': instance.subtotalAmount,
      'totalVatAmount': instance.totalVatAmount,
      'totalAmount': instance.totalAmount,
      'paymentStatus': instance.paymentStatus,
      'createdAt': instance.createdAt.toIso8601String(),
      'lineItems': instance.lineItems,
    };

_$_PurchaseLineItemModel _$$_PurchaseLineItemModelFromJson(
        Map<String, dynamic> json) =>
    _$_PurchaseLineItemModel(
      id: json['id'] as String?,
      productId: json['productId'] as String?,
      description: json['description'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      vatRate: (json['vatRate'] as num?)?.toDouble() ?? 15.0,
      subtotalAmount: (json['subtotalAmount'] as num).toDouble(),
      vatAmount: (json['vatAmount'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
    );

Map<String, dynamic> _$$_PurchaseLineItemModelToJson(
        _$_PurchaseLineItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'description': instance.description,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'vatRate': instance.vatRate,
      'subtotalAmount': instance.subtotalAmount,
      'vatAmount': instance.vatAmount,
      'totalAmount': instance.totalAmount,
    };
