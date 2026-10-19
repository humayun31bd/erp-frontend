import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../providers/invoice_provider.dart';
import 'package:intl/intl.dart';
import '../../../whatsapp/providers/whatsapp_provider.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/network/dio_client.dart';
import '../../../payments/providers/payments_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/pdf_generator.dart';
import '../../domain/invoice_responses.dart';
import '../../../../app.dart';

class InvoiceDetailScreen extends ConsumerWidget {
  final String invoiceId;

  const InvoiceDetailScreen({super.key, required this.invoiceId});

  void _showPaymentDialog(BuildContext context, WidgetRef ref, InvoiceDetail invoice) {
    final isArabic = ref.read(localeProvider).languageCode == 'ar';
    if (invoice.zatcaStatus.toUpperCase() == 'CLEARED') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic ? 'الدفع معطل للفواتير المعتمدة ZATCA.' : 'Payment is disabled for Cleared invoices.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    final isAlreadyPaid = invoice.paymentStatus.toUpperCase() == 'PAID';
    String selectedMethod = 'CASH';
    final refController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final paymentLinkState = ref.watch(paymentLinkProvider);

          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  isAlreadyPaid ? Icons.check_circle : Icons.payment,
                  color: isAlreadyPaid ? Colors.green : Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(isAlreadyPaid
                    ? (isArabic ? 'حالة الدفع' : 'Payment Status')
                    : (isArabic ? 'معالجة الدفع' : 'Process Payment')),
              ],
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 480,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(isArabic ? 'رقم الفاتورة:' : 'Invoice Number:', style: TextStyle(color: Colors.grey.shade600)),
                              Text(invoice.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(isArabic ? 'الإجمالي:' : 'Total Amount:', style: TextStyle(color: Colors.grey.shade600)),
                              Text(isArabic ? '${invoice.totalAmount} ر.س' : 'SAR ${invoice.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(isArabic ? 'حالة الدفع:' : 'Status:', style: TextStyle(color: Colors.grey.shade600)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isAlreadyPaid ? Colors.green.shade50 : Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: isAlreadyPaid ? Colors.green.shade200 : Colors.orange.shade200),
                                ),
                                child: Text(
                                  isAlreadyPaid
                                      ? (isArabic ? 'مدفوعة' : 'PAID')
                                      : (isArabic ? 'غير مدفوعة' : 'UNPAID'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: isAlreadyPaid ? Colors.green.shade700 : Colors.orange.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (isAlreadyPaid) ...[
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            children: [
                              const Icon(Icons.check_circle_outline, color: Colors.green, size: 48),
                              const SizedBox(height: 8),
                              Text(
                                isArabic ? 'تم دفع هذه الفاتورة بالكامل.' : 'This invoice is already PAID in full.',
                                style: TextStyle(fontSize: 16, color: Colors.green.shade700, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      Text(isArabic ? 'الدفع الفوري المباشر:' : 'In-Store Payment (Instant):', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedMethod,
                        decoration: InputDecoration(
                          labelText: isArabic ? 'طريقة الدفع' : 'Payment Method',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        items: [
                          DropdownMenuItem(value: 'CASH', child: Text(isArabic ? 'نقدًا' : 'Cash')),
                          DropdownMenuItem(value: 'CARD', child: Text(isArabic ? 'بطاقة (مدى / فيزا / ماستر)' : 'Card (Mada / Visa / Master)')),
                          DropdownMenuItem(value: 'BANK', child: Text(isArabic ? 'تحويل بنكي' : 'Bank Transfer')),
                        ],
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedMethod = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: refController,
                        decoration: InputDecoration(
                          labelText: isArabic ? 'رقم المرجع / تفويض الدفع (اختياري)' : 'Reference / Authorization No. (Optional)',
                          hintText: isArabic ? 'مثال: رقم تفويض الشبكة، مرجع البنك' : 'e.g. POS Auth Code, Bank Ref',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton.icon(
                          icon: isSubmitting
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.check_circle_outline),
                          label: Text(isSubmitting
                              ? (isArabic ? 'جاري تسجيل الدفع...' : 'Recording Payment...')
                              : (isArabic ? 'تسجيل الدفع وتحديد كـ مدفوع' : 'Record Payment & Mark as PAID')),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  setDialogState(() => isSubmitting = true);
                                  try {
                                    final dio = ref.read(dioProvider);
                                    await dio.put(
                                      '/invoices/${invoice.id}',
                                      data: {
                                        'paymentStatus': 'PAID',
                                        'paymentMethod': selectedMethod,
                                        'referenceNumber': refController.text.trim().isNotEmpty ? refController.text.trim() : null,
                                      },
                                    );
                                    ref.invalidate(invoiceDetailProvider(invoice.id));
                                    ref.invalidate(invoiceListProvider);
                                    if (ctx.mounted) {
                                      Navigator.pop(ctx);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(isArabic
                                              ? 'تم تسجيل دفع ${invoice.totalAmount} ر.س ($selectedMethod) بنجاح!'
                                              : 'Payment of SAR ${invoice.totalAmount} ($selectedMethod) recorded successfully!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    setDialogState(() => isSubmitting = false);
                                    if (ctx.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(isArabic ? 'فشل تسجيل الدفع: $e' : 'Failed to record payment: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Online Payment Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(isArabic ? 'رابط الدفع الإلكتروني:' : 'Online Payment Link (Checkout):', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          if (paymentLinkState.isLoading)
                            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          else
                            TextButton.icon(
                              icon: const Icon(Icons.link, size: 16),
                              label: Text(paymentLinkState.paymentUrl == null
                                  ? (isArabic ? 'إنشاء رابط' : 'Generate Link')
                                  : (isArabic ? 'إعادة إنشاء' : 'Regenerate')),
                              onPressed: () {
                                ref.read(paymentLinkProvider.notifier).generateLink(invoice.id);
                              },
                            ),
                        ],
                      ),
                      if (paymentLinkState.paymentUrl != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.blue.shade100)),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  paymentLinkState.paymentUrl!,
                                  style: TextStyle(color: Colors.blue.shade900, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 18),
                                tooltip: isArabic ? 'نسخ الرابط' : 'Copy link',
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: paymentLinkState.paymentUrl!));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(isArabic ? 'تم نسخ رابط الدفع للحافظة!' : 'Payment link copied to clipboard!')),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.open_in_new, size: 18),
                                tooltip: isArabic ? 'فتح صفحة الدفع' : 'Open checkout',
                                onPressed: () async {
                                  final uri = Uri.parse(paymentLinkState.paymentUrl!);
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isArabic ? 'إغلاق' : 'Close')),
            ],
          );
        },
      ),
    );
  }

  void _showWhatsAppDialog(BuildContext context, WidgetRef ref, InvoiceDetail invoice) {
    final isArabic = ref.read(localeProvider).languageCode == 'ar';
    final phoneCtrl = TextEditingController(text: invoice.buyerPhone ?? '');
    bool isSendingApi = false;

    final defaultText = isArabic
        ? 'فاتورة ضريبية: ${invoice.invoiceNumber}\n'
          'العميل: ${invoice.buyerName}\n'
          'الإجمالي: ${invoice.totalAmount} ر.س\n'
          'التاريخ: ${DateFormat('yyyy-MM-dd').format(invoice.issueDatetime)}\n'
          'حالة ZATCA: ${invoice.zatcaStatus}\n\n'
          'شكراً لتعاملكم مع Intelligent ERP!'
        : 'Tax Invoice: ${invoice.invoiceNumber}\n'
          'Customer: ${invoice.buyerName}\n'
          'Total Amount: SAR ${invoice.totalAmount}\n'
          'Date: ${DateFormat('yyyy-MM-dd').format(invoice.issueDatetime)}\n'
          'ZATCA Status: ${invoice.zatcaStatus}\n\n'
          'Thank you for doing business with Intelligent ERP!';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.chat, color: Colors.green),
                const SizedBox(width: 8),
                Text(isArabic ? 'مشاركة عبر واتساب' : 'Share via WhatsApp'),
              ],
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 480,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: isArabic ? 'رقم واتساب العميل' : 'Customer WhatsApp Phone Number',
                        hintText: isArabic ? '+966 50 123 4567 أو 966501234567' : '+966 50 123 4567 or 966501234567',
                        prefixIcon: const Icon(Icons.phone),
                        border: const OutlineInputBorder(),
                        helperText: isArabic ? 'أدخل رقم الجوال مع رمز الدولة' : 'Enter mobile number with country code',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(isArabic ? 'معاينة الرسالة:' : 'Message Preview:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Text(
                        defaultText,
                        style: TextStyle(fontSize: 13, color: Colors.green.shade900),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Direct WhatsApp Web / App Launch Button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.open_in_new),
                        label: Text(isArabic ? 'فتح في واتساب ويب / التطبيق' : 'Open in WhatsApp Web / App'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          final cleanPhone = phoneCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
                          final waUrl = cleanPhone.isEmpty
                              ? 'https://wa.me/?text=${Uri.encodeComponent(defaultText)}'
                              : 'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(defaultText)}';

                          final uri = Uri.parse(waUrl);
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Cloud API Button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        icon: isSendingApi
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.send),
                        label: Text(isSendingApi
                            ? (isArabic ? 'جاري الإرسال...' : 'Dispatching...')
                            : (isArabic ? 'إرسال عبر WhatsApp Cloud API' : 'Send via WhatsApp Cloud API')),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green.shade800,
                          side: BorderSide(color: Colors.green.shade600),
                        ),
                        onPressed: isSendingApi
                            ? null
                            : () async {
                                final cleanPhone = phoneCtrl.text.replaceAll(RegExp(r'[^0-9+]'), '').trim();
                                if (cleanPhone.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(isArabic ? 'يرجى إدخال رقم هاتف صحيح.' : 'Please enter a valid phone number.')),
                                  );
                                  return;
                                }
                                setDialogState(() => isSendingApi = true);
                                await ref.read(whatsappSendProvider.notifier).sendInvoice(
                                      invoice.id,
                                      cleanPhone.startsWith('+') ? cleanPhone : '+$cleanPhone',
                                    );
                                if (ctx.mounted) Navigator.pop(ctx);
                              },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isArabic ? 'إغلاق' : 'Cancel')),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(invoiceDetailProvider(invoiceId));
    final l10n = AppLocalizations.of(context)!;
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    ref.listen<WhatsAppSendState>(whatsappSendProvider, (prev, next) {
      if (next.success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.invoiceSentWhatsApp), backgroundColor: Colors.green));
      } else if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.errorPrefix}: ${next.error}'), backgroundColor: Colors.red));
      }
    });

    ref.listen<PaymentLinkState>(paymentLinkProvider, (prev, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.errorPrefix}: ${next.error}'), backgroundColor: Colors.red));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'تفاصيل الفاتورة' : l10n.invoiceDetail),
        actions: [
          IconButton(
            icon: Icon(isArabic ? Icons.language : Icons.g_translate),
            tooltip: isArabic ? 'Switch to English' : 'التحويل للعربية',
            onPressed: () {
              ref.read(localeProvider.notifier).state =
                  isArabic ? const Locale('en') : const Locale('ar');
            },
          ),
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: isArabic ? 'طباعة' : 'Print',
            onPressed: () {
              detailState.whenData((invoice) {
                PdfGenerator.printInvoice(invoice);
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'credit' || value == 'debit') {
                final noteType = value == 'credit' ? '381' : '383';
                context.pushNamed(
                  'create_invoice',
                  extra: {'originalInvoiceId': invoiceId, 'noteType': noteType},
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'credit', child: Text(isArabic ? 'إصدار إشعار دائن (381)' : l10n.issueCreditNote)),
              PopupMenuItem(value: 'debit', child: Text(isArabic ? 'إصدار إشعار مدين (383)' : l10n.issueDebitNote)),
            ],
          ),
          const SizedBox(width: 8),
          detailState.maybeWhen(
            data: (invoice) {
              final isCleared = invoice.zatcaStatus.toUpperCase() == 'CLEARED';
              final isPaid = invoice.paymentStatus.toUpperCase() == 'PAID';
              final isPayDisabled = isCleared || isPaid;

              String label;
              IconData icon;
              Color bg;
              if (isCleared) {
                label = isArabic ? 'الدفع (معطل - معتمدة)' : 'Pay (Disabled - Cleared)';
                icon = Icons.lock_outline;
                bg = Colors.grey.shade500;
              } else if (isPaid) {
                label = isArabic ? 'مدفوعة' : 'Paid';
                icon = Icons.check_circle;
                bg = Colors.green.shade600;
              } else {
                label = isArabic ? 'ادفع الآن' : l10n.payNow;
                icon = Icons.payment;
                bg = Colors.blue.shade700;
              }

              return Tooltip(
                message: isCleared
                    ? (isArabic ? 'الدفع معطل للفواتير المعتمدة ZATCA' : 'Payment is disabled for Cleared invoices')
                    : (isPaid ? (isArabic ? 'الفاتورة مدفوعة بالفعل' : 'Invoice is already paid') : (isArabic ? 'معالجة الدفع' : 'Process payment')),
                child: ElevatedButton.icon(
                  icon: Icon(icon),
                  label: Text(label),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPayDisabled ? Colors.grey.shade400 : bg,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade400,
                    disabledForegroundColor: Colors.white,
                  ),
                  onPressed: isPayDisabled ? null : () => _showPaymentDialog(context, ref, invoice),
                ),
              );
            },
            orElse: () => ElevatedButton.icon(
              icon: const Icon(Icons.payment),
              label: Text(isArabic ? 'ادفع الآن' : l10n.payNow),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: null,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.share),
            label: Text(isArabic ? 'واتساب' : l10n.whatsappBtn),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              detailState.whenData((invoice) => _showWhatsAppDialog(context, ref, invoice));
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: detailState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('${l10n.errorPrefix}: $err')),
        data: (invoice) {
          final qrData = invoice.qrCodeBase64 ?? "AQVTYWZlYgIPMzEyMzQ1Njc4OTEyMzQzAxQyMDIzLTEwLTI2VDEwOjMwOjAwWgQFMTAwLjAwBQUxNS4wMA==";
          final isPaid = invoice.paymentStatus.toUpperCase() == 'PAID';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Intelligent ERP', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(isArabic ? 'فاتورة مبيعات ضريبية' : l10n.taxInvoiceTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(isArabic ? 'رقم الفاتورة: ${invoice.invoiceNumber}' : l10n.invoiceNo(invoice.invoiceNumber)),
                                Text(isArabic
                                    ? 'التاريخ: ${DateFormat('yyyy-MM-dd').format(invoice.issueDatetime)}'
                                    : l10n.dateText(DateFormat('yyyy-MM-dd').format(invoice.issueDatetime))),
                                Text(isArabic ? 'حالة ZATCA: ${invoice.zatcaStatus}' : l10n.statusText(invoice.zatcaStatus)),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isPaid ? Colors.green.shade50 : Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: isPaid ? Colors.green.shade300 : Colors.orange.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    isArabic
                                        ? 'حالة الدفع: ${isPaid ? "مدفوعة" : "غير مدفوعة"}'
                                        : 'PAYMENT: ${invoice.paymentStatus.toUpperCase()}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isPaid ? Colors.green.shade700 : Colors.orange.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Buyer Info
                        Text(isArabic ? 'مفلترة إلى (العميل):' : l10n.billedTo, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(invoice.buyerName),
                        if (invoice.buyerVat != null) Text(isArabic ? 'الرقم الضريبي: ${invoice.buyerVat}' : l10n.vatNo(invoice.buyerVat!)),
                        if (invoice.buyerPhone != null) Text(isArabic ? 'الهاتف: ${invoice.buyerPhone}' : 'Phone: ${invoice.buyerPhone!}'),
                        
                        const Divider(height: 48),
                        
                        // Line Items Table
                        DataTable(
                          columns: [
                            DataColumn(label: Text(isArabic ? 'الصنف / الوصف' : l10n.description)),
                            DataColumn(label: Text(isArabic ? 'الكمية' : l10n.qty), numeric: true),
                            DataColumn(label: Text(isArabic ? 'السعر' : l10n.price), numeric: true),
                            DataColumn(label: Text(isArabic ? 'الإجمالي' : l10n.total), numeric: true),
                          ],
                          rows: invoice.lineItems.map((item) {
                            return DataRow(
                              cells: [
                                DataCell(Text(item.description)),
                                DataCell(Text(item.quantity)),
                                DataCell(Text(item.unitPrice)),
                                DataCell(Text(item.lineTotal)),
                              ],
                            );
                          }).toList(),
                        ),

                        const Divider(height: 48),

                        // Footer with QR Code and Totals
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // ZATCA QR Code
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(isArabic ? 'رمز الاستجابة السريعة (ZATCA QR)' : l10n.zatcaQrCode, style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                QrImageView(
                                  data: qrData,
                                  version: QrVersions.auto,
                                  size: 150.0,
                                ),
                              ],
                            ),
                            // Totals
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(isArabic
                                    ? 'المجموع الفرعي: ${invoice.subtotalAmount} ر.س'
                                    : l10n.subtotalAmount(invoice.subtotalAmount.toString())),
                                Text(isArabic
                                    ? 'ضريبة القيمة المضافة 15%: ${invoice.totalVatAmount} ر.س'
                                    : l10n.vat15Amount(invoice.totalVatAmount.toString())),
                                Text(
                                  isArabic
                                      ? 'الإجمالي الشامل للضريبة: ${invoice.totalAmount} ر.س'
                                      : l10n.totalAmountSAR(invoice.totalAmount.toString()),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


