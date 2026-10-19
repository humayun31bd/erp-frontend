class PayGrade {
  final String id;
  final String gradeCode;
  final String gradeName;
  final double minSalary;
  final double maxSalary;
  final double housingAllowancePercent;
  final double transportAllowancePercent;
  final String? description;

  PayGrade({
    required this.id,
    required this.gradeCode,
    required this.gradeName,
    required this.minSalary,
    required this.maxSalary,
    required this.housingAllowancePercent,
    required this.transportAllowancePercent,
    this.description,
  });

  factory PayGrade.fromJson(Map<String, dynamic> json) {
    double parseD(dynamic val, [double def = 0]) {
      if (val == null) return def;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? def;
    }

    return PayGrade(
      id: (json['id'] ?? '').toString(),
      gradeCode: (json['gradeCode'] ?? json['grade_code'] ?? 'G1').toString(),
      gradeName: (json['gradeName'] ?? json['grade_name'] ?? '').toString(),
      minSalary: parseD(json['minSalary'] ?? json['min_salary']),
      maxSalary: parseD(json['maxSalary'] ?? json['max_salary']),
      housingAllowancePercent: parseD(json['housingAllowancePercent'] ?? json['housing_allowance_percent'], 25),
      transportAllowancePercent: parseD(json['transportAllowancePercent'] ?? json['transport_allowance_percent'], 10),
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'grade_code': gradeCode,
      'grade_name': gradeName,
      'min_salary': minSalary,
      'max_salary': maxSalary,
      'housing_allowance_percent': housingAllowancePercent,
      'transport_allowance_percent': transportAllowancePercent,
      'description': description,
    };
  }
}

class PayScale {
  final String id;
  final String? gradeId;
  final String gradeCode;
  final String scaleName;
  final double basicSalary;
  final double housingAllowance;
  final double transportAllowance;
  final double medicalAllowance;
  final double otherAllowances;
  final double totalPackage;
  final double incrementRate;
  final String? description;

  PayScale({
    required this.id,
    this.gradeId,
    required this.gradeCode,
    required this.scaleName,
    required this.basicSalary,
    required this.housingAllowance,
    required this.transportAllowance,
    required this.medicalAllowance,
    required this.otherAllowances,
    required this.totalPackage,
    required this.incrementRate,
    this.description,
  });

  factory PayScale.fromJson(Map<String, dynamic> json) {
    double parseD(dynamic val, [double def = 0]) {
      if (val == null) return def;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? def;
    }

    return PayScale(
      id: (json['id'] ?? '').toString(),
      gradeId: json['gradeId']?.toString() ?? json['grade_id']?.toString(),
      gradeCode: (json['gradeCode'] ?? json['grade_code'] ?? 'G1').toString(),
      scaleName: (json['scaleName'] ?? json['scale_name'] ?? '').toString(),
      basicSalary: parseD(json['basicSalary'] ?? json['basic_salary']),
      housingAllowance: parseD(json['housingAllowance'] ?? json['housing_allowance']),
      transportAllowance: parseD(json['transportAllowance'] ?? json['transport_allowance']),
      medicalAllowance: parseD(json['medicalAllowance'] ?? json['medical_allowance']),
      otherAllowances: parseD(json['otherAllowances'] ?? json['other_allowances']),
      totalPackage: parseD(json['totalPackage'] ?? json['total_package']),
      incrementRate: parseD(json['incrementRate'] ?? json['increment_rate']),
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'grade_id': gradeId,
      'grade_code': gradeCode,
      'scale_name': scaleName,
      'basic_salary': basicSalary,
      'housing_allowance': housingAllowance,
      'transport_allowance': transportAllowance,
      'medical_allowance': medicalAllowance,
      'other_allowances': otherAllowances,
      'total_package': totalPackage,
      'increment_rate': incrementRate,
      'description': description,
    };
  }
}
