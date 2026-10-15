import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/product_features_provider.dart';

class ProductSettingsContent extends ConsumerWidget {
  const ProductSettingsContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productFeaturesProvider);
    final notifier = ref.read(productFeaturesProvider.notifier);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Product Features Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                SwitchListTile(
                  title: const Text('Enable Variable Products'),
                  subtitle: const Text('Allow products with multiple variations (e.g., sizes, colors)'),
                  value: state.enableVariableProduct,
                  onChanged: (val) => notifier.updateState(state.copyWith(enableVariableProduct: val)),
                ),
                SwitchListTile(
                  title: const Text('Enable Stock Management'),
                  subtitle: const Text('Track and manage inventory levels for products'),
                  value: state.enableStockManagement,
                  onChanged: (val) {
                    notifier.updateState(state.copyWith(
                      enableStockManagement: val,
                      enableLowStockAlert: val ? state.enableLowStockAlert : false,
                    ));
                  },
                ),
                SwitchListTile(
                  title: const Text('Enable Multiple Branches'),
                  subtitle: const Text('Track inventory across different branches/stores'),
                  value: state.enableBranches,
                  onChanged: (val) => notifier.updateState(state.copyWith(enableBranches: val)),
                ),
                SwitchListTile(
                  title: const Text('Enable Categories'),
                  subtitle: const Text('Organize products into categories'),
                  value: state.enableCategories,
                  onChanged: (val) => notifier.updateState(state.copyWith(enableCategories: val)),
                ),
                SwitchListTile(
                  title: const Text('Enable Sub-Categories'),
                  subtitle: const Text('Organize products into sub-categories'),
                  value: state.enableSubCategories,
                  onChanged: state.enableCategories 
                    ? (val) => notifier.updateState(state.copyWith(enableSubCategories: val))
                    : null,
                ),
                SwitchListTile(
                  title: const Text('Enable Units'),
                  subtitle: const Text('Manage different measurement units (e.g., kg, piece, box)'),
                  value: state.enableUnits,
                  onChanged: (val) => notifier.updateState(state.copyWith(enableUnits: val)),
                ),
                SwitchListTile(
                  title: const Text('Enable Tax Rates'),
                  subtitle: const Text('Apply specific tax rates to products'),
                  value: state.enableTaxRates,
                  onChanged: (val) => notifier.updateState(state.copyWith(enableTaxRates: val)),
                ),
                SwitchListTile(
                  title: const Text('Enable Group Tax'),
                  subtitle: const Text('Apply combined tax groups to products'),
                  value: state.enableGroupTax,
                  onChanged: (val) => notifier.updateState(state.copyWith(enableGroupTax: val)),
                ),
                SwitchListTile(
                  title: const Text('Enable Low Stock Alert'),
                  subtitle: const Text('Receive notifications when product stock goes below a threshold'),
                  value: state.enableLowStockAlert,
                  onChanged: state.enableStockManagement 
                    ? (val) => notifier.updateState(state.copyWith(enableLowStockAlert: val))
                    : null,
                ),
                SwitchListTile(
                  title: const Text('Enable Product Expiry'),
                  subtitle: const Text('Track expiry dates for perishable goods'),
                  value: state.enableProductExpiry,
                  onChanged: (val) {
                    notifier.updateState(state.copyWith(
                      enableProductExpiry: val,
                      enableLowStockExpiryAlert: val ? state.enableLowStockExpiryAlert : false,
                    ));
                  },
                ),
                SwitchListTile(
                  title: const Text('Enable Low Stock Expiry Alerts'),
                  subtitle: const Text('Receive alerts for products approaching their expiry date'),
                  value: state.enableLowStockExpiryAlert,
                  onChanged: state.enableProductExpiry 
                    ? (val) => notifier.updateState(state.copyWith(enableLowStockExpiryAlert: val))
                    : null,
                ),
                SwitchListTile(
                  title: const Text('Enable IMEI / Serial Number'),
                  subtitle: const Text('Track unique serial numbers for electronics and devices'),
                  value: state.enableImeiSerial,
                  onChanged: (val) => notifier.updateState(state.copyWith(enableImeiSerial: val)),
                ),
                SwitchListTile(
                  title: const Text('Enable Lot Number'),
                  subtitle: const Text('Track batches and lot numbers for products'),
                  value: state.enableLotNumber,
                  onChanged: (val) => notifier.updateState(state.copyWith(enableLotNumber: val)),
                ),
                SwitchListTile(
                  title: const Text('Enable Print Barcode & Labels'),
                  subtitle: const Text('Generate and print barcodes for products'),
                  value: state.enableBarcodePrinting,
                  onChanged: (val) => notifier.updateState(state.copyWith(enableBarcodePrinting: val)),
                ),
                SwitchListTile(
                  title: const Text('Enable Selling Price Group'),
                  subtitle: const Text('Create different price groups (e.g., Wholesale, Retail)'),
                  value: state.enableSellingPriceGroup,
                  onChanged: (val) => notifier.updateState(state.copyWith(enableSellingPriceGroup: val)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Save Settings'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Product Settings Saved (Locally) Successfully!')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
