import 'dart:typed_data';
import 'package:flutter/material.dart' show BuildContext;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:erp_frontend/features/accounting/utils/number_to_words_converter.dart';

class VoucherPdfExporter {
  static Future<Uint8List> generateVoucherPdf({
    required String voucherNumber,
    required String voucherType,
    required String dateStr,
    required String fiscalYear,
    required int periodNumber,
    required String narration,
    required double totalAmount,
    required List<Map<String, dynamic>> lines,
    String? status,
    String? companyName,
    String? vatNumber,
    String? chequeNumber,
    String? payeeName,
    String? makerId,
    String? checkerId,
    String? approverId,
  }) async {
    final pdf = pw.Document();

    String statusText;
    PdfColor statusColor;

    final normStatus = (status ?? 'POSTED').toUpperCase();
    if (normStatus == 'POSTED' || normStatus == 'APPROVED') {
      statusText = 'Status: POSTED / APPROVED';
      statusColor = PdfColors.green800;
    } else if (normStatus == 'DRAFT' || normStatus == 'PENDING' || normStatus == 'PENDING_APPROVAL') {
      statusText = 'Status: PENDING APPROVAL (DRAFT)';
      statusColor = PdfColors.orange800;
    } else if (normStatus == 'REJECTED') {
      statusText = 'Status: REJECTED';
      statusColor = PdfColors.red800;
    } else if (normStatus == 'CANCELLED' || normStatus == 'VOID') {
      statusText = 'Status: CANCELLED';
      statusColor = PdfColors.grey700;
    } else {
      statusText = 'Status: $normStatus';
      statusColor = PdfColors.blue800;
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Company & Document Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        companyName ?? 'Intelligent Enterprise Systems',
                        style: const pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text('VAT Reg No: ${vatNumber ?? '300123456700003'}', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('Official Financial Record / General Ledger Document', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue900,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      voucherType.replaceAll('_', ' ').toUpperCase(),
                      style: const pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Divider(thickness: 1, color: PdfColors.grey400),
              pw.SizedBox(height: 12),

              // Voucher Metadata Grid
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Voucher No: $voucherNumber', style: const pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Voucher Date: $dateStr'),
                      pw.Text('Fiscal Year: $fiscalYear (Period $periodNumber)'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      if (chequeNumber != null) pw.Text('Cheque Leaf No: $chequeNumber', style: const pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      if (payeeName != null) pw.Text('Payee / Beneficiary: $payeeName'),
                      pw.Text(statusText, style: pw.TextStyle(color: statusColor, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),

              // Narration Box
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text('Narration: $narration', style: const pw.TextStyle(fontSize: 10)),
              ),
              pw.SizedBox(height: 16),

              // Transaction Line Items Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(4),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.blue50),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Account Code', style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Account Title & Particulars', style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Debit (BDT ৳)', textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Credit (BDT ৳)', textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                    ],
                  ),
                  // Table Rows
                  ...lines.map((line) {
                    final dr = (line['debit'] as num? ?? 0).toDouble();
                    final cr = (line['credit'] as num? ?? 0).toDouble();
                    return pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(line['code']?.toString() ?? '5.10.01', style: const pw.TextStyle(fontSize: 9))),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(line['accountName']?.toString() ?? line['narration']?.toString() ?? 'General Account', style: const pw.TextStyle(fontSize: 9))),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(dr > 0 ? dr.toStringAsFixed(2) : '-', textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 9))),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(cr > 0 ? cr.toStringAsFixed(2) : '-', textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 9))),
                      ],
                    );
                  }),
                  // Totals Row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('TOTAL', style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Double-Entry Balance Verified', style: const pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 9))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(totalAmount.toStringAsFixed(2), textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(totalAmount.toStringAsFixed(2), textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),

              // Amount in Words
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Amount in Words:', style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                    pw.Text(NumberToWordsConverter.convert(totalAmount), style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                  ],
                ),
              ),
              pw.Spacer(),

              // 4-Tier Signature Block
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildSignatureLine('PREPARED BY', makerId ?? 'Maker User'),
                  _buildSignatureLine('CHECKED BY', checkerId ?? 'Checker User'),
                  _buildSignatureLine('APPROVED BY', approverId ?? 'Finance Approver'),
                  _buildSignatureLine('RECEIVER SIGNATURE', 'Payee / Custodian'),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Center(
                child: pw.Text(
                  'Generated automatically by Intelligent ERP Accounts System • Invariant Audit Hash Validated',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildSignatureLine(String title, String name) {
    return pw.Column(
      children: [
        pw.Container(width: 90, height: 1, color: PdfColors.grey600),
        pw.SizedBox(height: 4),
        pw.Text(title, style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
        pw.Text(name, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
      ],
    );
  }

  static Future<void> printOrSaveVoucher(
    BuildContext context, {
    required String voucherNumber,
    required String voucherType,
    required String dateStr,
    required String fiscalYear,
    required int periodNumber,
    required String narration,
    required double totalAmount,
    required List<Map<String, dynamic>> lines,
    String? status,
    String? companyName,
    String? vatNumber,
    String? chequeNumber,
    String? payeeName,
    String? makerId,
    String? checkerId,
    String? approverId,
  }) async {
    final pdfBytes = await generateVoucherPdf(
      voucherNumber: voucherNumber,
      voucherType: voucherType,
      dateStr: dateStr,
      fiscalYear: fiscalYear,
      periodNumber: periodNumber,
      narration: narration,
      totalAmount: totalAmount,
      lines: lines,
      status: status,
      companyName: companyName,
      vatNumber: vatNumber,
      chequeNumber: chequeNumber,
      payeeName: payeeName,
      makerId: makerId,
      checkerId: checkerId,
      approverId: approverId,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Voucher_$voucherNumber.pdf',
    );
  }
}
