import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/procurement_document_formatter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import '../../providers/procurement_provider.dart';
import '../../../suppliers/providers/suppliers_provider.dart';

class BillCsvImportDialog extends ConsumerStatefulWidget {
  final bool isArabic;

  const BillCsvImportDialog({
    super.key,
    required this.isArabic,
  });

  @override
  ConsumerState<BillCsvImportDialog> createState() => _BillCsvImportDialogState();
}

class _ParsedBillRow {
  final String supplierId;
  final String supplierName;
  final String? poId;
  final String? grnId;
  final DateTime issueDate;
  final DateTime? dueDate;
  final double subtotalAmount;
  final double vatAmount;
  final double totalAmount;
  final String remarks;
  final bool isValid;
  final String? error;

  _ParsedBillRow({
    required this.supplierId,
    required this.supplierName,
    this.poId,
    this.grnId,
    required this.issueDate,
    this.dueDate,
    required this.subtotalAmount,
    required this.vatAmount,
    required this.totalAmount,
    required this.remarks,
    required this.isValid,
    this.error,
  });
}

class _BillCsvImportDialogState extends ConsumerState<BillCsvImportDialog> {
  final TextEditingController _pasteController = TextEditingController();
  List<_ParsedBillRow> _parsedRows = [];
  bool _isImporting = false;
  String? _parseErrorMessage;
  int _importedCount = 0;

  static const String sampleCsvTemplate =
      'Supplier Code,Supplier Name,PO Number,GRN Number,Issue Date,Due Date,Subtotal Amount,VAT Amount,Remarks\n'
      'SUP-001,Al-Marai Dairy,PO-2026-001,GRN-2026-001,2026-10-10,2026-11-10,5000,750,Monthly bulk dairy consignment\n'
      'SUP-002,Saudia National Foods,PO-2026-002,,2026-10-12,2026-11-12,12000,1800,Canned goods supply batch #41\n'
      'SUP-003,Nadec Agriculture,,,2026-10-13,2026-11-13,3500,,Fresh produce deliveries';

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

      final suppliersList = ref.read(suppliersProvider).value ?? [];
      final dataRows = rows.skip(1);
      final List<_ParsedBillRow> list = [];

      for (final row in dataRows) {
        if (row.isEmpty || (row.length == 1 && row[0].toString().trim().isEmpty)) {
          continue;
        }

        final rawSupplierId = row.isNotEmpty ? row[0].toString().trim() : '';
        var supplierName = row.length > 1 ? row[1].toString().trim() : '';
        final poNo = row.length > 2 ? row[2].toString().trim() : '';
        final grnNo = row.length > 3 ? row[3].toString().trim() : '';
        final rawIssueDate = row.length > 4 ? row[4].toString().trim() : '';
        final rawDueDate = row.length > 5 ? row[5].toString().trim() : '';
        final rawSubtotal = row.length > 6 ? row[6].toString().trim() : '0';
        final rawVat = row.length > 7 ? row[7].toString().trim() : '';
        final remarks = row.length > 8 ? row[8].toString().trim() : '';

        // Match supplier from database if possible
        String finalSupplierId = rawSupplierId;
        if (suppliersList.isNotEmpty) {
          final matched = suppliersList.firstWhere(
            (s) =>
                s.id.toLowerCase() == rawSupplierId.toLowerCase() ||
                s.name.toLowerCase() == rawSupplierId.toLowerCase() ||
                s.name.toLowerCase() == supplierName.toLowerCase(),
            orElse: () => suppliersList.first,
          );
          if (finalSupplierId.isEmpty && supplierName.isNotEmpty) {
            finalSupplierId = matched.id;
          }
          if (supplierName.isEmpty) {
            supplierName = matched.name;
          }
        }

        final subtotal = double.tryParse(rawSubtotal) ?? 0.0;
        double vat = double.tryParse(rawVat) ?? 0.0;
        if (vat <= 0.0 && subtotal > 0.0) {
          vat = subtotal * 0.15;
        }
        final total = subtotal + vat;

        DateTime issueDate = DateTime.now();
        if (rawIssueDate.isNotEmpty) {
          issueDate = DateTime.tryParse(rawIssueDate) ?? DateTime.now();
        }

        DateTime? dueDate;
        if (rawDueDate.isNotEmpty) {
          dueDate = DateTime.tryParse(rawDueDate);
        }

        bool isValid = true;
        String? errorMsg;

        if (finalSupplierId.isEmpty && supplierName.isEmpty) {
          isValid = false;
          errorMsg = widget.isArabic ? 'اسم أو كود المورد مطلوب' : 'Supplier Code or Name required';
        } else if (subtotal <= 0.0) {
          isValid = false;
          errorMsg = widget.isArabic ? 'المبلغ الفرعي يجب أن يكون أكبر من 0' : 'Subtotal must be greater than 0';
        }

        list.add(_ParsedBillRow(
          supplierId: finalSupplierId.isNotEmpty ? finalSupplierId : 'SUP-DEFAULT',
          supplierName: supplierName.isNotEmpty ? supplierName : 'Supplier',
          poId: poNo.isNotEmpty ? poNo : null,
          grnId: grnNo.isNotEmpty ? grnNo : null,
          issueDate: issueDate,
          dueDate: dueDate,
          subtotalAmount: subtotal,
          vatAmount: vat,
          totalAmount: total,
          remarks: remarks,
          isValid: isValid,
          error: errorMsg,
        ));
      }

      setState(() {
        _parsedRows = list;
        _parseErrorMessage = null;
      });
    } catch (e) {
      setState(() {
        _parsedRows = [];
        _parseErrorMessage = '${widget.isArabic ? 'خطأ في معالجة البيانات:' : 'Failed to parse CSV:'} $e';
      });
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        String content = '';
        if (file.bytes != null) {
          content = utf8.decode(file.bytes!);
        }
        _pasteController.text = content;
        _parseCsvString(content);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isArabic ? 'فشل قراءة الملف: $e' : 'Failed to pick file: $e'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    }
  }

  void _copyTemplate() {
    Clipboard.setData(const ClipboardData(text: sampleCsvTemplate));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isArabic
              ? 'تم نسخ قالب استيراد فواتير الموردين إلى الحافظة'
              : 'Supplier Bills CSV template copied to clipboard',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _submitImport() async {
    final validRows = _parsedRows.where((r) => r.isValid).toList();
    if (validRows.isEmpty) return;

    setState(() {
      _isImporting = true;
      _importedCount = 0;
    });

    int successCount = 0;
    int failedCount = 0;

    for (final row in validRows) {
      final payload = {
        'supplierId': row.supplierId,
        'supplierName': row.supplierName,
        'poId': row.poId,
        'grnId': row.grnId,
        'issueDate': row.issueDate.toIso8601String(),
        'dueDate': row.dueDate?.toIso8601String(),
        'subtotalAmount': row.subtotalAmount,
        'vatAmount': row.vatAmount,
        'totalAmount': row.totalAmount,
        'remarks': row.remarks.isNotEmpty ? row.remarks : 'Imported via CSV',
      };

      try {
        await ref.read(procurementServiceProvider).createSupplierBill(payload);
        successCount++;
      } catch (e) {
        failedCount++;
      }

      setState(() {
        _importedCount = successCount + failedCount;
      });
    }

    ref.invalidate(supplierBillsProvider);

    if (mounted) {
      setState(() => _isImporting = false);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isArabic
                ? 'اكتمل الاستيراد: تم إنشاء $successCount فاتورة بنجاح${failedCount > 0 ? ' (فشل $failedCount)' : ''}'
                : 'Import complete: $successCount bills recorded successfully${failedCount > 0 ? ' ($failedCount failed)' : ''}',
          ),
          backgroundColor: successCount > 0 ? Colors.green.shade800 : Colors.red.shade800,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isArabic;
    final validRowsCount = _parsedRows.where((r) => r.isValid).length;
    final totalSum = _parsedRows.where((r) => r.isValid).fold<double>(0.0, (sum, r) => sum + r.totalAmount);

    final dateFormat = DateFormat('yyyy-MM-dd');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 860,
        constraints: const BoxConstraints(maxHeight: 740),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(bottom: BorderSide(color: Colors.indigo.shade100)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.indigo.shade700,
                    child: const Icon(Icons.file_upload, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'استيراد فواتير الموردين من ملف CSV' : 'Import Supplier Bills from CSV',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade900,
                          ),
                        ),
                        Text(
                          isAr
                              ? 'استيراد فواتير الذمم الدائنة دفعة واحدة مع التحقق التلقائي واحتساب الضريبة'
                              : 'Batch import AP bills with automatic validation and 15% VAT calculation',
                          style: TextStyle(color: Colors.indigo.shade700, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _isImporting ? null : () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Main Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Action Buttons Row
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isImporting ? null : _pickFile,
                          icon: const Icon(Icons.folder_open, size: 18),
                          label: Text(isAr ? 'اختيار ملف CSV' : 'Choose CSV File'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo.shade700,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: _copyTemplate,
                          icon: const Icon(Icons.copy, size: 18),
                          label: Text(isAr ? 'نسخ قالب CSV' : 'Copy Sample Template'),
                        ),
                        const Spacer(),
                        if (_parsedRows.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: validRowsCount > 0 ? Colors.green.shade50 : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: validRowsCount > 0 ? Colors.green.shade200 : Colors.red.shade200,
                              ),
                            ),
                            child: Text(
                              '$validRowsCount ${isAr ? 'فاتورة صالحة' : 'Valid Bills'} • SAR ${totalSum.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: validRowsCount > 0 ? Colors.green.shade800 : Colors.red.shade800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Paste Text Area
                    TextField(
                      controller: _pasteController,
                      maxLines: 4,
                      style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                      decoration: InputDecoration(
                        hintText: isAr
                            ? 'أو الصق نص CSV هنا مباشرة...\n$sampleCsvTemplate'
                            : 'Or paste CSV data directly here...\n$sampleCsvTemplate',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      onChanged: _parseCsvString,
                    ),

                    if (_parseErrorMessage != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, size: 16, color: Colors.red.shade800),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _parseErrorMessage!,
                                style: TextStyle(color: Colors.red.shade900, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Preview Section Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isAr ? 'معاينة صفوف الفواتير قبل الاعتماد:' : 'Pre-import Bills Preview:',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        if (_parsedRows.isNotEmpty)
                          Text(
                            '${_parsedRows.length} ${isAr ? 'إجمالي الصفوف' : 'total parsed rows'}',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Preview Table
                    Expanded(
                      child: _parsedRows.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.receipt, size: 48, color: Colors.grey.shade300),
                                  const SizedBox(height: 8),
                                  Text(
                                    isAr
                                        ? 'قم باختيار ملف أو لصق البيانات أعلاه للمعاينة'
                                        : 'Upload a file or paste CSV text above to preview rows',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                                      dataRowMinHeight: 40,
                                      dataRowMaxHeight: 44,
                                      columnSpacing: 18,
                                      columns: [
                                        const DataColumn(label: Text('#')),
                                        DataColumn(label: Text(isAr ? 'المورد' : 'Supplier')),
                                        DataColumn(label: Text(isAr ? 'أمر الشراء / GRN' : 'PO / GRN')),
                                        DataColumn(label: Text(isAr ? 'تاريخ الفاتورة' : 'Issue Date')),
                                        DataColumn(label: Text(isAr ? 'المجموع الفرعي' : 'Subtotal')),
                                        DataColumn(label: Text(isAr ? 'الضريبة (15%)' : 'VAT (15%)')),
                                        DataColumn(label: Text(isAr ? 'الإجمالي' : 'Total (SAR)')),
                                        DataColumn(label: Text(isAr ? 'الحالة' : 'Status')),
                                      ],
                                      rows: _parsedRows.asMap().entries.map((entry) {
                                        final idx = entry.key + 1;
                                        final r = entry.value;

                                        return DataRow(
                                          color: WidgetStateProperty.all(
                                            r.isValid ? Colors.white : Colors.red.shade50.withValues(alpha: 0.5),
                                          ),
                                          cells: [
                                            DataCell(Text('$idx')),
                                            DataCell(
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(r.supplierName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                                  Text(ProcurementDocumentFormatter.formatSupplierCode(r.supplierId), style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                                                ],
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                r.poId != null
                                                    ? 'PO: ${ProcurementDocumentFormatter.formatPoNumber(r.poId, r.poId)}'
                                                    : (r.grnId != null ? 'GRN: ${ProcurementDocumentFormatter.formatGrnNumber(r.grnId, r.grnId)}' : '-'),
                                                style: const TextStyle(fontSize: 11),
                                              ),
                                            ),
                                            DataCell(Text(dateFormat.format(r.issueDate), style: const TextStyle(fontSize: 11))),
                                            DataCell(Text(r.subtotalAmount.toStringAsFixed(2), style: const TextStyle(fontSize: 11))),
                                            DataCell(Text(r.vatAmount.toStringAsFixed(2), style: const TextStyle(fontSize: 11))),
                                            DataCell(
                                              Text(
                                                r.totalAmount.toStringAsFixed(2),
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                              ),
                                            ),
                                            DataCell(
                                              r.isValid
                                                  ? Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: Colors.green.shade50,
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Text(
                                                        isAr ? 'صالح' : 'Ready',
                                                        style: TextStyle(color: Colors.green.shade800, fontSize: 10, fontWeight: FontWeight.bold),
                                                      ),
                                                    )
                                                  : Tooltip(
                                                      message: r.error ?? '',
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: Colors.red.shade50,
                                                          borderRadius: BorderRadius.circular(4),
                                                        ),
                                                        child: Text(
                                                          r.error ?? 'Invalid',
                                                          style: TextStyle(color: Colors.red.shade800, fontSize: 10, fontWeight: FontWeight.bold),
                                                        ),
                                                      ),
                                                    ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isImporting
                        ? (isAr ? 'جارِ الاستيراد: $_importedCount / $validRowsCount' : 'Importing: $_importedCount of $validRowsCount bills...')
                        : '$validRowsCount ${isAr ? 'جاهزة للحفظ' : 'ready to import'}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _isImporting ? null : () => Navigator.of(context).pop(),
                        child: Text(isAr ? 'إلغاء' : 'Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade700,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: (_isImporting || validRowsCount == 0) ? null : _submitImport,
                        icon: _isImporting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.cloud_upload, size: 18),
                        label: Text(
                          isAr ? 'اعتماد واستيراد ($validRowsCount)' : 'Import ($validRowsCount) Bills',
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
