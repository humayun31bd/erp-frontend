import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../shared/widgets/responsive_builder.dart';
import 'widgets/kpi_card.dart';
import 'widgets/revenue_chart.dart';
import '../../../../core/theme/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final crossAxisCount = ResponsiveBuilder.isDesktop(context) ? 4 : (ResponsiveBuilder.isTablet(context) ? 2 : 1);

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'لوحة التحكم' : 'Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? 'مرحباً بعودتك 👋' : 'Welcome back 👋',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn().slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 24),
            
            // KPI Grid
            GridView.count(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2,
              children: [
                KpiCard(
                  title: isArabic ? 'إجمالي الإيرادات' : 'Total Revenue',
                  value: 'SAR 45,231.00',
                  icon: Icons.account_balance_wallet_outlined,
                  color: AppColors.primary,
                  trend: '+12.5%',
                ),
                KpiCard(
                  title: isArabic ? 'فواتير زاتكا' : 'ZATCA Invoices',
                  value: '1,284',
                  icon: Icons.receipt_long_outlined,
                  color: AppColors.success,
                  trend: '+5.2%',
                ),
                KpiCard(
                  title: isArabic ? 'العملاء' : 'Total Clients',
                  value: '342',
                  icon: Icons.people_outline,
                  color: AppColors.accent,
                ),
                KpiCard(
                  title: isArabic ? 'متأخرة' : 'Overdue',
                  value: 'SAR 2,100',
                  icon: Icons.warning_amber_rounded,
                  color: AppColors.danger,
                  trend: '-2.1%',
                  isTrendUp: false,
                ),
              ].animate(interval: 100.ms).fadeIn().slideY(begin: 0.2, end: 0),
            ),

            const SizedBox(height: 24),

            // Charts & Lists
            SizedBox(
              height: 400,
              child: const RevenueChart().animate().fadeIn(delay: 400.ms),
            ),
          ],
        ),
      ),
    );
  }
}
