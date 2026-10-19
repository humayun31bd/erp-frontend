import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../features/pos/providers/pos_provider.dart';
import '../../features/clients/domain/client_model.dart';

final hiveStorageServiceProvider = Provider<HiveStorageService>((ref) {
  return HiveStorageService();
});

class HiveStorageService {
  static const String _cartsBoxName = 'offline_carts_box';
  static const String _heldCartsBoxName = 'held_carts_box';
  
  late Box _cartsBox;
  late Box _heldCartsBox;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> init() async {
    await Hive.initFlutter();
    
    final encryptionKeyString = await _secureStorage.read(key: 'hive_encryption_key');
    
    late List<int> encryptionKeyUint8List;
    if (encryptionKeyString == null) {
      final key = Hive.generateSecureKey();
      await _secureStorage.write(
        key: 'hive_encryption_key',
        value: base64UrlEncode(key),
      );
      encryptionKeyUint8List = key;
    } else {
      encryptionKeyUint8List = base64Url.decode(encryptionKeyString);
    }
    
    final encryptionCipher = HiveAesCipher(encryptionKeyUint8List);
    
    try {
      _cartsBox = await Hive.openBox(_cartsBoxName, encryptionCipher: encryptionCipher);
    } catch (e) {
      // If it fails (e.g. because it was previously unencrypted), clear and recreate
      await Hive.deleteBoxFromDisk(_cartsBoxName);
      _cartsBox = await Hive.openBox(_cartsBoxName, encryptionCipher: encryptionCipher);
    }

    try {
      _heldCartsBox = await Hive.openBox(_heldCartsBoxName, encryptionCipher: encryptionCipher);
    } catch (e) {
      await Hive.deleteBoxFromDisk(_heldCartsBoxName);
      _heldCartsBox = await Hive.openBox(_heldCartsBoxName, encryptionCipher: encryptionCipher);
    }
  }

  // --- Offline Checkouts ---

  Future<void> saveOfflineCheckout(Map<String, dynamic> checkoutData) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    
    // 1. Get the hash of the previous transaction from secure storage
    String previousHash = await _secureStorage.read(key: 'last_transaction_hash') ?? '0000000000000000000000000000000000000000000000000000000000000000'; // Genesis Hash
    
    // 2. Generate the new HMAC-SHA256 hash using a server secret
    final payloadString = jsonEncode(checkoutData);
    final hmacKey = utf8.encode('zatca_hmac_secret_key');
    final bytes = utf8.encode(payloadString + previousHash);
    
    final hmacSha256 = Hmac(sha256, hmacKey);
    final currentHash = hmacSha256.convert(bytes).toString();
    
    // 3. Save the hashes alongside the payload for ZATCA validation
    checkoutData['transaction_hash'] = currentHash;
    checkoutData['previous_hash'] = previousHash;
    
    await _cartsBox.put(timestamp, jsonEncode(checkoutData));
    
    // 4. Update the persistent last hash
    await _secureStorage.write(key: 'last_transaction_hash', value: currentHash);
  }

  Future<List<Map<String, dynamic>>> getOfflineCheckouts() async {
    final List<Map<String, dynamic>> checkouts = [];
    for (var key in _cartsBox.keys) {
      final dataStr = _cartsBox.get(key) as String?;
      if (dataStr != null) {
        checkouts.add({...jsonDecode(dataStr), 'local_id': key});
      }
    }
    return checkouts;
  }

  Future<void> removeOfflineCheckout(String localId) async {
    await _cartsBox.delete(localId);
  }

  // --- Held Carts ---

  Future<void> holdCart(List<CartItem> cart, ClientModel? customer, double discount, double total) async {
    final timestamp = DateTime.now().toIso8601String();
    
    final data = {
      'timestamp': timestamp,
      'cart': cart.map((e) => e.toJson()).toList(),
      'customer': customer?.toJson(),
      'discount': discount,
      'total': total,
    };
    
    await _heldCartsBox.put(timestamp, jsonEncode(data));
  }

  Future<List<Map<String, dynamic>>> getHeldCarts() async {
    final List<Map<String, dynamic>> held = [];
    for (var key in _heldCartsBox.keys) {
      final dataStr = _heldCartsBox.get(key) as String?;
      if (dataStr != null) {
        held.add({...jsonDecode(dataStr), 'hold_id': key});
      }
    }
    return held;
  }

  Future<void> removeHeldCart(String holdId) async {
    await _heldCartsBox.delete(holdId);
  }
}
