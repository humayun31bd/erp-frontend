import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:erp_frontend/features/accounting/domain/accounting_models.dart';
import 'package:erp_frontend/features/accounting/domain/account_mapping_models.dart';

part 'accounting_api.g.dart';

@RestApi()
abstract class AccountingApi {
  factory AccountingApi(Dio dio, {String baseUrl}) = _AccountingApi;

  @GET('/accounting/account-mappings')
  Future<AccountMappingsResponse> getAccountMappings();

  @POST('/accounting/account-mappings')
  Future<HttpResponse<dynamic>> updateAccountMappings(@Body() Map<String, dynamic> body);

  @GET('/accounting/accounts')
  Future<AccountsResponse> getAccounts();

  @POST('/accounting/accounts')
  Future<AccountResponse> createAccount(@Body() Map<String, dynamic> body);

  @PUT('/accounting/accounts/{id}')
  Future<AccountResponse> updateAccount(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/accounting/accounts/{id}')
  Future<void> deleteAccount(@Path('id') String id);

  @GET('/accounting/journal-entries')
  Future<JournalEntriesResponse> getJournalEntries();

  @POST('/accounting/journal-entries')
  Future<JournalEntryResponse> createJournalEntry(@Body() Map<String, dynamic> body);

  @PUT('/accounting/journal-entries/{id}')
  Future<JournalEntryResponse> updateJournalEntryStatus(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  @GET('/accounting/cash-bank-accounts')
  Future<AccountsResponse> getCashBankAccounts(@Query("type") String type);

  @PUT('/accounting/accounts/{id}/nature')
  Future<AccountResponse> updateAccountNature(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  @POST('/accounting/vouchers')
  Future<JournalEntryResponse> createVoucher(@Body() Map<String, dynamic> body);

  @GET('/accounting/vouchers')
  Future<VouchersResponse> getVouchers(@Query("voucherType") String? voucherType);

  @PUT('/accounting/vouchers')
  Future<HttpResponse<dynamic>> updateVoucherStatus(@Body() Map<String, dynamic> body);

  @GET('/accounting/ledger')
  Future<LedgerResponse> getLedgerBalances();

  @GET('/settings/branches')
  Future<BranchesResponse> getBranches();

  @POST('/settings/branches')
  Future<BranchResponse> createBranch(@Body() Map<String, dynamic> body);

  @GET('/accounting/cost-centers')
  Future<CostCentersResponse> getCostCenters();

  @POST('/accounting/cost-centers')
  Future<CostCenterResponse> createCostCenter(@Body() Map<String, dynamic> body);

  @PUT('/accounting/cost-centers')
  Future<CostCenterResponse> updateCostCenter(@Body() Map<String, dynamic> body);

  @DELETE('/accounting/cost-centers')
  Future<HttpResponse<dynamic>> deleteCostCenter(@Query("id") String id);

  @POST('/accounting/cost-centers/sync')
  Future<HttpResponse<dynamic>> syncCostCenters();

  @GET('/accounting/cost-centers/sources')
  Future<HttpResponse<dynamic>> getCostCenterSources();

  @GET('/accounting/financial-years')
  Future<FinancialYearsResponse> getFinancialYears();
  @POST('/accounting/financial-years')
  Future<FinancialYearResponse> createFinancialYear(@Body() Map<String, dynamic> body);
}

class FinancialYearsResponse {
  final bool success;
  final List<FinancialYear> financialYears;
  FinancialYearsResponse({required this.success, required this.financialYears});
  factory FinancialYearsResponse.fromJson(Map<String, dynamic> json) {
    return FinancialYearsResponse(
      success: json['success'] ?? false,
      financialYears: (json['financialYears'] as List?)?.map((e) => FinancialYear.fromJson(e)).toList() ?? [],
    );
  }
}

class FinancialYearResponse {
  final bool success;
  final FinancialYear? financialYear;
  FinancialYearResponse({required this.success, this.financialYear});
  factory FinancialYearResponse.fromJson(Map<String, dynamic> json) {
    return FinancialYearResponse(
      success: json['success'] ?? false,
      financialYear: json['financialYear'] != null ? FinancialYear.fromJson(json['financialYear']) : null,
    );
  }
}

class FinancialYear {
  final String id;
  final String yearName;
  final String startDate;
  final String endDate;
  final bool isActive;
  final bool isClosed;
  FinancialYear({
    required this.id,
    required this.yearName,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.isClosed,
  });
  factory FinancialYear.fromJson(Map<String, dynamic> json) {
    return FinancialYear(
      id: json['id']?.toString() ?? '',
      yearName: (json['yearName'] ?? json['name'])?.toString() ?? 'FY 2026-2027',
      startDate: (json['startDate'] ?? json['fromDate'])?.toString() ?? '2026-07-01',
      endDate: (json['endDate'] ?? json['toDate'])?.toString() ?? '2027-06-30',
      isActive: json['isActive'] == true || json['isActive'] == 1,
      isClosed: json['isClosed'] == true || json['isClosed'] == 1,
    );
  }
}

class AccountsResponse {
  final bool success;
  final List<Account> accounts;
  AccountsResponse({required this.success, required this.accounts});
  factory AccountsResponse.fromJson(Map<String, dynamic> json) {
    return AccountsResponse(
      success: json['success'] ?? false,
      accounts: (json['accounts'] as List?)?.map((e) => Account.fromJson(e)).toList() ?? [],
    );
  }
}

class AccountResponse {
  final bool success;
  final Account? account;
  AccountResponse({required this.success, this.account});
  factory AccountResponse.fromJson(Map<String, dynamic> json) {
    return AccountResponse(
      success: json['success'] ?? false,
      account: json['account'] != null ? Account.fromJson(json['account']) : null,
    );
  }
}

class JournalEntriesResponse {
  final bool success;
  final List<JournalEntry> journalEntries;
  JournalEntriesResponse({required this.success, required this.journalEntries});
  factory JournalEntriesResponse.fromJson(Map<String, dynamic> json) {
    return JournalEntriesResponse(
      success: json['success'] ?? false,
      journalEntries: (json['journalEntries'] as List?)?.map((e) => JournalEntry.fromJson(e)).toList() ?? [],
    );
  }
}

class JournalEntryResponse {
  final bool success;
  final JournalEntry? journalEntry;
  JournalEntryResponse({required this.success, this.journalEntry});
  factory JournalEntryResponse.fromJson(Map<String, dynamic> json) {
    return JournalEntryResponse(
      success: json['success'] ?? false,
      journalEntry: json['journalEntry'] != null ? JournalEntry.fromJson(json['journalEntry']) : null,
    );
  }
}

class LedgerResponse {
  final bool success;
  final List<LedgerBalance> ledger;
  LedgerResponse({required this.success, required this.ledger});
  factory LedgerResponse.fromJson(Map<String, dynamic> json) {
    return LedgerResponse(
      success: json['success'] ?? false,
      ledger: (json['ledger'] as List?)?.map((e) => LedgerBalance.fromJson(e)).toList() ?? [],
    );
  }
}

class BranchesResponse {
  final bool success;
  final List<Branch> branches;
  BranchesResponse({required this.success, required this.branches});
  factory BranchesResponse.fromJson(Map<String, dynamic> json) {
    return BranchesResponse(
      success: json['success'] ?? false,
      branches: (json['branches'] as List?)?.map((e) => Branch.fromJson(e)).toList() ?? [],
    );
  }
}

class CostCentersResponse {
  final bool success;
  final List<CostCenter> costCenters;
  CostCentersResponse({required this.success, required this.costCenters});
  factory CostCentersResponse.fromJson(Map<String, dynamic> json) {
    return CostCentersResponse(
      success: json['success'] ?? false,
      costCenters: (json['costCenters'] as List?)?.map((e) => CostCenter.fromJson(e)).toList() ?? [],
    );
  }
}

class BranchResponse {
  final bool success;
  final Branch? branch;
  BranchResponse({required this.success, this.branch});
  factory BranchResponse.fromJson(Map<String, dynamic> json) {
    return BranchResponse(
      success: json['success'] ?? false,
      branch: json['branch'] != null ? Branch.fromJson(json['branch']) : null,
    );
  }
}

class CostCenterResponse {
  final bool success;
  final CostCenter? costCenter;
  CostCenterResponse({required this.success, this.costCenter});
  factory CostCenterResponse.fromJson(Map<String, dynamic> json) {
    return CostCenterResponse(
      success: json['success'] ?? false,
      costCenter: json['costCenter'] != null ? CostCenter.fromJson(json['costCenter']) : null,
    );
  }
}

class VouchersResponse {
  final bool success;
  final List<Map<String, dynamic>> vouchers;

  VouchersResponse({required this.success, required this.vouchers});

  factory VouchersResponse.fromJson(Map<String, dynamic> json) {
    return VouchersResponse(
      success: json['success'] ?? false,
      vouchers: (json['vouchers'] as List?)?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [],
    );
  }
}
