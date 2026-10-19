import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../data/supplier_api.dart';
import '../domain/supplier_model.dart';

final supplierApiProvider = Provider<SupplierApi>((ref) {
  final dio = ref.watch(dioProvider);
  return SupplierApi(dio);
});

final suppliersProvider = FutureProvider<List<SupplierModel>>((ref) async {
  final api = ref.watch(supplierApiProvider);
  return await api.getSuppliers();
});
