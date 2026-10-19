class DeliveryOrderItem {
  final String id;
  final String productName;
  final double quantity;
  final double unitPrice;
  final double totalPrice;

  const DeliveryOrderItem({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory DeliveryOrderItem.fromJson(Map<String, dynamic> json) {
    return DeliveryOrderItem(
      id: json['id']?.toString() ?? '',
      productName: json['productName']?.toString() ?? 'Item',
      quantity: (json['quantity'] is num) ? (json['quantity'] as num).toDouble() : double.tryParse(json['quantity']?.toString() ?? '1') ?? 1.0,
      unitPrice: (json['unitPrice'] is num) ? (json['unitPrice'] as num).toDouble() : double.tryParse(json['unitPrice']?.toString() ?? '0') ?? 0.0,
      totalPrice: (json['totalPrice'] is num) ? (json['totalPrice'] as num).toDouble() : double.tryParse(json['totalPrice']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class NextStatusAction {
  final String label;
  final String labelAr;
  final String targetStatus;
  final String buttonColorHex;

  const NextStatusAction({
    required this.label,
    required this.labelAr,
    required this.targetStatus,
    required this.buttonColorHex,
  });
}

class DeliveryOrderModel {
  final String id;
  final String orderNumber;
  final String? invoiceId;
  final String orderType; // 'dine_in', 'take_away', 'delivery', 'online_delivery'
  final String channel; // 'pos', 'online', 'third_party'
  final String? aggregator;
  final String? aggregatorReference;
  final String status; // 'WFC', 'OUP', 'RTS', 'RFT', 'RFD', 'OOW', 'TA', 'Srvd', 'Dlvd', 'CANCELLED'
  final String? tableNumber;
  final String? driverId;
  final double deliveryFee;
  final String? deliveryAddress;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? confirmedAt;
  final DateTime? kitchenStartedAt;
  final DateTime? readyAt;
  final DateTime? dispatchedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final String? driverName;
  final String? driverPhone;
  final String? invoiceNumber;
  final String? buyerName;
  final String? buyerPhone;
  final double totalAmount;
  final List<DeliveryOrderItem> items;

  const DeliveryOrderModel({
    required this.id,
    required this.orderNumber,
    this.invoiceId,
    required this.orderType,
    required this.channel,
    this.aggregator,
    this.aggregatorReference,
    required this.status,
    this.tableNumber,
    this.driverId,
    this.deliveryFee = 0.0,
    this.deliveryAddress,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.confirmedAt,
    this.kitchenStartedAt,
    this.readyAt,
    this.dispatchedAt,
    this.deliveredAt,
    this.cancelledAt,
    this.driverName,
    this.driverPhone,
    this.invoiceNumber,
    this.buyerName,
    this.buyerPhone,
    this.totalAmount = 0.0,
    this.items = const [],
  });

  factory DeliveryOrderModel.fromJson(Map<String, dynamic> json) {
    final driver = json['driver'] as Map<String, dynamic>?;
    final inv = json['invoice'] as Map<String, dynamic>?;

    final rawItems = inv?['items'] as List<dynamic>? ?? [];
    final itemsList = rawItems.map((e) => DeliveryOrderItem.fromJson(e as Map<String, dynamic>)).toList();

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString());
    }

    return DeliveryOrderModel(
      id: json['id']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ?? 'ORD-0000',
      invoiceId: json['invoiceId']?.toString(),
      orderType: json['orderType']?.toString() ?? 'take_away',
      channel: json['channel']?.toString() ?? 'pos',
      aggregator: json['aggregator']?.toString(),
      aggregatorReference: json['aggregatorReference']?.toString(),
      status: json['status']?.toString() ?? 'WFC',
      tableNumber: json['tableNumber']?.toString(),
      driverId: json['driverId']?.toString(),
      deliveryFee: (json['deliveryFee'] is num) ? (json['deliveryFee'] as num).toDouble() : double.tryParse(json['deliveryFee']?.toString() ?? '0') ?? 0.0,
      deliveryAddress: json['deliveryAddress']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      confirmedAt: parseDate(json['confirmedAt']),
      kitchenStartedAt: parseDate(json['kitchenStartedAt']),
      readyAt: parseDate(json['readyAt']),
      dispatchedAt: parseDate(json['dispatchedAt']),
      deliveredAt: parseDate(json['deliveredAt']),
      cancelledAt: parseDate(json['cancelledAt']),
      driverName: driver?['name']?.toString(),
      driverPhone: driver?['phone']?.toString(),
      invoiceNumber: inv?['invoiceNumber']?.toString(),
      buyerName: inv?['buyerName']?.toString(),
      buyerPhone: inv?['buyerPhone']?.toString(),
      totalAmount: (inv?['totalAmount'] is num) ? (inv!['totalAmount'] as num).toDouble() : double.tryParse(inv?['totalAmount']?.toString() ?? '0') ?? 0.0,
      items: itemsList,
    );
  }

  int get elapsedMinutes {
    if (createdAt == null) return 0;
    return DateTime.now().difference(createdAt!).inMinutes;
  }

  bool get isLate {
    if (status == 'CANCELLED' || status == 'Dlvd' || status == 'Srvd' || status == 'TA') {
      return false;
    }
    return elapsedMinutes >= 20;
  }

  bool get isWarning {
    if (isLate) return false;
    if (status == 'CANCELLED' || status == 'Dlvd' || status == 'Srvd' || status == 'TA') {
      return false;
    }
    return elapsedMinutes >= 12;
  }

  String get orderTypeLabelEn {
    switch (orderType) {
      case 'dine_in': return 'Dine In';
      case 'delivery': return 'Delivery';
      case 'online_delivery': return 'Online Delivery';
      case 'take_away':
      default: return 'Take Away';
    }
  }

  String get orderTypeLabelAr {
    switch (orderType) {
      case 'dine_in': return 'محلي';
      case 'delivery': return 'توصيل';
      case 'online_delivery': return 'طلب أونلاين';
      case 'take_away':
      default: return 'سفري';
    }
  }

  String get statusLabelEn {
    switch (status) {
      case 'WFC': return 'Waiting Confirmation';
      case 'OUP': return 'In Kitchen';
      case 'RTS': return 'Ready to Serve';
      case 'RFT': return 'Ready for Pickup';
      case 'RFD': return 'Ready for Delivery';
      case 'OOW': return 'On the Way';
      case 'TA': return 'Takeaway Done';
      case 'Srvd': return 'Served';
      case 'Dlvd': return 'Delivered';
      case 'CANCELLED': return 'Cancelled';
      default: return status;
    }
  }

  String get statusLabelAr {
    switch (status) {
      case 'WFC': return 'في انتظار التأكيد';
      case 'OUP': return 'قيد التحضير';
      case 'RTS': return 'جاهز للتقديم';
      case 'RFT': return 'جاهز للاستلام';
      case 'RFD': return 'جاهز للتوصيل';
      case 'OOW': return 'في الطريق';
      case 'TA': return 'تم التسليم سفري';
      case 'Srvd': return 'تم التقديم';
      case 'Dlvd': return 'تم التوصيل';
      case 'CANCELLED': return 'ملغي';
      default: return status;
    }
  }

  /// Calculates the primary next transition action according to business rules
  NextStatusAction? get nextAction {
    switch (status) {
      case 'WFC':
        return const NextStatusAction(
          label: 'Accept & Cook',
          labelAr: 'قبول وبدء التحضير',
          targetStatus: 'OUP',
          buttonColorHex: '0xFF2563EB', // Blue
        );

      case 'OUP':
        if (orderType == 'dine_in') {
          return const NextStatusAction(
            label: 'Ready to Serve',
            labelAr: 'جاهز للتقديم',
            targetStatus: 'RTS',
            buttonColorHex: '0xFF10B981', // Green
          );
        } else if (orderType == 'take_away') {
          return const NextStatusAction(
            label: 'Ready for Pickup',
            labelAr: 'جاهز للاستلام',
            targetStatus: 'RFT',
            buttonColorHex: '0xFF10B981', // Green
          );
        } else {
          return const NextStatusAction(
            label: 'Ready for Delivery',
            labelAr: 'جاهز للتوصيل',
            targetStatus: 'RFD',
            buttonColorHex: '0xFF10B981', // Green
          );
        }

      case 'RTS':
        return const NextStatusAction(
          label: 'Mark as Served',
          labelAr: 'تم التقديم للطاولة',
          targetStatus: 'Srvd',
          buttonColorHex: '0xFF059669', // Emerald
        );

      case 'RFT':
        return const NextStatusAction(
          label: 'Handover to Customer',
          labelAr: 'تسليم للعميل',
          targetStatus: 'TA',
          buttonColorHex: '0xFF059669', // Emerald
        );

      case 'RFD':
        return const NextStatusAction(
          label: 'Dispatch (On the Way)',
          labelAr: 'تسليم للسائق (في الطريق)',
          targetStatus: 'OOW',
          buttonColorHex: '0xFF8B5CF6', // Purple
        );

      case 'OOW':
        return const NextStatusAction(
          label: 'Confirm Delivered',
          labelAr: 'تأكيد التسليم للعميل',
          targetStatus: 'Dlvd',
          buttonColorHex: '0xFF059669', // Emerald
        );

      default:
        return null;
    }
  }

  /// Categorizes order into one of the 5 Kanban Columns
  String get kanbanColumnKey {
    switch (status) {
      case 'WFC':
        return 'new';
      case 'OUP':
        return 'kitchen';
      case 'RTS':
      case 'RFT':
      case 'RFD':
        return 'ready';
      case 'OOW':
        return 'dispatch';
      case 'Dlvd':
      case 'Srvd':
      case 'TA':
        return 'completed';
      case 'CANCELLED':
      default:
        return 'cancelled';
    }
  }
}
