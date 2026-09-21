import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../domain/auth_response.dart';

part 'auth_api.g.dart';

@RestApi()
abstract class AuthApi {
  factory AuthApi(Dio dio, {String baseUrl}) = _AuthApi;

  @POST('/auth/login')
  Future<AuthResponse> login(@Body() Map<String, dynamic> credentials);

  @POST('/auth/refresh')
  Future<AuthResponse> refresh(@Body() Map<String, dynamic> tokenRequest);
}
