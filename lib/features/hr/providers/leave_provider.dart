import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'employees_provider.dart';
import '../domain/leave_model.dart';

final leavesProvider = FutureProvider.family<List<LeaveRecord>, String?>((ref, employeeId) async {
  final api = ref.watch(hrApiProvider);
  return await api.getLeaves(employeeId: employeeId);
});
