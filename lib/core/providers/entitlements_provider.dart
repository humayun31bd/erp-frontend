import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../network/dio_client.dart';

class EntitlementsState {
  final String packagePlan;
  final Map<String, bool> featureFlags;
  final int maxBranches;
  final int maxUsers;
  final int currentUsersCount;
  final int monthlyBillLimit;
  final int monthlyBillsCount;
  final bool isBillQuotaExceeded;
  final bool isLoading;
  final String? error;

  EntitlementsState({
    this.packagePlan = 'FREE',
    this.featureFlags = const {},
    this.maxBranches = 1,
    this.maxUsers = 2,
    this.currentUsersCount = 1,
    this.monthlyBillLimit = 300,
    this.monthlyBillsCount = 0,
    this.isBillQuotaExceeded = false,
    this.isLoading = false,
    this.error,
  });

  bool hasFeature(String featureKey) {
    if (packagePlan == 'PREMIUM' || packagePlan == 'AGENCY') return true;

    // Purchase module & procurement features unlocked in development
    const purchaseModuleFeatures = {
      'purchases',
      'purchaseModule',
      'purchaseOrders',
      'goodsReceived',
      'qualityCheck',
      'quotations',
      'quotationCs',
      'batchExpiry',
      'deliveryChallans',
      'suppliers',
      'receivedBills',
    };
    if (purchaseModuleFeatures.contains(featureKey)) {
      return true;
    }

    return featureFlags[featureKey] ?? false;
  }

  EntitlementsState copyWith({
    String? packagePlan,
    Map<String, bool>? featureFlags,
    int? maxBranches,
    int? maxUsers,
    int? currentUsersCount,
    int? monthlyBillLimit,
    int? monthlyBillsCount,
    bool? isBillQuotaExceeded,
    bool? isLoading,
    String? error,
  }) {
    return EntitlementsState(
      packagePlan: packagePlan ?? this.packagePlan,
      featureFlags: featureFlags ?? this.featureFlags,
      maxBranches: maxBranches ?? this.maxBranches,
      maxUsers: maxUsers ?? this.maxUsers,
      currentUsersCount: currentUsersCount ?? this.currentUsersCount,
      monthlyBillLimit: monthlyBillLimit ?? this.monthlyBillLimit,
      monthlyBillsCount: monthlyBillsCount ?? this.monthlyBillsCount,
      isBillQuotaExceeded: isBillQuotaExceeded ?? this.isBillQuotaExceeded,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class EntitlementsNotifier extends StateNotifier<EntitlementsState> {
  final Dio _dio;

  EntitlementsNotifier(this._dio) : super(EntitlementsState()) {
    fetchEntitlements();
  }

  Future<void> fetchEntitlements() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.get('/tenant/entitlements');
      if (response.data != null && response.data['success'] == true) {
        final data = response.data;
        final flags = Map<String, bool>.from(
          (data['featureFlags'] as Map<dynamic, dynamic>? ?? {}).map(
            (key, value) => MapEntry(key.toString(), value == true),
          ),
        );
        final quotas = data['quotas'] ?? {};

        state = state.copyWith(
          packagePlan: data['packagePlan'] ?? 'FREE',
          featureFlags: flags,
          maxBranches: quotas['maxBranches'] ?? 1,
          maxUsers: quotas['maxUsers'] ?? 2,
          currentUsersCount: quotas['currentUsersCount'] ?? 1,
          monthlyBillLimit: quotas['monthlyBillLimit'] ?? 300,
          monthlyBillsCount: quotas['monthlyBillsCount'] ?? 0,
          isBillQuotaExceeded: quotas['isBillQuotaExceeded'] ?? false,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> unlockDevPlan([String plan = 'AGENCY']) async {
    state = state.copyWith(isLoading: true);
    try {
      await _dio.post('/tenant/entitlements', data: {'plan': plan});
      await fetchEntitlements();
    } catch (_) {
      state = state.copyWith(
        packagePlan: plan.toUpperCase(),
        isLoading: false,
      );
    }
  }
}

final entitlementsProvider =
    StateNotifierProvider<EntitlementsNotifier, EntitlementsState>((ref) {
  final dio = ref.watch(dioProvider);
  return EntitlementsNotifier(dio);
});
