import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'whatsapp_api.g.dart';

@RestApi()
abstract class WhatsappApi {
  factory WhatsappApi(Dio dio, {String baseUrl}) = _WhatsappApi;

  @POST('/whatsapp/send')
  Future<void> sendInvoice(@Body() Map<String, dynamic> payload);

  @POST('/demo-simulator')
  Future<void> triggerDemo(@Body() Map<String, dynamic> payload);
}
