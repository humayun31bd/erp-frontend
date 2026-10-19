import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/document_sequence_formatter.dart';
import '../domain/procurement_models.dart';

class ProcurementService {
  final Dio _dio;
  ProcurementService(this._dio);

  List _extractList(dynamic responseData, List<String> possibleKeys) {
    if (responseData is List) {
      return responseData;
    }
    if (responseData is Map) {
      for (final key in possibleKeys) {
        if (responseData[key] is List) {
          return responseData[key] as List;
        }
      }
      if (responseData['data'] is List) {
        return responseData['data'] as List;
      }
    }
    return [];
  }

  Map<String, dynamic> _extractObject(dynamic responseData, [String key = 'data']) {
    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey(key) && responseData[key] is Map<String, dynamic>) {
        return responseData[key] as Map<String, dynamic>;
      }
      return responseData;
    }
    return {};
  }

  Future<List<SupplierQuotationModel>> getQuotations() async {
    final response = await _dio.get('/procurement/quotations');
    final List list = _extractList(response.data, ['quotations', 'data']);
    return list.map((json) => SupplierQuotationModel.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  Future<SupplierQuotationModel> createQuotation(Map<String, dynamic> payload) async {
    final response = await _dio.post('/procurement/quotations', data: payload);
    final obj = _extractObject(response.data, 'data');
    return SupplierQuotationModel.fromJson(obj);
  }

  Future<SupplierQuotationModel> updateQuotation(String id, Map<String, dynamic> payload) async {
    final response = await _dio.put('/procurement/quotations/$id', data: payload);
    final obj = _extractObject(response.data, 'data');
    return SupplierQuotationModel.fromJson(obj);
  }

  Future<List<ComparativeStatementModel>> getComparativeStatements() async {
    final response = await _dio.get('/procurement/cs');
    final List list = _extractList(response.data, ['csStatements', 'cs', 'data']);
    return list.map((json) => ComparativeStatementModel.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  Future<ComparativeStatementModel> createComparativeStatement(Map<String, dynamic> payload) async {
    final response = await _dio.post('/procurement/cs', data: payload);
    final obj = _extractObject(response.data, 'data');
    return ComparativeStatementModel.fromJson(obj);
  }

  Future<ComparativeStatementModel> approveComparativeStatement({
    required String csId,
    String? winnerQuotationId,
    String? winnerSupplierId,
    String awardMode = 'SINGLE',
    List<Map<String, dynamic>>? splitAllocations,
    String? notes,
  }) async {
    final response = await _dio.put('/procurement/cs', data: {
      'csId': csId,
      'status': 'APPROVED',
      'awardMode': awardMode,
      if (winnerQuotationId != null) 'winningQuotationId': winnerQuotationId,
      if (winnerQuotationId != null) 'winnerQuotationId': winnerQuotationId,
      if (winnerSupplierId != null) 'winnerSupplierId': winnerSupplierId,
      if (splitAllocations != null) 'splitAllocations': splitAllocations,
      'remarks': notes,
      'notes': notes,
    });
    final obj = _extractObject(response.data, 'data');
    return ComparativeStatementModel.fromJson(obj);
  }

  Future<List<PurchaseOrderModel>> getPurchaseOrders() async {
    final response = await _dio.get('/procurement/orders');
    final List list = _extractList(response.data, ['orders', 'data']);
    return list.map((json) => PurchaseOrderModel.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  Future<PurchaseOrderModel> createPurchaseOrder(Map<String, dynamic> payload) async {
    final response = await _dio.post('/procurement/orders', data: payload);
    final obj = _extractObject(response.data, 'data');
    return PurchaseOrderModel.fromJson(obj);
  }

  Future<PurchaseOrderModel> updatePurchaseOrder(String id, Map<String, dynamic> payload) async {
    final response = await _dio.put('/procurement/orders/$id', data: payload);
    final obj = _extractObject(response.data, 'data');
    return PurchaseOrderModel.fromJson(obj);
  }

  Future<void> deletePurchaseOrder(String id) async {
    await _dio.delete('/procurement/orders/$id');
  }

  Future<List<GoodsReceivedNoteModel>> getGoodsReceivedNotes() async {
    final response = await _dio.get('/procurement/grn');
    final List list = _extractList(response.data, ['grnList', 'grn', 'data']);
    return list.map((json) => GoodsReceivedNoteModel.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  Future<GoodsReceivedNoteModel> createGoodsReceivedNote(Map<String, dynamic> payload) async {
    final response = await _dio.post('/procurement/grn', data: payload);
    final obj = _extractObject(response.data, 'data');
    return GoodsReceivedNoteModel.fromJson(obj);
  }

  Future<GoodsReceivedNoteModel> updateGoodsReceivedNote(String id, Map<String, dynamic> payload) async {
    final response = await _dio.put('/procurement/grn/$id', data: payload);
    final obj = _extractObject(response.data, 'data');
    return GoodsReceivedNoteModel.fromJson(obj);
  }

  Future<void> deleteGoodsReceivedNote(String id) async {
    await _dio.delete('/procurement/grn/$id');
  }

  Future<List<QualityCheckRecordModel>> getQualityChecks() async {
    final response = await _dio.get('/procurement/qc');
    final List list = _extractList(response.data, ['qcList', 'qc', 'data']);
    return list.map((json) => QualityCheckRecordModel.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  Future<QualityCheckRecordModel> createQualityCheck(Map<String, dynamic> payload) async {
    final response = await _dio.post('/procurement/qc', data: payload);
    final obj = _extractObject(response.data, 'data');
    return QualityCheckRecordModel.fromJson(obj);
  }

  Future<List<SupplierBillModel>> getSupplierBills() async {
    final response = await _dio.get('/procurement/bills');
    final List list = _extractList(response.data, ['bills', 'data']);
    return list.map((json) => SupplierBillModel.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  Future<SupplierBillModel> createSupplierBill(Map<String, dynamic> payload) async {
    final response = await _dio.post('/procurement/bills', data: payload);
    final obj = _extractObject(response.data, 'data');
    return SupplierBillModel.fromJson(obj);
  }

  Future<SupplierBillModel> paySupplierBill({
    required String billId,
    required double paymentAmount,
    String paymentMethod = 'BANK',
    String? referenceNumber,
  }) async {
    final response = await _dio.put('/procurement/bills', data: {
      'billId': billId,
      'paymentAmount': paymentAmount,
      'paymentMethod': paymentMethod,
      'referenceNumber': referenceNumber,
    });
    final obj = _extractObject(response.data, 'data');
    return SupplierBillModel.fromJson(obj);
  }

  Future<String> fetchNextDocumentNumber(String type, {bool reserve = false}) async {
    try {
      final response = await _dio.get('/procurement/sequences', queryParameters: {
        'type': type,
        'reserve': reserve,
      });
      final data = response.data;
      if (data is Map && data['documentNumber'] != null) {
        return data['documentNumber'].toString();
      }
    } catch (_) {}
    return DocumentSequenceFormatter.format(prefix: type);
  }
}

final procurementServiceProvider = Provider<ProcurementService>((ref) {
  final dio = ref.watch(dioProvider);
  return ProcurementService(dio);
});

final supplierQuotationsProvider = FutureProvider<List<SupplierQuotationModel>>((ref) async {
  final service = ref.watch(procurementServiceProvider);
  return await service.getQuotations();
});

final comparativeStatementsProvider = FutureProvider<List<ComparativeStatementModel>>((ref) async {
  final service = ref.watch(procurementServiceProvider);
  return await service.getComparativeStatements();
});

final purchaseOrdersProvider = FutureProvider<List<PurchaseOrderModel>>((ref) async {
  final service = ref.watch(procurementServiceProvider);
  return await service.getPurchaseOrders();
});

final goodsReceivedNotesProvider = FutureProvider<List<GoodsReceivedNoteModel>>((ref) async {
  final service = ref.watch(procurementServiceProvider);
  return await service.getGoodsReceivedNotes();
});

final qualityChecksProvider = FutureProvider<List<QualityCheckRecordModel>>((ref) async {
  final service = ref.watch(procurementServiceProvider);
  return await service.getQualityChecks();
});

final supplierBillsProvider = FutureProvider<List<SupplierBillModel>>((ref) async {
  final service = ref.watch(procurementServiceProvider);
  return await service.getSupplierBills();
});
