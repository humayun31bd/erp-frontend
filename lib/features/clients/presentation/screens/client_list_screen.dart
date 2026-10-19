import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/client_provider.dart';
import '../../providers/customer_grid_provider.dart';
import '../../domain/customer_enums.dart';
import '../widgets/customer_help_modal.dart';
import '../../../../app.dart';

class CustomerGridScreen extends ConsumerStatefulWidget {
  const CustomerGridScreen({super.key});

  @override
  ConsumerState<CustomerGridScreen> createState() => _CustomerGridScreenState();
}

class _CustomerGridScreenState extends ConsumerState<CustomerGridScreen> {
  final _searchCtrl = TextEditingController();
  static const int _pageSize = 15;
  int _currentPage = 0;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ─── Delete confirm dialog ───
  Future<void> _confirmDelete(BuildContext context, CustomerRow row) async {
    final isArabic = ref.read(localeProvider).languageCode == 'ar';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isArabic ? 'حذف العميل' : 'Delete Customer'),
        content: Text(isArabic ? 'هل تريد حذف "${row.name}" نهائياً؟' : 'Remove "${row.name}" permanently?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(isArabic ? 'إغلاق' : 'Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isArabic ? 'حذف' : 'Delete', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      try {
        await ref.read(clientNotifierProvider.notifier).deleteClient(row.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isArabic ? 'تم حذف "${row.name}".' : '"${row.name}" deleted.')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isArabic ? 'فشل الحذف: $e' : 'Delete failed: $e')),
          );
        }
      }
    }
  }

  // ─── Inline edit dialog ───
  Future<void> _showEditDialog(BuildContext context, CustomerRow row) async {
    final isArabic = ref.read(localeProvider).languageCode == 'ar';
    final nameCtrl = TextEditingController(text: row.name);
    final emailCtrl = TextEditingController(text: row.email ?? '');
    final phoneCtrl = TextEditingController(text: row.phone ?? '');
    final countryCtrl = TextEditingController(text: row.country ?? '');
    final stateCtrl = TextEditingController(text: row.state ?? '');
    final cityCtrl = TextEditingController(text: row.city ?? '');
    final addressCtrl = TextEditingController(text: row.address ?? '');
    final fundsCtrl = TextEditingController(text: row.funds.toStringAsFixed(2));
    final duesCtrl = TextEditingController(text: row.dues.toStringAsFixed(2));
    final creditLimitCtrl = TextEditingController(text: row.creditLimit.toStringAsFixed(2));
    bool permitCredit = row.permitCredit;
    CustomerType selectedType = row.type;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).primaryColor.withValues(alpha: 0.08),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline, size: 22),
                      const SizedBox(width: 10),
                      Text(isArabic ? 'تعديل بيانات العميل' : 'Edit Customer',
                          style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          _row2([
                            _field(nameCtrl, isArabic ? 'الاسم *' : 'Name *',
                                validator: (v) => v == null || v.isEmpty ? (isArabic ? 'مطلوب' : 'Required') : null),
                            _field(emailCtrl, isArabic ? 'البريد الإلكتروني' : 'Email', type: TextInputType.emailAddress),
                          ]),
                          const SizedBox(height: 12),
                          _row2([
                            _field(phoneCtrl, isArabic ? 'رقم الهاتف' : 'Phone', type: TextInputType.phone),
                            _dropdownField<CustomerType>(
                              label: isArabic ? 'فئة العميل' : 'Customer Type',
                              value: selectedType,
                              items: CustomerType.values,
                              itemLabel: (t) => t.getLabel(isArabic),
                              onChanged: (t) => setS(() => selectedType = t!),
                            ),
                          ]),
                          const SizedBox(height: 12),
                          _row2([
                            _field(countryCtrl, isArabic ? 'الدولة' : 'Country'),
                            _field(stateCtrl, isArabic ? 'المنطقة / المحافظة' : 'State / Province'),
                          ]),
                          const SizedBox(height: 12),
                          _row2([
                            _field(cityCtrl, isArabic ? 'المدينة' : 'City'),
                            _field(addressCtrl, isArabic ? 'العنوان التفصيلي' : 'Address'),
                          ]),
                          const SizedBox(height: 12),
                          _row2([
                            _field(fundsCtrl, isArabic ? 'الرصيد الدائن (ر.س)' : 'Funds (Credit)', type: TextInputType.number),
                            _field(duesCtrl, isArabic ? 'الذمم المستحقة (ر.س)' : 'Dues (Payable)', type: TextInputType.number),
                          ]),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              children: [
                                SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                  title: Text(isArabic ? 'السماح بالبيع الآجل (على الحساب)' : 'Permit Credit (On Account)',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  subtitle: Text(
                                      isArabic ? 'السماح لهذا العميل بالشراء بالأجل حتى الحد الائتماني' : 'Allow this customer to purchase on credit',
                                      style: const TextStyle(fontSize: 11)),
                                  value: permitCredit,
                                  activeThumbColor: Colors.indigo,
                                  activeTrackColor: Colors.indigo.shade200,
                                  onChanged: (v) => setS(() => permitCredit = v),
                                ),
                                if (permitCredit) ...[
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: creditLimitCtrl,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: InputDecoration(
                                      labelText: isArabic ? 'سقف الحد الائتماني (ر.س)' : 'Credit Limit Amount (SAR)',
                                      border: const OutlineInputBorder(),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Actions
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(onPressed: () => Navigator.pop(ctx), child: Text(isArabic ? 'إغلاق' : 'Cancel')),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          try {
                            await ref.read(clientNotifierProvider.notifier).updateClient(row.id, {
                              'name': nameCtrl.text.trim(),
                              'email': emailCtrl.text.trim(),
                              'phoneNumber': phoneCtrl.text.trim(),
                              'country': countryCtrl.text.trim(),
                              'state': stateCtrl.text.trim(),
                              'city': cityCtrl.text.trim(),
                              'address': addressCtrl.text.trim(),
                              'customerType': selectedType.name,
                              'funds': double.tryParse(fundsCtrl.text) ?? 0,
                              'dues': double.tryParse(duesCtrl.text) ?? 0,
                              'permitCredit': permitCredit,
                              'creditLimit': double.tryParse(creditLimitCtrl.text) ?? 0,
                            });
                            if (ctx.mounted) Navigator.pop(ctx);
                          } catch (e) {
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(content: Text(isArabic ? 'فشل التحديث: $e' : 'Update failed: $e')),
                              );
                            }
                          }
                        },
                        child: Text(isArabic ? 'حفظ' : 'Save'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label,
      {TextInputType? type, String? Function(String?)? validator}) {
    return Expanded(
      child: TextFormField(
        controller: ctrl,
        keyboardType: type,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  Widget _dropdownField<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return Expanded(
      child: DropdownButtonFormField<T>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        items: items.map((i) => DropdownMenuItem(value: i, child: Text(itemLabel(i)))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _row2(List<Widget> children) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [children[0], const SizedBox(width: 12), children[1]],
      );

  // ─── CSV import ───
  Future<void> _importCsv(BuildContext context) async {
    final isArabic = ref.read(localeProvider).languageCode == 'ar';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.upload_file, color: Colors.indigo),
            const SizedBox(width: 10),
            Text(isArabic ? 'استيراد العملاء من ملف CSV' : 'Import Customers from CSV'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isArabic ? 'أعمدة ملف CSV المطلوبة:' : 'Expected CSV columns:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'name, email, phone, country, state, city, address, customer_type, funds, dues',
                style: TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),
            Text(isArabic ? 'اختر ملف .csv لاستيراد مجموعة عملاء دفعة واحدة.' : 'Select a .csv file to import customers in bulk.'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isArabic ? 'إغلاق' : 'Cancel')),
          ElevatedButton.icon(
            icon: const Icon(Icons.folder_open, size: 18),
            label: Text(isArabic ? 'اختر الملف' : 'Pick File'),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isArabic
                      ? 'ميزة اختيار الملف تتطلب حزمة file_picker.'
                      : 'File picker requires file_picker package. Add it to pubspec.yaml to enable.'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ─── Sort indicator ───
  Widget _sortIcon(String col, CustomerFilterState f) {
    if (f.sortColumn != col) return const Icon(Icons.unfold_more, size: 14, color: Colors.grey);
    return Icon(f.sortAsc ? Icons.arrow_upward : Icons.arrow_downward, size: 14, color: Colors.indigo);
  }

  Widget _colHeader(String label, String col, CustomerFilterState f, CustomerFilterNotifier notifier) {
    return InkWell(
      onTap: () => notifier.sort(col),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(width: 2),
          _sortIcon(col, f),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsProvider);
    final filter = ref.watch(customerFilterProvider);
    final filterNotifier = ref.read(customerFilterProvider.notifier);
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            const Icon(Icons.people_outline, color: Colors.indigo),
            const SizedBox(width: 10),
            Text(isArabic ? 'قائمة العملاء' : 'Customers',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isArabic ? Icons.language : Icons.g_translate),
            tooltip: isArabic ? 'Switch to English' : 'التحويل للعربية',
            onPressed: () {
              ref.read(localeProvider.notifier).state =
                  isArabic ? const Locale('en') : const Locale('ar');
            },
          ),
          const SizedBox(width: 8),
          // Help Guide Link
          OutlinedButton.icon(
            icon: const Icon(Icons.help_outline, size: 18),
            label: Text(isArabic ? 'الدليل والتعليمات' : 'Help & Guide'),
            onPressed: () => showDialog(
              context: context,
              builder: (ctx) => const CustomerHelpModal(),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.indigo,
              side: BorderSide(color: Colors.indigo.shade200),
            ),
          ),
          const SizedBox(width: 8),
          // Import CSV
          OutlinedButton.icon(
            icon: const Icon(Icons.upload_file, size: 18),
            label: Text(isArabic ? 'استيراد CSV' : 'Import CSV'),
            onPressed: () => _importCsv(context),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.indigo),
          ),
          const SizedBox(width: 8),
          // Add new
          ElevatedButton.icon(
            icon: const Icon(Icons.add, size: 18, color: Colors.white),
            label: Text(isArabic ? 'إضافة عميل' : 'Add Customer', style: const TextStyle(color: Colors.white)),
            onPressed: () => context.go('/customers/new'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: clientsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (clients) {
          // Build CustomerRow list from API models
          final rows = clients.map(CustomerRow.fromClient).toList();

          // Derive unique dropdown values from data
          final countries = rows.map((r) => r.country).whereType<String>().toSet().toList()..sort();
          final states = rows.map((r) => r.state).whereType<String>().toSet().toList()..sort();
          final cities = rows.map((r) => r.city).whereType<String>().toSet().toList()..sort();

          // ── Apply filters ──
          var filtered = rows.where((r) {
            final q = filter.search.toLowerCase();
            final matchSearch = q.isEmpty ||
                r.name.toLowerCase().contains(q) ||
                (r.email?.toLowerCase().contains(q) ?? false) ||
                (r.phone?.contains(q) ?? false) ||
                (r.city?.toLowerCase().contains(q) ?? false);
            final matchCountry = filter.country == null || r.country == filter.country;
            final matchState = filter.state == null || r.state == filter.state;
            final matchCity = filter.city == null || r.city == filter.city;
            final matchType = filter.type == null || r.type == filter.type;
            return matchSearch && matchCountry && matchState && matchCity && matchType;
          }).toList();

          // ── Apply sort ──
          filtered.sort((a, b) {
            int cmp;
            switch (filter.sortColumn) {
              case 'email':   cmp = (a.email ?? '').compareTo(b.email ?? ''); break;
              case 'phone':   cmp = (a.phone ?? '').compareTo(b.phone ?? ''); break;
              case 'country': cmp = (a.country ?? '').compareTo(b.country ?? ''); break;
              case 'city':    cmp = (a.city ?? '').compareTo(b.city ?? ''); break;
              case 'type':    cmp = a.type.label.compareTo(b.type.label); break;
              case 'funds':   cmp = a.funds.compareTo(b.funds); break;
              case 'dues':    cmp = a.dues.compareTo(b.dues); break;
              case 'creditLimit': cmp = a.creditLimit.compareTo(b.creditLimit); break;
              case 'date':    cmp = a.createdAt.compareTo(b.createdAt); break;
              default:        cmp = a.name.compareTo(b.name);
            }
            return filter.sortAsc ? cmp : -cmp;
          });

          // ── Pagination ──
          final totalPages = (filtered.length / _pageSize).ceil().clamp(1, 9999);
          final safePage = _currentPage.clamp(0, totalPages - 1);
          final start = safePage * _pageSize;
          final end = (start + _pageSize).clamp(0, filtered.length);
          final pageRows = filtered.sublist(start, end);

          return Column(
            children: [
              // ── Search + Filters bar ──
              Container(
                color: Colors.grey[50],
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Search
                    SizedBox(
                      width: 260,
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: isArabic ? 'البحث عن الاسم، البريد، الهاتف...' : 'Search name, email, phone...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          suffixIcon: filter.search.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    filterNotifier.setSearch('');
                                    setState(() => _currentPage = 0);
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                        ),
                        onChanged: (v) {
                          filterNotifier.setSearch(v);
                          setState(() => _currentPage = 0);
                        },
                      ),
                    ),
                    // Country filter
                    _filterDropdown<String?>(
                      label: isArabic ? 'الدولة' : 'Country',
                      value: filter.country,
                      items: [null, ...countries],
                      itemLabel: (v) => v ?? (isArabic ? 'جميع الدول' : 'All Countries'),
                      onChanged: (v) { filterNotifier.setCountry(v); setState(() => _currentPage = 0); },
                    ),
                    // State filter
                    _filterDropdown<String?>(
                      label: isArabic ? 'المنطقة' : 'State',
                      value: filter.state,
                      items: [null, ...states],
                      itemLabel: (v) => v ?? (isArabic ? 'جميع المناطق' : 'All States'),
                      onChanged: (v) { filterNotifier.setState2(v); setState(() => _currentPage = 0); },
                    ),
                    // City filter
                    _filterDropdown<String?>(
                      label: isArabic ? 'المدينة' : 'City',
                      value: filter.city,
                      items: [null, ...cities],
                      itemLabel: (v) => v ?? (isArabic ? 'جميع المدن' : 'All Cities'),
                      onChanged: (v) { filterNotifier.setCity(v); setState(() => _currentPage = 0); },
                    ),
                    // Customer Group/Type filter
                    _filterDropdown<CustomerType?>(
                      label: isArabic ? 'فئة العميل' : 'Group',
                      value: filter.type,
                      items: [null, ...CustomerType.values],
                      itemLabel: (v) => v?.getLabel(isArabic) ?? (isArabic ? 'جميع الفئات' : 'All Groups'),
                      onChanged: (v) { filterNotifier.setType(v); setState(() => _currentPage = 0); },
                    ),
                    // Clear all
                    if (filter.country != null || filter.state != null || filter.city != null || filter.type != null || filter.search.isNotEmpty)
                      TextButton.icon(
                        icon: const Icon(Icons.filter_alt_off, size: 16),
                        label: Text(isArabic ? 'مسح الفلاتر' : 'Clear Filters'),
                        onPressed: () {
                          _searchCtrl.clear();
                          filterNotifier.clearFilters();
                          setState(() => _currentPage = 0);
                        },
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // ── Stats row ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Row(
                  children: [
                    Text(isArabic ? '${filtered.length} عميل' : '${filtered.length} customer${filtered.length == 1 ? "" : "s"}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    const Spacer(),
                    Text(
                      isArabic
                          ? 'إجمالي الرصيد الدائن: ${filtered.fold<double>(0, (s, r) => s + r.funds).toStringAsFixed(2)} ر.س  •  إجمالي المستحقات (الذمم): ${filtered.fold<double>(0, (s, r) => s + r.dues).toStringAsFixed(2)} ر.س'
                          : 'Total Funds: SAR ${filtered.fold<double>(0, (s, r) => s + r.funds).toStringAsFixed(2)}  •  Total Dues: SAR ${filtered.fold<double>(0, (s, r) => s + r.dues).toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // ── Data Grid ──
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 12),
                            Text(isArabic ? 'لا يوجد عملاء' : 'No customers found', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            columnSpacing: 16,
                            horizontalMargin: 16,
                            headingRowHeight: 42,
                            dataRowMinHeight: 52,
                            dataRowMaxHeight: 60,
                            headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
                            showCheckboxColumn: false,
                            columns: [
                              DataColumn(label: _colHeader(isArabic ? 'الاسم' : 'Name', 'name', filter, filterNotifier)),
                              DataColumn(label: _colHeader(isArabic ? 'البريد الإلكتروني' : 'Email', 'email', filter, filterNotifier)),
                              DataColumn(label: _colHeader(isArabic ? 'الهاتف' : 'Phone', 'phone', filter, filterNotifier)),
                              DataColumn(label: _colHeader(isArabic ? 'الدولة' : 'Country', 'country', filter, filterNotifier)),
                              DataColumn(label: _colHeader(isArabic ? 'المنطقة' : 'State', 'state', filter, filterNotifier)),
                              DataColumn(label: _colHeader(isArabic ? 'المدينة' : 'City', 'city', filter, filterNotifier)),
                              DataColumn(label: _colHeader(isArabic ? 'الفئة' : 'Type', 'type', filter, filterNotifier)),
                              DataColumn(label: _colHeader(isArabic ? 'الرصيد (دائن)' : 'Funds', 'funds', filter, filterNotifier), numeric: true),
                              DataColumn(label: _colHeader(isArabic ? 'الذمم (مستحق)' : 'Dues', 'dues', filter, filterNotifier), numeric: true),
                              DataColumn(label: _colHeader(isArabic ? 'الدفع الآجل' : 'Credit Permit', 'permitCredit', filter, filterNotifier)),
                              DataColumn(label: _colHeader(isArabic ? 'حد الائتمان' : 'Credit Limit', 'creditLimit', filter, filterNotifier), numeric: true),
                              DataColumn(label: _colHeader(isArabic ? 'تاريخ التسجيل' : 'Joined', 'date', filter, filterNotifier)),
                              DataColumn(label: Text(isArabic ? 'إجراءات' : 'Actions', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                            ],
                            rows: pageRows.map((row) {
                              final typeChipColor = _typeColor(row.type);
                              return DataRow(
                                onSelectChanged: (_) => context.go('/customers/${row.id}'),
                                cells: [
                                  // Name
                                  DataCell(Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: Colors.indigo[50],
                                        child: Text(
                                          row.name.isNotEmpty ? row.name[0].toUpperCase() : '?',
                                          style: TextStyle(color: Colors.indigo[700], fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(row.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    ],
                                  )),
                                  DataCell(Text(row.email ?? '—', style: TextStyle(color: Colors.grey[700]))),
                                  DataCell(Text(row.phone ?? '—', style: TextStyle(color: Colors.grey[700]))),
                                  DataCell(Text(row.country ?? '—')),
                                  DataCell(Text(row.state ?? '—')),
                                  DataCell(Text(row.city ?? '—')),
                                  // Type chip
                                  DataCell(Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: typeChipColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: typeChipColor.withValues(alpha: 0.4)),
                                    ),
                                    child: Text(row.type.getLabel(isArabic),
                                        style: TextStyle(fontSize: 11, color: typeChipColor, fontWeight: FontWeight.bold)),
                                  )),
                                  // Funds
                                  DataCell(Text(
                                    row.funds > 0
                                        ? (isArabic ? '${row.funds.toStringAsFixed(2)} ر.س' : 'SAR ${row.funds.toStringAsFixed(2)}')
                                        : '—',
                                    style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.right,
                                  )),
                                  // Dues
                                  DataCell(Text(
                                    row.dues > 0
                                        ? (isArabic ? '${row.dues.toStringAsFixed(2)} ر.س' : 'SAR ${row.dues.toStringAsFixed(2)}')
                                        : '—',
                                    style: TextStyle(color: row.dues > 0 ? Colors.red[700] : Colors.grey, fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.right,
                                  )),
                                  // Credit Permit
                                  DataCell(Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: (row.permitCredit ? Colors.green : Colors.grey).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: (row.permitCredit ? Colors.green : Colors.grey).withValues(alpha: 0.4)),
                                    ),
                                    child: Text(
                                      row.permitCredit ? (isArabic ? 'مسموح' : 'Permitted') : (isArabic ? 'معطل' : 'Disabled'),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: row.permitCredit ? Colors.green[700] : Colors.grey[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )),
                                  // Credit Limit
                                  DataCell(Text(
                                    row.creditLimit > 0
                                        ? (isArabic ? '${row.creditLimit.toStringAsFixed(2)} ر.س' : 'SAR ${row.creditLimit.toStringAsFixed(2)}')
                                        : (isArabic ? '0.00 ر.س' : '0.00'),
                                    style: TextStyle(
                                      color: row.creditLimit > 0 ? Colors.indigo[700] : Colors.grey,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.right,
                                  )),
                                  // Date
                                  DataCell(Text(
                                    row.createdAt.toIso8601String().split('T')[0],
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  )),
                                  // Actions
                                  DataCell(Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, size: 18),
                                        color: Colors.indigo,
                                        tooltip: isArabic ? 'تعديل' : 'Edit',
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () => _showEditDialog(context, row),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 18),
                                        color: Colors.red,
                                        tooltip: isArabic ? 'حذف' : 'Delete',
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () => _confirmDelete(context, row),
                                      ),
                                    ],
                                  )),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
              ),

              // ── Pagination ──
              if (filtered.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.grey[200]!)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        isArabic
                            ? 'عرض ${filtered.isEmpty ? 0 : start + 1}–$end من أصل ${filtered.length}'
                            : 'Showing ${filtered.isEmpty ? 0 : start + 1}–$end of ${filtered.length}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.first_page),
                        onPressed: safePage > 0 ? () => setState(() => _currentPage = 0) : null,
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: safePage > 0 ? () => setState(() => _currentPage = safePage - 1) : null,
                        visualDensity: VisualDensity.compact,
                      ),
                      Text(isArabic ? 'صفحة ${safePage + 1} / $totalPages' : 'Page ${safePage + 1} / $totalPages',
                          style: const TextStyle(fontSize: 13)),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: safePage < totalPages - 1 ? () => setState(() => _currentPage = safePage + 1) : null,
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        icon: const Icon(Icons.last_page),
                        onPressed: safePage < totalPages - 1 ? () => setState(() => _currentPage = totalPages - 1) : null,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // Compact filter dropdown
  Widget _filterDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return SizedBox(
      width: 150,
      child: DropdownButtonFormField<T>(
        initialValue: value,
        isDense: true,
        decoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
        ),
        items: items.map((i) => DropdownMenuItem<T>(value: i, child: Text(itemLabel(i), overflow: TextOverflow.ellipsis))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Color _typeColor(CustomerType t) {
    switch (t) {
      case CustomerType.loyal:          return Colors.green;
      case CustomerType.repeat:         return Colors.blue;
      case CustomerType.newCustomer:    return Colors.indigo;
      case CustomerType.impulseBuyer:   return Colors.orange;
      case CustomerType.needBased:      return Colors.teal;
      case CustomerType.discountDriven: return Colors.purple;
      case CustomerType.lapsed:         return Colors.red;
    }
  }
}
