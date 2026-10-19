import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/procurement_models.dart';
import '../../providers/procurement_provider.dart';
import '../../utils/po_pdf_printer.dart';
import '../../utils/procurement_document_formatter.dart';
import 'receive_goods_dialog.dart';

class PurchaseOrderDetailsDialog extends ConsumerStatefulWidget {
  final PurchaseOrderModel po;
  final bool isArabic;

  const PurchaseOrderDetailsDialog({
    super.key,
    required this.po,
    required this.isArabic,
  });

  @override
  ConsumerState<PurchaseOrderDetailsDialog> createState() => _PurchaseOrderDetailsDialogState();
}

class _PurchaseOrderDetailsDialogState extends ConsumerState<PurchaseOrderDetailsDialog> {
  late PurchaseOrderModel _po;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _po = widget.po;
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true);
    try {
      final updated = await ref.read(procurementServiceProvider).updatePurchaseOrder(_po.id, {
        'status': newStatus,
      });
      ref.invalidate(purchaseOrdersProvider);
      setState(() {
        _po = updated;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isArabic ? 'تم تحديث حالة أمر الشراء بنجاح' : 'PO status updated to $newStatus',
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = widget.isArabic;
    final subtotal = double.tryParse(_po.subtotalAmount) ?? 0.0;
    final vat = double.tryParse(_po.vatAmount) ?? 0.0;
    final total = double.tryParse(_po.totalAmount) ?? 0.0;

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
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
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
                              _po.poNumber,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 10),
                            _buildStatusChip(_po.status),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${isAr ? "المورد" : "Supplier"}: ${_po.supplierName} • ${DateFormat('yyyy-MM-dd').format(_po.issueDate)}',
                          style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.print_outlined),
                    tooltip: isAr ? 'طباعة أمر الشراء' : 'Print / Export PDF',
                    onPressed: () => PoPdfPrinter.printPo(_po),
                  ),
                  const SizedBox(width: 8),
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
                    // Info Cards Grid
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Vendor Box
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.storefront, size: 16, color: theme.colorScheme.primary),
                                    const SizedBox(width: 6),
                                    Text(
                                      isAr ? 'بيانات المورد (Vendor)' : 'VENDOR INFORMATION',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _po.supplierName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${isAr ? 'كود المورد' : 'Supplier Code'}: ${ProcurementDocumentFormatter.formatSupplierCode(_po.supplierId)}',
                                  style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                                ),
                                if (_po.supplierTaxNumber != null && _po.supplierTaxNumber!.isNotEmpty)
                                  Text(
                                    'VAT #: ${_po.supplierTaxNumber}',
                                    style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                                  ),
                                if (_po.supplierPhone != null && _po.supplierPhone!.isNotEmpty)
                                  Text(
                                    'Phone: ${_po.supplierPhone}',
                                    style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                                  ),
                                if (_po.supplierAddress != null && _po.supplierAddress!.isNotEmpty)
                                  Text(
                                    'Address: ${_po.supplierAddress}',
                                    style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Order Metadata Box
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.calendar_month, size: 16, color: theme.colorScheme.primary),
                                    const SizedBox(width: 6),
                                    Text(
                                      isAr ? 'مواصفات أمر الشراء' : 'PO SPECIFICATIONS',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _buildDetailRow(
                                  isAr ? 'تاريخ الإصدار:' : 'Issue Date:',
                                  DateFormat('yyyy-MM-dd').format(_po.issueDate),
                                ),
                                const SizedBox(height: 4),
                                _buildDetailRow(
                                  isAr ? 'تاريخ التوريد المتوقع:' : 'Expected Delivery:',
                                  _po.expectedDeliveryDate != null
                                      ? DateFormat('yyyy-MM-dd').format(_po.expectedDeliveryDate!)
                                      : (isAr ? 'غير محدد' : 'As per agreement'),
                                ),
                                const SizedBox(height: 4),
                                _buildDetailRow(
                                  isAr ? 'العملة:' : 'Currency:',
                                  _po.currency,
                                ),
                                if (_po.csId != null && _po.csId!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  _buildDetailRow(
                                    isAr ? 'مرجع مقارنة الأسعار (CS):' : 'Ref CS Statement:',
                                    ProcurementDocumentFormatter.formatCsNumber(_po.csId),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Items Table
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isAr ? 'أصناف أمر الشراء (${_po.items.length})' : 'Order Line Items (${_po.items.length})',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Table(
                        columnWidths: const {
                          0: FixedColumnWidth(40),
                          1: FlexColumnWidth(4),
                          2: FlexColumnWidth(1.2),
                          3: FlexColumnWidth(1.8),
                          4: FlexColumnWidth(1.2),
                          5: FlexColumnWidth(2),
                        },
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        children: [
                          TableRow(
                            decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
                            children: [
                              const Padding(padding: EdgeInsets.all(10), child: Text('#', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                              Padding(padding: const EdgeInsets.all(10), child: Text(isAr ? 'الوصف' : 'Description', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                              Padding(padding: const EdgeInsets.all(10), child: Text(isAr ? 'الكمية' : 'Qty', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                              Padding(padding: const EdgeInsets.all(10), child: Text(isAr ? 'سعر الوحدة' : 'Unit Price', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                              Padding(padding: const EdgeInsets.all(10), child: Text(isAr ? 'الضريبة' : 'VAT', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                              Padding(padding: const EdgeInsets.all(10), child: Text(isAr ? 'الإجمالي' : 'Total (SAR)', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                            ],
                          ),
                          ..._po.items.asMap().entries.map((entry) {
                            final idx = entry.key + 1;
                            final item = entry.value;
                            return TableRow(
                              decoration: BoxDecoration(
                                border: Border(top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3))),
                              ),
                              children: [
                                Padding(padding: const EdgeInsets.all(10), child: Text('$idx', style: const TextStyle(fontSize: 12))),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.description, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                      if (item.productId != null && item.productId!.isNotEmpty)
                                        Text('SKU: ${item.productId}', style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color)),
                                    ],
                                  ),
                                ),
                                Padding(padding: const EdgeInsets.all(10), child: Text('${item.quantity}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12))),
                                Padding(padding: const EdgeInsets.all(10), child: Text(item.unitPrice.toStringAsFixed(2), textAlign: TextAlign.right, style: const TextStyle(fontSize: 12))),
                                Padding(padding: const EdgeInsets.all(10), child: Text('${item.vatRate.toStringAsFixed(0)}%', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12))),
                                Padding(padding: const EdgeInsets.all(10), child: Text(item.totalAmount.toStringAsFixed(2), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Bottom Row: Notes & Financial Summary
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Notes Box
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAr ? 'ملاحظات وشروط التوريد' : 'Notes & Delivery Terms',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: theme.colorScheme.primary),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  (_po.notes != null && _po.notes!.isNotEmpty)
                                      ? _po.notes!
                                      : (isAr ? 'لا توجد تعليمات خاصة إضافية.' : 'Standard 30 days payment upon delivery & QA check.'),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Totals Card
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(isAr ? 'المجموع الفرعي:' : 'Subtotal:', style: const TextStyle(fontSize: 12)),
                                    Text('SAR ${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(isAr ? 'ضريبة القيمة المضافة (15%):' : 'VAT (15%):', style: const TextStyle(fontSize: 12)),
                                    Text('SAR ${vat.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                                const Divider(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      isAr ? 'الإجمالي النهائي:' : 'Grand Total:',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: theme.colorScheme.primary),
                                    ),
                                    Text(
                                      'SAR ${total.toStringAsFixed(2)}',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: theme.colorScheme.primary),
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

            // Footer Actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  // Change Status menu
                  Text(isAr ? 'تغيير الحالة:' : 'Change Status:', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _po.status,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 'ISSUED', child: Text('ISSUED')),
                      DropdownMenuItem(value: 'PARTIAL_RECEIVED', child: Text('PARTIAL_RECEIVED')),
                      DropdownMenuItem(value: 'RECEIVED', child: Text('RECEIVED')),
                      DropdownMenuItem(value: 'COMPLETED', child: Text('COMPLETED')),
                      DropdownMenuItem(value: 'CANCELLED', child: Text('CANCELLED')),
                    ],
                    onChanged: _isUpdating ? null : (val) {
                      if (val != null && val != _po.status) {
                        _updateStatus(val);
                      }
                    },
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.teal,
                      side: const BorderSide(color: Colors.teal),
                    ),
                    icon: const Icon(Icons.move_to_inbox_rounded, size: 16),
                    label: Text(isAr ? 'استلام البضائع (GRN)' : 'Receive Goods (GRN)'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      showDialog(
                        context: context,
                        builder: (ctx) => ReceiveGoodsDialog(preselectedPo: _po, isArabic: isAr),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.print, size: 16),
                    label: Text(isAr ? 'طباعة / PDF' : 'Print PO / PDF'),
                    onPressed: () => PoPdfPrinter.printPo(_po),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
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

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color bg;
    Color fg;
    switch (status.toUpperCase()) {
      case 'ISSUED':
        bg = Colors.blue.withValues(alpha: 0.15);
        fg = Colors.blue.shade800;
        break;
      case 'PARTIAL_RECEIVED':
        bg = Colors.amber.withValues(alpha: 0.15);
        fg = Colors.amber.shade900;
        break;
      case 'RECEIVED':
      case 'COMPLETED':
        bg = Colors.green.withValues(alpha: 0.15);
        fg = Colors.green.shade800;
        break;
      case 'CANCELLED':
        bg = Colors.red.withValues(alpha: 0.15);
        fg = Colors.red.shade800;
        break;
      default:
        bg = Colors.grey.withValues(alpha: 0.2);
        fg = Colors.grey.shade800;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }
}
