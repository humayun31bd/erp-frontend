double _safeParseDouble(dynamic value, [double defaultValue = 0.0]) {
  if (value == null) return defaultValue;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? defaultValue;
  return defaultValue;
}

int _safeParseInt(dynamic value, [int defaultValue = 0]) {
  if (value == null) return defaultValue;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
}

class SupplierQuotationItemModel {
  final String? id;
  final String? quotationId;
  final String? productId;
  final String description;
  final double quantity;
  final double unitPrice;
  final double totalAmount;

  SupplierQuotationItemModel({
    this.id,
    this.quotationId,
    this.productId,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
  });

  factory SupplierQuotationItemModel.fromJson(Map<String, dynamic> json) => SupplierQuotationItemModel(
        id: json['id'] as String?,
        quotationId: json['quotationId'] as String? ?? json['quotation_id'] as String?,
        productId: json['productId'] as String? ?? json['product_id'] as String?,
        description: json['description'] as String? ?? '',
        quantity: _safeParseDouble(json['quantity']),
        unitPrice: _safeParseDouble(json['unitPrice'] ?? json['unit_price']),
        totalAmount: _safeParseDouble(json['totalAmount'] ?? json['total_amount']),
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (quotationId != null) 'quotation_id': quotationId,
        if (productId != null) 'product_id': productId,
        'description': description,
        'quantity': quantity,
        'unit_price': unitPrice,
        'total_amount': totalAmount,
      };
}

class SupplierQuotationModel {
  final String id;
  final String tenantId;
  final String supplierId;
  final String quotationNumber;
  final String? supplierRefNo;
  final String? documentUrl;
  final String status;
  final String? title;
  final DateTime quotationDate;
  final DateTime? validUntil;
  final String totalAmount;
  final String currency;
  final String? notes;
  final DateTime createdAt;
  final String? supplierName;
  final List<SupplierQuotationItemModel> items;

  SupplierQuotationModel({
    required this.id,
    required this.tenantId,
    required this.supplierId,
    required this.quotationNumber,
    this.supplierRefNo,
    this.documentUrl,
    required this.status,
    this.title,
    required this.quotationDate,
    this.validUntil,
    required this.totalAmount,
    this.currency = 'SAR',
    this.notes,
    required this.createdAt,
    this.supplierName,
    this.items = const [],
  });

  factory SupplierQuotationModel.fromJson(Map<String, dynamic> json) => SupplierQuotationModel(
        id: json['id'] as String? ?? '',
        tenantId: json['tenantId'] as String? ?? json['tenant_id'] as String? ?? '',
        supplierId: json['supplierId'] as String? ?? json['supplier_id'] as String? ?? '',
        quotationNumber: json['quotationNumber'] as String? ?? json['quotation_number'] as String? ?? '',
        supplierRefNo: json['supplierRefNo'] as String? ?? json['supplier_ref_no'] as String?,
        documentUrl: json['documentUrl'] as String? ?? json['document_url'] as String?,
        status: json['status'] as String? ?? 'SUBMITTED',
        title: json['title'] as String? ?? json['remarks'] as String?,
        quotationDate: json['issueDate'] != null
            ? (DateTime.tryParse(json['issueDate'].toString()) ?? DateTime.now())
            : (json['quotationDate'] != null
                ? (DateTime.tryParse(json['quotationDate'].toString()) ?? DateTime.now())
                : (json['quotation_date'] != null
                    ? (DateTime.tryParse(json['quotation_date'].toString()) ?? DateTime.now())
                    : DateTime.now())),
        validUntil: json['validUntil'] != null
            ? DateTime.tryParse(json['validUntil'].toString())
            : (json['valid_until'] != null ? DateTime.tryParse(json['valid_until'].toString()) : null),
        totalAmount: json['totalAmount']?.toString() ?? json['total_amount']?.toString() ?? '0.00',
        currency: json['currency'] as String? ?? 'SAR',
        notes: json['remarks'] as String? ?? json['notes'] as String?,
        createdAt: json['createdAt'] != null
            ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now())
            : (json['created_at'] != null
                ? (DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now())
                : DateTime.now()),
        supplierName: json['supplierName'] as String? ?? json['supplier_name'] as String?,
        items: json['items'] != null
            ? (json['items'] as List)
                .map((i) => SupplierQuotationItemModel.fromJson(i as Map<String, dynamic>))
                .toList()
            : [],
      );
}

class CsItemModel {
  final String id;
  final String csId;
  final String quotationId;
  final String? supplierId;
  final String supplierName;
  final String quotationNumber;
  final String quotedAmount;
  final int deliveryLeadDays;
  final int score;
  final double financialScore;
  final double deliveryScore;
  final double technicalScore;
  final double compositeScore;
  final int rank;
  final bool isLowestPrice;
  final bool isHighestScore;
  final bool isSelected;
  final String? rejectionReason;

  CsItemModel({
    required this.id,
    required this.csId,
    required this.quotationId,
    this.supplierId,
    required this.supplierName,
    required this.quotationNumber,
    required this.quotedAmount,
    required this.deliveryLeadDays,
    required this.score,
    this.financialScore = 0.0,
    this.deliveryScore = 0.0,
    this.technicalScore = 80.0,
    this.compositeScore = 0.0,
    this.rank = 1,
    this.isLowestPrice = false,
    this.isHighestScore = false,
    required this.isSelected,
    this.rejectionReason,
  });

  factory CsItemModel.fromJson(Map<String, dynamic> json) => CsItemModel(
        id: json['id'] as String? ?? '',
        csId: json['cs_id'] as String? ?? json['csId'] as String? ?? '',
        quotationId: json['quotation_id'] as String? ?? json['quotationId'] as String? ?? '',
        supplierId: json['supplier_id'] as String? ?? json['supplierId'] as String?,
        supplierName: json['supplier_name'] as String? ?? json['supplierName'] as String? ?? 'Unknown Supplier',
        quotationNumber: json['quotation_number'] as String? ?? json['quotationNumber'] as String? ?? '',
        quotedAmount: json['quoted_amount']?.toString() ?? json['quotedAmount']?.toString() ?? '0.00',
        deliveryLeadDays: _safeParseInt(json['delivery_lead_days'] ?? json['deliveryLeadDays'], 7),
        score: _safeParseInt(json['composite_score'] ?? json['compositeScore'] ?? json['score']),
        financialScore: _safeParseDouble(json['financial_score'] ?? json['financialScore']),
        deliveryScore: _safeParseDouble(json['delivery_score'] ?? json['deliveryScore']),
        technicalScore: _safeParseDouble(json['technical_score'] ?? json['technicalScore'], 80.0),
        compositeScore: _safeParseDouble(json['composite_score'] ?? json['compositeScore'] ?? json['score']),
        rank: _safeParseInt(json['rank'], 1),
        isLowestPrice: json['is_lowest_price'] == 1 || json['is_lowest_price'] == true || json['isLowestPrice'] == true,
        isHighestScore: json['is_highest_score'] == 1 || json['is_highest_score'] == true || json['isHighestScore'] == true,
        isSelected: json['is_selected'] == 1 || json['is_selected'] == true || json['isSelected'] == true,
        rejectionReason: json['rejection_reason'] as String? ?? json['rejectionReason'] as String?,
      );
}

class LineItemBidModel {
  final String quotationId;
  final String supplierId;
  final String supplierName;
  final String quotationNumber;
  final double unitPrice;
  final double quantity;
  final double totalAmount;
  final bool isLowestPrice;

  LineItemBidModel({
    required this.quotationId,
    required this.supplierId,
    required this.supplierName,
    required this.quotationNumber,
    required this.unitPrice,
    required this.quantity,
    required this.totalAmount,
    required this.isLowestPrice,
  });

  factory LineItemBidModel.fromJson(Map<String, dynamic> json) => LineItemBidModel(
        quotationId: json['quotationId']?.toString() ?? '',
        supplierId: json['supplierId']?.toString() ?? '',
        supplierName: json['supplierName']?.toString() ?? 'Supplier',
        quotationNumber: json['quotationNumber']?.toString() ?? '',
        unitPrice: _safeParseDouble(json['unitPrice']),
        quantity: _safeParseDouble(json['quantity'], 1.0),
        totalAmount: _safeParseDouble(json['totalAmount']),
        isLowestPrice: json['isLowestPrice'] == true,
      );
}

class LineItemMatrixRowModel {
  final String key;
  final String? productId;
  final String productName;
  final String description;
  final double quantity;
  final double lowestUnitPrice;
  final double highestUnitPrice;
  final String lowestSupplierName;
  final String lowestQuotationId;
  final String lowestSupplierId;
  final double variancePercent;
  final double potentialSavings;
  final Map<String, LineItemBidModel> supplierBids;

  LineItemMatrixRowModel({
    required this.key,
    this.productId,
    required this.productName,
    required this.description,
    required this.quantity,
    required this.lowestUnitPrice,
    required this.highestUnitPrice,
    required this.lowestSupplierName,
    required this.lowestQuotationId,
    required this.lowestSupplierId,
    required this.variancePercent,
    required this.potentialSavings,
    required this.supplierBids,
  });

  factory LineItemMatrixRowModel.fromJson(Map<String, dynamic> json) {
    final bidsRaw = json['supplierBids'] as Map<String, dynamic>? ?? {};
    final bids = <String, LineItemBidModel>{};
    bidsRaw.forEach((k, v) {
      if (v is Map<String, dynamic>) {
        bids[k] = LineItemBidModel.fromJson(v);
      }
    });

    return LineItemMatrixRowModel(
      key: json['key']?.toString() ?? '',
      productId: json['productId']?.toString(),
      productName: json['productName']?.toString() ?? json['description']?.toString() ?? 'Item',
      description: json['description']?.toString() ?? '',
      quantity: _safeParseDouble(json['quantity'], 1.0),
      lowestUnitPrice: _safeParseDouble(json['lowestUnitPrice']),
      highestUnitPrice: _safeParseDouble(json['highestUnitPrice']),
      lowestSupplierName: json['lowestSupplierName']?.toString() ?? 'N/A',
      lowestQuotationId: json['lowestQuotationId']?.toString() ?? '',
      lowestSupplierId: json['lowestSupplierId']?.toString() ?? '',
      variancePercent: _safeParseDouble(json['variancePercent']),
      potentialSavings: _safeParseDouble(json['potentialSavings']),
      supplierBids: bids,
    );
  }
}

class LineItemMatrixSummaryModel {
  final int totalItems;
  final double cherryPickTotal;
  final double potentialSavingsVsHighest;
  final double potentialSavingsPercent;

  LineItemMatrixSummaryModel({
    required this.totalItems,
    required this.cherryPickTotal,
    required this.potentialSavingsVsHighest,
    required this.potentialSavingsPercent,
  });

  factory LineItemMatrixSummaryModel.fromJson(Map<String, dynamic> json) => LineItemMatrixSummaryModel(
        totalItems: _safeParseInt(json['totalItems']),
        cherryPickTotal: _safeParseDouble(json['cherryPickTotal']),
        potentialSavingsVsHighest: _safeParseDouble(json['potentialSavingsVsHighest']),
        potentialSavingsPercent: _safeParseDouble(json['potentialSavingsPercent']),
      );
}

class LineItemMatrixModel {
  final List<LineItemMatrixRowModel> rows;
  final LineItemMatrixSummaryModel? summary;

  LineItemMatrixModel({
    required this.rows,
    this.summary,
  });

  factory LineItemMatrixModel.fromJson(Map<String, dynamic> json) {
    final rowsList = (json['rows'] as List?)
            ?.map((r) => LineItemMatrixRowModel.fromJson(r as Map<String, dynamic>))
            .toList() ??
        [];
    final summaryObj = json['summary'] != null
        ? LineItemMatrixSummaryModel.fromJson(json['summary'] as Map<String, dynamic>)
        : null;

    return LineItemMatrixModel(
      rows: rowsList,
      summary: summaryObj,
    );
  }
}

class GeneratedPoSummaryModel {
  final String id;
  final String poNumber;
  final String supplierId;
  final String supplierName;
  final String totalAmount;
  final String status;
  final DateTime? createdAt;

  GeneratedPoSummaryModel({
    required this.id,
    required this.poNumber,
    required this.supplierId,
    required this.supplierName,
    required this.totalAmount,
    required this.status,
    this.createdAt,
  });

  factory GeneratedPoSummaryModel.fromJson(Map<String, dynamic> json) => GeneratedPoSummaryModel(
        id: json['id'] as String? ?? '',
        poNumber: json['poNumber'] as String? ?? json['po_number'] as String? ?? '',
        supplierId: json['supplierId'] as String? ?? json['supplier_id'] as String? ?? '',
        supplierName: json['supplierName'] as String? ?? json['supplier_name'] as String? ?? 'Supplier',
        totalAmount: json['totalAmount']?.toString() ?? json['total_amount']?.toString() ?? '0.00',
        status: json['status'] as String? ?? 'ISSUED',
        createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      );
}

class ComparativeStatementModel {
  final String id;
  final String csNumber;
  final String title;
  final String status;
  final String? winnerQuotationId;
  final String? winnerSupplierId;
  final String? winnerSupplierName;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? notes;
  final DateTime createdAt;
  final List<CsItemModel> items;
  final LineItemMatrixModel? lineItemMatrix;
  final List<GeneratedPoSummaryModel> purchaseOrders;

  ComparativeStatementModel({
    required this.id,
    required this.csNumber,
    required this.title,
    required this.status,
    this.winnerQuotationId,
    this.winnerSupplierId,
    this.winnerSupplierName,
    this.approvedBy,
    this.approvedAt,
    this.notes,
    required this.createdAt,
    this.items = const [],
    this.lineItemMatrix,
    this.purchaseOrders = const [],
  });

  factory ComparativeStatementModel.fromJson(Map<String, dynamic> json) => ComparativeStatementModel(
        id: json['id'] as String? ?? '',
        csNumber: json['cs_number'] as String? ?? json['csNumber'] as String? ?? '',
        title: json['title'] as String? ?? '',
        status: json['status'] as String? ?? 'DRAFT',
        winnerQuotationId: json['winner_quotation_id'] as String? ?? json['winnerQuotationId'] as String?,
        winnerSupplierId: json['winner_supplier_id'] as String? ?? json['winnerSupplierId'] as String?,
        winnerSupplierName: json['winner_supplier_name'] as String? ?? json['winnerSupplierName'] as String?,
        approvedBy: json['approved_by'] as String? ?? json['approvedBy'] as String?,
        approvedAt: json['approved_at'] != null ? DateTime.tryParse(json['approved_at'].toString()) : (json['approvedAt'] != null ? DateTime.tryParse(json['approvedAt'].toString()) : null),
        notes: json['notes'] as String?,
        createdAt: json['created_at'] != null
            ? (DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now())
            : (json['createdAt'] != null ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()) : DateTime.now()),
        items: json['items'] != null
            ? (json['items'] as List)
                .map((i) => CsItemModel.fromJson(i as Map<String, dynamic>))
                .toList()
            : [],
        lineItemMatrix: json['lineItemMatrix'] != null
            ? LineItemMatrixModel.fromJson(json['lineItemMatrix'] as Map<String, dynamic>)
            : null,
        purchaseOrders: json['purchaseOrders'] != null
            ? (json['purchaseOrders'] as List)
                .map((p) => GeneratedPoSummaryModel.fromJson(p as Map<String, dynamic>))
                .toList()
            : (json['generatedPurchaseOrders'] != null
                ? (json['generatedPurchaseOrders'] as List)
                    .map((p) => GeneratedPoSummaryModel.fromJson(p as Map<String, dynamic>))
                    .toList()
                : []),
      );
}

class PurchaseOrderItemModel {
  final String? id;
  final String? poId;
  final String? productId;
  final String description;
  final double quantity;
  final double unitPrice;
  final double vatRate;
  final double subtotalAmount;
  final double vatAmount;
  final double totalAmount;

  PurchaseOrderItemModel({
    this.id,
    this.poId,
    this.productId,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.vatRate = 15.0,
    required this.subtotalAmount,
    required this.vatAmount,
    required this.totalAmount,
  });

  factory PurchaseOrderItemModel.fromJson(Map<String, dynamic> json) => PurchaseOrderItemModel(
        id: json['id'] as String?,
        poId: json['po_id'] as String? ?? json['poId'] as String?,
        productId: json['product_id'] as String? ?? json['productId'] as String?,
        description: json['description'] as String? ?? '',
        quantity: _safeParseDouble(json['quantity']),
        unitPrice: _safeParseDouble(json['unit_price'] ?? json['unitPrice']),
        vatRate: _safeParseDouble(json['vat_rate'] ?? json['vatRate'], 15.0),
        subtotalAmount: _safeParseDouble(json['subtotal_amount'] ?? json['subtotalAmount']),
        vatAmount: _safeParseDouble(json['vat_amount'] ?? json['vatAmount']),
        totalAmount: _safeParseDouble(json['total_amount'] ?? json['totalAmount']),
      );
}

class PurchaseOrderModel {
  final String id;
  final String tenantId;
  final String poNumber;
  final String supplierId;
  final String supplierName;
  final String? supplierPhone;
  final String? supplierEmail;
  final String? supplierAddress;
  final String? supplierTaxNumber;
  final String? csId;
  final String? quotationId;
  final String status;
  final DateTime issueDate;
  final DateTime? expectedDeliveryDate;
  final String subtotalAmount;
  final String vatAmount;
  final String totalAmount;
  final String currency;
  final String? notes;
  final DateTime createdAt;
  final List<PurchaseOrderItemModel> items;

  PurchaseOrderModel({
    required this.id,
    required this.tenantId,
    required this.poNumber,
    required this.supplierId,
    required this.supplierName,
    this.supplierPhone,
    this.supplierEmail,
    this.supplierAddress,
    this.supplierTaxNumber,
    this.csId,
    this.quotationId,
    required this.status,
    required this.issueDate,
    this.expectedDeliveryDate,
    required this.subtotalAmount,
    required this.vatAmount,
    required this.totalAmount,
    this.currency = 'SAR',
    this.notes,
    required this.createdAt,
    this.items = const [],
  });

  factory PurchaseOrderModel.fromJson(Map<String, dynamic> json) => PurchaseOrderModel(
        id: json['id'] as String? ?? '',
        tenantId: json['tenant_id'] as String? ?? json['tenantId'] as String? ?? '',
        poNumber: json['po_number'] as String? ?? json['poNumber'] as String? ?? '',
        supplierId: json['supplier_id'] as String? ?? json['supplierId'] as String? ?? '',
        supplierName: json['supplier_name'] as String? ?? json['supplierName'] as String? ?? 'Supplier',
        supplierPhone: json['supplierPhone'] as String? ?? json['supplier_phone'] as String?,
        supplierEmail: json['supplierEmail'] as String? ?? json['supplier_email'] as String?,
        supplierAddress: json['supplierAddress'] as String? ?? json['supplier_address'] as String?,
        supplierTaxNumber: json['supplierTaxNumber'] as String? ?? json['supplier_tax_number'] as String?,
        csId: json['cs_id'] as String? ?? json['csId'] as String?,
        quotationId: json['quotation_id'] as String? ?? json['quotationId'] as String?,
        status: json['status'] as String? ?? 'ISSUED',
        issueDate: json['issue_date'] != null
            ? (DateTime.tryParse(json['issue_date'].toString()) ?? DateTime.now())
            : (json['issueDate'] != null ? (DateTime.tryParse(json['issueDate'].toString()) ?? DateTime.now()) : DateTime.now()),
        expectedDeliveryDate: json['expected_delivery_date'] != null
            ? DateTime.tryParse(json['expected_delivery_date'].toString())
            : (json['expectedDeliveryDate'] != null ? DateTime.tryParse(json['expectedDeliveryDate'].toString()) : null),
        subtotalAmount: json['subtotal_amount']?.toString() ?? json['subtotalAmount']?.toString() ?? '0.00',
        vatAmount: json['vat_amount']?.toString() ?? json['vatAmount']?.toString() ?? '0.00',
        totalAmount: json['total_amount']?.toString() ?? json['totalAmount']?.toString() ?? '0.00',
        currency: json['currency'] as String? ?? 'SAR',
        notes: json['notes'] as String?,
        createdAt: json['created_at'] != null
            ? (DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now())
            : (json['createdAt'] != null ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()) : DateTime.now()),
        items: json['items'] != null
            ? (json['items'] as List)
                .map((i) => PurchaseOrderItemModel.fromJson(i as Map<String, dynamic>))
                .toList()
            : [],
      );
}

class GrnItemModel {
  final String? id;
  final String? grnId;
  final String? productId;
  final String description;
  final double orderedQuantity;
  final double receivedQuantity;
  final double unitPrice;

  GrnItemModel({
    this.id,
    this.grnId,
    this.productId,
    required this.description,
    required this.orderedQuantity,
    required this.receivedQuantity,
    required this.unitPrice,
  });

  factory GrnItemModel.fromJson(Map<String, dynamic> json) => GrnItemModel(
        id: json['id'] as String?,
        grnId: json['grn_id'] as String? ?? json['grnId'] as String?,
        productId: json['product_id'] as String? ?? json['productId'] as String?,
        description: json['description'] as String? ?? '',
        orderedQuantity: _safeParseDouble(json['ordered_quantity'] ?? json['orderedQuantity']),
        receivedQuantity: _safeParseDouble(json['received_quantity'] ?? json['receivedQuantity']),
        unitPrice: _safeParseDouble(json['unit_price'] ?? json['unitPrice']),
      );
}

class GoodsReceivedNoteModel {
  final String id;
  final String tenantId;
  final String grnNumber;
  final String? poId;
  final String? poNumber;
  final String supplierId;
  final String supplierName;
  final String? supplierPhone;
  final String? supplierEmail;
  final String? supplierAddress;
  final String? supplierTaxNumber;
  final String? warehouseId;
  final String? warehouseName;
  final DateTime receivedDate;
  final String status;
  final String? deliveryNoteNumber;
  final String? remarks;
  final DateTime createdAt;
  final List<GrnItemModel> items;

  GoodsReceivedNoteModel({
    required this.id,
    required this.tenantId,
    required this.grnNumber,
    this.poId,
    this.poNumber,
    required this.supplierId,
    required this.supplierName,
    this.supplierPhone,
    this.supplierEmail,
    this.supplierAddress,
    this.supplierTaxNumber,
    this.warehouseId,
    this.warehouseName,
    required this.receivedDate,
    required this.status,
    this.deliveryNoteNumber,
    this.remarks,
    required this.createdAt,
    this.items = const [],
  });

  double get totalOrderedQuantity =>
      items.fold(0.0, (sum, i) => sum + i.orderedQuantity);
  double get totalReceivedQuantity =>
      items.fold(0.0, (sum, i) => sum + i.receivedQuantity);
  double get totalValue =>
      items.fold(0.0, (sum, i) => sum + (i.receivedQuantity * i.unitPrice));
  double get fulfillmentRate => totalOrderedQuantity > 0
      ? (totalReceivedQuantity / totalOrderedQuantity) * 100
      : 100.0;
  int get itemCount => items.length;

  factory GoodsReceivedNoteModel.fromJson(Map<String, dynamic> json) => GoodsReceivedNoteModel(
        id: json['id'] as String? ?? '',
        tenantId: json['tenant_id'] as String? ?? json['tenantId'] as String? ?? '',
        grnNumber: json['grn_number'] as String? ?? json['grnNumber'] as String? ?? '',
        poId: json['po_id'] as String? ?? json['poId'] as String?,
        poNumber: json['po_number'] as String? ?? json['poNumber'] as String?,
        supplierId: json['supplier_id'] as String? ?? json['supplierId'] as String? ?? '',
        supplierName: json['supplier_name'] as String? ?? json['supplierName'] as String? ?? 'Supplier',
        supplierPhone: json['supplier_phone'] as String? ?? json['supplierPhone'] as String?,
        supplierEmail: json['supplier_email'] as String? ?? json['supplierEmail'] as String?,
        supplierAddress: json['supplier_address'] as String? ?? json['supplierAddress'] as String?,
        supplierTaxNumber: json['supplier_tax_number'] as String? ?? json['supplierTaxNumber'] as String?,
        warehouseId: json['warehouse_id'] as String? ?? json['warehouseId'] as String?,
        warehouseName: json['warehouse_name'] as String? ?? json['warehouseName'] as String?,
        receivedDate: json['received_date'] != null
            ? (DateTime.tryParse(json['received_date'].toString()) ?? DateTime.now())
            : (json['receivedDate'] != null ? (DateTime.tryParse(json['receivedDate'].toString()) ?? DateTime.now()) : DateTime.now()),
        status: json['status'] as String? ?? 'RECEIVED',
        deliveryNoteNumber: json['delivery_note_number'] as String? ?? json['deliveryNoteNumber'] as String?,
        remarks: json['remarks'] as String?,
        createdAt: json['created_at'] != null
            ? (DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now())
            : (json['createdAt'] != null ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()) : DateTime.now()),
        items: json['items'] != null
            ? (json['items'] as List)
                .map((i) => GrnItemModel.fromJson(i as Map<String, dynamic>))
                .toList()
            : [],
      );
}

class QcItemModel {
  final String? id;
  final String? qcId;
  final String description;
  final double receivedQuantity;
  final double acceptedQuantity;
  final double rejectedQuantity;
  final double exchangedQuantity;
  final String status;
  final String? defectReason;

  QcItemModel({
    this.id,
    this.qcId,
    required this.description,
    required this.receivedQuantity,
    required this.acceptedQuantity,
    required this.rejectedQuantity,
    required this.exchangedQuantity,
    required this.status,
    this.defectReason,
  });

  factory QcItemModel.fromJson(Map<String, dynamic> json) => QcItemModel(
        id: json['id'] as String?,
        qcId: json['qc_id'] as String? ?? json['qcId'] as String?,
        description: json['description'] as String? ?? '',
        receivedQuantity: _safeParseDouble(json['received_quantity'] ?? json['receivedQuantity']),
        acceptedQuantity: _safeParseDouble(json['accepted_quantity'] ?? json['acceptedQuantity']),
        rejectedQuantity: _safeParseDouble(json['rejected_quantity'] ?? json['rejectedQuantity']),
        exchangedQuantity: _safeParseDouble(json['exchanged_quantity'] ?? json['exchangedQuantity']),
        status: json['status'] as String? ?? 'PASSED',
        defectReason: json['defect_reason'] as String? ?? json['defectReason'] as String?,
      );
}

class QualityCheckRecordModel {
  final String id;
  final String tenantId;
  final String qcNumber;
  final String grnId;
  final String grnNumber;
  final String inspectorName;
  final DateTime checkDate;
  final String overallStatus;
  final double totalReceived;
  final double totalAccepted;
  final double totalRejected;
  final double totalExchanged;
  final String? remarks;
  final DateTime createdAt;
  final List<QcItemModel> items;

  QualityCheckRecordModel({
    required this.id,
    required this.tenantId,
    required this.qcNumber,
    required this.grnId,
    required this.grnNumber,
    required this.inspectorName,
    required this.checkDate,
    required this.overallStatus,
    required this.totalReceived,
    required this.totalAccepted,
    required this.totalRejected,
    required this.totalExchanged,
    this.remarks,
    required this.createdAt,
    this.items = const [],
  });

  factory QualityCheckRecordModel.fromJson(Map<String, dynamic> json) => QualityCheckRecordModel(
        id: json['id'] as String? ?? '',
        tenantId: json['tenant_id'] as String? ?? json['tenantId'] as String? ?? '',
        qcNumber: json['qc_number'] as String? ?? json['qcNumber'] as String? ?? '',
        grnId: json['grn_id'] as String? ?? json['grnId'] as String? ?? '',
        grnNumber: json['grn_number'] as String? ?? json['grnNumber'] as String? ?? 'GRN',
        inspectorName: json['inspector_name'] as String? ?? json['inspectorName'] as String? ?? 'Inspector',
        checkDate: json['check_date'] != null
            ? (DateTime.tryParse(json['check_date'].toString()) ?? DateTime.now())
            : (json['checkDate'] != null ? (DateTime.tryParse(json['checkDate'].toString()) ?? DateTime.now()) : DateTime.now()),
        overallStatus: json['overall_status'] as String? ?? json['overallStatus'] as String? ?? 'PASSED',
        totalReceived: _safeParseDouble(json['total_received'] ?? json['totalReceived']),
        totalAccepted: _safeParseDouble(json['total_accepted'] ?? json['totalAccepted']),
        totalRejected: _safeParseDouble(json['total_rejected'] ?? json['totalRejected']),
        totalExchanged: _safeParseDouble(json['total_exchanged'] ?? json['totalExchanged']),
        remarks: json['remarks'] as String?,
        createdAt: json['created_at'] != null
            ? (DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now())
            : (json['createdAt'] != null ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()) : DateTime.now()),
        items: json['items'] != null
            ? (json['items'] as List)
                .map((i) => QcItemModel.fromJson(i as Map<String, dynamic>))
                .toList()
            : [],
      );
}

class SupplierBillModel {
  final String id;
  final String tenantId;
  final String billNumber;
  final String supplierId;
  final String supplierName;
  final String? poId;
  final String? grnId;
  final DateTime issueDate;
  final DateTime? dueDate;
  final String subtotalAmount;
  final String discountAmount;
  final String vatAmount;
  final String totalAmount;
  final String paidAmount;
  final String paymentStatus;
  final String? referenceDocUrl;
  final String? referenceDocName;
  final String? remarks;
  final DateTime createdAt;

  SupplierBillModel({
    required this.id,
    required this.tenantId,
    required this.billNumber,
    required this.supplierId,
    required this.supplierName,
    this.poId,
    this.grnId,
    required this.issueDate,
    this.dueDate,
    required this.subtotalAmount,
    this.discountAmount = '0.00',
    required this.vatAmount,
    required this.totalAmount,
    required this.paidAmount,
    required this.paymentStatus,
    this.referenceDocUrl,
    this.referenceDocName,
    this.remarks,
    required this.createdAt,
  });

  factory SupplierBillModel.fromJson(Map<String, dynamic> json) => SupplierBillModel(
        id: json['id'] as String? ?? '',
        tenantId: json['tenant_id'] as String? ?? json['tenantId'] as String? ?? '',
        billNumber: json['bill_number'] as String? ?? json['billNumber'] as String? ?? '',
        supplierId: json['supplier_id'] as String? ?? json['supplierId'] as String? ?? '',
        supplierName: json['supplier_name'] as String? ?? json['supplierName'] as String? ?? 'Supplier',
        poId: json['po_id'] as String? ?? json['poId'] as String?,
        grnId: json['grn_id'] as String? ?? json['grnId'] as String?,
        issueDate: json['issue_date'] != null
            ? (DateTime.tryParse(json['issue_date'].toString()) ?? DateTime.now())
            : (json['issueDate'] != null ? (DateTime.tryParse(json['issueDate'].toString()) ?? DateTime.now()) : DateTime.now()),
        dueDate: json['due_date'] != null
            ? DateTime.tryParse(json['due_date'].toString())
            : (json['dueDate'] != null ? DateTime.tryParse(json['dueDate'].toString()) : null),
        subtotalAmount: json['subtotal_amount']?.toString() ?? json['subtotalAmount']?.toString() ?? '0.00',
        discountAmount: json['discount_amount']?.toString() ?? json['discountAmount']?.toString() ?? '0.00',
        vatAmount: json['vat_amount']?.toString() ?? json['vatAmount']?.toString() ?? '0.00',
        totalAmount: json['total_amount']?.toString() ?? json['totalAmount']?.toString() ?? '0.00',
        paidAmount: json['paid_amount']?.toString() ?? json['paidAmount']?.toString() ?? '0.00',
        paymentStatus: json['payment_status'] as String? ?? json['paymentStatus'] as String? ?? 'UNPAID',
        referenceDocUrl: json['reference_doc_url'] as String? ?? json['referenceDocUrl'] as String?,
        referenceDocName: json['reference_doc_name'] as String? ?? json['referenceDocName'] as String?,
        remarks: json['remarks'] as String?,
        createdAt: json['created_at'] != null
            ? (DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now())
            : (json['createdAt'] != null ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()) : DateTime.now()),
      );
}
