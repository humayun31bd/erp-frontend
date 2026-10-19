import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../domain/procurement_models.dart';
import 'procurement_document_formatter.dart';

class RfqPdfPrinter {
  static Future<Uint8List> generateQuotationPdf({
    required SupplierQuotationModel quotation,
    String companyName = 'Shapla Mart Enterprise',
    String companyVat = '310000000000003',
    String companyAddress = 'Riyadh, Kingdom of Saudi Arabia',
  }) async {
    final pdf = pw.Document();

    PdfColor statusColor;
    final statusTitle = quotation.status.toUpperCase();
    switch (statusTitle) {
      case 'ACCEPTED':
        statusColor = PdfColors.green800;
        break;
      case 'SUBMITTED':
        statusColor = PdfColors.blue800;
        break;
      case 'REJECTED':
        statusColor = PdfColors.red800;
        break;
      case 'DRAFT':
      default:
        statusColor = PdfColors.amber800;
    }

    final totalVal = double.tryParse(quotation.totalAmount) ?? 0.0;
    // Estimate subtotal & vat if not separately stored on quotation root
    final subtotalVal = quotation.items.isNotEmpty
        ? quotation.items.fold<double>(0.0, (acc, item) => acc + (item.quantity * item.unitPrice))
        : totalVal / 1.15;
    final vatVal = totalVal > subtotalVal ? (totalVal - subtotalVal) : (totalVal * 0.15);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Banner
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
                          color: PdfColors.indigo900,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text('VAT Reg: $companyVat', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                      pw.Text(companyAddress, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'REQUEST FOR QUOTATION',
                        style: const pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.indigo900,
                        ),
                      ),
                      pw.Text(
                        'طلب تسعير / عرض سعر مورد',
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
              pw.Divider(thickness: 1.5, color: PdfColors.indigo900),
              pw.SizedBox(height: 10),

              // Metadata & Supplier Block
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Vendor Block
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
                            'SUPPLIER / VENDOR DETAILS',
                            style: const pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.indigo900,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text('Name: ${quotation.supplierName ?? ProcurementDocumentFormatter.formatSupplierCode(quotation.supplierId)}',
                              style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                          pw.Text('Supplier Code: ${ProcurementDocumentFormatter.formatSupplierCode(quotation.supplierId)}',
                              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                          if (quotation.supplierRefNo != null && quotation.supplierRefNo!.isNotEmpty)
                            pw.Text('Supplier Ref #: ${quotation.supplierRefNo}',
                                style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 16),
                  // RFQ Specs Block
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
                            'QUOTATION DETAILS',
                            style: const pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.indigo900,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('RFQ Number:', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                              pw.Text(quotation.quotationNumber,
                                  style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Issue Date:', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                              pw.Text(DateFormat('yyyy-MM-dd').format(quotation.quotationDate),
                                  style: const pw.TextStyle(fontSize: 9)),
                            ],
                          ),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Valid Until:', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                              pw.Text(
                                quotation.validUntil != null
                                    ? DateFormat('yyyy-MM-dd').format(quotation.validUntil!)
                                    : 'Not specified',
                                style: const pw.TextStyle(fontSize: 9),
                              ),
                            ],
                          ),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Currency:', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                              pw.Text(quotation.currency, style: const pw.TextStyle(fontSize: 9)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),

              // Items Table Header
              pw.Container(
                color: PdfColors.indigo900,
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: pw.Row(
                  children: [
                    pw.SizedBox(
                        width: 24,
                        child: pw.Text('#',
                            style: const pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(
                        flex: 4,
                        child: pw.Text('Item Description',
                            style: const pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(
                        flex: 1,
                        child: pw.Text('Qty',
                            textAlign: pw.TextAlign.center,
                            style: const pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(
                        flex: 2,
                        child: pw.Text('Unit Price (SAR)',
                            textAlign: pw.TextAlign.right,
                            style: const pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(
                        flex: 2,
                        child: pw.Text('Total (SAR)',
                            textAlign: pw.TextAlign.right,
                            style: const pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold))),
                  ],
                ),
              ),

              // Items Rows
              if (quotation.items.isEmpty)
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: pw.Center(
                    child: pw.Text(
                      'Quotation total: SAR ${totalVal.toStringAsFixed(2)} (Direct amount)',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                    ),
                  ),
                )
              else
                ...quotation.items.asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final item = entry.value;
                  final isEven = idx % 2 == 0;
                  return pw.Container(
                    color: isEven ? PdfColors.grey100 : PdfColors.white,
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5)),
                    ),
                    child: pw.Row(
                      children: [
                        pw.SizedBox(width: 24, child: pw.Text('$idx', style: const pw.TextStyle(fontSize: 9))),
                        pw.Expanded(
                          flex: 4,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(item.description,
                                  style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                              if (item.productId != null && item.productId!.isNotEmpty)
                                pw.Text('SKU: ${item.productId}',
                                    style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                            ],
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text('${item.quantity}',
                              textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 9)),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(item.unitPrice.toStringAsFixed(2),
                              textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 9)),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(item.totalAmount.toStringAsFixed(2),
                              textAlign: pw.TextAlign.right,
                              style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                }),

              pw.SizedBox(height: 12),

              // Summary & Notes
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                        border: pw.Border.all(color: PdfColors.grey300),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'REMARKS & TERMS:',
                            style: const pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.indigo900,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            (quotation.notes != null && quotation.notes!.isNotEmpty)
                                ? quotation.notes!
                                : '1. Prices are valid until the specified date.\n2. Standard delivery terms as quoted.\n3. Subject to comparative statement review and final PO award.',
                            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800),
                          ),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 16),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey100,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                        border: pw.Border.all(color: PdfColors.grey300),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Subtotal:', style: const pw.TextStyle(fontSize: 9)),
                              pw.Text('SAR ${subtotalVal.toStringAsFixed(2)}',
                                  style: const pw.TextStyle(fontSize: 9)),
                            ],
                          ),
                          pw.SizedBox(height: 4),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('VAT (15%):', style: const pw.TextStyle(fontSize: 9)),
                              pw.Text('SAR ${vatVal.toStringAsFixed(2)}',
                                  style: const pw.TextStyle(fontSize: 9)),
                            ],
                          ),
                          pw.Divider(thickness: 1, color: PdfColors.grey400),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('TOTAL AMOUNT:',
                                  style: const pw.TextStyle(
                                      fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
                              pw.Text(
                                'SAR ${totalVal.toStringAsFixed(2)}',
                                style: const pw.TextStyle(
                                    fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900),
                              ),
                            ],
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
                      pw.Text('Prepared By', style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Procurement Officer', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(width: 130, height: 1, color: PdfColors.grey500),
                      pw.SizedBox(height: 4),
                      pw.Text('Reviewed By', style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Procurement Manager', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(width: 130, height: 1, color: PdfColors.grey500),
                      pw.SizedBox(height: 4),
                      pw.Text('Supplier Acceptance', style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Stamp & Signature', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'Computer generated Supplier Quotation (RFQ) - Shapla Mart Enterprise ERP',
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

  static Future<void> printQuotation(SupplierQuotationModel quotation) async {
    final pdfBytes = await generateQuotationPdf(quotation: quotation);
    await Printing.layoutPdf(
      name: 'RFQ_${quotation.quotationNumber}.pdf',
      onLayout: (format) async => pdfBytes,
    );
  }

  static Future<void> printRfqRegister({
    required List<SupplierQuotationModel> quotations,
    String title = 'Supplier Quotations (RFQ) Registry Report',
  }) async {
    final pdf = pw.Document();

    final totalValue = quotations.fold<double>(
      0.0,
      (sum, q) => sum + (double.tryParse(q.totalAmount) ?? 0.0),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) {
          return [
            // Title Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      title,
                      style: const pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900),
                    ),
                    pw.Text(
                      'Generated on: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())} | Total Records: ${quotations.length}',
                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                    ),
                  ],
                ),
                pw.Text(
                  'Total RFQ Value: SAR ${totalValue.toStringAsFixed(2)}',
                  style: const pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900),
                ),
              ],
            ),
            pw.SizedBox(height: 12),

            // Table
            pw.TableHelper.fromTextArray(
              headers: ['#', 'RFQ Number', 'Supplier Name', 'Ref #', 'Issue Date', 'Valid Until', 'Items', 'Total (SAR)', 'Status'],
              data: quotations.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final q = entry.value;
                return [
                  '$idx',
                  q.quotationNumber,
                  q.supplierName ?? ProcurementDocumentFormatter.formatSupplierCode(q.supplierId),
                  q.supplierRefNo ?? '-',
                  DateFormat('yyyy-MM-dd').format(q.quotationDate),
                  q.validUntil != null ? DateFormat('yyyy-MM-dd').format(q.validUntil!) : '-',
                  '${q.items.length}',
                  (double.tryParse(q.totalAmount) ?? 0.0).toStringAsFixed(2),
                  q.status,
                ];
              }).toList(),
              headerStyle: const pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 8),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo900),
              cellStyle: const pw.TextStyle(fontSize: 8),
              cellHeight: 22,
              cellAlignments: {
                0: pw.Alignment.center,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.centerLeft,
                4: pw.Alignment.center,
                5: pw.Alignment.center,
                6: pw.Alignment.center,
                7: pw.Alignment.centerRight,
                8: pw.Alignment.center,
              },
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    await Printing.layoutPdf(
      name: 'RFQ_Registry_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
      onLayout: (format) async => bytes,
    );
  }
}
