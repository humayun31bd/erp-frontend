import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../domain/invoice_responses.dart';

part 'invoice_api.g.dart';

@RestApi()
abstract class InvoiceApi {
  factory InvoiceApi(Dio dio, {String baseUrl}) = _InvoiceApi;

  @GET('/invoices')
  Future<InvoiceListResponse> getInvoices({@Query('clientId') String? clientId});

  @POST('/invoices')
  Future<CreateInvoiceResponse> createInvoice(@Body() Map<String, dynamic> invoiceData);

  @POST('/invoices/{id}/credit-note')
  Future<CreateInvoiceResponse> createCreditNote(@Path('id') String id, @Body() Map<String, dynamic> invoiceData);

  @POST('/invoices/{id}/debit-note')
  Future<CreateInvoiceResponse> createDebitNote(@Path('id') String id, @Body() Map<String, dynamic> invoiceData);

  @GET('/invoices/{id}')
  Future<InvoiceDetailResponse> getInvoiceById(@Path('id') String id);
}
