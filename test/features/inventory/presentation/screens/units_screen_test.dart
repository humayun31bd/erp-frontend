import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erp_frontend/features/inventory/presentation/screens/units_screen.dart';
import 'package:erp_frontend/features/inventory/providers/unit_provider.dart';

class MockUnitNotifier extends StateNotifier<AsyncValue<List<UnitModel>>> implements UnitNotifier {
  @override
  final Ref ref;
  MockUnitNotifier(this.ref, AsyncValue<List<UnitModel>> state) : super(state);
  @override
  Future<void> fetchUnits() async {}
  @override
  Future<bool> createUnit(String name, String shortName, bool baseUnit) async => true;
  @override
  Future<bool> updateUnit(String id, String name, String shortName, bool baseUnit) async => true;
  @override
  Future<bool> deleteUnit(String id) async => true;
}

void main() {
  testWidgets('UnitsScreen displays a list of units', (WidgetTester tester) async {
    final List<UnitModel> mockUnits = [
      UnitModel(id: '1', name: 'Kilogram', shortName: 'kg', baseUnit: true),
      UnitModel(id: '2', name: 'Gram', shortName: 'g', baseUnit: false),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          unitProvider.overrideWith((ref) => MockUnitNotifier(ref, AsyncValue.data(mockUnits))),
        ],
        child: const MaterialApp(
          home: UnitsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Units'), findsWidgets);
    expect(find.text('Kilogram'), findsOneWidget);
    expect(find.text('Short Name: kg | Base Unit: Yes'), findsOneWidget);
    expect(find.text('Gram'), findsOneWidget);
    expect(find.text('Short Name: g | Base Unit: No'), findsOneWidget);
    expect(find.byIcon(Icons.edit), findsNWidgets(2));
    expect(find.byIcon(Icons.delete), findsNWidgets(2));
    expect(find.text('Add Unit'), findsOneWidget);
  });
}
