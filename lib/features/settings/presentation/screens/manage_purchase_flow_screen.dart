import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';

class ManagePurchaseFlowScreen extends ConsumerStatefulWidget {
  const ManagePurchaseFlowScreen({super.key});

  @override
  ConsumerState<ManagePurchaseFlowScreen> createState() => _ManagePurchaseFlowScreenState();
}

class _ManagePurchaseFlowScreenState extends ConsumerState<ManagePurchaseFlowScreen> {
  String _selectedBusinessType = 'Retail Business';
  String _selectedFlow = 'NORMAL';
  bool _isSaving = false;
  bool _isInitialized = false;

  final List<Map<String, String>> _businessTypes = const [
    {'name': 'Retail Business', 'defaultFlow': 'NORMAL', 'desc': 'Supermarkets, clothing stores, electronics, retail outlets'},
    {'name': 'Food & Beverage (F&B) Business', 'defaultFlow': 'NORMAL', 'desc': 'Restaurants, cafes, bakeries, grocery suppliers'},
    {'name': 'Services Business', 'defaultFlow': 'SIMPLE', 'desc': 'Consulting, IT agencies, legal, accounting services'},
    {'name': 'Professional/Office-based SMEs Business', 'defaultFlow': 'SIMPLE', 'desc': 'Corporate offices, agencies, consultancy firms'},
    {'name': 'Healthcare & Wellness Business', 'defaultFlow': 'NORMAL', 'desc': 'Clinics, pharmacies, diagnostic labs'},
    {'name': 'Trade & Light Manufacturing Business', 'defaultFlow': 'COMPLEX', 'desc': 'Factories, assembly plants, wholesale trade'},
    {'name': 'E-commerce/Warehouse-linked Business', 'defaultFlow': 'COMPLEX', 'desc': 'Online stores, multi-warehouse fulfillment centers'},
  ];

  final Map<String, List<String>> _flowFeatures = const {
    'SIMPLE': [
      '1. Create Purchase Invoice (Quick Entry)',
      '2. Make Payment to Supplier (AP Cash/Bank)',
    ],
    'NORMAL': [
      '1. Create Purchase Invoice & Stock Update',
      '2. Return to Supplier (Debit Notes)',
      '3. Make Payment to Supplier',
      '4. Manage Inventory Adjustment (Manager Approved)',
    ],
    'COMPLEX': [
      '1. Supplier Quotations Input',
      '2. Comparative Statement (CS) Matrix Generator',
      '3. Purchase Orders (PO) with Approval Workflow',
      '4. Goods Received Notes (GRN) & Receiving',
      '5. Quality Check (QC) (Accept / Partial Return / Full Return / Exchange)',
      '6. Received Bills Processing',
      '7. Accounts Payable Make Payment',
      '8. Multi-Location Inventory Transfers (Warehouse ↔ Branch)',
      '9. Inventory Adjustments (Manager Approval)',
    ]
  };

  void _onBusinessTypeChanged(String? newType) {
    if (newType == null) return;
    final matched = _businessTypes.firstWhere(
      (b) => b['name'] == newType,
      orElse: () => _businessTypes.first,
    );
    setState(() {
      _selectedBusinessType = newType;
      _selectedFlow = matched['defaultFlow'] ?? 'NORMAL';
    });
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    try {
      final api = ref.read(settingsApiProvider);
      await api.updatePurchaseFlowSettings({
        'businessType': _selectedBusinessType,
        'purchaseFlowType': _selectedFlow,
      });

      ref.invalidate(purchaseFlowSettingsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase Flow Settings updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving settings: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(purchaseFlowSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Purchase Flow & Business Type'),
      ),
      body: settingsAsync.when(
        data: (data) {
          if (!_isInitialized) {
            _selectedBusinessType = data['businessType'] as String? ?? 'Retail Business';
            _selectedFlow = data['purchaseFlowType'] as String? ?? 'NORMAL';
            _isInitialized = true;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Business Type Selection Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.storefront_outlined, color: Colors.blue, size: 28),
                            SizedBox(width: 12),
                            Text(
                              'Tenant Business Type Selection',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Select your primary business operational mode to auto-tune your inventory & procurement workflows.',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedBusinessType,
                          decoration: const InputDecoration(
                            labelText: 'Business Type',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.business_outlined),
                          ),
                          items: _businessTypes.map((b) {
                            return DropdownMenuItem<String>(
                              value: b['name'],
                              child: Text(b['name']!),
                            );
                          }).toList(),
                          onChanged: _onBusinessTypeChanged,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Flow Selector Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.alt_route_outlined, color: Colors.indigo, size: 28),
                            SizedBox(width: 12),
                            Text(
                              'Purchase Flow Mode Configuration',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Choose the complexity level of your purchasing & inventory workflow.',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 20),

                        // Radio options for flows
                        _buildFlowOption(
                          key: 'SIMPLE',
                          title: 'a. Simple Flow',
                          subtitle: 'Ideal for Services & Office SMEs (Invoice → Direct Payment)',
                          color: Colors.green,
                        ),
                        const SizedBox(height: 12),
                        _buildFlowOption(
                          key: 'NORMAL',
                          title: 'b. Normal Flow',
                          subtitle: 'Ideal for Retail, F&B & Clinics (Invoice → Return → Payment → Stock Adjustment)',
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 12),
                        _buildFlowOption(
                          key: 'COMPLEX',
                          title: 'c. Complex Flow',
                          subtitle: 'Full Enterprise 9-Step Procurement (Quotation → CS → PO → GRN → QC → Bills → AP → Transfers → Adjustments)',
                          color: Colors.purple,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Enabled Steps Preview Card
                Card(
                  elevation: 1,
                  color: Colors.blue.withValues(alpha: 0.05),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.blueAccent)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active Modules & Steps for $_selectedFlow Flow',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
                        ),
                        const SizedBox(height: 12),
                        ...(_flowFeatures[_selectedFlow] ?? []).map((step) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                              const SizedBox(width: 8),
                              Expanded(child: Text(step, style: const TextStyle(fontSize: 14))),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Save Action Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save_outlined),
                    label: Text(_isSaving ? 'Saving Settings...' : 'Save Purchase Flow Configuration', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading settings: $err')),
      ),
    );
  }

  Widget _buildFlowOption({
    required String key,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final isSelected = _selectedFlow == key;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: isSelected ? 2 : 1),
        color: isSelected ? color.withValues(alpha: 0.05) : Colors.transparent,
      ),
      child: RadioListTile<String>(
        value: key,
        groupValue: _selectedFlow,
        activeColor: color,
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? color : Colors.black)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        onChanged: (val) {
          if (val != null) setState(() => _selectedFlow = val);
        },
      ),
    );
  }
}
