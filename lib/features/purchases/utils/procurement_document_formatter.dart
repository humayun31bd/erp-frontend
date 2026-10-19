class ProcurementDocumentFormatter {
  /// Transforms any supplier identifier (even raw UUIDs) into a clean, human-readable Supplier Code.
  /// Example: '336eaf82-a524-4b0a-9326-7197b1e5459e' -> 'SUP-336EAF82'
  /// 'SUP-001' -> 'SUP-001'
  static String formatSupplierCode(String? rawId) {
    if (rawId == null || rawId.trim().isEmpty) return 'SUP-001';
    final trimmed = rawId.trim();
    if (trimmed.toUpperCase().startsWith('SUP-')) {
      return trimmed.toUpperCase();
    }
    // If it's a UUID (contains hyphens and length > 20)
    if (trimmed.length > 20 && trimmed.contains('-')) {
      final prefix = trimmed.split('-').first.toUpperCase();
      return 'SUP-$prefix';
    }
    // If it already looks like a code (e.g. S01, VENDOR-1)
    if (trimmed.length <= 12 && !trimmed.contains('-')) {
      return 'SUP-${trimmed.toUpperCase()}';
    }
    return trimmed.startsWith('SUP') ? trimmed.toUpperCase() : 'SUP-${trimmed.toUpperCase()}';
  }

  /// Ensures a clean Purchase Order Number is displayed instead of any internal UUID.
  static String formatPoNumber(String? poNumber, [String? poId]) {
    if (poNumber != null && poNumber.trim().isNotEmpty && !isUuid(poNumber)) {
      return poNumber.trim();
    }
    if (poId != null && poId.trim().isNotEmpty) {
      if (!isUuid(poId)) return poId.trim();
      return 'PO-${poId.split('-').first.toUpperCase()}';
    }
    return 'PO-PENDING';
  }

  /// Ensures a clean Goods Received Note Number is displayed.
  static String formatGrnNumber(String? grnNumber, [String? grnId]) {
    if (grnNumber != null && grnNumber.trim().isNotEmpty && !isUuid(grnNumber)) {
      return grnNumber.trim();
    }
    if (grnId != null && grnId.trim().isNotEmpty) {
      if (!isUuid(grnId)) return grnId.trim();
      return 'GRN-${grnId.split('-').first.toUpperCase()}';
    }
    return 'GRN-PENDING';
  }

  /// Ensures a clean Quality Check Number is displayed.
  static String formatQcNumber(String? qcNumber, [String? qcId]) {
    if (qcNumber != null && qcNumber.trim().isNotEmpty && !isUuid(qcNumber)) {
      return qcNumber.trim();
    }
    if (qcId != null && qcId.trim().isNotEmpty) {
      if (!isUuid(qcId)) return qcId.trim();
      return 'QC-${qcId.split('-').first.toUpperCase()}';
    }
    return 'QC-PENDING';
  }

  /// Ensures a clean RFQ / Supplier Quotation Number is displayed.
  static String formatRfqNumber(String? quotationNumber, [String? quotationId]) {
    if (quotationNumber != null && quotationNumber.trim().isNotEmpty && !isUuid(quotationNumber)) {
      return quotationNumber.trim();
    }
    if (quotationId != null && quotationId.trim().isNotEmpty) {
      if (!isUuid(quotationId)) return quotationId.trim();
      return 'RFQ-${quotationId.split('-').first.toUpperCase()}';
    }
    return 'RFQ-PENDING';
  }

  /// Ensures a clean Supplier Bill Number is displayed.
  static String formatBillNumber(String? billNumber, [String? billId]) {
    if (billNumber != null && billNumber.trim().isNotEmpty && !isUuid(billNumber)) {
      return billNumber.trim();
    }
    if (billId != null && billId.trim().isNotEmpty) {
      if (!isUuid(billId)) return billId.trim();
      return 'BILL-${billId.split('-').first.toUpperCase()}';
    }
    return 'BILL-PENDING';
  }

  /// Ensures a clean Tax Purchase Invoice Number is displayed.
  static String formatInvoiceNumber(String? invoiceNumber, [String? invoiceId]) {
    if (invoiceNumber != null && invoiceNumber.trim().isNotEmpty && !isUuid(invoiceNumber)) {
      return invoiceNumber.trim();
    }
    if (invoiceId != null && invoiceId.trim().isNotEmpty) {
      if (!isUuid(invoiceId)) return invoiceId.trim();
      return 'PINV-${invoiceId.split('-').first.toUpperCase()}';
    }
    return 'PINV-PENDING';
  }

  /// Ensures a clean Comparative Statement Number is displayed instead of raw UUIDs.
  static String formatCsNumber(String? csNumber, [String? csId]) {
    if (csNumber != null && csNumber.trim().isNotEmpty && !isUuid(csNumber)) {
      return csNumber.trim();
    }
    if (csId != null && csId.trim().isNotEmpty) {
      if (!isUuid(csId)) return csId.trim();
      return 'CS-${csId.split('-').first.toUpperCase()}';
    }
    return 'CS-PENDING';
  }

  /// Helper to test if a string looks like a raw system UUID
  static bool isUuid(String str) {
    final s = str.trim();
    return s.length >= 32 && (s.contains('-') && s.split('-').length >= 4);
  }
}
