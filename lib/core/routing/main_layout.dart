import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../constants/app_colors.dart';
import '../../app.dart';
import '../l10n/app_localizations.dart';

final sidebarCollapsedProvider = StateProvider<bool>((ref) => false);


class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  Widget _buildNavItem(BuildContext context, {
    required String title,
    required IconData icon,
    required String routeName,
    required String targetPath,
    required String currentPath,
    required bool isCollapsed,
  }) {
    final isSelected = currentPath == targetPath || (targetPath != '/' && currentPath.startsWith(targetPath));

    final listTile = ListTile(
      leading: Icon(icon),
      title: isCollapsed ? null : Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      selected: isSelected,
      onTap: () => context.goNamed(routeName),
      contentPadding: isCollapsed ? const EdgeInsets.symmetric(horizontal: 0) : const EdgeInsets.symmetric(horizontal: 16),
      titleAlignment: ListTileTitleAlignment.center,
    );

    return Padding(
      padding: isCollapsed 
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: isCollapsed 
        ? Tooltip(
            message: title,
            preferBelow: false,
            child: listTile,
          )
        : listTile,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final isCollapsed = ref.watch(sidebarCollapsedProvider) && isDesktop; // Only collapse on desktop
    
    // Get current location for active states
    final String currentPath = GoRouterState.of(context).uri.path;

    final sidebar = DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: isCollapsed ? 80 : 260,
        child: Column(
          children: [
            // Header
            Container(
              height: 56,
              alignment: isCollapsed ? Alignment.center : Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 0 : 24),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
              ),
              child: Row(
                mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  if (isCollapsed)
                    IconButton(
                      icon: Image.asset('assets/images/logo.png', width: 32, height: 32),
                      onPressed: () => ref.read(sidebarCollapsedProvider.notifier).state = false,
                      tooltip: l10n.expandMenu,
                    )
                  else ...[
                    Image.asset('assets/images/logo.png', width: 32, height: 32),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Intelligent ERP',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isDesktop)
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => ref.read(sidebarCollapsedProvider.notifier).state = true,
                        tooltip: l10n.collapseMenu,
                      ),
                  ]
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Nav items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildNavItem(context, title: l10n.dashboard, icon: Icons.dashboard_outlined, routeName: RouteNames.dashboard, targetPath: RoutePaths.dashboard, currentPath: currentPath, isCollapsed: isCollapsed),
                  _buildNavItem(context, title: l10n.invoices, icon: Icons.receipt_outlined, routeName: RouteNames.invoices, targetPath: RoutePaths.invoices, currentPath: currentPath, isCollapsed: isCollapsed),
                  _buildNavItem(context, title: l10n.customers, icon: Icons.people_outline, routeName: RouteNames.customers, targetPath: RoutePaths.customers, currentPath: currentPath, isCollapsed: isCollapsed),
                  _buildNavItem(context, title: l10n.suppliers, icon: Icons.local_shipping_outlined, routeName: RouteNames.suppliers, targetPath: RoutePaths.suppliers, currentPath: currentPath, isCollapsed: isCollapsed),
                  _buildNavItem(context, title: l10n.purchases, icon: Icons.shopping_cart_checkout, routeName: RouteNames.purchases, targetPath: RoutePaths.purchases, currentPath: currentPath, isCollapsed: isCollapsed),
                  _buildNavItem(context, title: l10n.cashBook, icon: Icons.account_balance_wallet_outlined, routeName: RouteNames.cashBook, targetPath: RoutePaths.cashBook, currentPath: currentPath, isCollapsed: isCollapsed),
                  _buildNavItem(context, title: l10n.hrDashboard, icon: Icons.work_outline, routeName: RouteNames.hrDashboard, targetPath: RoutePaths.hrDashboard, currentPath: currentPath, isCollapsed: isCollapsed),
                  _buildNavItem(context, title: l10n.hrEmployees, icon: Icons.badge_outlined, routeName: RouteNames.hrEmployees, targetPath: RoutePaths.hrEmployees, currentPath: currentPath, isCollapsed: isCollapsed),
                  _buildNavItem(context, title: 'Attendance', icon: Icons.access_time, routeName: RouteNames.hrAttendance, targetPath: RoutePaths.hrAttendance, currentPath: currentPath, isCollapsed: isCollapsed),
                  _buildNavItem(context, title: 'Payroll', icon: Icons.receipt_long, routeName: RouteNames.hrPayroll, targetPath: RoutePaths.hrPayroll, currentPath: currentPath, isCollapsed: isCollapsed),
                  _buildNavItem(context, title: 'Pay Scales & Policy', icon: Icons.auto_graph, routeName: RouteNames.hrPayrollPolicy, targetPath: RoutePaths.hrPayrollPolicy, currentPath: currentPath, isCollapsed: isCollapsed),
                  _buildNavItem(context, title: 'Leaves', icon: Icons.event_busy, routeName: RouteNames.hrLeaves, targetPath: RoutePaths.hrLeaves, currentPath: currentPath, isCollapsed: isCollapsed),
                  _buildNavItem(context, title: 'Overtime', icon: Icons.timer, routeName: RouteNames.hrOvertime, targetPath: RoutePaths.hrOvertime, currentPath: currentPath, isCollapsed: isCollapsed),
                  _buildNavItem(context, title: 'Loans', icon: Icons.money, routeName: RouteNames.hrLoans, targetPath: RoutePaths.hrLoans, currentPath: currentPath, isCollapsed: isCollapsed),
                  _buildNavItem(context, title: 'EOSB', icon: Icons.calculate, routeName: RouteNames.hrEosb, targetPath: RoutePaths.hrEosb, currentPath: currentPath, isCollapsed: isCollapsed),
                  _buildNavItem(context, title: 'General Ledger', icon: Icons.account_balance, routeName: RouteNames.accountingLedger, targetPath: RoutePaths.accountingLedger, currentPath: currentPath, isCollapsed: isCollapsed),
                  _buildNavItem(context, title: 'Chart of Accounts', icon: Icons.account_tree, routeName: RouteNames.accountingCoA, targetPath: RoutePaths.accountingCoA, currentPath: currentPath, isCollapsed: isCollapsed),
                  _buildNavItem(context, title: 'Journal Entries', icon: Icons.book, routeName: RouteNames.accountingJournal, targetPath: RoutePaths.accountingJournal, currentPath: currentPath, isCollapsed: isCollapsed),
                  _buildNavItem(context, title: 'Cash Transactions', icon: Icons.receipt, routeName: RouteNames.accountingVouchers, targetPath: RoutePaths.accountingVouchers, currentPath: currentPath, isCollapsed: isCollapsed),
                  _buildNavItem(context, title: l10n.posCashier, icon: Icons.point_of_sale_outlined, routeName: RouteNames.posCashier, targetPath: RoutePaths.posCashier, currentPath: currentPath, isCollapsed: isCollapsed),
                  _buildNavItem(context, title: l10n.posDashboard, icon: Icons.grid_view, routeName: RouteNames.posDashboard, targetPath: RoutePaths.posDashboard, currentPath: currentPath, isCollapsed: isCollapsed),
                  if (!isCollapsed)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Text(l10n.aiAndLogs, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    )
                  else
                    const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(indent: 16, endIndent: 16)),
                  _buildNavItem(context, title: l10n.aiCopilot, icon: Icons.smart_toy_outlined, routeName: RouteNames.copilot, targetPath: RoutePaths.copilot, currentPath: currentPath, isCollapsed: isCollapsed),
                  _buildNavItem(context, title: l10n.whatsappLogs, icon: Icons.mark_chat_read_outlined, routeName: RouteNames.whatsapp, targetPath: RoutePaths.whatsapp, currentPath: currentPath, isCollapsed: isCollapsed),
                  if (!isCollapsed)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Text(l10n.management, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    )
                  else
                    const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(indent: 16, endIndent: 16)),
                  _buildNavItem(context, title: l10n.payments, icon: Icons.payment_outlined, routeName: RouteNames.payments, targetPath: RoutePaths.payments, currentPath: currentPath, isCollapsed: isCollapsed),
                  _buildNavItem(context, title: l10n.reports, icon: Icons.bar_chart_outlined, routeName: RouteNames.reports, targetPath: RoutePaths.reports, currentPath: currentPath, isCollapsed: isCollapsed),
                  _buildNavItem(context, title: 'Branches', icon: Icons.store_outlined, routeName: RouteNames.settingsBranches, targetPath: RoutePaths.settingsBranches, currentPath: currentPath, isCollapsed: isCollapsed),
                  _buildNavItem(context, title: 'Cost Centers', icon: Icons.business_center_outlined, routeName: RouteNames.settingsCostCenters, targetPath: RoutePaths.settingsCostCenters, currentPath: currentPath, isCollapsed: isCollapsed),
                  _buildNavItem(context, title: l10n.settings, icon: Icons.settings_outlined, routeName: RouteNames.settings, targetPath: RoutePaths.settings, currentPath: currentPath, isCollapsed: isCollapsed),
                  _buildNavItem(context, title: 'Product Policy', icon: Icons.policy_outlined, routeName: RouteNames.settingsProductPolicy, targetPath: RoutePaths.settingsProductPolicy, currentPath: currentPath, isCollapsed: isCollapsed),
                  _buildNavItem(context, title: l10n.agencyPortal, icon: Icons.business_center_outlined, routeName: RouteNames.agencyDashboard, targetPath: RoutePaths.agencyDashboard, currentPath: currentPath, isCollapsed: isCollapsed),
                ],
              ),
            ),
            const Divider(),
            // Logout button
            Padding(
              padding: isCollapsed
                  ? const EdgeInsets.symmetric(horizontal: 8, vertical: 8)
                  : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: isCollapsed
                  ? Tooltip(
                      message: l10n.logout,
                      preferBelow: false,
                      child: ListTile(
                        leading: const Icon(Icons.logout, color: AppColors.danger),
                        onTap: () => ref.read(authProvider.notifier).logout(),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        hoverColor: AppColors.danger.withValues(alpha: 0.1),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                        titleAlignment: ListTileTitleAlignment.center,
                      ),
                    )
                  : ListTile(
                      leading: const Icon(Icons.logout, color: AppColors.danger),
                      title: Text(l10n.logout, style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w500)),
                      onTap: () => ref.read(authProvider.notifier).logout(),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      hoverColor: AppColors.danger.withValues(alpha: 0.1),
                    ),
            ),
            // Language toggle
            Padding(
              padding: isCollapsed
                  ? const EdgeInsets.symmetric(horizontal: 8, vertical: 8)
                  : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: isCollapsed
                  ? Tooltip(
                      message: l10n.changeLanguage,
                      preferBelow: false,
                      child: ListTile(
                        leading: const Icon(Icons.language, color: AppColors.primary),
                        onTap: () {
                          final current = ref.read(localeProvider);
                          ref.read(localeProvider.notifier).state = current.languageCode == 'en' ? const Locale('ar') : const Locale('en');
                        },
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        hoverColor: AppColors.primary.withValues(alpha: 0.1),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                        titleAlignment: ListTileTitleAlignment.center,
                      ),
                    )
                  : ListTile(
                      leading: const Icon(Icons.language, color: AppColors.primary),
                      title: Text(isArabic ? l10n.english : l10n.arabic, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
                      onTap: () {
                        final current = ref.read(localeProvider);
                        ref.read(localeProvider.notifier).state = current.languageCode == 'en' ? const Locale('ar') : const Locale('en');
                      },
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      hoverColor: AppColors.primary.withValues(alpha: 0.1),
                    ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      ),
    );

    return Scaffold(
      drawer: isDesktop ? null : Drawer(child: sidebar),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isDesktop) sidebar,
          Expanded(child: child),
        ],
      ),
    );
  }
}
