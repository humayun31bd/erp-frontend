class SupplierReturnItemModel {
  final String id;
  final String? productId;
  final String itemDescription;
  final double unitPrice;
  final double quantity;
  final double vatRate;
  final double vatAmount;
  final double totalAmount;
  final String? reason;

  SupplierReturnItemModel({
    required this.id,
    this.productId,
    required this.itemDescription,
    required this.unitPrice,
    required this.quantity,
    this.vatRate = 15.0,
    required this.vatAmount,
    required this.totalAmount,
    this.reason,
  });

  factory SupplierReturnItemModel.fromJson(Map<String, dynamic> json) {
    return SupplierReturnItemModel(
      id: json['id'] as String? ?? '',
      productId: json['productId'] as String?,
      itemDescription: json['itemDescription'] as String? ?? 'Returned Item',
      unitPrice: double.tryParse(json['unitPrice']?.toString() ?? '0') ?? 0.0,
      quantity: double.tryParse(json['quantity']?.toString() ?? '1') ?? 1.0,
      vatRate: double.tryParse(json['vatRate']?.toString() ?? '15') ?? 15.0,
      vatAmount: double.tryParse(json['vatAmount']?.toString() ?? '0') ?? 0.0,
      totalAmount: double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0.0,
      reason: json['reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'itemDescription': itemDescription,
        'unitPrice': unitPrice,
        'quantity': quantity,
        'vatRate': vatRate,
        'vatAmount': vatAmount,
        'totalAmount': totalAmount,
        'reason': reason,
      };
}

class SupplierReturnModel {
  final String id;
  final String tenantId;
  final String returnNumber;
  final String debitNoteNumber;
  final String supplierId;
  final String supplierName;
  final String? originalBillId;
  final String? billNumber;
  final String returnDate;
  final String reason;
  final double subtotalAmount;
  final double vatAmount;
  final double totalAmount;
  final String status; // 'DRAFT', 'SUBMITTED', 'APPROVED', 'REFUNDED', 'REJECTED'
  final String refundStatus; // 'PENDING', 'CREDITED_TO_ACCOUNT', 'REFUNDED_CASH', 'REFUNDED_BANK'
  final String? remarks;
  final List<SupplierReturnItemModel> items;
  final String createdAt;

  SupplierReturnModel({
    required this.id,
    required this.tenantId,
    required this.returnNumber,
    required this.debitNoteNumber,
    required this.supplierId,
    required this.supplierName,
    this.originalBillId,
    this.billNumber,
    required this.returnDate,
    this.reason = 'DEFECTIVE',
    required this.subtotalAmount,
    required this.vatAmount,
    required this.totalAmount,
    this.status = 'DRAFT',
    this.refundStatus = 'PENDING',
    this.remarks,
    this.items = const [],
    required this.createdAt,
  });

  factory SupplierReturnModel.fromJson(Map<String, dynamic> json) {
    var rawItems = json['items'] as List<dynamic>? ?? [];
    List<SupplierReturnItemModel> itemList = rawItems
        .map((i) => SupplierReturnItemModel.fromJson(i as Map<String, dynamic>))
        .toList();

    return SupplierReturnModel(
      id: json['id'] as String? ?? '',
      tenantId: json['tenantId'] as String? ?? '',
      returnNumber: json['returnNumber'] as String? ?? '',
      debitNoteNumber: json['debitNoteNumber'] as String? ?? '',
      supplierId: json['supplierId'] as String? ?? '',
      supplierName: json['supplierName'] as String? ?? 'Supplier',
      originalBillId: json['originalBillId'] as String?,
      billNumber: json['billNumber'] as String?,
      returnDate: json['returnDate'] as String? ?? '',
      reason: json['reason'] as String? ?? 'DEFECTIVE',
      subtotalAmount: double.tryParse(json['subtotalAmount']?.toString() ?? '0') ?? 0.0,
      vatAmount: double.tryParse(json['vatAmount']?.toString() ?? '0') ?? 0.0,
      totalAmount: double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0.0,
      status: json['status'] as String? ?? 'DRAFT',
      refundStatus: json['refundStatus'] as String? ?? 'PENDING',
      remarks: json['remarks'] as String?,
      items: itemList,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tenantId': tenantId,
        'returnNumber': returnNumber,
        'debitNoteNumber': debitNoteNumber,
        'supplierId': supplierId,
        'supplierName': supplierName,
        'originalBillId': originalBillId,
        'billNumber': billNumber,
        'returnDate': returnDate,
        'reason': reason,
        'subtotalAmount': subtotalAmount,
        'vatAmount': vatAmount,
        'totalAmount': totalAmount,
        'status': status,
        'refundStatus': refundStatus,
        'remarks': remarks,
        'items': items.map((i) => i.toJson()).toList(),
        'createdAt': createdAt,
      };
}
