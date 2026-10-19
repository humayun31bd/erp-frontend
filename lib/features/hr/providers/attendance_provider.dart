import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/attendance_model.dart';
import 'employees_provider.dart';

final attendanceProvider = FutureProvider.family<List<AttendanceRecord>, Map<String, String?>>((ref, params) async {
  final api = ref.watch(hrApiProvider);
  return await api.getAttendance(
    employeeId: params['employeeId'],
    startDate: params['startDate'],
    endDate: params['endDate'],
  );
});
