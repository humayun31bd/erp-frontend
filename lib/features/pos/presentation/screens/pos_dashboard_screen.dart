import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/pos_provider.dart';
import '../../domain/dashboard_model.dart';
import '../../../../shared/widgets/fade_slide_animation.dart';
import '../../../../shared/widgets/hover_tilt_card.dart';
import '../../../../core/l10n/app_localizations.dart';

class PosDashboardScreen extends ConsumerWidget {
  const PosDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dashboardState = ref.watch(posDashboardProvider);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.posDashboard),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeSlideAnimation(
              delay: const Duration(milliseconds: 100),
              child: _buildQuickActionsGrid(theme, context, l10n),
            ),
            const SizedBox(height: 24),
            FadeSlideAnimation(
              delay: const Duration(milliseconds: 200),
              child: _buildConfigurationSection(theme, l10n),
            ),
            const SizedBox(height: 24),
            
            FadeSlideAnimation(
              delay: const Duration(milliseconds: 300),
              child: dashboardState.when(
                data: (data) => _buildReportingSection(theme, data, l10n),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, st) => Center(child: Text('Error loading dashboard: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid(ThemeData theme, BuildContext context, AppLocalizations l10n) {
    final items = [
      {'icon': Icons.receipt, 'label': l10n.salesInvoice, 'route': 'createInvoice'},
      {'icon': Icons.shopping_cart, 'label': l10n.purchaseOrder, 'route': 'createPurchase'},
      {'icon': Icons.local_shipping, 'label': l10n.shipments, 'route': null},
      {'icon': Icons.payment, 'label': l10n.paymentReceipts, 'route': 'payments'},
      {'icon': Icons.money_off, 'label': l10n.expenses, 'route': 'cashBook'},
      {'icon': Icons.people, 'label': l10n.customer, 'route': 'clients'},
      {'icon': Icons.store, 'label': l10n.vendor, 'route': 'suppliers'},
      {'icon': Icons.receipt_long, 'label': l10n.receiptsSettings, 'route': null},
      {'icon': Icons.summarize, 'label': l10n.summary, 'route': 'reports'},
      {'icon': Icons.assignment, 'label': l10n.salesOrder, 'route': null},
      {'icon': Icons.account_balance_wallet, 'label': l10n.cashLedger, 'route': 'cashBook'},
      {'icon': Icons.more_horiz, 'label': l10n.more, 'route': null},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.quickActions, style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1.1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return HoverTiltCard(
              depth: 10.0,
              child: Card(
              elevation: 2,
              child: InkWell(
                onTap: () {
                  if (item['route'] != null) {
                    context.pushNamed(item['route'] as String);
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item['icon'] as IconData, size: 32, color: theme.primaryColor),
                    const SizedBox(height: 8),
                    Text(
                      item['label'] as String,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ));
          },
        ),
      ],
    );
  }

  Widget _buildConfigurationSection(ThemeData theme, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.configurationSettings, style: theme.textTheme.titleMedium),
            const Divider(),
            SwitchListTile(
              title: Text(l10n.enableRestaurantMode),
              value: false, // Default or bound to state
              onChanged: (bool value) {},
            ),
            ListTile(
              leading: const Icon(Icons.monetization_on),
              title: Text(l10n.currencyConfiguration),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.warning),
              title: Text(l10n.lowStockProducts),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.print),
              title: Text(l10n.printerSettings),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.contact_support),
              title: Text(l10n.contactUs),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportingSection(ThemeData theme, PosDashboardData data, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.salesReporting, style: theme.textTheme.titleLarge),
            Text('${l10n.totalRevenue}: SAR ${data.totalRevenue.toStringAsFixed(2)}', 
                 style: theme.textTheme.titleMedium?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildReportCard(
                theme,
                title: l10n.revenueReport,
                description: l10n.topProductsRevenue,
                icon: Icons.pie_chart,
                content: _buildTopProductsList(data.topProducts, theme, l10n),
                l10n: l10n,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildReportCard(
                theme,
                title: l10n.inventoryReport,
                description: '${data.lowStock.length} ${l10n.lowStockAlerts}',
                icon: Icons.inventory,
                content: _buildLowStockList(data.lowStock, theme, l10n),
                l10n: l10n,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopProductsList(List<TopProduct> topProducts, ThemeData theme, AppLocalizations l10n) {
    if (topProducts.isEmpty) return Center(child: Text(l10n.noSalesData));
    return ListView.builder(
      shrinkWrap: true,
      itemCount: topProducts.length,
      itemBuilder: (context, i) {
        final p = topProducts[i];
        return ListTile(
          dense: true,
          title: Text(p.name),
          trailing: Text('SAR ${p.totalRevenue.toStringAsFixed(2)}'),
          subtitle: Text('${l10n.sold}: ${p.totalQuantitySold}'),
        );
      },
    );
  }

  Widget _buildLowStockList(List<LowStockProduct> lowStock, ThemeData theme, AppLocalizations l10n) {
    if (lowStock.isEmpty) return Center(child: Text(l10n.stockLevelsGood));
    return ListView.builder(
      shrinkWrap: true,
      itemCount: lowStock.length,
      itemBuilder: (context, i) {
        final p = lowStock[i];
        return ListTile(
          dense: true,
          title: Text(p.name, style: const TextStyle(color: Colors.red)),
          trailing: Text('${p.stockQuantity} / ${p.minStockLevel}', style: const TextStyle(fontWeight: FontWeight.bold)),
        );
      },
    );
  }

  Widget _buildReportCard(ThemeData theme, {required String title, required String description, required IconData icon, required Widget content, required AppLocalizations l10n}) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: content,
            ),
            const SizedBox(height: 12),
            Text(description, style: theme.textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.date_range, size: 16),
              label: Text(l10n.dateSearch),
            )
          ],
        ),
      ),
    );
  }
}
