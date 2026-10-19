import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/procurement_models.dart';
import '../../providers/procurement_provider.dart';
import '../../utils/grn_pdf_printer.dart';
import '../../utils/procurement_document_formatter.dart';
import 'record_received_bill_dialog.dart';

class GrnDetailsDialog extends ConsumerStatefulWidget {
  final GoodsReceivedNoteModel grn;
  final bool isArabic;

  const GrnDetailsDialog({
    super.key,
    required this.grn,
    this.isArabic = false,
  });

  @override
  ConsumerState<GrnDetailsDialog> createState() => _GrnDetailsDialogState();
}

class _GrnDetailsDialogState extends ConsumerState<GrnDetailsDialog> {
  late GoodsReceivedNoteModel _grn;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _grn = widget.grn;
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true);
    try {
      final updated = await ref.read(procurementServiceProvider).updateGoodsReceivedNote(_grn.id, {
        'status': newStatus,
      });
      ref.invalidate(goodsReceivedNotesProvider);
      setState(() {
        _grn = updated;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isArabic ? 'تم تحديث حالة استلام البضائع بنجاح' : 'GRN status updated to $newStatus',
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

  Future<void> _deleteGrn() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(widget.isArabic ? 'حذف إذن الاستلام' : 'Delete Goods Received Note'),
        content: Text(
          widget.isArabic
              ? 'هل أنت متأكد من رغبتك في حذف إذن الاستلام ${_grn.grnNumber}؟ لا يمكن التراجع عن هذا الإجراء.'
              : 'Are you sure you want to delete ${_grn.grnNumber}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(widget.isArabic ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(widget.isArabic ? 'حذف' : 'Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(procurementServiceProvider).deleteGoodsReceivedNote(_grn.id);
        ref.invalidate(goodsReceivedNotesProvider);
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.isArabic ? 'تم حذف إذن الاستلام بنجاح' : 'GRN deleted successfully'),
              backgroundColor: Colors.orange.shade800,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete GRN: $e'), backgroundColor: Colors.red.shade700),
          );
        }
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'RECEIVED':
        return Colors.blue;
      case 'QC_PENDING':
        return Colors.amber.shade800;
      case 'QC_COMPLETED':
      case 'ACCEPTED':
        return Colors.green.shade700;
      case 'REJECTED':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = widget.isArabic;
    final statusColor = _getStatusColor(_grn.status);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 860,
        constraints: const BoxConstraints(maxHeight: 800),
        child: Column(
          children: [
            // Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(bottom: BorderSide(color: theme.dividerColor)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.inventory_2_rounded, color: Colors.teal, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _grn.grnNumber,
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                _grn.status.toUpperCase(),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${isAr ? "تاريخ الاستلام:" : "Received:"} ${DateFormat('MMM dd, yyyy HH:mm').format(_grn.receivedDate)} | ${isAr ? "المورد:" : "Supplier:"} ${_grn.supplierName}',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                        ),
                      ],
                    ),
                  ),
                  // Top Quick Print button
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    icon: const Icon(Icons.print_rounded, size: 18),
                    label: Text(isAr ? 'طباعة السند' : 'Print GRN'),
                    onPressed: () => GrnPdfPrinter.printGrn(_grn),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top 4 Metrics Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricTile(
                            context: context,
                            title: isAr ? 'عدد الأصناف' : 'Total Items',
                            value: '${_grn.items.length}',
                            subtitle: isAr ? 'بند مستلم' : 'Lines',
                            icon: Icons.format_list_numbered_rounded,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricTile(
                            context: context,
                            title: isAr ? 'الكمية المطلوبة' : 'Ordered Qty',
                            value: _grn.totalOrderedQuantity.toStringAsFixed(1),
                            subtitle: isAr ? 'وحدة' : 'Units',
                            icon: Icons.shopping_cart_checkout_rounded,
                            color: Colors.indigo,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricTile(
                            context: context,
                            title: isAr ? 'الكمية المستلمة' : 'Received Qty',
                            value: _grn.totalReceivedQuantity.toStringAsFixed(1),
                            subtitle: isAr ? 'وحدة فعلية' : 'Units Actual',
                            icon: Icons.check_circle_rounded,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricTile(
                            context: context,
                            title: isAr ? 'نسبة الاستيفاء' : 'Fulfillment',
                            value: '${_grn.fulfillmentRate.toStringAsFixed(0)}%',
                            subtitle: _grn.fulfillmentRate >= 100
                                ? (isAr ? 'مكتمل بالكامل' : 'Complete')
                                : (isAr ? 'استلام جزئي' : 'Partial'),
                            icon: Icons.pie_chart_rounded,
                            color: _grn.fulfillmentRate >= 100 ? Colors.green : Colors.amber.shade800,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Details Section (Supplier Card & Receiving Info Card)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Supplier Info Card
                        Expanded(
                          flex: 5,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.storefront_rounded, size: 18, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Text(
                                      isAr ? 'بيانات المورد' : 'Supplier Details',
                                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const Divider(height: 20),
                                Text(
                                  _grn.supplierName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(height: 6),
                                _buildInfoRow(
                                  isAr ? 'كود المورد:' : 'Supplier Code:',
                                  ProcurementDocumentFormatter.formatSupplierCode(_grn.supplierId),
                                ),
                                if (_grn.supplierTaxNumber != null && _grn.supplierTaxNumber!.isNotEmpty)
                                  _buildInfoRow(
                                    isAr ? 'الرقم الضريبي:' : 'VAT/Tax Number:',
                                    _grn.supplierTaxNumber!,
                                  ),
                                if (_grn.supplierPhone != null && _grn.supplierPhone!.isNotEmpty)
                                  _buildInfoRow(
                                    isAr ? 'رقم الهاتف:' : 'Phone:',
                                    _grn.supplierPhone!,
                                  ),
                                if (_grn.supplierEmail != null && _grn.supplierEmail!.isNotEmpty)
                                  _buildInfoRow(
                                    isAr ? 'البريد الإلكتروني:' : 'Email:',
                                    _grn.supplierEmail!,
                                  ),
                                if (_grn.supplierAddress != null && _grn.supplierAddress!.isNotEmpty)
                                  _buildInfoRow(
                                    isAr ? 'العنوان:' : 'Address:',
                                    _grn.supplierAddress!,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Receiving Info Card
                        Expanded(
                          flex: 5,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.local_shipping_outlined, size: 18, color: Colors.teal),
                                    const SizedBox(width: 8),
                                    Text(
                                      isAr ? 'بيانات الإذن والشحن' : 'Receiving & Logistics Info',
                                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const Divider(height: 20),
                                _buildInfoRow(
                                  isAr ? 'رقم إذن الاستلام:' : 'GRN Number:',
                                  _grn.grnNumber,
                                  isBold: true,
                                ),
                                _buildInfoRow(
                                  isAr ? 'أمر الشراء المرتبط:' : 'PO Reference:',
                                  ProcurementDocumentFormatter.formatPoNumber(_grn.poNumber, _grn.poId),
                                  valueColor: _grn.poNumber != null ? Colors.blue.shade700 : null,
                                ),
                                _buildInfoRow(
                                  isAr ? 'رقم إشعار التسليم / البوليصة:' : 'Delivery Note / Waybill #:',
                                  _grn.deliveryNoteNumber != null && _grn.deliveryNoteNumber!.isNotEmpty
                                      ? _grn.deliveryNoteNumber!
                                      : (isAr ? 'غير مسجل' : 'N/A'),
                                ),
                                _buildInfoRow(
                                  isAr ? 'المستودع / المخزن:' : 'Warehouse / Store:',
                                  _grn.warehouseName ?? (isAr ? 'المستودع المركزي' : 'Central Warehouse'),
                                ),
                                _buildInfoRow(
                                  isAr ? 'القيمة التقديرية:' : 'Estimated Value:',
                                  'SAR ${_grn.totalValue.toStringAsFixed(2)}',
                                  isBold: true,
                                  valueColor: Colors.teal.shade800,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Items Table Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isAr ? 'الأصناف المستلمة تفصيلياً' : 'Itemized Consignment Table',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${_grn.items.length} ${isAr ? "عنصر" : "Items"}',
                          style: TextStyle(color: theme.colorScheme.outline, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Items Table
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Table(
                          columnWidths: const {
                            0: FixedColumnWidth(40), // SL
                            1: FlexColumnWidth(4), // Description
                            2: FlexColumnWidth(2), // Ordered Qty
                            3: FlexColumnWidth(2), // Received Qty
                            4: FlexColumnWidth(2), // Difference
                            5: FlexColumnWidth(2), // Unit Cost
                            6: FlexColumnWidth(2.2), // Total
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                              ),
                              children: [
                                _buildTableHeaderCell('#'),
                                _buildTableHeaderCell(isAr ? 'الوصف / الصنف' : 'Item Description'),
                                _buildTableHeaderCell(isAr ? 'المطلوب' : 'Ordered', align: TextAlign.right),
                                _buildTableHeaderCell(isAr ? 'المستلم' : 'Received', align: TextAlign.right),
                                _buildTableHeaderCell(isAr ? 'الفارق' : 'Diff', align: TextAlign.right),
                                _buildTableHeaderCell(isAr ? 'سعر الوحدة' : 'Unit Cost', align: TextAlign.right),
                                _buildTableHeaderCell(isAr ? 'الإجمالي (ر.س)' : 'Total (SAR)', align: TextAlign.right),
                              ],
                            ),
                            ...List.generate(_grn.items.length, (index) {
                              final item = _grn.items[index];
                              final diff = item.receivedQuantity - item.orderedQuantity;
                              final rowTotal = item.receivedQuantity * item.unitPrice;
                              final isEven = index % 2 == 0;

                              return TableRow(
                                decoration: BoxDecoration(
                                  color: isEven
                                      ? theme.colorScheme.surface
                                      : theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
                                ),
                                children: [
                                  _buildTableCell('${index + 1}', align: TextAlign.center),
                                  _buildTableCell(item.description, isBold: true),
                                  _buildTableCell(item.orderedQuantity.toStringAsFixed(1), align: TextAlign.right),
                                  _buildTableCell(
                                    item.receivedQuantity.toStringAsFixed(1),
                                    align: TextAlign.right,
                                    isBold: true,
                                    color: Colors.teal.shade800,
                                  ),
                                  _buildTableCell(
                                    diff == 0
                                        ? '0.0'
                                        : (diff > 0 ? '+${diff.toStringAsFixed(1)}' : diff.toStringAsFixed(1)),
                                    align: TextAlign.right,
                                    color: diff < 0
                                        ? Colors.red.shade700
                                        : (diff > 0 ? Colors.amber.shade900 : Colors.grey),
                                    isBold: diff != 0,
                                  ),
                                  _buildTableCell(item.unitPrice.toStringAsFixed(2), align: TextAlign.right),
                                  _buildTableCell(rowTotal.toStringAsFixed(2),
                                      align: TextAlign.right, isBold: true),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Remarks Card
                    if (_grn.remarks != null && _grn.remarks!.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.note_alt_outlined, size: 16, color: Colors.teal),
                                const SizedBox(width: 6),
                                Text(
                                  isAr ? 'ملاحظات الفحص والاستلام:' : 'Inspection Remarks & Warehouse Notes:',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _grn.remarks!,
                              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Bottom Actions Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border(top: BorderSide(color: theme.dividerColor)),
              ),
              child: Row(
                children: [
                  // Delete Button
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                    tooltip: isAr ? 'حذف إذن الاستلام' : 'Delete GRN',
                    onPressed: _isUpdating ? null : _deleteGrn,
                  ),
                  const SizedBox(width: 8),

                  // Status Dropdown
                  PopupMenuButton<String>(
                    tooltip: isAr ? 'تغيير الحالة' : 'Change Status',
                    enabled: !_isUpdating,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.edit_note_rounded, size: 18, color: statusColor),
                          const SizedBox(width: 6),
                          Text(
                            '${isAr ? "الحالة:" : "Status:"} ${_grn.status}',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: statusColor),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_drop_down, size: 18),
                        ],
                      ),
                    ),
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'RECEIVED',
                        child: Row(
                          children: [
                            Icon(Icons.inbox_rounded, color: Colors.blue, size: 18),
                            SizedBox(width: 8),
                            Text('RECEIVED'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'QC_PENDING',
                        child: Row(
                          children: [
                            Icon(Icons.rule_rounded, color: Colors.amber, size: 18),
                            SizedBox(width: 8),
                            Text('QC_PENDING (قيد الفحص)'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'QC_COMPLETED',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                            SizedBox(width: 8),
                            Text('QC_COMPLETED (تم اجتياز الفحص)'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'ACCEPTED',
                        child: Row(
                          children: [
                            Icon(Icons.done_all_rounded, color: Colors.teal, size: 18),
                            SizedBox(width: 8),
                            Text('ACCEPTED (مقبول بالمستودع)'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'REJECTED',
                        child: Row(
                          children: [
                            Icon(Icons.cancel_rounded, color: Colors.red, size: 18),
                            SizedBox(width: 8),
                            Text('REJECTED (مرفوض)'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (val) => _updateStatus(val),
                  ),

                  const Spacer(),

                  // Share PDF
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: Text(isAr ? 'مشاركة PDF' : 'Share PDF'),
                    onPressed: () => GrnPdfPrinter.shareGrn(_grn),
                  ),
                  const SizedBox(width: 10),

                  // Print PDF Voucher
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    icon: const Icon(Icons.print_rounded, size: 18),
                    label: Text(isAr ? 'طباعة إذن الاستلام' : 'Print GRN'),
                    onPressed: () => GrnPdfPrinter.printGrn(_grn),
                  ),
                  const SizedBox(width: 10),

                  // Record Bill from GRN
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    icon: const Icon(Icons.receipt_long_rounded, size: 18),
                    label: Text(isAr ? 'تسجيل فاتورة من السند' : 'Record Bill'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx) => RecordReceivedBillDialog(
                          isArabic: isAr,
                          initialGrn: _grn,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 10),

                  TextButton(
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

  Widget _buildMetricTile({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline, fontSize: 11),
                ),
                Text(
                  value,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12.5, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeaderCell(String text, {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(
        text,
        textAlign: align,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildTableCell(
    String text, {
    TextAlign align = TextAlign.left,
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
          color: color,
        ),
      ),
    );
  }
}
