import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'employees_provider.dart';
import '../domain/loan_model.dart';

final loansProvider = FutureProvider.family<List<LoanRecord>, String?>((ref, employeeId) async {
  final api = ref.watch(hrApiProvider);
  return await api.getLoans(employeeId: employeeId);
});
