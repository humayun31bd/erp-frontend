import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/procurement_models.dart';
import '../../providers/procurement_provider.dart';
import '../../utils/rfq_pdf_printer.dart';
import '../../utils/procurement_document_formatter.dart';

class QuotationDetailsDialog extends ConsumerStatefulWidget {
  final SupplierQuotationModel quotation;
  final bool isArabic;

  const QuotationDetailsDialog({
    super.key,
    required this.quotation,
    required this.isArabic,
  });

  @override
  ConsumerState<QuotationDetailsDialog> createState() => _QuotationDetailsDialogState();
}

class _QuotationDetailsDialogState extends ConsumerState<QuotationDetailsDialog> {
  late SupplierQuotationModel _quotation;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _quotation = widget.quotation;
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true);
    try {
      final updated = await ref.read(procurementServiceProvider).updateQuotation(_quotation.id, {
        'status': newStatus,
      });
      ref.invalidate(supplierQuotationsProvider);
      setState(() {
        _quotation = updated;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isArabic ? 'تم تحديث حالة عرض السعر بنجاح' : 'RFQ status updated to $newStatus',
            ),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isArabic ? 'فشل التحديث: $e' : 'Failed to update status: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Widget _buildStatusChip(String status) {
    Color bg;
    Color fg;
    switch (status.toUpperCase()) {
      case 'ACCEPTED':
        bg = Colors.green.shade50;
        fg = Colors.green.shade800;
        break;
      case 'SUBMITTED':
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade800;
        break;
      case 'REJECTED':
        bg = Colors.red.shade50;
        fg = Colors.red.shade800;
        break;
      case 'DRAFT':
      default:
        bg = Colors.amber.shade50;
        fg = Colors.amber.shade900;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = widget.isArabic;
    final totalVal = double.tryParse(_quotation.totalAmount) ?? 0.0;
    final subtotalVal = _quotation.items.isNotEmpty
        ? _quotation.items.fold<double>(0.0, (acc, item) => acc + (item.quantity * item.unitPrice))
        : totalVal / 1.15;
    final vatVal = totalVal > subtotalVal ? (totalVal - subtotalVal) : (totalVal * 0.15);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 820,
        constraints: const BoxConstraints(maxHeight: 780),
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
                    child: const Icon(Icons.receipt_long, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _quotation.quotationNumber,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const SizedBox(width: 12),
                            _buildStatusChip(_quotation.status),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isAr ? 'تفاصيل عرض سعر المورد (RFQ)' : 'Supplier Quotation Details (RFQ)',
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: isAr ? 'تغيير الحالة' : 'Change Status',
                    enabled: !_isUpdating,
                    icon: _isUpdating
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.edit_note_rounded),
                    onSelected: _updateStatus,
                    itemBuilder: (ctx) => [
                      PopupMenuItem(value: 'DRAFT', child: Text(isAr ? 'مسودة' : 'Draft')),
                      PopupMenuItem(value: 'SUBMITTED', child: Text(isAr ? 'مقدم' : 'Submitted')),
                      PopupMenuItem(value: 'ACCEPTED', child: Text(isAr ? 'مقبول' : 'Accepted')),
                      PopupMenuItem(value: 'REJECTED', child: Text(isAr ? 'مرفوض' : 'Rejected')),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vendor & RFQ Information
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Supplier Info
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.business_rounded, size: 16, color: theme.colorScheme.primary),
                                    const SizedBox(width: 8),
                                    Text(
                                      isAr ? 'بيانات المورد' : 'Supplier Information',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 13, color: theme.colorScheme.primary),
                                    ),
                                  ],
                                ),
                                const Divider(height: 16),
                                Text(
                                  _quotation.supplierName ?? ProcurementDocumentFormatter.formatSupplierCode(_quotation.supplierId),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${isAr ? 'كود المورد' : 'Supplier Code'}: ${ProcurementDocumentFormatter.formatSupplierCode(_quotation.supplierId)}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                                if (_quotation.supplierRefNo != null && _quotation.supplierRefNo!.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.blue.shade200),
                                    ),
                                    child: Text(
                                      'Ref #: ${_quotation.supplierRefNo}',
                                      style: TextStyle(
                                          fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // RFQ Specifications
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.info_outline_rounded, size: 16, color: theme.colorScheme.primary),
                                    const SizedBox(width: 8),
                                    Text(
                                      isAr ? 'بيانات التواريخ' : 'Dates & Specs',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 13, color: theme.colorScheme.primary),
                                    ),
                                  ],
                                ),
                                const Divider(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(isAr ? 'تاريخ الإصدار:' : 'Issue Date:',
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                                    Text(DateFormat('yyyy-MM-dd').format(_quotation.quotationDate),
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(isAr ? 'صالح حتى:' : 'Valid Until:',
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                                    Text(
                                      _quotation.validUntil != null
                                          ? DateFormat('yyyy-MM-dd').format(_quotation.validUntil!)
                                          : (isAr ? 'غير محدد' : 'Open'),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: _quotation.validUntil != null &&
                                                _quotation.validUntil!.isBefore(DateTime.now())
                                            ? Colors.red.shade800
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(isAr ? 'العملة:' : 'Currency:',
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                                    Text(_quotation.currency,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Items List Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isAr ? 'الأصناف المسعرة' : 'Quoted Line Items',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_quotation.items.length} ${isAr ? "أصناف" : "Items"}',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Items Table
                    if (_quotation.items.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Center(
                          child: Text(
                            isAr ? 'لا توجد أصناف تفصيلية (تسعير إجمالي مباشر)' : 'No item breakdown (Direct lump-sum quotation)',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                            columnSpacing: 24,
                            columns: [
                              DataColumn(label: Text(isAr ? 'الصنف' : 'Item Description')),
                              DataColumn(label: Text(isAr ? 'الكمية' : 'Qty'), numeric: true),
                              DataColumn(label: Text(isAr ? 'السعر (ر.س)' : 'Unit Price (SAR)'), numeric: true),
                              DataColumn(label: Text(isAr ? 'الإجمالي (ر.س)' : 'Total (SAR)'), numeric: true),
                            ],
                            rows: _quotation.items.map((item) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.description, style: const TextStyle(fontWeight: FontWeight.w600)),
                                        if (item.productId != null && item.productId!.isNotEmpty)
                                          Text('SKU: ${item.productId}',
                                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                      ],
                                    ),
                                  ),
                                  DataCell(Text('${item.quantity}')),
                                  DataCell(Text(item.unitPrice.toStringAsFixed(2))),
                                  DataCell(Text(item.totalAmount.toStringAsFixed(2),
                                      style: const TextStyle(fontWeight: FontWeight.bold))),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Financial Summary Box
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Remarks
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAr ? 'ملاحظات وشروط المورد' : 'Remarks & Supplier Notes',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade800),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  (_quotation.notes != null && _quotation.notes!.isNotEmpty)
                                      ? _quotation.notes!
                                      : (isAr ? 'لا توجد ملاحظات إضافية مسجلة.' : 'No additional remarks provided.'),
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Totals
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(isAr ? 'المجموع الفرعي:' : 'Subtotal:',
                                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                                    Text('SAR ${subtotalVal.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(isAr ? 'ضريبة القيمة المضافة (15%):' : 'VAT (15%):',
                                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                                    Text('SAR ${vatVal.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                const Divider(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      isAr ? 'الإجمالي الكلي:' : 'Total Amount:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 15, color: theme.colorScheme.primary),
                                    ),
                                    Text(
                                      'SAR ${totalVal.toStringAsFixed(2)}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.primary),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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
                  OutlinedButton.icon(
                    icon: const Icon(Icons.print_rounded, size: 18),
                    label: Text(isAr ? 'طباعة عرض السعر (PDF)' : 'Print RFQ (PDF)'),
                    onPressed: () => RfqPdfPrinter.printQuotation(_quotation),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(isAr ? 'إغلاق' : 'Close'),
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
