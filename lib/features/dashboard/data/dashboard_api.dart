import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../domain/dashboard_stats_model.dart';

part 'dashboard_api.g.dart';

@RestApi()
abstract class DashboardApi {
  factory DashboardApi(Dio dio, {String baseUrl}) = _DashboardApi;

  @GET('/dashboard/stats')
  Future<DashboardStatsModel> getDashboardStats();
}
