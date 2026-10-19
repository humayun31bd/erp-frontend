import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../domain/purchase_model.dart';
import '../../utils/purchase_invoice_pdf_printer.dart';
import '../../utils/procurement_document_formatter.dart';

class PurchaseDetailsDialog extends StatelessWidget {
  final PurchaseModel purchase;
  final bool isArabic;
  final VoidCallback? onEdit;

  const PurchaseDetailsDialog({
    super.key,
    required this.purchase,
    required this.isArabic,
    this.onEdit,
  });

  Widget _buildStatusBadge(String status, bool isArabic) {
    Color bg;
    Color fg;
    String label;

    switch (status.toUpperCase()) {
      case 'PAID':
        bg = Colors.green.shade50;
        fg = Colors.green.shade800;
        label = isArabic ? 'مدفوع' : 'PAID';
        break;
      case 'PARTIAL':
        bg = Colors.amber.shade50;
        fg = Colors.amber.shade900;
        label = isArabic ? 'جزئي' : 'PARTIAL';
        break;
      case 'UNPAID':
      default:
        bg = Colors.red.shade50;
        fg = Colors.red.shade800;
        label = isArabic ? 'غير مدفوع' : 'UNPAID';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    label,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(BuildContext context, String label, String value, {bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                if (copyable) ...[
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: value));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$label copied to clipboard'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Icon(Icons.copy, size: 14, color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = isArabic;
    final currency = isAr ? 'ر.س ' : 'SAR ';

    final totalVal = double.tryParse(purchase.totalAmount) ?? 0.0;
    final subtotalVal = double.tryParse(purchase.subtotalAmount) ?? (totalVal / 1.15);
    final vatVal = double.tryParse(purchase.totalVatAmount) ?? (totalVal - subtotalVal);

    final isOverdue = purchase.dueDate != null &&
        purchase.dueDate!.isBefore(DateTime.now()) &&
        purchase.paymentStatus.toUpperCase() != 'PAID';

    final dateFormat = DateFormat('yyyy-MM-dd');
    final issueDateStr = dateFormat.format(purchase.issueDate);
    final dueDateStr = purchase.dueDate != null ? dateFormat.format(purchase.dueDate!) : (isAr ? 'عند الاستلام' : 'Upon Receipt');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 840,
        constraints: const BoxConstraints(maxHeight: 760),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    child: Icon(Icons.receipt_long, color: Colors.blue.shade800),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              purchase.invoiceNumber,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 10),
                            _buildStatusBadge(purchase.paymentStatus, isAr),
                            if (isOverdue) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isAr ? 'متأخرة السداد' : 'OVERDUE',
                                  style: TextStyle(
                                    color: Colors.red.shade900,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${isAr ? 'المورد' : 'Supplier'}: ${purchase.supplierName ?? ProcurementDocumentFormatter.formatSupplierCode(purchase.supplierId)} • ${isAr ? 'تاريخ الفاتورة' : 'Issue Date'}: $issueDateStr',
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Financial KPI Stats Row
                    Row(
                      children: [
                        _buildStatCard(
                          isAr ? 'إجمالي الفاتورة' : 'Total Amount',
                          '$currency${totalVal.toStringAsFixed(2)}',
                          Colors.blue.shade800,
                          Icons.payments,
                        ),
                        const SizedBox(width: 10),
                        _buildStatCard(
                          isAr ? 'المبلغ الصافي' : 'Subtotal (Excl. VAT)',
                          '$currency${subtotalVal.toStringAsFixed(2)}',
                          Colors.teal.shade800,
                          Icons.calculate,
                        ),
                        const SizedBox(width: 10),
                        _buildStatCard(
                          isAr ? 'ضريبة القيمة المضافة (15%)' : 'Input VAT (15%)',
                          '$currency${vatVal.toStringAsFixed(2)}',
                          Colors.amber.shade800,
                          Icons.percent,
                        ),
                        const SizedBox(width: 10),
                        _buildStatCard(
                          isAr ? 'عدد الأصناف' : 'Line Items',
                          '${purchase.lineItems.length}',
                          Colors.indigo.shade800,
                          Icons.format_list_numbered,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Metadata Box
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.business, size: 16, color: Colors.blue.shade800),
                              const SizedBox(width: 6),
                              Text(
                                isAr ? 'بيانات المورد والامتثال الضريبي' : 'Supplier & Tax Compliance Details',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 18),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildMetaRow(context, isAr ? 'اسم المورد' : 'Supplier Name', purchase.supplierName ?? 'Supplier'),
                                    _buildMetaRow(context, isAr ? 'كود المورد' : 'Supplier Code', ProcurementDocumentFormatter.formatSupplierCode(purchase.supplierId), copyable: true),
                                    _buildMetaRow(context, isAr ? 'رقم الفاتورة' : 'Invoice Number', purchase.invoiceNumber, copyable: true),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildMetaRow(context, isAr ? 'تاريخ الإصدار' : 'Issue Date', issueDateStr),
                                    _buildMetaRow(context, isAr ? 'تاريخ الاستحقاق' : 'Payment Due Date', dueDateStr),
                                    _buildMetaRow(
                                      context,
                                      isAr ? 'تاريخ الإنشاء' : 'Recorded At',
                                      DateFormat('yyyy-MM-dd HH:mm').format(purchase.createdAt),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Line Items Table Section
                    Text(
                      isAr ? 'أصناف وبنود فاتورة الشراء:' : 'Purchased Line Items Breakdown:',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                            dataRowMinHeight: 42,
                            dataRowMaxHeight: 46,
                            columnSpacing: 18,
                            columns: [
                              const DataColumn(label: Text('#')),
                              DataColumn(label: Text(isAr ? 'الوصف' : 'Description')),
                              DataColumn(label: Text(isAr ? 'الكمية' : 'Qty')),
                              DataColumn(label: Text(isAr ? 'سعر الوحدة' : 'Unit Price')),
                              DataColumn(label: Text(isAr ? 'الضريبة' : 'VAT Rate')),
                              DataColumn(label: Text(isAr ? 'المجموع الفرعي' : 'Subtotal')),
                              DataColumn(label: Text(isAr ? 'مبلغ الضريبة' : 'VAT Amount')),
                              DataColumn(label: Text(isAr ? 'الإجمالي' : 'Total (SAR)')),
                            ],
                            rows: purchase.lineItems.asMap().entries.map((entry) {
                              final idx = entry.key + 1;
                              final item = entry.value;
                              return DataRow(
                                cells: [
                                  DataCell(Text('$idx')),
                                  DataCell(Text(item.description, style: const TextStyle(fontWeight: FontWeight.bold))),
                                  DataCell(Text('${item.quantity}')),
                                  DataCell(Text('$currency${item.unitPrice.toStringAsFixed(2)}')),
                                  DataCell(Text('${item.vatRate.toStringAsFixed(0)}%')),
                                  DataCell(Text('$currency${item.subtotalAmount.toStringAsFixed(2)}')),
                                  DataCell(Text('$currency${item.vatAmount.toStringAsFixed(2)}')),
                                  DataCell(Text('$currency${item.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold))),
                                ],
                              );
                            }).toList(),
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
                  OutlinedButton.icon(
                    icon: const Icon(Icons.print, size: 18),
                    label: Text(isAr ? 'طباعة فاتورة الشراء الضريبية' : 'Print Tax Invoice (PDF)'),
                    onPressed: () => PurchaseInvoicePdfPrinter.printPurchaseInvoice(purchase),
                  ),
                  Row(
                    children: [
                      if (onEdit != null) ...[
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.edit, size: 16),
                          label: Text(isAr ? 'تعديل الفاتورة' : 'Edit Invoice'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            onEdit!();
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(isAr ? 'إغلاق' : 'Close'),
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
