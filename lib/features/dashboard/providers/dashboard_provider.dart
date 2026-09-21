import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../data/dashboard_api.dart';
import '../domain/dashboard_stats_model.dart';

final dashboardApiProvider = Provider<DashboardApi>((ref) {
  final dio = ref.watch(dioProvider);
  return DashboardApi(dio);
});

final dashboardStatsProvider = FutureProvider<DashboardStatsModel>((ref) async {
  final api = ref.watch(dashboardApiProvider);
  return await api.getDashboardStats();
});
