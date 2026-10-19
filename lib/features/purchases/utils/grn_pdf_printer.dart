import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../domain/procurement_models.dart';
import 'procurement_document_formatter.dart';

class GrnPdfPrinter {
  static Future<Uint8List> generateGrnPdf({
    required GoodsReceivedNoteModel grn,
    String companyName = 'Shapla Mart Enterprise',
    String companyVat = '310000000000003',
    String companyAddress = 'Riyadh, Kingdom of Saudi Arabia',
  }) async {
    final pdf = pw.Document();

    PdfColor statusColor;
    String statusTitle = grn.status.toUpperCase();
    switch (statusTitle) {
      case 'RECEIVED':
        statusColor = PdfColors.blue800;
        break;
      case 'QC_PENDING':
        statusColor = PdfColors.amber800;
        break;
      case 'QC_COMPLETED':
      case 'ACCEPTED':
        statusColor = PdfColors.green800;
        break;
      case 'REJECTED':
        statusColor = PdfColors.red800;
        break;
      default:
        statusColor = PdfColors.grey700;
    }

    final totalOrdered = grn.totalOrderedQuantity;
    final totalReceived = grn.totalReceivedQuantity;
    final totalVal = grn.totalValue;

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
                          color: PdfColors.blue900,
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
                        'GOODS RECEIVED NOTE (GRN)',
                        style: const pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.Text(
                        'سند استلام البضائع والمستودعات',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: pw.BoxDecoration(
                          color: statusColor,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                        ),
                        child: pw.Text(
                          'STATUS: $statusTitle',
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

              pw.SizedBox(height: 14),
              pw.Divider(color: PdfColors.grey400, thickness: 1),
              pw.SizedBox(height: 8),

              // Two Box Metadata
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Supplier Info Box
                  pw.Expanded(
                    flex: 5,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                        color: PdfColors.grey100,
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'SUPPLIER / VENDOR DETAILS:',
                            style: const pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue900,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            grn.supplierName,
                            style: const pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text('Supplier Code: ${ProcurementDocumentFormatter.formatSupplierCode(grn.supplierId)}',
                              style: const pw.TextStyle(fontSize: 9)),
                          if (grn.supplierTaxNumber != null && grn.supplierTaxNumber!.isNotEmpty)
                            pw.Text('VAT/Tax ID: ${grn.supplierTaxNumber}',
                                style: const pw.TextStyle(fontSize: 9)),
                          if (grn.supplierPhone != null && grn.supplierPhone!.isNotEmpty)
                            pw.Text('Phone: ${grn.supplierPhone}',
                                style: const pw.TextStyle(fontSize: 9)),
                          if (grn.supplierEmail != null && grn.supplierEmail!.isNotEmpty)
                            pw.Text('Email: ${grn.supplierEmail}',
                                style: const pw.TextStyle(fontSize: 9)),
                          if (grn.supplierAddress != null && grn.supplierAddress!.isNotEmpty)
                            pw.Text('Address: ${grn.supplierAddress}',
                                style: const pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 14),
                  // GRN Metadata Box
                  pw.Expanded(
                    flex: 5,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                        color: PdfColors.grey100,
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'RECEIVING INFORMATION:',
                            style: const pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue900,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          _buildPdfMetaRow('GRN Number:', grn.grnNumber, isBold: true),
                          _buildPdfMetaRow('Received Date:',
                              DateFormat('yyyy-MM-dd HH:mm').format(grn.receivedDate)),
                          _buildPdfMetaRow(
                              'PO Reference:',
                              ProcurementDocumentFormatter.formatPoNumber(grn.poNumber, grn.poId)),
                          _buildPdfMetaRow('Delivery / Waybill #:',
                              grn.deliveryNoteNumber ?? 'N/A'),
                          _buildPdfMetaRow(
                              'Warehouse / Store:', grn.warehouseName ?? 'Central Warehouse'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 16),

              // Items Table Title
              pw.Text(
                'RECEIVED ITEMS SPECIFICATION',
                style: const pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 6),

              // Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                columnWidths: {
                  0: const pw.FixedColumnWidth(26), // SL
                  1: const pw.FlexColumnWidth(3.5), // Description
                  2: const pw.FlexColumnWidth(1.4), // Ordered
                  3: const pw.FlexColumnWidth(1.4), // Received
                  4: const pw.FlexColumnWidth(1.4), // Diff
                  5: const pw.FlexColumnWidth(1.5), // Unit Price
                  6: const pw.FlexColumnWidth(1.8), // Total Value
                },
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.blue50),
                    children: [
                      _buildTableHeaderCell('#'),
                      _buildTableHeaderCell('Item Description'),
                      _buildTableHeaderCell('Ordered', align: pw.TextAlign.right),
                      _buildTableHeaderCell('Received', align: pw.TextAlign.right),
                      _buildTableHeaderCell('Diff', align: pw.TextAlign.right),
                      _buildTableHeaderCell('Unit (SAR)', align: pw.TextAlign.right),
                      _buildTableHeaderCell('Total (SAR)', align: pw.TextAlign.right),
                    ],
                  ),
                  // Table Rows
                  ...List.generate(grn.items.length, (index) {
                    final item = grn.items[index];
                    final diff = item.receivedQuantity - item.orderedQuantity;
                    final rowTotal = item.receivedQuantity * item.unitPrice;
                    final isEven = index % 2 == 0;
                    return pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: isEven ? PdfColors.white : PdfColors.grey50,
                      ),
                      children: [
                        _buildTableCell('${index + 1}', align: pw.TextAlign.center),
                        _buildTableCell(item.description, isBold: true),
                        _buildTableCell(item.orderedQuantity.toStringAsFixed(1),
                            align: pw.TextAlign.right),
                        _buildTableCell(item.receivedQuantity.toStringAsFixed(1),
                            align: pw.TextAlign.right,
                            isBold: true,
                            color: PdfColors.blue900),
                        _buildTableCell(
                          diff == 0
                              ? '0.0'
                              : (diff > 0 ? '+${diff.toStringAsFixed(1)}' : diff.toStringAsFixed(1)),
                          align: pw.TextAlign.right,
                          color: diff < 0 ? PdfColors.red800 : (diff > 0 ? PdfColors.amber900 : PdfColors.grey700),
                        ),
                        _buildTableCell(item.unitPrice.toStringAsFixed(2),
                            align: pw.TextAlign.right),
                        _buildTableCell(rowTotal.toStringAsFixed(2),
                            align: pw.TextAlign.right, isBold: true),
                      ],
                    );
                  }),
                ],
              ),

              pw.SizedBox(height: 10),

              // Summary Box & Fulfillment
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 5,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                        color: PdfColors.grey50,
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('RECEIVING REMARKS / INSPECTION NOTES:',
                              style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            grn.remarks != null && grn.remarks!.isNotEmpty
                                ? grn.remarks!
                                : 'All consignments unloaded, checked against delivery docket, packaging in sound condition.',
                            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800),
                          ),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 14),
                  pw.Expanded(
                    flex: 5,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue50,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                        border: pw.Border.all(color: PdfColors.blue200),
                      ),
                      child: pw.Column(
                        children: [
                          _buildPdfSummaryRow('Total Items Count:', '${grn.items.length} Lines'),
                          _buildPdfSummaryRow('Total Ordered Quantity:', totalOrdered.toStringAsFixed(1)),
                          _buildPdfSummaryRow('Total Received Quantity:', totalReceived.toStringAsFixed(1), isBold: true),
                          pw.Divider(color: PdfColors.blue300, thickness: 0.5),
                          _buildPdfSummaryRow(
                            'Estimated Value (SAR):',
                            'SAR ${totalVal.toStringAsFixed(2)}',
                            isBold: true,
                            fontSize: 10,
                            color: PdfColors.blue900,
                          ),
                          _buildPdfSummaryRow(
                            'Order Fulfillment Rate:',
                            '${grn.fulfillmentRate.toStringAsFixed(1)}%',
                            isBold: true,
                            color: grn.fulfillmentRate >= 100 ? PdfColors.green800 : PdfColors.amber800,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
                      pw.Text('Storekeeper / Received By',
                          style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Signature & Date',
                          style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(width: 130, height: 1, color: PdfColors.grey500),
                      pw.SizedBox(height: 4),
                      pw.Text('Quality Inspector (QC)',
                          style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Inspection Sign-off',
                          style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(width: 130, height: 1, color: PdfColors.grey500),
                      pw.SizedBox(height: 4),
                      pw.Text('Warehouse Manager',
                          style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Stock In Approval',
                          style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'This is an official computer-generated Goods Received Note from Shapla Mart Enterprise ERP.',
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

  static pw.Widget _buildPdfMetaRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 8.5,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTableHeaderCell(String text, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: pw.Text(
        text,
        textAlign: align,
        style: const pw.TextStyle(
          fontSize: 8.5,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blue900,
        ),
      ),
    );
  }

  static pw.Widget _buildTableCell(
    String text, {
    pw.TextAlign align = pw.TextAlign.left,
    bool isBold = false,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? PdfColors.black,
        ),
      ),
    );
  }

  static pw.Widget _buildPdfSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 8.5,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: fontSize, color: PdfColors.grey800)),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color ?? PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> printGrn(GoodsReceivedNoteModel grn) async {
    final pdfBytes = await generateGrnPdf(grn: grn);
    await Printing.layoutPdf(
      name: 'GRN_${grn.grnNumber}.pdf',
      onLayout: (format) async => pdfBytes,
    );
  }

  static Future<void> shareGrn(GoodsReceivedNoteModel grn) async {
    final pdfBytes = await generateGrnPdf(grn: grn);
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'GRN_${grn.grnNumber}.pdf',
    );
  }
}
