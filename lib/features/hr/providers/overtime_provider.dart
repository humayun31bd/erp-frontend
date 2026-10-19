import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'employees_provider.dart';
import '../domain/overtime_model.dart';

final overtimeProvider = FutureProvider.family<List<OvertimeRecord>, String?>((ref, employeeId) async {
  final api = ref.watch(hrApiProvider);
  return await api.getOvertime(employeeId: employeeId);
});
