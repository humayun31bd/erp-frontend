import 'package:flutter/material.dart';
import '../../domain/delivery_order_model.dart';
import '../../../pos/providers/receipt_printer_service.dart';
import 'order_cancel_dialog.dart';

class OrderTicketCard extends StatelessWidget {
  final DeliveryOrderModel order;
  final Function(String targetStatus, {String? notes, String? podNotes}) onStatusTransition;
  final Function(String reason, String cancelledBy) onCancelOrder;
  final VoidCallback? onAssignDriver;
  final VoidCallback? onConfirmDelivery;

  const OrderTicketCard({
    super.key,
    required this.order,
    required this.onStatusTransition,
    required this.onCancelOrder,
    this.onAssignDriver,
    this.onConfirmDelivery,
  });

  Color _getTimerColor() {
    if (order.isLate) return Colors.red.shade700;
    if (order.isWarning) return Colors.orange.shade800;
    return Colors.blueGrey.shade600;
  }

  Color _getAggregatorColor(String? aggregator) {
    if (aggregator == null) return Colors.teal;
    final lower = aggregator.toLowerCase();
    if (lower.contains('jahez')) return const Color(0xFFE11D48); // Rose red
    if (lower.contains('hunger')) return const Color(0xFFF59E0B); // Amber
    if (lower.contains('marsool')) return const Color(0xFF10B981); // Emerald
    if (lower.contains('toyou')) return const Color(0xFF6366F1); // Indigo
    if (lower.contains('ninja')) return const Color(0xFF8B5CF6); // Purple
    return Colors.teal;
  }

  @override
  Widget build(BuildContext context) {
    final nextAction = order.nextAction;
    final isLate = order.isLate;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLate ? Colors.red.shade300 : Colors.grey.shade200,
          width: isLate ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isLate
                ? Colors.red.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Order #, Timer, Type Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isLate ? Colors.red.shade50 : Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      order.orderNumber,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isLate ? Colors.red.shade900 : const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildOrderTypeBadge(),
                  ],
                ),
                // Elapsed Timer
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTimerColor().withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 14, color: _getTimerColor()),
                      const SizedBox(width: 4),
                      Text(
                        '${order.elapsedMinutes}m',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getTimerColor(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Metadata row (Table or Delivery Aggregator & Customer)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (order.tableNumber != null && order.tableNumber!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.table_restaurant, size: 14, color: Colors.brown),
                            const SizedBox(width: 4),
                            Text(
                              order.tableNumber!,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.brown),
                            ),
                          ],
                        ),
                      )
                    else if (order.aggregator != null && order.aggregator!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _getAggregatorColor(order.aggregator).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${order.aggregator} ${order.aggregatorReference != null ? "#${order.aggregatorReference}" : ""}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: _getAggregatorColor(order.aggregator),
                          ),
                        ),
                      )
                    else
                      Text(
                        'Order Type: ${order.orderTypeLabelEn}',
                        style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                      ),

                    if (order.driverName != null)
                      InkWell(
                        onTap: onAssignDriver,
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.purple.shade200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.delivery_dining, size: 14, color: Colors.purple),
                              const SizedBox(width: 4),
                              Text(
                                order.driverName!,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.purple),
                              ),
                              const SizedBox(width: 3),
                              const Icon(Icons.edit, size: 10, color: Colors.purple),
                            ],
                          ),
                        ),
                      )
                    else if ((order.orderType == 'delivery' || order.orderType == 'third_party_delivery') && onAssignDriver != null)
                      InkWell(
                        onTap: onAssignDriver,
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_add_alt_1_rounded, size: 13, color: Color(0xFF8B5CF6)),
                              SizedBox(width: 4),
                              Text(
                                '+ Assign Driver',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF8B5CF6)),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

                if (order.buyerName != null && order.buyerName!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${order.buyerName} ${order.buyerPhone != null ? "(${order.buyerPhone})" : ""}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                if (order.deliveryAddress != null && order.deliveryAddress!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          order.deliveryAddress!,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1, thickness: 0.8),

          // Items List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (order.items.isEmpty)
                  const Text('No line items recorded', style: TextStyle(fontSize: 12, color: Colors.grey))
                else
                  ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.5),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${item.quantity.toStringAsFixed(item.quantity % 1 == 0 ? 0 : 1)}x',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.productName,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
                              ),
                            ),
                            Text(
                              '${item.totalPrice.toStringAsFixed(2)} SAR',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      )),

                if (order.notes != null && order.notes!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Text(
                      '📝 Note: ${order.notes}',
                      style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.brown.shade800),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Total & Actions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(13),
                bottomRight: Radius.circular(13),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      '${order.totalAmount.toStringAsFixed(2)} SAR',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Print KOT ticket
                    IconButton(
                      icon: const Icon(Icons.print_outlined, size: 20),
                      tooltip: 'Print KOT / Ticket',
                      color: Colors.blueGrey,
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        ReceiptPrinterService.printKitchenTicketFromData(
                          orderNumber: order.orderNumber,
                          orderType: order.orderType,
                          tableNumber: order.tableNumber,
                          aggregator: order.aggregator,
                          status: order.status,
                          items: order.items.map((it) => {
                            'productName': it.productName,
                            'quantity': it.quantity,
                          }).toList(),
                          notes: order.notes,
                        );
                      },
                    ),

                    // Cancel Order button (if not already completed or cancelled)
                    if (order.status != 'CANCELLED' && order.status != 'Dlvd' && order.status != 'Srvd' && order.status != 'TA')
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        tooltip: 'Cancel Order',
                        color: Colors.red.shade400,
                        visualDensity: VisualDensity.compact,
                        onPressed: () async {
                          final res = await showDialog<Map<String, dynamic>>(
                            context: context,
                            builder: (ctx) => OrderCancelDialog(orderNumber: order.orderNumber),
                          );
                          if (res != null) {
                            onCancelOrder(res['reason'] as String, res['cancelledBy'] as String);
                          }
                        },
                      ),

                    const Spacer(),

                    // Primary Progression Action Button
                    if (nextAction != null)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(int.parse(nextAction.buttonColorHex)),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                        label: Text(
                          nextAction.label,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        onPressed: () {
                          if (nextAction.targetStatus == 'OOW' && order.driverName == null && onAssignDriver != null) {
                            onAssignDriver!();
                          } else if (nextAction.targetStatus == 'Dlvd' && (order.orderType == 'delivery' || order.orderType == 'third_party_delivery') && onConfirmDelivery != null) {
                            onConfirmDelivery!();
                          } else {
                            onStatusTransition(nextAction.targetStatus);
                          }
                        },
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: order.status == 'CANCELLED' ? Colors.red.shade50 : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          order.statusLabelEn,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: order.status == 'CANCELLED' ? Colors.red.shade700 : Colors.green.shade700,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTypeBadge() {
    IconData icon;
    Color color;

    switch (order.orderType) {
      case 'dine_in':
        icon = Icons.restaurant;
        color = const Color(0xFF0284C7); // Sky blue
        break;
      case 'delivery':
      case 'online_delivery':
        icon = Icons.two_wheeler;
        color = const Color(0xFF7C3AED); // Violet
        break;
      case 'take_away':
      default:
        icon = Icons.shopping_bag_outlined;
        color = const Color(0xFF059669); // Emerald
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            order.orderTypeLabelEn,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: color),
          ),
        ],
      ),
    );
  }
}
