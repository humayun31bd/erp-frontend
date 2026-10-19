import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../data/purchase_api.dart';
import '../domain/purchase_model.dart';

final purchaseApiProvider = Provider<PurchaseApi>((ref) {
  final dio = ref.watch(dioProvider);
  return PurchaseApi(dio);
});

final purchasesProvider = FutureProvider<List<PurchaseModel>>((ref) async {
  final api = ref.watch(purchaseApiProvider);
  return await api.getPurchases();
});
