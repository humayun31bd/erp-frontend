import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../data/payments_api.dart';

final paymentsApiProvider = Provider<PaymentsApi>((ref) {
  final dio = ref.watch(dioProvider);
  return PaymentsApi(dio);
});

class PaymentLinkState {
  final bool isLoading;
  final String? error;
  final String? paymentUrl;

  PaymentLinkState({this.isLoading = false, this.error, this.paymentUrl});
}

class PaymentLinkNotifier extends StateNotifier<PaymentLinkState> {
  final PaymentsApi _api;

  PaymentLinkNotifier(this._api) : super(PaymentLinkState());

  Future<void> generateLink(String invoiceId) async {
    state = PaymentLinkState(isLoading: true);
    try {
      final response = await _api.generateLink({
        'invoiceId': invoiceId,
        'gateway': 'MOYASAR',
      });

      if (response.success) {
        state = PaymentLinkState(isLoading: false, paymentUrl: response.paymentUrl);
      } else {
        state = PaymentLinkState(isLoading: false, error: response.error ?? 'Unknown error');
      }
    } catch (e) {
      state = PaymentLinkState(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = PaymentLinkState();
  }
}

final paymentLinkProvider = StateNotifierProvider.autoDispose<PaymentLinkNotifier, PaymentLinkState>((ref) {
  return PaymentLinkNotifier(ref.watch(paymentsApiProvider));
});
