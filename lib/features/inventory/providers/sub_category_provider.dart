import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../features/auth/providers/auth_provider.dart';

class SubCategory {
  final String id;
  final String categoryId;
  final String name;
  final String? description;

  SubCategory({required this.id, required this.categoryId, required this.name, this.description});

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: (json['id'] ?? '').toString(),
      categoryId: (json['categoryId'] ?? json['category_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
    );
  }
}

class SubCategoryNotifier extends StateNotifier<AsyncValue<List<SubCategory>>> {
  final Ref ref;

  SubCategoryNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchSubCategories();
  }

  Future<void> fetchSubCategories() async {
    try {
      state = const AsyncValue.loading();
      final dio = ref.read(dioProvider);
      final tenantId = ref.read(tenantIdProvider);

      final response = await dio.get(
        '/inventory/sub-categories',
        options: Options(headers: {'x-tenant-id': tenantId}),
      );

      final dynamic data = response.data;
      final List rawList = data is List
          ? data
          : (data is Map && data['data'] is List ? data['data'] as List : []);

      final List<SubCategory> subCategories = rawList
          .whereType<Map<String, dynamic>>()
          .map((json) => SubCategory.fromJson(json))
          .toList();

      state = AsyncValue.data(subCategories);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> createSubCategory(String name, String categoryId, String? description) async {
    try {
      final dio = ref.read(dioProvider);
      final tenantId = ref.read(tenantIdProvider);
      
      await dio.post(
        '/inventory/sub-categories',
        data: {'name': name, 'categoryId': categoryId, 'description': description},
        options: Options(headers: {'x-tenant-id': tenantId}),
      );
      
      await fetchSubCategories();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateSubCategory(String id, String name, String categoryId, String? description) async {
    try {
      final dio = ref.read(dioProvider);
      final tenantId = ref.read(tenantIdProvider);
      
      await dio.put(
        '/inventory/sub-categories/$id',
        data: {'name': name, 'categoryId': categoryId, 'description': description},
        options: Options(headers: {'x-tenant-id': tenantId}),
      );
      
      await fetchSubCategories();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteSubCategory(String id) async {
    try {
      final dio = ref.read(dioProvider);
      final tenantId = ref.read(tenantIdProvider);
      
      await dio.delete(
        '/inventory/sub-categories/$id',
        options: Options(headers: {'x-tenant-id': tenantId}),
      );
      
      await fetchSubCategories();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final subCategoryProvider = StateNotifierProvider<SubCategoryNotifier, AsyncValue<List<SubCategory>>>((ref) {
  return SubCategoryNotifier(ref);
});
