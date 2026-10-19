import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import '../../../../app.dart';
import '../../providers/unit_provider.dart';

class UnitsScreen extends ConsumerStatefulWidget {
  const UnitsScreen({super.key});

  @override
  ConsumerState<UnitsScreen> createState() => _UnitsScreenState();
}

class _UnitsScreenState extends ConsumerState<UnitsScreen> {
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _importCsv() async {
    final isArabic = ref.read(localeProvider).languageCode == 'ar';
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final csvString = utf8.decode(bytes);
        final fields = Csv().decode(csvString);
        
        if (fields.isEmpty || fields.length == 1) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isArabic ? 'ملف CSV فارغ أو غير صالحة.' : 'CSV file is empty or invalid.')));
          return;
        }
        
        final dataRows = fields.skip(1);
        final notifier = ref.read(unitProvider.notifier);
        
        int successCount = 0;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isArabic ? 'جاري استيراد الوحدات... يرجى الانتظار.' : 'Importing units... Please wait.')));
        }

        for (var row in dataRows) {
          if (row.length >= 2) { // Need name and shortName
             final name = row[0].toString().trim();
             final shortName = row[1].toString().trim();
             final isBaseUnit = row.length > 2 ? row[2].toString().toLowerCase() == 'true' : true;
             
             if (name.isNotEmpty && shortName.isNotEmpty) {
               try {
                 final success = await notifier.createUnit(name, shortName, isBaseUnit);
                 if (success) successCount++;
               } catch(e) {
                 print('Error importing row: $e');
               }
             }
          }
        }
        
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isArabic ? 'تم استيراد $successCount وحدة بنجاح!' : 'Successfully imported $successCount units!')));
        }
      }
    } catch(e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${isArabic ? "خطأ في قراءة ملف CSV: " : "Error parsing CSV: "}$e')));
      }
    }
  }

  void _showUnitDialog(BuildContext context, WidgetRef ref, {UnitModel? unit}) {
    final isEditing = unit != null;
    final isArabic = ref.read(localeProvider).languageCode == 'ar';
    
    // For single edit
    final nameController = TextEditingController(text: unit?.name);
    final shortNameController = TextEditingController(text: unit?.shortName);
    bool isBaseUnit = unit?.baseUnit ?? true;

    // For multiple additions
    List<Map<String, dynamic>> entries = [
      {'name': TextEditingController(), 'short': TextEditingController(), 'base': true}
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(isEditing ? (isArabic ? 'تعديل الوحدة' : 'Edit Unit') : (isArabic ? 'إضافة وحدات' : 'Add Units'), style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: 600,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isEditing) ...[
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: isArabic ? 'الاسم (مثال: كيلوجرام)' : 'Name (e.g. Kilogram)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.square_foot),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: shortNameController,
                          decoration: InputDecoration(
                            labelText: isArabic ? 'الاسم القصير (مثال: كجم)' : 'Short Name (e.g. kg)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.short_text),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CheckboxListTile(
                            title: Text(isArabic ? 'وحدة أساسية' : 'Is Base Unit', style: const TextStyle(fontWeight: FontWeight.w500)),
                            value: isBaseUnit,
                            onChanged: (val) => setState(() => isBaseUnit = val ?? true),
                            controlAffinity: ListTileControlAffinity.leading,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ] else ...[
                        ...entries.asMap().entries.map((e) {
                          int idx = e.key;
                          var row = e.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                    controller: row['name'],
                                    decoration: InputDecoration(
                                      labelText: isArabic ? 'الاسم' : 'Name',
                                      isDense: true,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: row['short'],
                                    decoration: InputDecoration(
                                      labelText: isArabic ? 'الرمز' : 'Short',
                                      isDense: true,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(isArabic ? 'أساسية؟' : 'Base?', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    Checkbox(
                                      value: row['base'],
                                      onChanged: (val) => setState(() => row['base'] = val ?? true),
                                    ),
                                  ],
                                ),
                                if (entries.length > 1)
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                    onPressed: () => setState(() => entries.removeAt(idx)),
                                  )
                                else
                                  const SizedBox(width: 40),
                              ],
                            ),
                          );
                        }),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                entries.add({'name': TextEditingController(), 'short': TextEditingController(), 'base': true});
                              });
                            },
                            icon: const Icon(Icons.add),
                            label: Text(isArabic ? 'إضافة وحدة أخرى' : 'Add Another Unit'),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(isArabic ? 'إلغاء' : 'Cancel', style: const TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    bool allSuccess = true;
                    if (isEditing) {
                      final name = nameController.text.trim();
                      final short = shortNameController.text.trim();
                      if (name.isEmpty || short.isEmpty) return;
                      allSuccess = await ref.read(unitProvider.notifier).updateUnit(unit.id, name, short, isBaseUnit);
                    } else {
                      for (var row in entries) {
                        final name = row['name'].text.trim();
                        final short = row['short'].text.trim();
                        final base = row['base'];
                        if (name.isNotEmpty && short.isNotEmpty) {
                          final s = await ref.read(unitProvider.notifier).createUnit(name, short, base);
                          if (!s) allSuccess = false;
                        }
                      }
                    }

                    if (allSuccess && context.mounted) {
                      Navigator.pop(context);
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isArabic ? 'فشل حفظ بعض/كل الوحدات.' : 'Failed to save some/all units. Check if they already exist.')));
                    }
                  },
                  child: Text(isArabic ? 'حفظ' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, UnitModel unit) {
    final isArabic = ref.read(localeProvider).languageCode == 'ar';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(isArabic ? 'حذف الوحدة' : 'Delete Unit', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(isArabic ? 'هل أنت تأكد من رغبتك في حذف "${unit.name}"؟ لا يمكن التراجع عن هذا الإجراء.' : 'Are you sure you want to delete "${unit.name}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isArabic ? 'إلغاء' : 'Cancel', style: const TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () async {
                final success = await ref.read(unitProvider.notifier).deleteUnit(unit.id);
                if (success && context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: Text(isArabic ? 'حذف' : 'Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final unitState = ref.watch(unitProvider);
    final theme = Theme.of(context);
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(isArabic ? 'وحدات القياس' : 'Units', style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              final current = ref.read(localeProvider);
              ref.read(localeProvider.notifier).state =
                  current.languageCode == 'en' ? const Locale('ar') : const Locale('en');
            },
            tooltip: isArabic ? 'تغيير اللغة' : 'Switch Language',
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: isArabic ? 'تنزيل النموذج' : 'Download Template',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isArabic ? 'صيغة CSV: الاسم، الاسم القصير، وحدة أساسية (true/false)' : 'CSV Format: Name, Short Name, Base Unit (true/false)')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined),
            tooltip: isArabic ? 'استيراد من CSV' : 'Import from CSV',
            onPressed: _importCsv,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(unitProvider.notifier).fetchUnits(),
            tooltip: isArabic ? 'تحديث' : 'Refresh',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
                decoration: InputDecoration(
                  hintText: isArabic ? 'بحث عن وحدة...' : 'Search units...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),
          ),
          
          // Grid View
          Expanded(
            child: unitState.when(
              data: (units) {
                final filteredUnits = units.where((u) {
                  return u.name.toLowerCase().contains(searchQuery) ||
                         u.shortName.toLowerCase().contains(searchQuery);
                }).toList();

                if (filteredUnits.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.square_foot_outlined, size: 80, color: Colors.grey.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isEmpty ? (isArabic ? 'لم يتم العثور على وحدات.' : 'No units found.') : (isArabic ? 'لا توجد نتائج لـ "$searchQuery"' : 'No results for "$searchQuery"'),
                          style: const TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 2;
                    if (constraints.maxWidth > 1200) crossAxisCount = 5;
                    else if (constraints.maxWidth > 900) crossAxisCount = 4;
                    else if (constraints.maxWidth > 600) crossAxisCount = 3;

                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 1.0, 
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filteredUnits.length,
                      itemBuilder: (context, index) {
                        final unit = filteredUnits[index];

                        return Container(
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.teal.withValues(alpha: 0.1),
                                        Colors.teal.withValues(alpha: 0.2),
                                      ]
                                    ),
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.square_foot_rounded,
                                      size: 48,
                                      color: Colors.teal,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        unit.name,
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, height: 1.2),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        unit.shortName,
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.bold),
                                      ),
                                      const Spacer(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: unit.baseUnit ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              unit.baseUnit ? (isArabic ? 'وحدة أساسية' : 'Base Unit') : (isArabic ? 'وحدة مشتقة' : 'Derived Unit'),
                                              style: TextStyle(
                                                color: unit.baseUnit ? Colors.green : Colors.orange,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                icon: Icon(Icons.edit_rounded, color: Colors.blue.shade400, size: 20),
                                                onPressed: () => _showUnitDialog(context, ref, unit: unit),
                                              ),
                                              const SizedBox(width: 12),
                                              IconButton(
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                icon: Icon(Icons.delete_rounded, color: Colors.red.shade400, size: 20),
                                                onPressed: () => _confirmDelete(context, ref, unit),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Center(child: Text('${isArabic ? "خطأ: " : "Error: "}$err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUnitDialog(context, ref),
        icon: const Icon(Icons.add),
        label: Text(isArabic ? 'إضافة وحدة' : 'Add Unit', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
