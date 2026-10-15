import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:erp_frontend/features/pos/presentation/widgets/plan_guard_modal.dart';
import 'package:erp_frontend/core/providers/tenant_settings_provider.dart';
import 'package:erp_frontend/features/settings/domain/tenant_preset_models.dart';

void main() {
  testWidgets('PlanGuardModal renders feature name, required plan, and action buttons', (WidgetTester tester) async {
    final testTenant = TenantSetupModel.fromPreset(
      CountryPreset.findByCode('SA'),
      marketingPlan: 'STARTER',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tenantSettingsProvider.overrideWith((ref) => TenantSettingsNotifier(Dio(), initialSettings: testTenant)),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: PlanGuardModal(
              featureKey: 'holdCart',
              featureName: 'Order Holding & Multi-Cart Parking',
              requiredPlan: 'Standard',
            ),
          ),
        ),
      ),
    );

    // Verify feature name is displayed
    expect(find.text('Order Holding & Multi-Cart Parking'), findsOneWidget);
    expect(find.text('FEATURE LOCKED'), findsOneWidget);

    // Verify current plan and required plan pills
    expect(find.text('STARTER'), findsOneWidget);
    expect(find.text('STANDARD TIER'), findsOneWidget);

    // Verify buttons
    expect(find.text('Maybe Later'), findsOneWidget);
    expect(find.text('View Plans & Upgrade'), findsOneWidget);
  });
}
