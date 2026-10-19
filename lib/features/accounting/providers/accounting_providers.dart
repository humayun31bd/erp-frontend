import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import 'package:erp_frontend/features/accounting/data/accounting_api.dart';
import 'package:erp_frontend/features/accounting/domain/accounting_models.dart';
import 'package:erp_frontend/features/accounting/domain/account_mapping_models.dart';
export 'package:erp_frontend/features/accounting/domain/accounting_models.dart';

final accountingApiProvider = Provider<AccountingApi>((ref) {
  final dio = ref.watch(dioProvider);
  return AccountingApi(dio);
});

final accountMappingsProvider = FutureProvider<List<AccountMapping>>((ref) async {
  final api = ref.watch(accountingApiProvider);
  final response = await api.getAccountMappings();
  return response.mappings;
});

final accountsProvider = FutureProvider<List<Account>>((ref) async {
  final api = ref.watch(accountingApiProvider);
  final response = await api.getAccounts();
  return response.accounts;
});

final journalEntriesProvider = FutureProvider<List<JournalEntry>>((ref) async {
  final api = ref.watch(accountingApiProvider);
  final response = await api.getJournalEntries();
  return response.journalEntries;
});

final ledgerProvider = FutureProvider<List<LedgerBalance>>((ref) async {
  final api = ref.watch(accountingApiProvider);
  final response = await api.getLedgerBalances();
  return response.ledger;
});

final branchesProvider = FutureProvider<List<Branch>>((ref) async {
  final api = ref.watch(accountingApiProvider);
  final response = await api.getBranches();
  return response.branches;
});

final costCentersProvider = FutureProvider<List<CostCenter>>((ref) async {
  final api = ref.watch(accountingApiProvider);
  final response = await api.getCostCenters();
  return response.costCenters;
});

final cashBankAccountsProvider = FutureProvider.family<List<Account>, String>((ref, type) async {
  final api = ref.watch(accountingApiProvider);
  final response = await api.getCashBankAccounts(type);
  return response.accounts;
});

final financialYearsProvider = FutureProvider<List<FinancialYear>>((ref) async {
  final api = ref.watch(accountingApiProvider);
  final response = await api.getFinancialYears();
  return response.financialYears;
});

final vouchersProvider = FutureProvider.family<List<Map<String, dynamic>>, String?>((ref, voucherType) async {
  final api = ref.watch(accountingApiProvider);
  final response = await api.getVouchers(voucherType == 'ALL' ? null : voucherType);
  return response.vouchers;
});

final pendingVouchersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final api = ref.watch(accountingApiProvider);
  final response = await api.getVouchers('ALL');
  return response.vouchers.where((v) => v['status'] == 'DRAFT' || v['status'] == 'SUBMITTED' || v['status'] == 'PENDING').toList();
});
