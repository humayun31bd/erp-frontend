import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'reports_api.g.dart';

@RestApi()
abstract class ReportsApi {
  factory ReportsApi(Dio dio, {String baseUrl}) = _ReportsApi;

  @GET('/reports/vat')
  Future<VatReportResponse> getVatReport(@Query("startDate") String? startDate, @Query("endDate") String? endDate);

  @GET('/reports/profit-loss')
  Future<ProfitLossResponse> getProfitLoss(@Query("startDate") String? startDate, @Query("endDate") String? endDate);

  @GET('/reports/customer-balances')
  Future<CustomerBalancesResponse> getCustomerBalances();

  @GET('/accounting/ledger')
  Future<LedgerResponse> getLedger();

  @GET('/reports/detailed-ledger')
  Future<DetailedLedgerResponse> getDetailedLedger();

  @GET('/reports/trial-balance')
  Future<TrialBalanceResponse> getTrialBalance(@Query("startDate") String? startDate, @Query("endDate") String? endDate);

  @GET('/reports/balance-sheet')
  Future<BalanceSheetResponse> getBalanceSheet(@Query("asOfDate") String? asOfDate);
}

class VatReportResponse {
  final Map<String, dynamic> summary;
  final List<dynamic> invoices;
  final String? error;

  VatReportResponse({required this.summary, required this.invoices, this.error});

  factory VatReportResponse.fromJson(Map<String, dynamic> json) {
    return VatReportResponse(
      summary: json['summary'] ?? {},
      invoices: json['invoices'] ?? [],
      error: json['error'] as String?,
    );
  }
}

class ProfitLossResponse {
  final Map<String, dynamic> data;

  ProfitLossResponse({required this.data});

  factory ProfitLossResponse.fromJson(Map<String, dynamic> json) {
    return ProfitLossResponse(
      data: json['data'] ?? {},
    );
  }
}

class CustomerBalancesResponse {
  final List<dynamic> data;

  CustomerBalancesResponse({required this.data});

  factory CustomerBalancesResponse.fromJson(Map<String, dynamic> json) {
    return CustomerBalancesResponse(
      data: json['data'] ?? [],
    );
  }
}

class LedgerResponse {
  final List<dynamic> ledger;
  final String? error;

  LedgerResponse({required this.ledger, this.error});

  factory LedgerResponse.fromJson(Map<String, dynamic> json) {
    return LedgerResponse(
      ledger: json['ledger'] ?? [],
      error: json['error'] as String?,
    );
  }
}

class DetailedLedgerResponse {
  final List<dynamic> data;
  final String? error;

  DetailedLedgerResponse({required this.data, this.error});

  factory DetailedLedgerResponse.fromJson(Map<String, dynamic> json) {
    return DetailedLedgerResponse(
      data: json['data'] ?? [],
      error: json['error'] as String?,
    );
  }
}

class TrialBalanceResponse {
  final Map<String, dynamic> data;
  final String? error;

  TrialBalanceResponse({required this.data, this.error});

  factory TrialBalanceResponse.fromJson(Map<String, dynamic> json) {
    return TrialBalanceResponse(
      data: json['data'] ?? {},
      error: json['error'] as String?,
    );
  }
}

class BalanceSheetResponse {
  final Map<String, dynamic> data;
  final String? error;

  BalanceSheetResponse({required this.data, this.error});

  factory BalanceSheetResponse.fromJson(Map<String, dynamic> json) {
    return BalanceSheetResponse(
      data: json['data'] ?? {},
      error: json['error'] as String?,
    );
  }
}
