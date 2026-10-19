import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import '../../providers/procurement_provider.dart';
import '../../../suppliers/providers/suppliers_provider.dart';

class RfqCsvImportDialog extends ConsumerStatefulWidget {
  final bool isArabic;

  const RfqCsvImportDialog({
    super.key,
    required this.isArabic,
  });

  @override
  ConsumerState<RfqCsvImportDialog> createState() => _RfqCsvImportDialogState();
}

class _ParsedRfqRow {
  final String supplier;
  final String rfqNumber;
  final String refNo;
  final String itemDescription;
  final double quantity;
  final double unitPrice;
  final String validUntil;
  final String remarks;
  final bool isValid;
  final String? error;

  _ParsedRfqRow({
    required this.supplier,
    required this.rfqNumber,
    required this.refNo,
    required this.itemDescription,
    required this.quantity,
    required this.unitPrice,
    required this.validUntil,
    required this.remarks,
    required this.isValid,
    this.error,
  });
}

class _RfqCsvImportDialogState extends ConsumerState<RfqCsvImportDialog> {
  final TextEditingController _pasteController = TextEditingController();
  List<_ParsedRfqRow> _parsedRows = [];
  bool _isImporting = false;
  String? _parseErrorMessage;

  static const String sampleCsvTemplate =
      'Supplier,RFQ Number,Ref No,Item Description,Quantity,Unit Price,Valid Until,Remarks\n'
      'Al-Marai Dairy,RFQ-2026-001,REF-ALM-101,Fresh Milk 1L,100,5.50,2026-11-30,Chilled delivery required\n'
      'Al-Marai Dairy,RFQ-2026-001,REF-ALM-101,Greek Yogurt 500g,50,8.25,2026-11-30,Batch freshness guarantee\n'
      'Saudia Foods,RFQ-2026-002,SF-992,Tomato Paste Cans,200,3.10,2026-12-15,Carton packaging';

  @override
  void dispose() {
    _pasteController.dispose();
    super.dispose();
  }

  void _parseCsvString(String rawCsv) {
    if (rawCsv.trim().isEmpty) {
      setState(() {
        _parsedRows = [];
        _parseErrorMessage = null;
      });
      return;
    }

    try {
      final rows = Csv().decode(rawCsv);

      if (rows.isEmpty || rows.length <= 1) {
        setState(() {
          _parsedRows = [];
          _parseErrorMessage = widget.isArabic ? 'الملف لا يحتوي على صفوف بيانات' : 'CSV has no data rows';
        });
        return;
      }

      final dataRows = rows.skip(1);
      final List<_ParsedRfqRow> list = [];

      for (final row in dataRows) {
        if (row.isEmpty || (row.length == 1 && row[0].toString().trim().isEmpty)) {
          continue;
        }

        final supplier = row.isNotEmpty ? row[0].toString().trim() : '';
        final rfqNo = row.length > 1 ? row[1].toString().trim() : '';
        final refNo = row.length > 2 ? row[2].toString().trim() : '';
        final itemDesc = row.length > 3 ? row[3].toString().trim() : 'Quoted Item';
        final qty = row.length > 4 ? (double.tryParse(row[4].toString().trim()) ?? 1.0) : 1.0;
        final price = row.length > 5 ? (double.tryParse(row[5].toString().trim()) ?? 0.0) : 0.0;
        final validUntil = row.length > 6 ? row[6].toString().trim() : '';
        final remarks = row.length > 7 ? row[7].toString().trim() : '';

        String? err;
        if (supplier.isEmpty) {
          err = widget.isArabic ? 'اسم المورد مفقود' : 'Supplier is missing';
        } else if (price <= 0) {
          err = widget.isArabic ? 'السعر يجب أن يكون أكبر من صفر' : 'Unit price must be > 0';
        }

        list.add(_ParsedRfqRow(
          supplier: supplier,
          rfqNumber: rfqNo,
          refNo: refNo,
          itemDescription: itemDesc,
          quantity: qty,
          unitPrice: price,
          validUntil: validUntil,
          remarks: remarks,
          isValid: err == null,
          error: err,
        ));
      }

      setState(() {
        _parsedRows = list;
        _parseErrorMessage = list.isEmpty ? (widget.isArabic ? 'لا توجد صفوف صالحة' : 'No valid rows found') : null;
      });
    } catch (e) {
      setState(() {
        _parsedRows = [];
        _parseErrorMessage = '${widget.isArabic ? "خطأ في تحليل CSV: " : "CSV Parse Error: "}$e';
      });
    }
  }

  Future<void> _pickCsvFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final csvString = utf8.decode(bytes);
        _pasteController.text = csvString;
        _parseCsvString(csvString);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.isArabic ? "فشل فتح الملف: " : "Error reading file: "}$e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  Future<void> _executeImport() async {
    final validRows = _parsedRows.where((r) => r.isValid).toList();
    if (validRows.isEmpty) return;

    setState(() => _isImporting = true);

    try {
      final suppliersAsync = ref.read(suppliersProvider);
      final existingSuppliers = suppliersAsync.asData?.value ?? [];

      // Group rows by Supplier + RFQ Number
      final Map<String, List<_ParsedRfqRow>> grouped = {};
      for (final row in validRows) {
        final key = '${row.supplier.toLowerCase()}:::${row.rfqNumber.toLowerCase()}';
        grouped.putIfAbsent(key, () => []).add(row);
      }

      int createdCount = 0;
      final service = ref.read(procurementServiceProvider);

      for (final entry in grouped.entries) {
        final group = entry.value;
        final first = group.first;

        // Try to match supplier ID from existing suppliers list
        final matchedSupplier = existingSuppliers.where(
          (s) => s.name.trim().toLowerCase() == first.supplier.trim().toLowerCase(),
        ).firstOrNull;

        final supplierId = matchedSupplier?.id ?? 'sup-custom';

        final itemsPayload = group.map((item) => {
          'description': item.itemDescription,
          'quantity': item.quantity,
          'unitPrice': item.unitPrice,
          'vatRate': 15.0,
        }).toList();

        final payload = {
          'supplierId': supplierId,
          'supplierName': first.supplier,
          if (first.rfqNumber.isNotEmpty) 'quotationNumber': first.rfqNumber,
          if (first.refNo.isNotEmpty) 'supplierRefNo': first.refNo,
          if (first.validUntil.isNotEmpty) 'validUntil': first.validUntil,
          'remarks': first.remarks.isNotEmpty ? first.remarks : 'Imported via bulk CSV',
          'items': itemsPayload,
        };

        await service.createQuotation(payload);
        createdCount++;
      }

      ref.invalidate(supplierQuotationsProvider);
      ref.invalidate(suppliersProvider);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isArabic
                  ? 'تم استيراد $createdCount عرض سعر مورد بنجاح (${validRows.length} صنف)!'
                  : 'Successfully imported $createdCount RFQ(s) with ${validRows.length} item(s)!',
            ),
            backgroundColor: Colors.green.shade800,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.isArabic ? "خطأ أثناء الاستيراد: " : "Import error: "}$e'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = widget.isArabic;
    final validCount = _parsedRows.where((r) => r.isValid).length;
    final invalidCount = _parsedRows.length - validCount;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 860,
        constraints: const BoxConstraints(maxHeight: 760),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.upload_file_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'استيراد عروض أسعار الموردين (CSV Import)' : 'Import Supplier Quotations (CSV)',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        Text(
                          isAr
                              ? 'قم برفع ملف CSV أو لصق محتواه لاستيراد عروض الأسعار والأصناف دفعة واحدة'
                              : 'Upload a CSV file or paste content to import RFQs and line items in bulk',
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Action Buttons: Pick File & Copy Template
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isImporting ? null : _pickCsvFile,
                          icon: const Icon(Icons.file_open_rounded, size: 18),
                          label: Text(isAr ? 'اختيار ملف CSV من الجهاز' : 'Upload CSV File'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            Clipboard.setData(const ClipboardData(text: sampleCsvTemplate));
                            _pasteController.text = sampleCsvTemplate;
                            _parseCsvString(sampleCsvTemplate);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isAr
                                      ? 'تم نسخ ولصق نموذج CSV النموذجي للمعاينة'
                                      : 'Sample CSV copied & loaded into preview!',
                                ),
                                backgroundColor: Colors.indigo.shade800,
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          label: Text(isAr ? 'تحميل / نسخ نموذج تجريبي' : 'Load Sample Template'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Paste Text Area
                    Text(
                      isAr ? 'أو قم بلصق بيانات CSV هنا:' : 'Or paste CSV text directly below:',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _pasteController,
                      maxLines: 4,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                      decoration: InputDecoration(
                        hintText: isAr
                          ? 'Supplier,RFQ Number,Ref No,Item Description,Quantity,Unit Price,Valid Until,Remarks...'
                          : 'Supplier,RFQ Number,Ref No,Item Description,Quantity,Unit Price,Valid Until,Remarks...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      onChanged: _parseCsvString,
                    ),

                    if (_parseErrorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _parseErrorMessage!,
                        style: TextStyle(color: Colors.red.shade700, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Preview Section
                    if (_parsedRows.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                isAr ? 'معاينة البيانات المستخرجة' : 'Parsed Records Preview',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.green.shade300),
                                ),
                                child: Text(
                                  '$validCount ${isAr ? "صالح" : "Valid"}',
                                  style: TextStyle(
                                      color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                              ),
                              if (invalidCount > 0) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.red.shade300),
                                  ),
                                  child: Text(
                                    '$invalidCount ${isAr ? "تحذير / أخطاء" : "Errors"}',
                                    style: TextStyle(
                                        color: Colors.red.shade800, fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            isAr ? 'إجمالي الصفوف: ${_parsedRows.length}' : 'Total Rows: ${_parsedRows.length}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                              columnSpacing: 16,
                              columns: [
                                DataColumn(label: Text(isAr ? 'الحالة' : 'Status')),
                                DataColumn(label: Text(isAr ? 'المورد' : 'Supplier')),
                                DataColumn(label: Text(isAr ? 'رقم RFQ' : 'RFQ #')),
                                DataColumn(label: Text(isAr ? 'الرقم المرجعي' : 'Ref #')),
                                DataColumn(label: Text(isAr ? 'الصنف' : 'Item Description')),
                                DataColumn(label: Text(isAr ? 'الكمية' : 'Qty'), numeric: true),
                                DataColumn(label: Text(isAr ? 'السعر (ر.س)' : 'Price (SAR)'), numeric: true),
                                DataColumn(label: Text(isAr ? 'صالح حتى' : 'Valid Until')),
                              ],
                              rows: _parsedRows.map((row) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      row.isValid
                                          ? const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18)
                                          : Tooltip(
                                              message: row.error ?? 'Invalid',
                                              child: const Icon(Icons.error_outline_rounded, color: Colors.red, size: 18),
                                            ),
                                    ),
                                    DataCell(Text(row.supplier, style: const TextStyle(fontWeight: FontWeight.w600))),
                                    DataCell(Text(row.rfqNumber.isNotEmpty ? row.rfqNumber : '-')),
                                    DataCell(Text(row.refNo.isNotEmpty ? row.refNo : '-')),
                                    DataCell(Text(row.itemDescription)),
                                    DataCell(Text('${row.quantity}')),
                                    DataCell(Text(row.unitPrice.toStringAsFixed(2))),
                                    DataCell(Text(row.validUntil.isNotEmpty ? row.validUntil : '-')),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    validCount > 0
                        ? (isAr ? 'جاهز لاستيراد $validCount صنف' : 'Ready to import $validCount item(s)')
                        : '',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _isImporting ? null : () => Navigator.of(context).pop(),
                        child: Text(isAr ? 'إلغاء' : 'Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _isImporting || validCount == 0 ? null : _executeImport,
                        icon: _isImporting
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.cloud_upload_rounded, size: 18),
                        label: Text(
                          _isImporting
                              ? (isAr ? 'جاري الاستيراد...' : 'Importing...')
                              : (isAr ? 'تأكيد واستيراد ($validCount)' : 'Confirm & Import ($validCount)'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
