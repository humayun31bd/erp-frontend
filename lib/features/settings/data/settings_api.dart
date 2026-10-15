import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'settings_api.g.dart';

@RestApi()
abstract class SettingsApi {
  factory SettingsApi(Dio dio, {String baseUrl}) = _SettingsApi;

  @GET('/settings/product-policy')
  Future<dynamic> getProductPolicy();

  @POST('/settings/product-policy')
  Future<void> updateProductPolicy(@Body() Map<String, dynamic> body);

  @GET('/settings/receipt')
  Future<dynamic> getReceiptSettings();

  @POST('/settings/receipt')
  Future<void> updateReceiptSettings(@Body() Map<String, dynamic> body);

  @GET('/settings/branches')
  Future<dynamic> getBranches();

  @POST('/settings/branches')
  Future<dynamic> createBranch(@Body() Map<String, dynamic> body);

  @PUT('/settings/branches/{id}')
  Future<dynamic> updateBranch(@Path('id') String id, @Body() Map<String, dynamic> body);

  @DELETE('/settings/branches/{id}')
  Future<dynamic> deleteBranch(@Path('id') String id);

  @GET('/users')
  Future<dynamic> getUsers();

  @GET('/warehouses')
  Future<dynamic> getWarehouses();

  @POST('/warehouses')
  Future<dynamic> createWarehouse(@Body() Map<String, dynamic> body);

  @PUT('/warehouses/{id}')
  Future<dynamic> updateWarehouse(@Path('id') String id, @Body() Map<String, dynamic> body);

  @DELETE('/warehouses/{id}')
  Future<dynamic> deleteWarehouse(@Path('id') String id);

  @GET('/settings/purchase-flow')
  Future<dynamic> getPurchaseFlowSettings();

  @PUT('/settings/purchase-flow')
  Future<dynamic> updatePurchaseFlowSettings(@Body() Map<String, dynamic> body);

  @GET('/settings/smtp')
  Future<dynamic> getSmtpSettings();

  @POST('/settings/smtp')
  Future<dynamic> updateSmtpSettings(@Body() Map<String, dynamic> body);

  @POST('/settings/smtp/test')
  Future<dynamic> testSmtpSettings(@Body() Map<String, dynamic> body);
}
