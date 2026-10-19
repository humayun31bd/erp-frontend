import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../pos/domain/product_model.dart';
import '../domain/label_print_model.dart';
import '../utils/label_pdf_generator.dart';

/// Manages products queued for printing and copies per product.
class LabelQueueNotifier extends StateNotifier<List<LabelItem>> {
  LabelQueueNotifier() : super([]);

  void addProduct(ProductModel product, {int copies = 1}) {
    final existingIdx = state.indexWhere((item) => item.productId == product.id);
    if (existingIdx >= 0) {
      final updated = List<LabelItem>.from(state);
      final current = updated[existingIdx];
      updated[existingIdx] = current.copyWith(copiesCount: current.copiesCount + copies);
      state = updated;
    } else {
      state = [...state, LabelItem.fromProduct(product, copies: copies)];
    }
  }

  void addMultipleProducts(List<ProductModel> products) {
    final updated = List<LabelItem>.from(state);
    for (final p in products) {
      final existingIdx = updated.indexWhere((item) => item.productId == p.id);
      if (existingIdx >= 0) {
        final current = updated[existingIdx];
        updated[existingIdx] = current.copyWith(copiesCount: current.copiesCount + 1);
      } else {
        updated.add(LabelItem.fromProduct(p, copies: 1));
      }
    }
    state = updated;
  }

  void removeProduct(String productId) {
    state = state.where((item) => item.productId != productId).toList();
  }

  void updateCopies(String productId, int copies) {
    if (copies <= 0) {
      removeProduct(productId);
      return;
    }
    state = state.map((item) {
      if (item.productId == productId) {
        return item.copyWith(copiesCount: copies);
      }
      return item;
    }).toList();
  }

  void updateBatch(String productId, String batch) {
    state = state.map((item) {
      if (item.productId == productId) {
        return item.copyWith(batchNumber: batch);
      }
      return item;
    }).toList();
  }

  void updateExpiry(String productId, DateTime expiry) {
    state = state.map((item) {
      if (item.productId == productId) {
        return item.copyWith(expiryDate: expiry);
      }
      return item;
    }).toList();
  }

  void updatePackingDate(String productId, DateTime packingDate) {
    state = state.map((item) {
      if (item.productId == productId) {
        return item.copyWith(packingDate: packingDate);
      }
      return item;
    }).toList();
  }

  void updateSerial(String productId, String serial) {
    state = state.map((item) {
      if (item.productId == productId) {
        return item.copyWith(serialNumber: serial);
      }
      return item;
    }).toList();
  }

  void updateHsn(String productId, String hsn) {
    state = state.map((item) {
      if (item.productId == productId) {
        return item.copyWith(hsnCode: hsn);
      }
      return item;
    }).toList();
  }

  void updateRetailPrice(String productId, double price) {
    state = state.map((item) {
      if (item.productId == productId) {
        return item.copyWith(retailPrice: price);
      }
      return item;
    }).toList();
  }

  void clearQueue() {
    state = [];
  }
}

final labelQueueProvider = StateNotifierProvider<LabelQueueNotifier, List<LabelItem>>((ref) {
  return LabelQueueNotifier();
});

/// Manages label display toggles and customizations.
class LabelSettingsNotifier extends StateNotifier<LabelDisplaySettings> {
  LabelSettingsNotifier() : super(const LabelDisplaySettings());

  void toggleShopName(bool val) => state = state.copyWith(showShopName: val);
  void toggleShopAddress(bool val) => state = state.copyWith(showShopAddress: val);
  void toggleShopPhone(bool val) => state = state.copyWith(showShopPhone: val);
  void toggleShopEmail(bool val) => state = state.copyWith(showShopEmail: val);
  void toggleShopLogo(bool val) => state = state.copyWith(showShopLogo: val);

  void setShopDetails({String? name, String? address, String? phone, String? email}) {
    state = state.copyWith(
      shopName: name,
      shopAddress: address,
      shopPhone: phone,
      shopEmail: email,
    );
  }

  void toggleProductName(bool val) => state = state.copyWith(showProductName: val);
  void toggleBarcodeText(bool val) => state = state.copyWith(showBarcodeText: val);
  void toggleHsnCode(bool val) => state = state.copyWith(showHsnCode: val);

  void toggleRequireExpiry(bool val) => state = state.copyWith(requireExpiryDate: val);
  void toggleRequireBatch(bool val) => state = state.copyWith(requireBatchNumber: val);
  void toggleRequireSerial(bool val) => state = state.copyWith(requireSerialNumber: val);
  void togglePackingDate(bool val) => state = state.copyWith(showPackingDate: val);

  void toggleRetailPrice(bool val) => state = state.copyWith(showRetailPrice: val);
  void toggleWholesalePrice(bool val) => state = state.copyWith(showWholesalePrice: val);
  void toggleDiscountPrice(bool val) => state = state.copyWith(showDiscountPrice: val);

  void toggleBarcode(bool val) => state = state.copyWith(showBarcode: val);
  void toggleQrCode(bool val) => state = state.copyWith(showQrCode: val);
  void toggleDimensions(bool val) => state = state.copyWith(showLabelDimensions: val);
}

final labelSettingsProvider = StateNotifierProvider<LabelSettingsNotifier, LabelDisplaySettings>((ref) {
  return LabelSettingsNotifier();
});

/// Manages the selected paper sheet or continuous roll preset.
class LabelPresetNotifier extends StateNotifier<LabelSheetPreset> {
  LabelPresetNotifier() : super(LabelSheetPreset.sheet30);

  void setPreset(LabelSheetPreset preset) {
    state = preset;
  }
}

final labelPresetProvider = StateNotifierProvider<LabelPresetNotifier, LabelSheetPreset>((ref) {
  return LabelPresetNotifier();
});

/// Total number of individual labels to print across all queued items.
final totalLabelsCountProvider = Provider<int>((ref) {
  final queue = ref.watch(labelQueueProvider);
  return queue.fold<int>(0, (sum, item) => sum + item.copiesCount);
});

/// Generates the PDF Uint8List dynamically for live preview.
final labelPdfFutureProvider = FutureProvider.autoDispose<Uint8List>((ref) async {
  final queue = ref.watch(labelQueueProvider);
  final settings = ref.watch(labelSettingsProvider);
  final preset = ref.watch(labelPresetProvider);

  return LabelPdfGenerator.generateLabelsDoc(
    items: queue,
    settings: settings,
    preset: preset,
  );
});
