import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../domain/cheque_models.dart';

class ChequePdfPrinter {
  /// Converts currency amount (SAR) into English words
  static String amountToWordsEn(double amount) {
    if (amount <= 0) return 'Zero Saudi Riyals Only';

    final int riyals = amount.truncate();
    final int halalas = ((amount - riyals) * 100).round();

    final String riyalWords = _convertNumberToWords(riyals);
    final String result = '$riyalWords Saudi Riyals';

    if (halalas > 0) {
      final String halalaWords = _convertNumberToWords(halalas);
      return '$result and $halalaWords Halalas Only';
    }

    return '$result Only';
  }

  static String _convertNumberToWords(int number) {
    if (number == 0) return 'Zero';

    final units = [
      '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine',
      'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen',
      'Seventeen', 'Eighteen', 'Nineteen'
    ];

    final tens = [
      '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'
    ];

    if (number < 20) return units[number];
    if (number < 100) {
      return tens[number ~/ 10] + (number % 10 != 0 ? ' ${units[number % 10]}' : '');
    }
    if (number < 1000) {
      return '${units[number ~/ 100]} Hundred${number % 100 != 0 ? ' ${_convertNumberToWords(number % 100)}' : ''}';
    }
    if (number < 1000000) {
      return '${_convertNumberToWords(number ~/ 1000)} Thousand${number % 1000 != 0 ? ' ${_convertNumberToWords(number % 1000)}' : ''}';
    }
    return '${_convertNumberToWords(number ~/ 1000000)} Million${number % 1000000 != 0 ? ' ${_convertNumberToWords(number % 1000000)}' : ''}';
  }

  /// Prints or previews a Cheque Leaf PDF layout based on bank template preset
  static Future<Uint8List> generateChequePdf({
    required ChequeLeafModel leaf,
    required String bankPresetName,
    bool isAcPayeeOnly = true,
  }) async {
    final pdf = pw.Document();

    // Standard Cheque Paper dimensions: 210mm x 90mm
    const chequePageFormat = PdfPageFormat(
      210 * PdfPageFormat.mm,
      90 * PdfPageFormat.mm,
      marginAll: 0,
    );

    final String dateFormatted = leaf.issuedDate != null
        ? DateFormat('dd  MM  yyyy').format(DateTime.parse(leaf.issuedDate!))
        : DateFormat('dd  MM  yyyy').format(DateTime.now());

    final String amountFormatted = NumberFormat('#,##0.00').format(leaf.amount);
    final String amountWords = amountToWordsEn(leaf.amount);

    pdf.addPage(
      pw.Page(
        pageFormat: chequePageFormat,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // A/C Payee Only Stamp
              if (isAcPayeeOnly)
                pw.Positioned(
                  left: 20 * PdfPageFormat.mm,
                  top: 10 * PdfPageFormat.mm,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.black, width: 1.5),
                    ),
                    child: pw.Text(
                      'A/C PAYEE ONLY',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // Date Box (Top Right)
              pw.Positioned(
                left: 155 * PdfPageFormat.mm,
                top: 12 * PdfPageFormat.mm,
                child: pw.Text(
                  dateFormatted,
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),

              // Payee Name (Middle)
              pw.Positioned(
                left: 36 * PdfPageFormat.mm,
                top: 28 * PdfPageFormat.mm,
                child: pw.Text(
                  leaf.payeeName ?? 'Beneficiary',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              // Amount in Words
              pw.Positioned(
                left: 36 * PdfPageFormat.mm,
                top: 42 * PdfPageFormat.mm,
                child: pw.SizedBox(
                  width: 110 * PdfPageFormat.mm,
                  child: pw.Text(
                    '*** $amountWords ***',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Amount in Figures (Right)
              pw.Positioned(
                left: 154 * PdfPageFormat.mm,
                top: 42 * PdfPageFormat.mm,
                child: pw.Text(
                  '** $amountFormatted **',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              // Cheque Leaf Number & Details Footer
              pw.Positioned(
                left: 36 * PdfPageFormat.mm,
                top: 75 * PdfPageFormat.mm,
                child: pw.Text(
                  'Cheque #${leaf.chequeNumber} | ${leaf.bankAccountName ?? "Bank Account"}',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Triggers direct printing in browser or desktop
  static Future<void> printCheque({
    required ChequeLeafModel leaf,
    required String bankPresetName,
  }) async {
    final pdfBytes = await generateChequePdf(leaf: leaf, bankPresetName: bankPresetName);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Cheque_${leaf.chequeNumber}',
    );
  }
}
