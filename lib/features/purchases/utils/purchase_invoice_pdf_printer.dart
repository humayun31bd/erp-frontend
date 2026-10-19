import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../domain/purchase_model.dart';
import 'procurement_document_formatter.dart';

class PurchaseInvoicePdfPrinter {
  static Future<Uint8List> generateInvoicePdf({
    required PurchaseModel purchase,
    String companyName = 'Shapla Mart Enterprise',
    String companyVat = '310000000000003',
    String companyAddress = 'Riyadh, Kingdom of Saudi Arabia',
  }) async {
    final pdf = pw.Document();

    final statusStr = purchase.paymentStatus.toUpperCase();
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

    final totalVal = double.tryParse(purchase.totalAmount) ?? 0.0;
    final subtotalVal = double.tryParse(purchase.subtotalAmount) ?? (totalVal / 1.15);
    final vatVal = double.tryParse(purchase.totalVatAmount) ?? (totalVal - subtotalVal);

    final dateFormat = DateFormat('yyyy-MM-dd');
    final issueDateStr = dateFormat.format(purchase.issueDate);
    final dueDateStr = purchase.dueDate != null ? dateFormat.format(purchase.dueDate!) : 'Upon Receipt';

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
                        'TAX PURCHASE INVOICE',
                        style: const pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.Text(
                        'فاتورة شراء ضريبية',
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

              pw.SizedBox(height: 14),
              pw.Divider(color: PdfColors.grey400, thickness: 1),
              pw.SizedBox(height: 10),

              // Metadata Boxes Row
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
                            'SUPPLIER / VENDOR DETAILS / بيانات المورد',
                            style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            purchase.supplierName ?? ProcurementDocumentFormatter.formatSupplierCode(purchase.supplierId),
                            style: const pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text('Supplier Code / كود المورد: ${ProcurementDocumentFormatter.formatSupplierCode(purchase.supplierId)}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
                          pw.Text('Tax Status: 15% Standard ZATCA Input Credit Eligible', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                        ],
                      ),
                    ),
                  ),

                  pw.SizedBox(width: 14),

                  // Invoice Info Box
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
                            'INVOICE & TAX DETAILS / تفاصيل الفاتورة',
                            style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                          ),
                          pw.SizedBox(height: 4),
                          _buildPdfMetaRow('Invoice # / رقم الفاتورة:', purchase.invoiceNumber, isBold: true),
                          pw.SizedBox(height: 2),
                          _buildPdfMetaRow('Issue Date / تاريخ الإصدار:', issueDateStr),
                          pw.SizedBox(height: 2),
                          _buildPdfMetaRow('Due Date / تاريخ الاستحقاق:', dueDateStr),
                          pw.SizedBox(height: 2),
                          _buildPdfMetaRow('Payment Status / الحالة:', statusStr, valColor: statusColor),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 14),

              // Line Items Table Header
              pw.Text(
                'PURCHASED ITEMS & GOODS BREAKDOWN / تفاصيل الأصناف',
                style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
              ),
              pw.SizedBox(height: 6),

              // Line Items Table
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300, width: 0.8),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Column(
                  children: [
                    // Table Header
                    pw.Container(
                      color: PdfColors.blue900,
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: pw.Row(
                        children: [
                          pw.SizedBox(width: 20, child: pw.Text('#', style: const pw.TextStyle(fontSize: 8, color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
                          pw.Expanded(flex: 4, child: pw.Text('Item Description / الوصف', style: const pw.TextStyle(fontSize: 8, color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
                          pw.Expanded(flex: 1, child: pw.Text('Qty', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 8, color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
                          pw.Expanded(flex: 2, child: pw.Text('Unit Price', textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 8, color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
                          pw.Expanded(flex: 1, child: pw.Text('VAT %', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 8, color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
                          pw.Expanded(flex: 2, child: pw.Text('Subtotal', textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 8, color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
                          pw.Expanded(flex: 2, child: pw.Text('VAT (SAR)', textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 8, color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
                          pw.Expanded(flex: 2, child: pw.Text('Total (SAR)', textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 8, color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
                        ],
                      ),
                    ),

                    // Items rows
                    if (purchase.lineItems.isEmpty)
                      pw.Container(
                        padding: const pw.EdgeInsets.all(12),
                        child: pw.Text(
                          'Single-line recorded purchase invoice summary.',
                          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                        ),
                      )
                    else
                      ...purchase.lineItems.asMap().entries.map((entry) {
                        final idx = entry.key + 1;
                        final item = entry.value;
                        final isEven = entry.key % 2 == 0;

                        return pw.Container(
                          color: isEven ? PdfColors.grey100 : PdfColors.white,
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5)),
                          ),
                          child: pw.Row(
                            children: [
                              pw.SizedBox(width: 20, child: pw.Text('$idx', style: const pw.TextStyle(fontSize: 8))),
                              pw.Expanded(flex: 4, child: pw.Text(item.description, style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
                              pw.Expanded(flex: 1, child: pw.Text('${item.quantity}', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 8))),
                              pw.Expanded(flex: 2, child: pw.Text('SAR ${item.unitPrice.toStringAsFixed(2)}', textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 8))),
                              pw.Expanded(flex: 1, child: pw.Text('${item.vatRate.toStringAsFixed(0)}%', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 8))),
                              pw.Expanded(flex: 2, child: pw.Text('SAR ${item.subtotalAmount.toStringAsFixed(2)}', textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 8))),
                              pw.Expanded(flex: 2, child: pw.Text('SAR ${item.vatAmount.toStringAsFixed(2)}', textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 8))),
                              pw.Expanded(flex: 2, child: pw.Text('SAR ${item.totalAmount.toStringAsFixed(2)}', textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),

              pw.SizedBox(height: 12),

              // Financial Summary & Totals
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Tax Compliance note
                  pw.Expanded(
                    flex: 5,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey100,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                        border: pw.Border.all(color: PdfColors.grey300),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'ZATCA TAX AUDIT NOTICE / إشعار الضريبة',
                            style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            'Input tax credit is recorded under VAT regulations of the Kingdom of Saudi Arabia. Retain invoice documentation for standard audit retention periods.',
                            style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700),
                          ),
                        ],
                      ),
                    ),
                  ),

                  pw.SizedBox(width: 16),

                  // Totals Box
                  pw.Expanded(
                    flex: 5,
                    child: pw.Table(
                      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.8),
                      columnWidths: {
                        0: const pw.FlexColumnWidth(6),
                        1: const pw.FlexColumnWidth(4),
                      },
                      children: [
                        _buildPdfSummaryRow('Subtotal (Excl. VAT) / الصافي:', 'SAR ${subtotalVal.toStringAsFixed(2)}'),
                        _buildPdfSummaryRow('Total 15% VAT / ضريبة 15%:', 'SAR ${vatVal.toStringAsFixed(2)}'),
                        pw.TableRow(
                          decoration: const pw.BoxDecoration(color: PdfColors.blue50),
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              child: pw.Text('Gross Payable Total / الإجمالي:', style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              child: pw.Text('SAR ${totalVal.toStringAsFixed(2)}', textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
                      pw.Text('Goods Received By', style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Warehouse Storekeeper', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(width: 140, height: 1, color: PdfColors.grey500),
                      pw.SizedBox(height: 4),
                      pw.Text('Verified By', style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Procurement Officer', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(width: 140, height: 1, color: PdfColors.grey500),
                      pw.SizedBox(height: 4),
                      pw.Text('Finance Approved', style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Accounts Payable / CFO', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'Generated from Shapla Mart Enterprise ERP - Compliant with ZATCA Invoicing Architecture.',
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

  static pw.TableRow _buildPdfSummaryRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: pw.Text(value, textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
        ),
      ],
    );
  }

  static pw.Widget _buildPdfMetaRow(String label, String value, {bool isBold = false, PdfColor? valColor}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 8.5,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: valColor ?? PdfColors.black,
          ),
        ),
      ],
    );
  }

  static Future<void> printPurchaseInvoice(PurchaseModel purchase) async {
    final pdfBytes = await generateInvoicePdf(purchase: purchase);
    await Printing.layoutPdf(
      name: 'Purchase_${purchase.invoiceNumber}.pdf',
      onLayout: (format) async => pdfBytes,
    );
  }

  static Future<void> printPurchasesRegister({
    required List<PurchaseModel> purchases,
    String title = 'Purchases & AP Invoices Audit Register',
  }) async {
    final pdf = pw.Document();

    final totalAmountSum = purchases.fold<double>(0.0, (sum, p) => sum + (double.tryParse(p.totalAmount) ?? 0.0));
    final totalVatSum = purchases.fold<double>(0.0, (sum, p) => sum + (double.tryParse(p.totalVatAmount) ?? 0.0));
    final subtotalSum = purchases.fold<double>(0.0, (sum, p) => sum + (double.tryParse(p.subtotalAmount) ?? 0.0));
    final paidCount = purchases.where((p) => p.paymentStatus.toUpperCase() == 'PAID').length;
    final unpaidCount = purchases.where((p) => p.paymentStatus.toUpperCase() != 'PAID').length;

    const itemsPerPage = 14;
    final totalPages = (purchases.length / itemsPerPage).ceil().clamp(1, 999);
    final dateFormat = DateFormat('yyyy-MM-dd');

    for (int pageIdx = 0; pageIdx < totalPages; pageIdx++) {
      final startIndex = pageIdx * itemsPerPage;
      final pageItems = purchases.skip(startIndex).take(itemsPerPage).toList();

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
                          style: const pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                        ),
                        pw.Text(
                          'Shapla Mart Enterprise - Purchases Registry | Generated: ${dateFormat.format(DateTime.now())}',
                          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                    pw.Text('Page ${pageIdx + 1} of $totalPages', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                  ],
                ),

                pw.SizedBox(height: 8),

                // Top KPI Summary row (on first page)
                if (pageIdx == 0) ...[
                  pw.Row(
                    children: [
                      _buildPdfStatBox('Total Purchases', '${purchases.length}', PdfColors.blue900),
                      pw.SizedBox(width: 6),
                      _buildPdfStatBox('Paid Invoices', '$paidCount', PdfColors.green800),
                      pw.SizedBox(width: 6),
                      _buildPdfStatBox('Unpaid Invoices', '$unpaidCount', PdfColors.red800),
                      pw.SizedBox(width: 6),
                      _buildPdfStatBox('Net Subtotal', 'SAR ${subtotalSum.toStringAsFixed(2)}', PdfColors.blue900),
                      pw.SizedBox(width: 6),
                      _buildPdfStatBox('Total Input VAT (15%)', 'SAR ${totalVatSum.toStringAsFixed(2)}', PdfColors.amber800),
                      pw.SizedBox(width: 6),
                      _buildPdfStatBox('Total Invoiced', 'SAR ${totalAmountSum.toStringAsFixed(2)}', PdfColors.blue900),
                    ],
                  ),
                  pw.SizedBox(height: 10),
                ],

                // Table Header
                pw.Container(
                  color: PdfColors.blue900,
                  padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                  child: pw.Row(
                    children: [
                      pw.SizedBox(width: 24, child: pw.Text('#', style: const pw.TextStyle(fontSize: 8, color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 3, child: pw.Text('Invoice #', style: const pw.TextStyle(fontSize: 8, color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 4, child: pw.Text('Supplier Name', style: const pw.TextStyle(fontSize: 8, color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 2, child: pw.Text('Issue Date', style: const pw.TextStyle(fontSize: 8, color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 2, child: pw.Text('Due Date', style: const pw.TextStyle(fontSize: 8, color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 1, child: pw.Text('Items', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 8, color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 2, child: pw.Text('Subtotal (SAR)', textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 8, color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 2, child: pw.Text('VAT (SAR)', textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 8, color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 2, child: pw.Text('Total (SAR)', textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 8, color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 2, child: pw.Text('Status', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 8, color: PdfColors.white, fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                ),

                // Table Rows
                ...pageItems.asMap().entries.map((entry) {
                  final idx = startIndex + entry.key + 1;
                  final p = entry.value;
                  final isEven = entry.key % 2 == 0;

                  final tot = double.tryParse(p.totalAmount) ?? 0.0;
                  final sub = double.tryParse(p.subtotalAmount) ?? 0.0;
                  final vat = double.tryParse(p.totalVatAmount) ?? 0.0;

                  PdfColor statusColor;
                  switch (p.paymentStatus.toUpperCase()) {
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

                  return pw.Container(
                    color: isEven ? PdfColors.grey100 : PdfColors.white,
                    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5)),
                    ),
                    child: pw.Row(
                      children: [
                        pw.SizedBox(width: 24, child: pw.Text('$idx', style: const pw.TextStyle(fontSize: 7))),
                        pw.Expanded(flex: 3, child: pw.Text(p.invoiceNumber, style: const pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold))),
                        pw.Expanded(flex: 4, child: pw.Text(p.supplierName ?? ProcurementDocumentFormatter.formatSupplierCode(p.supplierId), style: const pw.TextStyle(fontSize: 7))),
                        pw.Expanded(flex: 2, child: pw.Text(dateFormat.format(p.issueDate), style: const pw.TextStyle(fontSize: 7))),
                        pw.Expanded(flex: 2, child: pw.Text(p.dueDate != null ? dateFormat.format(p.dueDate!) : '-', style: const pw.TextStyle(fontSize: 7))),
                        pw.Expanded(flex: 1, child: pw.Text('${p.lineItems.length}', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 7))),
                        pw.Expanded(flex: 2, child: pw.Text(sub.toStringAsFixed(2), textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 7))),
                        pw.Expanded(flex: 2, child: pw.Text(vat.toStringAsFixed(2), textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 7))),
                        pw.Expanded(flex: 2, child: pw.Text(tot.toStringAsFixed(2), textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold))),
                        pw.Expanded(flex: 2, child: pw.Text(p.paymentStatus.toUpperCase(), textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: statusColor))),
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
                      color: PdfColors.blue50,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                      border: pw.Border.all(color: PdfColors.blue200),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('GRAND TOTALS (${purchases.length} INVOICES):', style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                        pw.Row(
                          children: [
                            pw.Text('Subtotal: SAR ${subtotalSum.toStringAsFixed(2)}  |  ', style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                            pw.Text('15% Input VAT: SAR ${totalVatSum.toStringAsFixed(2)}  |  ', style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.amber800)),
                            pw.Text('Total: SAR ${totalAmountSum.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 6),
                ],

                pw.Center(
                  child: pw.Text(
                    'Shapla Mart Enterprise ERP - ZATCA Tax Compliant Purchase Register',
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
      name: 'Purchases_Register_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
      onLayout: (format) async => pdfBytes,
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
}
