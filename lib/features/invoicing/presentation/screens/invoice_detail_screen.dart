import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final String invoiceId;

  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context) {
    // Fake base64 for demo purposes
    const String fakeZatcaQrBase64 = "AQVTYWZlYgIPMzEyMzQ1Njc4OTEyMzQzAxQyMDIzLTEwLTI2VDEwOjMwOjAwWgQFMTAwLjAwBQUxNS4wMA==";

    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice $invoiceId'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Numou ERP', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('TAX INVOICE / فاتورة ضريبية', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Invoice No: $invoiceId'),
                            const Text('Date: 2026-09-21'),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 48),
                    
                    // Body / Items Placeholder
                    const SizedBox(
                      height: 200,
                      child: Center(child: Text('Invoice line items rendering here...')),
                    ),

                    const Divider(height: 48),

                    // Footer with QR Code
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // ZATCA QR Code
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ZATCA QR Code', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            QrImageView(
                              data: fakeZatcaQrBase64,
                              version: QrVersions.auto,
                              size: 150.0,
                            ),
                          ],
                        ),
                        // Totals
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Subtotal: SAR 150.00'),
                            Text('VAT (15%): SAR 22.50'),
                            Text('Total Amount: SAR 172.50', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
      ),
    );
  }
}
