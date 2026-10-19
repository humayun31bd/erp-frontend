import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../domain/invoice_responses.dart';
import 'package:intl/intl.dart';

class PdfGenerator {
  static Future<void> printInvoice(InvoiceDetail invoice) async {
    final pdf = pw.Document();

    // Default mock ZATCA QR Base64 if not available
    final qrData = invoice.qrCodeBase64 ?? "AQVTYWZlYgIPMzEyMzQ1Njc4OTEyMzQzAxQyMDIzLTEwLTI2VDEwOjMwOjAwWgQFMTAwLjAwBQUxNS4wMA==";

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Intelligent ERP', style: const pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Tax Invoice', style: const pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Invoice No: ${invoice.invoiceNumber}'),
                    pw.Text('Date: ${DateFormat('yyyy-MM-dd').format(invoice.issueDatetime)}'),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 32),
            
            // Seller & Buyer Info
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('From:', style: const pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(invoice.sellerName),
                      if (invoice.sellerVat != null) pw.Text('VAT No: ${invoice.sellerVat}'),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Billed To:', style: const pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(invoice.buyerName),
                      if (invoice.buyerVat != null) pw.Text('VAT No: ${invoice.buyerVat}'),
                    ],
                  ),
                ),
              ],
            ),
            
            pw.Divider(height: 48),
            
            // Line Items Table
            pw.TableHelper.fromTextArray(
              headers: const ['Description', 'Qty', 'Unit Price', 'Total'],
              data: invoice.lineItems.map((item) {
                return [
                  item.description,
                  item.quantity,
                  item.unitPrice,
                  item.lineTotal,
                ];
              }).toList(),
              headerStyle: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellHeight: 30,
              cellAlignments: const {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerRight,
                2: pw.Alignment.centerRight,
                3: pw.Alignment.centerRight,
              },
            ),

            pw.Divider(height: 48),

            // Footer with QR Code and Totals
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                // ZATCA QR Code
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('ZATCA QR Code', style: const pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 8),
                    pw.BarcodeWidget(
                      data: qrData,
                      barcode: pw.Barcode.qrCode(),
                      width: 100,
                      height: 100,
                    ),
                  ],
                ),
                // Totals
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Subtotal: ${invoice.subtotalAmount} SAR'),
                    pw.Text('VAT (15%): ${invoice.totalVatAmount} SAR'),
                    pw.Text(
                      'Total: ${invoice.totalAmount} SAR',
                      style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Invoice_${invoice.invoiceNumber}.pdf',
    );
  }
}
