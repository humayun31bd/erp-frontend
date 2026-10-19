import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erp_frontend/features/inventory/presentation/screens/stock_management_screen.dart';
import 'package:erp_frontend/features/inventory/providers/stock_provider.dart';

class MockStockNotifier extends StateNotifier<AsyncValue<List<StockItem>>> implements StockNotifier {
  @override
  final Ref ref;
  MockStockNotifier(this.ref, AsyncValue<List<StockItem>> state) : super(state);
  @override
  Future<void> fetchStock() async {}
  @override
  Future<bool> updateStock(String id, int stockQuantity, int minStockLevel) async => true;
}

void main() {
  testWidgets('StockManagementScreen displays a list of stock items', (WidgetTester tester) async {
    final mockStock = [
      StockItem(id: '1', name: 'Product A', barcode: '123', stockQuantity: 50, minStockLevel: 10),
      StockItem(id: '2', name: 'Product B', barcode: '456', stockQuantity: 5, minStockLevel: 20), // Low stock
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stockProvider.overrideWith((ref) => MockStockNotifier(ref, AsyncValue.data(mockStock))),
        ],
        child: const MaterialApp(
          home: StockManagementScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Stock Management'), findsWidgets);
    expect(find.text('Product A'), findsOneWidget);
    expect(find.text('Barcode: 123 | Min Level: 10'), findsOneWidget);
    expect(find.text('50 in stock'), findsOneWidget);
    
    expect(find.text('Product B'), findsOneWidget);
    expect(find.text('Barcode: 456 | Min Level: 20'), findsOneWidget);
    expect(find.text('5 in stock'), findsOneWidget);

    expect(find.byIcon(Icons.edit), findsNWidgets(2));
  });
}
