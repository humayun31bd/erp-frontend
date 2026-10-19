import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/driver_model.dart';
import '../../domain/delivery_order_model.dart';
import '../../providers/drivers_provider.dart';

class AssignDriverDialog extends ConsumerStatefulWidget {
  final DeliveryOrderModel order;

  const AssignDriverDialog({
    super.key,
    required this.order,
  });

  @override
  ConsumerState<AssignDriverDialog> createState() => _AssignDriverDialogState();
}

class _AssignDriverDialogState extends ConsumerState<AssignDriverDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Tab 1: Fleet Driver
  String? _selectedFleetDriverId;

  // Tab 2: Third-Party Rider
  String _selectedPlatform = 'Jahez';
  final TextEditingController _riderNameController = TextEditingController();
  final TextEditingController _riderPhoneController = TextEditingController();
  final TextEditingController _riderVehicleController = TextEditingController();
  final TextEditingController _aggregatorRefController = TextEditingController();
  final TextEditingController _trackingNoteController = TextEditingController();

  // Create new driver inline modal controllers
  final TextEditingController _newDriverNameController = TextEditingController();
  final TextEditingController _newDriverPhoneController = TextEditingController();
  final TextEditingController _newDriverPlateController = TextEditingController();
  String _newDriverVehicleType = 'bike';
  bool _isCreatingDriver = false;

  bool _autoDispatch = true;

  final List<String> _platforms = [
    'Jahez (جاهز)',
    'HungerStation (هنقرستيشن)',
    'Marsool (مرسول)',
    'ToYou (تويو)',
    'Ninja (نينجا)',
    'Careem (كريم)',
    'Barq (برق)',
    'Other / آخر',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // If order already has aggregator, pre-select Tab 2
    if (widget.order.channel == 'third_party' || widget.order.aggregator != null) {
      _tabController.index = 1;
      final existingAgg = widget.order.aggregator ?? '';
      for (var p in _platforms) {
        if (p.toLowerCase().contains(existingAgg.toLowerCase())) {
          _selectedPlatform = p;
          break;
        }
      }
    }

    _aggregatorRefController.text = widget.order.aggregatorReference ?? '';
    if (widget.order.driverName != null) {
      _riderNameController.text = widget.order.driverName!;
    }
    if (widget.order.driverPhone != null) {
      _riderPhoneController.text = widget.order.driverPhone!;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _riderNameController.dispose();
    _riderPhoneController.dispose();
    _riderVehicleController.dispose();
    _aggregatorRefController.dispose();
    _trackingNoteController.dispose();
    _newDriverNameController.dispose();
    _newDriverPhoneController.dispose();
    _newDriverPlateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final driversState = ref.watch(driversProvider);
    final drivers = driversState.drivers;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.all(16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      actionsPadding: const EdgeInsets.all(16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.delivery_dining_rounded, color: Color(0xFF8B5CF6), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assign Delivery Driver - ${widget.order.orderNumber}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'تعيين سائق التوصيل وتحديث حالة الطلب إلى (في الطريق OOW)',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tabs
            TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF8B5CF6),
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: const Color(0xFF8B5CF6),
              tabs: const [
                Tab(icon: Icon(Icons.badge_outlined, size: 18), text: 'Company Drivers (أسطولنا)'),
                Tab(icon: Icon(Icons.two_wheeler_outlined, size: 18), text: 'Third-Party Rider (مندوب خارجي)'),
              ],
            ),
            const SizedBox(height: 14),

            // Tab Views
            SizedBox(
              height: 290,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Company Drivers
                  _buildCompanyDriversTab(drivers, driversState.isLoading),

                  // Tab 2: Third Party Rider
                  _buildThirdPartyRiderTab(),
                ],
              ),
            ),

            const SizedBox(height: 10),
            // Auto dispatch checkbox
            CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              value: _autoDispatch,
              activeColor: const Color(0xFF8B5CF6),
              title: const Text(
                'Auto-Dispatch to "On the Way (OOW)" immediately',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'تحديث حالة الطلب تلقائياً إلى "في الطريق" وتوثيق وقت الخروج',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              onChanged: (v) => setState(() => _autoDispatch = v ?? true),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B5CF6),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: _handleSubmit,
          child: const Text('Confirm & Dispatch Driver', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildCompanyDriversTab(List<DriverModel> drivers, bool isLoading) {
    if (_isCreatingDriver) {
      return _buildNewDriverForm();
    }

    if (isLoading && drivers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Driver (${drivers.length} registered)',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            TextButton.icon(
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add New Driver', style: TextStyle(fontSize: 12)),
              onPressed: () => setState(() => _isCreatingDriver = true),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Expanded(
          child: drivers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_off_outlined, size: 36, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      const Text('No company drivers found', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => setState(() => _isCreatingDriver = true),
                        child: const Text('Add Driver to Fleet'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: drivers.length,
                  itemBuilder: (context, index) {
                    final d = drivers[index];
                    final isSelected = _selectedFleetDriverId == d.id;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF8B5CF6).withValues(alpha: 0.08) : Colors.grey.shade50,
                        border: Border.all(
                          color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey.shade200,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: RadioListTile<String>(
                        value: d.id,
                        groupValue: _selectedFleetDriverId,
                        activeColor: const Color(0xFF8B5CF6),
                        onChanged: (v) => setState(() => _selectedFleetDriverId = v),
                        title: Row(
                          children: [
                            Icon(d.vehicleIcon, size: 16, color: const Color(0xFF8B5CF6)),
                            const SizedBox(width: 8),
                            Text(d.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: d.isAvailable ? Colors.green.shade50 : Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                d.isAvailable ? 'Available' : 'Busy',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: d.isAvailable ? Colors.green.shade700 : Colors.orange.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          '${d.phone} ${d.vehiclePlate != null ? "• Plate: ${d.vehiclePlate}" : ""}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildNewDriverForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Add Driver to Fleet / تسجيل سائق جديد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => setState(() => _isCreatingDriver = false),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _newDriverNameController,
            decoration: const InputDecoration(labelText: 'Driver Full Name *', isDense: true, border: OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _newDriverPhoneController,
            decoration: const InputDecoration(labelText: 'Driver Mobile Phone *', isDense: true, border: OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newDriverPlateController,
                  decoration: const InputDecoration(labelText: 'Plate / لوحة المركبة', isDense: true, border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _newDriverVehicleType,
                  decoration: const InputDecoration(labelText: 'Vehicle Type', isDense: true, border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'bike', child: Text('Motorcycle')),
                    DropdownMenuItem(value: 'car', child: Text('Car')),
                    DropdownMenuItem(value: 'van', child: Text('Van')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _newDriverVehicleType = v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), foregroundColor: Colors.white),
            onPressed: () async {
              if (_newDriverNameController.text.trim().isEmpty || _newDriverPhoneController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name and phone are required')));
                return;
              }
              final created = await ref.read(driversProvider.notifier).createDriver(
                    name: _newDriverNameController.text.trim(),
                    phone: _newDriverPhoneController.text.trim(),
                    vehicleType: _newDriverVehicleType,
                    vehiclePlate: _newDriverPlateController.text.trim(),
                  );
              if (created != null) {
                setState(() {
                  _selectedFleetDriverId = created.id;
                  _isCreatingDriver = false;
                });
              }
            },
            child: const Text('Save Driver & Select'),
          ),
        ],
      ),
    );
  }

  Widget _buildThirdPartyRiderTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedPlatform,
                  decoration: const InputDecoration(labelText: 'Platform / المنصة', isDense: true, border: OutlineInputBorder()),
                  items: _platforms.map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 12)))).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedPlatform = v);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _aggregatorRefController,
                  decoration: const InputDecoration(
                    labelText: 'Platform Order Ref #',
                    hintText: 'e.g. JHZ-9821',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _riderNameController,
                  decoration: const InputDecoration(labelText: 'Rider Name *', hintText: 'e.g. Ahmad (Rider)', isDense: true, border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _riderPhoneController,
                  decoration: const InputDecoration(labelText: 'Rider Phone *', hintText: '05xxxxxxxx', isDense: true, border: OutlineInputBorder()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _riderVehicleController,
            decoration: const InputDecoration(labelText: 'Vehicle / Bike Plate Info', hintText: 'e.g. Honda 123-KSA', isDense: true, border: OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _trackingNoteController,
            decoration: const InputDecoration(
              labelText: 'Rider Tracking Note / ملاحظات الاستلام',
              hintText: 'e.g. Picked in thermal bag #2, verified badge',
              isDense: true,
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubmit() {
    if (_tabController.index == 0) {
      // Company Fleet
      if (_selectedFleetDriverId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a driver from the fleet')));
        return;
      }
      final driver = ref.read(driversProvider).drivers.firstWhere((d) => d.id == _selectedFleetDriverId);

      Navigator.pop(context, {
        'driverId': driver.id,
        'driverName': driver.name,
        'driverPhone': driver.phone,
        'vehicleInfo': driver.vehiclePlate != null ? '${driver.vehicleLabel} (${driver.vehiclePlate})' : driver.vehicleLabel,
        'autoDispatch': _autoDispatch,
      });
    } else {
      // Third-party rider
      if (_riderNameController.text.trim().isEmpty || _riderPhoneController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rider name and phone are required')));
        return;
      }

      Navigator.pop(context, {
        'driverId': null,
        'driverName': '${_riderNameController.text.trim()} ($_selectedPlatform)',
        'driverPhone': _riderPhoneController.text.trim(),
        'vehicleInfo': _riderVehicleController.text.trim().isNotEmpty ? _riderVehicleController.text.trim() : _selectedPlatform,
        'aggregatorReference': _aggregatorRefController.text.trim().isNotEmpty ? _aggregatorRefController.text.trim() : null,
        'riderTrackingNote': _trackingNoteController.text.trim().isNotEmpty ? _trackingNoteController.text.trim() : null,
        'autoDispatch': _autoDispatch,
      });
    }
  }
}
