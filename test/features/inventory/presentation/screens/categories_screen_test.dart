import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erp_frontend/features/inventory/presentation/screens/categories_screen.dart';
import 'package:erp_frontend/features/inventory/providers/category_provider.dart';

class MockCategoryNotifier extends StateNotifier<AsyncValue<List<Category>>> implements CategoryNotifier {
  @override
  final Ref ref;
  MockCategoryNotifier(this.ref, AsyncValue<List<Category>> state) : super(state);

  @override
  Future<void> fetchCategories() async {}

  @override
  Future<bool> createCategory(String name, String? description) async => true;

  @override
  Future<bool> updateCategory(String id, String name, String? description) async => true;

  @override
  Future<bool> deleteCategory(String id) async => true;
}

void main() {
  testWidgets('CategoriesScreen displays a list of categories', (WidgetTester tester) async {
    final mockCategories = [
      Category(id: '1', name: 'Electronics', description: 'Gadgets and devices'),
      Category(id: '2', name: 'Clothing', description: 'Apparel and accessories'),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          categoryProvider.overrideWith((ref) => MockCategoryNotifier(ref, AsyncValue.data(mockCategories))),
        ],
        child: const MaterialApp(
          home: CategoriesScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Categories'), findsWidgets);
    expect(find.text('Electronics'), findsOneWidget);
    expect(find.text('Gadgets and devices'), findsOneWidget);
    expect(find.text('Clothing'), findsOneWidget);
    expect(find.text('Apparel and accessories'), findsOneWidget);
    expect(find.byIcon(Icons.edit), findsNWidgets(2));
    expect(find.byIcon(Icons.delete), findsNWidgets(2));
    expect(find.text('Add Category'), findsOneWidget);
  });

  testWidgets('CategoriesScreen displays empty state when no categories', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          categoryProvider.overrideWith((ref) => MockCategoryNotifier(ref, const AsyncValue.data([]))),
        ],
        child: const MaterialApp(
          home: CategoriesScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No categories found.'), findsOneWidget);
    expect(find.byIcon(Icons.category_outlined), findsOneWidget);
  });

  testWidgets('CategoriesScreen displays loading indicator', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          categoryProvider.overrideWith((ref) => MockCategoryNotifier(ref, const AsyncValue.loading())),
        ],
        child: const MaterialApp(
          home: CategoriesScreen(),
        ),
      ),
    );

    // Don't pumpAndSettle because CircularProgressIndicator animates infinitely
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
