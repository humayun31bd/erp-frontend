import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'employees_provider.dart';
import '../domain/payroll_model.dart';

final payrollProvider = FutureProvider.family<List<PayrollRecord>, Map<String, dynamic>>((ref, params) async {
  final api = ref.watch(hrApiProvider);
  return await api.getPayroll(
    month: params['month'] as int?,
    year: params['year'] as int?,
    department: params['department'] as String?,
    status: params['status'] as String?,
  );
});
