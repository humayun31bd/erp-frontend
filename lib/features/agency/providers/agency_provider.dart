import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../data/agency_api.dart';
import '../domain/tenant_model.dart';

final agencyApiProvider = Provider<AgencyApi>((ref) {
  final dio = ref.watch(dioProvider);
  return AgencyApi(dio);
});

final agencyTenantsProvider = FutureProvider.autoDispose<List<TenantModel>>((ref) async {
  final api = ref.watch(agencyApiProvider);
  return api.getTenants();
});

class AgencyNotifier extends StateNotifier<AsyncValue<void>> {
  final AgencyApi _api;
  final Ref _ref;

  AgencyNotifier(this._api, this._ref) : super(const AsyncValue.data(null));

  Future<void> provisionTenant(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _api.provisionTenant(data);
      state = const AsyncValue.data(null);
      _ref.invalidate(agencyTenantsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final agencyNotifierProvider = StateNotifierProvider<AgencyNotifier, AsyncValue<void>>((ref) {
  final api = ref.watch(agencyApiProvider);
  return AgencyNotifier(api, ref);
});
