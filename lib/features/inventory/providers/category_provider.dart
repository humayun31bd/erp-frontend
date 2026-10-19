import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../features/auth/providers/auth_provider.dart';

class Category {
  final String id;
  final String name;
  final String? description;

  Category({required this.id, required this.name, this.description});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
    );
  }
}

class CategoryNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final Ref ref;

  CategoryNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      state = const AsyncValue.loading();
      final dio = ref.read(dioProvider);
      final tenantId = ref.read(tenantIdProvider);

      final response = await dio.get(
        '/inventory/categories',
        options: Options(headers: {'x-tenant-id': tenantId}),
      );

      final dynamic data = response.data;
      final List rawList = data is List
          ? data
          : (data is Map && data['data'] is List ? data['data'] as List : []);

      final List<Category> categories = rawList
          .whereType<Map<String, dynamic>>()
          .map((json) => Category.fromJson(json))
          .toList();

      state = AsyncValue.data(categories);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> createCategory(String name, String? description) async {
    try {
      final dio = ref.read(dioProvider);
      final tenantId = ref.read(tenantIdProvider);
      
      await dio.post(
        '/inventory/categories',
        data: {'name': name, 'description': description},
        options: Options(headers: {'x-tenant-id': tenantId}),
      );
      
      await fetchCategories();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateCategory(String id, String name, String? description) async {
    try {
      final dio = ref.read(dioProvider);
      final tenantId = ref.read(tenantIdProvider);
      
      await dio.put(
        '/inventory/categories/$id',
        data: {'name': name, 'description': description},
        options: Options(headers: {'x-tenant-id': tenantId}),
      );
      
      await fetchCategories();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      final dio = ref.read(dioProvider);
      final tenantId = ref.read(tenantIdProvider);
      
      await dio.delete(
        '/inventory/categories/$id',
        options: Options(headers: {'x-tenant-id': tenantId}),
      );
      
      await fetchCategories();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final categoryProvider = StateNotifierProvider<CategoryNotifier, AsyncValue<List<Category>>>((ref) {
  return CategoryNotifier(ref);
});
