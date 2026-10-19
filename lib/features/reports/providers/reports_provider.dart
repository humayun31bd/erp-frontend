import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../data/reports_api.dart';

final reportsApiProvider = Provider<ReportsApi>((ref) {
  final dio = ref.watch(dioProvider);
  return ReportsApi(dio);
});

final vatReportProvider = FutureProvider.family<VatReportResponse, Map<String, String?>>((ref, dateRange) async {
  final api = ref.watch(reportsApiProvider);
  return await api.getVatReport(dateRange['startDate'], dateRange['endDate']);
});

final profitLossProvider = FutureProvider.family<ProfitLossResponse, Map<String, String?>>((ref, dateRange) async {
  final api = ref.watch(reportsApiProvider);
  return await api.getProfitLoss(dateRange['startDate'], dateRange['endDate']);
});

final customerBalancesProvider = FutureProvider<CustomerBalancesResponse>((ref) async {
  final api = ref.watch(reportsApiProvider);
  return await api.getCustomerBalances();
});

final ledgerProvider = FutureProvider<LedgerResponse>((ref) async {
  final api = ref.watch(reportsApiProvider);
  return await api.getLedger();
});

final detailedLedgerProvider = FutureProvider<DetailedLedgerResponse>((ref) async {
  final api = ref.watch(reportsApiProvider);
  return await api.getDetailedLedger();
});

final trialBalanceProvider = FutureProvider.family<TrialBalanceResponse, Map<String, String?>>((ref, dateRange) async {
  final api = ref.watch(reportsApiProvider);
  return await api.getTrialBalance(dateRange['startDate'], dateRange['endDate']);
});

final balanceSheetProvider = FutureProvider.family<BalanceSheetResponse, String?>((ref, asOfDate) async {
  final api = ref.watch(reportsApiProvider);
  return await api.getBalanceSheet(asOfDate);
});
