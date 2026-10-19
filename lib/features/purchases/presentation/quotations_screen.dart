import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:erp_frontend/app.dart';
import '../domain/procurement_models.dart';
import '../providers/procurement_provider.dart';
import '../../suppliers/providers/suppliers_provider.dart';
import '../../suppliers/domain/supplier_model.dart';
import '../../pos/domain/product_model.dart';
import '../../pos/providers/pos_provider.dart';
import '../utils/rfq_pdf_printer.dart';
import '../utils/procurement_document_formatter.dart';
import 'widgets/quotation_details_dialog.dart';
import 'widgets/rfq_csv_import_dialog.dart';

class QuotationsScreen extends ConsumerStatefulWidget {
  const QuotationsScreen({super.key});

  @override
  ConsumerState<QuotationsScreen> createState() => _QuotationsScreenState();
}

class _QuotationsScreenState extends ConsumerState<QuotationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'ALL';
  String? _selectedSupplierId;
  String _sortBy = 'DATE_DESC';
  bool _isTableView = false; // false = Card View, true = Grid / Table View

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetails(SupplierQuotationModel q, bool isArabic) {
    showDialog(
      context: context,
      builder: (ctx) => QuotationDetailsDialog(quotation: q, isArabic: isArabic),
    );
  }

  void _openCsvImport(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (ctx) => RfqCsvImportDialog(isArabic: isArabic),
    );
  }

  void _printQuotation(SupplierQuotationModel q) {
    RfqPdfPrinter.printQuotation(q);
  }

  void _printFilteredReport(List<SupplierQuotationModel> filtered, bool isArabic) {
    if (filtered.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic ? 'لا توجد سجلات لطباعتها' : 'No records available to print'),
          backgroundColor: Colors.amber.shade800,
        ),
      );
      return;
    }
    final title = isArabic
        ? 'تقرير سجل طلبات وعروض أسعار الموردين (RFQs)'
        : 'Supplier Quotations (RFQ) Registry Report';
    RfqPdfPrinter.printRfqRegister(quotations: filtered, title: title);
  }

  List<SupplierQuotationModel> _applyFiltersAndSort(List<SupplierQuotationModel> quotations) {
    final filtered = quotations.where((q) {
      final query = _searchQuery.trim().toLowerCase();
      final matchQuery = query.isEmpty ||
          q.quotationNumber.toLowerCase().contains(query) ||
          (q.supplierRefNo ?? '').toLowerCase().contains(query) ||
          (q.supplierName ?? '').toLowerCase().contains(query) ||
          q.supplierId.toLowerCase().contains(query) ||
          (q.title ?? '').toLowerCase().contains(query) ||
          (q.notes ?? '').toLowerCase().contains(query) ||
          q.items.any((item) => item.description.toLowerCase().contains(query));

      final matchStatus = _selectedStatus == 'ALL' || q.status.toUpperCase() == _selectedStatus.toUpperCase();

      final matchSupplier = _selectedSupplierId == null ||
          _selectedSupplierId == 'ALL' ||
          q.supplierId == _selectedSupplierId;

      return matchQuery && matchStatus && matchSupplier;
    }).toList();

    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'DATE_ASC':
          return a.quotationDate.compareTo(b.quotationDate);
        case 'AMOUNT_DESC':
          final aAmt = double.tryParse(a.totalAmount) ?? 0.0;
          final bAmt = double.tryParse(b.totalAmount) ?? 0.0;
          return bAmt.compareTo(aAmt);
        case 'AMOUNT_ASC':
          final aAmt = double.tryParse(a.totalAmount) ?? 0.0;
          final bAmt = double.tryParse(b.totalAmount) ?? 0.0;
          return aAmt.compareTo(bAmt);
        case 'RFQ_NO':
          return a.quotationNumber.compareTo(b.quotationNumber);
        case 'DATE_DESC':
        default:
          return b.quotationDate.compareTo(a.quotationDate);
      }
    });

    return filtered;
  }

  Widget _buildStatusBadge(String status) {
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
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quotationsAsync = ref.watch(supplierQuotationsProvider);
    final suppliersAsync = ref.watch(suppliersProvider);
    final suppliers = suppliersAsync.asData?.value ?? [];
    final theme = Theme.of(context);
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'عروض أسعار الموردين (RFQs)' : 'Supplier Quotations (RFQs)'),
        actions: [
          // View Mode Toggle (Card vs Table)
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
                      color: !_isTableView ? theme.colorScheme.primary : Colors.transparent,
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
                      color: _isTableView ? theme.colorScheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.table_rows_rounded,
                          size: 16,
                          color: _isTableView ? Colors.white : Colors.grey.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isArabic ? 'جدول' : 'Grid Table',
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
          const SizedBox(width: 10),

          // Import CSV Button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.upload_file_rounded, size: 18),
            label: Text(isArabic ? 'استيراد CSV' : 'Import CSV'),
            onPressed: () => _openCsvImport(context, isArabic),
          ),
          const SizedBox(width: 8),

          // Print Report Button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.print_rounded, size: 18),
            label: Text(isArabic ? 'طباعة السجل' : 'Print Register'),
            onPressed: () {
              final allQuotes = quotationsAsync.asData?.value ?? [];
              final filtered = _applyFiltersAndSort(allQuotes);
              _printFilteredReport(filtered, isArabic);
            },
          ),
          const SizedBox(width: 8),

          // Language Switcher
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              final current = ref.read(localeProvider);
              ref.read(localeProvider.notifier).state =
                  current.languageCode == 'en' ? const Locale('ar') : const Locale('en');
            },
            tooltip: isArabic ? 'تغيير اللغة' : 'Switch Language',
          ),

          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(supplierQuotationsProvider),
            tooltip: isArabic ? 'تحديث' : 'Refresh',
          ),

          // Add Quotation Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.add_task_rounded, size: 20),
            label: Text(
              isArabic ? '+ عرض سعر جديد' : '+ New RFQ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () => _showCreateQuotationDialog(context, isArabic),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Filter & Search Controls Panel
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Search Input + Supplier Dropdown + Sort Dropdown
                Row(
                  children: [
                    // Search Bar
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: isArabic
                              ? 'بحث برقم RFQ، اسم المورد، الرقم المرجعي، الصنف، الملاحظات...'
                              : 'Search by RFQ #, Supplier, Ref #, items, notes...',
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
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Supplier Filter Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedSupplierId ?? 'ALL',
                          hint: Text(isArabic ? 'المورد' : 'Supplier'),
                          items: [
                            DropdownMenuItem(
                              value: 'ALL',
                              child: Text(isArabic ? 'جميع الموردين' : 'All Suppliers'),
                            ),
                            ...suppliers.map((s) => DropdownMenuItem(
                                  value: s.id,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 160),
                                    child: Text(s.name, overflow: TextOverflow.ellipsis),
                                  ),
                                )),
                          ],
                          onChanged: (val) {
                            setState(() => _selectedSupplierId = (val == 'ALL' ? null : val));
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Sort By Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _sortBy,
                          items: [
                            DropdownMenuItem(
                              value: 'DATE_DESC',
                              child: Text(isArabic ? 'الأحدث أولاً' : 'Newest First'),
                            ),
                            DropdownMenuItem(
                              value: 'DATE_ASC',
                              child: Text(isArabic ? 'الأقدم أولاً' : 'Oldest First'),
                            ),
                            DropdownMenuItem(
                              value: 'AMOUNT_DESC',
                              child: Text(isArabic ? 'الأعلى قيمة' : 'Highest Value'),
                            ),
                            DropdownMenuItem(
                              value: 'AMOUNT_ASC',
                              child: Text(isArabic ? 'الأقل قيمة' : 'Lowest Value'),
                            ),
                            DropdownMenuItem(
                              value: 'RFQ_NO',
                              child: Text(isArabic ? 'رقم العرض (تصاعدي)' : 'RFQ Number'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _sortBy = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Bottom Row: Status Filter Chips & Result Counter
                quotationsAsync.maybeWhen(
                  data: (quotations) {
                    final draftCount = quotations.where((q) => q.status.toUpperCase() == 'DRAFT').length;
                    final submittedCount = quotations.where((q) => q.status.toUpperCase() == 'SUBMITTED').length;
                    final acceptedCount = quotations.where((q) => q.status.toUpperCase() == 'ACCEPTED').length;
                    final rejectedCount = quotations.where((q) => q.status.toUpperCase() == 'REJECTED').length;
                    final filtered = _applyFiltersAndSort(quotations);

                    return Row(
                      children: [
                        // Quick Status Chips
                        _buildFilterChip('ALL', isArabic ? 'الكل' : 'All', quotations.length),
                        const SizedBox(width: 6),
                        _buildFilterChip('SUBMITTED', isArabic ? 'مقدم' : 'Submitted', submittedCount),
                        const SizedBox(width: 6),
                        _buildFilterChip('ACCEPTED', isArabic ? 'مقبول' : 'Accepted', acceptedCount),
                        const SizedBox(width: 6),
                        _buildFilterChip('DRAFT', isArabic ? 'مسودة' : 'Draft', draftCount),
                        const SizedBox(width: 6),
                        _buildFilterChip('REJECTED', isArabic ? 'مرفوض' : 'Rejected', rejectedCount),

                        const Spacer(),

                        // Results count indicator
                        Text(
                          isArabic
                              ? 'عرض ${filtered.length} من أصل ${quotations.length} عرض سعر'
                              : 'Showing ${filtered.length} of ${quotations.length} RFQs',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                        ),

                        if (_searchQuery.isNotEmpty || _selectedStatus != 'ALL' || _selectedSupplierId != null) ...[
                          const SizedBox(width: 8),
                          TextButton.icon(
                            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                            icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                            label: Text(isArabic ? 'مسح الفلاتر' : 'Reset Filters', style: const TextStyle(fontSize: 12)),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _selectedStatus = 'ALL';
                                _selectedSupplierId = null;
                              });
                            },
                          ),
                        ],
                      ],
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          // Main Quotation Content (Card View or Table Grid)
          Expanded(
            child: quotationsAsync.when(
              data: (quotations) {
                final filtered = _applyFiltersAndSort(quotations);

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.request_quote_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          isArabic ? 'لا توجد عروض أسعار مطابقة للبحث والفلاتر' : 'No supplier quotations match your criteria.',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _openCsvImport(context, isArabic),
                              icon: const Icon(Icons.upload_file_rounded),
                              label: Text(isArabic ? 'استيراد عبر CSV' : 'Import from CSV'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: () => _showCreateQuotationDialog(context, isArabic),
                              icon: const Icon(Icons.add),
                              label: Text(isArabic ? 'إضافة عرض سعر جديد' : 'Create Quotation'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }

                // Render Table / Grid View or Responsive Card View
                return _isTableView
                    ? _buildGridTableView(filtered, theme, isArabic)
                    : _buildResponsiveCardView(filtered, theme, isArabic);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text('Error loading quotations: $err', style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(supplierQuotationsProvider),
                        child: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String statusKey, String label, int count) {
    final isSelected = _selectedStatus == statusKey;
    final theme = Theme.of(context);

    return FilterChip(
      selected: isSelected,
      label: Text('$label ($count)'),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? theme.colorScheme.onPrimary : Colors.grey.shade800,
      ),
      selectedColor: theme.colorScheme.primary,
      backgroundColor: Colors.grey.shade100,
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      onSelected: (_) {
        setState(() => _selectedStatus = statusKey);
      },
    );
  }

  // Responsive Card View (Grid of Cards on Desktop, List on Mobile)
  Widget _buildResponsiveCardView(
    List<SupplierQuotationModel> filtered,
    ThemeData theme,
    bool isArabic,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 950;

        if (isWide) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 480,
              mainAxisExtent: 250,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final q = filtered[index];
              return _buildQuotationCard(q, theme, isArabic);
            },
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final q = filtered[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildQuotationCard(q, theme, isArabic),
            );
          },
        );
      },
    );
  }

  Widget _buildQuotationCard(
    SupplierQuotationModel q,
    ThemeData theme,
    bool isArabic,
  ) {
    final isExpired = q.validUntil != null && q.validUntil!.isBefore(DateTime.now());
    final totalVal = double.tryParse(q.totalAmount) ?? 0.0;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () => _openDetails(q, isArabic),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Row: Avatar, Quotation #, Status, Menu
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      (q.supplierName?.isNotEmpty == true ? q.supplierName![0] : 'S').toUpperCase(),
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              q.quotationNumber,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.copy_rounded, size: 14, color: Colors.grey),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip: isArabic ? 'نسخ رقم RFQ' : 'Copy RFQ #',
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: q.quotationNumber));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${q.quotationNumber} copied!'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        Text(
                          q.supplierName ?? ProcurementDocumentFormatter.formatSupplierCode(q.supplierId),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade800, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(q.status),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, size: 20, color: Colors.grey),
                    onSelected: (val) {
                      if (val == 'PRINT') {
                        _printQuotation(q);
                      } else if (val == 'VIEW') {
                        _openDetails(q, isArabic);
                      }
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        value: 'VIEW',
                        child: Row(
                          children: [
                            const Icon(Icons.visibility_rounded, size: 18),
                            const SizedBox(width: 8),
                            Text(isArabic ? 'عرض التفاصيل' : 'View Details'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'PRINT',
                        child: Row(
                          children: [
                            const Icon(Icons.print_rounded, size: 18),
                            const SizedBox(width: 8),
                            Text(isArabic ? 'طباعة PDF' : 'Print PDF'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Middle: Dates & Items preview
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('yyyy-MM-dd').format(q.quotationDate),
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                    if (q.validUntil != null)
                      Row(
                        children: [
                          Icon(
                            Icons.event_available_outlined,
                            size: 14,
                            color: isExpired ? Colors.red.shade700 : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('yyyy-MM-dd').format(q.validUntil!),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isExpired ? FontWeight.bold : FontWeight.normal,
                              color: isExpired ? Colors.red.shade700 : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${q.items.length} ${isArabic ? "أصناف" : "Items"}',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom: Total Amount & Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'الإجمالي الكلي' : 'Total Amount',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                      Text(
                        'SAR ${totalVal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton.filledTonal(
                        icon: const Icon(Icons.print_rounded, size: 18),
                        tooltip: isArabic ? 'طباعة عرض السعر' : 'Print RFQ PDF',
                        onPressed: () => _printQuotation(q),
                      ),
                      const SizedBox(width: 6),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _openDetails(q, isArabic),
                        child: Text(isArabic ? 'تفاصيل' : 'Details', style: const TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Enterprise Grid Table View (DataTable)
  Widget _buildGridTableView(
    List<SupplierQuotationModel> filtered,
    ThemeData theme,
    bool isArabic,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        elevation: 1.5,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
              dataRowMinHeight: 48,
              dataRowMaxHeight: 56,
              columnSpacing: 24,
              columns: [
                DataColumn(label: Text(isArabic ? 'رقم RFQ' : 'RFQ #', style: const TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text(isArabic ? 'المورد' : 'Supplier', style: const TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text(isArabic ? 'المرجع' : 'Supplier Ref', style: const TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text(isArabic ? 'تاريخ الإصدار' : 'Issue Date', style: const TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text(isArabic ? 'صالح حتى' : 'Valid Until', style: const TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text(isArabic ? 'الأصناف' : 'Items', style: const TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                DataColumn(label: Text(isArabic ? 'الإجمالي (ر.س)' : 'Total (SAR)', style: const TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                DataColumn(label: Text(isArabic ? 'الحالة' : 'Status', style: const TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text(isArabic ? 'إجراءات' : 'Actions', style: const TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: filtered.asMap().entries.map((entry) {
                final idx = entry.key;
                final q = entry.value;
                final totalVal = double.tryParse(q.totalAmount) ?? 0.0;
                final isExpired = q.validUntil != null && q.validUntil!.isBefore(DateTime.now());

                return DataRow(
                  color: WidgetStateProperty.resolveWith<Color?>((states) {
                    if (states.contains(WidgetState.hovered)) return Colors.blue.shade50.withValues(alpha: 0.5);
                    return idx.isEven ? Colors.white : Colors.grey.shade50;
                  }),
                  cells: [
                    DataCell(
                      InkWell(
                        onTap: () => _openDetails(q, isArabic),
                        child: Text(
                          q.quotationNumber,
                          style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.business_rounded, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(q.supplierName ?? ProcurementDocumentFormatter.formatSupplierCode(q.supplierId), style: const TextStyle(fontWeight: FontWeight.w600)), Text(ProcurementDocumentFormatter.formatSupplierCode(q.supplierId), style: TextStyle(fontSize: 10, color: Colors.grey.shade600))]),
                        ],
                      ),
                    ),
                    DataCell(Text(q.supplierRefNo ?? '-')),
                    DataCell(Text(DateFormat('yyyy-MM-dd').format(q.quotationDate))),
                    DataCell(
                      Text(
                        q.validUntil != null ? DateFormat('yyyy-MM-dd').format(q.validUntil!) : '-',
                        style: TextStyle(
                          color: isExpired ? Colors.red.shade700 : null,
                          fontWeight: isExpired ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${q.items.length}',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        totalVal.toStringAsFixed(2),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    DataCell(_buildStatusBadge(q.status)),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility_rounded, size: 18),
                            tooltip: isArabic ? 'عرض التفاصيل' : 'View Details',
                            onPressed: () => _openDetails(q, isArabic),
                          ),
                          IconButton(
                            icon: const Icon(Icons.print_rounded, size: 18),
                            tooltip: isArabic ? 'طباعة PDF' : 'Print PDF',
                            onPressed: () => _printQuotation(q),
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

  void _showCreateQuotationDialog(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _QuotationFormDialog(isArabic: isArabic),
    );
  }
}

class _QuotationFormDialog extends ConsumerStatefulWidget {
  final bool isArabic;
  const _QuotationFormDialog({required this.isArabic});

  @override
  ConsumerState<_QuotationFormDialog> createState() => _QuotationFormDialogState();
}

class _QuotationItemInput {
  String? productId;
  String? sku;
  TextEditingController descController = TextEditingController();
  TextEditingController qtyController = TextEditingController(text: '1');
  TextEditingController priceController = TextEditingController(text: '0.00');
  double vatRate = 15.0;

  void dispose() {
    descController.dispose();
    qtyController.dispose();
    priceController.dispose();
  }
}

class _QuotationFormDialogState extends ConsumerState<_QuotationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _rfqNumberController;
  late TextEditingController _supplierRefNoController;
  late TextEditingController _remarksController;
  late TextEditingController _manualSupplierController;
  
  SupplierModel? _selectedSupplier;
  bool _useManualSupplier = false;
  
  String? _uploadedFileName;
  String? _uploadedFileUrl;

  DateTime _issueDate = DateTime.now();
  DateTime _validUntil = DateTime.now().add(const Duration(days: 30));
  
  bool _isSubmitting = false;

  final List<_QuotationItemInput> _items = [];

  @override
  void initState() {
    super.initState();
    final randomDigits = (1000 + (DateTime.now().millisecondsSinceEpoch % 8999));
    _rfqNumberController = TextEditingController(text: 'RFQ-2026-$randomDigits');
    _supplierRefNoController = TextEditingController();
    _remarksController = TextEditingController();
    _manualSupplierController = TextEditingController();
  }

  @override
  void dispose() {
    _rfqNumberController.dispose();
    _supplierRefNoController.dispose();
    _remarksController.dispose();
    _manualSupplierController.dispose();
    for (var item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  void _addItemRow() {
    setState(() {
      _items.add(_QuotationItemInput());
    });
  }

  Future<void> _addInventoryProductItemRow() async {
    final selectedProduct = await showDialog<ProductModel>(
      context: context,
      builder: (ctx) => _InventoryProductPickerModal(isArabic: widget.isArabic),
    );

    if (selectedProduct != null) {
      setState(() {
        final newItem = _QuotationItemInput();
        newItem.productId = selectedProduct.id;
        newItem.sku = selectedProduct.sku;
        newItem.descController.text = selectedProduct.name;
        final cost = double.tryParse(selectedProduct.costPrice ?? '') ?? double.tryParse(selectedProduct.price) ?? 0.0;
        newItem.priceController.text = cost > 0 ? cost.toStringAsFixed(2) : selectedProduct.price;
        _items.add(newItem);
      });
    }
  }

  Future<void> _linkRowToInventoryProduct(int index) async {
    final selectedProduct = await showDialog<ProductModel>(
      context: context,
      builder: (ctx) => _InventoryProductPickerModal(isArabic: widget.isArabic),
    );

    if (selectedProduct != null && index < _items.length) {
      setState(() {
        final item = _items[index];
        item.productId = selectedProduct.id;
        item.sku = selectedProduct.sku;
        item.descController.text = selectedProduct.name;
        final cost = double.tryParse(selectedProduct.costPrice ?? '') ?? double.tryParse(selectedProduct.price) ?? 0.0;
        item.priceController.text = cost > 0 ? cost.toStringAsFixed(2) : selectedProduct.price;
      });
    }
  }

  void _removeItemRow(int index) {
    if (index >= _items.length) return;
    setState(() {
      final removed = _items.removeAt(index);
      removed.dispose();
    });
  }

  double _calculateSubtotal() {
    double sub = 0;
    for (var item in _items) {
      final q = double.tryParse(item.qtyController.text) ?? 0;
      final p = double.tryParse(item.priceController.text) ?? 0;
      sub += (q * p);
    }
    return sub;
  }

  double _calculateTotalVat() {
    double vat = 0;
    for (var item in _items) {
      final q = double.tryParse(item.qtyController.text) ?? 0;
      final p = double.tryParse(item.priceController.text) ?? 0;
      final itemSub = q * p;
      vat += itemSub * (item.vatRate / 100);
    }
    return vat;
  }

  Future<void> _openSupplierSearchModal() async {
    final selected = await showDialog<SupplierModel>(
      context: context,
      builder: (ctx) => _SupplierPickerModal(isArabic: widget.isArabic),
    );

    if (selected != null) {
      setState(() {
        _selectedSupplier = selected;
        _useManualSupplier = false;
      });
    }
  }

  void _simulateDocumentUpload() {
    setState(() {
      final supName = (_selectedSupplier?.name ?? 'Supplier').replaceAll(RegExp(r'\s+'), '_').toLowerCase();
      _uploadedFileName = '${supName}_quotation_quote_doc.pdf';
      _uploadedFileUrl = 'https://storage.zatca-erp.com/procurement/docs/$_uploadedFileName';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.isArabic
            ? 'تم إرفاق المستند المرجعي: $_uploadedFileName'
            : 'Attached quotation document: $_uploadedFileName'),
        backgroundColor: Colors.purple.shade800,
      ),
    );
  }

  Future<void> _submitQuotation() async {
    if (!_formKey.currentState!.validate()) return;

    final supplierName = _useManualSupplier
        ? _manualSupplierController.text.trim()
        : _selectedSupplier?.name;

    final supplierId = _useManualSupplier
        ? 'sup-custom'
        : _selectedSupplier?.id;

    if (supplierName == null || supplierName.isEmpty || supplierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isArabic ? 'يرجى تحديد المورد قبل الحفظ' : 'Please select a supplier before saving.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isArabic ? 'يجب إضافة صنف واحد على الأقل بعرض السعر' : 'Quotation must contain at least one line item.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final formattedItems = _items.map((i) {
        final qty = double.tryParse(i.qtyController.text) ?? 1.0;
        final price = double.tryParse(i.priceController.text) ?? 0.0;
        final sub = qty * price;
        final vat = sub * (i.vatRate / 100);
        return {
          'productId': i.productId,
          'sku': i.sku,
          'description': i.descController.text.trim().isEmpty ? 'General Item' : i.descController.text.trim(),
          'quantity': qty,
          'unitPrice': price,
          'vatRate': i.vatRate,
          'subtotalAmount': sub,
          'vatAmount': vat,
          'totalAmount': sub + vat,
        };
      }).toList();

      final payload = {
        'supplierId': supplierId,
        'supplierName': supplierName,
        'quotationNumber': _rfqNumberController.text.trim(),
        'supplierRefNo': _supplierRefNoController.text.trim(),
        'documentUrl': _uploadedFileUrl,
        'issueDate': _issueDate.toIso8601String(),
        'validUntil': _validUntil.toIso8601String(),
        'remarks': _remarksController.text.trim(),
        'status': 'SUBMITTED',
        'items': formattedItems,
      };

      await ref.read(procurementServiceProvider).createQuotation(payload);
      ref.invalidate(supplierQuotationsProvider);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isArabic ? 'تم تقديم عرض سعر المورد والمستند بنجاح!' : 'Supplier quotation & reference document submitted successfully!'),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isArabic ? 'حدث خطأ أثناء الحفظ: $e' : 'Failed to save quotation: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isArabic;
    final subtotal = _calculateSubtotal();
    final vatTotal = _calculateTotalVat();
    final grandTotal = subtotal + vatTotal;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 860,
        constraints: const BoxConstraints(maxHeight: 760),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dialog Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.request_quote_rounded, color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAr ? 'إضافة عرض سعر جديد للمورد (RFQ)' : 'New Supplier Quotation (RFQ)',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            isAr ? 'اختيار المورد والمنتجات من المخزون وإرفاق المستند المرجعي' : 'Pick supplier & inventory products, add pricing & attach quote doc',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Supplier Selection Section
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      isAr ? 'المورد المسعر *' : 'Quoting Supplier *',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          _useManualSupplier = !_useManualSupplier;
                                        });
                                      },
                                      child: Text(
                                        _useManualSupplier
                                            ? (isAr ? 'اختر من الموردين المسجلين' : 'Search Directory')
                                            : (isAr ? '+ كتابة مورد غير مسجل' : '+ Unlisted Supplier'),
                                        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                if (_useManualSupplier)
                                  TextFormField(
                                    controller: _manualSupplierController,
                                    decoration: InputDecoration(
                                      labelText: isAr ? 'اسم المورد غير المسجل *' : 'Unlisted Supplier Name *',
                                      hintText: isAr ? 'مثال: شركة الخليج للتوريدات' : 'e.g. Gulf Trading Supplies',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                      prefixIcon: const Icon(Icons.business_outlined),
                                    ),
                                    validator: (val) {
                                      if (_useManualSupplier && (val == null || val.trim().isEmpty)) {
                                        return isAr ? 'اسم المورد مطلوب' : 'Supplier name required';
                                      }
                                      return null;
                                    },
                                  )
                                else if (_selectedSupplier != null)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.green.shade300, width: 1.5),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.green.shade700,
                                          radius: 20,
                                          child: Text(
                                            _selectedSupplier!.name.substring(0, 1).toUpperCase(),
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    _selectedSupplier!.name,
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green.shade100,
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Text(
                                                      _selectedSupplier!.category,
                                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'VAT #: ${_selectedSupplier!.vatNumber ?? "N/A"} | ${_selectedSupplier!.email ?? _selectedSupplier!.phoneNumber ?? ""}',
                                                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                                              ),
                                            ],
                                          ),
                                        ),
                                        OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                            side: BorderSide(color: Colors.green.shade600),
                                          ),
                                          onPressed: _openSupplierSearchModal,
                                          icon: const Icon(Icons.swap_horiz_rounded, size: 16, color: Colors.green),
                                          label: Text(
                                            isAr ? 'تغيير' : 'Change',
                                            style: TextStyle(color: Colors.green.shade800, fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  InkWell(
                                    onTap: _openSupplierSearchModal,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.blue.shade300,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.person_search_rounded, color: Colors.blue.shade800, size: 22),
                                          const SizedBox(width: 10),
                                          Text(
                                            isAr ? 'بحث واختيار المورد من القائمة' : 'Search & Select Supplier from Directory',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.blue.shade900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAr ? 'رقم RFQ النظام *' : 'System RFQ Number *',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _rfqNumberController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    prefixIcon: const Icon(Icons.tag),
                                  ),
                                  validator: (val) => val == null || val.isEmpty ? (isAr ? 'مطلوب' : 'Required') : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Supplier Ref No & Reference Document Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAr ? 'الرقم المرجعي للمورد (Supplier Ref. No)' : 'Supplier Reference / Quote No.',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _supplierRefNoController,
                                  decoration: InputDecoration(
                                    labelText: isAr ? 'رقم الفاتورة/العرض الخاص بالمورد' : 'Vendor Proposal Ref # (e.g. ALM-QT-9921)',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    prefixIcon: const Icon(Icons.numbers_rounded),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAr ? 'مستند عرض السعر (PDF / صورة)' : 'Quotation Reference Document',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(height: 8),
                                if (_uploadedFileName != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.purple.shade300),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.picture_as_pdf_rounded, color: Colors.purple.shade800, size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _uploadedFileName!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.purple.shade900),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close, size: 18, color: Colors.red),
                                          onPressed: () => setState(() {
                                            _uploadedFileName = null;
                                            _uploadedFileUrl = null;
                                          }),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  InkWell(
                                    onTap: _simulateDocumentUpload,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.cloud_upload_outlined, color: Colors.purple.shade800, size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            isAr ? '+ رفع ملف العرض (PDF/Image)' : '+ Upload Quote Document (PDF/Image)',
                                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.purple.shade900),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Dates Row (Issue Date & Valid Until)
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: _issueDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (d != null) setState(() => _issueDate = d);
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: isAr ? 'تاريخ عرض السعر' : 'Quotation Issue Date',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  prefixIcon: const Icon(Icons.calendar_today),
                                ),
                                child: Text(DateFormat('yyyy-MM-dd').format(_issueDate)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: _validUntil,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (d != null) setState(() => _validUntil = d);
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: isAr ? 'صالح حتى تاريخ' : 'Valid Until Date',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  prefixIcon: const Icon(Icons.event_available),
                                ),
                                child: Text(DateFormat('yyyy-MM-dd').format(_validUntil)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Line Items Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isAr ? 'تفاصيل الأصناف والأسعار (Line Items)' : 'Itemized Price Breakdown',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal.shade700,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: _addInventoryProductItemRow,
                                icon: const Icon(Icons.inventory_2_rounded, size: 16),
                                label: Text(isAr ? '+ اختر من المخزون' : '+ Pick from Inventory'),
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: _addItemRow,
                                icon: const Icon(Icons.add_circle_outline, size: 18),
                                label: Text(isAr ? '+ صنف يدوي' : '+ Manual Item'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (_items.isEmpty)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 36,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isAr ? 'لم يتم إضافة أصناف بعرض السعر بعد' : 'No line items added yet.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal.shade800,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    ),
                                    onPressed: _addInventoryProductItemRow,
                                    icon: const Icon(Icons.inventory_2_rounded, size: 16),
                                    label: Text(isAr ? '+ اختر من المخزون' : '+ Pick from Inventory'),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    onPressed: _addItemRow,
                                    icon: const Icon(Icons.add_circle_outline, size: 16),
                                    label: Text(isAr ? '+ صنف يدوي' : '+ Manual Item'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                      // Items Table / Cards
                      ..._items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;

                        final q = double.tryParse(item.qtyController.text) ?? 0;
                        final p = double.tryParse(item.priceController.text) ?? 0;
                        final itemSub = q * p;
                        final itemVat = itemSub * (item.vatRate / 100);
                        final itemTotal = itemSub + itemVat;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: item.productId != null ? Colors.teal.shade300 : Colors.grey.shade300,
                              width: item.productId != null ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (item.sku != null || item.productId != null) ...[
                                Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.teal.shade200),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.inventory_2, size: 12, color: Colors.teal.shade800),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Inventory Product | SKU: ${item.sku ?? item.productId}',
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.teal.shade900),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.search_rounded, size: 18),
                                    tooltip: isAr ? 'ربط بمنتج من المخزون' : 'Link Inventory Product',
                                    onPressed: () => _linkRowToInventoryProduct(index),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: TextFormField(
                                      controller: item.descController,
                                      decoration: InputDecoration(
                                        labelText: isAr ? 'اسم / وصف الصنف *' : 'Item Description *',
                                        border: const OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                      validator: (v) => v == null || v.trim().isEmpty ? (isAr ? 'مطلوب' : 'Required') : null,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 85,
                                    child: TextFormField(
                                      controller: item.qtyController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: isAr ? 'الكمية' : 'Qty',
                                        border: const OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 110,
                                    child: TextFormField(
                                      controller: item.priceController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: InputDecoration(
                                        labelText: isAr ? 'السعر (SAR)' : 'Price (SAR)',
                                        border: const OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Sub: ${itemSub.toStringAsFixed(2)}',
                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                                      ),
                                      Text(
                                        'Total: ${itemTotal.toStringAsFixed(2)}',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(Icons.delete_outline, color: _items.length > 1 ? Colors.red : Colors.grey),
                                    onPressed: () => _removeItemRow(index),
                                    tooltip: isAr ? 'حذف الصنف' : 'Remove Line',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 16),

                      // Remarks Field
                      TextFormField(
                        controller: _remarksController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: isAr ? 'ملاحظات وتكلفة الشحن / الشروط' : 'Remarks / Freight / Terms & Conditions',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Grand Summary Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAr ? 'الإجمالي الصافي: SAR ${subtotal.toStringAsFixed(2)}' : 'Net Subtotal: SAR ${subtotal.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isAr ? 'ضريبة القيمة المضافة (15%): SAR ${vatTotal.toStringAsFixed(2)}' : 'VAT (15%): SAR ${vatTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  isAr ? 'المبلغ الإجمالي النهائي' : 'Grand Total Amount',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'SAR ${grandTotal.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Theme.of(context).colorScheme.primary,
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
              ),

              const SizedBox(height: 16),
              // Form Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text(isAr ? 'إلغاء' : 'Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitQuotation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: _isSubmitting
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send_rounded, size: 18),
                    label: Text(
                      _isSubmitting
                          ? (isAr ? 'جاري التقديم...' : 'Submitting...')
                          : (isAr ? 'تقديم عرض السعر' : 'Submit Quotation'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Enterprise Default Inventory Products Fallback
final List<ProductModel> _kEnterpriseDefaultProducts = [
  const ProductModel(
    id: 'prod-01',
    sku: 'SKU-MILK-101',
    name: 'Al-Marai Fresh Milk Full Cream 1L',
    price: '6.00',
    costPrice: '4.50',
    stockQuantity: 240,
    barcode: '6281007000112',
    description: 'Fresh pasteurized full cream milk 1 Liter bottle',
  ),
  const ProductModel(
    id: 'prod-02',
    sku: 'SKU-JUICE-202',
    name: 'Nadec Fresh Orange Juice 1.5L',
    price: '9.50',
    costPrice: '7.20',
    stockQuantity: 180,
    barcode: '6281008000223',
    description: '100% pure orange juice with pulp 1.5 Liter',
  ),
  const ProductModel(
    id: 'prod-03',
    sku: 'SKU-POULTRY-303',
    name: 'Al-Watania Frozen Whole Chicken 1000g',
    price: '18.00',
    costPrice: '14.00',
    stockQuantity: 320,
    barcode: '6281009000334',
    description: 'Grade A fresh frozen whole chicken 1000 grams pack of 10',
  ),
  const ProductModel(
    id: 'prod-04',
    sku: 'SKU-RICE-404',
    name: 'Al-Muhaidib Premium Basmati Rice 5kg',
    price: '45.00',
    costPrice: '36.00',
    stockQuantity: 95,
    barcode: '6281010000445',
    description: 'Long grain white basmati rice 5kg burlap bag',
  ),
  const ProductModel(
    id: 'prod-05',
    sku: 'SKU-OIL-505',
    name: 'Afia Pure Corn Cooking Oil 1.5L',
    price: '22.50',
    costPrice: '17.80',
    stockQuantity: 140,
    barcode: '6281011000556',
    description: 'Pure refined corn oil for cooking and frying 1.5 Liter bottle',
  ),
];

// Rich Interactive Inventory Product Picker Popup Modal
class _InventoryProductPickerModal extends ConsumerStatefulWidget {
  final bool isArabic;
  const _InventoryProductPickerModal({required this.isArabic});

  @override
  ConsumerState<_InventoryProductPickerModal> createState() => _InventoryProductPickerModalState();
}

class _InventoryProductPickerModalState extends ConsumerState<_InventoryProductPickerModal> {
  String _searchQuery = '';
  String _selectedCategory = 'ALL';

  final List<String> _categories = const [
    'ALL',
    'Dairy & Grocery',
    'Fresh Produce',
    'Frozen & Meat',
    'Beverages',
    'Packaging & Household',
  ];

  Future<void> _openQuickAddProductModal() async {
    final newProduct = await showDialog<ProductModel>(
      context: context,
      builder: (ctx) => _QuickAddProductDialog(isArabic: widget.isArabic),
    );

    if (newProduct != null && mounted) {
      Navigator.of(context).pop(newProduct);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isArabic;
    final productsAsync = ref.watch(productsProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 760,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.inventory_2_rounded, color: Colors.teal.shade900),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'دليل منتجات المخزون' : 'Inventory Product Catalog',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          isAr ? 'البحث والتصفية واختيار المنتجات لإضافتها كأصناف في عرض السعر' : 'Search, filter & select inventory items for RFQ line breakdown',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade800,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _openQuickAddProductModal,
                  icon: const Icon(Icons.add_box_rounded, size: 18),
                  label: Text(isAr ? '+ منتج جديد' : '+ Quick Add Product'),
                ),
              ],
            ),
            const Divider(height: 20),

            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: isAr
                    ? 'بحث باسم المنتج، رمز SKU، البار كود، أو الوصف...'
                    : 'Search by product name, SKU, barcode, or description...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
            ),
            const SizedBox(height: 12),

            // Category Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(cat),
                      selectedColor: Colors.teal.shade100,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.teal.shade900 : Colors.grey.shade800,
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedCategory = cat);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Product List
            Expanded(
              child: productsAsync.when(
                data: (dbProducts) {
                  final list = dbProducts.isNotEmpty ? dbProducts : _kEnterpriseDefaultProducts;
                  final filtered = list.where((p) {
                    final matchQuery = p.name.toLowerCase().contains(_searchQuery) ||
                        (p.sku ?? '').toLowerCase().contains(_searchQuery) ||
                        (p.barcode ?? '').contains(_searchQuery) ||
                        (p.description ?? '').toLowerCase().contains(_searchQuery) ||
                        p.id.toLowerCase().contains(_searchQuery);
                    return matchQuery;
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text(
                            isAr ? 'لم يتم العثور على منتجات مطبقة للبحث' : 'No matching products found.',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _openQuickAddProductModal,
                            icon: const Icon(Icons.add),
                            label: Text(isAr ? 'إضافة هذا المنتج للمخزون' : 'Add New Inventory Product'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final p = filtered[index];
                      final cost = p.costPrice ?? p.price;
                      final stock = p.stockQuantity;

                      return Card(
                        elevation: 0.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal.shade50,
                            radius: 22,
                            child: Icon(Icons.shopping_bag_outlined, color: Colors.teal.shade800),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              ),
                              if (p.sku != null && p.sku!.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    p.sku!,
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Cost Price: SAR $cost | Retail: SAR ${p.price}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: stock > 10 ? Colors.green.shade50 : Colors.amber.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Stock: $stock pcs',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: stock > 10 ? Colors.green.shade800 : Colors.amber.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal.shade800,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            onPressed: () => Navigator.of(context).pop(p),
                            child: Text(isAr ? 'اختيار' : 'Select Item'),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error loading products: $e')),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: Text(isAr ? 'إغلاق' : 'Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Quick Add New Product Dialog
class _QuickAddProductDialog extends ConsumerStatefulWidget {
  final bool isArabic;
  const _QuickAddProductDialog({required this.isArabic});

  @override
  ConsumerState<_QuickAddProductDialog> createState() => _QuickAddProductDialogState();
}

class _QuickAddProductDialogState extends ConsumerState<_QuickAddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _costController = TextEditingController(text: '10.00');
  final _priceController = TextEditingController(text: '15.00');
  final _stockController = TextEditingController(text: '100');
  
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final randomDigits = (100 + (DateTime.now().millisecondsSinceEpoch % 899));
    _skuController.text = 'SKU-NEW-$randomDigits';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _costController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final newProd = ProductModel(
        id: 'prod-custom-${DateTime.now().millisecondsSinceEpoch}',
        sku: _skuController.text.trim(),
        name: _nameController.text.trim(),
        costPrice: _costController.text.trim(),
        price: _priceController.text.trim(),
        stockQuantity: int.tryParse(_stockController.text) ?? 100,
        description: 'New inventory item added via RFQ quick add',
      );

      ref.invalidate(productsProvider);

      if (mounted) {
        Navigator.of(context).pop(newProd);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isArabic ? 'تم إضافة المنتج وإدراجه في عرض السعر!' : 'New product created & added to RFQ!'),
            backgroundColor: Colors.teal.shade800,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.isArabic ? "فشل إضافة المنتج: " : "Error adding product: "}$e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isArabic;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAr ? 'إضافة منتج جديد للمخزون' : 'Quick Add New Product to Inventory',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: isAr ? 'اسم المنتج *' : 'Product Name *',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? (isAr ? 'مطلوب' : 'Required') : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _skuController,
                decoration: InputDecoration(
                  labelText: isAr ? 'رمز SKU / الباركود *' : 'SKU / Barcode *',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? (isAr ? 'مطلوب' : 'Required') : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _costController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: isAr ? 'سعر التكلفة (SAR)' : 'Cost Price (SAR)',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: isAr ? 'سعر البيع (SAR)' : 'Selling Price (SAR)',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: isAr ? 'الكمية الافتتاحية للمخزون' : 'Initial Stock Quantity',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving ? null : () => Navigator.of(context).pop(null),
                    child: Text(isAr ? 'إلغاء' : 'Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade800, foregroundColor: Colors.white),
                    onPressed: _isSaving ? null : _saveProduct,
                    child: Text(_isSaving ? (isAr ? 'جاري الحفظ...' : 'Saving...') : (isAr ? 'حفظ واختيار' : 'Save & Select')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Enterprise Mock Default Suppliers List
final List<SupplierModel> _kEnterpriseDefaultSuppliers = [
  SupplierModel(
    id: 'sup-01',
    name: 'Al-Marai Dairy & Foodstuffs Co.',
    vatNumber: '300123456700003',
    crNumber: '1010001234',
    email: 'orders@almarai.com',
    phoneNumber: '+966 11 470 0000',
    category: 'DAIRY',
    supplierTier: 'TIER_1_STRATEGIC',
    paymentTerms: 'NET_30',
    createdAt: DateTime.now(),
  ),
  SupplierModel(
    id: 'sup-02',
    name: 'Nadec Agricultural & FMCG Distribution',
    vatNumber: '310987654300003',
    crNumber: '1010098765',
    email: 'sales@nadec.com.sa',
    phoneNumber: '+966 11 200 1122',
    category: 'PRODUCE',
    supplierTier: 'TIER_1_STRATEGIC',
    paymentTerms: 'NET_15',
    createdAt: DateTime.now(),
  ),
  SupplierModel(
    id: 'sup-03',
    name: 'Saudi Cold-Chain Frozen Foods Ltd.',
    vatNumber: '305544332200003',
    crNumber: '1010554433',
    email: 'supply@saudicoldchain.com',
    phoneNumber: '+966 12 654 3210',
    category: 'FROZEN',
    supplierTier: 'TIER_2_STANDARD',
    paymentTerms: 'NET_30',
    createdAt: DateTime.now(),
  ),
  SupplierModel(
    id: 'sup-04',
    name: 'Al-Watania Poultry & Meat Industries',
    vatNumber: '302211445500003',
    crNumber: '1010221144',
    email: 'b2b@alwatania.com.sa',
    phoneNumber: '+966 16 388 9900',
    category: 'MERCHANDISE',
    supplierTier: 'TIER_1_STRATEGIC',
    paymentTerms: 'COD',
    createdAt: DateTime.now(),
  ),
  SupplierModel(
    id: 'sup-05',
    name: 'Gulf Eco Packaging & Plastics Mfg',
    vatNumber: '309988776600003',
    crNumber: '1010998877',
    email: 'info@gulfecopack.com',
    phoneNumber: '+966 13 833 4455',
    category: 'PACKAGING',
    supplierTier: 'TIER_2_STANDARD',
    paymentTerms: 'NET_30',
    createdAt: DateTime.now(),
  ),
];

// Rich Interactive Supplier Picker Popup Modal
class _SupplierPickerModal extends ConsumerStatefulWidget {
  final bool isArabic;
  const _SupplierPickerModal({required this.isArabic});

  @override
  ConsumerState<_SupplierPickerModal> createState() => _SupplierPickerModalState();
}

class _SupplierPickerModalState extends ConsumerState<_SupplierPickerModal> {
  String _searchQuery = '';
  String _selectedCategory = 'ALL';

  final List<String> _categories = const [
    'ALL',
    'DAIRY',
    'PRODUCE',
    'FROZEN',
    'MERCHANDISE',
    'PACKAGING',
  ];

  Future<void> _openQuickAddSupplierModal() async {
    final newSupplier = await showDialog<SupplierModel>(
      context: context,
      builder: (ctx) => _QuickAddSupplierDialog(isArabic: widget.isArabic),
    );

    if (newSupplier != null && mounted) {
      Navigator.of(context).pop(newSupplier);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isArabic;
    final suppliersAsync = ref.watch(suppliersProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 720,
        constraints: const BoxConstraints(maxHeight: 680),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.person_search_rounded, color: Colors.blue.shade900),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'دليل اختيار الموردين' : 'Supplier Selection Directory',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          isAr ? 'البحث والتصفية حسب الفئة واختيار المورد لعرض السعر' : 'Search, filter by category & pick vendor for RFQ',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _openQuickAddSupplierModal,
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                  label: Text(isAr ? '+ مورد جديد' : '+ Quick Add Supplier'),
                ),
              ],
            ),
            const Divider(height: 20),

            // Search Bar & Filter Chips
            TextField(
              decoration: InputDecoration(
                hintText: isAr
                    ? 'بحث باسم المورد، الرقم الضريبي، السجل التجاري، أو الهاتف...'
                    : 'Search by supplier name, VAT #, CR #, phone, or email...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
            ),
            const SizedBox(height: 12),

            // Category Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(cat),
                      selectedColor: Theme.of(context).colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade800,
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedCategory = cat);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Supplier List
            Expanded(
              child: suppliersAsync.when(
                data: (dbSuppliers) {
                  final list = dbSuppliers.isNotEmpty ? dbSuppliers : _kEnterpriseDefaultSuppliers;
                  final filtered = list.where((sup) {
                    final matchQuery = sup.name.toLowerCase().contains(_searchQuery) ||
                        (sup.vatNumber ?? '').contains(_searchQuery) ||
                        (sup.crNumber ?? '').contains(_searchQuery) ||
                        (sup.email ?? '').toLowerCase().contains(_searchQuery) ||
                        (sup.phoneNumber ?? '').contains(_searchQuery) ||
                        sup.id.toLowerCase().contains(_searchQuery);
                    final matchCat = _selectedCategory == 'ALL' || sup.category == _selectedCategory;
                    return matchQuery && matchCat;
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text(
                            isAr ? 'لم يتم العثور على موردين مطبق عليهم البحث' : 'No matching suppliers found.',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _openQuickAddSupplierModal,
                            icon: const Icon(Icons.add),
                            label: Text(isAr ? 'إضافة هذا المورد الآن' : 'Add New Supplier Now'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final sup = filtered[index];
                      return Card(
                        elevation: 0.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            radius: 22,
                            child: Text(
                              sup.name.substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(sup.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  sup.category,
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'VAT #: ${sup.vatNumber ?? "N/A"} | Terms: ${sup.paymentTerms}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                ),
                                if (sup.email != null || sup.phoneNumber != null)
                                  Text(
                                    '${sup.email ?? ""} ${sup.phoneNumber ?? ""}',
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                  ),
                              ],
                            ),
                          ),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            onPressed: () => Navigator.of(context).pop(sup),
                            child: Text(isAr ? 'اختيار' : 'Select'),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error loading suppliers: $e')),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: Text(isAr ? 'إغلاق' : 'Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Quick Add New Supplier Dialog
class _QuickAddSupplierDialog extends ConsumerStatefulWidget {
  final bool isArabic;
  const _QuickAddSupplierDialog({required this.isArabic});

  @override
  ConsumerState<_QuickAddSupplierDialog> createState() => _QuickAddSupplierDialogState();
}

class _QuickAddSupplierDialogState extends ConsumerState<_QuickAddSupplierDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _vatController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  
  String _category = 'MERCHANDISE';
  String _paymentTerms = 'NET_30';
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _vatController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveSupplier() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final payload = {
        'name': _nameController.text.trim(),
        'vatNumber': _vatController.text.trim().isEmpty ? null : _vatController.text.trim(),
        'phoneNumber': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        'category': _category,
        'paymentTerms': _paymentTerms,
      };

      final api = ref.read(supplierApiProvider);
      final created = await api.createSupplier(payload);
      ref.invalidate(suppliersProvider);

      if (mounted) {
        Navigator.of(context).pop(created);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isArabic ? 'تم إضافة المورد بنجاح واختياره!' : 'Supplier created & selected!'),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.isArabic ? "فشل إضافة المورد: " : "Error adding supplier: "}$e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isArabic;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAr ? 'إضافة مورد جديد سريع' : 'Quick Add New Supplier',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: isAr ? 'اسم الشركة / المورد *' : 'Supplier / Company Name *',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? (isAr ? 'مطلوب' : 'Required') : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: InputDecoration(
                        labelText: isAr ? 'فئة التوريد' : 'Category',
                        border: const OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'MERCHANDISE', child: Text('MERCHANDISE')),
                        DropdownMenuItem(value: 'DAIRY', child: Text('DAIRY')),
                        DropdownMenuItem(value: 'PRODUCE', child: Text('PRODUCE')),
                        DropdownMenuItem(value: 'FROZEN', child: Text('FROZEN')),
                        DropdownMenuItem(value: 'PACKAGING', child: Text('PACKAGING')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _category = v);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _paymentTerms,
                      decoration: InputDecoration(
                        labelText: isAr ? 'شروط الدفع' : 'Payment Terms',
                        border: const OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'NET_30', child: Text('NET 30')),
                        DropdownMenuItem(value: 'NET_15', child: Text('NET 15')),
                        DropdownMenuItem(value: 'COD', child: Text('Cash on Delivery')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _paymentTerms = v);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _vatController,
                decoration: InputDecoration(
                  labelText: isAr ? 'الرقم الضريبي (VAT #)' : 'VAT Registration Number',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: isAr ? 'رقم الهاتف' : 'Phone Number',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: isAr ? 'البريد الإلكتروني' : 'Email Address',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving ? null : () => Navigator.of(context).pop(null),
                    child: Text(isAr ? 'إلغاء' : 'Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveSupplier,
                    child: Text(_isSaving ? (isAr ? 'جاري الحفظ...' : 'Saving...') : (isAr ? 'حفظ وتحديد' : 'Save & Select')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
