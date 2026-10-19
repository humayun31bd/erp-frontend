import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../domain/tenant_model.dart';

part 'agency_api.g.dart';

@RestApi()
abstract class AgencyApi {
  factory AgencyApi(Dio dio, {String baseUrl}) = _AgencyApi;

  @GET('/agency/tenants')
  Future<List<TenantModel>> getTenants();

  @POST('/agency/tenants')
  Future<TenantModel> provisionTenant(@Body() Map<String, dynamic> data);
}
