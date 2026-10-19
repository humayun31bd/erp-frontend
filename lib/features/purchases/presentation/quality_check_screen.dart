import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:erp_frontend/app.dart';
import '../domain/procurement_models.dart';
import '../providers/procurement_provider.dart';
import '../../../../core/widgets/feature_guard.dart';
import '../utils/qc_pdf_printer.dart';
import '../utils/procurement_document_formatter.dart';
import 'widgets/qc_details_dialog.dart';
import 'widgets/qc_csv_import_dialog.dart';

class QualityCheckScreen extends ConsumerStatefulWidget {
  const QualityCheckScreen({super.key});

  @override
  ConsumerState<QualityCheckScreen> createState() => _QualityCheckScreenState();
}

class _QualityCheckScreenState extends ConsumerState<QualityCheckScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'ALL';
  String? _selectedInspector;
  String _sortBy = 'DATE_DESC';
  bool _isTableView = false; // false = Card View, true = Grid / Table View

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetails(QualityCheckRecordModel qc, bool isArabic) {
    showDialog(
      context: context,
      builder: (ctx) => QcDetailsDialog(qc: qc, isArabic: isArabic),
    );
  }

  void _openCsvImport(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (ctx) => QcCsvImportDialog(isArabic: isArabic),
    );
  }

  void _printQc(QualityCheckRecordModel qc) {
    QcPdfPrinter.printQc(qc);
  }

  void _printFilteredReport(List<QualityCheckRecordModel> filtered, bool isArabic) {
    if (filtered.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic ? 'لا توجد سجلات لطباعتها' : 'No inspection records available to print'),
          backgroundColor: Colors.amber.shade800,
        ),
      );
      return;
    }
    final title = isArabic
        ? 'تقرير سجل فحوصات ومطابقة الجودة (QC Audit Register)'
        : 'Quality Check (QC) Audit Register Report';
    QcPdfPrinter.printQcRegister(qcList: filtered, title: title);
  }

  List<QualityCheckRecordModel> _applyFiltersAndSort(List<QualityCheckRecordModel> qcList) {
    final filtered = qcList.where((qc) {
      final query = _searchQuery.trim().toLowerCase();
      final matchQuery = query.isEmpty ||
          qc.qcNumber.toLowerCase().contains(query) ||
          qc.grnNumber.toLowerCase().contains(query) ||
          qc.inspectorName.toLowerCase().contains(query) ||
          (qc.remarks ?? '').toLowerCase().contains(query) ||
          qc.items.any((item) =>
              item.description.toLowerCase().contains(query) ||
              (item.defectReason ?? '').toLowerCase().contains(query));

      bool matchStatus = true;
      if (_selectedStatus == 'PASSED') {
        matchStatus = qc.overallStatus.toUpperCase() == 'PASSED';
      } else if (_selectedStatus == 'PARTIAL_PASSED') {
        matchStatus = qc.overallStatus.toUpperCase() == 'PARTIAL_PASSED';
      } else if (_selectedStatus == 'FAILED') {
        matchStatus = qc.overallStatus.toUpperCase() == 'FAILED' ||
            qc.overallStatus.toUpperCase() == 'REJECTED';
      }

      final matchInspector = _selectedInspector == null ||
          _selectedInspector == 'ALL' ||
          qc.inspectorName == _selectedInspector;

      return matchQuery && matchStatus && matchInspector;
    }).toList();

    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'DATE_ASC':
          return a.checkDate.compareTo(b.checkDate);
        case 'REJECTED_DESC':
          return b.totalRejected.compareTo(a.totalRejected);
        case 'VOLUME_DESC':
          return b.totalReceived.compareTo(a.totalReceived);
        case 'QC_NO':
          return a.qcNumber.compareTo(b.qcNumber);
        case 'DATE_DESC':
        default:
          return b.checkDate.compareTo(a.checkDate);
      }
    });

    return filtered;
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    switch (status.toUpperCase()) {
      case 'PASSED':
        bg = Colors.green.shade50;
        fg = Colors.green.shade800;
        break;
      case 'PARTIAL_PASSED':
        bg = Colors.amber.shade50;
        fg = Colors.amber.shade900;
        break;
      case 'FAILED':
      case 'REJECTED':
        bg = Colors.red.shade50;
        fg = Colors.red.shade800;
        break;
      default:
        bg = Colors.grey.shade100;
        fg = Colors.grey.shade800;
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
    final qcAsync = ref.watch(qualityChecksProvider);
    final theme = Theme.of(context);
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'فحوصات الجودة (QC Inspections)' : 'Quality Check Inspections (QC)'),
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
                      color: !_isTableView ? Colors.teal.shade700 : Colors.transparent,
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
                      color: _isTableView ? Colors.teal.shade700 : Colors.transparent,
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

          // Print Audit Register Button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.print_rounded, size: 18),
            label: Text(isArabic ? 'طباعة السجل' : 'Print Register'),
            onPressed: () {
              final allQc = qcAsync.asData?.value ?? [];
              final filtered = _applyFiltersAndSort(allQc);
              _printFilteredReport(filtered, isArabic);
            },
          ),
          const SizedBox(width: 8),

          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(qualityChecksProvider),
            tooltip: isArabic ? 'تحديث' : 'Refresh',
          ),

          // Perform QC Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.verified, size: 20),
            label: Text(
              isArabic ? '+ إجراء فحص جديد' : '+ Perform QC',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () => _showCreateQcDialog(context),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: FeatureGuard(
        featureKey: 'batchExpiry',
        featureTitle: 'Quality Check & Batch Inspection',
        child: Column(
          children: [
            // Controls Filter & Search Panel
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar + Inspector Dropdown + Sort By Dropdown
                  Row(
                    children: [
                      // Search Field
                      Expanded(
                        flex: 4,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: isArabic
                                ? 'بحث برقم QC، رقم GRN، المفتش، الصنف، سبب العيب...'
                                : 'Search by QC #, GRN #, inspector, item description, defect...',
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

                      // Inspector Filter Dropdown
                      qcAsync.maybeWhen(
                        data: (qcList) {
                          final inspectors = qcList
                              .map((q) => q.inspectorName)
                              .toSet()
                              .where((name) => name.isNotEmpty)
                              .toList();

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedInspector ?? 'ALL',
                                hint: Text(isArabic ? 'المفتش' : 'Inspector'),
                                items: [
                                  DropdownMenuItem(
                                    value: 'ALL',
                                    child: Text(isArabic ? 'جميع المفتشين' : 'All Inspectors'),
                                  ),
                                  ...inspectors.map((ins) => DropdownMenuItem(
                                        value: ins,
                                        child: Text(ins),
                                      )),
                                ],
                                onChanged: (val) {
                                  setState(() => _selectedInspector = (val == 'ALL' ? null : val));
                                },
                              ),
                            ),
                          );
                        },
                        orElse: () => const SizedBox.shrink(),
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
                                value: 'REJECTED_DESC',
                                child: Text(isArabic ? 'الأعلى رفضاً' : 'Most Rejected'),
                              ),
                              DropdownMenuItem(
                                value: 'VOLUME_DESC',
                                child: Text(isArabic ? 'الأعلى استلاماً' : 'Highest Volume'),
                              ),
                              DropdownMenuItem(
                                value: 'QC_NO',
                                child: Text(isArabic ? 'رقم QC' : 'QC Number'),
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

                  // Status Filter Chips Row
                  qcAsync.maybeWhen(
                    data: (qcList) {
                      final passedCount =
                          qcList.where((q) => q.overallStatus.toUpperCase() == 'PASSED').length;
                      final partialCount =
                          qcList.where((q) => q.overallStatus.toUpperCase() == 'PARTIAL_PASSED').length;
                      final failedCount = qcList
                          .where((q) =>
                              q.overallStatus.toUpperCase() == 'FAILED' ||
                              q.overallStatus.toUpperCase() == 'REJECTED')
                          .length;
                      final filtered = _applyFiltersAndSort(qcList);

                      return Row(
                        children: [
                          _buildFilterChip('ALL', isArabic ? 'الكل' : 'All', qcList.length),
                          const SizedBox(width: 6),
                          _buildFilterChip('PASSED', isArabic ? 'مطابق (ناجح)' : 'Passed', passedCount),
                          const SizedBox(width: 6),
                          _buildFilterChip('PARTIAL_PASSED', isArabic ? 'مطابق جزئياً' : 'Partial Passed', partialCount),
                          const SizedBox(width: 6),
                          _buildFilterChip('FAILED', isArabic ? 'مرفوض' : 'Failed / Rejected', failedCount),

                          const Spacer(),

                          Text(
                            isArabic
                                ? 'عرض ${filtered.length} من أصل ${qcList.length} فحص'
                                : 'Showing ${filtered.length} of ${qcList.length} QC inspections',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                          ),

                          if (_searchQuery.isNotEmpty || _selectedStatus != 'ALL' || _selectedInspector != null) ...[
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
                                  _selectedInspector = null;
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

            // Main Body: Card View or Table Grid View
            Expanded(
              child: qcAsync.when(
                data: (qcList) {
                  final filtered = _applyFiltersAndSort(qcList);

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.fact_check_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            isArabic ? 'لا توجد سجلات فحص جودة مطابقة' : 'No quality check inspections match your criteria.',
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
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade700, foregroundColor: Colors.white),
                                onPressed: () => _showCreateQcDialog(context),
                                icon: const Icon(Icons.verified),
                                label: Text(isArabic ? 'إجراء فحص جديد' : 'Perform QC Inspection'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }

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
                        Text('Error loading Quality Checks: $err', style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => ref.invalidate(qualityChecksProvider),
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
      ),
    );
  }

  Widget _buildFilterChip(String statusKey, String label, int count) {
    final isSelected = _selectedStatus == statusKey;

    return FilterChip(
      selected: isSelected,
      label: Text('$label ($count)'),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Colors.white : Colors.grey.shade800,
      ),
      selectedColor: Colors.teal.shade700,
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
    List<QualityCheckRecordModel> filtered,
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
              maxCrossAxisExtent: 460,
              mainAxisExtent: 260,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final qc = filtered[index];
              return _buildQcCard(qc, theme, isArabic);
            },
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final qc = filtered[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildQcCard(qc, theme, isArabic),
            );
          },
        );
      },
    );
  }

  Widget _buildQcCard(
    QualityCheckRecordModel qc,
    ThemeData theme,
    bool isArabic,
  ) {
    final passRate = qc.totalReceived > 0
        ? ((qc.totalAccepted / qc.totalReceived) * 100).toStringAsFixed(1)
        : '100.0';

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () => _openDetails(qc, isArabic),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Row: Avatar, QC #, Status, Menu
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.teal.shade50,
                    child: Icon(Icons.verified_rounded, color: Colors.teal.shade700, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              qc.qcNumber,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.copy_rounded, size: 14, color: Colors.grey),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip: isArabic ? 'نسخ رقم QC' : 'Copy QC #',
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: qc.qcNumber));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${qc.qcNumber} copied!'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'GRN: ${ProcurementDocumentFormatter.formatGrnNumber(qc.grnNumber)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo.shade800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '• ${qc.inspectorName}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(qc.overallStatus),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, size: 20, color: Colors.grey),
                    onSelected: (val) {
                      if (val == 'PRINT') {
                        _printQc(qc);
                      } else if (val == 'VIEW') {
                        _openDetails(qc, isArabic);
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
                            Text(isArabic ? 'طباعة شهادة الفحص' : 'Print Certificate (PDF)'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Middle: Metric Bar / Stat Badges
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMiniStat(isArabic ? 'مستلم' : 'Rec', qc.totalReceived.toStringAsFixed(0), Colors.blue.shade700),
                    _buildMiniStat(isArabic ? 'مقبول' : 'Acc', qc.totalAccepted.toStringAsFixed(0), Colors.green.shade700),
                    _buildMiniStat(isArabic ? 'مرفوض' : 'Rej', qc.totalRejected.toStringAsFixed(0), qc.totalRejected > 0 ? Colors.red.shade700 : Colors.grey),
                    _buildMiniStat(isArabic ? 'مستبدل' : 'Exc', qc.totalExchanged.toStringAsFixed(0), qc.totalExchanged > 0 ? Colors.amber.shade800 : Colors.grey),
                  ],
                ),
              ),

              // Middle 2: Items count & defect tags
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${qc.items.length} ${isArabic ? "أصناف مفحوصة" : "Items tested"}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Text(
                      '${isArabic ? "نسبة القبول: " : "Yield: "}$passRate%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ),
                ],
              ),

              // Bottom Row: Date & Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('yyyy-MM-dd').format(qc.checkDate),
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton.filledTonal(
                        icon: const Icon(Icons.print_rounded, size: 18),
                        tooltip: isArabic ? 'طباعة شهادة الفحص' : 'Print Certificate',
                        onPressed: () => _printQc(qc),
                      ),
                      const SizedBox(width: 6),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _openDetails(qc, isArabic),
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

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  // Enterprise Grid Table View (DataTable)
  Widget _buildGridTableView(
    List<QualityCheckRecordModel> filtered,
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
              columnSpacing: 22,
              columns: [
                DataColumn(label: Text(isArabic ? 'رقم QC' : 'QC #', style: const TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text(isArabic ? 'رقم GRN' : 'GRN #', style: const TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text(isArabic ? 'المفتش' : 'Inspector', style: const TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text(isArabic ? 'تاريخ الفحص' : 'Inspection Date', style: const TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text(isArabic ? 'مستلم' : 'Received', style: const TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                DataColumn(label: Text(isArabic ? 'مقبول' : 'Accepted', style: const TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                DataColumn(label: Text(isArabic ? 'مرفوض' : 'Rejected', style: const TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                DataColumn(label: Text(isArabic ? 'نسبة القبول' : 'Yield (%)', style: const TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                DataColumn(label: Text(isArabic ? 'الحالة' : 'Status', style: const TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text(isArabic ? 'إجراءات' : 'Actions', style: const TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: filtered.asMap().entries.map((entry) {
                final idx = entry.key;
                final qc = entry.value;
                final passRate = qc.totalReceived > 0
                    ? ((qc.totalAccepted / qc.totalReceived) * 100).toStringAsFixed(1)
                    : '100.0';

                return DataRow(
                  color: WidgetStateProperty.resolveWith<Color?>((states) {
                    if (states.contains(WidgetState.hovered)) return Colors.teal.shade50.withValues(alpha: 0.5);
                    return idx.isEven ? Colors.white : Colors.grey.shade50;
                  }),
                  cells: [
                    DataCell(
                      InkWell(
                        onTap: () => _openDetails(qc, isArabic),
                        child: Text(
                          qc.qcNumber,
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade800),
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          ProcurementDocumentFormatter.formatGrnNumber(qc.grnNumber),
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade800),
                        ),
                      ),
                    ),
                    DataCell(Text(qc.inspectorName, style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text(DateFormat('yyyy-MM-dd').format(qc.checkDate))),
                    DataCell(Text(qc.totalReceived.toStringAsFixed(0))),
                    DataCell(
                      Text(
                        qc.totalAccepted.toStringAsFixed(0),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ),
                    DataCell(
                      Text(
                        qc.totalRejected.toStringAsFixed(0),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: qc.totalRejected > 0 ? Colors.red : Colors.grey,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '$passRate%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: double.parse(passRate) >= 90 ? Colors.green.shade800 : Colors.amber.shade900,
                        ),
                      ),
                    ),
                    DataCell(_buildStatusBadge(qc.overallStatus)),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility_rounded, size: 18),
                            tooltip: isArabic ? 'عرض التفاصيل' : 'View Details',
                            onPressed: () => _openDetails(qc, isArabic),
                          ),
                          IconButton(
                            icon: const Icon(Icons.print_rounded, size: 18),
                            tooltip: isArabic ? 'طباعة شهادة الفحص' : 'Print Certificate',
                            onPressed: () => _printQc(qc),
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

  void _showCreateQcDialog(BuildContext context) {
    final grnAsync = ref.read(goodsReceivedNotesProvider);

    grnAsync.whenData((grnList) {
      if (grnList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please record a Goods Received Note (GRN) first before performing QC.')),
        );
        return;
      }

      String selectedGrnId = grnList.first.id;
      String selectedGrnNumber = grnList.first.grnNumber;
      final inspectorController = TextEditingController(text: 'QC Inspector');
      final descController = TextEditingController(text: 'Inspected Items');
      final recQtyController = TextEditingController(text: '10');
      final accQtyController = TextEditingController(text: '10');
      final rejQtyController = TextEditingController(text: '0');
      final excQtyController = TextEditingController(text: '0');
      final defectReasonController = TextEditingController();
      final remarksController = TextEditingController();

      showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (context, setModalState) => AlertDialog(
            title: const Text('Perform Quality Check Inspection'),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 520,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedGrnId,
                      decoration: const InputDecoration(labelText: 'Select GRN *'),
                      items: grnList.map((g) {
                        return DropdownMenuItem(
                          value: g.id,
                          child: Text('${g.grnNumber} - ${g.supplierName} (${DateFormat('yyyy-MM-dd').format(g.receivedDate)})'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() {
                            selectedGrnId = val;
                            selectedGrnNumber = grnList.firstWhere((g) => g.id == val).grnNumber;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: inspectorController,
                      decoration: const InputDecoration(labelText: 'Inspector Name *'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: 'Item Description *'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: recQtyController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Received Qty'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: accQtyController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Accepted Qty'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: rejQtyController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Rejected Qty'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: excQtyController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Exchanged Qty'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: defectReasonController,
                      decoration: const InputDecoration(labelText: 'Defect Reason (if any)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: remarksController,
                      decoration: const InputDecoration(labelText: 'QC Inspection Remarks'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final rec = double.tryParse(recQtyController.text) ?? 10.0;
                  final acc = double.tryParse(accQtyController.text) ?? 10.0;
                  final rej = double.tryParse(rejQtyController.text) ?? 0.0;
                  final exc = double.tryParse(excQtyController.text) ?? 0.0;

                  final payload = {
                    'grnId': selectedGrnId,
                    'grnNumber': selectedGrnNumber,
                    'inspectorName': inspectorController.text.trim(),
                    'checkDate': DateTime.now().toIso8601String(),
                    'remarks': remarksController.text.trim(),
                    'items': [
                      {
                        'description': descController.text.trim().isEmpty ? 'Inspected Goods' : descController.text.trim(),
                        'receivedQuantity': rec,
                        'acceptedQuantity': acc,
                        'rejectedQuantity': rej,
                        'exchangedQuantity': exc,
                        'defectReason': defectReasonController.text.trim(),
                      }
                    ],
                  };

                  try {
                    await ref.read(procurementServiceProvider).createQualityCheck(payload);
                    ref.invalidate(qualityChecksProvider);
                    ref.invalidate(goodsReceivedNotesProvider);
                    if (ctx.mounted) Navigator.of(ctx).pop();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Quality Check completed successfully!')),
                      );
                    }
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text('Failed to save QC: $e')),
                      );
                    }
                  }
                },
                child: const Text('Save QC Record'),
              ),
            ],
          ),
        ),
      );
    });
  }
}
