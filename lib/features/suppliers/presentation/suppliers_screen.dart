import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app.dart';
import '../../../../core/routing/route_names.dart';
import '../domain/supplier_model.dart';
import '../providers/suppliers_provider.dart';

enum SupplierViewMode { card, grid, list }

class SuppliersScreen extends ConsumerStatefulWidget {
  const SuppliersScreen({super.key});

  @override
  ConsumerState<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends ConsumerState<SuppliersScreen> {
  SupplierViewMode _viewMode = SupplierViewMode.card;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterTag = 'ALL'; // ALL, VAT_ONLY, WITH_EMAIL, WITH_PHONE
  String _sortBy = 'NAME_ASC'; // NAME_ASC, NAME_DESC, NEWEST

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SupplierModel> _applyFilters(List<SupplierModel> suppliers) {
    var filtered = suppliers.where((s) {
      // Search text match
      final q = _searchQuery.trim().toLowerCase();
      if (q.isNotEmpty) {
        final nameMatch = s.name.toLowerCase().contains(q);
        final vatMatch = s.vatNumber?.toLowerCase().contains(q) ?? false;
        final crMatch = s.crNumber?.toLowerCase().contains(q) ?? false;
        final phoneMatch = s.phoneNumber?.toLowerCase().contains(q) ?? false;
        final emailMatch = s.email?.toLowerCase().contains(q) ?? false;
        if (!nameMatch && !vatMatch && !crMatch && !phoneMatch && !emailMatch) {
          return false;
        }
      }

      // Filter tags
      if (_filterTag == 'VAT_ONLY' && (s.vatNumber == null || s.vatNumber!.isEmpty)) return false;
      if (_filterTag == 'TIER_1' && s.supplierTier != 'TIER_1_PREFERRED') return false;
      if (_filterTag == 'RAW_MAT' && s.category != 'RAW_MATERIAL') return false;
      if (_filterTag == 'WITH_EMAIL' && (s.email == null || s.email!.isEmpty)) return false;
      if (_filterTag == 'WITH_PHONE' && (s.phoneNumber == null || s.phoneNumber!.isEmpty)) return false;

      return true;
    }).toList();

    // Sort
    if (_sortBy == 'NAME_ASC') {
      filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } else if (_sortBy == 'NAME_DESC') {
      filtered.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
    } else if (_sortBy == 'NEWEST') {
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return filtered;
  }

  void _showHelpGuideDialog(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.help_center_rounded, color: Color(0xFF4361EE), size: 28),
            const SizedBox(width: 10),
            Text(
              isArabic ? 'دليل إدارة الموردين والامتثال الضريبي' : 'Supplier Directory & ZATCA Guide',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SizedBox(
          width: 580,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGuideSection(
                  title: isArabic ? '١. متطلبات هيئة الزكاة والضريبة والجمارك (ZATCA)' : '1. ZATCA VAT & CR Compliance',
                  content: isArabic
                      ? '• الرقم الضريبي للمورد (VAT) يجب أن يتكون من 15 رقم يبدأ برقم 3 وينتهي برقم 3.\n'
                        '• السجل التجاري (CR) يتكون من 10 أرقام.\n'
                        '• تسجيل الفواتير الضريبية للشراء يتطلب وجود بيانات المورد مكتملة لتفادي الغرامات.'
                      : '• Supplier VAT registration number must be 15 digits starting & ending with 3.\n'
                        '• Commercial Registration (CR) number is 10 digits.\n'
                        '• Valid tax invoices require accurate supplier VAT details for tax input credits.',
                  icon: Icons.verified_user_rounded,
                  color: const Color(0xFF10B981),
                ),
                const SizedBox(height: 14),
                _buildGuideSection(
                  title: isArabic ? '٢. استيراد الموردين عبر ملف CSV' : '2. Bulk CSV Import Instructions',
                  content: isArabic
                      ? '• قم بإعداد ملف CSV يحتوي على الأعمدة التالية:\n'
                        '  name, vatNumber, crNumber, phoneNumber, email, address, bankDetails\n'
                        '• يمكنك نسخ القالب الجاهز مباشرة من نافذة الاستيراد ولصقه للرفع السريع.'
                      : '• Prepare your CSV with header fields:\n'
                        '  name, vatNumber, crNumber, phoneNumber, email, address, bankDetails\n'
                        '• Use the built-in CSV Paste tool to preview and import bulk records instantly.',
                  icon: Icons.upload_file_rounded,
                  color: const Color(0xFF3B82F6),
                ),
                const SizedBox(height: 14),
                _buildGuideSection(
                  title: isArabic ? '٣. طرق العرض وتصفية البيانات' : '3. CardView, GridView & Filtering',
                  content: isArabic
                      ? '• استخدم أزرار التبديل في الأعلى للتنقل بين العرض الشبكي (Grid)، كروت الموردين (Card)، أو القائمة (List).\n'
                        '• يمكنك البحث بالاسم، الرقم الضريبي، الهاتف، أو البريد الإلكتروني.'
                      : '• Toggle between CardView, GridView, and ListView using top action buttons.\n'
                        '• Instantly search suppliers by Name, VAT number, Phone, or Email.',
                  icon: Icons.view_compact_rounded,
                  color: const Color(0xFF8B5CF6),
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4361EE),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text(isArabic ? 'حسناً، فهمت' : 'Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideSection({required String title, required String content, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
                const SizedBox(height: 4),
                Text(content, style: const TextStyle(fontSize: 12.5, height: 1.4, color: Color(0xFF334155))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCsvImportDialog(BuildContext context, bool isArabic) {
    final TextEditingController csvController = TextEditingController();
    List<Map<String, String>> parsedItems = [];
    String? parseError;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          void parseCsvText(String text) {
            final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
            if (lines.isEmpty) {
              setDialogState(() {
                parsedItems = [];
                parseError = isArabic ? 'الملف فارغ' : 'CSV text is empty';
              });
              return;
            }

            final items = <Map<String, String>>[];
            int startIdx = 0;

            // Check if line 0 is header
            final firstLineLower = lines[0].toLowerCase();
            if (firstLineLower.contains('name') || firstLineLower.contains('vat')) {
              startIdx = 1;
            }

            for (int i = startIdx; i < lines.length; i++) {
              final cols = lines[i].split(',').map((c) => c.trim().replaceAll('"', '')).toList();
              if (cols.isEmpty || cols[0].isEmpty) continue;

              items.add({
                'name': cols[0],
                'vatNumber': cols.length > 1 ? cols[1] : '',
                'crNumber': cols.length > 2 ? cols[2] : '',
                'phoneNumber': cols.length > 3 ? cols[3] : '',
                'email': cols.length > 4 ? cols[4] : '',
                'address': cols.length > 5 ? cols[5] : '',
                'bankDetails': cols.length > 6 ? cols[6] : '',
              });
            }

            setDialogState(() {
              parsedItems = items;
              parseError = items.isEmpty ? (isArabic ? 'لم يتم العثور على سجلات صالحة' : 'No valid records found') : null;
            });
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.file_upload_rounded, color: Color(0xFF4361EE), size: 28),
                const SizedBox(width: 10),
                Text(
                  isArabic ? 'استيراد الموردين عبر CSV' : 'Import Suppliers from CSV',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: SizedBox(
              width: 650,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic
                          ? 'قم بلصق بيانات CSV بالصيغة:\nName, VatNumber, CrNumber, Phone, Email, Address, BankDetails'
                          : 'Paste your CSV lines with format:\nName, VatNumber, CrNumber, Phone, Email, Address, BankDetails',
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            const sample =
                                "Name,VatNumber,CrNumber,Phone,Email,Address,BankDetails\n"
                                "Al-Marai Foods Co.,310123456700003,1010123456,+966112345678,info@almarai.com,Riyadh Industrial City,NCB SA8810000012\n"
                                "P&G Saudi Distribution,310987654300003,1010987654,+966126543210,sales@pgsaudi.com,Jeddah Port Area,Rajhi SA4420000099\n"
                                "Nadec Dairy Industries,310445566700003,1010445566,+966114455667,orders@nadec.com,Haradh Highway,RiyadBank SA123";
                            csvController.text = sample;
                            parseCsvText(sample);
                          },
                          icon: const Icon(Icons.copy_all_rounded, size: 16),
                          label: Text(isArabic ? 'تحميل نموذج تجريبي' : 'Fill Sample Template'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: csvController,
                      maxLines: 5,
                      onChanged: (val) => parseCsvText(val),
                      decoration: InputDecoration(
                        hintText: "Supplier A, 310..., 1010..., +966..., info@a.com, Riyadh, Bank AlJazira",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                      ),
                    ),
                    if (parseError != null) ...[
                      const SizedBox(height: 8),
                      Text(parseError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                    ],
                    if (parsedItems.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        isArabic ? 'معاينة السجلات المكتشفة (${parsedItems.length}):' : 'Parsed Records Preview (${parsedItems.length}):',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 180),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SingleChildScrollView(
                          child: DataTable(
                            columnSpacing: 16,
                            headingRowHeight: 32,
                            dataRowMinHeight: 32,
                            dataRowMaxHeight: 40,
                            columns: [
                              DataColumn(label: Text(isArabic ? 'الاسم' : 'Name')),
                              DataColumn(label: Text(isArabic ? 'الرقم الضريبي' : 'VAT Number')),
                              DataColumn(label: Text(isArabic ? 'الهاتف' : 'Phone')),
                              DataColumn(label: Text(isArabic ? 'البريد' : 'Email')),
                            ],
                            rows: parsedItems.map((item) {
                              return DataRow(cells: [
                                DataCell(Text(item['name'] ?? '', style: const TextStyle(fontSize: 12))),
                                DataCell(Text(item['vatNumber'] ?? '', style: const TextStyle(fontSize: 12))),
                                DataCell(Text(item['phoneNumber'] ?? '', style: const TextStyle(fontSize: 12))),
                                DataCell(Text(item['email'] ?? '', style: const TextStyle(fontSize: 12))),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(isArabic ? 'إلغاء' : 'Cancel'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4361EE),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: parsedItems.isEmpty
                    ? null
                    : () async {
                        try {
                          final api = ref.read(supplierApiProvider);
                          await api.importSuppliers(parsedItems);
                          ref.invalidate(suppliersProvider);
                          if (mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isArabic
                                    ? 'تم استيراد ${parsedItems.length} مورد بنجاح'
                                    : 'Successfully imported ${parsedItems.length} suppliers'),
                                backgroundColor: const Color(0xFF10B981),
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isArabic ? 'فشل الاستيراد: $e' : 'Import failed: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                icon: const Icon(Icons.file_upload_rounded, size: 18),
                label: Text(isArabic ? 'تأكيد الاستيراد' : 'Import ${parsedItems.length} Records'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _makePhoneCall(String phone) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final suppliersAsync = ref.watch(suppliersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4361EE).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.local_shipping_rounded, color: Color(0xFF4361EE)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? 'دليل الموردين' : 'Supplier Directory',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
                ),
                Text(
                  isArabic ? 'إدارة الموردين والعقود والامتثال الضريبي' : 'Manage vendors, contracts & ZATCA tax profiles',
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Language Toggle Button
          IconButton(
            icon: Icon(isArabic ? Icons.language : Icons.g_translate, color: const Color(0xFF4361EE)),
            tooltip: isArabic ? 'Switch to English' : 'التحويل للعربية',
            onPressed: () {
              ref.read(localeProvider.notifier).state =
                  isArabic ? const Locale('en') : const Locale('ar');
            },
          ),

          // Help & Guide Button
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: Color(0xFF4361EE)),
            tooltip: isArabic ? 'الدليل والتوجيهات' : 'Help & Guide',
            onPressed: () => _showHelpGuideDialog(context, isArabic),
          ),

          // Import CSV Button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF4361EE)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => _showCsvImportDialog(context, isArabic),
            icon: const Icon(Icons.file_upload_outlined, size: 18, color: Color(0xFF4361EE)),
            label: Text(isArabic ? 'استيراد CSV' : 'Import CSV', style: const TextStyle(color: Color(0xFF4361EE))),
          ),
          const SizedBox(width: 8),

          // Supplier Returns & Debit Notes Button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE11D48)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => context.pushNamed(RouteNames.supplierReturns),
            icon: const Icon(Icons.assignment_return_outlined, size: 18, color: Color(0xFFE11D48)),
            label: Text(isArabic ? 'المرتجعات والإشعار المدين' : 'Supplier Returns', style: const TextStyle(color: Color(0xFFE11D48))),
          ),
          const SizedBox(width: 8),

          // Add Supplier Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4361EE),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => context.goNamed('createSupplier'),
            icon: const Icon(Icons.add_rounded, size: 20, color: Colors.white),
            label: Text(isArabic ? 'إضافة مورد' : 'Add Supplier', style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: suppliersAsync.when(
        data: (suppliers) {
          final filteredSuppliers = _applyFilters(suppliers);

          return Column(
            children: [
              // Search & Filter Toolbar
              _buildFilterToolbar(context, isArabic, suppliers.length, filteredSuppliers.length),

              // Main Directory Content View (Card / Grid / List)
              Expanded(
                child: filteredSuppliers.isEmpty
                    ? _buildEmptyState(isArabic)
                    : _buildDirectoryView(filteredSuppliers, isArabic),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(isArabic ? 'حدث خطأ في تحميل الموردين: $err' : 'Error loading suppliers: $err'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(suppliersProvider),
                child: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterToolbar(BuildContext context, bool isArabic, int totalCount, int filteredCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          // Search Box
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: isArabic ? 'البحث عن مورد، هاتف، رقم ضريبي...' : 'Search supplier name, phone, VAT, CR...',
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF64748B)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Filter Tag ChoiceChips
          Wrap(
            spacing: 6,
            children: [
              _buildFilterChip('ALL', isArabic ? 'الكل ($totalCount)' : 'All ($totalCount)'),
              _buildFilterChip('VAT_ONLY', isArabic ? 'مسجل بالضريبة' : 'VAT Registered'),
              _buildFilterChip('TIER_1', isArabic ? 'فئة أ (Tier 1 ⭐)' : 'Tier 1 Preferred ⭐'),
              _buildFilterChip('RAW_MAT', isArabic ? 'مواد خام' : 'Raw Materials'),
              _buildFilterChip('WITH_EMAIL', isArabic ? 'يوجد بريد' : 'With Email'),
            ],
          ),
          const SizedBox(width: 12),

          // Sort Dropdown
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _sortBy,
                style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                items: [
                  DropdownMenuItem(value: 'NAME_ASC', child: Text(isArabic ? 'الاسم (أ - ي)' : 'Name (A - Z)')),
                  DropdownMenuItem(value: 'NAME_DESC', child: Text(isArabic ? 'الاسم (ي - أ)' : 'Name (Z - A)')),
                  DropdownMenuItem(value: 'NEWEST', child: Text(isArabic ? 'الأحدث أولاً' : 'Newest First')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _sortBy = val);
                },
              ),
            ),
          ),
          const SizedBox(width: 12),

          // View Mode Toggle Segment
          Container(
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _buildViewModeIconButton(SupplierViewMode.card, Icons.grid_view_rounded, isArabic ? 'عرض كروت' : 'Card View'),
                _buildViewModeIconButton(SupplierViewMode.grid, Icons.table_chart_rounded, isArabic ? 'عرض شبكي' : 'Grid View'),
                _buildViewModeIconButton(SupplierViewMode.list, Icons.view_list_rounded, isArabic ? 'عرض قائمة' : 'List View'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String tag, String label) {
    final isSelected = _filterTag == tag;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : const Color(0xFF475569))),
      selected: isSelected,
      selectedColor: const Color(0xFF4361EE),
      backgroundColor: const Color(0xFFF1F5F9),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      onSelected: (selected) {
        if (selected) setState(() => _filterTag = tag);
      },
    );
  }

  Widget _buildViewModeIconButton(SupplierViewMode mode, IconData icon, String tooltip) {
    final isSelected = _viewMode == mode;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => setState(() => _viewMode = mode),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : null,
          ),
          child: Icon(icon, size: 18, color: isSelected ? const Color(0xFF4361EE) : const Color(0xFF64748B)),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isArabic) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            isArabic ? 'لم يتم العثور على موردين مطبقين للمعايير' : 'No matching suppliers found',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 6),
          Text(
            isArabic ? 'جرب تغيير نص البحث أو إضافة موردين جديد عبر CSV' : 'Try updating your search query or importing suppliers via CSV.',
            style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectoryView(List<SupplierModel> suppliers, bool isArabic) {
    switch (_viewMode) {
      case SupplierViewMode.card:
        return _buildCardView(suppliers, isArabic);
      case SupplierViewMode.grid:
        return _buildGridView(suppliers, isArabic);
      case SupplierViewMode.list:
        return _buildListView(suppliers, isArabic);
    }
  }

  // ─── 1. Card View Layout ───────────────────────────────────────────────────
  Widget _buildCardView(List<SupplierModel> suppliers, bool isArabic) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 380,
        mainAxisExtent: 220,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: suppliers.length,
      itemBuilder: (context, index) {
        final supplier = suppliers[index];
        final hasVat = supplier.vatNumber != null && supplier.vatNumber!.isNotEmpty;

        return InkWell(
          onTap: () => context.pushNamed(RouteNames.supplierDetail, pathParameters: {'id': supplier.id}, extra: supplier),
          borderRadius: BorderRadius.circular(12),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Avatar, Name & VAT Badge
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFF4361EE).withValues(alpha: 0.1),
                      child: Text(
                        supplier.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF4361EE)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            supplier.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: hasVat ? const Color(0xFF10B981).withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  hasVat ? (isArabic ? 'مسجل زكاة/ضريبة' : 'VAT Registered') : (isArabic ? 'غير مسجل' : 'No VAT'),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: hasVat ? const Color(0xFF10B981) : Colors.orange.shade800,
                                  ),
                                ),
                              ),
                              if (supplier.crNumber != null && supplier.crNumber!.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Text('CR: ${supplier.crNumber}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Details: Phone, Email, Address
                if (supplier.vatNumber != null && supplier.vatNumber!.isNotEmpty)
                  _buildDetailRow(Icons.receipt_long_rounded, 'VAT: ${supplier.vatNumber}'),
                if (supplier.phoneNumber != null && supplier.phoneNumber!.isNotEmpty)
                  _buildDetailRow(Icons.phone_rounded, supplier.phoneNumber!),
                if (supplier.email != null && supplier.email!.isNotEmpty)
                  _buildDetailRow(Icons.email_rounded, supplier.email!),
                if (supplier.address != null && supplier.address!.isNotEmpty)
                  _buildDetailRow(Icons.location_on_rounded, supplier.address!),

                const Spacer(),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 8),

                // Quick Action Bar
                Row(
                  children: [
                    if (supplier.phoneNumber != null && supplier.phoneNumber!.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.phone_outlined, size: 18, color: Color(0xFF4361EE)),
                        onPressed: () => _makePhoneCall(supplier.phoneNumber!),
                        tooltip: isArabic ? 'اتصال بالهاتف' : 'Call Phone',
                      ),
                    if (supplier.email != null && supplier.email!.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.email_outlined, size: 18, color: Color(0xFF3B82F6)),
                        onPressed: () => _sendEmail(supplier.email!),
                        tooltip: isArabic ? 'إرسال بريد' : 'Send Email',
                      ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => context.pushNamed(RouteNames.editSupplier, extra: supplier),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: Text(isArabic ? 'تعديل' : 'Edit'),
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
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 2. Grid View Layout ───────────────────────────────────────────────────
  Widget _buildGridView(List<SupplierModel> suppliers, bool isArabic) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        child: SingleChildScrollView(
          child: DataTable(
            columnSpacing: 24,
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
            columns: [
              DataColumn(label: Text(isArabic ? 'اسم المورد' : 'Supplier Name', style: const TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text(isArabic ? 'الرقم الضريبي (VAT)' : 'VAT Number', style: const TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text(isArabic ? 'السجل التجاري (CR)' : 'CR Number', style: const TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text(isArabic ? 'رقم الهاتف' : 'Phone Number', style: const TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text(isArabic ? 'البريد الإلكتروني' : 'Email Address', style: const TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text(isArabic ? 'تفاصيل الحساب البنكي' : 'Bank Details', style: const TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text(isArabic ? 'إجراءات' : 'Actions', style: const TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: suppliers.map((s) {
              return DataRow(cells: [
                DataCell(Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                DataCell(Text(s.vatNumber ?? '-', style: const TextStyle(fontSize: 12.5))),
                DataCell(Text(s.crNumber ?? '-', style: const TextStyle(fontSize: 12.5))),
                DataCell(Text(s.phoneNumber ?? '-', style: const TextStyle(fontSize: 12.5))),
                DataCell(Text(s.email ?? '-', style: const TextStyle(fontSize: 12.5))),
                DataCell(Text(s.bankDetails ?? '-', style: const TextStyle(fontSize: 12))),
                DataCell(Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.analytics_outlined, size: 18, color: Color(0xFF10B981)),
                      onPressed: () => context.pushNamed(RouteNames.supplierDetail, pathParameters: {'id': s.id}, extra: s),
                      tooltip: 'AP Aging Analysis',
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF4361EE)),
                      onPressed: () => context.pushNamed(RouteNames.editSupplier, extra: s),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                      onPressed: () {},
                    ),
                  ],
                )),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  // ─── 3. List View Layout ───────────────────────────────────────────────────
  Widget _buildListView(List<SupplierModel> suppliers, bool isArabic) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: suppliers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final supplier = suppliers[index];
        final hasVat = supplier.vatNumber != null && supplier.vatNumber!.isNotEmpty;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          child: ListTile(
            onTap: () => context.pushNamed(RouteNames.supplierDetail, pathParameters: {'id': supplier.id}, extra: supplier),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF4361EE).withValues(alpha: 0.1),
              child: Text(supplier.name.substring(0, 1).toUpperCase(), style: const TextStyle(color: Color(0xFF4361EE), fontWeight: FontWeight.bold)),
            ),
            title: Row(
              children: [
                Text(supplier.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(width: 10),
                if (hasVat)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text(supplier.vatNumber!, style: const TextStyle(fontSize: 10, color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            subtitle: Text(
              '${supplier.phoneNumber ?? ''} ${supplier.email != null ? '• ${supplier.email}' : ''} ${supplier.address != null ? '• ${supplier.address}' : ''}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (supplier.phoneNumber != null)
                  IconButton(icon: const Icon(Icons.phone_outlined, size: 18), onPressed: () => _makePhoneCall(supplier.phoneNumber!)),
                IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () => context.pushNamed(RouteNames.editSupplier, extra: supplier)),
              ],
            ),
          ),
        );
      },
    );
  }
}
