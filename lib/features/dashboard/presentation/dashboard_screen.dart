import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/sar_formatter.dart';
import '../providers/dashboard_provider.dart';
import 'widgets/kpi_card.dart';
import 'widgets/recent_activity_list.dart';
import '../../../shared/widgets/fade_slide_animation.dart';
import '../../../core/l10n/app_localizations.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardStatsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboardTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refreshDashboard,
            onPressed: () => ref.refresh(dashboardStatsProvider),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: dashboardState.when(
        data: (stats) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!stats.isZatcaHealthy)
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.red),
                        const SizedBox(width: 12),
                        Text(l10n.zatcaOffline, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                
                // KPI Cards
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth > 800;
                    
                    final cards = [
                      KpiCard(
                        title: l10n.totalRevenue, // Total Revenue (Accrual)
                        value: SarFormatter.format(stats.totalRevenue),
                        icon: Icons.account_balance_wallet_outlined,
                        color: Theme.of(context).primaryColor,
                        trend: '+12.5%',
                        isTrendUp: true,
                      ),
                      KpiCard(
                        title: 'Cash on Hand', // Total Cash on Hand (Real)
                        value: SarFormatter.format(stats.totalCashOnHand),
                        icon: Icons.attach_money_rounded,
                        color: const Color(0xFF10B981), // Emerald green
                        trend: '+8.3%',
                        isTrendUp: true,
                      ),
                      KpiCard(
                        title: l10n.clearedInvoices,
                        value: stats.invoicesCleared.toString(),
                        icon: Icons.receipt_long_outlined,
                        color: const Color(0xFF3B82F6),
                        trend: '+5.2%',
                        isTrendUp: true,
                      ),
                      KpiCard(
                        title: l10n.overdueAmount,
                        value: SarFormatter.format(stats.overdueAmount),
                        icon: Icons.warning_amber_rounded,
                        color: const Color(0xFFF59E0B),
                        trend: '-2.1%',
                        isTrendUp: false,
                      ),
                    ];

                    if (isDesktop) {
                      return Row(
                        children: [
                          Expanded(child: FadeSlideAnimation(delay: const Duration(milliseconds: 100), child: cards[0])),
                          const SizedBox(width: 24),
                          Expanded(child: FadeSlideAnimation(delay: const Duration(milliseconds: 150), child: cards[1])),
                          const SizedBox(width: 24),
                          Expanded(child: FadeSlideAnimation(delay: const Duration(milliseconds: 200), child: cards[2])),
                          const SizedBox(width: 24),
                          Expanded(child: FadeSlideAnimation(delay: const Duration(milliseconds: 250), child: cards[3])),
                        ],
                      );
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FadeSlideAnimation(delay: const Duration(milliseconds: 100), child: cards[0]),
                          const SizedBox(height: 16),
                          FadeSlideAnimation(delay: const Duration(milliseconds: 150), child: cards[1]),
                          const SizedBox(height: 16),
                          FadeSlideAnimation(delay: const Duration(milliseconds: 200), child: cards[2]),
                          const SizedBox(height: 16),
                          FadeSlideAnimation(delay: const Duration(milliseconds: 250), child: cards[3]),
                        ],
                      );
                    }
                  },
                ),
                
                const SizedBox(height: 48),
                
                FadeSlideAnimation(
                  delay: const Duration(milliseconds: 400),
                  child: Text(
                    l10n.recentActivity,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                ),
                const SizedBox(height: 24),
                
                FadeSlideAnimation(
                  delay: const Duration(milliseconds: 500),
                  child: RecentActivityList(activities: stats.recentActivity),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(l10n.failedToLoadDashboard, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(err.toString(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
                onPressed: () => ref.refresh(dashboardStatsProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
