class PayrollRecord {
  final String id;
  final String employeeId;
  final int month;
  final int year;
  final String basicSalary;
  final String housingAllowance;
  final String transportAllowance;
  final String otherAllowance;
  final String allowances;
  final double overtimeHours;
  final String overtimePay;
  final int presentDays;
  final int absentDays;
  final int lateDays;
  final String finesPenalties;
  final String loanDeduction;
  final String gosiDeduction;
  final String deductions;
  final String netSalary;
  final String status;
  final String? paymentDate;
  final String paymentMethod;
  final String? departmentName;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? designationName;
  final String? nationalId;
  final String? gosiNumber;
  final String? bankIban;
  final String? startDate;
  final String? endDate;

  PayrollRecord({
    required this.id,
    required this.employeeId,
    required this.month,
    required this.year,
    required this.basicSalary,
    this.housingAllowance = '0',
    this.transportAllowance = '0',
    this.otherAllowance = '0',
    required this.allowances,
    this.overtimeHours = 0.0,
    this.overtimePay = '0',
    this.presentDays = 0,
    this.absentDays = 0,
    this.lateDays = 0,
    this.finesPenalties = '0',
    this.loanDeduction = '0',
    this.gosiDeduction = '0',
    required this.deductions,
    required this.netSalary,
    this.status = 'DRAFT',
    this.paymentDate,
    this.paymentMethod = 'BANK',
    this.departmentName,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.designationName,
    this.nationalId,
    this.gosiNumber,
    this.bankIban,
    this.startDate,
    this.endDate,
  });

  factory PayrollRecord.fromJson(Map<String, dynamic> json) {
    double parseD(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    int parseI(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    return PayrollRecord(
      id: json['id']?.toString() ?? '',
      employeeId: json['employeeId']?.toString() ?? json['employee_id']?.toString() ?? '',
      month: parseI(json['month']),
      year: parseI(json['year']),
      basicSalary: parseD(json['basicSalary'] ?? json['basic_salary']).toStringAsFixed(2),
      housingAllowance: parseD(json['housingAllowance'] ?? json['housing_allowance']).toStringAsFixed(2),
      transportAllowance: parseD(json['transportAllowance'] ?? json['transport_allowance']).toStringAsFixed(2),
      otherAllowance: parseD(json['otherAllowance'] ?? json['other_allowance']).toStringAsFixed(2),
      allowances: parseD(json['allowances']).toStringAsFixed(2),
      overtimeHours: parseD(json['overtimeHours'] ?? json['overtime_hours']),
      overtimePay: parseD(json['overtimePay'] ?? json['overtime_pay']).toStringAsFixed(2),
      presentDays: parseI(json['presentDays'] ?? json['present_days']),
      absentDays: parseI(json['absentDays'] ?? json['absent_days']),
      lateDays: parseI(json['lateDays'] ?? json['late_days']),
      finesPenalties: parseD(json['finesPenalties'] ?? json['fines_penalties']).toStringAsFixed(2),
      loanDeduction: parseD(json['loanDeduction'] ?? json['loan_deduction']).toStringAsFixed(2),
      gosiDeduction: parseD(json['gosiDeduction'] ?? json['gosi_deduction']).toStringAsFixed(2),
      deductions: parseD(json['deductions']).toStringAsFixed(2),
      netSalary: parseD(json['netSalary'] ?? json['net_salary']).toStringAsFixed(2),
      status: json['status']?.toString() ?? 'DRAFT',
      paymentDate: json['paymentDate']?.toString() ?? json['payment_date']?.toString(),
      paymentMethod: json['paymentMethod']?.toString() ?? json['payment_method']?.toString() ?? 'BANK',
      departmentName: json['departmentName']?.toString() ?? json['department_name']?.toString(),
      firstName: json['firstName']?.toString() ?? json['first_name']?.toString(),
      lastName: json['lastName']?.toString() ?? json['last_name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      designationName: json['designationName']?.toString() ?? json['designation_name']?.toString(),
      nationalId: json['nationalId']?.toString() ?? json['national_id']?.toString(),
      gosiNumber: json['gosiNumber']?.toString() ?? json['gosi_number']?.toString(),
      bankIban: json['bankIban']?.toString() ?? json['bank_iban']?.toString(),
      startDate: json['startDate']?.toString() ?? json['start_date']?.toString(),
      endDate: json['endDate']?.toString() ?? json['end_date']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'employee_id': employeeId,
        'month': month,
        'year': year,
        'basic_salary': basicSalary,
        'housing_allowance': housingAllowance,
        'transport_allowance': transportAllowance,
        'other_allowance': otherAllowance,
        'allowances': allowances,
        'overtime_hours': overtimeHours,
        'overtime_pay': overtimePay,
        'present_days': presentDays,
        'absent_days': absentDays,
        'late_days': lateDays,
        'fines_penalties': finesPenalties,
        'loan_deduction': loanDeduction,
        'gosi_deduction': gosiDeduction,
        'deductions': deductions,
        'net_salary': netSalary,
        'status': status,
        'payment_date': paymentDate,
        'payment_method': paymentMethod,
        'department_name': departmentName,
        'start_date': startDate,
        'end_date': endDate,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'designation_name': designationName,
        'national_id': nationalId,
        'gosi_number': gosiNumber,
        'bank_iban': bankIban,
      };
}
