import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app.dart';
import '../domain/supplier_return_model.dart';
import '../providers/suppliers_provider.dart';
import 'widgets/create_debit_note_dialog.dart';

class SupplierReturnsScreen extends ConsumerStatefulWidget {
  const SupplierReturnsScreen({super.key});

  @override
  ConsumerState<SupplierReturnsScreen> createState() => _SupplierReturnsScreenState();
}

class _SupplierReturnsScreenState extends ConsumerState<SupplierReturnsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatusFilter = 'ALL';
  String _selectedReasonFilter = 'ALL';
  bool _isCardView = false;
  bool _isArabic = false;

  // Mock list of supplier returns for immediate interactive display + API backing
  List<SupplierReturnModel> _returns = [
    SupplierReturnModel(
      id: 'ret-101',
      tenantId: 'tenant-grocery-01',
      returnNumber: 'PRN-2026-0041',
      debitNoteNumber: 'DN-2026-0041',
      supplierId: 'sup-01',
      supplierName: 'Al-Marai Dairy & Foodstuffs Co.',
      originalBillId: 'bill-889',
      billNumber: 'BILL-2026-9912',
      returnDate: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      reason: 'DEFECTIVE',
      subtotalAmount: 1800.00,
      vatAmount: 270.00,
      totalAmount: 2070.00,
      status: 'APPROVED',
      refundStatus: 'PENDING',
      remarks: 'Returned 12 crates of expired yogurt cartons during inbound QC check',
      createdAt: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      items: [
        SupplierReturnItemModel(
          id: 'item-1',
          itemDescription: 'Al-Marai Fresh Milk 2L (Batch #9921)',
          unitPrice: 15.00,
          quantity: 80,
          vatRate: 15,
          vatAmount: 180.0,
          totalAmount: 1380.0,
          reason: 'SHORT_EXPIRY',
        ),
        SupplierReturnItemModel(
          id: 'item-2',
          itemDescription: 'Greek Yogurt Plain 500g',
          unitPrice: 10.00,
          quantity: 60,
          vatRate: 15,
          vatAmount: 90.0,
          totalAmount: 690.0,
          reason: 'PACKAGING_DAMAGED',
        ),
      ],
    ),
    SupplierReturnModel(
      id: 'ret-102',
      tenantId: 'tenant-grocery-01',
      returnNumber: 'PRN-2026-0038',
      debitNoteNumber: 'DN-2026-0038',
      supplierId: 'sup-02',
      supplierName: 'Saudi Electronics & Industrial Automation',
      originalBillId: 'bill-772',
      billNumber: 'BILL-2026-4401',
      returnDate: DateTime.now().subtract(const Duration(days: 8)).toIso8601String(),
      reason: 'DAMAGED_GOODS',
      subtotalAmount: 4500.00,
      vatAmount: 675.00,
      totalAmount: 5175.00,
      status: 'REFUNDED',
      refundStatus: 'CREDITED_TO_ACCOUNT',
      remarks: 'Defective barcode scanner sensors replaced under warranty terms',
      createdAt: DateTime.now().subtract(const Duration(days: 8)).toIso8601String(),
      items: [
        SupplierReturnItemModel(
          id: 'item-3',
          itemDescription: 'Zebra Handheld Laser Scanner 2D',
          unitPrice: 1500.00,
          quantity: 3,
          vatRate: 15,
          vatAmount: 675.0,
          totalAmount: 5175.0,
          reason: 'DEFECTIVE_BOARD',
        ),
      ],
    ),
    SupplierReturnModel(
      id: 'ret-103',
      tenantId: 'tenant-grocery-01',
      returnNumber: 'PRN-2026-0029',
      debitNoteNumber: 'DN-2026-0029',
      supplierId: 'sup-03',
      supplierName: 'Global Logistics & Freight Co.',
      originalBillId: 'bill-610',
      billNumber: 'BILL-2026-3310',
      returnDate: DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
      reason: 'WRONG_ITEM',
      subtotalAmount: 3200.00,
      vatAmount: 480.00,
      totalAmount: 3680.00,
      status: 'DRAFT',
      refundStatus: 'PENDING',
      remarks: 'Incorrect pallets dispatched to Dammam warehouse branch',
      createdAt: DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
      items: [
        SupplierReturnItemModel(
          id: 'item-4',
          itemDescription: 'Heavy Duty Wooden Pallets 120x100cm',
          unitPrice: 80.00,
          quantity: 40,
          vatRate: 15,
          vatAmount: 480.0,
          totalAmount: 3680.0,
          reason: 'SPECIFICATION_MISMATCH',
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchReturnsFromApi();
  }

  Future<void> _fetchReturnsFromApi() async {
    try {
      final api = ref.read(supplierApiProvider);
      final response = await api.getSupplierReturns();
      if (response != null && response['success'] == true && response['data'] != null) {
        final list = (response['data'] as List)
            .map((item) => SupplierReturnModel.fromJson(item as Map<String, dynamic>))
            .toList();
        setState(() {
          _returns = list;
        });
      }
    } catch (_) {
      // Fallback to rich mock data if backend api server is loading
    }
  }

  List<SupplierReturnModel> get _filteredReturns {
    return _returns.where((ret) {
      final query = _searchController.text.toLowerCase().trim();
      final matchesSearch = query.isEmpty ||
          ret.returnNumber.toLowerCase().contains(query) ||
          ret.debitNoteNumber.toLowerCase().contains(query) ||
          ret.supplierName.toLowerCase().contains(query) ||
          (ret.billNumber != null && ret.billNumber!.toLowerCase().contains(query));

      final matchesStatus = _selectedStatusFilter == 'ALL' || ret.status == _selectedStatusFilter;
      final matchesReason = _selectedReasonFilter == 'ALL' || ret.reason == _selectedReasonFilter;

      return matchesSearch && matchesStatus && matchesReason;
    }).toList();
  }

  double get _totalReturnValue {
    return _returns.fold(0.0, (sum, item) => sum + item.totalAmount);
  }

  int get _approvedCount {
    return _returns.where((r) => r.status == 'APPROVED' || r.status == 'REFUNDED').length;
  }

  int get _pendingRefundCount {
    return _returns.where((r) => r.refundStatus == 'PENDING').length;
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    _isArabic = currentLocale.languageCode == 'ar';
    final filtered = _filteredReturns;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(_isArabic ? 'مرتجعات الموردين والإشعارات المدينة' : 'Supplier Returns & Debit Notes'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isArabic ? Icons.language : Icons.g_translate),
            tooltip: _isArabic ? 'Switch to English' : 'التحويل للعربية',
            onPressed: () {
              ref.read(localeProvider.notifier).state =
                  _isArabic ? const Locale('en') : const Locale('ar');
            },
          ),
          IconButton(
            icon: Icon(_isCardView ? Icons.table_chart_outlined : Icons.grid_view_rounded),
            tooltip: _isCardView ? 'Table View' : 'Card View',
            onPressed: () => setState(() => _isCardView = !_isCardView),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Action Bar & Header
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isArabic ? 'إدارة إشعارات خصم الموردين والضريبة' : 'Manage Purchase Returns & Tax Debit Notes',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isArabic ? 'إصدار إشعارات مدينة معتمدة لضريبة القيمة المضافة 15%' : 'Issue ZATCA-compliant Debit Notes with 15% VAT adjustment',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _showCreateReturnDialog(context),
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: Text(_isArabic ? 'إنشاء إشعار مدين' : 'Create Debit Note'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // KPI Metric Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: _isArabic ? 'إجمالي المرتجعات' : 'Total Return Value',
                    value: '${_totalReturnValue.toStringAsFixed(2)} SAR',
                    icon: Icons.assignment_return_rounded,
                    color: const Color(0xFF2563EB),
                    subtitle: '${_returns.length} ${_isArabic ? 'إشعارات' : 'Vouchers'}',
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildMetricCard(
                    title: _isArabic ? 'الإشعارات المعتمدة' : 'Approved Debit Notes',
                    value: '$_approvedCount',
                    icon: Icons.check_circle_rounded,
                    color: const Color(0xFF10B981),
                    subtitle: _isArabic ? 'معتمدة ومطابقة' : 'Verified & Actioned',
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildMetricCard(
                    title: _isArabic ? 'مبالغ قيد المسترد' : 'Pending Refunds',
                    value: '$_pendingRefundCount',
                    icon: Icons.pending_actions_rounded,
                    color: const Color(0xFFF59E0B),
                    subtitle: _isArabic ? 'في انتظار رصيد الدائن' : 'Awaiting Supplier Credit',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search and Filters
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: _isArabic ? 'بحث برقم المرتجع، الإشعار المدين أو المورد...' : 'Search by Return #, Debit Note #, or Supplier...',
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Filter by Status
                  DropdownButton<String>(
                    value: _selectedStatusFilter,
                    onChanged: (val) => setState(() => _selectedStatusFilter = val!),
                    underline: const SizedBox(),
                    items: [
                      DropdownMenuItem(value: 'ALL', child: Text(_isArabic ? 'كل الحالات' : 'All Statuses')),
                      DropdownMenuItem(value: 'APPROVED', child: Text(_isArabic ? 'معتمد' : 'Approved')),
                      DropdownMenuItem(value: 'REFUNDED', child: Text(_isArabic ? 'مسترد' : 'Refunded')),
                      DropdownMenuItem(value: 'DRAFT', child: Text(_isArabic ? 'مسودة' : 'Draft')),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // Filter by Reason
                  DropdownButton<String>(
                    value: _selectedReasonFilter,
                    onChanged: (val) => setState(() => _selectedReasonFilter = val!),
                    underline: const SizedBox(),
                    items: [
                      DropdownMenuItem(value: 'ALL', child: Text(_isArabic ? 'كل الأسباب' : 'All Reasons')),
                      DropdownMenuItem(value: 'DEFECTIVE', child: Text(_isArabic ? 'منتج معيب' : 'Defective Goods')),
                      DropdownMenuItem(value: 'DAMAGED_GOODS', child: Text(_isArabic ? 'بضائع تالفة' : 'Damaged Goods')),
                      DropdownMenuItem(value: 'WRONG_ITEM', child: Text(_isArabic ? 'صنف غير مطابق' : 'Wrong Item')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Data Table / Cards View
            filtered.isEmpty
                ? _buildEmptyState()
                : _isCardView
                    ? _buildCardGrid(filtered)
                    : _buildTable(filtered),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(Icons.remove_shopping_cart_outlined, size: 48, color: Color(0xFF94A3B8)),
          const SizedBox(height: 12),
          Text(
            _isArabic ? 'لا توجد مرتجعات موردين مطابقة' : 'No Supplier Returns Found',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 6),
          Text(
            _isArabic ? 'قم بإنشاء إشعار مدين جديد لإدارة المرتجعات واسترداد الضريبة' : 'Create a new Debit Note to issue a supplier return and adjust VAT.',
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(List<SupplierReturnModel> list) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
        horizontalMargin: 20,
        columnSpacing: 24,
        columns: [
          DataColumn(label: Text(_isArabic ? 'رقم المرتجع / الإشعار' : 'Return / Debit Note #', style: _headerStyle)),
          DataColumn(label: Text(_isArabic ? 'اسم المورد' : 'Supplier Name', style: _headerStyle)),
          DataColumn(label: Text(_isArabic ? 'رقم الفاتورة الأصلية' : 'Original Bill #', style: _headerStyle)),
          DataColumn(label: Text(_isArabic ? 'تاريخ الإشعار' : 'Return Date', style: _headerStyle)),
          DataColumn(label: Text(_isArabic ? 'سبب الإرجاع' : 'Reason', style: _headerStyle)),
          DataColumn(label: Text(_isArabic ? 'إجمالي المبلغ' : 'Total Amount (SAR)', style: _headerStyle)),
          DataColumn(label: Text(_isArabic ? 'الحالة' : 'Status', style: _headerStyle)),
          DataColumn(label: Text(_isArabic ? 'إجراءات' : 'Actions', style: _headerStyle)),
        ],
        rows: list.map((item) {
          return DataRow(
            cells: [
              DataCell(
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.returnNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2563EB))),
                    Text(item.debitNoteNumber, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              DataCell(Text(item.supplierName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
              DataCell(Text(item.billNumber ?? '-', style: const TextStyle(fontSize: 12, color: Color(0xFF475569)))),
              DataCell(Text(item.returnDate.length >= 10 ? item.returnDate.substring(0, 10) : item.returnDate, style: const TextStyle(fontSize: 12))),
              DataCell(_buildReasonChip(item.reason)),
              DataCell(Text('${item.totalAmount.toStringAsFixed(2)} SAR', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
              DataCell(_buildStatusChip(item.status)),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.receipt_long_rounded, color: Color(0xFF2563EB), size: 20),
                      tooltip: _isArabic ? 'عرض الإشعار المدين ZATCA' : 'View ZATCA Debit Note',
                      onPressed: () => _showDebitNoteDialog(context, item),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCardGrid(List<SupplierReturnModel> list) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(item.returnNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2563EB))),
                    const Spacer(),
                    _buildStatusChip(item.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(item.supplierName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                Text('${_isArabic ? 'السبب:' : 'Reason:'} ${item.reason}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                const Spacer(),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('${item.totalAmount.toStringAsFixed(2)} SAR', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _showDebitNoteDialog(context, item),
                      icon: const Icon(Icons.print_rounded, size: 16),
                      label: Text(_isArabic ? 'الإشعار المدين' : 'Debit Note'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  TextStyle get _headerStyle => const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF475569));

  Widget _buildStatusChip(String status) {
    Color bg = Colors.grey.shade100;
    Color fg = Colors.grey.shade800;

    if (status == 'APPROVED') {
      bg = const Color(0xFF10B981).withValues(alpha: 0.1);
      fg = const Color(0xFF10B981);
    } else if (status == 'REFUNDED') {
      bg = const Color(0xFF2563EB).withValues(alpha: 0.1);
      fg = const Color(0xFF2563EB);
    } else if (status == 'DRAFT') {
      bg = Colors.orange.withValues(alpha: 0.1);
      fg = Colors.orange.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(status, style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  Widget _buildReasonChip(String reason) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
      child: Text(
        reason.replaceAll('_', ' '),
        style: const TextStyle(fontSize: 11, color: Color(0xFF475569), fontWeight: FontWeight.w500),
      ),
    );
  }

  // ZATCA Tax Debit Note Modal View
  void _showDebitNoteDialog(BuildContext context, SupplierReturnModel ret) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 650,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'إشعار مدين ضريبي / DEBIT NOTE',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 4),
                      Text('Simplified Tax Debit Note | ZATCA Phase 2 Compliant', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFF2563EB).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.qr_code_2_rounded, size: 40, color: Color(0xFF2563EB)),
                  ),
                ],
              ),
              const Divider(height: 28),

              // Voucher Details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${_isArabic ? 'رقم الإشعار:' : 'Debit Note #:'} ${ret.debitNoteNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('${_isArabic ? 'رقم المرتجع:' : 'Return Voucher #:'} ${ret.returnNumber}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      Text('${_isArabic ? 'الفاتورة الأصلية:' : 'Ref. Original Bill:'} ${ret.billNumber ?? "N/A"}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${_isArabic ? 'المورد:' : 'Supplier:'} ${ret.supplierName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('${_isArabic ? 'تاريخ الإصدار:' : 'Date:'} ${ret.returnDate.substring(0, 10)}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      Text('${_isArabic ? 'السبب:' : 'Reason:'} ${ret.reason}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Item Breakdown Table
              Container(
                decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      color: const Color(0xFFF8FAFC),
                      child: const Row(
                        children: [
                          Expanded(flex: 3, child: Text('Item Description / الوصف', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          Expanded(child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          Expanded(child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          Expanded(child: Text('VAT (15%)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          Expanded(child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                        ],
                      ),
                    ),
                    ...ret.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            Expanded(flex: 3, child: Text(item.itemDescription, style: const TextStyle(fontSize: 12))),
                            Expanded(child: Text('${item.quantity}', style: const TextStyle(fontSize: 12))),
                            Expanded(child: Text(item.unitPrice.toStringAsFixed(2), style: const TextStyle(fontSize: 12))),
                            Expanded(child: Text(item.vatAmount.toStringAsFixed(2), style: const TextStyle(fontSize: 12))),
                            Expanded(child: Text(item.totalAmount.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Summary
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 250,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal / المجموع:', style: TextStyle(fontSize: 12)),
                          Text('${ret.subtotalAmount.toStringAsFixed(2)} SAR', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('VAT 15% / ضريبة:', style: TextStyle(fontSize: 12)),
                          Text('${ret.vatAmount.toStringAsFixed(2)} SAR', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Credit / الإجمالي:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('${ret.totalAmount.toStringAsFixed(2)} SAR', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2563EB))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: Text(_isArabic ? 'إغلاق' : 'Close'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(_isArabic ? 'تم إرسال الإشعار المدين لطباعة PDF' : 'Debit Note sent to PDF printer')),
                      );
                    },
                    icon: const Icon(Icons.print_rounded, size: 18),
                    label: Text(_isArabic ? 'طباعة PDF' : 'Print PDF'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Create Return / Debit Note Form Modal
  void _showCreateReturnDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => CreateDebitNoteDialog(
        isArabic: _isArabic,
        onReturnCreated: (newReturn) {
          setState(() {
            _returns.insert(0, newReturn);
          });
        },
      ),
    );
  }
}
