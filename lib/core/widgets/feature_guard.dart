import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/entitlements_provider.dart';

class FeatureGuard extends ConsumerWidget {
  final String featureKey;
  final String featureTitle;
  final Widget child;
  final Widget? fallback;

  const FeatureGuard({
    Key? key,
    required this.featureKey,
    required this.featureTitle,
    required this.child,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entitlements = ref.watch(entitlementsProvider);
    final hasAccess = entitlements.hasFeature(featureKey);

    if (hasAccess) {
      return child;
    }

    if (fallback != null) {
      return fallback!;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF1E293B),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: Colors.amber,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$featureTitle is Locked',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This module is excluded from your current ${entitlements.packagePlan} package plan. Upgrade your plan to unlock full access.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF94A3B8),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.stars_rounded, size: 20),
              label: const Text(
                'Upgrade Subscription Plan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                _showUpgradeModal(context, ref, entitlements.packagePlan);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUpgradeModal(BuildContext context, WidgetRef ref, String currentPlan) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.rocket_launch_rounded, size: 48, color: Color(0xFF3B82F6)),
            const SizedBox(height: 12),
            const Text(
              'Unlock Full Intelligent ERP Capabilities',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Upgrade from $currentPlan to Standard or Premium to activate $featureTitle, Multi-Branch Transfers, KOT Restaurant Menu, and Automated WhatsApp Receipts.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      // In browser / web, navigate to upgrade link
                    },
                    child: const Text('View Pricing Plans'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              icon: const Icon(Icons.developer_mode_rounded, size: 16, color: Color(0xFF38BDF8)),
              label: const Text(
                'Unlock Plan in Development (Dev Mode)',
                style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                ref.read(entitlementsProvider.notifier).unlockDevPlan('AGENCY');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
