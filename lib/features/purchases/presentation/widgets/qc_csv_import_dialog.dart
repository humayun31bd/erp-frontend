import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import '../../providers/procurement_provider.dart';

class QcCsvImportDialog extends ConsumerStatefulWidget {
  final bool isArabic;

  const QcCsvImportDialog({
    super.key,
    required this.isArabic,
  });

  @override
  ConsumerState<QcCsvImportDialog> createState() => _QcCsvImportDialogState();
}

class _ParsedQcRow {
  final String grnNumber;
  final String inspector;
  final String itemDescription;
  final double receivedQty;
  final double acceptedQty;
  final double rejectedQty;
  final double exchangedQty;
  final String defectReason;
  final String remarks;
  final bool isValid;
  final String? error;

  _ParsedQcRow({
    required this.grnNumber,
    required this.inspector,
    required this.itemDescription,
    required this.receivedQty,
    required this.acceptedQty,
    required this.rejectedQty,
    required this.exchangedQty,
    required this.defectReason,
    required this.remarks,
    required this.isValid,
    this.error,
  });
}

class _QcCsvImportDialogState extends ConsumerState<QcCsvImportDialog> {
  final TextEditingController _pasteController = TextEditingController();
  List<_ParsedQcRow> _parsedRows = [];
  bool _isImporting = false;
  String? _parseErrorMessage;

  static const String sampleCsvTemplate =
      'GRN Number,Inspector,Item Description,Received Qty,Accepted Qty,Rejected Qty,Exchanged Qty,Defect Reason,Remarks\n'
      'GRN-2026-001,Eng. Ahmed,Fresh Milk 1L,100,98,2,0,Packaging puncture,Cold-chain inspection\n'
      'GRN-2026-001,Eng. Ahmed,Greek Yogurt 500g,50,50,0,0,,Batch expiry checked\n'
      'GRN-2026-002,Eng. Youssef,Tomato Paste Cans,200,195,5,0,Can denting,Damaged carton returned';

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
      final List<_ParsedQcRow> list = [];

      for (final row in dataRows) {
        if (row.isEmpty || (row.length == 1 && row[0].toString().trim().isEmpty)) {
          continue;
        }

        final grnNo = row.isNotEmpty ? row[0].toString().trim() : '';
        final inspector = row.length > 1 ? row[1].toString().trim() : 'QC Inspector';
        final itemDesc = row.length > 2 ? row[2].toString().trim() : 'Inspected Goods';
        final recQty = row.length > 3 ? (double.tryParse(row[3].toString().trim()) ?? 10.0) : 10.0;
        final accQty = row.length > 4 ? (double.tryParse(row[4].toString().trim()) ?? 10.0) : 10.0;
        final rejQty = row.length > 5 ? (double.tryParse(row[5].toString().trim()) ?? 0.0) : 0.0;
        final excQty = row.length > 6 ? (double.tryParse(row[6].toString().trim()) ?? 0.0) : 0.0;
        final defectReason = row.length > 7 ? row[7].toString().trim() : '';
        final remarks = row.length > 8 ? row[8].toString().trim() : '';

        String? err;
        if (grnNo.isEmpty) {
          err = widget.isArabic ? 'رقم GRN مفقود' : 'GRN # is missing';
        } else if (recQty <= 0) {
          err = widget.isArabic ? 'الكمية المستلمة يجب أن تكون أكبر من صفر' : 'Received qty must be > 0';
        }

        list.add(_ParsedQcRow(
          grnNumber: grnNo,
          inspector: inspector,
          itemDescription: itemDesc,
          receivedQty: recQty,
          acceptedQty: accQty,
          rejectedQty: rejQty,
          exchangedQty: excQty,
          defectReason: defectReason,
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
      final grnAsync = ref.read(goodsReceivedNotesProvider);
      final existingGrns = grnAsync.asData?.value ?? [];

      // Group rows by GRN Number + Inspector
      final Map<String, List<_ParsedQcRow>> grouped = {};
      for (final row in validRows) {
        final key = '${row.grnNumber.toLowerCase()}:::${row.inspector.toLowerCase()}';
        grouped.putIfAbsent(key, () => []).add(row);
      }

      int createdCount = 0;
      final service = ref.read(procurementServiceProvider);

      for (final entry in grouped.entries) {
        final group = entry.value;
        final first = group.first;

        // Find matching GRN by number or ID
        final matchedGrn = existingGrns.where(
          (g) => g.grnNumber.trim().toLowerCase() == first.grnNumber.trim().toLowerCase() ||
                 g.id == first.grnNumber,
        ).firstOrNull;

        final grnId = matchedGrn?.id ?? (existingGrns.isNotEmpty ? existingGrns.first.id : 'grn-custom');
        final grnNumber = matchedGrn?.grnNumber ?? first.grnNumber;

        final itemsPayload = group.map((item) => {
          'description': item.itemDescription,
          'receivedQuantity': item.receivedQty,
          'acceptedQuantity': item.acceptedQty,
          'rejectedQuantity': item.rejectedQty,
          'exchangedQuantity': item.exchangedQty,
          'defectReason': item.defectReason,
        }).toList();

        final payload = {
          'grnId': grnId,
          'grnNumber': grnNumber,
          'inspectorName': first.inspector,
          'checkDate': DateTime.now().toIso8601String(),
          'remarks': first.remarks.isNotEmpty ? first.remarks : 'Imported via bulk CSV',
          'items': itemsPayload,
        };

        await service.createQualityCheck(payload);
        createdCount++;
      }

      ref.invalidate(qualityChecksProvider);
      ref.invalidate(goodsReceivedNotesProvider);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isArabic
                  ? 'تم استيراد $createdCount سجل فحص جودة بنجاح (${validRows.length} صنف)!'
                  : 'Successfully imported $createdCount QC inspections with ${validRows.length} item(s)!',
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
                      color: Colors.teal.shade700,
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
                          isAr ? 'استيراد فحوصات الجودة (CSV Import)' : 'Import Quality Checks from CSV',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        Text(
                          isAr
                              ? 'قم برفع ملف CSV أو لصق بيانات الفحوصات لاستيراد نتائج الفحص دفعة واحدة'
                              : 'Upload CSV or paste lines to import batch inspection records instantly',
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
                            backgroundColor: Colors.teal.shade700,
                            foregroundColor: Colors.white,
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
                                      ? 'تم نسخ ولصق نموذج QC التجريبي للمعاينة'
                                      : 'Sample QC CSV copied & loaded into preview!',
                                ),
                                backgroundColor: Colors.teal.shade800,
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          label: Text(isAr ? 'تحميل نموذج تجريبي' : 'Load Sample Template'),
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
                        hintText: 'GRN Number,Inspector,Item Description,Received Qty,Accepted Qty,Rejected Qty,Exchanged Qty,Defect Reason,Remarks...',
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
                                DataColumn(label: Text(isAr ? 'رقم GRN' : 'GRN #')),
                                DataColumn(label: Text(isAr ? 'المفتش' : 'Inspector')),
                                DataColumn(label: Text(isAr ? 'الصنف' : 'Item Description')),
                                DataColumn(label: Text(isAr ? 'مستلم' : 'Rec'), numeric: true),
                                DataColumn(label: Text(isAr ? 'مقبول' : 'Acc'), numeric: true),
                                DataColumn(label: Text(isAr ? 'مرفوض' : 'Rej'), numeric: true),
                                DataColumn(label: Text(isAr ? 'عيب' : 'Defect Reason')),
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
                                    DataCell(Text(row.grnNumber, style: const TextStyle(fontWeight: FontWeight.bold))),
                                    DataCell(Text(row.inspector)),
                                    DataCell(Text(row.itemDescription)),
                                    DataCell(Text('${row.receivedQty}')),
                                    DataCell(Text('${row.acceptedQty}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                                    DataCell(Text('${row.rejectedQty}', style: TextStyle(color: row.rejectedQty > 0 ? Colors.red : Colors.grey))),
                                    DataCell(Text(row.defectReason.isNotEmpty ? row.defectReason : '-')),
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
                          backgroundColor: Colors.teal.shade700,
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
