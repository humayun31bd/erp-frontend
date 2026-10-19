import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../domain/attendance_model.dart';
import '../domain/employee_model.dart';
import '../domain/payroll_model.dart';
import '../domain/leave_model.dart';
import '../domain/overtime_model.dart';
import '../domain/loan_model.dart';
import '../domain/payroll_policy_model.dart';

part 'hr_api.g.dart';

@RestApi()
abstract class HrApi {
  factory HrApi(Dio dio, {String baseUrl}) = _HrApi;

  @GET('/hr/employees')
  Future<List<Employee>> getEmployees();

  @POST('/hr/employees')
  Future<Employee> createEmployee(@Body() Map<String, dynamic> body);

  @PUT('/hr/employees/{id}')
  Future<Employee> updateEmployee(@Path('id') String id, @Body() Map<String, dynamic> body);

  @DELETE('/hr/employees/{id}')
  Future<void> deleteEmployee(@Path('id') String id);

  @GET('/hr/attendance')
  Future<List<AttendanceRecord>> getAttendance({
    @Query('employeeId') String? employeeId,
    @Query('startDate') String? startDate,
    @Query('endDate') String? endDate,
  });

  @POST('/hr/attendance')
  Future<AttendanceRecord> recordAttendance(@Body() Map<String, dynamic> body);

  @PUT('/hr/attendance/{id}')
  Future<AttendanceRecord> updateAttendance(@Path('id') String id, @Body() Map<String, dynamic> body);

  @GET('/hr/payroll')
  Future<List<PayrollRecord>> getPayroll({
    @Query('month') int? month,
    @Query('year') int? year,
    @Query('department') String? department,
    @Query('status') String? status,
  });

  @POST('/hr/payroll')
  Future<dynamic> generatePayroll(@Body() Map<String, dynamic> body);

  @PUT('/hr/payroll/{id}')
  Future<PayrollRecord> updatePayrollStatus(@Path('id') String id, @Body() Map<String, dynamic> body);

  @POST('/hr/payroll/batch')
  Future<dynamic> executePayrollBatch(@Body() Map<String, dynamic> body);

  @GET('/hr/leaves')
  Future<List<LeaveRecord>> getLeaves({
    @Query('employeeId') String? employeeId,
  });

  @POST('/hr/leaves')
  Future<LeaveRecord> createLeaveRequest(@Body() Map<String, dynamic> body);

  @PUT('/hr/leaves/{id}')
  Future<LeaveRecord> updateLeaveRequest(@Path('id') String id, @Body() Map<String, dynamic> body);

  @GET('/hr/overtime')
  Future<List<OvertimeRecord>> getOvertime({
    @Query('employeeId') String? employeeId,
  });

  @POST('/hr/overtime')
  Future<OvertimeRecord> logOvertime(@Body() Map<String, dynamic> body);

  @PUT('/hr/overtime/{id}')
  Future<OvertimeRecord> updateOvertimeStatus(@Path('id') String id, @Body() Map<String, dynamic> body);

  @GET('/hr/loans')
  Future<List<LoanRecord>> getLoans({
    @Query('employeeId') String? employeeId,
  });

  @POST('/hr/loans')
  Future<LoanRecord> requestLoan(@Body() Map<String, dynamic> body);

  @PUT('/hr/loans/{id}')
  Future<LoanRecord> updateLoanStatus(@Path('id') String id, @Body() Map<String, dynamic> body);

  @POST('/hr/eosb')
  Future<dynamic> calculateEosb(@Body() Map<String, dynamic> body);

  @GET('/hr/payroll/grades')
  Future<List<PayGrade>> getPayGrades();

  @POST('/hr/payroll/grades')
  Future<PayGrade> createPayGrade(@Body() Map<String, dynamic> body);

  @GET('/hr/payroll/scales')
  Future<List<PayScale>> getPayScales();

  @POST('/hr/payroll/scales')
  Future<PayScale> createPayScale(@Body() Map<String, dynamic> body);
}
