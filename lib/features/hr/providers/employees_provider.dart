import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../data/hr_api.dart';
import '../domain/employee_model.dart';

import '../domain/payroll_policy_model.dart';

final hrApiProvider = Provider<HrApi>((ref) {
  final dio = ref.watch(dioProvider);
  return HrApi(dio);
});

final employeesProvider = FutureProvider<List<Employee>>((ref) async {
  final api = ref.watch(hrApiProvider);
  return await api.getEmployees();
});

final payGradesProvider = FutureProvider<List<PayGrade>>((ref) async {
  final api = ref.watch(hrApiProvider);
  return await api.getPayGrades();
});

final payScalesProvider = FutureProvider<List<PayScale>>((ref) async {
  final api = ref.watch(hrApiProvider);
  return await api.getPayScales();
});
