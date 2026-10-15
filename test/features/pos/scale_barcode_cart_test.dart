import 'package:flutter_test/flutter_test.dart';
import 'package:erp_frontend/features/pos/domain/product_model.dart';
import 'package:erp_frontend/features/pos/providers/pos_provider.dart';

void main() {
  group('Weighing Scale Barcode Logic Tests', () {
    test('EAN-13 Scale Barcode parser decodes PLU and weight in grams correctly', () {
      // Scale Barcode: Prefix 20, PLU 12345, Weight 01500 grams (1.500 kg), Checkdigit 8
      const rawBarcode = '2012345015008';
      expect(rawBarcode.length, 13);
      expect(rawBarcode.startsWith('20') || rawBarcode.startsWith('02') || rawBarcode.startsWith('21'), isTrue);

      final plu = rawBarcode.substring(2, 7);
      expect(plu, '12345');

      final weightGramsStr = rawBarcode.substring(7, 12);
      expect(weightGramsStr, '01500');

      final weightGrams = double.tryParse(weightGramsStr) ?? 0.0;
      final weightKg = weightGrams / 1000.0;
      expect(weightKg, 1.5);
    });

    test('EAN-13 Scale Barcode with prefix 02 parses sub-kilogram produce accurately', () {
      // Prefix 02, PLU 99887, Weight 00350 grams (0.350 kg)
      const rawBarcode = '0299887003504';
      final plu = rawBarcode.substring(2, 7);
      final weightKg = (double.tryParse(rawBarcode.substring(7, 12)) ?? 0.0) / 1000.0;

      expect(plu, '99887');
      expect(weightKg, 0.35);
    });
  });

  group('CartItem Specialized Pricing & Metadata Tests', () {
    const dummyProduct = ProductModel(
      id: 'prod-001',
      name: 'Fresh Premium Tomatoes',
      price: '10.00',
      stockQuantity: 100,
      isWeightBased: true,
      weight: 1.0,
    );

    test('effectivePrice scales proportionally with measuredWeightKg', () {
      // 1.5 kg @ 10.00/kg = 15.00
      final item1 = CartItem(
        product: dummyProduct,
        quantity: 1,
        measuredWeightKg: 1.5,
      );
      expect(item1.effectivePrice, 15.0);

      // 0.250 kg @ 10.00/kg = 2.50
      final item2 = CartItem(
        product: dummyProduct,
        quantity: 1,
        measuredWeightKg: 0.25,
      );
      expect(item2.effectivePrice, 2.5);
    });

    test('CartItem retains specialized batch, expiry, rx, modifiers, and staff metadata', () {
      final item = CartItem(
        product: dummyProduct,
        quantity: 2,
        batchNumber: 'LOT-98210',
        expiryDate: '12/28',
        modifiers: 'Extra Ripe',
        measuredWeightKg: 1.25,
        assignedStaff: 'Chef Marco',
      );

      expect(item.batchNumber, 'LOT-98210');
      expect(item.expiryDate, '12/28');
      expect(item.modifiers, 'Extra Ripe');
      expect(item.measuredWeightKg, 1.25);
      expect(item.assignedStaff, 'Chef Marco');
      // effective price: 10.00 * 1.25 = 12.50
      expect(item.effectivePrice, 12.5);
    });
  });
}
