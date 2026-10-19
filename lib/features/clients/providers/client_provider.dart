import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../data/client_api.dart';
import '../domain/client_model.dart';

final clientApiProvider = Provider<ClientApi>((ref) {
  final dio = ref.watch(dioProvider);
  return ClientApi(dio);
});

final clientsProvider = FutureProvider.autoDispose<List<ClientModel>>((ref) async {
  final api = ref.watch(clientApiProvider);
  return api.getClients();
});

class ClientNotifier extends StateNotifier<AsyncValue<void>> {
  final ClientApi _api;
  final Ref _ref;

  ClientNotifier(this._api, this._ref) : super(const AsyncValue.data(null));

  Future<void> createClient(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _api.createClient(data);
      state = const AsyncValue.data(null);
      _ref.invalidate(clientsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateClient(String id, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _api.updateClient(id, data);
      state = const AsyncValue.data(null);
      _ref.invalidate(clientsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteClient(String id) async {
    state = const AsyncValue.loading();
    try {
      await _api.deleteClient(id);
      state = const AsyncValue.data(null);
      _ref.invalidate(clientsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final clientNotifierProvider = StateNotifierProvider<ClientNotifier, AsyncValue<void>>((ref) {
  final api = ref.watch(clientApiProvider);
  return ClientNotifier(api, ref);
});
