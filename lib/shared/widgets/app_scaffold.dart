import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/routing/route_names.dart';
import '../../features/auth/providers/auth_provider.dart';
import 'responsive_builder.dart';

class AppScaffold extends ConsumerWidget {
  final Widget child;
  
  const AppScaffold({super.key, required this.child});

  void _onNavigationItemSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.goNamed(RouteNames.dashboard);
        break;
      case 1:
        context.goNamed(RouteNames.invoices);
        break;
      case 2:
        context.goNamed(RouteNames.clients);
        break;
      case 3:
        context.goNamed(RouteNames.settings);
        break;
    }
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith(RoutePaths.invoices)) return 1;
    if (location.startsWith(RoutePaths.clients)) return 2;
    if (location.startsWith(RoutePaths.settings)) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final selectedIndex = _calculateSelectedIndex(context);

    final navigationDestinations = [
      NavigationDestination(
        icon: const Icon(Icons.dashboard_outlined),
        selectedIcon: const Icon(Icons.dashboard_rounded),
        label: isArabic ? 'لوحة التحكم' : 'Dashboard',
      ),
      NavigationDestination(
        icon: const Icon(Icons.receipt_long_outlined),
        selectedIcon: const Icon(Icons.receipt_long_rounded),
        label: isArabic ? 'الفواتير' : 'Invoices',
      ),
      NavigationDestination(
        icon: const Icon(Icons.people_outline),
        selectedIcon: const Icon(Icons.people_rounded),
        label: isArabic ? 'العملاء' : 'Clients',
      ),
      NavigationDestination(
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.settings_rounded),
        label: isArabic ? 'الإعدادات' : 'Settings',
      ),
    ];

    return Scaffold(
      body: ResponsiveBuilder(
        mobile: child,
        desktop: Row(
          children: [
            NavigationRail(
              extended: ResponsiveBuilder.isDesktop(context),
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) => _onNavigationItemSelected(context, index),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.dashboard_customize_rounded, color: Theme.of(context).colorScheme.primary, size: 32),
                    if (ResponsiveBuilder.isDesktop(context)) ...[
                      const SizedBox(width: 12),
                      const Text('Numou ERP', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ]
                  ],
                ),
              ),
              destinations: navigationDestinations.map((d) => 
                NavigationRailDestination(
                  icon: d.icon,
                  selectedIcon: d.selectedIcon,
                  label: Text(d.label),
                )
              ).toList(),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () => ref.read(authProvider.notifier).logout(),
                      tooltip: isArabic ? 'تسجيل الخروج' : 'Logout',
                    ),
                  ),
                ),
              ),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: child),
          ],
        ),
      ),
      bottomNavigationBar: ResponsiveBuilder.isMobile(context)
          ? NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) => _onNavigationItemSelected(context, index),
              destinations: navigationDestinations,
            )
          : null,
    );
  }
}
