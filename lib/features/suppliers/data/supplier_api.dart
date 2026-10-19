import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../domain/supplier_model.dart';

part 'supplier_api.g.dart';

@RestApi()
abstract class SupplierApi {
  factory SupplierApi(Dio dio, {String baseUrl}) = _SupplierApi;

  @GET('/suppliers')
  Future<List<SupplierModel>> getSuppliers();

  @POST('/suppliers')
  Future<SupplierModel> createSupplier(@Body() Map<String, dynamic> body);

  @POST('/suppliers/bulk')
  Future<dynamic> importSuppliers(@Body() dynamic body);

  @PUT('/suppliers/{id}')
  Future<SupplierModel> updateSupplier(@Path('id') String id, @Body() Map<String, dynamic> body);

  @DELETE('/suppliers/{id}')
  Future<void> deleteSupplier(@Path('id') String id);

  @GET('/suppliers/{id}/aging')
  Future<dynamic> getSupplierAging(@Path('id') String id);

  @GET('/procurement/returns')
  Future<dynamic> getSupplierReturns();

  @POST('/procurement/returns')
  Future<dynamic> createSupplierReturn(@Body() Map<String, dynamic> body);
}
