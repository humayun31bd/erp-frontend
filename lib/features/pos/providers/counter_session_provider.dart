import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../data/counter_session_api.dart';
import '../domain/counter_session_model.dart';

final counterSessionApiProvider = Provider<CounterSessionApi>((ref) {
  final dio = ref.watch(dioProvider);
  return CounterSessionApi(dio);
});

final currentSessionProvider = FutureProvider.family.autoDispose<CounterSessionModel?, String>((ref, counterId) async {
  final api = ref.watch(counterSessionApiProvider);
  final response = await api.getCurrentSession(counterId);
  return response.session;
});

class CounterSessionNotifier extends StateNotifier<AsyncValue<CounterSessionModel?>> {
  final CounterSessionApi _api;
  final Ref _ref;

  CounterSessionNotifier(this._api, this._ref) : super(const AsyncValue.data(null));

  Future<void> loadSession(String counterId) async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getCurrentSession(counterId);
      state = AsyncValue.data(response.session);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> openSession({required String counterId, required double openingBalance}) async {
    try {
      final response = await _api.openSession({
        'counterId': counterId,
        'openingBalance': openingBalance,
      });
      if (response.success && response.session != null) {
        state = AsyncValue.data(response.session);
        return true;
      }
      return false;
    } catch (e) {
      print('openSession error: $e');
      return false;
    }
  }

  Future<bool> closeSession({required String sessionId, required double transferAmount, required double cashSales}) async {
    try {
      final response = await _api.closeSession({
        'sessionId': sessionId,
        'transferAmount': transferAmount,
        'cashSales': cashSales,
      });
      if (response.success) {
        state = const AsyncValue.data(null);
        return true;
      }
      return false;
    } catch (e) {
      print('closeSession error: $e');
      return false;
    }
  }

  void resumeSession(CounterSessionModel session) {
    state = AsyncValue.data(session);
  }
}

final sessionControllerProvider = StateNotifierProvider<CounterSessionNotifier, AsyncValue<CounterSessionModel?>>((ref) {
  return CounterSessionNotifier(ref.watch(counterSessionApiProvider), ref);
});
