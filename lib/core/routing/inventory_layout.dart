import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'route_names.dart';
import '../l10n/app_localizations.dart';

class InventoryLayout extends ConsumerWidget {
  final Widget child;

  const InventoryLayout({super.key, required this.child});

  Widget _buildNavItem(BuildContext context, {
    required String title,
    required IconData icon,
    required String routeName,
    required String targetPath,
    required String currentPath,
  }) {
    final isSelected = currentPath == targetPath || (targetPath != '/inventory' && currentPath.startsWith(targetPath));

    return ListTile(
      leading: Icon(icon, color: isSelected ? Theme.of(context).primaryColor : null),
      title: Text(
        title, 
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Theme.of(context).primaryColor : null,
        )
      ),
      selected: isSelected,
      selectedTileColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      onTap: () => context.goNamed(routeName),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final String currentPath = GoRouterState.of(context).uri.path;
    final isDesktop = MediaQuery.of(context).size.width > 800;

    final sidebar = Container(
      width: 250,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.inventory,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildNavItem(
            context,
            title: 'Products',
            icon: Icons.inventory_2,
            routeName: RouteNames.inventory,
            targetPath: RoutePaths.inventory,
            currentPath: currentPath,
          ),
          _buildNavItem(
            context,
            title: 'Categories',
            icon: Icons.category,
            routeName: RouteNames.categories,
            targetPath: RoutePaths.categories,
            currentPath: currentPath,
          ),
          _buildNavItem(
            context,
            title: 'Sub Categories',
            icon: Icons.account_tree,
            routeName: RouteNames.subCategories,
            targetPath: RoutePaths.subCategories,
            currentPath: currentPath,
          ),
          _buildNavItem(
            context,
            title: 'Units',
            icon: Icons.square_foot,
            routeName: RouteNames.units,
            targetPath: RoutePaths.units,
            currentPath: currentPath,
          ),
          _buildNavItem(
            context,
            title: 'Variable Products',
            icon: Icons.auto_awesome_motion,
            routeName: RouteNames.variableProducts,
            targetPath: RoutePaths.variableProducts,
            currentPath: currentPath,
          ),
          _buildNavItem(
            context,
            title: 'Opening Stock',
            icon: Icons.inventory_outlined,
            routeName: RouteNames.openingStock,
            targetPath: RoutePaths.openingStock,
            currentPath: currentPath,
          ),
          _buildNavItem(
            context,
            title: 'Print Product Labels',
            icon: Icons.qr_code_2,
            routeName: RouteNames.printLabels,
            targetPath: RoutePaths.printLabels,
            currentPath: currentPath,
          ),
        ],
      ),
    );

    if (!isDesktop) {
      return child; // On mobile, just return the child and use normal navigation
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        sidebar,
        Expanded(child: child),
      ],
    );
  }
}
