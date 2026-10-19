import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../domain/chat_message.dart';

part 'copilot_api.g.dart';

@RestApi()
abstract class CopilotApi {
  factory CopilotApi(Dio dio, {String baseUrl}) = _CopilotApi;

  @POST('/copilot/chat')
  Future<CopilotChatResponse> sendMessage(@Body() Map<String, dynamic> body);
}

class CopilotChatResponse {
  final bool success;
  final ChatMessage message;

  CopilotChatResponse({required this.success, required this.message});

  factory CopilotChatResponse.fromJson(Map<String, dynamic> json) {
    return CopilotChatResponse(
      success: json['success'] as bool,
      message: ChatMessage.fromJson(json['message'] as Map<String, dynamic>),
    );
  }
}
