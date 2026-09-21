import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../data/whatsapp_api.dart';

final whatsappApiProvider = Provider<WhatsappApi>((ref) {
  final dio = ref.watch(dioProvider);
  return WhatsappApi(dio);
});

class WhatsappActionNotifier extends StateNotifier<AsyncValue<void>> {
  final WhatsappApi _api;

  WhatsappActionNotifier(this._api) : super(const AsyncValue.data(null));

  Future<void> sendInvoice({required String invoiceId, required String phone}) async {
    state = const AsyncValue.loading();
    try {
      await _api.sendInvoice({
        'invoiceId': invoiceId,
        'phone': phone,
      });
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> triggerDemo({required String phone}) async {
    state = const AsyncValue.loading();
    try {
      await _api.triggerDemo({
        'phone': phone,
      });
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final whatsappActionProvider = StateNotifierProvider<WhatsappActionNotifier, AsyncValue<void>>((ref) {
  final api = ref.watch(whatsappApiProvider);
  return WhatsappActionNotifier(api);
});
