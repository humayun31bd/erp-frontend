import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../data/whatsapp_api.dart';

final whatsappApiProvider = Provider<WhatsAppApi>((ref) {
  final dio = ref.watch(dioProvider);
  return WhatsAppApi(dio);
});

class WhatsAppSendState {
  final bool isLoading;
  final String? error;
  final bool success;

  WhatsAppSendState({this.isLoading = false, this.error, this.success = false});
}

class WhatsAppSendNotifier extends StateNotifier<WhatsAppSendState> {
  final WhatsAppApi _api;

  WhatsAppSendNotifier(this._api) : super(WhatsAppSendState());

  Future<void> sendInvoice(String invoiceId, String phoneNumber) async {
    state = WhatsAppSendState(isLoading: true);
    try {
      final response = await _api.sendInvoice({
        'invoiceId': invoiceId,
        'phoneNumber': phoneNumber,
        'templateName': 'invoice_delivery_v1',
      });

      if (response.success) {
        state = WhatsAppSendState(isLoading: false, success: true);
      } else {
        state = WhatsAppSendState(isLoading: false, error: response.error ?? 'Unknown error');
      }
    } catch (e) {
      state = WhatsAppSendState(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = WhatsAppSendState();
  }
}

final whatsappSendProvider = StateNotifierProvider.autoDispose<WhatsAppSendNotifier, WhatsAppSendState>((ref) {
  return WhatsAppSendNotifier(ref.watch(whatsappApiProvider));
});
