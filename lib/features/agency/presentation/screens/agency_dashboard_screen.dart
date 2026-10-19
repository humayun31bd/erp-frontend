import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../providers/agency_provider.dart';
import '../../../../core/l10n/app_localizations.dart';

class AgencyDashboardScreen extends ConsumerWidget {
  const AgencyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenantsState = ref.watch(agencyTenantsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.agencyPortal),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(agencyTenantsProvider),
          ),
        ],
      ),
      body: tenantsState.when(
        data: (tenants) {
          if (tenants.isEmpty) {
            return Center(
              child: Text(l10n.noClientsFound),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(24.0),
            itemCount: tenants.length,
            itemBuilder: (context, index) {
              final tenant = tenants[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(tenant.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: tenant.status == 'ACTIVE' ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tenant.status,
                              style: TextStyle(
                                color: tenant.status == 'ACTIVE' ? Colors.green : Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('VAT: ${tenant.vatNumber} | ${tenant.email}'),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star, size: 16, color: Colors.blue),
                              const SizedBox(width: 4),
                              Text('${l10n.marketingPlans}: ${tenant.marketingPlan}', style: const TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.store, size: 16, color: Colors.blue),
                              const SizedBox(width: 4),
                              Text('${l10n.branches}: ${tenant.branches.length}', style: const TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                      ),
                      if (tenant.branches.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text('Branches:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: tenant.branches.map((b) => Chip(
                            label: Text(b, style: const TextStyle(fontSize: 12)),
                            backgroundColor: Colors.blue[50],
                            side: BorderSide.none,
                          )).toList(),
                        ),
                      ] else ...[
                        const SizedBox(height: 12),
                        const Text('No branches configured.', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                      ]
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.goNamed(RouteNames.agencyNewTenant);
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.addTenant),
      ),
    );
  }
}
