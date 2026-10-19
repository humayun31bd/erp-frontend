import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../domain/procurement_models.dart';
import '../../utils/bill_pdf_printer.dart';
import '../../utils/procurement_document_formatter.dart';

class BillDetailsDialog extends StatelessWidget {
  final SupplierBillModel bill;
  final bool isArabic;
  final VoidCallback? onPaymentClicked;

  const BillDetailsDialog({
    super.key,
    required this.bill,
    required this.isArabic,
    this.onPaymentClicked,
  });

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    switch (status.toUpperCase()) {
      case 'PAID':
        bg = Colors.green.shade50;
        fg = Colors.green.shade800;
        break;
      case 'PARTIAL':
        bg = Colors.amber.shade50;
        fg = Colors.amber.shade900;
        break;
      case 'UNPAID':
      default:
        bg = Colors.red.shade50;
        fg = Colors.red.shade800;
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

  Widget _buildMetaRow(BuildContext context, String label, String value, {bool copyable = false, Widget? trailingBadge}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
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
                if (trailingBadge != null) ...[
                  const SizedBox(width: 6),
                  trailingBadge,
                ],
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

    final totalVal = double.tryParse(bill.totalAmount) ?? 0.0;
    final paidVal = double.tryParse(bill.paidAmount) ?? 0.0;
    final discountVal = double.tryParse(bill.discountAmount) ?? 0.0;
    final subtotalVal = double.tryParse(bill.subtotalAmount) ?? (totalVal / 1.15);
    final taxableVal = (subtotalVal - discountVal).clamp(0.0, double.infinity);
    final vatVal = double.tryParse(bill.vatAmount) ?? (totalVal - taxableVal);
    final balanceVal = (totalVal - paidVal).clamp(0.0, double.infinity);

    final double paidPercentage = totalVal > 0 ? ((paidVal / totalVal) * 100).clamp(0.0, 100.0) : 0.0;
    final isOverdue = bill.dueDate != null && bill.dueDate!.isBefore(DateTime.now()) && balanceVal > 0.01;

    final dateFormat = DateFormat('yyyy-MM-dd');
    final issueDateStr = dateFormat.format(bill.issueDate);
    final dueDateStr = bill.dueDate != null ? dateFormat.format(bill.dueDate!) : (isAr ? 'عند الاستلام' : 'Upon Receipt');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 820,
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
                    backgroundColor: Colors.indigo.shade50,
                    child: Icon(Icons.receipt_long, color: Colors.indigo.shade800),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              bill.billNumber,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 10),
                            _buildStatusBadge(bill.paymentStatus),
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
                          '${isAr ? 'المورد' : 'Supplier'}: ${bill.supplierName} • ${isAr ? 'تاريخ الفاتورة' : 'Issue Date'}: $issueDateStr',
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
                    // Financial Stats Row
                    Row(
                      children: [
                        _buildStatCard(
                          isAr ? 'إجمالي الفاتورة' : 'Total Invoiced',
                          'SAR ${totalVal.toStringAsFixed(2)}',
                          Colors.indigo.shade800,
                          Icons.receipt,
                        ),
                        const SizedBox(width: 10),
                        _buildStatCard(
                          isAr ? 'المدفوع حتى الآن' : 'Paid to Date',
                          'SAR ${paidVal.toStringAsFixed(2)}',
                          Colors.green.shade800,
                          Icons.check_circle,
                        ),
                        const SizedBox(width: 10),
                        _buildStatCard(
                          isAr ? 'الرصيد المستحق' : 'Balance Due',
                          'SAR ${balanceVal.toStringAsFixed(2)}',
                          balanceVal > 0 ? Colors.red.shade800 : Colors.green.shade800,
                          Icons.account_balance_wallet,
                        ),
                        const SizedBox(width: 10),
                        _buildStatCard(
                          isAr ? 'نسبة السداد' : 'Paid Ratio',
                          '${paidPercentage.toStringAsFixed(1)}%',
                          paidPercentage >= 100 ? Colors.green.shade700 : Colors.teal.shade700,
                          Icons.donut_large,
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Payment Progress Bar
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isAr ? 'مؤشر تسوية الذمم الدائنة' : 'Accounts Payable Settlement Progress',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                              ),
                              Text(
                                '${paidPercentage.toStringAsFixed(1)}% ${isAr ? 'مسدد' : 'Settled'} (SAR ${paidVal.toStringAsFixed(2)} / SAR ${totalVal.toStringAsFixed(2)})',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: paidPercentage >= 100 ? Colors.green.shade800 : Colors.teal.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: totalVal > 0 ? (paidVal / totalVal).clamp(0.0, 1.0) : 0.0,
                              minHeight: 10,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                paidPercentage >= 100
                                    ? Colors.green.shade600
                                    : (paidPercentage > 0 ? Colors.amber.shade700 : Colors.red.shade400),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Two Column Grid
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column: Bill & Supplier Details
                        Expanded(
                          child: Container(
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
                                    Icon(Icons.business, size: 16, color: Colors.indigo.shade800),
                                    const SizedBox(width: 6),
                                    Text(
                                      isAr ? 'بيانات المورد والتوثيق' : 'Supplier & Documentation',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 18),
                                _buildMetaRow(context, isAr ? 'اسم المورد' : 'Supplier Name', bill.supplierName),
                                _buildMetaRow(context, isAr ? 'كود المورد' : 'Supplier Code', ProcurementDocumentFormatter.formatSupplierCode(bill.supplierId), copyable: true),
                                _buildMetaRow(
                                  context,
                                  isAr ? 'أمر الشراء (PO)' : 'Linked PO #',
                                  bill.poId != null && bill.poId!.isNotEmpty ? ProcurementDocumentFormatter.formatPoNumber(bill.poId, bill.poId) : (isAr ? 'غير محدد' : 'None'),
                                  copyable: bill.poId != null && bill.poId!.isNotEmpty,
                                ),
                                _buildMetaRow(
                                  context,
                                  isAr ? 'سند الاستلام (GRN)' : 'Linked GRN #',
                                  bill.grnId != null && bill.grnId!.isNotEmpty ? ProcurementDocumentFormatter.formatGrnNumber(bill.grnId, bill.grnId) : (isAr ? 'غير محدد' : 'None'),
                                  copyable: bill.grnId != null && bill.grnId!.isNotEmpty,
                                ),
                                _buildMetaRow(context, isAr ? 'تاريخ الإصدار' : 'Issue Date', issueDateStr),
                                _buildMetaRow(
                                  context,
                                  isAr ? 'تاريخ الاستحقاق' : 'Payment Due Date',
                                  dueDateStr,
                                  trailingBadge: isOverdue
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade50,
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: Colors.red.shade300),
                                          ),
                                          child: Text(
                                            isAr ? 'متأخر' : 'Overdue',
                                            style: TextStyle(fontSize: 10, color: Colors.red.shade800, fontWeight: FontWeight.bold),
                                          ),
                                        )
                                      : null,
                                ),
                                _buildMetaRow(
                                  context,
                                  isAr ? 'تاريخ الإنشاء' : 'Created At',
                                  DateFormat('yyyy-MM-dd HH:mm').format(bill.createdAt),
                                ),
                                if (bill.referenceDocName != null && bill.referenceDocName!.isNotEmpty)
                                  _buildMetaRow(
                                    context,
                                    isAr ? 'المستند المرجعي' : 'Ref Document',
                                    bill.referenceDocName!,
                                    copyable: true,
                                    trailingBadge: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.indigo.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: Colors.indigo.shade200),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.attachment, size: 12, color: Colors.indigo.shade700),
                                          const SizedBox(width: 3),
                                          Text(
                                            isAr ? 'مرفق' : 'Attached',
                                            style: TextStyle(fontSize: 10, color: Colors.indigo.shade700, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Right Column: Financial & Tax Breakdown
                        Expanded(
                          child: Container(
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
                                    Icon(Icons.calculate, size: 16, color: Colors.indigo.shade800),
                                    const SizedBox(width: 6),
                                    Text(
                                      isAr ? 'التفصيل المالي والضريبي' : 'Financial & Tax Breakdown',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 18),
                                _buildFinancialRow(
                                  isAr ? 'المجموع الفرعي (قبل الخصم)' : 'Gross Subtotal',
                                  'SAR ${subtotalVal.toStringAsFixed(2)}',
                                ),
                                if (discountVal > 0)
                                  _buildFinancialRow(
                                    isAr ? 'خصم المورد' : 'Supplier Discount',
                                    '- SAR ${discountVal.toStringAsFixed(2)}',
                                    highlightColor: Colors.amber.shade900,
                                    isBold: true,
                                  ),
                                if (discountVal > 0)
                                  _buildFinancialRow(
                                    isAr ? 'الوعاء الخاضع للضريبة' : 'Net Taxable Subtotal',
                                    'SAR ${taxableVal.toStringAsFixed(2)}',
                                    highlightColor: Colors.indigo.shade800,
                                  ),
                                _buildFinancialRow(
                                  isAr ? 'ضريبة القيمة المضافة (15% VAT)' : 'Value Added Tax (15% VAT)',
                                  'SAR ${vatVal.toStringAsFixed(2)}',
                                  highlightColor: Colors.blue.shade900,
                                ),
                                const Divider(height: 16),
                                _buildFinancialRow(
                                  isAr ? 'إجمالي الفاتورة المستحق' : 'Total Invoice Amount',
                                  'SAR ${totalVal.toStringAsFixed(2)}',
                                  isBold: true,
                                  fontSize: 14,
                                ),
                                _buildFinancialRow(
                                  isAr ? 'المبالغ المسددة' : 'Disbursed / Paid Amount',
                                  'SAR ${paidVal.toStringAsFixed(2)}',
                                  highlightColor: Colors.green.shade800,
                                  isBold: true,
                                ),
                                const Divider(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: balanceVal > 0 ? Colors.red.shade50 : Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: balanceVal > 0 ? Colors.red.shade200 : Colors.green.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        isAr ? 'صافي المتبقي للذمة' : 'Net Remaining AP Balance',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: balanceVal > 0 ? Colors.red.shade900 : Colors.green.shade900,
                                        ),
                                      ),
                                      Text(
                                        'SAR ${balanceVal.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: balanceVal > 0 ? Colors.red.shade900 : Colors.green.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (bill.remarks != null && bill.remarks!.trim().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.notes, size: 18, color: Colors.amber.shade900),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isAr ? 'ملاحظات ومرجع الفاتورة:' : 'Remarks & Invoice Reference:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber.shade900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    bill.remarks!,
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                    label: Text(isAr ? 'طباعة سند الفاتورة' : 'Print AP Voucher (PDF)'),
                    onPressed: () => BillPdfPrinter.printBill(bill),
                  ),
                  Row(
                    children: [
                      if (balanceVal > 0.01 && onPaymentClicked != null) ...[
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.payments, size: 18),
                          label: Text(isAr ? 'تسجيل دفعة ذمم دائنة' : 'Make AP Payment'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            onPaymentClicked!();
                          },
                        ),
                        const SizedBox(width: 10),
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

  Widget _buildFinancialRow(String label, String value, {bool isBold = false, double fontSize = 12, Color? highlightColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: highlightColor ?? (isBold ? Colors.black : Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }
}
