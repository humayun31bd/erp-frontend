import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../domain/client_model.dart';

part 'client_api.g.dart';

@RestApi()
abstract class ClientApi {
  factory ClientApi(Dio dio, {String baseUrl}) = _ClientApi;

  @GET('/clients')
  Future<List<ClientModel>> getClients();

  @POST('/clients')
  Future<ClientModel> createClient(@Body() Map<String, dynamic> body);

  @PUT('/clients/{id}')
  Future<ClientModel> updateClient(@Path('id') String id, @Body() Map<String, dynamic> body);

  @DELETE('/clients/{id}')
  Future<void> deleteClient(@Path('id') String id);
}
