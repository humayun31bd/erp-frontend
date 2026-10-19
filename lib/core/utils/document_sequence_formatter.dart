/// Standard enterprise document numbering utility
/// Formats document codes according to: <PREFIX>-YYYY-MM-DD-XXXXXX
/// (e.g. PO-2026-10-12-000001, GRN-2026-10-12-000001)
class DocumentSequenceFormatter {
  static String format({
    required String prefix,
    DateTime? date,
    int sequence = 1,
    int padding = 6,
  }) {
    final d = date ?? DateTime.now();
    final yyyy = d.year.toString().padLeft(4, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    final seqStr = sequence.toString().padLeft(padding, '0');
    return '$prefix-$yyyy-$mm-$dd-$seqStr';
  }

  /// Purchase Order
  static String poNumber({DateTime? date, int sequence = 1}) =>
      format(prefix: 'PO', date: date, sequence: sequence);

  /// Goods Received Note
  static String grnNumber({DateTime? date, int sequence = 1}) =>
      format(prefix: 'GRN', date: date, sequence: sequence);

  /// Supplier Request / Request for Quotation
  static String rfqNumber({DateTime? date, int sequence = 1}) =>
      format(prefix: 'RFQ', date: date, sequence: sequence);

  /// Supplier Request (SR alternative)
  static String srNumber({DateTime? date, int sequence = 1}) =>
      format(prefix: 'SR', date: date, sequence: sequence);

  /// Comparative Statement
  static String csNumber({DateTime? date, int sequence = 1}) =>
      format(prefix: 'CS', date: date, sequence: sequence);

  /// Quality Check
  static String qcNumber({DateTime? date, int sequence = 1}) =>
      format(prefix: 'QC', date: date, sequence: sequence);

  /// Purchase Bill / Supplier Bill
  static String billNumber({DateTime? date, int sequence = 1}) =>
      format(prefix: 'BILL', date: date, sequence: sequence);

  /// Purchase Bill (PB alternative)
  static String pbNumber({DateTime? date, int sequence = 1}) =>
      format(prefix: 'PB', date: date, sequence: sequence);
}
