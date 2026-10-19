class CountryCode {
  final String name;
  final String code;
  final String dialCode;
  final String flag;

  const CountryCode({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
  });
}

class HrConstants {
  static final List<CountryCode> countryCodes = [
    const CountryCode(name: 'Saudi Arabia', code: 'SA', dialCode: '+966', flag: '🇸🇦'),
    const CountryCode(name: 'United Arab Emirates', code: 'AE', dialCode: '+971', flag: '🇦🇪'),
    const CountryCode(name: 'Kuwait', code: 'KW', dialCode: '+965', flag: '🇰🇼'),
    const CountryCode(name: 'Qatar', code: 'QA', dialCode: '+974', flag: '🇶🇦'),
    const CountryCode(name: 'Bahrain', code: 'BH', dialCode: '+973', flag: '🇧🇭'),
    const CountryCode(name: 'Oman', code: 'OM', dialCode: '+968', flag: '🇴🇲'),
    const CountryCode(name: 'Egypt', code: 'EG', dialCode: '+20', flag: '🇪🇬'),
    const CountryCode(name: 'Jordan', code: 'JO', dialCode: '+962', flag: '🇯🇴'),
    const CountryCode(name: 'Lebanon', code: 'LB', dialCode: '+961', flag: '🇱🇧'),
    const CountryCode(name: 'Bangladesh', code: 'BD', dialCode: '+880', flag: '🇧🇩'),
    const CountryCode(name: 'India', code: 'IN', dialCode: '+91', flag: '🇮🇳'),
    const CountryCode(name: 'Pakistan', code: 'PK', dialCode: '+92', flag: '🇵🇰'),
    const CountryCode(name: 'Philippines', code: 'PH', dialCode: '+63', flag: '🇵🇭'),
    const CountryCode(name: 'United States / Canada', code: 'US', dialCode: '+1', flag: '🇺🇸'),
    const CountryCode(name: 'United Kingdom', code: 'GB', dialCode: '+44', flag: '🇬🇧'),
    const CountryCode(name: 'Germany', code: 'DE', dialCode: '+49', flag: '🇩🇪'),
    const CountryCode(name: 'France', code: 'FR', dialCode: '+33', flag: '🇫🇷'),
    const CountryCode(name: 'Turkey', code: 'TR', dialCode: '+90', flag: '🇹🇷'),
    const CountryCode(name: 'Sudan', code: 'SD', dialCode: '+249', flag: '🇸🇩'),
    const CountryCode(name: 'Yemen', code: 'YE', dialCode: '+967', flag: '🇾🇪'),
  ];

  static final List<String> departments = [
    'Human Resources (HR)',
    'Information Technology (IT)',
    'Finance & Accounting',
    'Sales & Marketing',
    'Operations & Logistics',
    'Customer Support',
    'Legal & Compliance',
    'Administration',
    'Research & Development',
  ];

  static final List<String> designations = [
    'Software Engineer',
    'Senior Software Engineer',
    'Tech Lead / Architect',
    'HR Manager',
    'HR Officer / Generalist',
    'Chief Accountant',
    'Accountant',
    'Financial Analyst',
    'Sales Executive',
    'Sales Manager',
    'Operations Manager',
    'Marketing Specialist',
    'Customer Support Specialist',
    'Administrative Assistant',
    'General Manager',
  ];

  static final List<String> shifts = [
    'Day Shift (09:00 AM - 05:00 PM)',
    'Morning Shift (08:00 AM - 04:00 PM)',
    'Evening Shift (02:00 PM - 10:00 PM)',
    'Night Shift (10:00 PM - 06:00 AM)',
    'Rotational Shift',
    'Flexible Working Hours (8 Hours/Day)',
  ];

  static final List<String> offDays = [
    'Friday & Saturday',
    'Saturday & Sunday',
    'Friday Only',
    'Sunday Only',
    'Rotational Off Days',
  ];

  static const List<String> weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static final List<String> yearlyBenefits = [
    'Annual Bonus (1 Month Salary)',
    'Air Ticket Allowance (Annual Return Ticket)',
    'Medical Insurance (Class A - VIP Coverage)',
    '30 Days Paid Annual Vacation',
    'Housing Allowance (25% of Basic)',
    'Transportation Allowance (10% of Basic)',
    'End of Service Benefit (EOSB) as per Saudi Labor Law',
  ];

  static const List<String> popularSkills = [
    'Flutter & Dart',
    'ZATCA E-Invoicing',
    'Financial Accounting',
    'HR & Payroll Management',
    'Saudi Labor Law Compliance',
    'Node.js & TypeScript',
    'PostgreSQL / SQLite',
    'ERP Operations',
    'Project Management',
    'Sales & CRM',
    'Customer Relations',
  ];

  static void addDepartment(String name) {
    final trimmed = name.trim();
    if (trimmed.isNotEmpty && !departments.contains(trimmed)) {
      departments.insert(0, trimmed);
    }
  }

  static void addDesignation(String name) {
    final trimmed = name.trim();
    if (trimmed.isNotEmpty && !designations.contains(trimmed)) {
      designations.insert(0, trimmed);
    }
  }

  static void addYearlyBenefit(String name) {
    final trimmed = name.trim();
    if (trimmed.isNotEmpty && !yearlyBenefits.contains(trimmed)) {
      yearlyBenefits.insert(0, trimmed);
    }
  }
}
