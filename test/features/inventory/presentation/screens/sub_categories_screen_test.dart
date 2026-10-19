import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erp_frontend/features/inventory/presentation/screens/sub_categories_screen.dart';
import 'package:erp_frontend/features/inventory/providers/category_provider.dart';
import 'package:erp_frontend/features/inventory/providers/sub_category_provider.dart';

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

class MockSubCategoryNotifier extends StateNotifier<AsyncValue<List<SubCategory>>> implements SubCategoryNotifier {
  @override
  final Ref ref;
  MockSubCategoryNotifier(this.ref, AsyncValue<List<SubCategory>> state) : super(state);
  @override
  Future<void> fetchSubCategories() async {}
  @override
  Future<bool> createSubCategory(String name, String categoryId, String? description) async => true;
  @override
  Future<bool> updateSubCategory(String id, String name, String categoryId, String? description) async => true;
  @override
  Future<bool> deleteSubCategory(String id) async => true;
}

void main() {
  testWidgets('SubCategoriesScreen displays a list of sub-categories', (WidgetTester tester) async {
    final mockCategories = [
      Category(id: 'cat1', name: 'Electronics'),
    ];
    final List<SubCategory> mockSubCategories = [
      SubCategory(id: '1', categoryId: 'cat1', name: 'Phones', description: 'Smartphones'),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          categoryProvider.overrideWith((ref) => MockCategoryNotifier(ref, AsyncValue.data(mockCategories))),
          subCategoryProvider.overrideWith((ref) => MockSubCategoryNotifier(ref, AsyncValue.data(mockSubCategories))),
        ],
        child: const MaterialApp(
          home: SubCategoriesScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Sub-Categories'), findsWidgets);
    expect(find.text('Phones'), findsOneWidget);
    expect(find.textContaining('Parent: Electronics'), findsOneWidget);
    expect(find.textContaining('Smartphones'), findsOneWidget);
    expect(find.byIcon(Icons.edit), findsOneWidget);
    expect(find.byIcon(Icons.delete), findsOneWidget);
    expect(find.text('Add Sub-Category'), findsOneWidget);
  });
}
