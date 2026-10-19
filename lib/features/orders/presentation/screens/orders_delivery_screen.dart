import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../domain/delivery_order_model.dart';
import '../../providers/delivery_orders_provider.dart';
import '../../services/audio_alert_service.dart';
import '../widgets/order_kanban_column.dart';
import '../widgets/order_ticket_card.dart';
import '../widgets/assign_driver_dialog.dart';
import '../widgets/delivery_proof_dialog.dart';

class OrdersDeliveryScreen extends ConsumerStatefulWidget {
  const OrdersDeliveryScreen({super.key});

  @override
  ConsumerState<OrdersDeliveryScreen> createState() => _OrdersDeliveryScreenState();
}

class _OrdersDeliveryScreenState extends ConsumerState<OrdersDeliveryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSoundOn = AudioAlertService.isSoundEnabled;
  bool _isKanbanMode = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openAssignDriverDialog(DeliveryOrderModel order, DeliveryOrdersNotifier notifier) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => AssignDriverDialog(order: order),
    );

    if (result != null) {
      final success = await notifier.assignDriver(
        order.id,
        driverId: result['driverId'] as String?,
        driverName: result['driverName'] as String,
        driverPhone: result['driverPhone'] as String,
        vehicleInfo: result['vehicleInfo'] as String?,
        aggregatorReference: result['aggregatorReference'] as String?,
        riderTrackingNote: result['riderTrackingNote'] as String?,
        autoDispatch: result['autoDispatch'] as bool? ?? true,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Driver assigned & dispatched successfully' : 'Failed to assign driver'),
          backgroundColor: success ? const Color(0xFF059669) : Colors.red,
        ),
      );
    }
  }

  Future<void> _openDeliveryProofDialog(DeliveryOrderModel order, DeliveryOrdersNotifier notifier) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => DeliveryProofDialog(order: order),
    );

    if (result != null) {
      final success = await notifier.updateOrderStatus(
        order.id,
        'Dlvd',
        podNotes: result['podNotes'] as String?,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Delivery confirmed & proof timestamped' : 'Failed to confirm delivery'),
          backgroundColor: success ? const Color(0xFF059669) : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deliveryOrdersProvider);
    final notifier = ref.read(deliveryOrdersProvider.notifier);

    // Filtered lists for each column
    final newOrders = state.ordersByColumn('new');
    final kitchenOrders = state.ordersByColumn('kitchen');
    final readyOrders = state.ordersByColumn('ready');
    final dispatchOrders = state.ordersByColumn('dispatch');
    final completedOrders = state.ordersByColumn('completed');

    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildTopBar(context, state, notifier),

            // Filter & Search Toolbar
            _buildToolbar(state, notifier),

            // Main Board / Tabs
            Expanded(
              child: state.isLoading && state.orders.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : (isCompact || !_isKanbanMode)
                      ? _buildTabbedView(
                          newOrders: newOrders,
                          kitchenOrders: kitchenOrders,
                          readyOrders: readyOrders,
                          dispatchOrders: dispatchOrders,
                          completedOrders: completedOrders,
                          notifier: notifier,
                        )
                      : _buildKanbanBoard(
                          newOrders: newOrders,
                          kitchenOrders: kitchenOrders,
                          readyOrders: readyOrders,
                          dispatchOrders: dispatchOrders,
                          completedOrders: completedOrders,
                          notifier: notifier,
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, DeliveryOrdersState state, DeliveryOrdersNotifier notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.soup_kitchen_rounded, color: Color(0xFF2563EB), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Kitchen Display & Delivery Dispatch (KDS)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'LIVE (${state.orders.length})',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF047857)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  'شاشة عرض المطبخ وإدارة توزيع الطلبات والسائقين',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // Sound Alert Toggle
          IconButton(
            tooltip: _isSoundOn ? 'Sound Alerts: Active (Mute)' : 'Sound Alerts: Muted (Unmute)',
            icon: Icon(
              _isSoundOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: _isSoundOn ? const Color(0xFF10B981) : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                AudioAlertService.toggleSound();
                _isSoundOn = AudioAlertService.isSoundEnabled;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isSoundOn ? 'Order Audio Chime Enabled' : 'Order Audio Chime Muted'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),

          // Auto-refresh Toggle
          IconButton(
            tooltip: state.autoRefreshEnabled ? 'Auto-refresh active (12s)' : 'Auto-refresh paused',
            icon: Icon(
              state.autoRefreshEnabled ? Icons.sync_rounded : Icons.sync_disabled_rounded,
              color: state.autoRefreshEnabled ? const Color(0xFF2563EB) : Colors.grey,
            ),
            onPressed: () => notifier.toggleAutoRefresh(),
          ),

          // Manual Refresh Button
          IconButton(
            tooltip: 'Refresh Now',
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF475569)),
            onPressed: () => notifier.fetchOrders(),
          ),

          const SizedBox(width: 8),

          // Switch View Mode (Kanban vs Tabs)
          IconButton(
            tooltip: _isKanbanMode ? 'Switch to Tabs' : 'Switch to Kanban Board',
            icon: Icon(
              _isKanbanMode ? Icons.view_column_rounded : Icons.view_agenda_rounded,
              color: const Color(0xFF475569),
            ),
            onPressed: () => setState(() => _isKanbanMode = !_isKanbanMode),
          ),

          const SizedBox(width: 8),

          // Back to POS Cashier Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.point_of_sale_rounded, size: 16),
            label: const Text('Back to POS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            onPressed: () => context.goNamed(RouteNames.posCashier),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(DeliveryOrdersState state, DeliveryOrdersNotifier notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          // Filter Chips
          Wrap(
            spacing: 6,
            children: [
              _buildFilterChip('All Orders', 'all', state.activeFilter, notifier),
              _buildFilterChip('🍽️ Dine In', 'dine_in', state.activeFilter, notifier),
              _buildFilterChip('🛍️ Take Away', 'take_away', state.activeFilter, notifier),
              _buildFilterChip('🛵 Delivery', 'delivery', state.activeFilter, notifier),
            ],
          ),

          const Spacer(),

          // Search Box
          SizedBox(
            width: 280,
            height: 38,
            child: TextField(
              controller: _searchController,
              onChanged: notifier.setSearchQuery,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search order #, table, customer...',
                hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                prefixIcon: const Icon(Icons.search, size: 18, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          notifier.setSearchQuery('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String key, String activeKey, DeliveryOrdersNotifier notifier) {
    final isSelected = activeKey == key;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? Colors.white : const Color(0xFF475569),
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFF2563EB),
      backgroundColor: const Color(0xFFF1F5F9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (_) => notifier.setFilter(key),
    );
  }

  Widget _buildKanbanBoard({
    required List<DeliveryOrderModel> newOrders,
    required List<DeliveryOrderModel> kitchenOrders,
    required List<DeliveryOrderModel> readyOrders,
    required List<DeliveryOrderModel> dispatchOrders,
    required List<DeliveryOrderModel> completedOrders,
    required DeliveryOrdersNotifier notifier,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column 1: New / WFC
          OrderKanbanColumn(
            title: 'New Orders',
            titleAr: 'بانتظار التأكيد (WFC)',
            columnKey: 'new',
            headerColor: const Color(0xFFF59E0B), // Amber
            icon: Icons.notifications_active_outlined,
            orders: newOrders,
            onStatusTransition: (orderId, targetStatus, {notes, podNotes}) {
              notifier.updateOrderStatus(orderId, targetStatus, notes: notes, podNotes: podNotes);
            },
            onCancelOrder: (orderId, reason, cancelledBy) {
              notifier.cancelOrder(orderId, reason: reason, cancelledBy: cancelledBy);
            },
            onAssignDriver: (order) => _openAssignDriverDialog(order, notifier),
            onConfirmDelivery: (order) => _openDeliveryProofDialog(order, notifier),
          ),

          // Column 2: In Kitchen / OUP
          OrderKanbanColumn(
            title: 'In Kitchen',
            titleAr: 'قيد التحضير (OUP)',
            columnKey: 'kitchen',
            headerColor: const Color(0xFF2563EB), // Blue
            icon: Icons.soup_kitchen_outlined,
            orders: kitchenOrders,
            onStatusTransition: (orderId, targetStatus, {notes, podNotes}) {
              notifier.updateOrderStatus(orderId, targetStatus, notes: notes, podNotes: podNotes);
            },
            onCancelOrder: (orderId, reason, cancelledBy) {
              notifier.cancelOrder(orderId, reason: reason, cancelledBy: cancelledBy);
            },
            onAssignDriver: (order) => _openAssignDriverDialog(order, notifier),
            onConfirmDelivery: (order) => _openDeliveryProofDialog(order, notifier),
          ),

          // Column 3: Ready / RTS • RFT • RFD
          OrderKanbanColumn(
            title: 'Ready',
            titleAr: 'جاهز للتسليم / التقديم',
            columnKey: 'ready',
            headerColor: const Color(0xFF10B981), // Emerald
            icon: Icons.check_circle_outline,
            orders: readyOrders,
            onStatusTransition: (orderId, targetStatus, {notes, podNotes}) {
              notifier.updateOrderStatus(orderId, targetStatus, notes: notes, podNotes: podNotes);
            },
            onCancelOrder: (orderId, reason, cancelledBy) {
              notifier.cancelOrder(orderId, reason: reason, cancelledBy: cancelledBy);
            },
            onAssignDriver: (order) => _openAssignDriverDialog(order, notifier),
            onConfirmDelivery: (order) => _openDeliveryProofDialog(order, notifier),
          ),

          // Column 4: Out for Delivery / OOW
          OrderKanbanColumn(
            title: 'Out for Delivery',
            titleAr: 'في الطريق (OOW)',
            columnKey: 'dispatch',
            headerColor: const Color(0xFF8B5CF6), // Purple
            icon: Icons.delivery_dining_outlined,
            orders: dispatchOrders,
            onStatusTransition: (orderId, targetStatus, {notes, podNotes}) {
              notifier.updateOrderStatus(orderId, targetStatus, notes: notes, podNotes: podNotes);
            },
            onCancelOrder: (orderId, reason, cancelledBy) {
              notifier.cancelOrder(orderId, reason: reason, cancelledBy: cancelledBy);
            },
            onAssignDriver: (order) => _openAssignDriverDialog(order, notifier),
            onConfirmDelivery: (order) => _openDeliveryProofDialog(order, notifier),
          ),

          // Column 5: Completed
          OrderKanbanColumn(
            title: 'Completed',
            titleAr: 'مكتمل (Dlvd / Srvd / TA)',
            columnKey: 'completed',
            headerColor: const Color(0xFF64748B), // Slate Grey
            icon: Icons.done_all_rounded,
            orders: completedOrders,
            onStatusTransition: (orderId, targetStatus, {notes, podNotes}) {
              notifier.updateOrderStatus(orderId, targetStatus, notes: notes, podNotes: podNotes);
            },
            onCancelOrder: (orderId, reason, cancelledBy) {
              notifier.cancelOrder(orderId, reason: reason, cancelledBy: cancelledBy);
            },
            onAssignDriver: (order) => _openAssignDriverDialog(order, notifier),
            onConfirmDelivery: (order) => _openDeliveryProofDialog(order, notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildTabbedView({
    required List<DeliveryOrderModel> newOrders,
    required List<DeliveryOrderModel> kitchenOrders,
    required List<DeliveryOrderModel> readyOrders,
    required List<DeliveryOrderModel> dispatchOrders,
    required List<DeliveryOrderModel> completedOrders,
    required DeliveryOrdersNotifier notifier,
  }) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF2563EB),
            unselectedLabelColor: Colors.grey.shade600,
            indicatorColor: const Color(0xFF2563EB),
            isScrollable: true,
            tabs: [
              Tab(text: 'New (${newOrders.length})'),
              Tab(text: 'Cooking (${kitchenOrders.length})'),
              Tab(text: 'Ready (${readyOrders.length})'),
              Tab(text: 'On the Way (${dispatchOrders.length})'),
              Tab(text: 'Completed (${completedOrders.length})'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOrdersList(newOrders, notifier),
              _buildOrdersList(kitchenOrders, notifier),
              _buildOrdersList(readyOrders, notifier),
              _buildOrdersList(dispatchOrders, notifier),
              _buildOrdersList(completedOrders, notifier),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersList(List<DeliveryOrderModel> list, DeliveryOrdersNotifier notifier) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('No orders in this stage', style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final order = list[index];
        return OrderTicketCard(
          order: order,
          onStatusTransition: (targetStatus, {notes, podNotes}) {
            notifier.updateOrderStatus(order.id, targetStatus, notes: notes, podNotes: podNotes);
          },
          onCancelOrder: (reason, cancelledBy) {
            notifier.cancelOrder(order.id, reason: reason, cancelledBy: cancelledBy);
          },
          onAssignDriver: () => _openAssignDriverDialog(order, notifier),
          onConfirmDelivery: () => _openDeliveryProofDialog(order, notifier),
        );
      },
    );
  }
}
