import 'package:flutter/material.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, dynamic>> _items = [
    {'name': '', 'quantity': 1, 'price': 0.0}
  ];

  void _addItem() {
    setState(() {
      _items.add({'name': '', 'quantity': 1, 'price': 0.0});
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  double get _subtotal {
    return _items.fold(0, (sum, item) => sum + ((item['quantity'] as int) * (item['price'] as double)));
  }

  double get _vat {
    return _subtotal * 0.15; // 15% VAT for KSA
  }

  double get _total => _subtotal + _vat;

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'إنشاء فاتورة جديدة' : 'Create New Invoice'),
        leading: const BackButton(),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            // Client Selection Placeholder
            TextFormField(
              decoration: InputDecoration(
                labelText: isArabic ? 'العميل' : 'Client',
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(Icons.arrow_drop_down),
              ),
            ),
            const SizedBox(height: 24),
            
            Text(
              isArabic ? 'عناصر الفاتورة' : 'Line Items',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            ..._items.asMap().entries.map((entry) {
              int idx = entry.key;
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          initialValue: entry.value['name'],
                          decoration: InputDecoration(labelText: isArabic ? 'الوصف' : 'Description'),
                          onChanged: (val) => _items[idx]['name'] = val,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          initialValue: entry.value['quantity'].toString(),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: isArabic ? 'الكمية' : 'Qty'),
                          onChanged: (val) => setState(() => _items[idx]['quantity'] = int.tryParse(val) ?? 0),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          initialValue: entry.value['price'].toString(),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: isArabic ? 'السعر' : 'Price'),
                          onChanged: (val) => setState(() => _items[idx]['price'] = double.tryParse(val) ?? 0.0),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeItem(idx),
                      ),
                    ],
                  ),
                ),
              );
            }),
            
            TextButton.icon(
              onPressed: _addItem,
              icon: const Icon(Icons.add),
              label: Text(isArabic ? 'إضافة عنصر' : 'Add Item'),
            ),
            
            const Divider(height: 48),
            
            // Totals
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Subtotal: SAR ${_subtotal.toStringAsFixed(2)}'),
                    const SizedBox(height: 8),
                    Text('VAT (15%): SAR ${_vat.toStringAsFixed(2)}'),
                    const SizedBox(height: 8),
                    Text(
                      'Total: SAR ${_total.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: () {
                // Submit to API
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(isArabic ? 'حفظ وإصدار' : 'Save & Issue Invoice'),
            ),
          ],
        ),
      ),
    );
  }
}
