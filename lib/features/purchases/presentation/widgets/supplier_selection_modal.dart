import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../suppliers/domain/supplier_model.dart';
import '../../../suppliers/providers/suppliers_provider.dart';

class SupplierSelectionModal extends ConsumerStatefulWidget {
  final bool isArabic;
  final String? currentSelectedSupplierId;
  final ValueChanged<SupplierModel?> onSelected;
  final bool allowClear;

  const SupplierSelectionModal({
    super.key,
    required this.isArabic,
    this.currentSelectedSupplierId,
    required this.onSelected,
    this.allowClear = true,
  });

  @override
  ConsumerState<SupplierSelectionModal> createState() => _SupplierSelectionModalState();
}

class _SupplierSelectionModalState extends ConsumerState<SupplierSelectionModal> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _categoryFilter = 'ALL';
  String _tierFilter = 'ALL';
  String _termsFilter = 'ALL';
  bool _isGridView = true; // default to rich Grid View
  SupplierModel? _highlightedSupplier;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final suppliers = ref.read(suppliersProvider).value ?? [];
      if (widget.currentSelectedSupplierId != null && suppliers.isNotEmpty) {
        final match = suppliers.where((s) => s.id == widget.currentSelectedSupplierId).firstOrNull;
        if (match != null && mounted) {
          setState(() => _highlightedSupplier = match);
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getTierColor(String tier) {
    switch (tier.toUpperCase()) {
      case 'TIER_1_STRATEGIC':
        return Colors.purple.shade700;
      case 'TIER_2_STANDARD':
        return Colors.blue.shade700;
      case 'TIER_3_OCCASIONAL':
        return Colors.teal.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  String _formatTierName(String tier, bool isAr) {
    switch (tier.toUpperCase()) {
      case 'TIER_1_STRATEGIC':
        return isAr ? 'استراتيجي (Tier 1)' : 'Tier 1 Strategic';
      case 'TIER_2_STANDARD':
        return isAr ? 'أساسي (Tier 2)' : 'Tier 2 Standard';
      case 'TIER_3_OCCASIONAL':
        return isAr ? 'موسمي/عرضي (Tier 3)' : 'Tier 3 Occasional';
      default:
        return tier;
    }
  }

  String _formatCategory(String cat, bool isAr) {
    switch (cat.toUpperCase()) {
      case 'MERCHANDISE':
        return isAr ? 'بضائع تجارية' : 'Merchandise';
      case 'RAW_MATERIALS':
        return isAr ? 'مواد خام' : 'Raw Materials';
      case 'SERVICES':
        return isAr ? 'خدمات' : 'Services';
      case 'LOGISTICS':
        return isAr ? 'لوجستيات ونقل' : 'Logistics';
      case 'EQUIPMENT':
        return isAr ? 'معدات وأصول' : 'Equipment';
      default:
        return cat;
    }
  }

  List<SupplierModel> _filterSuppliers(List<SupplierModel> suppliers) {
    return suppliers.where((s) {
      final q = _searchQuery.trim().toLowerCase();
      final matchSearch = q.isEmpty ||
          s.name.toLowerCase().contains(q) ||
          (s.vatNumber ?? '').toLowerCase().contains(q) ||
          (s.crNumber ?? '').toLowerCase().contains(q) ||
          (s.email ?? '').toLowerCase().contains(q) ||
          (s.phoneNumber ?? '').toLowerCase().contains(q) ||
          s.category.toLowerCase().contains(q);

      final matchCat = _categoryFilter == 'ALL' || s.category.toUpperCase() == _categoryFilter;
      final matchTier = _tierFilter == 'ALL' || s.supplierTier.toUpperCase() == _tierFilter;
      final matchTerms = _termsFilter == 'ALL' || s.paymentTerms.toUpperCase() == _termsFilter;

      return matchSearch && matchCat && matchTier && matchTerms;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isArabic;
    final suppliersAsync = ref.watch(suppliersProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Container(
        width: 1000,
        height: 720,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(bottom: BorderSide(color: Colors.indigo.shade100)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.indigo.shade700,
                    radius: 18,
                    child: const Icon(Icons.business_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'دليل وبحث الموردين المعتمدين' : 'Supplier Directory & Selection',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
                        ),
                        Text(
                          isAr
                              ? 'بحث وتصفية واختيار المورد لعرض فواتيره أو تسجيل فاتورة مستلمة جديدة'
                              : 'Search, filter, and pick a supplier for bill recording or ledger filtering',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),

                  // View Mode Toggle (Grid vs Table)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.indigo.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.grid_view_rounded,
                            size: 18,
                            color: _isGridView ? Colors.indigo.shade700 : Colors.grey.shade600,
                          ),
                          tooltip: isAr ? 'عرض شبكي (Grid)' : 'Grid View',
                          onPressed: () => setState(() => _isGridView = true),
                        ),
                        Container(width: 1, height: 20, color: Colors.indigo.shade100),
                        IconButton(
                          icon: Icon(
                            Icons.table_rows_rounded,
                            size: 18,
                            color: !_isGridView ? Colors.indigo.shade700 : Colors.grey.shade600,
                          ),
                          tooltip: isAr ? 'عرض جدولي (Table)' : 'Table View',
                          onPressed: () => setState(() => _isGridView = false),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Refresh Button
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    tooltip: isAr ? 'تحديث البيانات' : 'Refresh',
                    onPressed: () => ref.invalidate(suppliersProvider),
                  ),

                  // Close Button
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Search & Filter Toolbar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Search field
                      Expanded(
                        flex: 4,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: isAr
                                ? 'بحث بالاسم، السجل التجاري CR، الرقم الضريبي VAT، البريد أو الهاتف...'
                                : 'Search by supplier name, CR #, VAT #, email, phone...',
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
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                          onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Category Filter
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          initialValue: _categoryFilter,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: isAr ? 'التصنيف' : 'Category',
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          items: [
                            DropdownMenuItem(value: 'ALL', child: Text(isAr ? 'كل التصنيفات' : 'All Categories')),
                            DropdownMenuItem(value: 'MERCHANDISE', child: Text(isAr ? 'بضائع' : 'Merchandise')),
                            DropdownMenuItem(value: 'SERVICES', child: Text(isAr ? 'خدمات' : 'Services')),
                            DropdownMenuItem(value: 'RAW_MATERIALS', child: Text(isAr ? 'مواد خام' : 'Raw Materials')),
                            DropdownMenuItem(value: 'LOGISTICS', child: Text(isAr ? 'لوجستيات' : 'Logistics')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _categoryFilter = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Tier Filter
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          initialValue: _tierFilter,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: isAr ? 'المستوى' : 'Tier',
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          items: [
                            DropdownMenuItem(value: 'ALL', child: Text(isAr ? 'كل المستويات' : 'All Tiers')),
                            DropdownMenuItem(value: 'TIER_1_STRATEGIC', child: Text(isAr ? 'Tier 1 استراتيجي' : 'Tier 1 Strategic')),
                            DropdownMenuItem(value: 'TIER_2_STANDARD', child: Text(isAr ? 'Tier 2 أساسي' : 'Tier 2 Standard')),
                            DropdownMenuItem(value: 'TIER_3_OCCASIONAL', child: Text(isAr ? 'Tier 3 موسمي' : 'Tier 3 Occasional')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _tierFilter = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Payment Terms Filter
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          initialValue: _termsFilter,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: isAr ? 'شروط الدفع' : 'Payment Terms',
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          items: [
                            DropdownMenuItem(value: 'ALL', child: Text(isAr ? 'كل الشروط' : 'All Terms')),
                            DropdownMenuItem(value: 'CASH', child: Text(isAr ? 'نقدي (Cash)' : 'Cash')),
                            const DropdownMenuItem(value: 'NET_15', child: Text('Net 15')),
                            const DropdownMenuItem(value: 'NET_30', child: Text('Net 30')),
                            const DropdownMenuItem(value: 'NET_60', child: Text('Net 60')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _termsFilter = val);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content Area (Grid or Table)
            Expanded(
              child: suppliersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 36),
                      const SizedBox(height: 8),
                      Text(isAr ? 'خطأ في تحميل الموردين: $err' : 'Error loading suppliers: $err'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(suppliersProvider),
                        child: Text(isAr ? 'إعادة المحاولة' : 'Retry'),
                      ),
                    ],
                  ),
                ),
                data: (allSuppliers) {
                  final filtered = _filterSuppliers(allSuppliers);

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            isAr ? 'لا توجد نتائج مطابقة لشروط البحث والفلاتر' : 'No suppliers match the current filters',
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  }

                  return _isGridView ? _buildGridView(filtered, isAr) : _buildTableView(filtered, isAr);
                },
              ),
            ),

            // Actions Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  // Currently chosen indicator
                  if (_highlightedSupplier != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.indigo.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 16, color: Colors.indigo.shade700),
                          const SizedBox(width: 6),
                          Text(
                            '${isAr ? 'المورد المختار:' : 'Selected:'} ${_highlightedSupplier!.name}',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.indigo.shade900),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Text(
                      isAr ? 'انقر على أي مورد لاختياره' : 'Click on any supplier to select',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],

                  const Spacer(),

                  if (widget.allowClear) ...[
                    TextButton.icon(
                      icon: const Icon(Icons.clear_all, size: 18),
                      label: Text(isAr ? 'إلغاء التحديد (الكل)' : 'Clear Selection (All)'),
                      onPressed: () {
                        widget.onSelected(null);
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(width: 8),
                  ],

                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(isAr ? 'إلغاء' : 'Cancel'),
                  ),
                  const SizedBox(width: 10),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.check, size: 18),
                    label: Text(
                      isAr ? 'تأكيد الاختيار' : 'Confirm Selection',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: _highlightedSupplier != null
                        ? () {
                            widget.onSelected(_highlightedSupplier);
                            Navigator.of(context).pop();
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- GRID VIEW (CARDS) ---
  Widget _buildGridView(List<SupplierModel> suppliers, bool isAr) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 850 ? 3 : (constraints.maxWidth > 550 ? 2 : 1);
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.45,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: suppliers.length,
          itemBuilder: (context, idx) {
            final s = suppliers[idx];
            final isSelected = _highlightedSupplier?.id == s.id;
            final tierColor = _getTierColor(s.supplierTier);

            return InkWell(
              onTap: () {
                setState(() => _highlightedSupplier = s);
              },
              onDoubleTap: () {
                widget.onSelected(s);
                Navigator.of(context).pop();
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.indigo.shade50.withValues(alpha: 0.8) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.indigo.shade700 : Colors.grey.shade300,
                    width: isSelected ? 2.0 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected ? Colors.indigo.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.03),
                      blurRadius: isSelected ? 8 : 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row: Avatar + Name + Check icon
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: tierColor.withValues(alpha: 0.15),
                          child: Text(
                            s.name.isNotEmpty ? s.name[0].toUpperCase() : 'S',
                            style: TextStyle(fontWeight: FontWeight.bold, color: tierColor, fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isSelected ? Colors.indigo.shade900 : Colors.black87,
                                ),
                              ),
                              Text(
                                _formatCategory(s.category, isAr),
                                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade700,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, size: 14, color: Colors.white),
                          ),
                      ],
                    ),
                    const Spacer(),

                    // Badges (Tier & Terms)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: tierColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _formatTierName(s.supplierTier, isAr),
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: tierColor),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            s.paymentTerms,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Tax / CR Info
                    if ((s.vatNumber ?? '').isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.receipt_outlined, size: 12, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            'VAT: ${s.vatNumber}',
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    if ((s.crNumber ?? '').isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.badge_outlined, size: 12, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            'CR: ${s.crNumber}',
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- TABLE / DATA GRID VIEW ---
  Widget _buildTableView(List<SupplierModel> suppliers, bool isAr) {
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            showCheckboxColumn: false,
            headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
            columns: [
              DataColumn(label: Text(isAr ? 'الاختيار' : 'Select')),
              DataColumn(label: Text(isAr ? 'اسم المورد' : 'Supplier Name')),
              DataColumn(label: Text(isAr ? 'التصنيف' : 'Category')),
              DataColumn(label: Text(isAr ? 'المستوى' : 'Tier')),
              DataColumn(label: Text(isAr ? 'الرقم الضريبي VAT' : 'VAT Number')),
              DataColumn(label: Text(isAr ? 'السجل التجاري CR' : 'CR Number')),
              DataColumn(label: Text(isAr ? 'شروط الدفع' : 'Payment Terms')),
              DataColumn(label: Text(isAr ? 'الهاتف' : 'Phone')),
              DataColumn(label: Text(isAr ? 'إجراء' : 'Action')),
            ],
            rows: suppliers.map((s) {
              final isSelected = _highlightedSupplier?.id == s.id;
              final tierColor = _getTierColor(s.supplierTier);

              return DataRow(
                selected: isSelected,
                onSelectChanged: (_) {
                  setState(() => _highlightedSupplier = s);
                },
                cells: [
                  DataCell(
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: isSelected ? Colors.indigo.shade700 : Colors.grey.shade400,
                      size: 20,
                    ),
                  ),
                  DataCell(
                    Text(
                      s.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataCell(Text(_formatCategory(s.category, isAr))),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: tierColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _formatTierName(s.supplierTier, isAr),
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: tierColor),
                      ),
                    ),
                  ),
                  DataCell(Text(s.vatNumber ?? '-')),
                  DataCell(Text(s.crNumber ?? '-')),
                  DataCell(Text(s.paymentTerms)),
                  DataCell(Text(s.phoneNumber ?? '-')),
                  DataCell(
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? Colors.indigo.shade700 : Colors.grey.shade200,
                        foregroundColor: isSelected ? Colors.white : Colors.black87,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        elevation: 0,
                      ),
                      onPressed: () {
                        widget.onSelected(s);
                        Navigator.of(context).pop();
                      },
                      child: Text(isAr ? 'اختيار' : 'Select', style: const TextStyle(fontSize: 11)),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
