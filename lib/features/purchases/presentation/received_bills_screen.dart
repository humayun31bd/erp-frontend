import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:erp_frontend/app.dart';
import '../domain/procurement_models.dart';
import '../providers/procurement_provider.dart';
import '../utils/bill_pdf_printer.dart';
import '../utils/procurement_document_formatter.dart';
import 'widgets/bill_details_dialog.dart';
import 'widgets/bill_csv_import_dialog.dart';
import 'widgets/record_received_bill_dialog.dart';
import 'widgets/supplier_selection_modal.dart';

class ReceivedBillsScreen extends ConsumerStatefulWidget {
  const ReceivedBillsScreen({super.key});

  @override
  ConsumerState<ReceivedBillsScreen> createState() => _ReceivedBillsScreenState();
}

class _ReceivedBillsScreenState extends ConsumerState<ReceivedBillsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'ALL';
  String? _selectedSupplier;
  String _agingFilter = 'ALL'; // ALL, OVERDUE, DUE_7_DAYS
  String _sortBy = 'DATE_DESC'; // DATE_DESC, DATE_ASC, TOTAL_DESC, BALANCE_DESC, BILL_NO
  bool _isTableView = false; // false = Card View, true = Grid / Table View

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetails(SupplierBillModel bill, bool isArabic) {
    final balance = (double.tryParse(bill.totalAmount) ?? 0.0) - (double.tryParse(bill.paidAmount) ?? 0.0);
    showDialog(
      context: context,
      builder: (ctx) => BillDetailsDialog(
        bill: bill,
        isArabic: isArabic,
        onPaymentClicked: balance > 0.01 ? () => _showPaymentDialog(context, bill, balance) : null,
      ),
    );
  }

  void _openCsvImport(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (ctx) => BillCsvImportDialog(isArabic: isArabic),
    );
  }

  void _openSupplierSelectionModal(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (ctx) => SupplierSelectionModal(
        isArabic: isArabic,
        currentSelectedSupplierId: null,
        onSelected: (supplier) {
          setState(() {
            _selectedSupplier = supplier?.name;
          });
        },
      ),
    );
  }

  void _printSingleBill(SupplierBillModel bill) {
    BillPdfPrinter.printBill(bill);
  }

  void _printRegisterReport(List<SupplierBillModel> filtered, bool isArabic) {
    if (filtered.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic ? 'لا توجد فواتير لطباعتها' : 'No bills available to print'),
          backgroundColor: Colors.amber.shade800,
        ),
      );
      return;
    }
    final title = isArabic
        ? 'سجل حسابات الموردين والذمم الدائنة (AP Ledger Report)'
        : 'Accounts Payable (AP) & Received Bills Audit Register';
    BillPdfPrinter.printBillRegister(bills: filtered, title: title);
  }

  List<SupplierBillModel> _applyFiltersAndSort(List<SupplierBillModel> bills) {
    final now = DateTime.now();

    final filtered = bills.where((b) {
      final query = _searchQuery.trim().toLowerCase();
      final matchQuery = query.isEmpty ||
          b.billNumber.toLowerCase().contains(query) ||
          b.supplierName.toLowerCase().contains(query) ||
          b.supplierId.toLowerCase().contains(query) ||
          (b.poId ?? '').toLowerCase().contains(query) ||
          (b.grnId ?? '').toLowerCase().contains(query) ||
          (b.remarks ?? '').toLowerCase().contains(query);

      bool matchStatus = true;
      if (_selectedStatus != 'ALL') {
        matchStatus = b.paymentStatus.toUpperCase() == _selectedStatus;
      }

      final matchSupplier = _selectedSupplier == null ||
          _selectedSupplier == 'ALL' ||
          b.supplierName == _selectedSupplier ||
          b.supplierId == _selectedSupplier;

      bool matchAging = true;
      final total = double.tryParse(b.totalAmount) ?? 0.0;
      final paid = double.tryParse(b.paidAmount) ?? 0.0;
      final balance = total - paid;

      if (_agingFilter == 'OVERDUE') {
        matchAging = b.dueDate != null && b.dueDate!.isBefore(now) && balance > 0.01;
      } else if (_agingFilter == 'DUE_7_DAYS') {
        if (b.dueDate == null || balance <= 0.01) {
          matchAging = false;
        } else {
          final diffDays = b.dueDate!.difference(now).inDays;
          matchAging = diffDays >= 0 && diffDays <= 7;
        }
      }

      return matchQuery && matchStatus && matchSupplier && matchAging;
    }).toList();

    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'DATE_ASC':
          return a.issueDate.compareTo(b.issueDate);
        case 'TOTAL_DESC':
          final totA = double.tryParse(a.totalAmount) ?? 0.0;
          final totB = double.tryParse(b.totalAmount) ?? 0.0;
          return totB.compareTo(totA);
        case 'BALANCE_DESC':
          final balA = (double.tryParse(a.totalAmount) ?? 0.0) - (double.tryParse(a.paidAmount) ?? 0.0);
          final balB = (double.tryParse(b.totalAmount) ?? 0.0) - (double.tryParse(b.paidAmount) ?? 0.0);
          return balB.compareTo(balA);
        case 'BILL_NO':
          return a.billNumber.compareTo(b.billNumber);
        case 'DATE_DESC':
        default:
          return b.issueDate.compareTo(a.issueDate);
      }
    });

    return filtered;
  }

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
        style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final billsAsync = ref.watch(supplierBillsProvider);
    final theme = Theme.of(context);
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.receipt_long, color: Colors.indigo.shade800, size: 20),
            ),
            const SizedBox(width: 10),
            Text(isArabic ? 'فواتير الموردين والذمم الدائنة (AP)' : 'Received Bills & Accounts Payable (AP)'),
          ],
        ),
        actions: [
          // View Mode Switcher
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => setState(() => _isTableView = false),
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: !_isTableView ? Colors.indigo.shade700 : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.grid_view_rounded,
                          size: 16,
                          color: !_isTableView ? Colors.white : Colors.grey.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isArabic ? 'كروت' : 'Cards',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: !_isTableView ? Colors.white : Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => setState(() => _isTableView = true),
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _isTableView ? Colors.indigo.shade700 : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.table_chart_rounded,
                          size: 16,
                          color: _isTableView ? Colors.white : Colors.grey.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isArabic ? 'جدول' : 'Grid',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _isTableView ? Colors.white : Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Print Register Button
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: isArabic ? 'طباعة تقرير سجل فواتير الذمم الدائنة' : 'Print AP Register Report',
            onPressed: () {
              final bills = billsAsync.value ?? [];
              final filtered = _applyFiltersAndSort(bills);
              _printRegisterReport(filtered, isArabic);
            },
          ),

          // Import CSV Button
          OutlinedButton.icon(
            icon: const Icon(Icons.file_upload_outlined, size: 18),
            label: Text(isArabic ? 'استيراد CSV' : 'Import CSV'),
            onPressed: () => _openCsvImport(context, isArabic),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(width: 8),

          // Supplier Popup Modal (Search, Grid View, Filter, Selection)
          OutlinedButton.icon(
            icon: const Icon(Icons.person_search_rounded, size: 18),
            label: Text(isArabic ? 'دليل وبحث الموردين' : 'Suppliers Modal'),
            onPressed: () => _openSupplierSelectionModal(context, isArabic),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(width: 8),

          // Record Received Bill Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: Text(isArabic ? 'تسجيل فاتورة جديدة' : 'Record Bill'),
            onPressed: () => _showCreateBillDialog(context, isArabic),
          ),
          const SizedBox(width: 8),

          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: isArabic ? 'تحديث' : 'Refresh',
            onPressed: () => ref.invalidate(supplierBillsProvider),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: billsAsync.when(
        data: (bills) {
          final now = DateTime.now();

          // Compute KPI statistics
          final totalInvoiced = bills.fold<double>(0.0, (sum, b) => sum + (double.tryParse(b.totalAmount) ?? 0.0));
          final totalPaid = bills.fold<double>(0.0, (sum, b) => sum + (double.tryParse(b.paidAmount) ?? 0.0));
          final totalBalance = (totalInvoiced - totalPaid).clamp(0.0, double.infinity);
          final unpaidCount = bills.where((b) => b.paymentStatus.toUpperCase() == 'UNPAID').length;
          final partialCount = bills.where((b) => b.paymentStatus.toUpperCase() == 'PARTIAL').length;
          final paidCount = bills.where((b) => b.paymentStatus.toUpperCase() == 'PAID').length;
          final overdueCount = bills.where((b) {
            final bal = (double.tryParse(b.totalAmount) ?? 0.0) - (double.tryParse(b.paidAmount) ?? 0.0);
            return b.dueDate != null && b.dueDate!.isBefore(now) && bal > 0.01;
          }).length;

          // Unique suppliers list for filter dropdown
          final uniqueSuppliers = bills.map((b) => b.supplierName).toSet().toList()..sort();

          // Apply filters
          final filtered = _applyFiltersAndSort(bills);

          final hasActiveFilters = _searchQuery.isNotEmpty ||
              _selectedStatus != 'ALL' ||
              _selectedSupplier != null ||
              _agingFilter != 'ALL' ||
              _sortBy != 'DATE_DESC';

          return Column(
            children: [
              // KPI Statistics Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    _buildKpiCard(
                      title: isArabic ? 'إجمالي الفواتير المسجلة' : 'Total Invoiced (AP)',
                      value: 'SAR ${totalInvoiced.toStringAsFixed(2)}',
                      icon: Icons.receipt_long,
                      color: Colors.indigo.shade800,
                      subtitle: '${bills.length} ${isArabic ? 'فاتورة مورد' : 'bills total'}',
                    ),
                    const SizedBox(width: 10),
                    _buildKpiCard(
                      title: isArabic ? 'إجمالي المبالغ المسددة' : 'Disbursed / Paid',
                      value: 'SAR ${totalPaid.toStringAsFixed(2)}',
                      icon: Icons.check_circle_outline,
                      color: Colors.green.shade800,
                      subtitle: '$paidCount ${isArabic ? 'مسددة بالكامل' : 'fully settled'}',
                    ),
                    const SizedBox(width: 10),
                    _buildKpiCard(
                      title: isArabic ? 'الرصيد المستحق (ذمم دائنة)' : 'AP Balance Due',
                      value: 'SAR ${totalBalance.toStringAsFixed(2)}',
                      icon: Icons.account_balance_wallet,
                      color: totalBalance > 0 ? Colors.red.shade800 : Colors.green.shade800,
                      subtitle: '$unpaidCount ${isArabic ? 'غير مسددة' : 'unpaid'} • $partialCount ${isArabic ? 'جزئية' : 'partial'}',
                    ),
                    const SizedBox(width: 10),
                    _buildKpiCard(
                      title: isArabic ? 'فواتير متأخرة السداد' : 'Overdue Bills',
                      value: '$overdueCount',
                      icon: Icons.warning_amber_rounded,
                      color: overdueCount > 0 ? Colors.orange.shade800 : Colors.grey.shade600,
                      subtitle: isArabic ? 'تجاوزت تاريخ الاستحقاق' : 'Past due date',
                    ),
                  ],
                ),
              ),

              // Search & Filter Toolbar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Search Field
                        Expanded(
                          flex: 5,
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: isArabic
                                  ? 'بحث برقم الفاتورة، اسم المورد، أمر الشراء، الملاحظات...'
                                  : 'Search bill #, supplier, PO #, GRN #, or remarks...',
                              prefixIcon: const Icon(Icons.search, size: 20),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              isDense: true,
                            ),
                            onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Supplier Dropdown & Modal Button
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: _selectedSupplier,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    labelText: isArabic ? 'المورد' : 'Supplier',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    isDense: true,
                                  ),
                                  items: [
                                    DropdownMenuItem<String>(
                                      value: null,
                                      child: Text(isArabic ? 'جميع الموردين' : 'All Suppliers'),
                                    ),
                                    if (_selectedSupplier != null && !uniqueSuppliers.contains(_selectedSupplier))
                                      DropdownMenuItem(
                                        value: _selectedSupplier,
                                        child: Text(_selectedSupplier!, overflow: TextOverflow.ellipsis),
                                      ),
                                    ...uniqueSuppliers.map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis))),
                                  ],
                                  onChanged: (val) => setState(() => _selectedSupplier = val),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Tooltip(
                                message: isArabic ? 'فتح نافذة اختيار وبحث المورد (شبكة / جدول)' : 'Open Supplier Modal (Search, Grid, Filters)',
                                child: InkWell(
                                  onTap: () => _openSupplierSelectionModal(context, isArabic),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.all(9),
                                    decoration: BoxDecoration(
                                      color: Colors.indigo.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.indigo.shade200),
                                    ),
                                    child: Icon(Icons.person_search_rounded, size: 20, color: Colors.indigo.shade800),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Aging Dropdown
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String>(
                            initialValue: _agingFilter,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: isArabic ? 'الاستحقاق' : 'Due Status',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              isDense: true,
                            ),
                            items: [
                              DropdownMenuItem(value: 'ALL', child: Text(isArabic ? 'كل التواريخ' : 'All Due Dates')),
                              DropdownMenuItem(value: 'OVERDUE', child: Text(isArabic ? 'متأخرة السداد' : 'Overdue Only')),
                              DropdownMenuItem(value: 'DUE_7_DAYS', child: Text(isArabic ? 'خلال 7 أيام' : 'Due in 7 Days')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _agingFilter = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Sort Dropdown
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String>(
                            initialValue: _sortBy,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: isArabic ? 'الترتيب' : 'Sort By',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              isDense: true,
                            ),
                            items: [
                              DropdownMenuItem(value: 'DATE_DESC', child: Text(isArabic ? 'الأحدث إصداراً' : 'Newest First')),
                              DropdownMenuItem(value: 'DATE_ASC', child: Text(isArabic ? 'الأقدم إصداراً' : 'Oldest First')),
                              DropdownMenuItem(value: 'TOTAL_DESC', child: Text(isArabic ? 'الأعلى مبلغاً' : 'Highest Amount')),
                              DropdownMenuItem(value: 'BALANCE_DESC', child: Text(isArabic ? 'الأعلى رصيداً مستحقاً' : 'Highest Balance Due')),
                              DropdownMenuItem(value: 'BILL_NO', child: Text(isArabic ? 'رقم الفاتورة' : 'Bill Number')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _sortBy = val);
                            },
                          ),
                        ),

                        if (hasActiveFilters) ...[
                          const SizedBox(width: 8),
                          Tooltip(
                            message: isArabic ? 'إعادة ضبط الفلاتر' : 'Reset Filters',
                            child: IconButton(
                              icon: const Icon(Icons.filter_alt_off),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _selectedStatus = 'ALL';
                                  _selectedSupplier = null;
                                  _agingFilter = 'ALL';
                                  _sortBy = 'DATE_DESC';
                                });
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Live Status Chips Row
                    Row(
                      children: [
                        _buildFilterChip('ALL', isArabic ? 'الكل' : 'All', bills.length, Colors.indigo),
                        const SizedBox(width: 8),
                        _buildFilterChip('UNPAID', isArabic ? 'غير مسددة' : 'Unpaid', unpaidCount, Colors.red),
                        const SizedBox(width: 8),
                        _buildFilterChip('PARTIAL', isArabic ? 'مسددة جزئياً' : 'Partial', partialCount, Colors.amber),
                        const SizedBox(width: 8),
                        _buildFilterChip('PAID', isArabic ? 'مسددة بالكامل' : 'Paid', paidCount, Colors.green),
                        const Spacer(),
                        Text(
                          '${filtered.length} ${isArabic ? 'فاتورة معروضة' : 'bills matching'}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Content: Card View vs Table Grid View
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              hasActiveFilters
                                  ? (isArabic ? 'لا توجد فواتير تطابق شروط البحث والفلاتر.' : 'No bills match your filters and search.')
                                  : (isArabic ? 'لم يتم تسجيل أي فواتير موردين حتى الآن.' : 'No supplier bills recorded yet.'),
                              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 16),
                            if (hasActiveFilters)
                              OutlinedButton.icon(
                                icon: const Icon(Icons.refresh),
                                label: Text(isArabic ? 'إلغاء الفلاتر' : 'Reset Filters'),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                    _selectedStatus = 'ALL';
                                    _selectedSupplier = null;
                                    _agingFilter = 'ALL';
                                    _sortBy = 'DATE_DESC';
                                  });
                                },
                              )
                            else
                              ElevatedButton.icon(
                                icon: const Icon(Icons.add),
                                label: Text(isArabic ? 'تسجيل أول فاتورة مورد' : 'Record First Bill'),
                                onPressed: () => _showCreateBillDialog(context, isArabic),
                              ),
                          ],
                        ),
                      )
                    : _isTableView
                        ? _buildGridView(filtered, isArabic, theme)
                        : _buildCardView(filtered, isArabic, theme),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Loading supplier bills & AP ledger...'),
            ],
          ),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
              const SizedBox(height: 10),
              Text('Error loading AP bills: $err', style: TextStyle(color: Colors.red.shade800)),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                onPressed: () => ref.invalidate(supplierBillsProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label, int count, MaterialColor color) {
    final isSelected = _selectedStatus == key;
    return InkWell(
      onTap: () => setState(() => _selectedStatus = key),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.shade700 : color.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color.shade800 : color.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : color.shade800,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.25) : color.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : color.shade900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardView(List<SupplierBillModel> bills, bool isArabic, ThemeData theme) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final now = DateTime.now();

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth >= 1500) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth >= 1050) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth >= 680) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: 290,
          ),
          itemCount: bills.length,
          itemBuilder: (context, index) {
            final bill = bills[index];
            final total = double.tryParse(bill.totalAmount) ?? 0.0;
            final paid = double.tryParse(bill.paidAmount) ?? 0.0;
            final balance = (total - paid).clamp(0.0, double.infinity);
            final paidRatio = total > 0 ? (paid / total).clamp(0.0, 1.0) : 0.0;
            final isOverdue = bill.dueDate != null && bill.dueDate!.isBefore(now) && balance > 0.01;

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isOverdue ? Colors.red.shade300 : Colors.grey.shade200,
                  width: isOverdue ? 1.5 : 1.0,
                ),
              ),
              child: InkWell(
                onTap: () => _openDetails(bill, isArabic),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card Top Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.indigo.shade50,
                                child: Icon(Icons.receipt_long, size: 16, color: Colors.indigo.shade800),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                bill.billNumber,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              if (isOverdue) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    isArabic ? 'متأخر' : 'OVERDUE',
                                    style: TextStyle(
                                      color: Colors.red.shade900,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              _buildStatusBadge(bill.paymentStatus),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Supplier Name & Badges
                      Text(
                        bill.supplierName,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Linked PO / GRN
                      Row(
                        children: [
                          if (bill.poId != null && bill.poId!.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Text(
                                'PO: ${ProcurementDocumentFormatter.formatPoNumber(bill.poId, bill.poId)}',
                                style: TextStyle(fontSize: 10, color: Colors.blue.shade900, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          if (bill.grnId != null && bill.grnId!.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.teal.shade200),
                              ),
                              child: Text(
                                'GRN: ${ProcurementDocumentFormatter.formatGrnNumber(bill.grnId, bill.grnId)}',
                                style: TextStyle(fontSize: 10, color: Colors.teal.shade900, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            '${isArabic ? 'إصدار' : 'Issued'}: ${dateFormat.format(bill.issueDate)}',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Financial Progress Box
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isArabic ? 'إجمالي الفاتورة' : 'Total Amount',
                                      style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                    ),
                                    Text(
                                      'SAR ${total.toStringAsFixed(2)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      isArabic ? 'المتبقي للسداد' : 'Balance Due',
                                      style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                    ),
                                    Text(
                                      'SAR ${balance.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: balance > 0.01 ? Colors.red.shade700 : Colors.green.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: paidRatio,
                                minHeight: 6,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  paidRatio >= 1.0
                                      ? Colors.green.shade600
                                      : (paidRatio > 0 ? Colors.amber.shade700 : Colors.red.shade400),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${(paidRatio * 100).toStringAsFixed(0)}% ${isArabic ? 'مسدد' : 'paid'}',
                                  style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
                                ),
                                if (bill.dueDate != null)
                                  Text(
                                    '${isArabic ? 'استحقاق' : 'Due'}: ${dateFormat.format(bill.dueDate!)}',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: isOverdue ? Colors.red.shade700 : Colors.grey.shade600,
                                      fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Card Bottom Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Tooltip(
                                message: isArabic ? 'طباعة الفاتورة' : 'Print PDF',
                                child: IconButton(
                                  icon: const Icon(Icons.print, size: 18),
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => _printSingleBill(bill),
                                ),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                                onPressed: () => _openDetails(bill, isArabic),
                                child: Text(isArabic ? 'التفاصيل' : 'Details', style: const TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                          if (balance > 0.01)
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                visualDensity: VisualDensity.compact,
                              ),
                              icon: const Icon(Icons.payments, size: 14),
                              label: Text(isArabic ? 'سداد' : 'Pay AP', style: const TextStyle(fontSize: 11)),
                              onPressed: () => _showPaymentDialog(context, bill, balance),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGridView(List<SupplierBillModel> bills, bool isArabic, ThemeData theme) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final now = DateTime.now();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.indigo.shade50),
              dataRowMinHeight: 48,
              dataRowMaxHeight: 52,
              columnSpacing: 18,
              columns: [
                const DataColumn(label: Text('#')),
                DataColumn(label: Text(isArabic ? 'رقم الفاتورة' : 'Bill #')),
                DataColumn(label: Text(isArabic ? 'المورد' : 'Supplier')),
                DataColumn(label: Text(isArabic ? 'تاريخ الإصدار' : 'Issue Date')),
                DataColumn(label: Text(isArabic ? 'تاريخ الاستحقاق' : 'Due Date')),
                DataColumn(label: Text(isArabic ? 'أمر الشراء / GRN' : 'PO / GRN')),
                DataColumn(label: Text(isArabic ? 'المجموع الفرعي' : 'Subtotal (SAR)')),
                DataColumn(label: Text(isArabic ? 'الضريبة (15%)' : 'VAT (SAR)')),
                DataColumn(label: Text(isArabic ? 'الإجمالي (SAR)' : 'Total (SAR)')),
                DataColumn(label: Text(isArabic ? 'المدفوع (SAR)' : 'Paid (SAR)')),
                DataColumn(label: Text(isArabic ? 'المتبقي (SAR)' : 'Balance Due (SAR)')),
                DataColumn(label: Text(isArabic ? 'حالة السداد' : 'Status')),
                DataColumn(label: Text(isArabic ? 'إجراءات' : 'Actions')),
              ],
              rows: bills.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final bill = entry.value;
                final isEven = entry.key % 2 == 0;

                final total = double.tryParse(bill.totalAmount) ?? 0.0;
                final paid = double.tryParse(bill.paidAmount) ?? 0.0;
                final subtotal = double.tryParse(bill.subtotalAmount) ?? (total / 1.15);
                final vat = double.tryParse(bill.vatAmount) ?? (total - subtotal);
                final balance = (total - paid).clamp(0.0, double.infinity);
                final isOverdue = bill.dueDate != null && bill.dueDate!.isBefore(now) && balance > 0.01;

                final refStr = bill.poId != null && bill.poId!.isNotEmpty
                    ? 'PO: ${ProcurementDocumentFormatter.formatPoNumber(bill.poId, bill.poId)}'
                    : (bill.grnId != null && bill.grnId!.isNotEmpty ? 'GRN: ${ProcurementDocumentFormatter.formatGrnNumber(bill.grnId, bill.grnId)}' : '-');

                return DataRow(
                  color: WidgetStateProperty.all(isEven ? Colors.white : Colors.grey.shade50),
                  cells: [
                    DataCell(Text('$idx', style: TextStyle(color: Colors.grey.shade700, fontSize: 12))),
                    DataCell(
                      InkWell(
                        onTap: () => _openDetails(bill, isArabic),
                        child: Text(
                          bill.billNumber,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.indigo.shade800,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(bill.supplierName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                          Text(ProcurementDocumentFormatter.formatSupplierCode(bill.supplierId), style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    DataCell(Text(dateFormat.format(bill.issueDate), style: const TextStyle(fontSize: 12))),
                    DataCell(
                      Row(
                        children: [
                          Text(
                            bill.dueDate != null ? dateFormat.format(bill.dueDate!) : '-',
                            style: TextStyle(
                              fontSize: 12,
                              color: isOverdue ? Colors.red.shade800 : Colors.black87,
                              fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          if (isOverdue) ...[
                            const SizedBox(width: 4),
                            Icon(Icons.warning, size: 14, color: Colors.red.shade700),
                          ],
                        ],
                      ),
                    ),
                    DataCell(Text(refStr, style: const TextStyle(fontSize: 12))),
                    DataCell(Text(subtotal.toStringAsFixed(2), style: const TextStyle(fontSize: 12))),
                    DataCell(Text(vat.toStringAsFixed(2), style: const TextStyle(fontSize: 12))),
                    DataCell(
                      Text(
                        total.toStringAsFixed(2),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    DataCell(
                      Text(
                        paid.toStringAsFixed(2),
                        style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ),
                    DataCell(
                      Text(
                        balance.toStringAsFixed(2),
                        style: TextStyle(
                          color: balance > 0.01 ? Colors.red.shade800 : Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    DataCell(_buildStatusBadge(bill.paymentStatus)),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Tooltip(
                            message: isArabic ? 'طباعة الفاتورة' : 'Print Bill PDF',
                            child: IconButton(
                              icon: const Icon(Icons.print, size: 16),
                              visualDensity: VisualDensity.compact,
                              onPressed: () => _printSingleBill(bill),
                            ),
                          ),
                          Tooltip(
                            message: isArabic ? 'عرض التفاصيل' : 'View Details',
                            child: IconButton(
                              icon: const Icon(Icons.visibility, size: 16),
                              visualDensity: VisualDensity.compact,
                              onPressed: () => _openDetails(bill, isArabic),
                            ),
                          ),
                          if (balance > 0.01)
                            Tooltip(
                              message: isArabic ? 'تسجيل دفعة' : 'Make AP Payment',
                              child: IconButton(
                                icon: Icon(Icons.payments, size: 16, color: Colors.green.shade700),
                                visualDensity: VisualDensity.compact,
                                onPressed: () => _showPaymentDialog(context, bill, balance),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateBillDialog(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => RecordReceivedBillDialog(
        isArabic: isArabic,
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, SupplierBillModel bill, double balanceDue) {
    final amountController = TextEditingController(text: balanceDue.toStringAsFixed(2));
    final refController = TextEditingController();
    String method = 'BANK';
    final isArabic = ref.read(localeProvider).languageCode == 'ar';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.green.shade50,
                child: Icon(Icons.payments, color: Colors.green.shade800),
              ),
              const SizedBox(width: 10),
              Text(isArabic ? 'تسديد دفعة للفاتورة: ${bill.billNumber}' : 'Settle AP Bill: ${bill.billNumber}'),
            ],
          ),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${isArabic ? 'المورد' : 'Supplier'}: ${bill.supplierName}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '${isArabic ? 'إجمالي الفاتورة' : 'Total'}: SAR ${bill.totalAmount} | ${isArabic ? 'الرصيد المستحق' : 'Balance Due'}: SAR ${balanceDue.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: isArabic ? 'مبلغ السداد (SAR) *' : 'Payment Amount (SAR) *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: method,
                  decoration: InputDecoration(
                    labelText: isArabic ? 'طريقة الدفع' : 'Payment Method',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: [
                    DropdownMenuItem(value: 'BANK', child: Text(isArabic ? 'تحويل بنكي' : 'Bank Transfer')),
                    DropdownMenuItem(value: 'CASH', child: Text(isArabic ? 'نقدي (كاش)' : 'Cash')),
                    DropdownMenuItem(value: 'CHECK', child: Text(isArabic ? 'شيك مصرفي' : 'Cheque')),
                  ],
                  onChanged: (val) {
                    if (val != null) setModalState(() => method = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: refController,
                  decoration: InputDecoration(
                    labelText: isArabic ? 'المرجع البنكي / رقم الشيك' : 'Bank Reference # / Cheque #',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(isArabic ? 'إلغاء' : 'Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final amt = double.tryParse(amountController.text) ?? 0.0;
                if (amt <= 0) return;

                try {
                  await ref.read(procurementServiceProvider).paySupplierBill(
                        billId: bill.id,
                        paymentAmount: amt,
                        paymentMethod: method,
                        referenceNumber: refController.text.trim(),
                      );
                  ref.invalidate(supplierBillsProvider);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isArabic ? 'تم تسجيل دفعة الذمم الدائنة بنجاح!' : 'AP Payment recorded successfully!'),
                        backgroundColor: Colors.green.shade800,
                      ),
                    );
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('Failed to record AP payment: $e')),
                    );
                  }
                }
              },
              child: Text(isArabic ? 'تأكيد السداد' : 'Confirm Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
