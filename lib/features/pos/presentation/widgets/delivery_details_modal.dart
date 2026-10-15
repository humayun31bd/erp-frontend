import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/pos_provider.dart';
import '../../../../core/providers/tenant_settings_provider.dart';
import 'plan_guard_modal.dart';

class DeliveryDetailsModal extends ConsumerStatefulWidget {
  final PosDeliveryType deliveryType;

  const DeliveryDetailsModal({
    super.key,
    required this.deliveryType,
  });

  @override
  ConsumerState<DeliveryDetailsModal> createState() => _DeliveryDetailsModalState();
}

class _DeliveryDetailsModalState extends ConsumerState<DeliveryDetailsModal> {
  late TextEditingController _tableController;
  late TextEditingController _waiterController;
  late TextEditingController _addressController;
  late TextEditingController _feeController;
  late TextEditingController _aggregatorRefController;
  late TextEditingController _noteController;
  String? _selectedAggregator;

  static const List<String> _commonTables = [
    'Table 1', 'Table 2', 'Table 3', 'Table 4', 'Table 5', 'Table 6', 'VIP 1', 'VIP 2', 'Family 1'
  ];

  static const List<String> _commonWaiters = [
    'Ahmed', 'Karim', 'Faisal', 'Tariq', 'Sara', 'No Waiter'
  ];

  static const List<String> _aggregators = [
    'Self Delivery',
    'Jahez (جاهز)',
    'HungerStation (هنقرستيشن)',
    'Marsool (مرسول)',
    'ToYou (تويو)',
    'Ninja (نينجا)',
    'Careem (كريم)',
  ];

  @override
  void initState() {
    super.initState();
    final current = ref.read(posDeliveryDetailsProvider);
    _tableController = TextEditingController(text: current.tableNumber ?? '');
    _waiterController = TextEditingController(text: current.waiterName ?? '');
    _addressController = TextEditingController(text: current.deliveryAddress ?? '');
    _feeController = TextEditingController(text: current.deliveryFee > 0 ? current.deliveryFee.toStringAsFixed(2) : '');
    _aggregatorRefController = TextEditingController(text: current.aggregatorReference ?? '');
    _noteController = TextEditingController(text: current.deliveryNote ?? '');
    _selectedAggregator = current.aggregator ?? 'Self Delivery';

    // If customer is selected and has phone, pre-fill address hint if blank
    final customer = ref.read(selectedCustomerProvider);
    if (_addressController.text.isEmpty && customer != null) {
      if (customer.address != null && customer.address!.isNotEmpty) {
        _addressController.text = customer.address!;
      }
    }
  }

  @override
  void dispose() {
    _tableController.dispose();
    _waiterController.dispose();
    _addressController.dispose();
    _feeController.dispose();
    _aggregatorRefController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    final fee = double.tryParse(_feeController.text.trim()) ?? 0.0;
    final aggregator = _selectedAggregator == 'Self Delivery' ? null : _selectedAggregator;
    final waiter = _waiterController.text.trim() == 'No Waiter' ? null : _waiterController.text.trim();

    final updated = PosDeliveryOrderDetails(
      tableNumber: _tableController.text.trim().isNotEmpty ? _tableController.text.trim() : null,
      waiterName: waiter != null && waiter.isNotEmpty ? waiter : null,
      deliveryAddress: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
      deliveryFee: fee,
      aggregator: aggregator,
      aggregatorReference: _aggregatorRefController.text.trim().isNotEmpty ? _aggregatorRefController.text.trim() : null,
      deliveryNote: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
    );

    ref.read(posDeliveryDetailsProvider.notifier).state = updated;
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    final isDineIn = widget.deliveryType == PosDeliveryType.dineIn;
    final title = isDineIn ? 'Dine In / Table Details (محلي)' : 'Delivery & Dispatch Details (توصيل)';
    final primaryColor = Theme.of(context).primaryColor;
    final tenantSettings = ref.watch(tenantSettingsProvider);
    final hasAggregatorPlan = tenantSettings.isFeatureEnabled('aggregatorIntegration');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 480,
        constraints: const BoxConstraints(maxHeight: 650),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade900,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(
                    isDineIn ? Icons.restaurant : Icons.delivery_dining,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Modal Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isDineIn) ...[
                      // DINE IN: Table Number selection
                      const Text(
                        'Select or Enter Table Number / رقم الطاولة',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _commonTables.map((tbl) {
                          final isSelected = _tableController.text == tbl;
                          return ChoiceChip(
                            label: Text(tbl),
                            selected: isSelected,
                            selectedColor: primaryColor,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                            onSelected: (val) {
                              setState(() {
                                _tableController.text = val ? tbl : '';
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _tableController,
                        decoration: InputDecoration(
                          labelText: 'Custom Table # / رقم الطاولة',
                          prefixIcon: const Icon(Icons.table_restaurant_outlined, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Assigned Waiter / النادل المسؤول',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _commonWaiters.map((wtr) {
                          final isSelected = _waiterController.text == wtr;
                          return ChoiceChip(
                            label: Text(wtr),
                            selected: isSelected,
                            selectedColor: primaryColor,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                            onSelected: (val) {
                              setState(() {
                                _waiterController.text = val ? (wtr == 'No Waiter' ? '' : wtr) : '';
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _waiterController,
                        decoration: InputDecoration(
                          labelText: 'Custom Waiter Name / اسم النادل',
                          prefixIcon: const Icon(Icons.person_pin_outlined, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                    ] else ...[
                      // DELIVERY: Aggregator & Address
                      const Text(
                        'Delivery Channel / جهة التوصيل',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _aggregators.map((agg) {
                          final isSelected = _selectedAggregator == agg;
                          final isThirdParty = agg != 'Self Delivery';
                          final isLocked = isThirdParty && !hasAggregatorPlan;

                          return ChoiceChip(
                            avatar: isLocked ? const Icon(Icons.lock, size: 13, color: Colors.amber) : null,
                            label: Text(isLocked ? '$agg 🔒' : agg),
                            selected: isSelected,
                            selectedColor: primaryColor,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : (isLocked ? Colors.grey.shade600 : Colors.black87),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                            onSelected: (val) {
                              if (isLocked) {
                                PlanGuardModal.show(
                                  context,
                                  featureKey: 'aggregatorIntegration',
                                  featureName: 'Third-Party Delivery Aggregators (Jahez, HungerStation, Talabat)',
                                  requiredPlan: 'Pro',
                                  customDescription: 'Direct synchronization with third-party delivery platforms requires the Pro or Enterprise SaaS tier.',
                                );
                                return;
                              }
                              setState(() {
                                _selectedAggregator = val ? agg : 'Self Delivery';
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // If third-party aggregator selected, show aggregator reference input
                      if (_selectedAggregator != null && _selectedAggregator != 'Self Delivery') ...[
                        TextField(
                          controller: _aggregatorRefController,
                          decoration: InputDecoration(
                            labelText: 'Aggregator Order Reference / رقم الطلب في التطبيق',
                            hintText: 'e.g. #JHZ-9821',
                            prefixIcon: const Icon(Icons.tag, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Delivery Address
                      TextField(
                        controller: _addressController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Customer Delivery Address / عنوان التوصيل',
                          hintText: 'Building, Street, District, City',
                          prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Delivery Fee
                      TextField(
                        controller: _feeController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Delivery Fee / رسوم التوصيل (${tenantSettings.currencyCode})',
                          hintText: '0.00',
                          prefixIcon: const Icon(Icons.attach_money, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),

                    // Kitchen / Special Note
                    TextField(
                      controller: _noteController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Kitchen / Delivery Note / ملاحظات التحضير',
                        hintText: 'e.g. Extra napkins, no spicy, call on arrival',
                        prefixIcon: const Icon(Icons.note_alt_outlined, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Modal Footer Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: () {
                      _tableController.clear();
                      _addressController.clear();
                      _feeController.clear();
                      _aggregatorRefController.clear();
                      _noteController.clear();
                      _selectedAggregator = 'Self Delivery';
                      _save();
                    },
                    child: const Text('Clear'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Apply / حفظ'),
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
