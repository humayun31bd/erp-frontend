import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../domain/counter_model.dart';

part 'counter_api.g.dart';

@RestApi()
abstract class CounterApi {
  factory CounterApi(Dio dio, {String baseUrl}) = _CounterApi;

  @GET('/counters')
  Future<CounterListResponse> getCounters();

  @POST('/counters')
  Future<dynamic> createCounter(@Body() Map<String, dynamic> body);

  @PUT('/counters/{id}')
  Future<dynamic> updateCounter(@Path('id') String id, @Body() Map<String, dynamic> body);

  @DELETE('/counters/{id}')
  Future<dynamic> deleteCounter(@Path('id') String id);
}
