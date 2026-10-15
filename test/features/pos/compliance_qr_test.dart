import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:erp_frontend/features/pos/utils/compliance_qr_generator.dart';
import 'package:erp_frontend/features/pos/utils/zatca_qr_generator.dart';
import 'package:erp_frontend/features/settings/domain/tenant_preset_models.dart';

void main() {
  group('ZatcaQRGenerator TLV Encoding Tests', () {
    test('generateBase64 generates valid Base64 TLV encoding with tags 1-5', () {
      const seller = 'Intelligent Tech Trading Co.';
      const vatNumber = '310123456700003';
      const timestamp = '2026-10-15T14:30:00Z';
      const totalAmount = '115.00';
      const taxAmount = '15.00';

      final qrBase64 = ZatcaQRGenerator.generateBase64(
        sellerName: seller,
        vatNumber: vatNumber,
        timestamp: timestamp,
        invoiceTotal: totalAmount,
        vatTotal: taxAmount,
      );

      expect(qrBase64, isNotEmpty);

      // Decode Base64 and parse TLV tags
      final bytes = base64.decode(qrBase64);
      expect(bytes, isNotEmpty);

      int offset = 0;
      final Map<int, String> tlvValues = {};

      while (offset < bytes.length) {
        final tag = bytes[offset];
        final length = bytes[offset + 1];
        final valueBytes = bytes.sublist(offset + 2, offset + 2 + length);
        tlvValues[tag] = utf8.decode(valueBytes);
        offset += 2 + length;
      }

      // Verify all 5 tags are correctly encoded
      expect(tlvValues[1], seller);
      expect(tlvValues[2], vatNumber);
      expect(tlvValues[3], timestamp);
      expect(tlvValues[4], totalAmount);
      expect(tlvValues[5], taxAmount);
    });
  });

  group('ComplianceQrGenerator Multi-Regional Dispatcher Tests', () {
    test('generate routes ZATCA compliance to Base64 TLV', () {
      final qr = ComplianceQrGenerator.generate(
        compliance: ComplianceEngine.zatca,
        sellerName: 'Intelligent KSA',
        vatOrBinNumber: '310123456700003',
        invoiceNumber: 'INV-KSA-001',
        timestamp: '2026-10-15T14:30:00Z',
        invoiceTotal: 115.00,
        vatTotal: 15.00,
      );

      expect(() => base64.decode(qr), returnsNormally);
      final decoded = utf8.decode(base64.decode(qr), allowMalformed: true);
      expect(decoded, contains('Intelligent KSA'));
      expect(decoded, contains('310123456700003'));
    });

    test('generate routes UAE FTA to compliant FTA string', () {
      final qr = ComplianceQrGenerator.generate(
        compliance: ComplianceEngine.fta,
        sellerName: 'Dubai Market LLC',
        vatOrBinNumber: '100234567800003',
        invoiceNumber: 'INV-UAE-042',
        timestamp: '2026-10-15T12:00:00Z',
        invoiceTotal: 105.00,
        vatTotal: 5.00,
      );

      expect(qr, startsWith('FTA-UAE|'));
      expect(qr, contains('TRN:100234567800003'));
      expect(qr, contains('INV:INV-UAE-042'));
      expect(qr, contains('TOTAL:105.00'));
      expect(qr, contains('VAT:5.00'));
    });

    test('generate routes Bangladesh NBR to Mushuk 6.3 standard string', () {
      final qr = ComplianceQrGenerator.generate(
        compliance: ComplianceEngine.nbrBangladesh,
        sellerName: 'Dhaka Superstore',
        vatOrBinNumber: '123456789-0101',
        invoiceNumber: 'CH-2026-091',
        timestamp: '2026-10-15T16:00:00Z',
        invoiceTotal: 1150.00,
        vatTotal: 150.00,
      );

      expect(qr, startsWith('NBR-MUSHUK-6.3|'));
      expect(qr, contains('BIN:123456789-0101'));
      expect(qr, contains('INV:CH-2026-091'));
      expect(qr, contains('TOTAL:1150.00'));
      expect(qr, contains('VAT:150.00'));
    });

    test('generate routes GCC countries to standardized GCC-POS payload', () {
      final qrOman = ComplianceQrGenerator.generate(
        compliance: ComplianceEngine.ota,
        sellerName: 'Muscat Hypermarket',
        vatOrBinNumber: 'OM-VAT-999',
        invoiceNumber: 'INV-OM-001',
        timestamp: '2026-10-15T10:00:00Z',
        invoiceTotal: 52.500,
        vatTotal: 2.500,
      );

      expect(qrOman, startsWith('GCC-POS|OTA|'));
      expect(qrOman, contains('ID:OM-VAT-999'));
      expect(qrOman, contains('TOTAL:52.500'));
      expect(qrOman, contains('TAX:2.500'));

      final qrKuwait = ComplianceQrGenerator.generate(
        compliance: ComplianceEngine.mofKuwait,
        sellerName: 'Kuwait City Boutique',
        vatOrBinNumber: 'KW-MOF-123',
        invoiceNumber: 'INV-KW-007',
        timestamp: '2026-10-15T11:00:00Z',
        invoiceTotal: 12.000,
        vatTotal: 0.000,
      );

      expect(qrKuwait, startsWith('GCC-POS|MOFKUWAIT|'));
      expect(qrKuwait, contains('ID:KW-MOF-123'));
      expect(qrKuwait, contains('TAX:0.000'));
    });
  });
}
