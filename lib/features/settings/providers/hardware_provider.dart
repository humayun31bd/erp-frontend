import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:printing/printing.dart';

const _defaultPrinterKey = 'default_printer_url';

class HardwareService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Printer?> getDefaultPrinter() async {
    final String? printerJson = await _storage.read(key: _defaultPrinterKey);
    if (printerJson != null && printerJson.isNotEmpty) {
      try {
        final map = jsonDecode(printerJson);
        return Printer(url: map['url'], name: map['name'], model: map['model'], location: map['location'], comment: map['comment'], isAvailable: map['isAvailable'] ?? true, isDefault: map['isDefault'] ?? false);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> setDefaultPrinter(Printer printer) async {
    final map = {
      'url': printer.url,
      'name': printer.name,
      'model': printer.model,
      'location': printer.location,
      'comment': printer.comment,
      'isAvailable': printer.isAvailable,
      'isDefault': printer.isDefault,
    };
    await _storage.write(key: _defaultPrinterKey, value: jsonEncode(map));
  }

  Future<void> clearDefaultPrinter() async {
    await _storage.delete(key: _defaultPrinterKey);
  }

  Future<List<Printer>> getAvailablePrinters() async {
    try {
      return await Printing.listPrinters();
    } catch (e) {
      // On web or platforms where this throws
      return [];
    }
  }
}

final hardwareServiceProvider = Provider<HardwareService>((ref) {
  return HardwareService();
});

final defaultPrinterProvider = FutureProvider<Printer?>((ref) async {
  final service = ref.watch(hardwareServiceProvider);
  return await service.getDefaultPrinter();
});

final availablePrintersProvider = FutureProvider<List<Printer>>((ref) async {
  final service = ref.watch(hardwareServiceProvider);
  return await service.getAvailablePrinters();
});
