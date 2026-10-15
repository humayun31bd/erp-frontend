import 'package:flutter/material.dart';

enum ComplianceEngine {
  zatca('ZATCA (Phase 1 & 2)', 'Saudi Arabia Tax & Customs Authority e-Invoicing'),
  fta('UAE FTA', 'United Arab Emirates Federal Tax Authority'),
  ota('Oman OTA', 'Oman Tax Authority VAT Compliance'),
  nbrBahrain('Bahrain NBR', 'National Bureau for Revenue Bahrain'),
  gtaQatar('Qatar GTA', 'General Tax Authority Qatar'),
  mofKuwait('Kuwait MOF', 'Ministry of Finance Kuwait'),
  nbrBangladesh('NBR (Mushuk 6.3)', 'National Board of Revenue Bangladesh VAT Challan');

  final String title;
  final String description;
  const ComplianceEngine(this.title, this.description);
}

enum BusinessType {
  retail('Retail POS', Icons.storefront_rounded),
  pharmacy('Pharmacy POS', Icons.local_pharmacy_rounded),
  grocery('Grocery POS', Icons.local_grocery_store_rounded),
  beautySalon('Beauty & Salon POS', Icons.content_cut_rounded),
  restaurant('Restaurant POS', Icons.restaurant_rounded),
  laundry('Laundry POS', Icons.local_laundry_service_rounded),
  shoeStore('Shoe Store POS', Icons.shopping_bag_rounded);

  final String label;
  final IconData icon;
  const BusinessType(this.label, this.icon);

  List<String> get specializedFeatures {
    switch (this) {
      case BusinessType.retail:
        return [
          'Service & Physical Products',
          'Standard Barcode Scanning',
          'Variants (Size/Color)',
          'Store Credit & Layaway'
        ];
      case BusinessType.pharmacy:
        return [
          'Medicine Expiry Date Alert',
          'Batch & Lot Management',
          'Dosage / Strip Unit Conversions',
          'Prescription Reference'
        ];
      case BusinessType.grocery:
        return [
          'Weight Scale (RS-232/USB)',
          'Price-Embedded Barcodes (Prefix 20/02)',
          'Fast Perishable Expiry Alert',
          'Loose Product Weighing'
        ];
      case BusinessType.beautySalon:
        return [
          'Service-based Invoicing',
          'Staff / Beautician Commission',
          'Appointment Booking Calendar',
          'Package / Treatment Bundles'
        ];
      case BusinessType.restaurant:
        return [
          'Table Management & Floor Layout',
          'Kitchen Display System (KDS)',
          'Order Types (Dine-in, Takeaway, Delivery)',
          'Waiter Registration & Table Assignment',
          'Recipe & BOM Manufacturing',
          'Menu Modifiers & Set Menus'
        ];
      case BusinessType.laundry:
        return [
          'Service-type Item Billing (Wash/Iron/Dry)',
          'Garment Tagging & Bag Barcodes',
          'Pickup & Delivery Scheduling',
          'Ready-for-Pickup WhatsApp Alerts'
        ];
      case BusinessType.shoeStore:
        return [
          'Matrix Grid (Brand x Size x Color)',
          'Single-Box Barcode Scanning',
          'Serial & Warranty Tracking',
          'Replacement & Sizing Exchanges'
        ];
    }
  }
}

class CountryPreset {
  final String countryCode;
  final String countryName;
  final String flagEmoji;
  final String currencyCode;
  final String currencySymbol;
  final int decimalPlaces;
  final double defaultTaxRate;
  final String taxType;
  final String timezone;
  final String dateFormat;
  final String numberFormat;
  final ComplianceEngine compliance;
  final String primaryLanguage;
  final String secondaryLanguage;
  final String? tertiaryLanguage;

  const CountryPreset({
    required this.countryCode,
    required this.countryName,
    required this.flagEmoji,
    required this.currencyCode,
    required this.currencySymbol,
    required this.decimalPlaces,
    required this.defaultTaxRate,
    required this.taxType,
    required this.timezone,
    required this.dateFormat,
    required this.numberFormat,
    required this.compliance,
    required this.primaryLanguage,
    required this.secondaryLanguage,
    this.tertiaryLanguage,
  });

  static const List<CountryPreset> supportedCountries = [
    CountryPreset(
      countryCode: 'SA',
      countryName: 'Saudi Arabia',
      flagEmoji: '🇸🇦',
      currencyCode: 'SAR',
      currencySymbol: 'ر.س',
      decimalPlaces: 2,
      defaultTaxRate: 15.0,
      taxType: 'VAT (ضريبة القيمة المضافة)',
      timezone: 'Asia/Riyadh',
      dateFormat: 'YYYY-MM-DD',
      numberFormat: '#,##0.00',
      compliance: ComplianceEngine.zatca,
      primaryLanguage: 'ar',
      secondaryLanguage: 'en',
    ),
    CountryPreset(
      countryCode: 'AE',
      countryName: 'United Arab Emirates',
      flagEmoji: '🇦🇪',
      currencyCode: 'AED',
      currencySymbol: 'د.إ',
      decimalPlaces: 2,
      defaultTaxRate: 5.0,
      taxType: 'VAT (ضريبة القيمة المضافة)',
      timezone: 'Asia/Dubai',
      dateFormat: 'DD/MM/YYYY',
      numberFormat: '#,##0.00',
      compliance: ComplianceEngine.fta,
      primaryLanguage: 'ar',
      secondaryLanguage: 'en',
    ),
    CountryPreset(
      countryCode: 'OM',
      countryName: 'Oman',
      flagEmoji: '🇴🇲',
      currencyCode: 'OMR',
      currencySymbol: 'ر.ع.',
      decimalPlaces: 3,
      defaultTaxRate: 5.0,
      taxType: 'VAT (ضريبة القيمة المضافة)',
      timezone: 'Asia/Muscat',
      dateFormat: 'DD/MM/YYYY',
      numberFormat: '#,##0.000',
      compliance: ComplianceEngine.ota,
      primaryLanguage: 'ar',
      secondaryLanguage: 'en',
    ),
    CountryPreset(
      countryCode: 'BH',
      countryName: 'Bahrain',
      flagEmoji: '🇧🇭',
      currencyCode: 'BHD',
      currencySymbol: 'د.ب',
      decimalPlaces: 3,
      defaultTaxRate: 10.0,
      taxType: 'VAT (ضريبة القيمة المضافة)',
      timezone: 'Asia/Bahrain',
      dateFormat: 'DD/MM/YYYY',
      numberFormat: '#,##0.000',
      compliance: ComplianceEngine.nbrBahrain,
      primaryLanguage: 'ar',
      secondaryLanguage: 'en',
    ),
    CountryPreset(
      countryCode: 'QA',
      countryName: 'Qatar',
      flagEmoji: '🇶🇦',
      currencyCode: 'QAR',
      currencySymbol: 'ر.ق',
      decimalPlaces: 2,
      defaultTaxRate: 0.0,
      taxType: 'Exempt / No VAT',
      timezone: 'Asia/Qatar',
      dateFormat: 'DD/MM/YYYY',
      numberFormat: '#,##0.00',
      compliance: ComplianceEngine.gtaQatar,
      primaryLanguage: 'ar',
      secondaryLanguage: 'en',
    ),
    CountryPreset(
      countryCode: 'KW',
      countryName: 'Kuwait',
      flagEmoji: '🇰🇼',
      currencyCode: 'KWD',
      currencySymbol: 'د.ك',
      decimalPlaces: 3,
      defaultTaxRate: 0.0,
      taxType: 'Exempt / No VAT',
      timezone: 'Asia/Kuwait',
      dateFormat: 'DD/MM/YYYY',
      numberFormat: '#,##0.000',
      compliance: ComplianceEngine.mofKuwait,
      primaryLanguage: 'ar',
      secondaryLanguage: 'en',
    ),
    CountryPreset(
      countryCode: 'BD',
      countryName: 'Bangladesh',
      flagEmoji: '🇧🇩',
      currencyCode: 'BDT',
      currencySymbol: '৳',
      decimalPlaces: 2,
      defaultTaxRate: 15.0,
      taxType: 'VAT / মূসক (Mushuk 6.3)',
      timezone: 'Asia/Dhaka',
      dateFormat: 'DD-MM-YYYY',
      numberFormat: '#,##0.00',
      compliance: ComplianceEngine.nbrBangladesh,
      primaryLanguage: 'bn',
      secondaryLanguage: 'en',
      tertiaryLanguage: 'ar',
    ),
  ];

  static CountryPreset findByCode(String? code) {
    if (code == null) return supportedCountries.first;
    return supportedCountries.firstWhere(
      (c) => c.countryCode.toUpperCase() == code.toUpperCase(),
      orElse: () => supportedCountries.first,
    );
  }
}

class TenantSetupModel {
  final String? tenantId;
  final String name;
  final String vatNumber;
  final String email;
  final String phone;
  final String address;
  final String code;
  final String logoUrl;
  final String status;
  final CountryPreset country;
  final BusinessType businessType;
  final String marketingPlan;
  final String currencyCode;
  final String currencySymbol;
  final int decimalPlaces;
  final double taxRate;
  final String taxType;
  final String timezone;
  final String dateFormat;
  final String numberFormat;
  final String primaryLanguage;
  final String secondaryLanguage;
  final String? tertiaryLanguage;

  const TenantSetupModel({
    this.tenantId,
    required this.name,
    required this.vatNumber,
    required this.email,
    required this.phone,
    required this.address,
    required this.code,
    required this.logoUrl,
    this.status = 'ACTIVE',
    required this.country,
    this.businessType = BusinessType.retail,
    this.marketingPlan = 'STANDARD',
    required this.currencyCode,
    required this.currencySymbol,
    required this.decimalPlaces,
    required this.taxRate,
    required this.taxType,
    required this.timezone,
    required this.dateFormat,
    required this.numberFormat,
    required this.primaryLanguage,
    required this.secondaryLanguage,
    this.tertiaryLanguage,
  });

  factory TenantSetupModel.fromPreset(
    CountryPreset preset, {
    String name = 'My Business Chain',
    String vatNumber = '',
    String email = 'info@business.com',
    String phone = '',
    String address = '',
    String code = 'STORE-01',
    String logoUrl = '',
    BusinessType businessType = BusinessType.retail,
    String marketingPlan = 'STANDARD',
  }) {
    return TenantSetupModel(
      name: name,
      vatNumber: vatNumber,
      email: email,
      phone: phone,
      address: address,
      code: code,
      logoUrl: logoUrl,
      country: preset,
      businessType: businessType,
      marketingPlan: marketingPlan,
      currencyCode: preset.currencyCode,
      currencySymbol: preset.currencySymbol,
      decimalPlaces: preset.decimalPlaces,
      taxRate: preset.defaultTaxRate,
      taxType: preset.taxType,
      timezone: preset.timezone,
      dateFormat: preset.dateFormat,
      numberFormat: preset.numberFormat,
      primaryLanguage: preset.primaryLanguage,
      secondaryLanguage: preset.secondaryLanguage,
      tertiaryLanguage: preset.tertiaryLanguage,
    );
  }

  factory TenantSetupModel.fromJson(Map<String, dynamic> json) {
    final countryCode = json['countryCode'] as String? ?? 'SA';
    final preset = CountryPreset.findByCode(countryCode);

    final bTypeString = json['businessType'] as String? ?? 'retail';
    final bType = BusinessType.values.firstWhere(
      (e) => e.name.toLowerCase() == bTypeString.toLowerCase(),
      orElse: () => BusinessType.retail,
    );

    return TenantSetupModel(
      tenantId: json['id'] as String? ?? json['tenantId'] as String?,
      name: json['name'] as String? ?? 'Business Company',
      vatNumber: json['vatNumber'] as String? ?? json['taxNumber'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['whatsappNumber'] as String? ?? json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      code: json['code'] as String? ?? json['subdomain'] as String? ?? 'STORE-01',
      logoUrl: json['logoUrl'] as String? ?? '',
      status: json['status'] as String? ?? 'ACTIVE',
      country: preset,
      businessType: bType,
      marketingPlan: json['marketingPlan'] as String? ?? 'STANDARD',
      currencyCode: json['currencyCode'] as String? ?? preset.currencyCode,
      currencySymbol: json['currencySymbol'] as String? ?? preset.currencySymbol,
      decimalPlaces: (json['decimalPlaces'] as num?)?.toInt() ?? preset.decimalPlaces,
      taxRate: (json['taxRate'] as num?)?.toDouble() ?? preset.defaultTaxRate,
      taxType: json['taxType'] as String? ?? preset.taxType,
      timezone: json['timezone'] as String? ?? preset.timezone,
      dateFormat: json['dateFormat'] as String? ?? preset.dateFormat,
      numberFormat: json['numberFormat'] as String? ?? preset.numberFormat,
      primaryLanguage: json['primaryLanguage'] as String? ?? preset.primaryLanguage,
      secondaryLanguage: json['secondaryLanguage'] as String? ?? preset.secondaryLanguage,
      tertiaryLanguage: json['tertiaryLanguage'] as String? ?? preset.tertiaryLanguage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': tenantId,
      'name': name,
      'vatNumber': vatNumber,
      'email': email,
      'whatsappNumber': phone,
      'address': address,
      'code': code,
      'logoUrl': logoUrl,
      'status': status,
      'countryCode': country.countryCode,
      'businessType': businessType.name,
      'marketingPlan': marketingPlan,
      'currencyCode': currencyCode,
      'currencySymbol': currencySymbol,
      'decimalPlaces': decimalPlaces,
      'taxRate': taxRate,
      'taxType': taxType,
      'timezone': timezone,
      'dateFormat': dateFormat,
      'numberFormat': numberFormat,
      'primaryLanguage': primaryLanguage,
      'secondaryLanguage': secondaryLanguage,
      'tertiaryLanguage': tertiaryLanguage,
    };
  }

  TenantSetupModel copyWith({
    String? tenantId,
    String? name,
    String? vatNumber,
    String? email,
    String? phone,
    String? address,
    String? code,
    String? logoUrl,
    String? status,
    CountryPreset? country,
    BusinessType? businessType,
    String? marketingPlan,
    String? currencyCode,
    String? currencySymbol,
    int? decimalPlaces,
    double? taxRate,
    String? taxType,
    String? timezone,
    String? dateFormat,
    String? numberFormat,
    String? primaryLanguage,
    String? secondaryLanguage,
    String? tertiaryLanguage,
  }) {
    return TenantSetupModel(
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      vatNumber: vatNumber ?? this.vatNumber,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      code: code ?? this.code,
      logoUrl: logoUrl ?? this.logoUrl,
      status: status ?? this.status,
      country: country ?? this.country,
      businessType: businessType ?? this.businessType,
      marketingPlan: marketingPlan ?? this.marketingPlan,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      decimalPlaces: decimalPlaces ?? this.decimalPlaces,
      taxRate: taxRate ?? this.taxRate,
      taxType: taxType ?? this.taxType,
      timezone: timezone ?? this.timezone,
      dateFormat: dateFormat ?? this.dateFormat,
      numberFormat: numberFormat ?? this.numberFormat,
      primaryLanguage: primaryLanguage ?? this.primaryLanguage,
      secondaryLanguage: secondaryLanguage ?? this.secondaryLanguage,
      tertiaryLanguage: tertiaryLanguage ?? this.tertiaryLanguage,
    );
  }

  String formatCurrency(double amount) {
    final fixed = amount.toStringAsFixed(decimalPlaces);
    if (country.countryCode == 'BD') {
      return '$currencySymbol $fixed';
    }
    return '$fixed $currencySymbol';
  }

  String formatTax(double subtotal) {
    final taxAmount = (subtotal * (taxRate / 100.0));
    return formatCurrency(taxAmount);
  }

  bool isFeatureEnabled(String featureKey) {
    final plan = marketingPlan.toUpperCase();

    switch (featureKey) {
      // PRO / AGENCY only features
      case 'aggregatorIntegration':
      case 'receiptCustomization':
      case 'loyaltyPoints':
      case 'advancedAnalytics':
        return plan == 'PRO' || plan == 'AGENCY';

      // STANDARD & PRO features (Locked on STARTER)
      case 'holdCart':
      case 'customerCredit':
      case 'multiCounter':
        return plan != 'STARTER';

      // Restaurant specific (requires Standard+ and Restaurant business type)
      case 'tableManagement':
      case 'waiterService':
      case 'kitchenTicket':
        return businessType == BusinessType.restaurant && plan != 'STARTER';

      // Advanced Restaurant KDS (requires Pro+ and Restaurant business type)
      case 'kds':
      case 'modifiers':
      case 'recipes':
        return businessType == BusinessType.restaurant && (plan == 'PRO' || plan == 'AGENCY');

      // Pharmacy & Grocery specialized
      case 'expiryAlert':
      case 'batchManagement':
        return businessType == BusinessType.pharmacy || businessType == BusinessType.grocery;

      // Weighing scale
      case 'weightScale':
        return businessType == BusinessType.grocery || businessType == BusinessType.retail;

      // Service specialized
      case 'appointmentBooking':
      case 'servicePricing':
        return businessType == BusinessType.beautySalon || businessType == BusinessType.laundry;

      default:
        return true;
    }
  }

  String getRequiredPlanForFeature(String featureKey) {
    switch (featureKey) {
      case 'aggregatorIntegration':
      case 'receiptCustomization':
      case 'loyaltyPoints':
      case 'kds':
      case 'modifiers':
      case 'recipes':
      case 'advancedAnalytics':
        return 'Pro';
      case 'holdCart':
      case 'tableManagement':
      case 'waiterService':
      case 'kitchenTicket':
      case 'customerCredit':
      case 'multiCounter':
        return 'Standard';
      default:
        return 'Starter';
    }
  }
}

