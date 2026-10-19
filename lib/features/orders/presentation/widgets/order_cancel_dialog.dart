import 'package:flutter/material.dart';

class OrderCancelDialog extends StatefulWidget {
  final String orderNumber;

  const OrderCancelDialog({super.key, required this.orderNumber});

  @override
  State<OrderCancelDialog> createState() => _OrderCancelDialogState();
}

class _OrderCancelDialogState extends State<OrderCancelDialog> {
  String _selectedReason = 'Kitchen out of stock';
  String _cancelledBy = 'server';
  final TextEditingController _customReasonController = TextEditingController();

  final List<String> _reasons = [
    'Kitchen out of stock (المطبخ: نفاد الكمية)',
    'Customer cancelled before prep (إلغاء من العميل قبل التحضير)',
    'Customer unreachable / wrong address (العميل لا يجيب / عنوان خاطئ)',
    'Station closed (المحطة مغلقة)',
    'Duplicate order (طلب مكرر)',
    'Manager void (إلغاء إداري)',
    'Other reason (سبب آخر)',
  ];

  @override
  void dispose() {
    _customReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCustom = _selectedReason.startsWith('Other');

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.cancel_outlined, color: Colors.red, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Cancel Order ${widget.orderNumber}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please select the cancellation reason code. An audit trail will be logged.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),
              const Text(
                'Reason Code / سبب الإلغاء *',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedReason,
                    items: _reasons.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedReason = v);
                    },
                  ),
                ),
              ),
              if (isCustom) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _customReasonController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Specify Reason Details',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const Text(
                'Cancelled By / تم الإلغاء بواسطة',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'server', label: Text('Kitchen / Staff')),
                  ButtonSegment(value: 'customer', label: Text('Customer')),
                  ButtonSegment(value: 'admin', label: Text('Admin / Manager')),
                ],
                selected: {_cancelledBy},
                onSelectionChanged: (set) {
                  setState(() => _cancelledBy = set.first);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Dismiss'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            final reasonText = isCustom && _customReasonController.text.trim().isNotEmpty
                ? _customReasonController.text.trim()
                : _selectedReason;
            Navigator.pop(context, {
              'reason': reasonText,
              'cancelledBy': _cancelledBy,
            });
          },
          child: const Text('Confirm Cancellation'),
        ),
      ],
    );
  }
}
