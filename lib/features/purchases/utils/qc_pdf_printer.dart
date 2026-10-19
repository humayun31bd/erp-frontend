import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../domain/procurement_models.dart';
import 'procurement_document_formatter.dart';

class QcPdfPrinter {
  static Future<Uint8List> generateQcPdf({
    required QualityCheckRecordModel qc,
    String companyName = 'Shapla Mart Enterprise',
    String companyVat = '310000000000003',
    String companyAddress = 'Riyadh, Kingdom of Saudi Arabia',
  }) async {
    final pdf = pw.Document();

    PdfColor statusColor;
    final statusTitle = qc.overallStatus.toUpperCase();
    switch (statusTitle) {
      case 'PASSED':
        statusColor = PdfColors.green800;
        break;
      case 'PARTIAL_PASSED':
        statusColor = PdfColors.amber800;
        break;
      case 'FAILED':
      case 'REJECTED':
        statusColor = PdfColors.red800;
        break;
      default:
        statusColor = PdfColors.blue800;
    }

    final passRate = qc.totalReceived > 0
        ? ((qc.totalAccepted / qc.totalReceived) * 100).toStringAsFixed(1)
        : '100.0';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        companyName,
                        style: const pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.teal900,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text('VAT Reg: $companyVat',
                          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                      pw.Text(companyAddress,
                          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'QUALITY INSPECTION CERTIFICATE',
                        style: const pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.teal900,
                        ),
                      ),
                      pw.Text(
                        'شهادة فحص ومطابقة الجودة',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: statusColor,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                        ),
                        child: pw.Text(
                          'RESULT: $statusTitle',
                          style: const pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Divider(thickness: 1.5, color: PdfColors.teal900),
              pw.SizedBox(height: 10),

              // Metadata Blocks
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // QC & GRN References
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey100,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                        border: pw.Border.all(color: PdfColors.grey300),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'INSPECTION SPECIFICATIONS',
                            style: const pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.teal900,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('QC Certificate #:',
                                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                              pw.Text(qc.qcNumber,
                                  style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Source GRN #:',
                                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                              pw.Text(ProcurementDocumentFormatter.formatGrnNumber(qc.grnNumber),
                                  style: const pw.TextStyle(
                                      fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                            ],
                          ),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Inspection Date:',
                                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                              pw.Text(DateFormat('yyyy-MM-dd').format(qc.checkDate),
                                  style: const pw.TextStyle(fontSize: 9)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 16),
                  // Inspector & Yield Block
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey100,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                        border: pw.Border.all(color: PdfColors.grey300),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'AUDIT & PERSONNEL',
                            style: const pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.teal900,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Lead Inspector:',
                                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                              pw.Text(qc.inspectorName,
                                  style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Acceptance Yield:',
                                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                              pw.Text('$passRate%',
                                  style: const pw.TextStyle(
                                      fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                            ],
                          ),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Total Items Tested:',
                                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                              pw.Text('${qc.items.length}',
                                  style: const pw.TextStyle(fontSize: 9)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 12),

              // Summary Stat Cards Row
              pw.Row(
                children: [
                  _buildPdfStatBox('Total Received', qc.totalReceived.toStringAsFixed(0), PdfColors.blue800),
                  pw.SizedBox(width: 8),
                  _buildPdfStatBox('Total Accepted', qc.totalAccepted.toStringAsFixed(0), PdfColors.green800),
                  pw.SizedBox(width: 8),
                  _buildPdfStatBox('Total Rejected', qc.totalRejected.toStringAsFixed(0), PdfColors.red800),
                  pw.SizedBox(width: 8),
                  _buildPdfStatBox('Exchanged / Rework', qc.totalExchanged.toStringAsFixed(0), PdfColors.amber800),
                ],
              ),
              pw.SizedBox(height: 16),

              // Items Table Header
              pw.Container(
                color: PdfColors.teal900,
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: pw.Row(
                  children: [
                    pw.SizedBox(
                        width: 24,
                        child: pw.Text('#',
                            style: const pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(
                        flex: 4,
                        child: pw.Text('Item Description',
                            style: const pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(
                        flex: 1,
                        child: pw.Text('Rec',
                            textAlign: pw.TextAlign.center,
                            style: const pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(
                        flex: 1,
                        child: pw.Text('Acc',
                            textAlign: pw.TextAlign.center,
                            style: const pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(
                        flex: 1,
                        child: pw.Text('Rej',
                            textAlign: pw.TextAlign.center,
                            style: const pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(
                        flex: 1,
                        child: pw.Text('Exc',
                            textAlign: pw.TextAlign.center,
                            style: const pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(
                        flex: 2,
                        child: pw.Text('Defect Reason',
                            style: const pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(
                        flex: 2,
                        child: pw.Text('Status',
                            textAlign: pw.TextAlign.center,
                            style: const pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold))),
                  ],
                ),
              ),

              // Items Rows
              if (qc.items.isEmpty)
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  child: pw.Center(
                    child: pw.Text('No individual item breakdowns recorded.',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                  ),
                )
              else
                ...qc.items.asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final item = entry.value;
                  final isEven = idx % 2 == 0;

                  PdfColor itemColor = PdfColors.green800;
                  if (item.rejectedQuantity > 0 && item.acceptedQuantity == 0) {
                    itemColor = PdfColors.red800;
                  } else if (item.rejectedQuantity > 0 || item.exchangedQuantity > 0) {
                    itemColor = PdfColors.amber800;
                  }

                  return pw.Container(
                    color: isEven ? PdfColors.grey100 : PdfColors.white,
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5)),
                    ),
                    child: pw.Row(
                      children: [
                        pw.SizedBox(width: 24, child: pw.Text('$idx', style: const pw.TextStyle(fontSize: 8))),
                        pw.Expanded(
                          flex: 4,
                          child: pw.Text(item.description,
                              style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text('${item.receivedQuantity}',
                              textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 8)),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text('${item.acceptedQuantity}',
                              textAlign: pw.TextAlign.center,
                              style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text('${item.rejectedQuantity}',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.bold,
                                  color: item.rejectedQuantity > 0 ? PdfColors.red800 : PdfColors.grey600)),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text('${item.exchangedQuantity}',
                              textAlign: pw.TextAlign.center,
                              style: const pw.TextStyle(fontSize: 8)),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            item.defectReason != null && item.defectReason!.isNotEmpty ? item.defectReason! : '-',
                            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            item.status,
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: itemColor),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

              pw.SizedBox(height: 14),

              // Remarks Box
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('INSPECTION REMARKS & DISPOSITION:',
                        style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      (qc.remarks != null && qc.remarks!.isNotEmpty)
                          ? qc.remarks!
                          : 'Goods verified in accordance with procurement quality guidelines. Accepted quantities moved to warehouse inventory. Rejected items quarantined for vendor return / debit note.',
                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800),
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // Signatures
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(width: 130, height: 1, color: PdfColors.grey500),
                      pw.SizedBox(height: 4),
                      pw.Text(qc.inspectorName, style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.Text('QC Inspector', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(width: 130, height: 1, color: PdfColors.grey500),
                      pw.SizedBox(height: 4),
                      pw.Text('Warehouse Supervisor',
                          style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Goods Receipt Custodian', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(width: 130, height: 1, color: PdfColors.grey500),
                      pw.SizedBox(height: 4),
                      pw.Text('QA & Procurement Lead',
                          style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Approved Certification', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'Quality Management System (QMS) - Shapla Mart Enterprise ERP',
                  style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey500),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildPdfStatBox(String title, String val, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: pw.BoxDecoration(
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          border: pw.Border.all(color: PdfColors.grey300),
        ),
        child: pw.Column(
          children: [
            pw.Text(val, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: color)),
            pw.SizedBox(height: 2),
            pw.Text(title, style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
          ],
        ),
      ),
    );
  }

  static Future<void> printQc(QualityCheckRecordModel qc) async {
    final pdfBytes = await generateQcPdf(qc: qc);
    await Printing.layoutPdf(
      name: 'QC_${qc.qcNumber}.pdf',
      onLayout: (format) async => pdfBytes,
    );
  }

  static Future<void> printQcRegister({
    required List<QualityCheckRecordModel> qcList,
    String title = 'Quality Check (QC) Audit Register Report',
  }) async {
    final pdf = pw.Document();

    final totalRec = qcList.fold<double>(0.0, (sum, q) => sum + q.totalReceived);
    final totalAcc = qcList.fold<double>(0.0, (sum, q) => sum + q.totalAccepted);
    final totalRej = qcList.fold<double>(0.0, (sum, q) => sum + q.totalRejected);
    final passRate = totalRec > 0 ? ((totalAcc / totalRec) * 100).toStringAsFixed(1) : '100.0';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(title,
                        style: const pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
                    pw.Text(
                      'Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())} | Total Records: ${qcList.length}',
                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                    ),
                  ],
                ),
                pw.Text(
                  'Yield: $passRate% | Rec: ${totalRec.toStringAsFixed(0)} | Acc: ${totalAcc.toStringAsFixed(0)} | Rej: ${totalRej.toStringAsFixed(0)}',
                  style: const pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900),
                ),
              ],
            ),
            pw.SizedBox(height: 12),
            pw.TableHelper.fromTextArray(
              headers: ['#', 'QC Number', 'GRN #', 'Inspector', 'Date', 'Received', 'Accepted', 'Rejected', 'Exchanged', 'Status'],
              data: qcList.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final q = entry.value;
                return [
                  '$idx',
                  q.qcNumber,
                  q.grnNumber,
                  q.inspectorName,
                  DateFormat('yyyy-MM-dd').format(q.checkDate),
                  q.totalReceived.toStringAsFixed(0),
                  q.totalAccepted.toStringAsFixed(0),
                  q.totalRejected.toStringAsFixed(0),
                  q.totalExchanged.toStringAsFixed(0),
                  q.overallStatus,
                ];
              }).toList(),
              headerStyle: const pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 8),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.teal900),
              cellStyle: const pw.TextStyle(fontSize: 8),
              cellHeight: 22,
              cellAlignments: {
                0: pw.Alignment.center,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.centerLeft,
                4: pw.Alignment.center,
                5: pw.Alignment.centerRight,
                6: pw.Alignment.centerRight,
                7: pw.Alignment.centerRight,
                8: pw.Alignment.centerRight,
                9: pw.Alignment.center,
              },
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    await Printing.layoutPdf(
      name: 'QC_Registry_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
      onLayout: (format) async => bytes,
    );
  }
}
