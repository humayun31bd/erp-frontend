import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../domain/cash_book_model.dart';

part 'cash_book_api.g.dart';

@RestApi()
abstract class CashBookApi {
  factory CashBookApi(Dio dio, {String baseUrl}) = _CashBookApi;

  @GET('/cash/book')
  Future<List<CashBookModel>> getCashBookEntries();

  @POST('/cash/book')
  Future<CashBookModel> createCashBookEntry(@Body() Map<String, dynamic> body);

  @GET('/cash/summary')
  Future<CashBookSummary> getCashBookSummary();
}
