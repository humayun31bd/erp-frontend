import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../domain/product_model.dart';
import '../domain/dashboard_model.dart';

part 'pos_api.g.dart';

@RestApi()
abstract class PosApi {
  factory PosApi(Dio dio, {String baseUrl}) = _PosApi;

  @GET('/inventory/products')
  Future<List<ProductModel>> getProducts();

  @POST('/inventory/products')
  Future<ProductModel> createProduct(@Body() Map<String, dynamic> body);

  @DELETE('/inventory/products/{id}')
  Future<void> deleteProduct(@Path('id') String id);

  @PUT('/inventory/products/{id}')
  Future<ProductModel> updateProduct(@Path('id') String id, @Body() Map<String, dynamic> body);

  @POST('/pos/checkout')
  Future<dynamic> checkout(@Body() Map<String, dynamic> body);

  @GET('/pos/dashboard')
  Future<PosDashboardResponse> getDashboard();

  @GET('/pos/held-carts')
  Future<dynamic> getHeldCarts();

  @POST('/pos/held-carts')
  Future<dynamic> holdCart(@Body() Map<String, dynamic> body);

  @DELETE('/pos/held-carts/{id}')
  Future<void> deleteHeldCart(@Path('id') String id);

  @POST('/pos/cash-drawer')
  Future<void> postCashDrawerTransaction(@Body() Map<String, dynamic> body);

  @GET('/pos/cash-drawer')
  Future<dynamic> getCashDrawerTransactions();
}
