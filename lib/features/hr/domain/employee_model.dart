import 'dart:convert';

class EmployeeExperience {
  final String company;
  final String period;
  final String responsibilities;

  EmployeeExperience({
    required this.company,
    required this.period,
    required this.responsibilities,
  });

  factory EmployeeExperience.fromJson(Map<String, dynamic> json) {
    return EmployeeExperience(
      company: json['company'] ?? '',
      period: json['period'] ?? '',
      responsibilities: json['responsibilities'] ?? json['responsibility'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'company': company,
        'period': period,
        'responsibilities': responsibilities,
      };
}

class EmployeeEducation {
  final String degree;
  final String institution;
  final String passingYear;
  final String result;

  EmployeeEducation({
    required this.degree,
    required this.institution,
    required this.passingYear,
    required this.result,
  });

  factory EmployeeEducation.fromJson(Map<String, dynamic> json) {
    return EmployeeEducation(
      degree: json['degree'] ?? '',
      institution: json['institution'] ?? '',
      passingYear: json['passingYear'] ?? json['passing_year'] ?? json['year'] ?? '',
      result: json['result'] ?? json['gpa'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'degree': degree,
        'institution': institution,
        'passingYear': passingYear,
        'result': result,
      };
}

class EmployeeDocument {
  final String id;
  final String documentType;
  final String title;
  final String fileUrl;
  final String? expiryDate;
  final String? notes;

  EmployeeDocument({
    required this.id,
    required this.documentType,
    required this.title,
    required this.fileUrl,
    this.expiryDate,
    this.notes,
  });

  factory EmployeeDocument.fromJson(Map<String, dynamic> json) {
    return EmployeeDocument(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      documentType: json['documentType'] ?? json['document_type'] ?? 'General Document',
      title: json['title'] ?? '',
      fileUrl: json['fileUrl'] ?? json['file_url'] ?? '',
      expiryDate: json['expiryDate'] ?? json['expiry_date'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'document_type': documentType,
        'title': title,
        'file_url': fileUrl,
        'expiry_date': expiryDate,
        'notes': notes,
      };
}

class Employee {
  final String id;
  final String firstName;
  final String lastName;
  final String? fatherName;
  final String? motherName;
  final String? address;
  final String? email;
  final String? phone;
  final String? nationalId;
  final String? iqamaExpiryDate;
  final String? passportNumber;
  final String? passportExpiryDate;
  final String? gosiNumber;
  final String? joiningDate;
  final String? basicSalary;
  final String? payGrade;
  final String? payScale;
  final String? housingAllowance;
  final String? transportAllowance;
  final String? otherAllowance;
  final String? profilePicture;
  final String? departmentId;
  final String? departmentName;
  final String? designationId;
  final String? designationName;
  final String? managerId;
  final String? managerName;
  final String? jobResponsibility;
  final String? workingHours;
  final String? offDay;
  final String? shiftInfo;
  final String? yearlyBenefits;
  final List<EmployeeExperience> experiences;
  final List<String> skills;
  final List<EmployeeEducation> educations;
  final List<EmployeeDocument> documents;
  final String paymentMethod;
  final String status;

  Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.fatherName,
    this.motherName,
    this.address,
    this.email,
    this.phone,
    this.nationalId,
    this.iqamaExpiryDate,
    this.passportNumber,
    this.passportExpiryDate,
    this.gosiNumber,
    this.joiningDate,
    this.basicSalary,
    this.payGrade,
    this.payScale,
    this.housingAllowance,
    this.transportAllowance,
    this.otherAllowance,
    this.profilePicture,
    this.departmentId,
    this.departmentName,
    this.designationId,
    this.designationName,
    this.managerId,
    this.managerName,
    this.jobResponsibility,
    this.workingHours,
    this.offDay,
    this.shiftInfo,
    this.yearlyBenefits,
    this.experiences = const [],
    this.skills = const [],
    this.educations = const [],
    this.documents = const [],
    this.paymentMethod = 'BANK',
    this.status = 'ACTIVE',
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    // Parse experiences
    List<EmployeeExperience> parsedExperiences = [];
    if (json['experiences'] != null) {
      if (json['experiences'] is List) {
        parsedExperiences = (json['experiences'] as List)
            .map((e) => e is Map<String, dynamic> ? EmployeeExperience.fromJson(e) : null)
            .whereType<EmployeeExperience>()
            .toList();
      } else if (json['experiences'] is String && (json['experiences'] as String).isNotEmpty) {
        try {
          final List decoded = jsonDecode(json['experiences']);
          parsedExperiences = decoded
              .map((e) => EmployeeExperience.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        } catch (_) {}
      }
    }

    // Parse skills
    List<String> parsedSkills = [];
    if (json['skills'] != null) {
      if (json['skills'] is List) {
        parsedSkills = (json['skills'] as List).map((e) => e.toString()).toList();
      } else if (json['skills'] is String && (json['skills'] as String).isNotEmpty) {
        try {
          final List decoded = jsonDecode(json['skills']);
          parsedSkills = decoded.map((e) => e.toString()).toList();
        } catch (_) {
          parsedSkills = (json['skills'] as String)
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();
        }
      }
    }

    // Parse educations
    List<EmployeeEducation> parsedEducations = [];
    if (json['educations'] != null) {
      if (json['educations'] is List) {
        parsedEducations = (json['educations'] as List)
            .map((e) => e is Map<String, dynamic> ? EmployeeEducation.fromJson(e) : null)
            .whereType<EmployeeEducation>()
            .toList();
      } else if (json['educations'] is String && (json['educations'] as String).isNotEmpty) {
        try {
          final List decoded = jsonDecode(json['educations']);
          parsedEducations = decoded
              .map((e) => EmployeeEducation.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        } catch (_) {}
      }
    }

    // Parse documents
    List<EmployeeDocument> parsedDocuments = [];
    if (json['documents'] != null) {
      if (json['documents'] is List) {
        parsedDocuments = (json['documents'] as List)
            .map((e) => e is Map<String, dynamic> ? EmployeeDocument.fromJson(e) : null)
            .whereType<EmployeeDocument>()
            .toList();
      } else if (json['documents'] is String && (json['documents'] as String).isNotEmpty) {
        try {
          final List decoded = jsonDecode(json['documents']);
          parsedDocuments = decoded
              .map((e) => EmployeeDocument.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        } catch (_) {}
      }
    }

    return Employee(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName'] ?? json['first_name'] ?? '',
      lastName: json['lastName'] ?? json['last_name'] ?? '',
      fatherName: json['fatherName'] ?? json['father_name'],
      motherName: json['motherName'] ?? json['mother_name'],
      address: json['address'],
      email: json['email'],
      phone: json['phone'],
      nationalId: json['nationalId'] ?? json['national_id'],
      iqamaExpiryDate: json['iqamaExpiryDate'] ?? json['iqama_expiry_date'],
      passportNumber: json['passportNumber'] ?? json['passport_number'],
      passportExpiryDate: json['passportExpiryDate'] ?? json['passport_expiry_date'],
      gosiNumber: json['gosiNumber'] ?? json['gosi_number'],
      joiningDate: json['joiningDate'] ?? json['joining_date'],
      basicSalary: json['basicSalary']?.toString() ?? json['basic_salary']?.toString(),
      payGrade: json['payGrade'] ?? json['pay_grade'],
      payScale: json['payScale'] ?? json['pay_scale'],
      housingAllowance: json['housingAllowance']?.toString() ?? json['housing_allowance']?.toString(),
      transportAllowance: json['transportAllowance']?.toString() ?? json['transport_allowance']?.toString(),
      otherAllowance: json['otherAllowance']?.toString() ?? json['other_allowance']?.toString(),
      profilePicture: json['profilePicture'] ?? json['profile_picture'],
      departmentId: json['departmentId'] ?? json['department_id'],
      departmentName: json['departmentName'] ?? json['department_name'],
      designationId: json['designationId'] ?? json['designation_id'],
      designationName: json['designationName'] ?? json['designation_name'],
      managerId: json['managerId'] ?? json['manager_id'],
      managerName: json['managerName'] ?? json['manager_name'],
      jobResponsibility: json['jobResponsibility'] ?? json['job_responsibility'],
      workingHours: json['workingHours'] ?? json['working_hours'],
      offDay: json['offDay'] ?? json['off_day'],
      shiftInfo: json['shiftInfo'] ?? json['shift_info'],
      yearlyBenefits: json['yearlyBenefits'] ?? json['yearly_benefits'],
      experiences: parsedExperiences,
      skills: parsedSkills,
      educations: parsedEducations,
      documents: parsedDocuments,
      paymentMethod: json['paymentMethod'] ?? json['payment_method'] ?? 'BANK',
      status: json['status'] ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'father_name': fatherName,
      'mother_name': motherName,
      'address': address,
      'email': email,
      'phone': phone,
      'national_id': nationalId,
      'iqama_expiry_date': iqamaExpiryDate,
      'passport_number': passportNumber,
      'passport_expiry_date': passportExpiryDate,
      'gosi_number': gosiNumber,
      'joining_date': joiningDate,
      'basic_salary': basicSalary,
      'pay_grade': payGrade,
      'pay_scale': payScale,
      'housing_allowance': housingAllowance,
      'transport_allowance': transportAllowance,
      'other_allowance': otherAllowance,
      'profile_picture': profilePicture,
      'department_id': departmentId,
      'department_name': departmentName,
      'designation_id': designationId,
      'designation_name': designationName,
      'manager_id': managerId,
      'manager_name': managerName,
      'job_responsibility': jobResponsibility,
      'working_hours': workingHours,
      'off_day': offDay,
      'shift_info': shiftInfo,
      'yearly_benefits': yearlyBenefits,
      'experiences': experiences.map((e) => e.toJson()).toList(),
      'skills': skills,
      'educations': educations.map((e) => e.toJson()).toList(),
      'documents': documents.map((e) => e.toJson()).toList(),
      'payment_method': paymentMethod,
      'status': status,
    };
  }
}
