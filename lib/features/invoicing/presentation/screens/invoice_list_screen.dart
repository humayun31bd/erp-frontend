import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../widgets/invoice_card.dart';

class InvoiceListScreen extends StatelessWidget {
  const InvoiceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'الفواتير' : 'Invoices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24.0),
        itemCount: 10,
        itemBuilder: (context, index) {
          return InvoiceCard(
            invoiceNumber: 'INV-2023-${1000 + index}',
            clientName: 'Numou Client $index',
            amount: 150.00 + (index * 50),
            status: index % 3 == 0 ? 'CLEARED' : (index % 2 == 0 ? 'REPORTED' : 'DRAFT'),
            onTap: () {
              context.goNamed(
                RouteNames.invoiceDetail,
                pathParameters: {'id': 'INV-2023-${1000 + index}'},
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.goNamed(RouteNames.createInvoice);
        },
        icon: const Icon(Icons.add),
        label: Text(isArabic ? 'إنشاء فاتورة' : 'Create Invoice'),
      ),
    );
  }
}
