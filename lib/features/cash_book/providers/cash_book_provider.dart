import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../data/cash_book_api.dart';
import '../domain/cash_book_model.dart';

final cashBookApiProvider = Provider<CashBookApi>((ref) {
  final dio = ref.watch(dioProvider);
  return CashBookApi(dio);
});

final cashBookEntriesProvider = FutureProvider<List<CashBookModel>>((ref) async {
  final api = ref.watch(cashBookApiProvider);
  return await api.getCashBookEntries();
});

final cashBookSummaryProvider = FutureProvider<CashBookSummary>((ref) async {
  final api = ref.watch(cashBookApiProvider);
  return await api.getCashBookSummary();
});
