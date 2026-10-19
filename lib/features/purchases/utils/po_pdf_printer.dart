import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../domain/procurement_models.dart';
import 'procurement_document_formatter.dart';

class PoPdfPrinter {
  static Future<Uint8List> generatePoPdf({
    required PurchaseOrderModel po,
    String companyName = 'Shapla Mart Enterprise',
    String companyVat = '310000000000003',
    String companyAddress = 'Riyadh, Kingdom of Saudi Arabia',
  }) async {
    final pdf = pw.Document();

    PdfColor statusColor;
    String statusTitle = po.status.toUpperCase();
    switch (statusTitle) {
      case 'ISSUED':
        statusColor = PdfColors.blue800;
        break;
      case 'PARTIAL_RECEIVED':
        statusColor = PdfColors.amber800;
        break;
      case 'RECEIVED':
      case 'COMPLETED':
        statusColor = PdfColors.green800;
        break;
      case 'CANCELLED':
        statusColor = PdfColors.red800;
        break;
      default:
        statusColor = PdfColors.grey700;
    }

    final subtotalVal = double.tryParse(po.subtotalAmount) ?? 0.0;
    final vatVal = double.tryParse(po.vatAmount) ?? 0.0;
    final totalVal = double.tryParse(po.totalAmount) ?? 0.0;

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
                      pw.Text('VAT Reg: $companyVat', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                      pw.Text(companyAddress, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'PURCHASE ORDER',
                        style: const pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.Text(
                        'أمر شراء رسمي',
                        style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
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
              pw.Divider(thickness: 1.5, color: PdfColors.blue900),
              pw.SizedBox(height: 10),

              // PO Metadata & Vendor / Buyer Block
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Vendor Info
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
                          pw.Text('VENDOR / SUPPLIER DETAILS', style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                          pw.SizedBox(height: 4),
                          pw.Text('Name: ${po.supplierName}', style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                          pw.Text('Supplier Code: ${ProcurementDocumentFormatter.formatSupplierCode(po.supplierId)}', style: const pw.TextStyle(fontSize: 9)),
                          if (po.supplierTaxNumber != null && po.supplierTaxNumber!.isNotEmpty)
                            pw.Text('Tax/VAT #: ${po.supplierTaxNumber}', style: const pw.TextStyle(fontSize: 9)),
                          if (po.supplierPhone != null && po.supplierPhone!.isNotEmpty)
                            pw.Text('Phone: ${po.supplierPhone}', style: const pw.TextStyle(fontSize: 9)),
                          if (po.supplierEmail != null && po.supplierEmail!.isNotEmpty)
                            pw.Text('Email: ${po.supplierEmail}', style: const pw.TextStyle(fontSize: 9)),
                          if (po.supplierAddress != null && po.supplierAddress!.isNotEmpty)
                            pw.Text('Address: ${po.supplierAddress}', style: const pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 16),
                  // Order Details
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
                          pw.Text('ORDER SPECIFICATIONS', style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                          pw.SizedBox(height: 4),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('PO Number:', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                              pw.Text(po.poNumber, style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Issue Date:', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                              pw.Text(DateFormat('yyyy-MM-dd').format(po.issueDate), style: const pw.TextStyle(fontSize: 9)),
                            ],
                          ),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Expected Delivery:', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                              pw.Text(
                                po.expectedDeliveryDate != null ? DateFormat('yyyy-MM-dd').format(po.expectedDeliveryDate!) : 'As agreed',
                                style: const pw.TextStyle(fontSize: 9),
                              ),
                            ],
                          ),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Currency:', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                              pw.Text(po.currency, style: const pw.TextStyle(fontSize: 9)),
                            ],
                          ),
                          if (po.csId != null && po.csId!.isNotEmpty)
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text('Ref CS ID:', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                                pw.Text(po.csId!, style: const pw.TextStyle(fontSize: 8)),
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
                color: PdfColors.blue900,
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: pw.Row(
                  children: [
                    pw.SizedBox(width: 24, child: pw.Text('#', style: const pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(flex: 4, child: pw.Text('Item Description', style: const pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(flex: 1, child: pw.Text('Qty', textAlign: pw.TextAlign.center, style: const pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(flex: 2, child: pw.Text('Unit Price', textAlign: pw.TextAlign.right, style: const pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(flex: 1, child: pw.Text('VAT %', textAlign: pw.TextAlign.center, style: const pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold))),
                    pw.Expanded(flex: 2, child: pw.Text('Total (SAR)', textAlign: pw.TextAlign.right, style: const pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold))),
                  ],
                ),
              ),

              // Items Rows
              ...po.items.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final item = entry.value;
                final isEven = idx % 2 == 0;
                return pw.Container(
                  color: isEven ? PdfColors.grey100 : PdfColors.white,
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5))),
                  child: pw.Row(
                    children: [
                      pw.SizedBox(width: 24, child: pw.Text('$idx', style: const pw.TextStyle(fontSize: 9))),
                      pw.Expanded(
                        flex: 4,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(item.description, style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                            if (item.productId != null && item.productId!.isNotEmpty)
                              pw.Text('SKU: ${item.productId}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                          ],
                        ),
                      ),
                      pw.Expanded(flex: 1, child: pw.Text('${item.quantity}', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 9))),
                      pw.Expanded(flex: 2, child: pw.Text(item.unitPrice.toStringAsFixed(2), textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 9))),
                      pw.Expanded(flex: 1, child: pw.Text('${item.vatRate.toStringAsFixed(0)}%', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 9))),
                      pw.Expanded(flex: 2, child: pw.Text(item.totalAmount.toStringAsFixed(2), textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                );
              }),

              pw.SizedBox(height: 12),

              // Summary & Notes
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Notes block
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
                          pw.Text('TERMS & DELIVERY INSTRUCTIONS:', style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            (po.notes != null && po.notes!.isNotEmpty)
                                ? po.notes!
                                : '1. Standard 30 days payment terms upon delivery & inspection.\n2. Goods must strictly match provided specifications.\n3. VAT invoice must accompany the shipment.',
                            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800),
                          ),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 16),
                  // Totals Box
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
                              pw.Text('SAR ${subtotalVal.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 9)),
                            ],
                          ),
                          pw.SizedBox(height: 4),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('VAT (15%):', style: const pw.TextStyle(fontSize: 9)),
                              pw.Text('SAR ${vatVal.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 9)),
                            ],
                          ),
                          pw.Divider(thickness: 1, color: PdfColors.grey400),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('TOTAL DUE:', style: const pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                              pw.Text(
                                'SAR ${totalVal.toStringAsFixed(2)}',
                                style: const pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
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
                      pw.Container(width: 140, height: 1, color: PdfColors.grey500),
                      pw.SizedBox(height: 4),
                      pw.Text('Prepared By', style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Procurement Officer', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(width: 140, height: 1, color: PdfColors.grey500),
                      pw.SizedBox(height: 4),
                      pw.Text('Authorized Approval', style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Head of Procurement / GM', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(width: 140, height: 1, color: PdfColors.grey500),
                      pw.SizedBox(height: 4),
                      pw.Text('Supplier Acceptance', style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Signature & Company Stamp', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'This is a computer generated Purchase Order from Shapla Mart Enterprise ERP.',
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

  static Future<void> printPo(PurchaseOrderModel po) async {
    final pdfBytes = await generatePoPdf(po: po);
    await Printing.layoutPdf(
      name: 'PO_${po.poNumber}.pdf',
      onLayout: (format) async => pdfBytes,
    );
  }
}
