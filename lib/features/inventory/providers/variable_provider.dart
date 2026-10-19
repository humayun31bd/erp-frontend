import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../features/auth/providers/auth_provider.dart';

class VariableValue {
  final String id;
  final String value;

  VariableValue({required this.id, required this.value});

  factory VariableValue.fromJson(Map<String, dynamic> json) {
    return VariableValue(
      id: (json['id'] ?? '').toString(),
      value: (json['value'] ?? '').toString(),
    );
  }
}

class VariableTemplate {
  final String id;
  final String name;
  final List<VariableValue> values;

  VariableTemplate({required this.id, required this.name, required this.values});

  factory VariableTemplate.fromJson(Map<String, dynamic> json) {
    final rawValues = json['values'] is List ? json['values'] as List : [];
    return VariableTemplate(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      values: rawValues
          .whereType<Map<String, dynamic>>()
          .map((v) => VariableValue.fromJson(v))
          .toList(),
    );
  }
}

class VariableNotifier extends StateNotifier<AsyncValue<List<VariableTemplate>>> {
  final Ref ref;

  VariableNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchVariables();
  }

  Future<void> fetchVariables() async {
    try {
      state = const AsyncValue.loading();
      final dio = ref.read(dioProvider);
      final tenantId = ref.read(tenantIdProvider);

      final response = await dio.get(
        '/inventory/variables',
        options: Options(headers: {'x-tenant-id': tenantId}),
      );

      final dynamic data = response.data;
      final List rawList = data is List
          ? data
          : (data is Map && data['data'] is List ? data['data'] as List : []);

      final List<VariableTemplate> variables = rawList
          .whereType<Map<String, dynamic>>()
          .map((json) => VariableTemplate.fromJson(json))
          .toList();

      state = AsyncValue.data(variables);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> createVariable(String name, List<String> values) async {
    try {
      final dio = ref.read(dioProvider);
      final tenantId = ref.read(tenantIdProvider);
      
      await dio.post(
        '/inventory/variables',
        data: {'name': name, 'values': values},
        options: Options(headers: {'x-tenant-id': tenantId}),
      );
      
      await fetchVariables();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateVariable(String id, String name, List<String> values) async {
    try {
      final dio = ref.read(dioProvider);
      final tenantId = ref.read(tenantIdProvider);
      
      await dio.put(
        '/inventory/variables/$id',
        data: {'name': name, 'values': values},
        options: Options(headers: {'x-tenant-id': tenantId}),
      );
      
      await fetchVariables();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteVariable(String id) async {
    try {
      final dio = ref.read(dioProvider);
      final tenantId = ref.read(tenantIdProvider);
      
      await dio.delete(
        '/inventory/variables/$id',
        options: Options(headers: {'x-tenant-id': tenantId}),
      );
      
      await fetchVariables();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final variableProvider = StateNotifierProvider<VariableNotifier, AsyncValue<List<VariableTemplate>>>((ref) {
  return VariableNotifier(ref);
});
