import 'package:flutter/material.dart';
import '../../../../core/utils/sar_formatter.dart';
import '../../../invoicing/domain/invoice_model.dart';

class RecentActivityList extends StatelessWidget {
  final List<InvoiceModel> activities;

  const RecentActivityList({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Text("No recent activity found.", style: TextStyle(color: Colors.grey)),
      ));
    }

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final activity = activities[index];
          final color = _getStatusColor(activity.status);
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getStatusIcon(activity.status),
                  color: color,
                  size: 20,
                ),
              ),
              title: Text(activity.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Text(activity.clientName, style: const TextStyle(color: Color(0xFF64748B))),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(SarFormatter.format(activity.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      activity.status,
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'CLEARED':
      case 'REPORTED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'FAILED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'CLEARED':
      case 'REPORTED':
        return Icons.check_circle_outline;
      case 'PENDING':
        return Icons.hourglass_empty;
      case 'FAILED':
        return Icons.error_outline;
      default:
        return Icons.receipt_long_outlined;
    }
  }
}
