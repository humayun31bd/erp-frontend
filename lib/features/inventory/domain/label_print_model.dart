import '../../pos/domain/product_model.dart';

/// Represents a product queued for label printing.
class LabelItem {
  final String productId;
  final String productName;
  final String? variantAttrs;
  final String barcode;
  final String? hsnCode;
  final int copiesCount;
  final DateTime? packingDate;
  final DateTime? expiryDate;
  final String? batchNumber;
  final String? serialNumber;
  final double retailPrice;
  final double? wholesalePrice;
  final double? discountPrice;

  const LabelItem({
    required this.productId,
    required this.productName,
    this.variantAttrs,
    required this.barcode,
    this.hsnCode,
    this.copiesCount = 1,
    this.packingDate,
    this.expiryDate,
    this.batchNumber,
    this.serialNumber,
    required this.retailPrice,
    this.wholesalePrice,
    this.discountPrice,
  });

  factory LabelItem.fromProduct(ProductModel p, {int copies = 1}) {
    final retail = double.tryParse(p.retailPrice ?? p.price) ?? double.tryParse(p.price) ?? 0.0;
    final wholesale = double.tryParse(p.distributorPrice ?? '') ?? 0.0;
    final discount = double.tryParse(p.discountedPrice ?? '') ?? 0.0;

    // Build variant string if available
    final parts = <String>[];
    if (p.modelNumber != null && p.modelNumber!.isNotEmpty) parts.add(p.modelNumber!);
    final variantStr = parts.isNotEmpty ? parts.join(' - ') : null;

    return LabelItem(
      productId: p.id,
      productName: p.name,
      variantAttrs: variantStr,
      barcode: (p.barcode != null && p.barcode!.isNotEmpty) ? p.barcode! : (p.sku ?? p.id.substring(0, 8).toUpperCase()),
      hsnCode: 'HSN-8471', // Standard default or custom HSN
      copiesCount: copies,
      packingDate: DateTime.now(),
      expiryDate: DateTime.now().add(const Duration(days: 365)),
      batchNumber: 'BATCH-${DateTime.now().year}',
      serialNumber: 'SN-001',
      retailPrice: retail,
      wholesalePrice: wholesale > 0 ? wholesale : null,
      discountPrice: discount > 0 ? discount : null,
    );
  }

  LabelItem copyWith({
    String? productId,
    String? productName,
    String? variantAttrs,
    String? barcode,
    String? hsnCode,
    int? copiesCount,
    DateTime? packingDate,
    DateTime? expiryDate,
    String? batchNumber,
    String? serialNumber,
    double? retailPrice,
    double? wholesalePrice,
    double? discountPrice,
  }) {
    return LabelItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      variantAttrs: variantAttrs ?? this.variantAttrs,
      barcode: barcode ?? this.barcode,
      hsnCode: hsnCode ?? this.hsnCode,
      copiesCount: copiesCount ?? this.copiesCount,
      packingDate: packingDate ?? this.packingDate,
      expiryDate: expiryDate ?? this.expiryDate,
      batchNumber: batchNumber ?? this.batchNumber,
      serialNumber: serialNumber ?? this.serialNumber,
      retailPrice: retailPrice ?? this.retailPrice,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      discountPrice: discountPrice ?? this.discountPrice,
    );
  }
}

/// Toggles controlling which data fields appear on each printed label.
class LabelDisplaySettings {
  // 1. Shop Info Toggles
  final bool showShopName;
  final bool showShopAddress;
  final bool showShopPhone;
  final bool showShopEmail;
  final bool showShopLogo;
  final String shopName;
  final String shopAddress;
  final String shopPhone;
  final String shopEmail;

  // 2. Product Info Toggles
  final bool showProductName;
  final bool showBarcodeText;
  final bool showHsnCode;

  // 3. Tracking & Packing Info Toggles
  final bool requireExpiryDate;
  final bool requireBatchNumber;
  final bool requireSerialNumber;
  final bool showPackingDate;

  // 4. Price Info Toggles
  final bool showRetailPrice;
  final bool showWholesalePrice;
  final bool showDiscountPrice;
  final String currencySymbol;

  // 5. Code Symbology
  final bool showBarcode; // 1D Barcode (Code-128)
  final bool showQrCode;  // 2D QR Code

  // 6. Label Size Info
  final bool showLabelDimensions;

  const LabelDisplaySettings({
    // Shop
    this.showShopName = true,
    this.showShopAddress = false,
    this.showShopPhone = true,
    this.showShopEmail = false,
    this.showShopLogo = false,
    this.shopName = 'Intelligent ERP Store',
    this.shopAddress = 'Riyadh, Saudi Arabia',
    this.shopPhone = '+966 50 123 4567',
    this.shopEmail = 'info@store.sa',

    // Product
    this.showProductName = true,
    this.showBarcodeText = true,
    this.showHsnCode = true,

    // Tracking
    this.requireExpiryDate = false,
    this.requireBatchNumber = false,
    this.requireSerialNumber = false,
    this.showPackingDate = false,

    // Price
    this.showRetailPrice = true,
    this.showWholesalePrice = false,
    this.showDiscountPrice = false,
    this.currencySymbol = 'SAR',

    // Codes
    this.showBarcode = true,
    this.showQrCode = false,

    // Sizing
    this.showLabelDimensions = false,
  });

  LabelDisplaySettings copyWith({
    bool? showShopName,
    bool? showShopAddress,
    bool? showShopPhone,
    bool? showShopEmail,
    bool? showShopLogo,
    String? shopName,
    String? shopAddress,
    String? shopPhone,
    String? shopEmail,
    bool? showProductName,
    bool? showBarcodeText,
    bool? showHsnCode,
    bool? requireExpiryDate,
    bool? requireBatchNumber,
    bool? requireSerialNumber,
    bool? showPackingDate,
    bool? showRetailPrice,
    bool? showWholesalePrice,
    bool? showDiscountPrice,
    String? currencySymbol,
    bool? showBarcode,
    bool? showQrCode,
    bool? showLabelDimensions,
  }) {
    return LabelDisplaySettings(
      showShopName: showShopName ?? this.showShopName,
      showShopAddress: showShopAddress ?? this.showShopAddress,
      showShopPhone: showShopPhone ?? this.showShopPhone,
      showShopEmail: showShopEmail ?? this.showShopEmail,
      showShopLogo: showShopLogo ?? this.showShopLogo,
      shopName: shopName ?? this.shopName,
      shopAddress: shopAddress ?? this.shopAddress,
      shopPhone: shopPhone ?? this.shopPhone,
      shopEmail: shopEmail ?? this.shopEmail,
      showProductName: showProductName ?? this.showProductName,
      showBarcodeText: showBarcodeText ?? this.showBarcodeText,
      showHsnCode: showHsnCode ?? this.showHsnCode,
      requireExpiryDate: requireExpiryDate ?? this.requireExpiryDate,
      requireBatchNumber: requireBatchNumber ?? this.requireBatchNumber,
      requireSerialNumber: requireSerialNumber ?? this.requireSerialNumber,
      showPackingDate: showPackingDate ?? this.showPackingDate,
      showRetailPrice: showRetailPrice ?? this.showRetailPrice,
      showWholesalePrice: showWholesalePrice ?? this.showWholesalePrice,
      showDiscountPrice: showDiscountPrice ?? this.showDiscountPrice,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      showBarcode: showBarcode ?? this.showBarcode,
      showQrCode: showQrCode ?? this.showQrCode,
      showLabelDimensions: showLabelDimensions ?? this.showLabelDimensions,
    );
  }
}

/// Standard Sheet and Continuous Roll Presets defined in printlebel.md.
enum LabelSheetPreset {
  sheet20(
    name: '20 Labels per Sheet',
    description: 'Sheet: 8.5" x 11.5", Label: 4" x 1" (2 cols x 10 rows)',
    sheetWidthInches: 8.5,
    sheetHeightInches: 11.5,
    labelWidthInches: 4.0,
    labelHeightInches: 1.0,
    columns: 2,
    rows: 10,
    isRoll: false,
    horizontalMarginInches: 0.25,
    verticalMarginInches: 0.5,
    horizontalGapInches: 0.0,
    verticalGapInches: 0.05,
  ),
  sheet30(
    name: '30 Labels per Sheet',
    description: 'Sheet: 8.5" x 11.5", Label: 2" x 2" (3 cols x 10 rows)',
    sheetWidthInches: 8.5,
    sheetHeightInches: 11.5,
    labelWidthInches: 2.0,
    labelHeightInches: 1.0, // standard 1" height for 10 rows on 11.5" sheet
    columns: 3,
    rows: 10,
    isRoll: false,
    horizontalMarginInches: 0.25,
    verticalMarginInches: 0.5,
    horizontalGapInches: 0.25,
    verticalGapInches: 0.05,
  ),
  sheet32(
    name: '32 Labels per Sheet',
    description: 'Sheet: 8.5" x 11.5", Label: 2" x 1.5" (4 cols x 8 rows)',
    sheetWidthInches: 8.5,
    sheetHeightInches: 11.5,
    labelWidthInches: 2.0,
    labelHeightInches: 1.35,
    columns: 4,
    rows: 8,
    isRoll: false,
    horizontalMarginInches: 0.25,
    verticalMarginInches: 0.35,
    horizontalGapInches: 0.0,
    verticalGapInches: 0.05,
  ),
  sheet40(
    name: '40 Labels per Sheet',
    description: 'Sheet: 8.5" x 11.5", Label: 2" x 1" (4 cols x 10 rows)',
    sheetWidthInches: 8.5,
    sheetHeightInches: 11.5,
    labelWidthInches: 2.0,
    labelHeightInches: 1.0,
    columns: 4,
    rows: 10,
    isRoll: false,
    horizontalMarginInches: 0.25,
    verticalMarginInches: 0.5,
    horizontalGapInches: 0.0,
    verticalGapInches: 0.05,
  ),
  sheet50(
    name: '50 Labels per Sheet',
    description: 'Sheet: 8.5" x 11.5", Label: 1.5" x 1" (5 cols x 10 rows)',
    sheetWidthInches: 8.5,
    sheetHeightInches: 11.5,
    labelWidthInches: 1.5,
    labelHeightInches: 1.0,
    columns: 5,
    rows: 10,
    isRoll: false,
    horizontalMarginInches: 0.5,
    verticalMarginInches: 0.5,
    horizontalGapInches: 0.1,
    verticalGapInches: 0.05,
  ),
  continuousRoll3Inch(
    name: 'Continuous Roll 3" (Thermal)',
    description: 'Roll width: 31.75 mm x 25.40 mm, Gap: 3.18 mm',
    sheetWidthInches: 1.25,   // 31.75 mm
    sheetHeightInches: 1.0,   // 25.40 mm
    labelWidthInches: 1.25,
    labelHeightInches: 1.0,
    columns: 1,
    rows: 1,
    isRoll: true,
    horizontalMarginInches: 0.04,
    verticalMarginInches: 0.04,
    horizontalGapInches: 0.0,
    verticalGapInches: 0.125, // 3.18 mm
  );

  final String name;
  final String description;
  final double sheetWidthInches;
  final double sheetHeightInches;
  final double labelWidthInches;
  final double labelHeightInches;
  final int columns;
  final int rows;
  final bool isRoll;
  final double horizontalMarginInches;
  final double verticalMarginInches;
  final double horizontalGapInches;
  final double verticalGapInches;

  const LabelSheetPreset({
    required this.name,
    required this.description,
    required this.sheetWidthInches,
    required this.sheetHeightInches,
    required this.labelWidthInches,
    required this.labelHeightInches,
    required this.columns,
    required this.rows,
    required this.isRoll,
    required this.horizontalMarginInches,
    required this.verticalMarginInches,
    required this.horizontalGapInches,
    required this.verticalGapInches,
  });

  int get labelsPerPage => columns * rows;
  double get labelWidthPt => labelWidthInches * 72.0;
  double get labelHeightPt => labelHeightInches * 72.0;
  double get sheetWidthPt => sheetWidthInches * 72.0;
  double get sheetHeightPt => sheetHeightInches * 72.0;
  double get horizontalMarginPt => horizontalMarginInches * 72.0;
  double get verticalMarginPt => verticalMarginInches * 72.0;
  double get horizontalGapPt => horizontalGapInches * 72.0;
  double get verticalGapPt => verticalGapInches * 72.0;
}
