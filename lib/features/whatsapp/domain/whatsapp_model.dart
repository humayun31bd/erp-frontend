import 'package:freezed_annotation/freezed_annotation.dart';

part 'whatsapp_model.freezed.dart';
part 'whatsapp_model.g.dart';

@freezed
class WhatsAppLogModel with _$WhatsAppLogModel {
  const factory WhatsAppLogModel({
    required String waMessageId,
    required String invoiceId,
    required String phoneNumber,
    required String templateName,
    required String status,
    String? sentAt,
    String? deliveredAt,
    String? readAt,
  }) = _WhatsAppLogModel;

  factory WhatsAppLogModel.fromJson(Map<String, dynamic> json) => _$WhatsAppLogModelFromJson(json);
}
