import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../data/settings_api.dart';

final settingsApiProvider = Provider<SettingsApi>((ref) {
  final dio = ref.watch(dioProvider);
  return SettingsApi(dio);
});

final productPolicyProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.watch(settingsApiProvider);
  final response = await api.getProductPolicy();
  return response as Map<String, dynamic>;
});

final receiptSettingsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.watch(settingsApiProvider);
  final response = await api.getReceiptSettings();
  return response as Map<String, dynamic>;
});

final branchesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ref.watch(settingsApiProvider);
  final response = await api.getBranches();
  return (response['branches'] as List<dynamic>?) ?? [];
});

final usersProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ref.watch(settingsApiProvider);
  final response = await api.getUsers();
  return (response['users'] as List<dynamic>?) ?? [];
});

final warehousesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ref.watch(settingsApiProvider);
  final response = await api.getWarehouses();
  return (response['warehouses'] as List<dynamic>?) ?? [];
});

final purchaseFlowSettingsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.watch(settingsApiProvider);
  final response = await api.getPurchaseFlowSettings();
  return response as Map<String, dynamic>;
});

final activePurchaseFlowProvider = Provider<String>((ref) {
  final settings = ref.watch(purchaseFlowSettingsProvider).valueOrNull;
  return settings?['purchaseFlowType'] as String? ?? 'NORMAL';
});

final smtpSettingsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.watch(settingsApiProvider);
  final response = await api.getSmtpSettings();
  if (response is Map<String, dynamic> && response.containsKey('smtpSettings')) {
    return response['smtpSettings'] as Map<String, dynamic>;
  }
  return (response as Map<String, dynamic>?) ?? {};
});



