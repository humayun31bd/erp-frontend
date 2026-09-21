import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../domain/invoice_model.dart';

part 'invoice_api.g.dart';

@RestApi()
abstract class InvoiceApi {
  factory InvoiceApi(Dio dio, {String baseUrl}) = _InvoiceApi;

  @GET('/invoices')
  Future<List<InvoiceModel>> getInvoices();

  @POST('/invoices')
  Future<InvoiceModel> createInvoice(@Body() Map<String, dynamic> invoiceData);

  @GET('/invoices/{id}')
  Future<InvoiceModel> getInvoiceById(@Path('id') String id);
}
