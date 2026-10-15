import 'package:flutter/material.dart';
import '../../inventory/presentation/screens/categories_screen.dart';
import '../../inventory/presentation/screens/sub_categories_screen.dart';
import '../../inventory/presentation/screens/units_screen.dart';
import '../../inventory/presentation/screens/variable_products_screen.dart';
import '../../inventory/presentation/screens/stock_management_screen.dart';
import '../../pos/presentation/screens/inventory_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/product_features_provider.dart';

class ManageProductsContent extends ConsumerWidget {
  const ManageProductsContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(productFeaturesProvider);

    final List<Widget> tabs = [
      const Tab(text: 'Products'),
    ];
    final List<Widget> tabViews = [
      const InventoryScreen(),
    ];

    if (settings.enableCategories) {
      tabs.add(const Tab(text: 'Categories'));
      tabViews.add(const CategoriesScreen());
    }
    if (settings.enableSubCategories) {
      tabs.add(const Tab(text: 'Sub Categories'));
      tabViews.add(const SubCategoriesScreen());
    }
    if (settings.enableUnits) {
      tabs.add(const Tab(text: 'Units'));
      tabViews.add(const UnitsScreen());
    }
    if (settings.enableVariableProduct) {
      tabs.add(const Tab(text: 'Variable Products'));
      tabViews.add(const VariableProductsScreen());
    }
    if (settings.enableStockManagement) {
      tabs.add(const Tab(text: 'Stock Management'));
      tabViews.add(const StockManagementScreen());
    }

    return DefaultTabController(
      length: tabs.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TabBar(
                  isScrollable: true,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey[600],
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  tabs: tabs,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(bottom: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey[100]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: TabBarView(
                  children: tabViews,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

