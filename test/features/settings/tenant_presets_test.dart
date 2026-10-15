import 'package:flutter_test/flutter_test.dart';
import 'package:erp_frontend/features/settings/domain/tenant_preset_models.dart';

void main() {
  group('CountryPreset Multi-Region Model Tests', () {
    test('supportedCountries contains all 7 mandatory region presets', () {
      const countries = CountryPreset.supportedCountries;
      expect(countries.length, 7);

      final countryCodes = countries.map((c) => c.countryCode).toSet();
      expect(countryCodes, containsAll(['SA', 'AE', 'OM', 'BH', 'QA', 'KW', 'BD']));
    });

    test('findByCode finds country case-insensitively and falls back to default', () {
      final sa = CountryPreset.findByCode('sa');
      expect(sa.countryCode, 'SA');
      expect(sa.compliance, ComplianceEngine.zatca);
      expect(sa.currencyCode, 'SAR');

      final bd = CountryPreset.findByCode('BD');
      expect(bd.countryCode, 'BD');
      expect(bd.compliance, ComplianceEngine.nbrBangladesh);
      expect(bd.currencyCode, 'BDT');

      final unknown = CountryPreset.findByCode('XYZ');
      expect(unknown.countryCode, 'SA'); // Fallback to Saudi Arabia default
    });

    test('GCC 3-decimal currencies have decimalPlaces == 3', () {
      final om = CountryPreset.findByCode('OM');
      final bh = CountryPreset.findByCode('BH');
      final kw = CountryPreset.findByCode('KW');

      expect(om.decimalPlaces, 3);
      expect(bh.decimalPlaces, 3);
      expect(kw.decimalPlaces, 3);
    });

    test('2-decimal currencies have decimalPlaces == 2', () {
      final sa = CountryPreset.findByCode('SA');
      final ae = CountryPreset.findByCode('AE');
      final qa = CountryPreset.findByCode('QA');
      final bd = CountryPreset.findByCode('BD');

      expect(sa.decimalPlaces, 2);
      expect(ae.decimalPlaces, 2);
      expect(qa.decimalPlaces, 2);
      expect(bd.decimalPlaces, 2);
    });
  });

  group('TenantSetupModel Currency & Tax Formatting Tests', () {
    test('formatCurrency formats 2-decimal SAR correctly', () {
      final saPreset = CountryPreset.findByCode('SA');
      final tenant = TenantSetupModel.fromPreset(saPreset);

      expect(tenant.formatCurrency(125.5), '125.50 ر.س');
      expect(tenant.formatCurrency(0.0), '0.00 ر.س');
      expect(tenant.formatCurrency(1299.99), '1299.99 ر.س');
    });

    test('formatCurrency formats 3-decimal OMR correctly', () {
      final omPreset = CountryPreset.findByCode('OM');
      final tenant = TenantSetupModel.fromPreset(omPreset);

      expect(tenant.formatCurrency(12.5), '12.500 ر.ع.');
      expect(tenant.formatCurrency(0.125), '0.125 ر.ع.');
      expect(tenant.formatCurrency(50.0), '50.000 ر.ع.');
    });

    test('formatCurrency formats 3-decimal KWD correctly', () {
      final kwPreset = CountryPreset.findByCode('KW');
      final tenant = TenantSetupModel.fromPreset(kwPreset);

      expect(tenant.formatCurrency(4.75), '4.750 د.ك');
      expect(tenant.formatCurrency(100.0), '100.000 د.ك');
    });

    test('formatCurrency formats BDT with prefix symbol correctly', () {
      final bdPreset = CountryPreset.findByCode('BD');
      final tenant = TenantSetupModel.fromPreset(bdPreset);

      expect(tenant.formatCurrency(550.0), '৳ 550.00');
      expect(tenant.formatCurrency(1250.75), '৳ 1250.75');
    });

    test('formatTax computes 15% ZATCA VAT in Saudi Arabia correctly', () {
      final saPreset = CountryPreset.findByCode('SA');
      final tenant = TenantSetupModel.fromPreset(saPreset);

      // 100 * 15% = 15.00 SAR
      expect(tenant.formatTax(100.0), '15.00 ر.س');
      // 200 * 15% = 30.00 SAR
      expect(tenant.formatTax(200.0), '30.00 ر.س');
    });

    test('formatTax computes 5% UAE FTA VAT correctly', () {
      final aePreset = CountryPreset.findByCode('AE');
      final tenant = TenantSetupModel.fromPreset(aePreset);

      // 100 * 5% = 5.00 AED
      expect(tenant.formatTax(100.0), '5.00 د.إ');
    });

    test('formatTax computes 0% in Qatar and Kuwait correctly', () {
      final qaPreset = CountryPreset.findByCode('QA');
      final kwPreset = CountryPreset.findByCode('KW');

      final qaTenant = TenantSetupModel.fromPreset(qaPreset);
      final kwTenant = TenantSetupModel.fromPreset(kwPreset);

      expect(qaTenant.formatTax(150.0), '0.00 ر.ق');
      expect(kwTenant.formatTax(150.0), '0.000 د.ك');
    });
  });
}
