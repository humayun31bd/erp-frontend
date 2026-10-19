import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class VoucherNumberHelper {
  /// Fetches the next formula & sequence-based voucher number from backend API
  static Future<String?> fetchNextVoucherNumber({
    required Dio dio,
    required String voucherType,
    DateTime? date,
  }) async {
    try {
      final dateStr = (date ?? DateTime.now()).toIso8601String().split('T')[0];
      final response = await dio.get('/accounting/vouchers/next-number', queryParameters: {
        'type': voucherType,
        'date': dateStr,
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['voucherNumber']?.toString();
      }
    } catch (e) {
      debugPrint('Error fetching next voucher number: $e');
    }
    return null;
  }

  /// Client-side preview formatter for live feedback during formula editing
  static String formatPreview({
    required String formula,
    required String typeCode,
    required int seqPadding,
    required int sequence,
    DateTime? date,
  }) {
    final dateObj = date ?? DateTime.now();
    final yearFull = dateObj.year.toString();
    final yearShort = dateObj.year.toString().substring(2);
    final monthStr = dateObj.month.toString().padLeft(2, '0');
    final dayStr = dateObj.day.toString().padLeft(2, '0');
    final seqStr = sequence.toString().padLeft(seqPadding, '0');

    return formula
        .replaceAll('{TYPE}', typeCode.isEmpty ? 'PV' : typeCode)
        .replaceAll('{YYYY}', yearFull)
        .replaceAll('{YY}', yearShort)
        .replaceAll('{MM}', monthStr)
        .replaceAll('{DD}', dayStr)
        .replaceAll('{SEQ}', seqStr);
  }
}
