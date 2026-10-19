import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'whatsapp_api.g.dart';

@RestApi()
abstract class WhatsAppApi {
  factory WhatsAppApi(Dio dio, {String baseUrl}) = _WhatsAppApi;

  @POST('/whatsapp/send')
  Future<WhatsAppSendResponse> sendInvoice(@Body() Map<String, dynamic> body);
}

class WhatsAppSendResponse {
  final bool success;
  final String? messageId;
  final String? status;
  final String? error;

  WhatsAppSendResponse({required this.success, this.messageId, this.status, this.error});

  factory WhatsAppSendResponse.fromJson(Map<String, dynamic> json) {
    return WhatsAppSendResponse(
      success: json['success'] as bool? ?? false,
      messageId: json['messageId'] as String?,
      status: json['status'] as String?,
      error: json['error'] as String?,
    );
  }
}
