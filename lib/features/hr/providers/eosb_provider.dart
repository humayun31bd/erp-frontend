import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'employees_provider.dart';

class EosbCalculationNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  EosbCalculationNotifier(this.ref) : super(const AsyncData(null));

  final Ref ref;

  Future<void> calculateEosb({
    required String employeeId,
    required String endDate,
    required String reason,
  }) async {
    state = const AsyncLoading();
    try {
      final api = ref.read(hrApiProvider);
      final response = await api.calculateEosb({
        'employeeId': employeeId,
        'endDate': endDate,
        'reason': reason,
      });
      state = AsyncData(response['data'] as Map<String, dynamic>);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}

final eosbCalculationProvider = StateNotifierProvider<EosbCalculationNotifier, AsyncValue<Map<String, dynamic>?>>((ref) {
  return EosbCalculationNotifier(ref);
});
