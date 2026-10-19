import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../features/auth/providers/auth_provider.dart';

class UnitModel {
  final String id;
  final String name;
  final String shortName;
  final bool baseUnit;

  UnitModel({required this.id, required this.name, required this.shortName, this.baseUnit = true});

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    final sName = (json['shortName'] ?? json['short_name'] ?? json['name'] ?? 'PCE').toString();
    return UnitModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? sName).toString(),
      shortName: sName.isEmpty ? 'PCE' : sName,
      baseUnit: json['baseUnit'] == true || json['base_unit'] == true || json['baseUnit'] == 1 || json['base_unit'] == 1,
    );
  }
}

class UnitNotifier extends StateNotifier<AsyncValue<List<UnitModel>>> {
  final Ref ref;

  UnitNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchUnits();
  }

  Future<void> fetchUnits() async {
    try {
      state = const AsyncValue.loading();
      final dio = ref.read(dioProvider);
      final tenantId = ref.read(tenantIdProvider);

      final response = await dio.get(
        '/inventory/units',
        options: Options(headers: {'x-tenant-id': tenantId}),
      );

      final dynamic data = response.data;
      final List rawList = data is List
          ? data
          : (data is Map && data['data'] is List ? data['data'] as List : []);

      final List<UnitModel> units = rawList
          .whereType<Map<String, dynamic>>()
          .map((json) => UnitModel.fromJson(json))
          .toList();

      state = AsyncValue.data(units);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> createUnit(String name, String shortName, bool baseUnit) async {
    try {
      final dio = ref.read(dioProvider);
      final tenantId = ref.read(tenantIdProvider);
      
      await dio.post(
        '/inventory/units',
        data: {'name': name, 'shortName': shortName, 'baseUnit': baseUnit},
        options: Options(headers: {'x-tenant-id': tenantId}),
      );
      
      await fetchUnits();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateUnit(String id, String name, String shortName, bool baseUnit) async {
    try {
      final dio = ref.read(dioProvider);
      final tenantId = ref.read(tenantIdProvider);
      
      await dio.put(
        '/inventory/units/$id',
        data: {'name': name, 'shortName': shortName, 'baseUnit': baseUnit},
        options: Options(headers: {'x-tenant-id': tenantId}),
      );
      
      await fetchUnits();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteUnit(String id) async {
    try {
      final dio = ref.read(dioProvider);
      final tenantId = ref.read(tenantIdProvider);
      
      await dio.delete(
        '/inventory/units/$id',
        options: Options(headers: {'x-tenant-id': tenantId}),
      );
      
      await fetchUnits();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final unitProvider = StateNotifierProvider<UnitNotifier, AsyncValue<List<UnitModel>>>((ref) {
  return UnitNotifier(ref);
});
