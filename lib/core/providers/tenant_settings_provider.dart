import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../network/dio_client.dart';
import '../../features/settings/domain/tenant_preset_models.dart';

class TenantSettingsNotifier extends StateNotifier<TenantSetupModel> {
  final Dio _dio;
  bool _isLoading = false;
  String? _error;

  TenantSettingsNotifier(this._dio, {TenantSetupModel? initialSettings})
      : super(initialSettings ?? TenantSetupModel.fromPreset(CountryPreset.supportedCountries.first)) {
    if (initialSettings == null) {
      loadTenantSettings();
    }
  }

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTenantSettings() async {
    _isLoading = true;
    _error = null;
    try {
      final response = await _dio.get('/settings/tenant');
      if (response.data != null && response.data['success'] == true && response.data['tenant'] != null) {
        state = TenantSetupModel.fromJson(response.data['tenant']);
      }
    } catch (e) {
      // Keep default preset if offline or not found
      _error = e.toString();
    } finally {
      _isLoading = false;
    }
  }

  /// Change country and automatically cascade preset defaults (currency, tax, decimals, timezone, format)
  void setCountry(CountryPreset preset, {bool autoCascade = true}) {
    if (autoCascade) {
      state = state.copyWith(
        country: preset,
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
    } else {
      state = state.copyWith(country: preset);
    }
  }

  void setBusinessType(BusinessType businessType) {
    state = state.copyWith(businessType: businessType);
  }

  void setMarketingPlan(String plan) {
    state = state.copyWith(marketingPlan: plan);
  }

  void updateCustomSettings({
    String? name,
    String? vatNumber,
    String? email,
    String? phone,
    String? address,
    String? code,
    String? logoUrl,
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
    state = state.copyWith(
      name: name,
      vatNumber: vatNumber,
      email: email,
      phone: phone,
      address: address,
      code: code,
      logoUrl: logoUrl,
      currencyCode: currencyCode,
      currencySymbol: currencySymbol,
      decimalPlaces: decimalPlaces,
      taxRate: taxRate,
      taxType: taxType,
      timezone: timezone,
      dateFormat: dateFormat,
      numberFormat: numberFormat,
      primaryLanguage: primaryLanguage,
      secondaryLanguage: secondaryLanguage,
      tertiaryLanguage: tertiaryLanguage,
    );
  }

  Future<bool> saveTenantSettings() async {
    try {
      await _dio.put('/settings/tenant', data: state.toJson());
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  String formatCurrency(double amount) {
    final fixed = amount.toStringAsFixed(state.decimalPlaces);
    // Left-to-right / right-to-left friendly display
    if (state.country.countryCode == 'BD') {
      return '${state.currencySymbol} $fixed';
    }
    return '$fixed ${state.currencySymbol}';
  }

  String formatTax(double subtotal) {
    final taxAmount = (subtotal * (state.taxRate / 100.0));
    return formatCurrency(taxAmount);
  }

  bool isFeatureEnabled(String featureKey) {
    final bType = state.businessType;
    switch (featureKey) {
      case 'tableManagement':
      case 'kds':
      case 'waiterService':
      case 'modifiers':
      case 'recipes':
        return bType == BusinessType.restaurant;
      case 'expiryAlert':
      case 'batchManagement':
        return bType == BusinessType.pharmacy || bType == BusinessType.grocery;
      case 'weightScale':
        return bType == BusinessType.grocery || bType == BusinessType.retail;
      case 'appointmentBooking':
      case 'servicePricing':
        return bType == BusinessType.beautySalon || bType == BusinessType.laundry;
      default:
        return true;
    }
  }
}

final tenantSettingsProvider =
    StateNotifierProvider<TenantSettingsNotifier, TenantSetupModel>((ref) {
  final dio = ref.watch(dioProvider);
  return TenantSettingsNotifier(dio);
});
