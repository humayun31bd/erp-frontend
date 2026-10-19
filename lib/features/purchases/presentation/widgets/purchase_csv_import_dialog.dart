import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/procurement_document_formatter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import '../../providers/purchases_provider.dart';
import '../../../suppliers/providers/suppliers_provider.dart';

class PurchaseCsvImportDialog extends ConsumerStatefulWidget {
  final bool isArabic;

  const PurchaseCsvImportDialog({
    super.key,
    required this.isArabic,
  });

  @override
  ConsumerState<PurchaseCsvImportDialog> createState() => _PurchaseCsvImportDialogState();
}

class _GroupedInvoiceImport {
  final String invoiceNumber;
  final String supplierId;
  final String supplierName;
  final DateTime issueDate;
  final DateTime? dueDate;
  final List<Map<String, dynamic>> lineItems;
  final double subtotalAmount;
  final double totalVatAmount;
  final double totalAmount;
  final bool isValid;
  final String? error;

  _GroupedInvoiceImport({
    required this.invoiceNumber,
    required this.supplierId,
    required this.supplierName,
    required this.issueDate,
    this.dueDate,
    required this.lineItems,
    required this.subtotalAmount,
    required this.totalVatAmount,
    required this.totalAmount,
    required this.isValid,
    this.error,
  });
}

class _PurchaseCsvImportDialogState extends ConsumerState<PurchaseCsvImportDialog> {
  final TextEditingController _pasteController = TextEditingController();
  List<_GroupedInvoiceImport> _parsedInvoices = [];
  bool _isImporting = false;
  String? _parseErrorMessage;
  int _importedCount = 0;

  static const String sampleCsvTemplate =
      'Invoice Number,Supplier Code,Supplier Name,Item Description,Quantity,Unit Price,VAT Rate,Issue Date,Due Date\n'
      'PINV-2026-001,SUP-001,Al-Marai Dairy,Fresh Full Cream Milk 1L,100,4.50,15,2026-10-10,2026-11-10\n'
      'PINV-2026-001,SUP-001,Al-Marai Dairy,Cheddar Cheese 200g,50,9.00,15,2026-10-10,2026-11-10\n'
      'PINV-2026-002,SUP-002,Saudia National Foods,Tomato Paste 135g Pack,200,2.50,15,2026-10-12,2026-11-12';

  @override
  void dispose() {
    _pasteController.dispose();
    super.dispose();
  }

  void _parseCsvString(String rawCsv) {
    if (rawCsv.trim().isEmpty) {
      setState(() {
        _parsedInvoices = [];
        _parseErrorMessage = null;
      });
      return;
    }

    try {
      final rows = Csv().decode(rawCsv);

      if (rows.isEmpty || rows.length <= 1) {
        setState(() {
          _parsedInvoices = [];
          _parseErrorMessage = widget.isArabic ? 'الملف لا يحتوي على صفوف بيانات' : 'CSV has no data rows';
        });
        return;
      }

      final suppliersList = ref.read(suppliersProvider).value ?? [];
      final dataRows = rows.skip(1);

      // Map to group line items by invoiceNumber
      final Map<String, List<Map<String, dynamic>>> invoiceGroups = {};
      final Map<String, Map<String, dynamic>> invoiceMeta = {};

      for (final row in dataRows) {
        if (row.isEmpty || (row.length == 1 && row[0].toString().trim().isEmpty)) {
          continue;
        }

        final invoiceNo = row.isNotEmpty ? row[0].toString().trim() : '';
        final rawSupId = row.length > 1 ? row[1].toString().trim() : '';
        var supName = row.length > 2 ? row[2].toString().trim() : '';
        final itemDesc = row.length > 3 ? row[3].toString().trim() : 'Goods';
        final qty = row.length > 4 ? (double.tryParse(row[4].toString().trim()) ?? 1.0) : 1.0;
        final unitPrice = row.length > 5 ? (double.tryParse(row[5].toString().trim()) ?? 0.0) : 0.0;
        final vatRate = row.length > 6 ? (double.tryParse(row[6].toString().trim()) ?? 15.0) : 15.0;
        final rawIssueDate = row.length > 7 ? row[7].toString().trim() : '';
        final rawDueDate = row.length > 8 ? row[8].toString().trim() : '';

        if (invoiceNo.isEmpty) continue;

        String finalSupId = rawSupId;
        if (suppliersList.isNotEmpty) {
          final matched = suppliersList.firstWhere(
            (s) =>
                s.id.toLowerCase() == rawSupId.toLowerCase() ||
                s.name.toLowerCase() == rawSupId.toLowerCase() ||
                s.name.toLowerCase() == supName.toLowerCase(),
            orElse: () => suppliersList.first,
          );
          if (finalSupId.isEmpty && supName.isNotEmpty) {
            finalSupId = matched.id;
          }
          if (supName.isEmpty) {
            supName = matched.name;
          }
        }

        DateTime issueDate = DateTime.now();
        if (rawIssueDate.isNotEmpty) {
          issueDate = DateTime.tryParse(rawIssueDate) ?? DateTime.now();
        }

        DateTime? dueDate;
        if (rawDueDate.isNotEmpty) {
          dueDate = DateTime.tryParse(rawDueDate);
        }

        final lineSubtotal = qty * unitPrice;
        final lineVat = lineSubtotal * (vatRate / 100.0);
        final lineTotal = lineSubtotal + lineVat;

        final lineItem = {
          'description': itemDesc,
          'quantity': qty,
          'unitPrice': unitPrice,
          'vatRate': vatRate,
          'subtotalAmount': lineSubtotal,
          'vatAmount': lineVat,
          'totalAmount': lineTotal,
        };

        if (!invoiceGroups.containsKey(invoiceNo)) {
          invoiceGroups[invoiceNo] = [];
          invoiceMeta[invoiceNo] = {
            'supplierId': finalSupId.isNotEmpty ? finalSupId : 'SUP-DEFAULT',
            'supplierName': supName.isNotEmpty ? supName : 'Supplier',
            'issueDate': issueDate,
            'dueDate': dueDate,
          };
        }

        invoiceGroups[invoiceNo]!.add(lineItem);
      }

      final List<_GroupedInvoiceImport> result = [];

      for (final entry in invoiceGroups.entries) {
        final invNo = entry.key;
        final lines = entry.value;
        final meta = invoiceMeta[invNo]!;

        double subtotalSum = 0;
        double vatSum = 0;
        double totalSum = 0;

        for (final li in lines) {
          subtotalSum += (li['subtotalAmount'] as num).toDouble();
          vatSum += (li['vatAmount'] as num).toDouble();
          totalSum += (li['totalAmount'] as num).toDouble();
        }

        bool isValid = true;
        String? errorMsg;

        if ((meta['supplierId'] as String).isEmpty) {
          isValid = false;
          errorMsg = widget.isArabic ? 'كود المورد مفقود' : 'Supplier Code missing';
        } else if (totalSum <= 0) {
          isValid = false;
          errorMsg = widget.isArabic ? 'إجمالي الفاتورة يجب أن يكون أكبر من 0' : 'Total must be greater than 0';
        }

        result.add(_GroupedInvoiceImport(
          invoiceNumber: invNo,
          supplierId: meta['supplierId'] as String,
          supplierName: meta['supplierName'] as String,
          issueDate: meta['issueDate'] as DateTime,
          dueDate: meta['dueDate'] as DateTime?,
          lineItems: lines,
          subtotalAmount: subtotalSum,
          totalVatAmount: vatSum,
          totalAmount: totalSum,
          isValid: isValid,
          error: errorMsg,
        ));
      }

      setState(() {
        _parsedInvoices = result;
        _parseErrorMessage = null;
      });
    } catch (e) {
      setState(() {
        _parsedInvoices = [];
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
              ? 'تم نسخ قالب استيراد فواتير المشتريات إلى الحافظة'
              : 'Purchase Invoices CSV template copied to clipboard',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _submitImport() async {
    final validInvoices = _parsedInvoices.where((inv) => inv.isValid).toList();
    if (validInvoices.isEmpty) return;

    setState(() {
      _isImporting = true;
      _importedCount = 0;
    });

    int successCount = 0;
    int failedCount = 0;

    for (final inv in validInvoices) {
      final payload = {
        'invoiceNumber': inv.invoiceNumber,
        'supplierId': inv.supplierId,
        'supplierName': inv.supplierName,
        'issueDate': inv.issueDate.toIso8601String(),
        'dueDate': inv.dueDate?.toIso8601String(),
        'subtotalAmount': inv.subtotalAmount,
        'totalVatAmount': inv.totalVatAmount,
        'totalAmount': inv.totalAmount,
        'paymentStatus': 'UNPAID',
        'lineItems': inv.lineItems,
      };

      try {
        await ref.read(purchaseApiProvider).createPurchase(payload);
        successCount++;
      } catch (e) {
        failedCount++;
      }

      setState(() {
        _importedCount = successCount + failedCount;
      });
    }

    ref.invalidate(purchasesProvider);

    if (mounted) {
      setState(() => _isImporting = false);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isArabic
                ? 'اكتمل الاستيراد: تم إنشاء $successCount فاتورة شراء بنجاح${failedCount > 0 ? ' (فشل $failedCount)' : ''}'
                : 'Import complete: $successCount purchase invoices imported${failedCount > 0 ? ' ($failedCount failed)' : ''}',
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
    final validCount = _parsedInvoices.where((i) => i.isValid).length;
    final totalSum = _parsedInvoices.where((i) => i.isValid).fold<double>(0.0, (sum, i) => sum + i.totalAmount);
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
                color: Colors.blue.shade50,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(bottom: BorderSide(color: Colors.blue.shade100)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue.shade700,
                    child: const Icon(Icons.file_upload, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'استيراد فواتير المشتريات من ملف CSV' : 'Import Purchase Invoices from CSV',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                        Text(
                          isAr
                              ? 'استيراد فواتير الشراء الضريبية مع تجميع بنود الأصناف وحساب ضريبة 15% تلقائياً'
                              : 'Batch import tax purchase invoices with line items grouping & 15% VAT auto-calculation',
                          style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
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

            // Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Toolbar Row
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isImporting ? null : _pickFile,
                          icon: const Icon(Icons.folder_open, size: 18),
                          label: Text(isAr ? 'اختيار ملف CSV' : 'Choose CSV File'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
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
                        if (_parsedInvoices.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: validCount > 0 ? Colors.green.shade50 : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: validCount > 0 ? Colors.green.shade200 : Colors.red.shade200,
                              ),
                            ),
                            child: Text(
                              '$validCount ${isAr ? 'فواتير صالحة' : 'Valid Invoices'} • SAR ${totalSum.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: validCount > 0 ? Colors.green.shade800 : Colors.red.shade800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Paste Area
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

                    // Preview Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isAr ? 'معاينة فواتير الشراء قبل الاستيراد:' : 'Pre-import Purchase Invoices Preview:',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        if (_parsedInvoices.isNotEmpty)
                          Text(
                            '${_parsedInvoices.length} ${isAr ? 'فواتير مجمعة' : 'grouped invoices'}',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Preview Table
                    Expanded(
                      child: _parsedInvoices.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.receipt_long, size: 48, color: Colors.grey.shade300),
                                  const SizedBox(height: 8),
                                  Text(
                                    isAr
                                        ? 'قم باختيار ملف أو لصق البيانات أعلاه للمعاينة'
                                        : 'Upload a file or paste CSV text above to preview invoices',
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
                                        DataColumn(label: Text(isAr ? 'رقم الفاتورة' : 'Invoice #')),
                                        DataColumn(label: Text(isAr ? 'المورد' : 'Supplier')),
                                        DataColumn(label: Text(isAr ? 'تاريخ الإصدار' : 'Issue Date')),
                                        DataColumn(label: Text(isAr ? 'الأصناف' : 'Items')),
                                        DataColumn(label: Text(isAr ? 'الصافي' : 'Subtotal')),
                                        DataColumn(label: Text(isAr ? 'الضريبة (15%)' : 'VAT (15%)')),
                                        DataColumn(label: Text(isAr ? 'الإجمالي' : 'Total (SAR)')),
                                        DataColumn(label: Text(isAr ? 'الحالة' : 'Status')),
                                      ],
                                      rows: _parsedInvoices.asMap().entries.map((entry) {
                                        final idx = entry.key + 1;
                                        final inv = entry.value;

                                        return DataRow(
                                          color: WidgetStateProperty.all(
                                            inv.isValid ? Colors.white : Colors.red.shade50.withValues(alpha: 0.5),
                                          ),
                                          cells: [
                                            DataCell(Text('$idx')),
                                            DataCell(Text(inv.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                            DataCell(
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(inv.supplierName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                                  Text(ProcurementDocumentFormatter.formatSupplierCode(inv.supplierId), style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                                                ],
                                              ),
                                            ),
                                            DataCell(Text(dateFormat.format(inv.issueDate), style: const TextStyle(fontSize: 11))),
                                            DataCell(Text('${inv.lineItems.length}', style: const TextStyle(fontSize: 11))),
                                            DataCell(Text(inv.subtotalAmount.toStringAsFixed(2), style: const TextStyle(fontSize: 11))),
                                            DataCell(Text(inv.totalVatAmount.toStringAsFixed(2), style: const TextStyle(fontSize: 11))),
                                            DataCell(
                                              Text(
                                                inv.totalAmount.toStringAsFixed(2),
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                              ),
                                            ),
                                            DataCell(
                                              inv.isValid
                                                  ? Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: Colors.green.shade50,
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Text(
                                                        isAr ? 'جاهزة' : 'Ready',
                                                        style: TextStyle(color: Colors.green.shade800, fontSize: 10, fontWeight: FontWeight.bold),
                                                      ),
                                                    )
                                                  : Tooltip(
                                                      message: inv.error ?? '',
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: Colors.red.shade50,
                                                          borderRadius: BorderRadius.circular(4),
                                                        ),
                                                        child: Text(
                                                          inv.error ?? 'Invalid',
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
                        ? (isAr ? 'جارِ الاستيراد: $_importedCount / $validCount' : 'Importing: $_importedCount of $validCount invoices...')
                        : '$validCount ${isAr ? 'فواتير جاهزة للاستيراد' : 'ready to import'}',
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
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: (_isImporting || validCount == 0) ? null : _submitImport,
                        icon: _isImporting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.cloud_upload, size: 18),
                        label: Text(
                          isAr ? 'استيراد ($validCount) فاتورة' : 'Import ($validCount) Invoices',
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
