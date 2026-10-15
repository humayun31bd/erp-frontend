import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';

class ProductPolicyScreen extends ConsumerStatefulWidget {
  const ProductPolicyScreen({super.key});

  @override
  ConsumerState<ProductPolicyScreen> createState() => _ProductPolicyScreenState();
}

class _ProductPolicyScreenState extends ConsumerState<ProductPolicyScreen> {
  String _selectedBusinessType = 'Retail';
  final List<String> _businessTypes = ['Retail', 'Electronics', 'Mobile Shop', 'Pharmacy', 'Apparel', 'Saloon / Beauty'];

  // Map to hold dynamic feature toggles based on business type
  Map<String, bool> _features = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchPolicy());
  }

  Future<void> _fetchPolicy() async {
    try {
      final policy = await ref.read(productPolicyProvider.future);
      setState(() {
        _selectedBusinessType = policy['businessType'] ?? 'Retail';
        // Only load default if the policy from backend is empty
        if (policy['productPolicy'] != null && (policy['productPolicy'] as Map).isNotEmpty) {
          _features = Map<String, bool>.from(policy['productPolicy']);
        } else {
          _loadFeaturesForBusinessType(_selectedBusinessType);
        }
      });
    } catch (e) {
      // Fallback
      _loadFeaturesForBusinessType(_selectedBusinessType);
    }
  }

  void _loadFeaturesForBusinessType(String type) {
    // Reset features based on the policy doc
    final Map<String, bool> defaultFeatures = {
      'Product Category': true,
      'Product Sub-Category': true,
      'Stock Policy (Track Inventory)': true,
      'Is Excizable': false,
      'Is Discountable': true,
      'Is Tax-Free': false,
      'Is Published (eCommerce)': true,
      'Number of Images (Default 0)': false,
      'Number of Videos (Default 0)': false,
    };

    if (type == 'Retail') {
      _features = {
        'Variants (Sizes, Colors, Weight)': true,
        ...defaultFeatures,
      };
    } else if (type == 'Electronics') {
      _features = {
        'Brand': true,
        'Model': true,
        'Serial Number': true,
        'Colors': true,
        'Warranty (1 / 2 / 3 Years)': true,
        ...defaultFeatures,
      };
    } else if (type == 'Mobile Shop') {
      _features = {
        'Brand': true,
        'Model': true,
        'Serial Number': true,
        'Storage Size': true,
        'Colors': true,
        'Warranty (1 / 2 / 3 Years)': true,
        'Stock Policy (Track Inventory)': true,
        'Is Excizable': false,
        'Is Discountable': true,
        'Is Published (eCommerce)': true,
        'Number of Images (Default 0)': false,
        'Number of Videos (Default 0)': false,
      };
    } else if (type == 'Pharmacy') {
      _features = {
        'Manufacturer / Brand': true,
        'Generic Name': true,
        'Expire Date': true,
        'Dosage Form': true,
        'Is Cold Chain': false,
        'Is Prescription Required': false,
        ...defaultFeatures,
      };
    } else if (type == 'Apparel') {
      _features = {
        'Size': true,
        'Color': true,
        'Material': true,
        'Weight': false,
        'Stock Policy (Track Inventory)': true,
        'Is Excizable': false,
        'Is Published (eCommerce)': true,
        'Number of Images (Default 0)': false,
        'Number of Videos (Default 0)': false,
      };
    } else if (type == 'Saloon / Beauty') {
      _features = {
        'Service Name': true,
        'Service Description': true,
        'Service Tax': true,
        'Is Published (eCommerce)': true,
        'Service Images': false,
      };
    }
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenant Product Policy Setup'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left sidebar for Business Type Selection
          Container(
            width: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(color: Colors.grey[300]!)),
            ),
            child: ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Select Business Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                ..._businessTypes.map((type) => ListTile(
                  title: Text(type),
                  selected: _selectedBusinessType == type,
                  selectedTileColor: Colors.blue[50],
                  selectedColor: Colors.blue[800],
                  onTap: () {
                    setState(() {
                      _selectedBusinessType = type;
                      _loadFeaturesForBusinessType(type);
                    });
                  },
                )),
              ],
            ),
          ),
          
          // Right content area for Feature Toggles
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$_selectedBusinessType Product Features', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Enable or disable data fields and attributes for your products based on your business type.', style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 24),
                  
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: _features.keys.map((feature) {
                          final isCategoryDisabled = feature == 'Product Sub-Category' && (_features['Product Category'] == false);

                          return SwitchListTile(
                            title: Text(feature, style: const TextStyle(fontWeight: FontWeight.w500)),
                            subtitle: isCategoryDisabled
                                ? const Text('Auto-disabled because Product Category is turned off', style: TextStyle(color: Colors.red, fontSize: 12))
                                : null,
                            value: isCategoryDisabled ? false : (_features[feature] ?? false),
                            onChanged: isCategoryDisabled
                                ? null
                                : (val) {
                                    setState(() {
                                      _features[feature] = val;
                                      // Automatic cascade logic: if user disables Product Category, automatically disable Product Sub-Category
                                      if (feature == 'Product Category' && !val) {
                                        _features['Product Sub-Category'] = false;
                                      }
                                    });
                                  },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text('Save Policy Config'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                        onPressed: () async {
                          try {
                            final api = ref.read(settingsApiProvider);
                            await api.updateProductPolicy({
                              'businessType': _selectedBusinessType,
                              'productPolicy': _features,
                            });
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product Policy Saved Successfully!')));
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving policy: $e'), backgroundColor: Colors.red));
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
