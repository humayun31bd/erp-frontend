import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erp_frontend/features/inventory/presentation/screens/variable_products_screen.dart';
import 'package:erp_frontend/features/inventory/providers/variable_provider.dart';

class MockVariableNotifier extends StateNotifier<AsyncValue<List<VariableTemplate>>> implements VariableNotifier {
  @override
  final Ref ref;
  MockVariableNotifier(this.ref, AsyncValue<List<VariableTemplate>> state) : super(state);
  @override
  Future<void> fetchVariables() async {}
  @override
  Future<bool> createVariable(String name, List<String> values) async => true;
  @override
  Future<bool> updateVariable(String id, String name, List<String> values) async => true;
  @override
  Future<bool> deleteVariable(String id) async => true;
}

void main() {
  testWidgets('VariableProductsScreen displays a list of variable templates', (WidgetTester tester) async {
    final mockVariables = [
      VariableTemplate(
        id: '1',
        name: 'Size',
        values: [VariableValue(id: 'v1', value: 'Small'), VariableValue(id: 'v2', value: 'Large')],
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          variableProvider.overrideWith((ref) => MockVariableNotifier(ref, AsyncValue.data(mockVariables))),
        ],
        child: const MaterialApp(
          home: VariableProductsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Variable Settings'), findsWidgets);
    expect(find.text('Size'), findsOneWidget);
    expect(find.text('Values: Small, Large'), findsOneWidget);
    expect(find.byIcon(Icons.edit), findsOneWidget);
    expect(find.byIcon(Icons.delete), findsOneWidget);
    expect(find.text('Add Variable'), findsOneWidget);
  });
}
