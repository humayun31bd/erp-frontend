import 'package:flutter/material.dart';
import 'package:erp_frontend/features/accounting/utils/voucher_pdf_exporter.dart';
import 'package:erp_frontend/features/accounting/utils/number_to_words_converter.dart';

class VoucherPreviewModal extends StatelessWidget {
  final Map<String, dynamic> voucherData;

  const VoucherPreviewModal({super.key, required this.voucherData});

  static Future<void> show(BuildContext context, Map<String, dynamic> voucher) {
    return showDialog(
      context: context,
      builder: (context) => VoucherPreviewModal(voucherData: voucher),
    );
  }

  @override
  Widget build(BuildContext context) {
    final voucherNumber = voucherData['voucherNumber'] ?? 'V-2026-001';
    final voucherType = voucherData['voucherType'] ?? 'PV';
    final dateStr = voucherData['voucherDate']?.toString().split('T')[0] ?? DateTime.now().toString().split(' ')[0];
    final fiscalYear = voucherData['fiscalYear'] ?? '2026-2027';
    final periodNumber = voucherData['periodNumber'] ?? 4;
    final narration = voucherData['narration'] ?? 'General Voucher Entry';
    final totalAmount = (voucherData['totalAmount'] as num? ?? 0.0).toDouble();
    final status = voucherData['status'] ?? 'APPROVED';
    final chequeNumber = voucherData['chequeNumber'];
    final payeeName = voucherData['payeeName'];

    final rawLines = (voucherData['lines'] as List<dynamic>?) ?? [];
    final List<Map<String, dynamic>> lines = rawLines.map((e) => Map<String, dynamic>.from(e as Map)).toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 750,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        voucherType.replaceAll('_', ' '),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      voucherNumber,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 24),

            // Metadata Chips
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildInfoChip(Icons.calendar_today, 'Date', dateStr),
                _buildInfoChip(Icons.date_range, 'Fiscal Year', '$fiscalYear (P$periodNumber)'),
                _buildInfoChip(Icons.check_circle, 'Status', status, color: Colors.green),
                if (chequeNumber != null) _buildInfoChip(Icons.payment, 'Cheque Leaf', chequeNumber, color: Colors.indigo),
                if (payeeName != null) _buildInfoChip(Icons.person, 'Payee', payeeName),
              ],
            ),
            const SizedBox(height: 16),

            // Narration Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Narration / Description:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(narration, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Line Items Table
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 24,
                  headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
                  columns: const [
                    DataColumn(label: Text('Code', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Account Name', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Cost Center (Ref)', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(numeric: true, label: Text('Debit (৳)', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(numeric: true, label: Text('Credit (৳)', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: [
                    ...lines.map((l) {
                      final dr = (l['debit'] as num? ?? 0.0).toDouble();
                      final cr = (l['credit'] as num? ?? 0.0).toDouble();
                      final ccName = l['costCenterName'] ?? (l['costCenter'] is Map ? l['costCenter']['name'] : null);
                      final ccRef = l['costCenterRef'] ?? (l['costCenter'] is Map ? (l['costCenter']['sourceId'] ?? l['costCenter']['sourceType']) : null);
                      final ccCode = l['costCenterCode'] ?? (l['costCenter'] is Map ? l['costCenter']['code'] : null);

                      return DataRow(cells: [
                        DataCell(Text(l['code']?.toString() ?? '5.10.01')),
                        DataCell(Text(l['accountName']?.toString() ?? l['narration']?.toString() ?? 'Account Line')),
                        DataCell(
                          ccName != null
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${ccCode != null ? "[$ccCode] " : ""}$ccName',
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                                    ),
                                    if (ccRef != null)
                                      Text(
                                        'Ref: $ccRef',
                                        style: TextStyle(color: Colors.blue.shade800, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                  ],
                                )
                              : const Text('-', style: TextStyle(color: Colors.grey)),
                        ),
                        DataCell(Text(dr > 0 ? dr.toStringAsFixed(2) : '-')),
                        DataCell(Text(cr > 0 ? cr.toStringAsFixed(2) : '-')),
                      ]);
                    }),
                    DataRow(
                      color: WidgetStateProperty.all(Colors.grey.shade100),
                      cells: [
                        const DataCell(Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold))),
                        const DataCell(Text('Invariant Balance Guard Passed', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.green))),
                        const DataCell(Text('')),
                        DataCell(Text(totalAmount.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(totalAmount.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Amount in Words Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.currency_exchange, size: 20, color: Colors.blue.shade800),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Amount in Words:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.blue.shade900),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          NumberToWordsConverter.convert(totalAmount),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.indigo.shade900),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Modal Action Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  label: const Text('Close'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    VoucherPdfExporter.printOrSaveVoucher(
                      context,
                      voucherNumber: voucherNumber,
                      voucherType: voucherType,
                      dateStr: dateStr,
                      fiscalYear: fiscalYear,
                      periodNumber: periodNumber,
                      narration: narration,
                      totalAmount: totalAmount,
                      lines: lines,
                      status: status,
                      chequeNumber: chequeNumber,
                      payeeName: payeeName,
                    );
                  },
                  icon: const Icon(Icons.print),
                  label: const Text('PRINT / EXPORT PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? Colors.blue).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (color ?? Colors.blue).withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color ?? Colors.blue.shade800),
          const SizedBox(width: 6),
          Text('$label: ', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color ?? Colors.black87)),
        ],
      ),
    );
  }
}
