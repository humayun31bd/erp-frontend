import 'package:flutter/material.dart';
import '../../domain/delivery_order_model.dart';
import 'order_ticket_card.dart';

class OrderKanbanColumn extends StatelessWidget {
  final String title;
  final String titleAr;
  final String columnKey;
  final Color headerColor;
  final IconData icon;
  final List<DeliveryOrderModel> orders;
  final Function(String orderId, String targetStatus, {String? notes, String? podNotes}) onStatusTransition;
  final Function(String orderId, String reason, String cancelledBy) onCancelOrder;
  final Function(DeliveryOrderModel order)? onAssignDriver;
  final Function(DeliveryOrderModel order)? onConfirmDelivery;

  const OrderKanbanColumn({
    super.key,
    required this.title,
    required this.titleAr,
    required this.columnKey,
    required this.headerColor,
    required this.icon,
    required this.orders,
    required this.onStatusTransition,
    required this.onCancelOrder,
    this.onAssignDriver,
    this.onConfirmDelivery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Column Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              border: Border(
                bottom: BorderSide(color: headerColor.withValues(alpha: 0.3), width: 2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: headerColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: headerColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        titleAr,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Counter Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: orders.isNotEmpty ? headerColor : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${orders.length}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: orders.isNotEmpty ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Cards List
          Expanded(
            child: orders.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return OrderTicketCard(
                        order: order,
                        onStatusTransition: (targetStatus, {notes, podNotes}) {
                          onStatusTransition(order.id, targetStatus, notes: notes, podNotes: podNotes);
                        },
                        onCancelOrder: (reason, cancelledBy) {
                          onCancelOrder(order.id, reason, cancelledBy);
                        },
                        onAssignDriver: onAssignDriver != null ? () => onAssignDriver!(order) : null,
                        onConfirmDelivery: onConfirmDelivery != null ? () => onConfirmDelivery!(order) : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 36,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 10),
            Text(
              'No orders here',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
