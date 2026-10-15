import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../settings/providers/settings_provider.dart';

class ReceiptCustomizationModal extends ConsumerStatefulWidget {
  const ReceiptCustomizationModal({super.key});

  @override
  ConsumerState<ReceiptCustomizationModal> createState() => _ReceiptCustomizationModalState();
}

class _ReceiptCustomizationModalState extends ConsumerState<ReceiptCustomizationModal> {
  // Mock State for toggles
  final Map<String, bool> _settings = {
    'Invoice Logo': true,
    'Tenant Information': true,
    'Invoice Number': true,
    'Customer Information': true,
    'Customer Loyalty Points': false,
    'Invoice Items': true,
    'Invoice Total Amount': true,
    'Invoice Tax Amount': true,
    'Invoice Discount Amount': true,
    'Invoice Total Amount in Words': false,
    'Payment Method': true,
    'Payment Amount': true,
    'Payment Change': true,
    'Payment Date': true,
    'Payment Time': true,
    'Payment Status': false,
    'Payment Transaction ID': false,
    'Payment Reference Number': false,
    'Payment Description': false,
    'Payment Notes': false,
    'Refund Policy': true,
    'Return Policy': true,
    'Exchange Policy': true,
  };

  String _selectedTemplate = 'Template 1 (Standard ZATCA)';
  final List<String> _templates = ['Template 1 (Standard ZATCA)', 'Template 2 (Minimalist)', 'Template 3 (Thermal 80mm)', 'Template 4 (Thermal 58mm)'];

  String _selectedCurrency = 'SAR';
  final List<String> _currencies = ['SAR', 'USD', 'EUR', 'AED'];

  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'Arabic', 'Dual (Arabic & English)'];

  final TextEditingController _returnPolicyController = TextEditingController(text: 'Exchange within 14 days with original receipt.\nالاستبدال خلال 14 يوماً بالفاتورة الأصلية.');

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchSettings());
  }

  @override
  void dispose() {
    _returnPolicyController.dispose();
    super.dispose();
  }

  Future<void> _fetchSettings() async {
    try {
      final data = await ref.read(receiptSettingsProvider.future);
      if (data['receiptSettings'] != null && (data['receiptSettings'] as Map).isNotEmpty) {
        final rs = data['receiptSettings'] as Map;
        setState(() {
          _selectedTemplate = rs['template'] ?? _selectedTemplate;
          _selectedCurrency = rs['currency'] ?? _selectedCurrency;
          _selectedLanguage = rs['language'] ?? _selectedLanguage;
          
          if (rs['returnPolicyText'] != null) {
            _returnPolicyController.text = rs['returnPolicyText'];
          }
          
          final toggles = rs['toggles'] as Map<String, dynamic>?;
          if (toggles != null) {
            for (var key in _settings.keys) {
              if (toggles.containsKey(key)) {
                _settings[key] = toggles[key] == true;
              }
            }
          }
        });
      }
    } catch (e) {
      // Use defaults
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 800,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Receipt Print Customization', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const Divider(),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Side - General Settings & Template
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('General Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 16),
                          const Text('Receipt Template'),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedTemplate,
                            items: _templates.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                            onChanged: (v) => setState(() => _selectedTemplate = v!),
                            decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                          ),
                          const SizedBox(height: 16),
                          const Text('Default Currency'),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCurrency,
                            items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                            onChanged: (v) => setState(() => _selectedCurrency = v!),
                            decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                          ),
                          const SizedBox(height: 16),
                          const Text('Default Language'),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedLanguage,
                            items: _languages.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                            onChanged: (v) => setState(() => _selectedLanguage = v!),
                            decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                          ),
                          const SizedBox(height: 16),
                          const Text('Custom Return Policy Text', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _returnPolicyController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'e.g. Exchange within 14 days with original receipt.',
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text('Live Preview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          Container(
                            height: 250,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              border: Border.all(color: Colors.grey[400]!),
                            ),
                            child: const Center(
                              child: Text('Receipt Preview\n(HTML/Widget Renderer)', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Right Side - Toggles
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Visibility Toggles (Show/Hide)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListView(
                              children: _settings.keys.map((key) {
                                return SwitchListTile(
                                  title: Text(key, style: const TextStyle(fontSize: 14)),
                                  value: _settings[key]!,
                                  onChanged: (val) {
                                    setState(() {
                                      _settings[key] = val;
                                    });
                                  },
                                  dense: true,
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final api = ref.read(settingsApiProvider);
                      await api.updateReceiptSettings({
                        'receiptSettings': {
                          'template': _selectedTemplate,
                          'currency': _selectedCurrency,
                          'language': _selectedLanguage,
                          'returnPolicyText': _returnPolicyController.text,
                          'toggles': _settings,
                        }
                      });
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Receipt Settings Saved Successfully.')));
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save settings: $e'), backgroundColor: Colors.red));
                      }
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save Settings'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
