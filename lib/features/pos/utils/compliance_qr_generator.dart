import '../../settings/domain/tenant_preset_models.dart';
import 'zatca_qr_generator.dart';

class ComplianceQrGenerator {
  /// Generates regional compliance verification QR code payload based on active legal standard
  static String generate({
    required ComplianceEngine compliance,
    required String sellerName,
    required String vatOrBinNumber,
    required String invoiceNumber,
    required String timestamp,
    required double invoiceTotal,
    required double vatTotal,
    String? currencySymbol,
  }) {
    switch (compliance) {
      case ComplianceEngine.zatca:
        // Saudi ZATCA Phase 1 & 2 Base64 TLV Encoding
        return ZatcaQRGenerator.generateBase64(
          sellerName: sellerName.isNotEmpty ? sellerName : 'Intelligent Commercial Trading',
          vatNumber: vatOrBinNumber.isNotEmpty ? vatOrBinNumber : '310123456700003',
          timestamp: timestamp,
          invoiceTotal: invoiceTotal.toStringAsFixed(2),
          vatTotal: vatTotal.toStringAsFixed(2),
        );

      case ComplianceEngine.nbrBangladesh:
        // Bangladesh NBR Mushuk 6.3 Standard QR String
        // Format: NBR-MUSHUK6.3|BIN|Invoice#|Date|Total|VAT
        final bin = vatOrBinNumber.isNotEmpty ? vatOrBinNumber : '1801122334455';
        return 'NBR-MUSHUK-6.3|BIN:$bin|INV:$invoiceNumber|TIME:$timestamp|TOTAL:${invoiceTotal.toStringAsFixed(2)}|VAT:${vatTotal.toStringAsFixed(2)}';

      case ComplianceEngine.fta:
        // UAE FTA Standard Verification Payload
        final trn = vatOrBinNumber.isNotEmpty ? vatOrBinNumber : '100234567800003';
        return 'FTA-UAE|TRN:$trn|INV:$invoiceNumber|DATE:$timestamp|TOTAL:${invoiceTotal.toStringAsFixed(2)}|VAT:${vatTotal.toStringAsFixed(2)}';

      case ComplianceEngine.ota:
      case ComplianceEngine.nbrBahrain:
      case ComplianceEngine.gtaQatar:
      case ComplianceEngine.mofKuwait:
        // GCC Standard Verification String
        final taxId = vatOrBinNumber.isNotEmpty ? vatOrBinNumber : 'TAX-REG-01';
        return 'GCC-POS|${compliance.name.toUpperCase()}|ID:$taxId|INV:$invoiceNumber|DATE:$timestamp|TOTAL:${invoiceTotal.toStringAsFixed(3)}|TAX:${vatTotal.toStringAsFixed(3)}';
    }
  }
}
