import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../domain/purchase_model.dart';

part 'purchase_api.g.dart';

@RestApi()
abstract class PurchaseApi {
  factory PurchaseApi(Dio dio, {String baseUrl}) = _PurchaseApi;

  @GET('/purchases')
  Future<List<PurchaseModel>> getPurchases();

  @POST('/purchases')
  Future<PurchaseModel> createPurchase(@Body() Map<String, dynamic> body);

  @PUT('/purchases/{id}')
  Future<PurchaseModel> updatePurchase(@Path('id') String id, @Body() Map<String, dynamic> body);

  @DELETE('/purchases/{id}')
  Future<void> deletePurchase(@Path('id') String id);
}
