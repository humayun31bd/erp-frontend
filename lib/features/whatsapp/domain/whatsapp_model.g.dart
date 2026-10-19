// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'whatsapp_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_WhatsAppLogModel _$$_WhatsAppLogModelFromJson(Map<String, dynamic> json) =>
    _$_WhatsAppLogModel(
      waMessageId: json['waMessageId'] as String,
      invoiceId: json['invoiceId'] as String,
      phoneNumber: json['phoneNumber'] as String,
      templateName: json['templateName'] as String,
      status: json['status'] as String,
      sentAt: json['sentAt'] as String?,
      deliveredAt: json['deliveredAt'] as String?,
      readAt: json['readAt'] as String?,
    );

Map<String, dynamic> _$$_WhatsAppLogModelToJson(_$_WhatsAppLogModel instance) =>
    <String, dynamic>{
      'waMessageId': instance.waMessageId,
      'invoiceId': instance.invoiceId,
      'phoneNumber': instance.phoneNumber,
      'templateName': instance.templateName,
      'status': instance.status,
      'sentAt': instance.sentAt,
      'deliveredAt': instance.deliveredAt,
      'readAt': instance.readAt,
    };
