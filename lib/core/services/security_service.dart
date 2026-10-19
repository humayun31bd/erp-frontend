import 'package:flutter/services.dart';

class SecurityService {
  static const MethodChannel _channel = MethodChannel('com.zatca.pos/security');

  /// Prevents malicious apps from drawing phishing overlays over the POS
  /// and disables screenshots/screen recording.
  static Future<void> enableSecureMode() async {
    try {
      await _channel.invokeMethod('enableSecureMode');
    } catch (e) {
      // Feature not implemented or not supported on this platform
    }
  }

  /// Disables secure mode, allowing screen captures.
  static Future<void> disableSecureMode() async {
    try {
      await _channel.invokeMethod('disableSecureMode');
    } catch (e) {
      // Feature not implemented or not supported on this platform
    }
  }
}
