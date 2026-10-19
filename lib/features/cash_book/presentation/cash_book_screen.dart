import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cash_book_provider.dart';
import '../domain/cash_book_model.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CashBookScreen extends ConsumerWidget {
  const CashBookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final cashBookState = ref.watch(cashBookEntriesProvider);
    final summaryState = ref.watch(cashBookSummaryProvider);
    final currencyFormatter = NumberFormat('#,##0.00');

    // Fallback sample data matching standard presentation format when DB entries are empty
    final List<Map<String, dynamic>> sampleData = [
      {
        'date': '01-Sep-2026',
        'voucherNo': '–',
        'particulars': 'Opening Balance',
        'debit': null,
        'credit': null,
        'balance': 100000.0,
      },
      {
        'date': '03-Sep-2026',
        'voucherNo': 'CV-0012',
        'particulars': 'Cash withdrawn from Sonali Bank',
        'debit': 200000.0,
        'credit': null,
        'balance': 300000.0,
      },
      {
        'date': '10-Sep-2026',
        'voucherNo': 'PV-0045',
        'particulars': 'Office supplies purchase',
        'debit': null,
        'credit': 25000.0,
        'balance': 275000.0,
      },
      {
        'date': '22-Sep-2026',
        'voucherNo': 'PV-0061',
        'particulars': 'Training refreshments',
        'debit': null,
        'credit': 25000.0,
        'balance': 250000.0,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'دفتر النقدية' : 'Cash Book Register'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.goNamed('createCashBook'),
            tooltip: isArabic ? 'إضافة معاملة' : 'Add Transaction',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Summary Cards
            summaryState.when(
              data: (summary) => Row(
                children: [
                  Expanded(child: _buildSummaryCard(isArabic ? 'إجمالي المقبوضات (Dr)' : 'Total Receipts (Dr)', summary.totalIn, Colors.green)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSummaryCard(isArabic ? 'إجمالي المدفوعات (Cr)' : 'Total Payments (Cr)', summary.totalOut, Colors.red)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSummaryCard(isArabic ? 'رصيد النقدية الحالي' : 'Closing Cash Balance', summary.closingBalance, Colors.blue)),
                ],
              ),
              loading: () => const Padding(padding: EdgeInsets.all(16), child: LinearProgressIndicator()),
              error: (e, s) => const SizedBox(),
            ),
            const SizedBox(height: 20),

            // Cash Book Data Table
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isArabic ? 'سجل المقبوضات والمدفوعات النقدي' : 'Cash Receipts & Payments Ledger',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => ref.invalidate(cashBookEntriesProvider),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: Text(isArabic ? 'تحديث' : 'Refresh'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    cashBookState.when(
                      data: (entries) {
                        List<DataRow> rows = [];
                        double runningBalance = 100000.0;
                        double totalDebitSum = 0;
                        double totalCreditSum = 0;

                        if (entries.isNotEmpty) {
                          rows = [];
                          runningBalance = 0.0;
                          final sortedEntries = List<CashBookModel>.from(entries)..sort((a, b) => a.entryDate.compareTo(b.entryDate));

                          for (var entry in sortedEntries) {
                            final amt = double.tryParse(entry.amount) ?? 0.0;
                            final isReceipt = entry.type.toUpperCase() == 'IN' || entry.type.toUpperCase() == 'RECEIPT';
                            
                            if (isReceipt) {
                              runningBalance += amt;
                              totalDebitSum += amt;
                            } else {
                              runningBalance -= amt;
                              totalCreditSum += amt;
                            }

                            final dateFormatted = DateFormat('dd-MMM-yyyy').format(entry.entryDate);
                            final voucherNo = entry.referenceId?.isNotEmpty == true ? entry.referenceId! : '–';
                            final particulars = entry.description?.isNotEmpty == true ? entry.description! : (entry.category ?? 'Cash Transaction');

                            rows.add(
                              DataRow(
                                cells: [
                                  DataCell(Text(dateFormatted)),
                                  DataCell(Text(voucherNo, style: const TextStyle(fontWeight: FontWeight.w500))),
                                  DataCell(Text(particulars)),
                                  DataCell(Text(isReceipt ? currencyFormatter.format(amt) : '', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500))),
                                  DataCell(Text(!isReceipt ? currencyFormatter.format(amt) : '', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500))),
                                  DataCell(Text(currencyFormatter.format(runningBalance), style: const TextStyle(fontWeight: FontWeight.bold))),
                                ],
                              ),
                            );
                          }
                        }


                        // Summary / Closing Balance Footer Row
                        final footerRow = DataRow(
                          color: WidgetStateProperty.all(Colors.blue.shade50),
                          cells: [
                            const DataCell(Text('')),
                            const DataCell(Text('')),
                            DataCell(Text(
                              isArabic ? 'إجمالي المقبوضات/المدفوعات والرصيد النهائي' : 'Total / Closing Balance',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
                            )),
                            DataCell(Text(
                              currencyFormatter.format(totalDebitSum),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13),
                            )),
                            DataCell(Text(
                              currencyFormatter.format(totalCreditSum),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 13),
                            )),
                            DataCell(Text(
                              currencyFormatter.format(runningBalance),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 13),
                            )),
                          ],
                        );

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                            columns: const [
                              DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Voucher No.', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Particulars', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Receipts (Dr)', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                              DataColumn(label: Text('Payments (Cr)', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                              DataColumn(label: Text('Balance', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            ],
                            rows: [...rows, footerRow],
                          ),
                        );
                      },
                      loading: () => const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator())),
                      error: (error, stack) => Center(child: Text('Error: $error')),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color) {
    final formatter = NumberFormat('#,##0.00');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade800, fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            formatter.format(amount),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
