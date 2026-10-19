import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/procurement_models.dart';
import '../../utils/qc_pdf_printer.dart';
import '../../utils/procurement_document_formatter.dart';

class QcDetailsDialog extends StatelessWidget {
  final QualityCheckRecordModel qc;
  final bool isArabic;

  const QcDetailsDialog({
    super.key,
    required this.qc,
    required this.isArabic,
  });

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    switch (status.toUpperCase()) {
      case 'PASSED':
        bg = Colors.green.shade50;
        fg = Colors.green.shade800;
        break;
      case 'PARTIAL_PASSED':
        bg = Colors.amber.shade50;
        fg = Colors.amber.shade900;
        break;
      case 'FAILED':
      case 'REJECTED':
        bg = Colors.red.shade50;
        fg = Colors.red.shade800;
        break;
      default:
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade800;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = isArabic;
    final passRate = qc.totalReceived > 0
        ? ((qc.totalAccepted / qc.totalReceived) * 100).toStringAsFixed(1)
        : '100.0';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 820,
        constraints: const BoxConstraints(maxHeight: 760),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade700,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.verified_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              qc.qcNumber,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const SizedBox(width: 10),
                            _buildStatusBadge(qc.overallStatus),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isAr ? 'تقرير فحص ومطابقة الجودة (QC Inspection Report)' : 'Quality Check Inspection Details',
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overview Specs
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAr ? 'رقم سند الاستلام (GRN #):' : 'Source GRN #:',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  ProcurementDocumentFormatter.formatGrnNumber(qc.grnNumber),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.indigo),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAr ? 'مسؤول الفحص (المفتش):' : 'QC Inspector:',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  qc.inspectorName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAr ? 'تاريخ الفحص:' : 'Inspection Date:',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat('yyyy-MM-dd').format(qc.checkDate),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAr ? 'نسبة القبول (Yield):' : 'Pass Rate (Yield):',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$passRate%',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green.shade800),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Stat Cards
                    Row(
                      children: [
                        _buildStatCard(isAr ? 'المستلم' : 'Received', qc.totalReceived.toStringAsFixed(0), Colors.blue.shade700, Icons.inventory_2_rounded),
                        const SizedBox(width: 10),
                        _buildStatCard(isAr ? 'المقبول' : 'Accepted', qc.totalAccepted.toStringAsFixed(0), Colors.green.shade700, Icons.check_circle_rounded),
                        const SizedBox(width: 10),
                        _buildStatCard(isAr ? 'المرفوض' : 'Rejected', qc.totalRejected.toStringAsFixed(0), Colors.red.shade700, Icons.cancel_rounded),
                        const SizedBox(width: 10),
                        _buildStatCard(isAr ? 'المستبدل' : 'Exchanged', qc.totalExchanged.toStringAsFixed(0), Colors.amber.shade800, Icons.sync_problem_rounded),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Inspected Items Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isAr ? 'الأصناف الخاضعة للفحص' : 'Inspected Line Items',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${qc.items.length} ${isAr ? "أصناف" : "Items"}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Inspected Items Table
                    if (qc.items.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Center(
                          child: Text(
                            isAr ? 'لا توجد تفاصيل أصناف فردية مسجلة' : 'No individual item breakdowns recorded.',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                            columnSpacing: 20,
                            columns: [
                              DataColumn(label: Text(isAr ? 'الصنف' : 'Item Description')),
                              DataColumn(label: Text(isAr ? 'مستلم' : 'Rec'), numeric: true),
                              DataColumn(label: Text(isAr ? 'مقبول' : 'Acc'), numeric: true),
                              DataColumn(label: Text(isAr ? 'مرفوض' : 'Rej'), numeric: true),
                              DataColumn(label: Text(isAr ? 'مستبدل' : 'Exc'), numeric: true),
                              DataColumn(label: Text(isAr ? 'سبب العيب' : 'Defect Reason')),
                              DataColumn(label: Text(isAr ? 'الحالة' : 'Status')),
                            ],
                            rows: qc.items.map((item) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(item.description, style: const TextStyle(fontWeight: FontWeight.w600))),
                                  DataCell(Text('${item.receivedQuantity}')),
                                  DataCell(Text(
                                    '${item.acceptedQuantity}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                  )),
                                  DataCell(Text(
                                    '${item.rejectedQuantity}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: item.rejectedQuantity > 0 ? Colors.red : Colors.grey,
                                    ),
                                  )),
                                  DataCell(Text('${item.exchangedQuantity}')),
                                  DataCell(Text(
                                    item.defectReason != null && item.defectReason!.isNotEmpty ? item.defectReason! : '-',
                                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                                  )),
                                  DataCell(_buildStatusBadge(item.status)),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Remarks
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAr ? 'ملاحظات الفحص والإجراءات المتبعة:' : 'Inspection Remarks & Disposition:',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            (qc.remarks != null && qc.remarks!.isNotEmpty)
                                ? qc.remarks!
                                : (isAr ? 'تم التحقق من مطابقة البضائع للمعايير القياسية.' : 'Goods verified in accordance with QA standards.'),
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.print_rounded, size: 18),
                    label: Text(isAr ? 'طباعة شهادة الفحص (PDF)' : 'Print QC Certificate (PDF)'),
                    onPressed: () => QcPdfPrinter.printQc(qc),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(isAr ? 'إغلاق' : 'Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
