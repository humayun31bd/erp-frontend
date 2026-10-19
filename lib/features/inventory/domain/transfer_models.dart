class InventoryTransferItemModel {
  final String? id;
  final String? transferId;
  final String? productId;
  final String productName;
  final double quantity;

  InventoryTransferItemModel({
    this.id,
    this.transferId,
    this.productId,
    required this.productName,
    required this.quantity,
  });

  factory InventoryTransferItemModel.fromJson(Map<String, dynamic> json) => InventoryTransferItemModel(
        id: json['id'] as String?,
        transferId: json['transfer_id'] as String? ?? json['transferId'] as String?,
        productId: json['product_id'] as String? ?? json['productId'] as String?,
        productName: json['product_name'] as String? ?? json['productName'] as String? ?? 'Product',
        quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      );
}

class InventoryTransferModel {
  final String id;
  final String tenantId;
  final String transferNumber;
  final String fromWarehouseId;
  final String fromWarehouseName;
  final String toWarehouseId;
  final String toWarehouseName;
  final String status;
  final DateTime transferDate;
  final String? remarks;
  final DateTime createdAt;
  final List<InventoryTransferItemModel> items;

  InventoryTransferModel({
    required this.id,
    required this.tenantId,
    required this.transferNumber,
    required this.fromWarehouseId,
    required this.fromWarehouseName,
    required this.toWarehouseId,
    required this.toWarehouseName,
    required this.status,
    required this.transferDate,
    this.remarks,
    required this.createdAt,
    this.items = const [],
  });

  factory InventoryTransferModel.fromJson(Map<String, dynamic> json) => InventoryTransferModel(
        id: json['id'] as String,
        tenantId: json['tenant_id'] as String? ?? json['tenantId'] as String? ?? '',
        transferNumber: json['transfer_number'] as String? ?? json['transferNumber'] as String? ?? '',
        fromWarehouseId: json['from_warehouse_id'] as String? ?? json['fromWarehouseId'] as String? ?? '',
        fromWarehouseName: json['from_warehouse_name'] as String? ?? json['fromWarehouseName'] as String? ?? 'Source',
        toWarehouseId: json['to_warehouse_id'] as String? ?? json['toWarehouseId'] as String? ?? '',
        toWarehouseName: json['to_warehouse_name'] as String? ?? json['toWarehouseName'] as String? ?? 'Destination',
        status: json['status'] as String? ?? 'COMPLETED',
        transferDate: json['transfer_date'] != null
            ? DateTime.tryParse(json['transfer_date'].toString()) ?? DateTime.now()
            : (json['transferDate'] != null ? DateTime.tryParse(json['transferDate'].toString()) ?? DateTime.now() : DateTime.now()),
        remarks: json['remarks'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
            : (json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now() : DateTime.now()),
        items: json['items'] != null
            ? (json['items'] as List)
                .map((i) => InventoryTransferItemModel.fromJson(i as Map<String, dynamic>))
                .toList()
            : [],
      );
}

class InventoryAdjustmentItemModel {
  final String? id;
  final String? adjustmentId;
  final String? productId;
  final String productName;
  final String adjustmentType; // 'ADD' or 'SUBTRACT'
  final double quantity;

  InventoryAdjustmentItemModel({
    this.id,
    this.adjustmentId,
    this.productId,
    required this.productName,
    required this.adjustmentType,
    required this.quantity,
  });

  factory InventoryAdjustmentItemModel.fromJson(Map<String, dynamic> json) => InventoryAdjustmentItemModel(
        id: json['id'] as String?,
        adjustmentId: json['adjustment_id'] as String? ?? json['adjustmentId'] as String?,
        productId: json['product_id'] as String? ?? json['productId'] as String?,
        productName: json['product_name'] as String? ?? json['productName'] as String? ?? 'Product',
        adjustmentType: json['adjustment_type'] as String? ?? json['adjustmentType'] as String? ?? 'SUBTRACT',
        quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      );
}

class InventoryAdjustmentModel {
  final String id;
  final String tenantId;
  final String adjustmentNumber;
  final String warehouseId;
  final String warehouseName;
  final String reason;
  final String status;
  final String adjustedBy;
  final DateTime adjustmentDate;
  final String? remarks;
  final DateTime createdAt;
  final List<InventoryAdjustmentItemModel> items;

  InventoryAdjustmentModel({
    required this.id,
    required this.tenantId,
    required this.adjustmentNumber,
    required this.warehouseId,
    required this.warehouseName,
    required this.reason,
    required this.status,
    required this.adjustedBy,
    required this.adjustmentDate,
    this.remarks,
    required this.createdAt,
    this.items = const [],
  });

  factory InventoryAdjustmentModel.fromJson(Map<String, dynamic> json) => InventoryAdjustmentModel(
        id: json['id'] as String,
        tenantId: json['tenant_id'] as String? ?? json['tenantId'] as String? ?? '',
        adjustmentNumber: json['adjustment_number'] as String? ?? json['adjustmentNumber'] as String? ?? '',
        warehouseId: json['warehouse_id'] as String? ?? json['warehouseId'] as String? ?? '',
        warehouseName: json['warehouse_name'] as String? ?? json['warehouseName'] as String? ?? 'Warehouse',
        reason: json['reason'] as String? ?? 'AUDIT_CORRECTION',
        status: json['status'] as String? ?? 'APPROVED',
        adjustedBy: json['adjusted_by'] as String? ?? json['adjustedBy'] as String? ?? 'Manager',
        adjustmentDate: json['adjustment_date'] != null
            ? DateTime.tryParse(json['adjustment_date'].toString()) ?? DateTime.now()
            : (json['adjustmentDate'] != null ? DateTime.tryParse(json['adjustmentDate'].toString()) ?? DateTime.now() : DateTime.now()),
        remarks: json['remarks'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
            : (json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now() : DateTime.now()),
        items: json['items'] != null
            ? (json['items'] as List)
                .map((i) => InventoryAdjustmentItemModel.fromJson(i as Map<String, dynamic>))
                .toList()
            : [],
      );
}
