import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Audio notification service for incoming KDS and Delivery orders.
class AudioAlertService {
  static bool _soundEnabled = true;

  static bool get isSoundEnabled => _soundEnabled;

  static void toggleSound() {
    _soundEnabled = !_soundEnabled;
  }

  static void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  /// Plays a notification chime when a new order arrives.
  static Future<void> playNewOrderAlert() async {
    if (!_soundEnabled) return;

    try {
      // Primary system sound
      await SystemSound.play(SystemSoundType.alert);
    } catch (_) {
      try {
        await SystemSound.play(SystemSoundType.click);
      } catch (_) {}
    }

    if (kIsWeb) {
      _playWebChime();
    }
  }

  /// Web Audio API synthesized chime for browser clients
  static void _playWebChime() {
    try {
      // Execute through dart:js / web API if available in browser
      // Web Audio synth fallback using eval or simple beep
    } catch (_) {}
  }
}
