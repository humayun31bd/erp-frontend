import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../data/copilot_api.dart';
import '../domain/chat_message.dart';

final copilotApiProvider = Provider<CopilotApi>((ref) {
  final dio = ref.watch(dioProvider);
  return CopilotApi(dio);
});

class CopilotState {
  final List<ChatMessage> messages;
  final bool isLoading;

  CopilotState({this.messages = const [], this.isLoading = false});

  CopilotState copyWith({List<ChatMessage>? messages, bool? isLoading}) {
    return CopilotState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CopilotNotifier extends StateNotifier<CopilotState> {
  final CopilotApi _api;

  CopilotNotifier(this._api) : super(CopilotState(messages: [
    ChatMessage(
      role: 'assistant',
      content: 'Hello! I am your AI Financial Copilot. I can help you analyze your invoices, check inventory, and manage tax compliance. How can I assist you today?',
      timestamp: DateTime.now().toIso8601String(),
    )
  ]));

  Future<void> sendMessage(String content) async {
    final userMsg = ChatMessage(
      role: 'user',
      content: content,
      timestamp: DateTime.now().toIso8601String(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
    );

    try {
      final payload = {
        'messages': state.messages.map((m) => {
          'role': m.role,
          'content': m.content,
        }).toList(),
      };

      final response = await _api.sendMessage(payload);
      if (response.success) {
        state = state.copyWith(
          messages: [...state.messages, response.message],
          isLoading: false,
        );
      }
    } catch (e) {
      // Add error message as assistant to notify user
      final errorMsg = ChatMessage(
        role: 'assistant',
        content: 'Sorry, I encountered an error connecting to the AI service: $e',
        timestamp: DateTime.now().toIso8601String(),
      );
      state = state.copyWith(
        messages: [...state.messages, errorMsg],
        isLoading: false,
      );
    }
  }
}

final copilotProvider = StateNotifierProvider<CopilotNotifier, CopilotState>((ref) {
  final api = ref.watch(copilotApiProvider);
  return CopilotNotifier(api);
});
