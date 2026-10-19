import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../domain/label_print_model.dart';

class LabelPdfGenerator {
  /// Generates the complete PDF document bytes containing the requested labels.
  static Future<Uint8List> generateLabelsDoc({
    required List<LabelItem> items,
    required LabelDisplaySettings settings,
    required LabelSheetPreset preset,
  }) async {
    final pdf = pw.Document();

    // 1. Unroll items into individual label instances based on copiesCount
    final unrolledLabels = <LabelItem>[];
    for (final item in items) {
      for (int i = 0; i < item.copiesCount; i++) {
        unrolledLabels.add(item);
      }
    }

    if (unrolledLabels.isEmpty) {
      // Create empty placeholder page if no items
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(preset.sheetWidthPt, preset.sheetHeightPt),
          build: (ctx) => pw.Center(
            child: pw.Text('No products selected for label printing', style: const pw.TextStyle(fontSize: 16)),
          ),
        ),
      );
      return pdf.save();
    }

    if (preset.isRoll) {
      // ─────────────────────────────────────────────
      // CONTINUOUS ROLL (1 Label per Page)
      // ─────────────────────────────────────────────
      for (final item in unrolledLabels) {
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat(
              preset.labelWidthPt,
              preset.labelHeightPt,
              marginLeft: preset.horizontalMarginPt,
              marginRight: preset.horizontalMarginPt,
              marginTop: preset.verticalMarginPt,
              marginBottom: preset.verticalMarginPt,
            ),
            build: (ctx) => pw.Container(
              width: preset.labelWidthPt,
              height: preset.labelHeightPt,
              child: _buildSingleLabel(item, settings, preset),
            ),
          ),
        );
      }
    } else {
      // ─────────────────────────────────────────────
      // SHEET PRINTING (Grid of Labels per Sheet Page)
      // ─────────────────────────────────────────────
      final labelsPerPage = preset.labelsPerPage;
      final totalPages = (unrolledLabels.length / labelsPerPage).ceil();

      for (int pageIdx = 0; pageIdx < totalPages; pageIdx++) {
        final startIdx = pageIdx * labelsPerPage;
        final endIdx = (startIdx + labelsPerPage < unrolledLabels.length)
            ? startIdx + labelsPerPage
            : unrolledLabels.length;
        final pageLabels = unrolledLabels.sublist(startIdx, endIdx);

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat(
              preset.sheetWidthPt,
              preset.sheetHeightPt,
              marginLeft: preset.horizontalMarginPt,
              marginRight: preset.horizontalMarginPt,
              marginTop: preset.verticalMarginPt,
              marginBottom: preset.verticalMarginPt,
            ),
            build: (ctx) {
              return pw.Column(
                children: List.generate(preset.rows, (rowIdx) {
                  return pw.Padding(
                    padding: pw.EdgeInsets.only(
                      bottom: rowIdx < preset.rows - 1 ? preset.verticalGapPt : 0,
                    ),
                    child: pw.Row(
                      children: List.generate(preset.columns, (colIdx) {
                        final itemIdx = (rowIdx * preset.columns) + colIdx;
                        final hasItem = itemIdx < pageLabels.length;

                        return pw.Padding(
                          padding: pw.EdgeInsets.only(
                            right: colIdx < preset.columns - 1 ? preset.horizontalGapPt : 0,
                          ),
                          child: pw.Container(
                            width: preset.labelWidthPt,
                            height: preset.labelHeightPt,
                            child: hasItem
                                ? _buildSingleLabel(pageLabels[itemIdx], settings, preset)
                                : pw.SizedBox(),
                          ),
                        );
                      }),
                    ),
                  );
                }),
              );
            },
          ),
        );
      }
    }

    return pdf.save();
  }

  /// Builds the content of an individual adhesive label.
  static pw.Widget _buildSingleLabel(
    LabelItem item,
    LabelDisplaySettings settings,
    LabelSheetPreset preset,
  ) {
    final barcodeData = _getCompositeBarcode(item, settings);
    final isCompact = preset.labelHeightInches <= 1.0;
    final isWide = preset.labelWidthInches >= 3.0;

    // Font sizing scaled by label height
    final double titleFontSize = isCompact ? 6.5 : 8.0;
    final double smallFontSize = isCompact ? 5.0 : 6.0;
    final double priceFontSize = isCompact ? 7.0 : 9.0;
    final double barcodeHeight = isCompact ? 16.0 : 28.0;

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 2),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 0.4),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
      ),
      child: isWide
          ? _buildWideLabelLayout(
              item: item,
              settings: settings,
              preset: preset,
              barcodeData: barcodeData,
              titleFontSize: titleFontSize,
              smallFontSize: smallFontSize,
              priceFontSize: priceFontSize,
              barcodeHeight: barcodeHeight,
            )
          : _buildStandardLabelLayout(
              item: item,
              settings: settings,
              preset: preset,
              barcodeData: barcodeData,
              titleFontSize: titleFontSize,
              smallFontSize: smallFontSize,
              priceFontSize: priceFontSize,
              barcodeHeight: barcodeHeight,
            ),
    );
  }

  /// Horizontal dual-pane layout for wide labels (e.g. 4" x 1")
  static pw.Widget _buildWideLabelLayout({
    required LabelItem item,
    required LabelDisplaySettings settings,
    required LabelSheetPreset preset,
    required String barcodeData,
    required double titleFontSize,
    required double smallFontSize,
    required double priceFontSize,
    required double barcodeHeight,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        // Left Column: Shop & Product details
        pw.Expanded(
          flex: 5,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // Shop Header
              if (settings.showShopName || settings.showShopPhone)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    if (settings.showShopName)
                      pw.Text(
                        settings.shopName,
                        style: pw.TextStyle(fontSize: smallFontSize, fontWeight: pw.FontWeight.bold),
                        maxLines: 1,
                      ),
                    if (settings.showShopPhone)
                      pw.Text(
                        settings.shopPhone,
                        style: pw.TextStyle(fontSize: smallFontSize, color: PdfColors.grey700),
                      ),
                  ],
                ),

              // Product Name & Variant
              if (settings.showProductName)
                pw.Text(
                  item.variantAttrs != null
                      ? '${item.productName} (${item.variantAttrs})'
                      : item.productName,
                  style: pw.TextStyle(fontSize: titleFontSize, fontWeight: pw.FontWeight.bold),
                  maxLines: 1,
                  overflow: pw.TextOverflow.clip,
                ),

              // Tracking details (HSN, Batch, Expiry)
              pw.Wrap(
                spacing: 4,
                children: [
                  if (settings.showHsnCode && item.hsnCode != null)
                    pw.Text('HSN:${item.hsnCode}', style: pw.TextStyle(fontSize: smallFontSize)),
                  if (settings.requireBatchNumber && item.batchNumber != null)
                    pw.Text('B:${item.batchNumber}', style: pw.TextStyle(fontSize: smallFontSize)),
                  if (settings.requireExpiryDate && item.expiryDate != null)
                    pw.Text('EXP:${_formatDate(item.expiryDate!)}', style: pw.TextStyle(fontSize: smallFontSize, fontWeight: pw.FontWeight.bold)),
                ],
              ),

              // Prices row
              _buildPriceSection(item, settings, priceFontSize, smallFontSize),
            ],
          ),
        ),

        pw.SizedBox(width: 4),

        // Right Column: Barcode / QR Code
        pw.Expanded(
          flex: 4,
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              if (settings.showBarcode)
                pw.Expanded(
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.code128(),
                    data: barcodeData,
                    drawText: false,
                    width: double.infinity,
                  ),
                ),
              if (settings.showBarcodeText)
                pw.Text(
                  item.barcode,
                  style: pw.TextStyle(fontSize: smallFontSize, fontWeight: pw.FontWeight.bold),
                ),
            ],
          ),
        ),

        // Optional QR Code
        if (settings.showQrCode) ...[
          pw.SizedBox(width: 4),
          pw.Container(
            width: 32,
            height: 32,
            child: pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(),
              data: barcodeData,
              drawText: false,
            ),
          ),
        ],
      ],
    );
  }

  /// Vertical stacked layout for square or compact labels (2"x1", 2"x2", 1.5"x1", 3" roll)
  static pw.Widget _buildStandardLabelLayout({
    required LabelItem item,
    required LabelDisplaySettings settings,
    required LabelSheetPreset preset,
    required String barcodeData,
    required double titleFontSize,
    required double smallFontSize,
    required double priceFontSize,
    required double barcodeHeight,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        // Shop Name
        if (settings.showShopName)
          pw.Text(
            settings.shopName,
            style: pw.TextStyle(fontSize: smallFontSize, fontWeight: pw.FontWeight.bold),
            maxLines: 1,
            textAlign: pw.TextAlign.center,
          ),

        // Product Name
        if (settings.showProductName)
          pw.Text(
            item.variantAttrs != null
                ? '${item.productName} (${item.variantAttrs})'
                : item.productName,
            style: pw.TextStyle(fontSize: titleFontSize, fontWeight: pw.FontWeight.bold),
            maxLines: 1,
            textAlign: pw.TextAlign.center,
            overflow: pw.TextOverflow.clip,
          ),

        // 1D Barcode & QR Code Section
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            if (settings.showBarcode)
              pw.Expanded(
                child: pw.Container(
                  height: barcodeHeight,
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.code128(),
                    data: barcodeData,
                    drawText: false,
                  ),
                ),
              ),
            if (settings.showQrCode)
              pw.Container(
                width: barcodeHeight,
                height: barcodeHeight,
                margin: const pw.EdgeInsets.only(left: 3),
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: barcodeData,
                  drawText: false,
                ),
              ),
          ],
        ),

        // Barcode Value Text
        if (settings.showBarcodeText)
          pw.Text(
            item.barcode,
            style: pw.TextStyle(fontSize: smallFontSize, fontWeight: pw.FontWeight.bold),
          ),

        // Tracking Row (Batch / Expiry / HSN)
        if (settings.showHsnCode || settings.requireExpiryDate || settings.requireBatchNumber)
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              if (settings.showHsnCode && item.hsnCode != null)
                pw.Text('HSN:${item.hsnCode}', style: pw.TextStyle(fontSize: smallFontSize)),
              if (settings.requireBatchNumber && item.batchNumber != null)
                pw.Text('B:${item.batchNumber}', style: pw.TextStyle(fontSize: smallFontSize)),
              if (settings.requireExpiryDate && item.expiryDate != null)
                pw.Text('EXP:${_formatDate(item.expiryDate!)}', style: pw.TextStyle(fontSize: smallFontSize, fontWeight: pw.FontWeight.bold)),
            ],
          ),

        // Price Row
        _buildPriceSection(item, settings, priceFontSize, smallFontSize),

        // Dimensions indicator if enabled
        if (settings.showLabelDimensions)
          pw.Text(
            '${preset.labelWidthInches}" x ${preset.labelHeightInches}"',
            style: const pw.TextStyle(fontSize: 4.5, color: PdfColors.grey500),
          ),
      ],
    );
  }

  /// Price display section supporting Retail, Wholesale, and Discount pricing
  static pw.Widget _buildPriceSection(
    LabelItem item,
    LabelDisplaySettings settings,
    double priceFontSize,
    double smallFontSize,
  ) {
    final prices = <pw.Widget>[];

    if (settings.showRetailPrice) {
      prices.add(
        pw.Text(
          '${settings.currencySymbol} ${item.retailPrice.toStringAsFixed(2)}',
          style: pw.TextStyle(fontSize: priceFontSize, fontWeight: pw.FontWeight.bold),
        ),
      );
    }

    if (settings.showWholesalePrice && item.wholesalePrice != null) {
      prices.add(
        pw.Text(
          'W/S: ${item.wholesalePrice!.toStringAsFixed(2)}',
          style: pw.TextStyle(fontSize: smallFontSize, color: PdfColors.grey800),
        ),
      );
    }

    if (settings.showDiscountPrice && item.discountPrice != null) {
      prices.add(
        pw.Text(
          'Sale: ${item.discountPrice!.toStringAsFixed(2)}',
          style: pw.TextStyle(fontSize: smallFontSize, color: PdfColors.red700, fontWeight: pw.FontWeight.bold),
        ),
      );
    }

    if (prices.isEmpty) return pw.SizedBox();

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: prices,
    );
  }

  /// Builds composite barcode string according to printlebel.md validation rules:
  /// "if is expiry date required and is batch number required and is serial number required:
  /// in barcode include product id, batch number, expiry date, serial number"
  static String _getCompositeBarcode(LabelItem item, LabelDisplaySettings settings) {
    if (!settings.requireBatchNumber && !settings.requireExpiryDate && !settings.requireSerialNumber) {
      return item.barcode;
    }

    final parts = <String>[item.barcode];
    if (settings.requireBatchNumber && item.batchNumber != null) {
      parts.add(item.batchNumber!);
    }
    if (settings.requireExpiryDate && item.expiryDate != null) {
      parts.add(_formatDate(item.expiryDate!));
    }
    if (settings.requireSerialNumber && item.serialNumber != null) {
      parts.add(item.serialNumber!);
    }

    return parts.join('|');
  }

  static String _formatDate(DateTime dt) {
    final y = dt.year.toString();
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
