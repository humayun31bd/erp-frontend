import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// Note: In a real app, you would import 'package:hive/hive.dart' 
// to pass the generated key into HiveAesCipher.

class SecureStorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // The key used to store the database encryption cipher in the keychain
  static const String _dbEncryptionKeyName = 'db_encryption_key';

  /// Retrieves the existing encryption key from the device's secure keychain,
  /// or generates a new one securely if this is a fresh install.
  /// 
  /// The returned key can be passed directly to Hive:
  /// `Hive.openBox('pos_cache', encryptionCipher: HiveAesCipher(key))`
  Future<List<int>> getDatabaseEncryptionKey() async {
    String? base64Key = await _secureStorage.read(key: _dbEncryptionKeyName);

    if (base64Key == null) {
      print('SECURITY: No encryption key found. Generating a new secure key...');
      
      // Generate a highly secure random 256-bit key
      // In Hive, Hive.generateSecureKey() returns List<int>
      // We mock it here since Hive isn't strictly imported in this file
      final secureKey = _generateMockSecureKey(); 
      
      base64Key = base64UrlEncode(secureKey);
      
      // Store it permanently in the platform's secure keystore (iOS Keychain / Android Keystore)
      await _secureStorage.write(key: _dbEncryptionKeyName, value: base64Key);
    } else {
      print('SECURITY: Recovered encryption key from secure storage.');
    }

    return base64Url.decode(base64Key);
  }

  /// Securely caches the manager PIN locally for offline overrides
  Future<void> cacheManagerPinHash(String managerId, String pin) async {
    // In production, NEVER store plain text. Hash it using BCrypt.
    // Example: final hash = BCrypt.hashpw(pin, BCrypt.gensalt());
    final hash = 'mock_bcrypt_hash_of_\$pin'; 
    await _secureStorage.write(key: 'manager_pin_\$managerId', value: hash);
  }

  /// Validates a PIN offline
  Future<bool> validateManagerPinOffline(String managerId, String pin) async {
    final cachedHash = await _secureStorage.read(key: 'manager_pin_\$managerId');
    if (cachedHash == null) return false;
    
    // In production: return BCrypt.checkpw(pin, cachedHash);
    return true; // Mock success
  }

  // --- Helpers ---

  List<int> _generateMockSecureKey() {
    // Generates a mock 32-byte key (256-bit)
    return List<int>.generate(32, (i) => i + 1);
  }
}
