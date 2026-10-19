import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../domain/cheque_models.dart';

class ChequeService {
  final Dio _dio;
  ChequeService(this._dio);

  Future<List<ChequeBookModel>> getChequeBooks({String? bankAccountId}) async {
    final response = await _dio.get(
      '/accounts/cheque-books',
      queryParameters: bankAccountId != null && bankAccountId.isNotEmpty ? {'bankAccountId': bankAccountId} : null,
    );
    final List list = response.data['chequeBooks'] ?? response.data['data'] ?? [];
    return list.map((json) => ChequeBookModel.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  Future<Map<String, dynamic>> createChequeBook({
    required String bankAccountId,
    required String chequeBookNumber,
    required int startLeafNumber,
    required int totalLeaves,
  }) async {
    final response = await _dio.post('/accounts/cheque-books', data: {
      'bankAccountId': bankAccountId,
      'chequeBookNumber': chequeBookNumber,
      'startLeafNumber': startLeafNumber,
      'totalLeaves': totalLeaves,
    });
    return Map<String, dynamic>.from(response.data);
  }

  Future<List<ChequeLeafModel>> getChequeLeaves({String? bankAccountId, String? status}) async {
    final params = <String, dynamic>{};
    if (bankAccountId != null && bankAccountId.isNotEmpty) params['bankAccountId'] = bankAccountId;
    if (status != null && status.isNotEmpty && status != 'ALL') params['status'] = status;

    final response = await _dio.get('/accounts/cheque-leaves', queryParameters: params);
    final List list = response.data['chequeLeaves'] ?? response.data['data'] ?? [];
    return list.map((json) => ChequeLeafModel.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  Future<ChequeLeafModel?> getAvailableChequeLeaf(String bankAccountId) async {
    final response = await _dio.get(
      '/accounts/cheque-books/available',
      queryParameters: {'bankAccountId': bankAccountId},
    );
    final data = response.data['availableLeaf'];
    if (data == null) return null;
    return ChequeLeafModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<Map<String, dynamic>> issueChequeLeaf({
    required String bankAccountId,
    String? chequeLeafId,
    required String payeeName,
    required double amount,
    String? issueDate,
    String? dueDate,
    String? remarks,
    String? voucherId,
  }) async {
    final response = await _dio.post('/accounts/cheque-leaves/issue', data: {
      'bankAccountId': bankAccountId,
      'chequeLeafId': chequeLeafId,
      'payeeName': payeeName,
      'amount': amount,
      'issueDate': issueDate ?? DateTime.now().toIso8601String(),
      'dueDate': dueDate,
      'remarks': remarks,
      'voucherId': voucherId,
    });
    return Map<String, dynamic>.from(response.data);
  }

  Future<List<ChequeLeafModel>> getPdcs({
    String? bankAccountId,
    String? pdcType,
    String? status,
    String? maturity,
  }) async {
    final params = <String, dynamic>{};
    if (bankAccountId != null && bankAccountId.isNotEmpty) params['bankAccountId'] = bankAccountId;
    if (pdcType != null && pdcType.isNotEmpty && pdcType != 'ALL') params['type'] = pdcType;
    if (status != null && status.isNotEmpty && status != 'ALL') params['status'] = status;
    if (maturity != null && maturity.isNotEmpty && maturity != 'ALL') params['maturity'] = maturity;

    final response = await _dio.get('/accounts/pdc', queryParameters: params);
    final List list = response.data['pdcs'] ?? [];
    return list.map((json) => ChequeLeafModel.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  Future<Map<String, dynamic>> recordReceivedPdc({
    required String bankAccountId,
    required String chequeNumber,
    required String drawerName,
    required double amount,
    String? issueDate,
    String? maturityDate,
    String? remarks,
  }) async {
    final response = await _dio.post('/accounts/pdc', data: {
      'bankAccountId': bankAccountId,
      'chequeNumber': chequeNumber,
      'drawerName': drawerName,
      'amount': amount,
      'issueDate': issueDate,
      'maturityDate': maturityDate ?? DateTime.now().toIso8601String(),
      'remarks': remarks,
    });
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> depositPdc({
    required String chequeLeafId,
    String? targetBankAccountId,
    String? depositDate,
    String? remarks,
  }) async {
    final response = await _dio.post('/accounts/pdc/deposit', data: {
      'chequeLeafId': chequeLeafId,
      'targetBankAccountId': targetBankAccountId,
      'depositDate': depositDate ?? DateTime.now().toIso8601String(),
      'remarks': remarks,
    });
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> clearCheque({
    required String chequeLeafId,
    String? clearedDate,
    String? remarks,
  }) async {
    final response = await _dio.post('/accounts/bank-recon/clear-cheque', data: {
      'chequeLeafId': chequeLeafId,
      'clearedDate': clearedDate ?? DateTime.now().toIso8601String(),
      'remarks': remarks,
    });
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> bounceCheque({
    required String chequeLeafId,
    String? bouncedDate,
    double penaltyFeeAmount = 0.0,
    String? remarks,
  }) async {
    final response = await _dio.post('/accounts/bank-recon/bounce-cheque', data: {
      'chequeLeafId': chequeLeafId,
      'bouncedDate': bouncedDate ?? DateTime.now().toIso8601String(),
      'penaltyFeeAmount': penaltyFeeAmount,
      'remarks': remarks,
    });
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> cancelCheque({
    required String chequeLeafId,
    String? reason,
    double stopFeeAmount = 0.0,
  }) async {
    final response = await _dio.post('/accounts/cheque-leaves/cancel', data: {
      'chequeLeafId': chequeLeafId,
      'reason': reason,
      'stopFeeAmount': stopFeeAmount,
    });
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> importBankStatement({
    required String bankAccountId,
    required List<Map<String, dynamic>> statementLines,
  }) async {
    final response = await _dio.post('/accounts/bank-recon/import-statement', data: {
      'bankAccountId': bankAccountId,
      'statementLines': statementLines,
    });
    return Map<String, dynamic>.from(response.data);
  }

  Future<List<ChequeAuditLogModel>> getChequeAuditLogs(String chequeLeafId) async {
    final response = await _dio.get(
      '/accounts/cheque-leaves/audit',
      queryParameters: {'chequeLeafId': chequeLeafId},
    );
    final List list = response.data['auditLogs'] ?? [];
    return list.map((json) => ChequeAuditLogModel.fromJson(Map<String, dynamic>.from(json))).toList();
  }
}

final chequeServiceProvider = Provider<ChequeService>((ref) {
  final dio = ref.watch(dioProvider);
  return ChequeService(dio);
});

final chequeBooksProvider = FutureProvider.family<List<ChequeBookModel>, String?>((ref, bankAccountId) async {
  final service = ref.watch(chequeServiceProvider);
  return await service.getChequeBooks(bankAccountId: bankAccountId);
});

final chequeLeavesProvider = FutureProvider.family<List<ChequeLeafModel>, Map<String, String?>>((ref, filter) async {
  final service = ref.watch(chequeServiceProvider);
  return await service.getChequeLeaves(
    bankAccountId: filter['bankAccountId'],
    status: filter['status'],
  );
});

final pdcsProvider = FutureProvider.family<List<ChequeLeafModel>, Map<String, String?>>((ref, filter) async {
  final service = ref.watch(chequeServiceProvider);
  return await service.getPdcs(
    bankAccountId: filter['bankAccountId'],
    pdcType: filter['pdcType'],
    status: filter['status'],
    maturity: filter['maturity'],
  );
});

final availableChequeLeafProvider = FutureProvider.family<ChequeLeafModel?, String>((ref, bankAccountId) async {
  final service = ref.watch(chequeServiceProvider);
  return await service.getAvailableChequeLeaf(bankAccountId);
});

final chequeAuditLogsProvider = FutureProvider.family<List<ChequeAuditLogModel>, String>((ref, chequeLeafId) async {
  final service = ref.watch(chequeServiceProvider);
  return await service.getChequeAuditLogs(chequeLeafId);
});
