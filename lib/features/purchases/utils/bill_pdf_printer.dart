import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../domain/procurement_models.dart';
import 'procurement_document_formatter.dart';

class BillPdfPrinter {
  static Future<Uint8List> generateBillPdf({
    required SupplierBillModel bill,
    String companyName = 'Shapla Mart Enterprise',
    String companyVat = '310000000000003',
    String companyAddress = 'Riyadh, Kingdom of Saudi Arabia',
  }) async {
    final pdf = pw.Document();

    final statusStr = bill.paymentStatus.toUpperCase();
    PdfColor statusColor;
    switch (statusStr) {
      case 'PAID':
        statusColor = PdfColors.green800;
        break;
      case 'PARTIAL':
        statusColor = PdfColors.amber800;
        break;
      case 'UNPAID':
      default:
        statusColor = PdfColors.red800;
    }

    final totalVal = double.tryParse(bill.totalAmount) ?? 0.0;
    final paidVal = double.tryParse(bill.paidAmount) ?? 0.0;
    final discountVal = double.tryParse(bill.discountAmount) ?? 0.0;
    final subtotalVal = double.tryParse(bill.subtotalAmount) ?? (totalVal / 1.15);
    final taxableVal = (subtotalVal - discountVal).clamp(0.0, double.infinity);
    final vatVal = double.tryParse(bill.vatAmount) ?? (totalVal - taxableVal);
    final balanceVal = totalVal - paidVal;

    final dateFormat = DateFormat('yyyy-MM-dd');
    final issueDateStr = dateFormat.format(bill.issueDate);
    final dueDateStr = bill.dueDate != null ? dateFormat.format(bill.dueDate!) : 'Upon Receipt';

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
                        'SUPPLIER BILL (AP)',
                        style: const pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.indigo900,
                        ),
                      ),
                      pw.Text(
                        'فاتورة المورد / حسابات الذمم الدائنة',
                        style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: statusColor,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                        ),
                        child: pw.Text(
                          'STATUS: $statusStr',
                          style: const pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 16),
              pw.Divider(color: PdfColors.grey400, thickness: 1),
              pw.SizedBox(height: 12),

              // Metadata Cards Row
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Vendor Info Box
                  pw.Expanded(
                    flex: 5,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                        border: pw.Border.all(color: PdfColors.grey300),
                        color: PdfColors.grey100,
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'VENDOR / SUPPLIER DETAILS',
                            style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            bill.supplierName,
                            style: const pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text('Supplier Code: ${ProcurementDocumentFormatter.formatSupplierCode(bill.supplierId)}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
                          if (bill.poId != null && bill.poId!.isNotEmpty) ...[
                            pw.SizedBox(height: 2),
                            pw.Text('Linked Purchase Order: ${ProcurementDocumentFormatter.formatPoNumber(bill.poId, bill.poId)}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
                          ],
                          if (bill.grnId != null && bill.grnId!.isNotEmpty) ...[
                            pw.SizedBox(height: 2),
                            pw.Text('Linked GRN: ${ProcurementDocumentFormatter.formatGrnNumber(bill.grnId, bill.grnId)}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
                          ],
                        ],
                      ),
                    ),
                  ),

                  pw.SizedBox(width: 16),

                  // Bill Info Box
                  pw.Expanded(
                    flex: 5,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                        border: pw.Border.all(color: PdfColors.grey300),
                        color: PdfColors.grey100,
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'BILL & PAYMENT METADATA',
                            style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900),
                          ),
                          pw.SizedBox(height: 4),
                          _buildPdfMetaRow('Bill Voucher #:', bill.billNumber, isBold: true),
                          pw.SizedBox(height: 2),
                          _buildPdfMetaRow('Bill Issue Date:', issueDateStr),
                          pw.SizedBox(height: 2),
                          _buildPdfMetaRow('Payment Due Date:', dueDateStr),
                          pw.SizedBox(height: 2),
                          _buildPdfMetaRow('Payment Status:', statusStr, valColor: statusColor),
                          if (bill.referenceDocName != null && bill.referenceDocName!.isNotEmpty) ...[
                            pw.SizedBox(height: 2),
                            _buildPdfMetaRow('Ref Doc Attached:', bill.referenceDocName!),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 16),

              // Remarks & Reference banner if any
              if (bill.remarks != null && bill.remarks!.trim().isNotEmpty) ...[
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.amber50,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                    border: pw.Border.all(color: PdfColors.amber300),
                  ),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Remarks / Invoice Ref: ', style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.amber900)),
                      pw.Expanded(
                        child: pw.Text(bill.remarks!, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),
              ],

              // Financial Breakdown Table
              pw.Text(
                'ACCOUNTING & FINANCIAL SUMMARY / ملخص الحسابات',
                style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900),
              ),
              pw.SizedBox(height: 6),

              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.8),
                columnWidths: {
                  0: const pw.FlexColumnWidth(6),
                  1: const pw.FlexColumnWidth(4),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.indigo50),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: pw.Text('Description / Financial Component', style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: pw.Text('Amount (SAR)', textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
                      ),
                    ],
                  ),
                  _buildPdfTableRow('Goods / Services Gross Subtotal', 'SAR ${subtotalVal.toStringAsFixed(2)}'),
                  if (discountVal > 0)
                    _buildPdfTableRow('Less: Supplier Discount', '- SAR ${discountVal.toStringAsFixed(2)}', valueColor: PdfColors.amber900),
                  if (discountVal > 0)
                    _buildPdfTableRow('Net Taxable Subtotal (Base)', 'SAR ${taxableVal.toStringAsFixed(2)}'),
                  _buildPdfTableRow('Value Added Tax (15% VAT)', 'SAR ${vatVal.toStringAsFixed(2)}'),
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: pw.Text('Total Invoiced Amount (Gross)', style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: pw.Text('SAR ${totalVal.toStringAsFixed(2)}', textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  _buildPdfTableRow('Disbursed Payments to Date (Paid)', 'SAR ${paidVal.toStringAsFixed(2)}', valueColor: PdfColors.green800),
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: balanceVal > 0 ? PdfColors.red50 : PdfColors.green50,
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        child: pw.Text(
                          'Outstanding Accounts Payable Balance (Due)',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: balanceVal > 0 ? PdfColors.red900 : PdfColors.green900,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        child: pw.Text(
                          'SAR ${balanceVal.toStringAsFixed(2)}',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: balanceVal > 0 ? PdfColors.red900 : PdfColors.green900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 24),

              // KPI Stats Row
              pw.Row(
                children: [
                  _buildPdfStatBox('Subtotal', 'SAR ${subtotalVal.toStringAsFixed(2)}', PdfColors.indigo900),
                  pw.SizedBox(width: 8),
                  _buildPdfStatBox('15% VAT', 'SAR ${vatVal.toStringAsFixed(2)}', PdfColors.blue800),
                  pw.SizedBox(width: 8),
                  _buildPdfStatBox('Total Invoiced', 'SAR ${totalVal.toStringAsFixed(2)}', PdfColors.indigo900),
                  pw.SizedBox(width: 8),
                  _buildPdfStatBox('Paid', 'SAR ${paidVal.toStringAsFixed(2)}', PdfColors.green800),
                  pw.SizedBox(width: 8),
                  _buildPdfStatBox('Balance Due', 'SAR ${balanceVal.toStringAsFixed(2)}', balanceVal > 0 ? PdfColors.red800 : PdfColors.green800),
                ],
              ),

              pw.Spacer(),

              // Signatures Section
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(width: 140, height: 1, color: PdfColors.grey500),
                      pw.SizedBox(height: 4),
                      pw.Text('Prepared By', style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Procurement / Accounts Clerk', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(width: 140, height: 1, color: PdfColors.grey500),
                      pw.SizedBox(height: 4),
                      pw.Text('Verified By', style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Accounts Payable Specialist', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(width: 140, height: 1, color: PdfColors.grey500),
                      pw.SizedBox(height: 4),
                      pw.Text('Approved For Payment', style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Finance Manager / CFO', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 12),
              pw.Center(
                child: pw.Text(
                  'This is an official Accounts Payable Voucher generated by Shapla Mart Enterprise ERP.',
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

  static pw.TableRow _buildPdfTableRow(String label, String value, {PdfColor? valueColor}) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: pw.Text(
            value,
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: valueColor ?? PdfColors.black,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildPdfMetaRow(String label, String value, {bool isBold = false, PdfColor? valColor}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: valColor ?? PdfColors.black,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildPdfStatBox(String title, String val, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        decoration: pw.BoxDecoration(
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          border: pw.Border.all(color: PdfColors.grey300),
        ),
        child: pw.Column(
          children: [
            pw.Text(val, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: color)),
            pw.SizedBox(height: 2),
            pw.Text(title, style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
          ],
        ),
      ),
    );
  }

  static Future<void> printBill(SupplierBillModel bill) async {
    final pdfBytes = await generateBillPdf(bill: bill);
    await Printing.layoutPdf(
      name: 'Bill_${bill.billNumber}.pdf',
      onLayout: (format) async => pdfBytes,
    );
  }

  static Future<void> printBillRegister({
    required List<SupplierBillModel> bills,
    String title = 'Accounts Payable (AP) & Supplier Bills Register',
  }) async {
    final pdf = pw.Document();

    final totalInvoiced = bills.fold<double>(0.0, (sum, b) => sum + (double.tryParse(b.totalAmount) ?? 0.0));
    final totalPaid = bills.fold<double>(0.0, (sum, b) => sum + (double.tryParse(b.paidAmount) ?? 0.0));
    final totalOutstanding = totalInvoiced - totalPaid;
    final unpaidCount = bills.where((b) => b.paymentStatus.toUpperCase() == 'UNPAID').length;
    final partialCount = bills.where((b) => b.paymentStatus.toUpperCase() == 'PARTIAL').length;
    final paidCount = bills.where((b) => b.paymentStatus.toUpperCase() == 'PAID').length;

    const itemsPerPage = 14;
    final totalPages = (bills.length / itemsPerPage).ceil().clamp(1, 999);

    final dateFormat = DateFormat('yyyy-MM-dd');

    for (int pageIdx = 0; pageIdx < totalPages; pageIdx++) {
      final startIndex = pageIdx * itemsPerPage;
      final pageBills = bills.skip(startIndex).take(itemsPerPage).toList();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(24),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          title,
                          style: const pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.indigo900,
                          ),
                        ),
                        pw.Text(
                          'Shapla Mart Enterprise - Accounts Payable Ledger | Generated: ${dateFormat.format(DateTime.now())}',
                          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                    pw.Text(
                      'Page ${pageIdx + 1} of $totalPages',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                    ),
                  ],
                ),

                pw.SizedBox(height: 8),

                // Top KPI Summary row (on first page)
                if (pageIdx == 0) ...[
                  pw.Row(
                    children: [
                      _buildPdfStatBox('Total Bills', '${bills.length}', PdfColors.indigo900),
                      pw.SizedBox(width: 6),
                      _buildPdfStatBox('Unpaid Bills', '$unpaidCount', PdfColors.red800),
                      pw.SizedBox(width: 6),
                      _buildPdfStatBox('Partial Bills', '$partialCount', PdfColors.amber800),
                      pw.SizedBox(width: 6),
                      _buildPdfStatBox('Paid Bills', '$paidCount', PdfColors.green800),
                      pw.SizedBox(width: 6),
                      _buildPdfStatBox('Total Invoiced', 'SAR ${totalInvoiced.toStringAsFixed(2)}', PdfColors.indigo900),
                      pw.SizedBox(width: 6),
                      _buildPdfStatBox('Total Paid', 'SAR ${totalPaid.toStringAsFixed(2)}', PdfColors.green800),
                      pw.SizedBox(width: 6),
                      _buildPdfStatBox('AP Balance Due', 'SAR ${totalOutstanding.toStringAsFixed(2)}', PdfColors.red800),
                    ],
                  ),
                  pw.SizedBox(height: 10),
                ],

                // Table Header
                pw.Container(
                  color: PdfColors.indigo900,
                  padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                  child: pw.Row(
                    children: [
                      pw.SizedBox(width: 22, child: pw.Text('#', style: const pw.TextStyle(fontSize: 8, color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 3, child: pw.Text('Bill #', style: const pw.TextStyle(fontSize: 8, color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 4, child: pw.Text('Supplier Name', style: const pw.TextStyle(fontSize: 8, color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 2, child: pw.Text('Issue Date', style: const pw.TextStyle(fontSize: 8, color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 2, child: pw.Text('Due Date', style: const pw.TextStyle(fontSize: 8, color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 2, child: pw.Text('PO / GRN', style: const pw.TextStyle(fontSize: 8, color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 2, child: pw.Text('Subtotal (SAR)', textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 8, color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 2, child: pw.Text('VAT (SAR)', textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 8, color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 2, child: pw.Text('Total (SAR)', textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 8, color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 2, child: pw.Text('Paid (SAR)', textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 8, color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 2, child: pw.Text('Balance (SAR)', textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 8, color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 2, child: pw.Text('Status', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 8, color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                ),

                // Table Rows
                ...pageBills.asMap().entries.map((entry) {
                  final idx = startIndex + entry.key + 1;
                  final bill = entry.value;
                  final isEven = entry.key % 2 == 0;

                  final tot = double.tryParse(bill.totalAmount) ?? 0.0;
                  final pd = double.tryParse(bill.paidAmount) ?? 0.0;
                  final sub = double.tryParse(bill.subtotalAmount) ?? 0.0;
                  final vat = double.tryParse(bill.vatAmount) ?? 0.0;
                  final bal = tot - pd;

                  PdfColor statusColor;
                  switch (bill.paymentStatus.toUpperCase()) {
                    case 'PAID':
                      statusColor = PdfColors.green800;
                      break;
                    case 'PARTIAL':
                      statusColor = PdfColors.amber800;
                      break;
                    case 'UNPAID':
                    default:
                      statusColor = PdfColors.red800;
                  }

                  final ref = (bill.poId != null && bill.poId!.isNotEmpty)
                      ? 'PO: ${ProcurementDocumentFormatter.formatPoNumber(bill.poId, bill.poId)}'
                      : ((bill.grnId != null && bill.grnId!.isNotEmpty) ? 'GRN: ${ProcurementDocumentFormatter.formatGrnNumber(bill.grnId, bill.grnId)}' : '-');

                  return pw.Container(
                    color: isEven ? PdfColors.grey100 : PdfColors.white,
                    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5)),
                    ),
                    child: pw.Row(
                      children: [
                        pw.SizedBox(width: 22, child: pw.Text('$idx', style: const pw.TextStyle(fontSize: 7))),
                        pw.Expanded(
                          flex: 3,
                          child: pw.Text(bill.billNumber, style: const pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Expanded(
                          flex: 4,
                          child: pw.Text(bill.supplierName, style: const pw.TextStyle(fontSize: 7)),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(dateFormat.format(bill.issueDate), style: const pw.TextStyle(fontSize: 7)),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(bill.dueDate != null ? dateFormat.format(bill.dueDate!) : '-', style: const pw.TextStyle(fontSize: 7)),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(ref, style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(sub.toStringAsFixed(2), textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 7)),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(vat.toStringAsFixed(2), textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 7)),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(tot.toStringAsFixed(2), textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(pd.toStringAsFixed(2), textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 7, color: PdfColors.green800)),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            bal.toStringAsFixed(2),
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(
                              fontSize: 7,
                              fontWeight: pw.FontWeight.bold,
                              color: bal > 0 ? PdfColors.red800 : PdfColors.green800,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            bill.paymentStatus.toUpperCase(),
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: statusColor),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                pw.Spacer(),

                // Footer Grand Totals
                if (pageIdx == totalPages - 1) ...[
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.indigo50,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                      border: pw.Border.all(color: PdfColors.indigo200),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('GRAND TOTALS (${bills.length} BILLS):', style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
                        pw.Row(
                          children: [
                            pw.Text('Total Invoiced: SAR ${totalInvoiced.toStringAsFixed(2)}  |  ', style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                            pw.Text('Total Paid: SAR ${totalPaid.toStringAsFixed(2)}  |  ', style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                            pw.Text('Outstanding Balance Due: SAR ${totalOutstanding.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 6),
                ],

                pw.Center(
                  child: pw.Text(
                    'Shapla Mart Enterprise ERP - Confidential Accounts Payable Audit Document',
                    style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey500),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    final pdfBytes = await pdf.save();
    await Printing.layoutPdf(
      name: 'AP_Bills_Register_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
      onLayout: (format) async => pdfBytes,
    );
  }
}
