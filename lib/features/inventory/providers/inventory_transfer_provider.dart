import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../domain/transfer_models.dart';

class InventoryTransferService {
  final Dio _dio;
  InventoryTransferService(this._dio);

  Future<List<InventoryTransferModel>> getTransfers() async {
    final response = await _dio.get('/inventory/transfers');
    final List list = response.data['data'] ?? response.data['transfers'] ?? [];
    return list.map((json) => InventoryTransferModel.fromJson(json)).toList();
  }

  Future<InventoryTransferModel> createTransfer(Map<String, dynamic> payload) async {
    final response = await _dio.post('/inventory/transfers', data: payload);
    return InventoryTransferModel.fromJson(response.data['data']);
  }

  Future<InventoryTransferModel> updateTransferStatus(String id, String status) async {
    final response = await _dio.put('/inventory/transfers/$id', data: {'status': status});
    return InventoryTransferModel.fromJson(response.data['data']);
  }

  Future<List<InventoryAdjustmentModel>> getAdjustments() async {
    final response = await _dio.get('/inventory/adjustments');
    final List list = response.data['data'] ?? response.data['adjustments'] ?? [];
    return list.map((json) => InventoryAdjustmentModel.fromJson(json)).toList();
  }

  Future<InventoryAdjustmentModel> createAdjustment(Map<String, dynamic> payload) async {
    final response = await _dio.post('/inventory/adjustments', data: payload);
    return InventoryAdjustmentModel.fromJson(response.data['data']);
  }

  Future<Map<String, dynamic>> getInventoryReport() async {
    final response = await _dio.get('/inventory/report');
    return response.data['data'] ?? {};
  }
}

final inventoryTransferServiceProvider = Provider<InventoryTransferService>((ref) {
  final dio = ref.watch(dioProvider);
  return InventoryTransferService(dio);
});

final inventoryTransfersProvider = FutureProvider<List<InventoryTransferModel>>((ref) async {
  final service = ref.watch(inventoryTransferServiceProvider);
  return await service.getTransfers();
});

final inventoryAdjustmentsProvider = FutureProvider<List<InventoryAdjustmentModel>>((ref) async {
  final service = ref.watch(inventoryTransferServiceProvider);
  return await service.getAdjustments();
});

final inventoryReportProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(inventoryTransferServiceProvider);
  return await service.getInventoryReport();
});
