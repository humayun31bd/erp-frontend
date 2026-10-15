import 'package:flutter/material.dart';
import '../../../../features/clients/domain/client_model.dart';
import 'payment_modal.dart';
import '../../providers/receipt_printer_service.dart';
import '../../providers/pos_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/settings/providers/hardware_provider.dart';
import '../../../../features/settings/providers/settings_provider.dart';
import '../../../../core/providers/tenant_settings_provider.dart';
import '../../../../features/settings/domain/tenant_preset_models.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../utils/compliance_qr_generator.dart';

class ReceiptViewModal extends ConsumerWidget {
  final List<CartItem> cart;
  final double cartTotal;
  final ClientModel? customer;
  final PaymentResult paymentResult;
  final PosDeliveryType deliveryType;
  final PosDeliveryOrderDetails? deliveryDetails;
  final String? orderNumber;

  const ReceiptViewModal({
    super.key,
    required this.cart,
    required this.cartTotal,
    this.customer,
    required this.paymentResult,
    this.deliveryType = PosDeliveryType.takeAway,
    this.deliveryDetails,
    this.orderNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenantSettings = ref.watch(tenantSettingsProvider);
    final double taxRate = tenantSettings.taxRate;
    final double vatDivisor = (taxRate > 0) ? (1.0 + (taxRate / 100.0)) : 1.0;
    final double subtotal = taxRate > 0 ? (cartTotal / vatDivisor) : cartTotal;
    final double vat = cartTotal - subtotal;
    final compliance = tenantSettings.country.compliance;

    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';
    final timeStr = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';

    final String storeName = tenantSettings.name.isNotEmpty ? tenantSettings.name : 'Intelligent POS Store';
    final String storeAddress = tenantSettings.address.isNotEmpty ? tenantSettings.address : 'Main Showroom';
    final String taxNumber = tenantSettings.vatNumber.isNotEmpty ? tenantSettings.vatNumber : '310123456700003';

    // Regional Compliance Title & Tax Label
    String invoiceTitle = 'SIMPLIFIED TAX INVOICE\nفاتورة ضريبية مبسطة';
    String taxLabel = 'VAT Number / الرقم الضريبي: $taxNumber';
    String scanLabel = 'Scan to verify / امسح للتحقق';
    String thankYouLabel = 'Thank you for your visit!\nشكراً لزيارتكم!';
    String returnPolicyLabel = 'Exchange within 14 days with original receipt.\nالاستبدال خلال 14 يوماً بالفاتورة الأصلية.';

    if (compliance == ComplianceEngine.nbrBangladesh) {
      invoiceTitle = 'TAX INVOICE (MUSHUK-6.3)\nকর চালানপত্র (মূসক-৬.৩)';
      taxLabel = 'BIN / বিআইএন: $taxNumber';
      scanLabel = 'Scan to verify NBR e-VAT / মূসক যাচাইয়ে স্ক্যান করুন';
      thankYouLabel = 'Thank you for shopping with us!\nআমাদের সাথে কেনাকাটা করার জন্য ধন্যবাদ!';
      returnPolicyLabel = 'Exchange within 7 days with original challan receipt.\nক্রয় রসিদসহ ৭ দিনের মধ্যে পণ্য পরিবর্তনযোগ্য।';
    } else if (compliance == ComplianceEngine.fta) {
      invoiceTitle = 'TAX INVOICE\nفاتورة ضريبية';
      taxLabel = 'TRN / الرقم الضريبي: $taxNumber';
    } else if (compliance == ComplianceEngine.gtaQatar || compliance == ComplianceEngine.mofKuwait) {
      invoiceTitle = 'COMMERCIAL CASH RECEIPT\nإيصال نقدي تجاري';
      taxLabel = 'Commercial Reg / السجل: $taxNumber';
    } else if (compliance == ComplianceEngine.ota || compliance == ComplianceEngine.nbrBahrain) {
      invoiceTitle = 'TAX INVOICE\nفاتورة ضريبية';
      taxLabel = 'VAT TRN / الرقم الضريبي: $taxNumber';
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 420,
        height: 720,
        color: Colors.grey[200], // receipt background
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.blueGrey[900],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(tenantSettings.country.flagEmoji, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        'Receipt Preview (${tenantSettings.country.compliance.title})',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Document Title
                      Center(
                        child: Text(
                          invoiceTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Store Info
                      Center(
                        child: Text(
                          storeName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          storeAddress,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          taxLabel,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Divider(color: Colors.black, thickness: 1),
                      const SizedBox(height: 8),

                      // Meta Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Date / التاريخ: $dateStr', style: const TextStyle(fontSize: 12)),
                          Text('Time / الوقت: $timeStr', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Invoice: ${orderNumber ?? "INV-2026-1001"}', style: const TextStyle(fontSize: 12)),
                          const Text('Cashier / الكاشير: Admin', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Order Type / نوع الطلب:', style: TextStyle(fontSize: 12)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(deliveryType.icon, size: 12, color: Colors.blue.shade800),
                                const SizedBox(width: 4),
                                Text(
                                  deliveryType.bilingualLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (deliveryType == PosDeliveryType.dineIn && deliveryDetails?.tableNumber != null) ...[
                        const SizedBox(height: 4),
                        Text('Table / الطاولة: ${deliveryDetails!.tableNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                      if (deliveryDetails?.aggregator != null) ...[
                        const SizedBox(height: 4),
                        Text('Aggregator / التطبيق: ${deliveryDetails!.aggregator}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                      if (deliveryDetails?.deliveryAddress != null) ...[
                        const SizedBox(height: 4),
                        Text('Address / العنوان: ${deliveryDetails!.deliveryAddress}', style: const TextStyle(fontSize: 12)),
                      ],
                      if (customer != null) ...[
                        const SizedBox(height: 4),
                        Text('Customer / العميل: ${customer!.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        if (customer!.phoneNumber != null) Text('Phone / الهاتف: ${customer!.phoneNumber}', style: const TextStyle(fontSize: 12)),
                      ],
                      const SizedBox(height: 8),
                      const Divider(color: Colors.black, thickness: 1),
                      const SizedBox(height: 8),

                      // Items Header
                      const Row(
                        children: [
                          Expanded(flex: 3, child: Text('Item / الصنف', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Expanded(flex: 1, child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Expanded(flex: 2, child: Text('Total', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Items List
                      ...cart.map((item) {
                        final itemTotal = item.effectivePrice * item.quantity;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: Text(item.product.name, style: const TextStyle(fontSize: 12))),
                              Expanded(flex: 1, child: Text('${item.quantity}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12))),
                              Expanded(flex: 2, child: Text(tenantSettings.formatCurrency(itemTotal), textAlign: TextAlign.right, style: const TextStyle(fontSize: 12))),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 8),
                      const Divider(color: Colors.black, thickness: 1),
                      const SizedBox(height: 8),

                      // Totals
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('Subtotal / الإجمالي الفرعي:', style: TextStyle(fontSize: 12)),
                        Text(tenantSettings.formatCurrency(subtotal), style: const TextStyle(fontSize: 12)),
                      ]),
                      const SizedBox(height: 4),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('${tenantSettings.taxType} (${taxRate.toStringAsFixed(0)}%):', style: const TextStyle(fontSize: 12)),
                        Text(tenantSettings.formatCurrency(vat), style: const TextStyle(fontSize: 12)),
                      ]),
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('GRAND TOTAL / الإجمالي الكلي:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(tenantSettings.formatCurrency(cartTotal), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF15803D))),
                      ]),

                      const SizedBox(height: 8),
                      const Divider(color: Colors.black, thickness: 1),
                      const SizedBox(height: 8),

                      // Payment Info
                      ...paymentResult.lines.map((line) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('Paid by / طريقة الدفع: ${line.method.name}', style: const TextStyle(fontSize: 12)),
                        Text(tenantSettings.formatCurrency(line.amountTendered), style: const TextStyle(fontSize: 12)),
                      ])),
                      if (paymentResult.change > 0)
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          const Text('Change / المتبقي:', style: TextStyle(fontSize: 12)),
                          Text(tenantSettings.formatCurrency(paymentResult.change), style: const TextStyle(fontSize: 12)),
                        ]),

                      const SizedBox(height: 20),

                      // Compliance Verification QR Code
                      Center(
                        child: Builder(
                          builder: (context) {
                            final qrData = ComplianceQrGenerator.generate(
                              compliance: compliance,
                              sellerName: storeName,
                              vatOrBinNumber: taxNumber,
                              invoiceNumber: orderNumber ?? 'INV-2026-1001',
                              timestamp: now.toIso8601String(),
                              invoiceTotal: cartTotal,
                              vatTotal: vat,
                              currencySymbol: tenantSettings.currencySymbol,
                            );
                            
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  scanLabel,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.black, width: 2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: QrImageView(
                                    data: qrData,
                                    version: QrVersions.auto,
                                    size: 135.0,
                                  ),
                                ),
                              ],
                            );
                          }
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          thankYouLabel,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Text(
                          returnPolicyLabel,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions Footer
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.soup_kitchen_outlined, size: 16),
                    label: const Text('KOT (مطبخ)'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                    onPressed: () async {
                      final defaultPrinter = await ref.read(defaultPrinterProvider.future);
                      ReceiptPrinterService.printKitchenOrderTicket(
                        cart: cart,
                        orderNumber: orderNumber,
                        deliveryType: deliveryType,
                        deliveryDetails: deliveryDetails,
                        customer: customer,
                        printer: defaultPrinter,
                      );
                    },
                  ),
                  if (deliveryType == PosDeliveryType.delivery) ...[
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.local_shipping_outlined, size: 16),
                      label: const Text('Dispatch (توصيل)'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      ),
                      onPressed: () async {
                        final defaultPrinter = await ref.read(defaultPrinterProvider.future);
                        ReceiptPrinterService.printDeliveryDispatchSlip(
                          cart: cart,
                          cartTotal: cartTotal,
                          orderNumber: orderNumber,
                          deliveryDetails: deliveryDetails,
                          customer: customer,
                          printer: defaultPrinter,
                        );
                      },
                    ),
                  ],
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.print, size: 18),
                      label: const Text('Print Receipt'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        final defaultPrinter = await ref.read(defaultPrinterProvider.future);
                        bool showLoyaltyPoints = false;
                        bool showReturnPolicy = true;
                        String? customReturnPolicyText;
                        try {
                          final data = await ref.read(receiptSettingsProvider.future);
                          if (data['receiptSettings'] != null && (data['receiptSettings'] as Map).isNotEmpty) {
                            final rs = data['receiptSettings'] as Map;
                            if (rs['returnPolicyText'] != null) {
                              customReturnPolicyText = rs['returnPolicyText'] as String;
                            }
                            final toggles = rs['toggles'] as Map<String, dynamic>?;
                            if (toggles != null) {
                              if (toggles['Customer Loyalty Points'] == true) {
                                showLoyaltyPoints = true;
                              }
                              if (toggles['Return Policy'] == false || toggles['Refund Policy'] == false) {
                                showReturnPolicy = false;
                              }
                            }
                          }
                        } catch (e) {
                          // Ignore error and stick to default
                        }
                        
                        ReceiptPrinterService.printReceipt(
                          cart: cart,
                          cartTotal: cartTotal,
                          customer: customer,
                          paymentResult: paymentResult,
                          deliveryType: deliveryType,
                          printer: defaultPrinter,
                          showLoyaltyPoints: showLoyaltyPoints,
                          showReturnPolicy: showReturnPolicy,
                          customReturnPolicyText: customReturnPolicyText,
                          tenantSettings: tenantSettings,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
