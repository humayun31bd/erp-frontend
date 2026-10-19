/// Customer type enum — matches newcustomers.md taxonomy.
enum CustomerType {
  newCustomer,
  repeat,
  loyal,
  impulseBuyer,
  needBased,
  discountDriven,
  lapsed,
}

extension CustomerTypeX on CustomerType {
  String get label {
    switch (this) {
      case CustomerType.newCustomer:    return 'New Customer';
      case CustomerType.repeat:         return 'Repeat';
      case CustomerType.loyal:          return 'Loyal';
      case CustomerType.impulseBuyer:   return 'Impulse Buyer';
      case CustomerType.needBased:      return 'Need-Based';
      case CustomerType.discountDriven: return 'Discount-Driven';
      case CustomerType.lapsed:         return 'Lapsed';
    }
  }

  String getLabel(bool isArabic) {
    if (!isArabic) return label;
    switch (this) {
      case CustomerType.newCustomer:    return 'عميل جديد';
      case CustomerType.repeat:         return 'عميل متكرر';
      case CustomerType.loyal:          return 'عميل دائم (مخلص)';
      case CustomerType.impulseBuyer:   return 'مشتري عابر';
      case CustomerType.needBased:      return 'مشتري عند الحاجة';
      case CustomerType.discountDriven: return 'مشتري العروض';
      case CustomerType.lapsed:         return 'عميل منقطع';
    }
  }

  static CustomerType fromString(String? s) {
    return CustomerType.values.firstWhere(
      (e) => e.name == s,
      orElse: () => CustomerType.newCustomer,
    );
  }
}

