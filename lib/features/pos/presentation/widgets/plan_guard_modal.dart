import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/tenant_settings_provider.dart';
import '../../../settings/presentation/marketing_plans_screen.dart';

class PlanGuardModal extends ConsumerWidget {
  final String featureKey;
  final String featureName;
  final String requiredPlan;
  final String? customDescription;

  const PlanGuardModal({
    super.key,
    required this.featureKey,
    required this.featureName,
    required this.requiredPlan,
    this.customDescription,
  });

  static Future<void> show(
    BuildContext context, {
    required String featureKey,
    required String featureName,
    required String requiredPlan,
    String? customDescription,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => PlanGuardModal(
        featureKey: featureKey,
        featureName: featureName,
        requiredPlan: requiredPlan,
        customDescription: customDescription,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenantSettings = ref.watch(tenantSettingsProvider);
    final currentPlan = tenantSettings.marketingPlan.toUpperCase();
    final isProTarget = requiredPlan.toUpperCase() == 'PRO' || requiredPlan.toUpperCase() == 'ENTERPRISE';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 12,
      child: Container(
        width: 480,
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Premium Header with gradient
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isProTarget
                      ? [const Color(0xFF1E1B4B), const Color(0xFF4338CA)]
                      : [const Color(0xFF0F172A), const Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isProTarget ? Icons.workspace_premium : Icons.lock_outline,
                      color: Colors.amberAccent,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'FEATURE LOCKED',
                          style: TextStyle(
                            color: Colors.amberAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          featureName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // 2. Body Details (Scrollable & Responsive)
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customDescription ??
                          'This capability is protected by your SaaS plan entitlements. To access "$featureName", please upgrade your organization\'s plan.',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
                    ),
                    const SizedBox(height: 16),

                    // Plan comparison pills
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('CURRENT PLAN', style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    currentPlan,
                                    style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_rounded, color: Colors.grey, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('REQUIRED TIER', style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isProTarget ? Colors.purple.shade50 : Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: isProTarget ? Colors.purple.shade200 : Colors.blue.shade200),
                                  ),
                                  child: Text(
                                    '${requiredPlan.toUpperCase()} TIER',
                                    style: TextStyle(
                                      color: isProTarget ? Colors.purple.shade800 : Colors.blue.shade800,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // What's included checklist
                    Text(
                      'Unlocked with $requiredPlan Plan:',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    ..._buildPerksList(requiredPlan),

                    const SizedBox(height: 20),

                    // 3. Actions
                    Align(
                      alignment: Alignment.centerRight,
                      child: Wrap(
                        alignment: WrapAlignment.end,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('Maybe Later', style: TextStyle(color: Colors.grey.shade600)),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const MarketingPlansScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.upgrade, size: 16),
                            label: const Text('View Plans & Upgrade'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isProTarget ? const Color(0xFF4338CA) : const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  List<Widget> _buildPerksList(String plan) {
    List<String> perks;
    if (plan.toUpperCase() == 'PRO' || plan.toUpperCase() == 'ENTERPRISE') {
      perks = [
        'Multi-aggregator sync (Jahez, HungerStation, Talabat, Deliveroo)',
        'Kitchen Display System (KDS) & Realtime Order Dispatch',
        'Custom Receipt Template Designer & Dynamic QR customization',
        'Customer Loyalty points, store credits & VIP rewards',
        'Unlimited branches, counters, and monthly invoices',
      ];
    } else {
      perks = [
        'Multi-cart Order Holding & instant recall',
        'Restaurant Dine-In & Table Management with Waiter Assignment',
        'Manager Security PIN Overrides & Line-item void tracking',
        'Up to 3 Branches and 3 Active Cashier Counters',
        '2,000 Invoices per month quota',
      ];
    }

    return perks.map((p) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF10B981)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                p,
                style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700, height: 1.25),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
