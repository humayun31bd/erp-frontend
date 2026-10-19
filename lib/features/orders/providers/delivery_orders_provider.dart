import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../domain/delivery_order_model.dart';
import '../services/audio_alert_service.dart';

class DeliveryOrdersState {
  final List<DeliveryOrderModel> orders;
  final bool isLoading;
  final String? error;
  final String activeFilter; // 'all', 'dine_in', 'take_away', 'delivery'
  final String searchQuery;
  final bool autoRefreshEnabled;
  final DateTime? lastRefreshed;

  const DeliveryOrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
    this.activeFilter = 'all',
    this.searchQuery = '',
    this.autoRefreshEnabled = true,
    this.lastRefreshed,
  });

  DeliveryOrdersState copyWith({
    List<DeliveryOrderModel>? orders,
    bool? isLoading,
    String? error,
    String? activeFilter,
    String? searchQuery,
    bool? autoRefreshEnabled,
    DateTime? lastRefreshed,
  }) {
    return DeliveryOrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      autoRefreshEnabled: autoRefreshEnabled ?? this.autoRefreshEnabled,
      lastRefreshed: lastRefreshed ?? this.lastRefreshed,
    );
  }

  /// Filtered orders by active tab/channel/type and search query
  List<DeliveryOrderModel> get filteredOrders {
    var result = orders;

    if (activeFilter != 'all') {
      result = result.where((o) => o.orderType == activeFilter).toList();
    }

    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim();
      result = result.where((o) {
        final matchesOrderNum = o.orderNumber.toLowerCase().contains(q);
        final matchesInvNum = o.invoiceNumber?.toLowerCase().contains(q) ?? false;
        final matchesCustomer = o.buyerName?.toLowerCase().contains(q) ?? false;
        final matchesPhone = o.buyerPhone?.toLowerCase().contains(q) ?? false;
        final matchesTable = o.tableNumber?.toLowerCase().contains(q) ?? false;
        final matchesAggregator = o.aggregator?.toLowerCase().contains(q) ?? false;
        return matchesOrderNum || matchesInvNum || matchesCustomer || matchesPhone || matchesTable || matchesAggregator;
      }).toList();
    }

    return result;
  }

  List<DeliveryOrderModel> ordersByColumn(String columnKey) {
    return filteredOrders.where((o) => o.kanbanColumnKey == columnKey).toList();
  }
}

class DeliveryOrdersNotifier extends StateNotifier<DeliveryOrdersState> {
  final Dio _dio;
  Timer? _pollingTimer;
  final Set<String> _knownOrderIds = {};
  bool _isFirstLoad = true;

  DeliveryOrdersNotifier(this._dio) : super(const DeliveryOrdersState()) {
    fetchOrders();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (state.autoRefreshEnabled) {
        fetchOrders(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void toggleAutoRefresh() {
    final next = !state.autoRefreshEnabled;
    state = state.copyWith(autoRefreshEnabled: next);
    if (next) {
      _startPolling();
    } else {
      _pollingTimer?.cancel();
    }
  }

  void setFilter(String filter) {
    state = state.copyWith(activeFilter: filter);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> fetchOrders({bool silent = false}) async {
    if (!silent) {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final response = await _dio.get('/orders/delivery', queryParameters: {
        'limit': 100,
      });

      if (response.statusCode == 200 && response.data != null) {
        final raw = response.data['data'] ?? response.data['orders'] ?? [];
        final data = raw as List<dynamic>;
        final parsed = data.map((json) => DeliveryOrderModel.fromJson(json as Map<String, dynamic>)).toList();

        // Check for new incoming orders in 'WFC' (Waiting For Confirmation)
        if (!_isFirstLoad) {
          final newWfcOrders = parsed.where((o) => o.status == 'WFC' && !_knownOrderIds.contains(o.id));
          if (newWfcOrders.isNotEmpty) {
            AudioAlertService.playNewOrderAlert();
          }
        }
        _isFirstLoad = false;

        _knownOrderIds.clear();
        for (var o in parsed) {
          _knownOrderIds.add(o.id);
        }

        state = state.copyWith(
          orders: parsed,
          isLoading: false,
          lastRefreshed: DateTime.now(),
          error: null,
        );
      } else {
        if (!silent) {
          state = state.copyWith(isLoading: false, error: 'Failed to load delivery orders');
        }
      }
    } catch (e) {
      if (!silent) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  /// Updates the status of an order (e.g. WFC -> OUP -> RTS -> Dlvd)
  Future<bool> updateOrderStatus(
    String orderId, 
    String nextStatus, {
    String? notes, 
    String? podNotes,
    String changedBy = 'pos_staff',
  }) async {
    try {
      final response = await _dio.patch('/orders/delivery/$orderId/status', data: {
        'status': nextStatus,
        if (notes != null) 'note': notes,
        if (podNotes != null) 'podNotes': podNotes,
        'changedBy': changedBy,
      });

      if (response.statusCode == 200) {
        await fetchOrders(silent: true);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Cancels an order with mandatory reason
  Future<bool> cancelOrder(
    String orderId, {
    required String reason,
    String cancelledBy = 'server',
  }) async {
    try {
      final response = await _dio.post('/orders/delivery/$orderId/cancel', data: {
        'reason': reason,
        'cancelledBy': cancelledBy,
      });

      if (response.statusCode == 200) {
        await fetchOrders(silent: true);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Assigns a driver to an order
  Future<bool> assignDriver(
    String orderId, {
    String? driverId,
    required String driverName,
    required String driverPhone,
    String? vehicleInfo,
    String? aggregatorReference,
    String? riderTrackingNote,
    bool autoDispatch = true,
  }) async {
    try {
      final response = await _dio.patch('/orders/delivery/$orderId/assign-driver', data: {
        if (driverId != null) 'driverId': driverId,
        'driverName': driverName,
        'driverPhone': driverPhone,
        if (vehicleInfo != null) 'vehicleInfo': vehicleInfo,
        if (aggregatorReference != null) 'aggregatorReference': aggregatorReference,
        if (riderTrackingNote != null) 'riderTrackingNote': riderTrackingNote,
        'autoDispatch': autoDispatch,
      });

      if (response.statusCode == 200) {
        await fetchOrders(silent: true);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

final deliveryOrdersProvider = StateNotifierProvider.autoDispose<DeliveryOrdersNotifier, DeliveryOrdersState>((ref) {
  final dio = ref.watch(dioProvider);
  return DeliveryOrdersNotifier(dio);
});
