import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HardwareService {
  final List<String> _barcodeBuffer = [];
  DateTime? _lastKeyPress;
  
  // Callback when a full barcode is scanned
  void Function(String barcode)? onBarcodeScanned;

  HardwareService();

  /// Listens to raw keyboard events to detect rapid barcode scanner input.
  /// Barcode scanners act as keyboards but type extremely fast.
  void handleKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final now = DateTime.now();
      
      // If time between keystrokes is too long (> 100ms), it's probably manual typing, clear buffer
      if (_lastKeyPress != null && now.difference(_lastKeyPress!).inMilliseconds > 100) {
        _barcodeBuffer.clear();
      }
      
      _lastKeyPress = now;

      // Scanners typically send an 'Enter' key at the end of the barcode
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (_barcodeBuffer.isNotEmpty) {
          final barcode = _barcodeBuffer.join();
          _barcodeBuffer.clear();
          
          if (onBarcodeScanned != null) {
            onBarcodeScanned!(barcode);
          }
        }
      } else {
        final char = event.character;
        if (char != null && char.isNotEmpty) {
          _barcodeBuffer.add(char);
        }
      }
    }
  }

  /// Sends an ESC/POS command to kick the cash drawer.
  /// Note: Real implementation requires a raw TCP socket or USB serial connection to the thermal printer.
  Future<void> openCashDrawer({String? printerIp}) async {
    // Standard ESC/POS Cash Drawer Kick Command: ESC p m t1 t2
    // List<int> kickCommand = [27, 112, 0, 50, 250];
    
    print('HARDWARE: Sending ESC/POS command to open cash drawer ${printerIp != null ? 'at $printerIp' : 'via USB'}...');
    
    // TODO: Implement actual raw socket connection to printer to send bytes.
    await Future.delayed(const Duration(milliseconds: 200)); 
    print('HARDWARE: Cash Drawer Opened');
  }
}

final hardwareServiceProvider = Provider<HardwareService>((ref) {
  return HardwareService();
});
