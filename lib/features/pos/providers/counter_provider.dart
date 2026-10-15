import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../data/counter_api.dart';
import '../domain/counter_model.dart';

final counterApiProvider = Provider<CounterApi>((ref) {
  final dio = ref.watch(dioProvider);
  return CounterApi(dio);
});

final countersProvider = FutureProvider<List<CounterModel>>((ref) async {
  final api = ref.watch(counterApiProvider);
  final response = await api.getCounters();
  return response.counters;
});
