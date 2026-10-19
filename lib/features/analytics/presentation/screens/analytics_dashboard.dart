import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/route_names.dart';
import '../providers/analytics_provider.dart';

class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(analyticsSummaryProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
      ),
      body: asyncData.when(
        data: (summary) => _buildContent(summary),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildContent(AnalyticsSummary summary) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _statCard('Total Orders', summary.totalOrders.toString()),
          _statCard('Cancelled Orders', summary.cancelledOrders.toString()),
          _statCard('Cancellation Rate', '${(summary.cancellationRate * 100).toStringAsFixed(2)}%'),
          _statCard('Avg Delivery Time', summary.avgDeliveryTimeMinutes != null ? '${summary.avgDeliveryTimeMinutes!.toStringAsFixed(2)} mins' : 'N/A'),
          const SizedBox(height: 20),
          const Text('Channel Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(),
          ...summary.channelDistribution.entries.map((e) => ListTile(title: Text(e.key), trailing: Text(e.value.toString()))),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(label),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// Model class
class AnalyticsSummary {
  final int totalOrders;
  final int cancelledOrders;
  final double cancellationRate;
  final double? avgDeliveryTimeMinutes;
  final Map<String, int> channelDistribution;

  AnalyticsSummary({
    required this.totalOrders,
    required this.cancelledOrders,
    required this.cancellationRate,
    required this.avgDeliveryTimeMinutes,
    required this.channelDistribution,
  });

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummary(
      totalOrders: json['totalOrders'] as int,
      cancelledOrders: json['cancelledOrders'] as int,
      cancellationRate: (json['cancellationRate'] as num).toDouble(),
      avgDeliveryTimeMinutes: json['avgDeliveryTimeMinutes'] != null ? (json['avgDeliveryTimeMinutes'] as num).toDouble() : null,
      channelDistribution: Map<String, int>.from(json['channelDistribution'] as Map),
    );
  }
}
