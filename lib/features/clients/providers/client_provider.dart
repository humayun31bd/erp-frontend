import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../data/client_api.dart';
import '../domain/client_model.dart';

final clientApiProvider = Provider<ClientApi>((ref) {
  final dio = ref.watch(dioProvider);
  return ClientApi(dio);
});

final clientListProvider = FutureProvider<List<ClientModel>>((ref) async {
  final api = ref.watch(clientApiProvider);
  return await api.getClients();
});

class ClientActionNotifier extends StateNotifier<AsyncValue<void>> {
  final ClientApi _api;
  final Ref _ref;

  ClientActionNotifier(this._api, this._ref) : super(const AsyncValue.data(null));

  Future<void> createClient(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _api.createClient(data);
      _ref.invalidate(clientListProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateClient(String id, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _api.updateClient(id, data);
      _ref.invalidate(clientListProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteClient(String id) async {
    state = const AsyncValue.loading();
    try {
      await _api.deleteClient(id);
      _ref.invalidate(clientListProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final clientActionProvider = StateNotifierProvider<ClientActionNotifier, AsyncValue<void>>((ref) {
  final api = ref.watch(clientApiProvider);
  return ClientActionNotifier(api, ref);
});
