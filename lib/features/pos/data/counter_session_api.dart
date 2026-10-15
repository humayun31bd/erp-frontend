import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../domain/counter_session_model.dart';

part 'counter_session_api.g.dart';

@RestApi()
abstract class CounterSessionApi {
  factory CounterSessionApi(Dio dio, {String baseUrl}) = _CounterSessionApi;

  @GET('/counters/sessions')
  Future<CounterSessionResponse> getCurrentSession(@Query('counterId') String counterId);

  @POST('/counters/sessions')
  Future<CounterSessionResponse> openSession(@Body() Map<String, dynamic> body);

  @PATCH('/counters/sessions')
  Future<CounterSessionResponse> closeSession(@Body() Map<String, dynamic> body);
}
