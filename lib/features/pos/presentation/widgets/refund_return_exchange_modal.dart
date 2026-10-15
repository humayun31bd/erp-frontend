import 'package:flutter/material.dart';

class RefundReturnExchangeModal extends StatefulWidget {
  const RefundReturnExchangeModal({super.key});

  @override
  State<RefundReturnExchangeModal> createState() => _RefundReturnExchangeModalState();
}

class _RefundReturnExchangeModalState extends State<RefundReturnExchangeModal> {
  String _actionType = 'Refund';
  final _invoiceCtrl = TextEditingController();
  bool _invoiceFound = false;

  final _reasonCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  
  // Dummy data for invoice items
  final List<Map<String, dynamic>> _dummyItems = [
    {'name': 'Coca Cola', 'price': 2.50, 'qty': 2, 'selected': false},
    {'name': 'Lays Chips', 'price': 5.00, 'qty': 1, 'selected': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Returns / Refunds / Exchanges', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            
            // Type Selector
            Row(
              children: ['Refund', 'Return', 'Exchange'].map((type) => Expanded(
                child: RadioListTile<String>(
                  title: Text(type),
                  value: type,
                  groupValue: _actionType,
                  onChanged: (val) {
                    setState(() {
                      _actionType = val!;
                    });
                  },
                ),
              )).toList(),
            ),
            const Divider(),

            // Search Invoice
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _invoiceCtrl,
                    decoration: const InputDecoration(labelText: 'Invoice Number', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text('Find Invoice'),
                  onPressed: () {
                    if (_invoiceCtrl.text.isNotEmpty) {
                      setState(() {
                        _invoiceFound = true;
                      });
                    }
                  },
                )
              ],
            ),

            if (_invoiceFound) ...[
              const SizedBox(height: 16),
              const Text('Select Items:', style: TextStyle(fontWeight: FontWeight.bold)),
              ..._dummyItems.map((item) => CheckboxListTile(
                title: Text('${item['name']} - SAR ${item['price']} (Qty: ${item['qty']})'),
                value: item['selected'],
                onChanged: (val) {
                  setState(() {
                    item['selected'] = val;
                  });
                },
              )),

              const SizedBox(height: 16),
              TextField(
                controller: _reasonCtrl,
                decoration: InputDecoration(labelText: '$_actionType Reason', border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesCtrl,
                decoration: const InputDecoration(labelText: 'Notes / Description', border: OutlineInputBorder()),
                maxLines: 2,
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Validate selected items
                  final selected = _dummyItems.where((i) => i['selected']).toList();
                  if (selected.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one item.')));
                    return;
                  }
                  if (_reasonCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a reason for $_actionType.')));
                    return;
                  }

                  // Process success
                  Navigator.pop(context);
                  showDialog(
                    context: context, 
                    builder: (_) => AlertDialog(
                      title: const Text('Success'),
                      content: Text('$_actionType processed successfully.\nReference: REF-${DateTime.now().millisecondsSinceEpoch}'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
                      ],
                    )
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('Process $_actionType', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              )
            ]
          ],
        ),
      ),
    );
  }
}
