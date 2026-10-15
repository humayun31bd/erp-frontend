import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/hive_storage_service.dart';

class OfflineSyncService {
  final HiveStorageService _hive;

  OfflineSyncService(this._hive);

  Future<void> saveCheckout(Map<String, dynamic> payload) async {
    // Add a unique ID and timestamp for local tracking
    payload['_localId'] = DateTime.now().millisecondsSinceEpoch.toString();
    payload['_savedAt'] = DateTime.now().toIso8601String();
    
    await _hive.saveOfflineCheckout(payload);
  }

  Future<List<Map<String, dynamic>>> getUnsyncedCheckouts() async {
    try {
      // Returns all checkouts regardless of age to ensure zero ZATCA data loss.
      return await _hive.getOfflineCheckouts();
    } catch (e) {
      return [];
    }
  }

  /// Pushes all pending offline checkouts to the secure backend.
  /// Enforces HTTPS and authenticates via Bearer JWT.
  Future<int> syncPendingCheckouts(String authToken) async {
    final checkouts = await getUnsyncedCheckouts();
    if (checkouts.isEmpty) return 0;

    int successCount = 0;
    
    // In production, you would point this to your actual ZATCA-compliant backend
    final uri = Uri.parse('https://api.intelligent-pos.com/v1/pos/sync-checkout');

    for (final checkout in checkouts) {
      try {
        final response = await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $authToken',
            'X-Idempotency-Key': checkout['transaction_hash'] ?? checkout['local_id'],
          },
          body: jsonEncode(checkout),
        );

        // Strictly only clear the local transaction if the backend acknowledges 
        // receiving and persisting it successfully (200 OK or 201 Created).
        if (response.statusCode == 200 || response.statusCode == 201) {
          await clearSyncedCheckout(checkout['local_id']);
          successCount++;
        }
      } catch (e) {
        // Network error (e.g., still offline, firewall blocks). 
        // Fail gracefully and leave the transaction in Hive for the next sync cycle.
        debugPrint('Failed to sync checkout ${checkout['local_id']}: $e');
      }
    }
    
    return successCount;
  }

  /// Groups checkouts by day (YYYY-MM-DD) and returns them sorted chronologically
  Future<Map<String, List<Map<String, dynamic>>>> getUnsyncedCheckoutsGroupedByDay() async {
    final checkouts = await getUnsyncedCheckouts();
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var c in checkouts) {
      final savedAtStr = c['_savedAt'] as String?;
      if (savedAtStr == null) continue;
      
      final savedAt = DateTime.parse(savedAtStr);
      final dateKey = '${savedAt.year}-${savedAt.month.toString().padLeft(2, '0')}-${savedAt.day.toString().padLeft(2, '0')}';
      
      grouped.putIfAbsent(dateKey, () => []).add(c);
    }
    
    // Sort keys chronologically
    final sortedKeys = grouped.keys.toList()..sort();
    final Map<String, List<Map<String, dynamic>>> sortedGrouped = {};
    for (var key in sortedKeys) {
      sortedGrouped[key] = grouped[key]!;
    }
    return sortedGrouped;
  }

  Future<void> clearSyncedCheckout(String localId) async {
    await _hive.removeOfflineCheckout(localId);
  }
  
  Future<void> clearAll() async {
    final checkouts = await _hive.getOfflineCheckouts();
    for (var c in checkouts) {
      await _hive.removeOfflineCheckout(c['local_id']);
    }
  }
}

final offlineSyncServiceProvider = Provider<OfflineSyncService>((ref) {
  final hive = ref.watch(hiveStorageServiceProvider);
  return OfflineSyncService(hive);
});

// A provider to expose the count of pending offline checkouts
final offlineCheckoutsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final service = ref.watch(offlineSyncServiceProvider);
  final checkouts = await service.getUnsyncedCheckouts();
  return checkouts.length;
});
