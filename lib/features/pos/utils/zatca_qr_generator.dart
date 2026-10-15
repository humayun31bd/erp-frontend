import 'dart:convert';
import 'dart:typed_data';

class ZatcaQRGenerator {
  /// Generates a Base64 encoded TLV string for ZATCA Phase 1 e-invoicing.
  /// 
  /// 1. Seller Name
  /// 2. VAT Registration Number
  /// 3. Timestamp (ISO 8601)
  /// 4. Invoice Total (with VAT)
  /// 5. VAT Total
  static String generateBase64({
    required String sellerName,
    required String vatNumber,
    required String timestamp,
    required String invoiceTotal,
    required String vatTotal,
  }) {
    final bytesBuilder = BytesBuilder();
    
    bytesBuilder.add(_getTlvBytes(1, sellerName));
    bytesBuilder.add(_getTlvBytes(2, vatNumber));
    bytesBuilder.add(_getTlvBytes(3, timestamp));
    bytesBuilder.add(_getTlvBytes(4, invoiceTotal));
    bytesBuilder.add(_getTlvBytes(5, vatTotal));
    
    return base64Encode(bytesBuilder.toBytes());
  }

  static List<int> _getTlvBytes(int tag, String value) {
    final valueBytes = utf8.encode(value);
    return [tag, valueBytes.length, ...valueBytes];
  }
}
