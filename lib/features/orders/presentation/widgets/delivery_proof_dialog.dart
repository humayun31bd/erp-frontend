import 'package:flutter/material.dart';
import '../../domain/delivery_order_model.dart';

class DeliveryProofDialog extends StatefulWidget {
  final DeliveryOrderModel order;

  const DeliveryProofDialog({super.key, required this.order});

  @override
  State<DeliveryProofDialog> createState() => _DeliveryProofDialogState();
}

class _DeliveryProofDialogState extends State<DeliveryProofDialog> {
  String _recipientType = 'Customer in Person (العميل شخصياً)';
  final TextEditingController _recipientNameController = TextEditingController();
  final TextEditingController _proofNoteController = TextEditingController();
  bool _cashCollected = true;
  late DateTime _podTime;

  final List<String> _recipientTypes = [
    'Customer in Person (العميل شخصياً)',
    'Family Member (أحد أفراد العائلة)',
    'Building Guard / Reception (الحارس / الاستقبال)',
    'Left at Doorstep per instructions (عند الباب حسب الطلب)',
    'Platform Confirmation (تأكيد منصة التوصيل)',
  ];

  @override
  void initState() {
    super.initState();
    _podTime = DateTime.now();
    if (widget.order.buyerName != null) {
      _recipientNameController.text = widget.order.buyerName!;
    }
  }

  @override
  void dispose() {
    _recipientNameController.dispose();
    _proofNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = '${_podTime.hour.toString().padLeft(2, '0')}:${_podTime.minute.toString().padLeft(2, '0')} - ${_podTime.day}/${_podTime.month}/${_podTime.year}';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.verified_rounded, color: Color(0xFF059669), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Confirm Delivery - ${widget.order.orderNumber}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'إثبات وتوثيق تسليم الطلب للعميل مع الختم الزمني',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
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
              // Timestamp banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF059669).withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF059669)),
                    const SizedBox(width: 8),
                    Text(
                      'Proof Timestamp: $timeStr',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF065F46)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Recipient category
              const Text('Handed Over To / مستلم الطلب *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _recipientType,
                isExpanded: true,
                decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                items: _recipientTypes.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12)))).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _recipientType = v);
                },
              ),
              const SizedBox(height: 12),

              // Recipient Name
              TextField(
                controller: _recipientNameController,
                decoration: const InputDecoration(
                  labelText: 'Recipient Name / اسم المستلم',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Proof note
              TextField(
                controller: _proofNoteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Proof Details / ملاحظات التوصيل والتسليم',
                  hintText: 'e.g. Signature received on invoice, delivery code verified',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Driver acknowledgement
              if (widget.order.driverName != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.delivery_dining, size: 18, color: Colors.purple),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Delivered by driver: ${widget.order.driverName} (${widget.order.driverPhone ?? ""})',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // Cash collection checkbox
              CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                value: _cashCollected,
                activeColor: const Color(0xFF059669),
                title: Text(
                  'Order payment confirmed (${widget.order.totalAmount.toStringAsFixed(2)} SAR)',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'تم استلام أو تأكيد المبلغ بالكامل من العميل أو المنصة',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                onChanged: (v) => setState(() => _cashCollected = v ?? true),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF059669),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            final proofSummary = 'Delivered to: ${_recipientNameController.text.trim().isNotEmpty ? _recipientNameController.text.trim() : _recipientType}. '
                'Proof: $_recipientType. '
                '${_proofNoteController.text.trim().isNotEmpty ? "Note: ${_proofNoteController.text.trim()}. " : ""}'
                'At: $timeStr';

            Navigator.pop(context, {
              'status': 'Dlvd',
              'podNotes': proofSummary,
              'cashCollected': _cashCollected,
              'timestamp': _podTime.toIso8601String(),
            });
          },
          child: const Text('Confirm Proof of Delivery', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
