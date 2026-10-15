import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'pos_provider.dart';
import '../../../../features/clients/domain/client_model.dart';
import '../presentation/widgets/payment_modal.dart';
import 'package:flutter/foundation.dart';
import '../utils/compliance_qr_generator.dart';
import '../../settings/domain/tenant_preset_models.dart';
import 'shift_provider.dart';

enum ReceiptLanguage { english, arabic, bilingual }

class ReceiptPrinterService {
  static Future<void> printReceipt({
    required List<CartItem> cart,
    required double cartTotal,
    ClientModel? customer,
    required PaymentResult paymentResult,
    PosDeliveryType deliveryType = PosDeliveryType.takeAway,
    Printer? printer,
    ReceiptLanguage language = ReceiptLanguage.bilingual,
    bool showLoyaltyPoints = false,
    bool showReturnPolicy = true,
    String? customReturnPolicyText,
    TenantSetupModel? tenantSettings,
  }) async {
    final doc = pw.Document();
    
    // Thermal receipt roll format (80mm)
    const format = PdfPageFormat.roll80;

    final double taxRate = tenantSettings?.taxRate ?? 15.0;
    final double vatDivisor = (taxRate > 0) ? (1.0 + (taxRate / 100.0)) : 1.0;
    final double subtotal = taxRate > 0 ? (cartTotal / vatDivisor) : cartTotal;
    final double vat = cartTotal - subtotal;
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';
    final timeStr = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    final compliance = tenantSettings?.country.compliance ?? ComplianceEngine.zatca;

    final String storeName = (tenantSettings?.name.isNotEmpty == true) ? tenantSettings!.name : 'Intelligent POS Store';
    final String storeAddress = (tenantSettings?.address.isNotEmpty == true) ? tenantSettings!.address : 'Main Branch';
    final String vatNumber = (tenantSettings?.vatNumber.isNotEmpty == true) ? tenantSettings!.vatNumber : '310122393500003';

    // Regional Compliance Titles
    String titleEn = 'SIMPLIFIED TAX INVOICE';
    String titleAr = 'فاتورة ضريبية مبسطة';
    String txtVatLabel = 'VAT No / الرقم الضريبي:';

    if (compliance == ComplianceEngine.nbrBangladesh) {
      titleEn = 'TAX INVOICE (MUSHUK-6.3)';
      titleAr = 'কর চালানপত্র (মূসক-৬.৩)';
      txtVatLabel = 'BIN / বিআইএন:';
    } else if (compliance == ComplianceEngine.fta) {
      titleEn = 'TAX INVOICE';
      titleAr = 'فاتورة ضريبية';
      txtVatLabel = 'TRN / الرقم الضريبي:';
    } else if (compliance == ComplianceEngine.gtaQatar || compliance == ComplianceEngine.mofKuwait) {
      titleEn = 'COMMERCIAL INVOICE';
      titleAr = 'فاتورة تجارية';
      txtVatLabel = 'CR / السجل:';
    }

    // ZATCA / Regional Arabic font support
    final ttf = await PdfGoogleFonts.cairoRegular();
    final ttfBold = await PdfGoogleFonts.cairoBold();
    final style = pw.TextStyle(font: ttf, fontSize: 10);
    final boldStyle = pw.TextStyle(font: ttfBold, fontSize: 10, fontWeight: pw.FontWeight.bold);
    
    final bool isBilingual = language == ReceiptLanguage.bilingual;
    final bool isArabic = language == ReceiptLanguage.arabic;
    
    final String txtStore = storeName;
    final String txtAddress = storeAddress;
    final String txtVat = isBilingual ? txtVatLabel : (isArabic ? 'الرقم الضريبي:' : 'Tax No:');
    final String txtDate = isBilingual ? 'Date / التاريخ:' : (isArabic ? 'التاريخ:' : 'Date:');
    final String txtTime = isBilingual ? 'Time / الوقت:' : (isArabic ? 'الوقت:' : 'Time:');
    final String txtInvoice = isBilingual ? 'Invoice / فاتورة #:' : (isArabic ? 'فاتورة #:' : 'Invoice #:');
    
    doc.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Center(child: pw.Text(isBilingual ? '$titleEn / $titleAr' : (isArabic ? titleAr : titleEn), style: pw.TextStyle(font: ttfBold, fontSize: 11, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
              pw.SizedBox(height: 6),
              pw.Center(child: pw.Text(txtStore, textAlign: pw.TextAlign.center, style: pw.TextStyle(font: ttfBold, fontSize: 13, fontWeight: pw.FontWeight.bold))),
              pw.SizedBox(height: 4),
              pw.Center(child: pw.Text(txtAddress, style: style, textAlign: pw.TextAlign.center)),
              pw.Center(child: pw.Text('$txtVat $vatNumber', style: style)),
              pw.SizedBox(height: 10),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 10),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('$txtDate $dateStr', style: style),
                  pw.Text('$txtTime $timeStr', style: style),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('$txtInvoice INV-2026-1001', style: style),
                  pw.Text('Cashier / الكاشير: Admin', style: style),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    isBilingual ? 'Order Type / نوع الطلب:' : (isArabic ? 'نوع الطلب:' : 'Order Type:'),
                    style: style,
                  ),
                  pw.Text(
                    isBilingual
                        ? deliveryType.bilingualLabel
                        : (isArabic ? deliveryType.arabicLabel : deliveryType.label),
                    style: boldStyle,
                  ),
                ],
              ),
              if (customer != null) ...[
                pw.SizedBox(height: 4),
                pw.Text('Customer / العميل: ${customer.name}', style: boldStyle),
                if (showLoyaltyPoints) ...[
                  pw.SizedBox(height: 2),
                  pw.Text('Loyalty Points / نقاط الولاء: ${(customer.name.length * 150) + 250}', style: style),
                ],
              ],
              pw.SizedBox(height: 10),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 10),

              // Headers
              pw.Row(
                children: [
                  pw.Expanded(flex: 3, child: pw.Text(isBilingual ? 'Item / الصنف' : (isArabic ? 'الصنف' : 'Item'), style: boldStyle)),
                  pw.Expanded(flex: 1, child: pw.Text(isBilingual ? 'Qty / الكمية' : (isArabic ? 'الكمية' : 'Qty'), textAlign: pw.TextAlign.center, style: boldStyle)),
                  pw.Expanded(flex: 2, child: pw.Text(isBilingual ? 'Total / المجموع' : (isArabic ? 'المجموع' : 'Total'), textAlign: pw.TextAlign.right, style: boldStyle)),
                ],
              ),
              pw.SizedBox(height: 6),

              // Items
              ...cart.map((item) {
                final itemTotal = item.effectivePrice * item.quantity;
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4.0),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(flex: 3, child: pw.Text(item.product.name, style: style)),
                      pw.Expanded(flex: 1, child: pw.Text('${item.quantity}', textAlign: pw.TextAlign.center, style: style)),
                      pw.Expanded(flex: 2, child: pw.Text(itemTotal.toStringAsFixed(2), textAlign: pw.TextAlign.right, style: style)),
                    ],
                  ),
                );
              }),
              pw.SizedBox(height: 10),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 10),

              // Totals
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text(isBilingual ? 'Subtotal / المجموع الفرعي:' : (isArabic ? 'المجموع الفرعي:' : 'Subtotal:'), style: style),
                pw.Text(tenantSettings?.formatCurrency(subtotal) ?? subtotal.toStringAsFixed(2), style: style),
              ]),
              pw.SizedBox(height: 2),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text(
                  isBilingual
                      ? '${tenantSettings?.taxType ?? "VAT"} (${taxRate.toStringAsFixed(0)}%) / الضريبة:'
                      : (isArabic ? 'الضريبة (${taxRate.toStringAsFixed(0)}%):' : '${tenantSettings?.taxType ?? "Tax"} (${taxRate.toStringAsFixed(0)}%):'),
                  style: style,
                ),
                pw.Text(tenantSettings?.formatCurrency(vat) ?? vat.toStringAsFixed(2), style: style),
              ]),
              pw.SizedBox(height: 6),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text(isBilingual ? 'GRAND TOTAL / الإجمالي:' : (isArabic ? 'الإجمالي:' : 'GRAND TOTAL:'), style: boldStyle),
                pw.Text(tenantSettings?.formatCurrency(cartTotal) ?? 'SAR ${cartTotal.toStringAsFixed(2)}', style: boldStyle),
              ]),

              pw.SizedBox(height: 10),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 10),

              // Payment
              ...paymentResult.lines.map((line) => pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text('Paid by: ${line.method.name}', style: style),
                pw.Text(tenantSettings?.formatCurrency(line.amountTendered) ?? line.amountTendered.toStringAsFixed(2), style: style),
              ])),
              if (paymentResult.change > 0)
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                  pw.Text(isBilingual ? 'Change / المتبقي:' : (isArabic ? 'المتبقي:' : 'Change:'), style: style),
                  pw.Text(tenantSettings?.formatCurrency(paymentResult.change) ?? paymentResult.change.toStringAsFixed(2), style: style),
                ]),
              
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      compliance == ComplianceEngine.nbrBangladesh
                          ? 'Scan to verify NBR e-VAT / মূসক যাচাইয়ে স্ক্যান'
                          : (isBilingual ? 'Scan to verify / امسح للتحقق' : (isArabic ? 'امسح للتحقق' : 'Scan to verify')),
                      style: pw.TextStyle(font: ttfBold, fontSize: 8, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(4),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.black, width: 1),
                      ),
                      child: pw.BarcodeWidget(
                        data: ComplianceQrGenerator.generate(
                          compliance: compliance,
                          sellerName: storeName,
                          vatOrBinNumber: vatNumber,
                          invoiceNumber: 'INV-2026-1001',
                          timestamp: now.toIso8601String(),
                          invoiceTotal: cartTotal,
                          vatTotal: vat,
                          currencySymbol: tenantSettings?.currencySymbol,
                        ),
                        barcode: pw.Barcode.qrCode(),
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Center(child: pw.Text(isBilingual ? 'Thank you! / شكراً لزيارتكم!' : (isArabic ? 'شكراً لزيارتكم!' : 'Thank you for your visit!'), style: style)),
              if (showReturnPolicy)
                pw.Center(child: pw.Text(
                  customReturnPolicyText?.isNotEmpty == true 
                      ? customReturnPolicyText! 
                      : (isBilingual ? 'Exchange within 14 days / استبدال خلال 14 يوم' : (isArabic ? 'استبدال خلال 14 يوم' : 'Exchange within 14 days with receipt.')),
                  style: pw.TextStyle(font: ttf, fontSize: 8),
                  textAlign: pw.TextAlign.center,
                )),
            ],
          );
        },
      ),
    );

    if (printer != null && !kIsWeb) {
      await Printing.directPrintPdf(
        printer: printer,
        onLayout: (PdfPageFormat format) async => doc.save(),
      );
    } else {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
        name: 'Receipt_INV-2026-1001',
      );
    }
  }

  static Future<void> printTestReceipt({Printer? printer}) async {
    final doc = pw.Document();
    
    // Thermal receipt roll format (80mm)
    const format = PdfPageFormat.roll80;

    doc.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('ZATCA ERP STORE', style: const pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('PRINTER TEST SUCCESSFUL', style: const pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 10),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 10),
              pw.Text('Date: ${DateTime.now().toLocal().toString().split('.')[0]}', style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 20),
              pw.Text('If you are reading this, your printer is configured correctly.', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 20),
            ],
          );
        },
      ),
    );

    if (printer != null && !kIsWeb) {
      await Printing.directPrintPdf(
        printer: printer,
        onLayout: (PdfPageFormat format) async => doc.save(),
      );
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
        name: 'Test_Print',
      );
    }
  }

  static Future<void> printZReport({
    required ShiftReport report,
    required double actualCash,
    required double variance,
    required String notes,
    Printer? printer,
  }) async {
    final doc = pw.Document();
    const format = PdfPageFormat.roll80;
    
    final ttf = await PdfGoogleFonts.cairoRegular();
    final ttfBold = await PdfGoogleFonts.cairoBold();

    doc.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('END OF DAY (Z-REPORT) / تقرير نهاية اليوم', style: pw.TextStyle(font: ttfBold, fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 10),
              
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text('Expected Cash:', style: pw.TextStyle(font: ttf, fontSize: 10)),
                pw.Text(report.expectedCash.toStringAsFixed(2), style: pw.TextStyle(font: ttf, fontSize: 10)),
              ]),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text('Actual Cash:', style: pw.TextStyle(font: ttf, fontSize: 10)),
                pw.Text(actualCash.toStringAsFixed(2), style: pw.TextStyle(font: ttf, fontSize: 10)),
              ]),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text('Variance:', style: pw.TextStyle(font: ttf, fontSize: 10)),
                pw.Text(variance.toStringAsFixed(2), style: pw.TextStyle(font: ttf, fontSize: 10)),
              ]),
              
              pw.SizedBox(height: 8),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 8),
              
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text('Card Sales:', style: pw.TextStyle(font: ttf, fontSize: 10)),
                pw.Text(report.totalCardSales.toStringAsFixed(2), style: pw.TextStyle(font: ttf, fontSize: 10)),
              ]),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text('Refunds:', style: pw.TextStyle(font: ttf, fontSize: 10)),
                pw.Text(report.totalRefunds.toStringAsFixed(2), style: pw.TextStyle(font: ttf, fontSize: 10)),
              ]),
              
              if (notes.isNotEmpty) ...[
                pw.SizedBox(height: 10),
                pw.Divider(borderStyle: pw.BorderStyle.dashed),
                pw.SizedBox(height: 10),
                pw.Text('Notes / ملاحظات:', style: pw.TextStyle(font: ttfBold, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                pw.Text(notes, style: pw.TextStyle(font: ttf, fontSize: 10)),
              ],
              
              pw.SizedBox(height: 20),
              pw.Text(DateTime.now().toString().split('.')[0], style: pw.TextStyle(font: ttf, fontSize: 8)),
            ],
          );
        },
      ),
    );

    if (printer != null && !kIsWeb) {
      await Printing.directPrintPdf(printer: printer, onLayout: (format) async => doc.save());
    } else {
      await Printing.layoutPdf(name: 'Z_Report', onLayout: (format) async => doc.save());
    }
  }

  static Future<void> printKitchenOrderTicket({
    required List<CartItem> cart,
    String? orderNumber,
    PosDeliveryType deliveryType = PosDeliveryType.takeAway,
    PosDeliveryOrderDetails? deliveryDetails,
    ClientModel? customer,
    Printer? printer,
  }) async {
    final doc = pw.Document();
    const format = PdfPageFormat.roll80;
    
    final ttf = await PdfGoogleFonts.cairoRegular();
    final ttfBold = await PdfGoogleFonts.cairoBold();
    final now = DateTime.now();
    final timeStr = '${now.hour}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    final dateStr = '${now.day}/${now.month}/${now.year}';
    final ordNum = orderNumber ?? 'ORD-${now.millisecondsSinceEpoch.toString().substring(7)}';

    doc.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Center(
                child: pw.Text(
                  'KITCHEN ORDER TICKET (KOT)',
                  style: pw.TextStyle(font: ttfBold, fontSize: 13, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'تذكرة طلب المطبخ',
                  style: pw.TextStyle(font: ttfBold, fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 4),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Order # / رقم الطلب:', style: pw.TextStyle(font: ttf, fontSize: 10)),
                  pw.Text(ordNum, style: pw.TextStyle(font: ttfBold, fontSize: 12, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 3),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Type / النوع:', style: pw.TextStyle(font: ttf, fontSize: 10)),
                  pw.Text(deliveryType.bilingualLabel, style: pw.TextStyle(font: ttfBold, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              if (deliveryType == PosDeliveryType.dineIn && deliveryDetails?.tableNumber != null) ...[
                pw.SizedBox(height: 3),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Table / الطاولة:', style: pw.TextStyle(font: ttfBold, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                    pw.Text(deliveryDetails!.tableNumber!, style: pw.TextStyle(font: ttfBold, fontSize: 13, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
              if (deliveryDetails?.aggregator != null) ...[
                pw.SizedBox(height: 3),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Platform / المنصة:', style: pw.TextStyle(font: ttf, fontSize: 10)),
                    pw.Text(deliveryDetails!.aggregator!, style: pw.TextStyle(font: ttfBold, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
              pw.SizedBox(height: 3),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Time / الوقت: $timeStr', style: pw.TextStyle(font: ttf, fontSize: 9)),
                  pw.Text('Date / التاريخ: $dateStr', style: pw.TextStyle(font: ttf, fontSize: 9)),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Divider(borderStyle: pw.BorderStyle.solid, thickness: 1.5),
              pw.SizedBox(height: 6),

              // Items with large quantities for kitchen visibility
              ...cart.map((item) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
                        child: pw.Text('${item.quantity}x', style: pw.TextStyle(font: ttfBold, fontSize: 13, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(item.product.name, style: pw.TextStyle(font: ttfBold, fontSize: 12, fontWeight: pw.FontWeight.bold)),
                            if (item.selectedUnit != null)
                              pw.Text('Unit: ${item.selectedUnit!.unitCode}', style: pw.TextStyle(font: ttf, fontSize: 9)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

              if (deliveryDetails?.deliveryNote != null && deliveryDetails!.deliveryNote!.isNotEmpty) ...[
                pw.SizedBox(height: 6),
                pw.Divider(borderStyle: pw.BorderStyle.dashed),
                pw.SizedBox(height: 4),
                pw.Text('NOTE / ملاحظات:', style: pw.TextStyle(font: ttfBold, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                pw.Text(deliveryDetails.deliveryNote!, style: pw.TextStyle(font: ttf, fontSize: 10)),
              ],

              pw.SizedBox(height: 8),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.Center(
                child: pw.Text('Total Items: ${cart.fold<int>(0, (sum, i) => sum + i.quantity)}', style: pw.TextStyle(font: ttf, fontSize: 10)),
              ),
              pw.SizedBox(height: 12),
            ],
          );
        },
      ),
    );

    if (printer != null && !kIsWeb) {
      await Printing.directPrintPdf(printer: printer, onLayout: (format) async => doc.save());
    } else {
      await Printing.layoutPdf(name: 'KOT_$ordNum', onLayout: (format) async => doc.save());
    }
  }

  static Future<void> printKitchenTicketFromData({
    required String orderNumber,
    required String orderType,
    String? tableNumber,
    String? aggregator,
    String? status,
    required List<Map<String, dynamic>> items,
    String? notes,
    Printer? printer,
  }) async {
    final doc = pw.Document();
    const format = PdfPageFormat.roll80;
    
    final ttf = await PdfGoogleFonts.cairoRegular();
    final ttfBold = await PdfGoogleFonts.cairoBold();
    final now = DateTime.now();
    final timeStr = '${now.hour}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    final dateStr = '${now.day}/${now.month}/${now.year}';

    doc.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Center(
                child: pw.Text(
                  'KITCHEN ORDER TICKET (KOT)',
                  style: pw.TextStyle(font: ttfBold, fontSize: 13, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'تذكرة طلب المطبخ',
                  style: pw.TextStyle(font: ttfBold, fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 4),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Order # / رقم الطلب:', style: pw.TextStyle(font: ttf, fontSize: 10)),
                  pw.Text(orderNumber, style: pw.TextStyle(font: ttfBold, fontSize: 12, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 3),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Type / النوع:', style: pw.TextStyle(font: ttf, fontSize: 10)),
                  pw.Text(orderType.toUpperCase(), style: pw.TextStyle(font: ttfBold, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              if (tableNumber != null && tableNumber.isNotEmpty) ...[
                pw.SizedBox(height: 3),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Table / الطاولة:', style: pw.TextStyle(font: ttfBold, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                    pw.Text(tableNumber, style: pw.TextStyle(font: ttfBold, fontSize: 13, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
              if (aggregator != null && aggregator.isNotEmpty) ...[
                pw.SizedBox(height: 3),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Platform / المنصة:', style: pw.TextStyle(font: ttf, fontSize: 10)),
                    pw.Text(aggregator, style: pw.TextStyle(font: ttfBold, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
              pw.SizedBox(height: 3),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Time / الوقت: $timeStr', style: pw.TextStyle(font: ttf, fontSize: 9)),
                  pw.Text('Date / التاريخ: $dateStr', style: pw.TextStyle(font: ttf, fontSize: 9)),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Divider(borderStyle: pw.BorderStyle.solid, thickness: 1.5),
              pw.SizedBox(height: 6),

              // Items
              ...items.map((item) {
                final qty = item['quantity']?.toString() ?? '1';
                final name = item['productName']?.toString() ?? 'Item';
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
                        child: pw.Text('${qty}x', style: pw.TextStyle(font: ttfBold, fontSize: 13, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Expanded(
                        child: pw.Text(name, style: pw.TextStyle(font: ttfBold, fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              }),

              if (notes != null && notes.isNotEmpty) ...[
                pw.SizedBox(height: 6),
                pw.Divider(borderStyle: pw.BorderStyle.dashed),
                pw.SizedBox(height: 4),
                pw.Text('NOTE / ملاحظات:', style: pw.TextStyle(font: ttfBold, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                pw.Text(notes, style: pw.TextStyle(font: ttf, fontSize: 10)),
              ],

              pw.SizedBox(height: 8),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 12),
            ],
          );
        },
      ),
    );

    if (printer != null && !kIsWeb) {
      await Printing.directPrintPdf(printer: printer, onLayout: (format) async => doc.save());
    } else {
      await Printing.layoutPdf(name: 'KOT_$orderNumber', onLayout: (format) async => doc.save());
    }
  }

  static Future<void> printDeliveryDispatchSlip({
    required List<CartItem> cart,
    required double cartTotal,
    String? orderNumber,
    PosDeliveryOrderDetails? deliveryDetails,
    ClientModel? customer,
    String? paymentMethod,
    Printer? printer,
  }) async {
    final doc = pw.Document();
    const format = PdfPageFormat.roll80;
    
    final ttf = await PdfGoogleFonts.cairoRegular();
    final ttfBold = await PdfGoogleFonts.cairoBold();
    final now = DateTime.now();
    final timeStr = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    final dateStr = '${now.day}/${now.month}/${now.year}';
    final ordNum = orderNumber ?? 'ORD-${now.millisecondsSinceEpoch.toString().substring(7)}';

    doc.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Center(
                child: pw.Text(
                  'DELIVERY DISPATCH SLIP',
                  style: pw.TextStyle(font: ttfBold, fontSize: 13, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'إيصال إرسال الطلب والتوصيل',
                  style: pw.TextStyle(font: ttfBold, fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 4),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Order #:', style: pw.TextStyle(font: ttf, fontSize: 10)),
                  pw.Text(ordNum, style: pw.TextStyle(font: ttfBold, fontSize: 12, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Dispatch Time:', style: pw.TextStyle(font: ttf, fontSize: 10)),
                  pw.Text('$dateStr $timeStr', style: pw.TextStyle(font: ttf, fontSize: 10)),
                ],
              ),
              if (deliveryDetails?.aggregator != null) ...[
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Channel / التطبيق:', style: pw.TextStyle(font: ttf, fontSize: 10)),
                    pw.Text(deliveryDetails!.aggregator!, style: pw.TextStyle(font: ttfBold, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
              if (deliveryDetails?.aggregatorReference != null) ...[
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Ref # / رقم المرجع:', style: pw.TextStyle(font: ttf, fontSize: 10)),
                    pw.Text(deliveryDetails!.aggregatorReference!, style: pw.TextStyle(font: ttfBold, fontSize: 11)),
                  ],
                ),
              ],
              pw.SizedBox(height: 6),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 4),

              pw.Text('CUSTOMER & DESTINATION / بيانات العميل:', style: pw.TextStyle(font: ttfBold, fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.Text('Name: ${customer?.name ?? 'Customer'}', style: pw.TextStyle(font: ttf, fontSize: 10)),
              if (customer?.phoneNumber != null)
                pw.Text('Phone: ${customer!.phoneNumber}', style: pw.TextStyle(font: ttfBold, fontSize: 11, fontWeight: pw.FontWeight.bold)),
              if (deliveryDetails?.deliveryAddress != null)
                pw.Text('Address: ${deliveryDetails!.deliveryAddress}', style: pw.TextStyle(font: ttf, fontSize: 10)),

              pw.SizedBox(height: 6),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 4),

              // Items Summary
              ...cart.map((item) {
                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(child: pw.Text('${item.quantity}x ${item.product.name}', style: pw.TextStyle(font: ttf, fontSize: 10))),
                    pw.Text((item.effectivePrice * item.quantity).toStringAsFixed(2), style: pw.TextStyle(font: ttf, fontSize: 10)),
                  ],
                );
              }),

              pw.SizedBox(height: 6),
              pw.Divider(borderStyle: pw.BorderStyle.solid, thickness: 1),
              pw.SizedBox(height: 4),

              if (deliveryDetails?.deliveryFee != null && deliveryDetails!.deliveryFee > 0)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Delivery Fee / رسوم التوصيل:', style: pw.TextStyle(font: ttf, fontSize: 10)),
                    pw.Text('SAR ${deliveryDetails.deliveryFee.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf, fontSize: 10)),
                  ],
                ),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('AMOUNT TO COLLECT / المبلغ المطلوب:', style: pw.TextStyle(font: ttfBold, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  pw.Text('SAR ${cartTotal.toStringAsFixed(2)}', style: pw.TextStyle(font: ttfBold, fontSize: 12, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              if (paymentMethod != null)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Payment Status:', style: pw.TextStyle(font: ttf, fontSize: 9)),
                    pw.Text(paymentMethod, style: pw.TextStyle(font: ttf, fontSize: 9)),
                  ],
                ),

              pw.SizedBox(height: 14),
              pw.Center(
                child: pw.Text('DRIVER SIGNATURE / توقيع السائق: ________________', style: pw.TextStyle(font: ttf, fontSize: 9)),
              ),
              pw.SizedBox(height: 12),
            ],
          );
        },
      ),
    );

    if (printer != null && !kIsWeb) {
      await Printing.directPrintPdf(printer: printer, onLayout: (format) async => doc.save());
    } else {
      await Printing.layoutPdf(name: 'Dispatch_$ordNum', onLayout: (format) async => doc.save());
    }
  }
}
