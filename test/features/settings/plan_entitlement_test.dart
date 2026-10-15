import 'package:flutter_test/flutter_test.dart';
import 'package:erp_frontend/features/settings/domain/tenant_preset_models.dart';

void main() {
  group('SaaS Plan Entitlement Gatekeeper Tests', () {
    final saPreset = CountryPreset.findByCode('SA');

    test('STARTER Plan locks high-tier and team features', () {
      final starterRetail = TenantSetupModel.fromPreset(
        saPreset,
        businessType: BusinessType.retail,
        marketingPlan: 'STARTER',
      );

      // Starter locks
      expect(starterRetail.isFeatureEnabled('holdCart'), isFalse);
      expect(starterRetail.isFeatureEnabled('tableManagement'), isFalse);
      expect(starterRetail.isFeatureEnabled('aggregatorIntegration'), isFalse);
      expect(starterRetail.isFeatureEnabled('kds'), isFalse);
      expect(starterRetail.isFeatureEnabled('receiptCustomization'), isFalse);
      expect(starterRetail.isFeatureEnabled('loyaltyPoints'), isFalse);
    });

    test('STANDARD Plan unlocks order holding and table management for restaurants', () {
      final standardRestaurant = TenantSetupModel.fromPreset(
        saPreset,
        businessType: BusinessType.restaurant,
        marketingPlan: 'STANDARD',
      );

      // Standard unlocks
      expect(standardRestaurant.isFeatureEnabled('holdCart'), isTrue);
      expect(standardRestaurant.isFeatureEnabled('tableManagement'), isTrue);
      expect(standardRestaurant.isFeatureEnabled('waiterService'), isTrue);
      expect(standardRestaurant.isFeatureEnabled('kitchenTicket'), isTrue);

      // Pro features still locked on Standard
      expect(standardRestaurant.isFeatureEnabled('kds'), isFalse);
      expect(standardRestaurant.isFeatureEnabled('aggregatorIntegration'), isFalse);
      expect(standardRestaurant.isFeatureEnabled('receiptCustomization'), isFalse);
    });

    test('PRO Plan unlocks all advanced features including KDS and Aggregators', () {
      final proRestaurant = TenantSetupModel.fromPreset(
        saPreset,
        businessType: BusinessType.restaurant,
        marketingPlan: 'PRO',
      );

      expect(proRestaurant.isFeatureEnabled('holdCart'), isTrue);
      expect(proRestaurant.isFeatureEnabled('tableManagement'), isTrue);
      expect(proRestaurant.isFeatureEnabled('kds'), isTrue);
      expect(proRestaurant.isFeatureEnabled('aggregatorIntegration'), isTrue);
      expect(proRestaurant.isFeatureEnabled('receiptCustomization'), isTrue);
      expect(proRestaurant.isFeatureEnabled('loyaltyPoints'), isTrue);
    });

    test('BusinessType specialization is strictly respected across plans', () {
      final proPharmacy = TenantSetupModel.fromPreset(
        saPreset,
        businessType: BusinessType.pharmacy,
        marketingPlan: 'PRO',
      );

      // Pharmacy features active
      expect(proPharmacy.isFeatureEnabled('batchManagement'), isTrue);
      expect(proPharmacy.isFeatureEnabled('expiryAlert'), isTrue);

      // Restaurant features inactive for Pharmacy even on PRO plan
      expect(proPharmacy.isFeatureEnabled('tableManagement'), isFalse);
      expect(proPharmacy.isFeatureEnabled('kds'), isFalse);

      final standardGrocery = TenantSetupModel.fromPreset(
        saPreset,
        businessType: BusinessType.grocery,
        marketingPlan: 'STANDARD',
      );
      expect(standardGrocery.isFeatureEnabled('weightScale'), isTrue);
      expect(standardGrocery.isFeatureEnabled('batchManagement'), isTrue);
    });

    test('getRequiredPlanForFeature reports correct minimum tier', () {
      final tenant = TenantSetupModel.fromPreset(saPreset);

      expect(tenant.getRequiredPlanForFeature('holdCart'), 'Standard');
      expect(tenant.getRequiredPlanForFeature('tableManagement'), 'Standard');
      expect(tenant.getRequiredPlanForFeature('waiterService'), 'Standard');
      expect(tenant.getRequiredPlanForFeature('aggregatorIntegration'), 'Pro');
      expect(tenant.getRequiredPlanForFeature('kds'), 'Pro');
      expect(tenant.getRequiredPlanForFeature('receiptCustomization'), 'Pro');
    });
  });
}
