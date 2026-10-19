import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app.dart';
import '../../providers/sub_category_provider.dart';
import '../../providers/category_provider.dart';

class SubCategoriesScreen extends ConsumerWidget {
  const SubCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subCategoryState = ref.watch(subCategoryProvider);
    final categoryState = ref.watch(categoryProvider);
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'الفئات الفرعية' : 'Sub-Categories', style: const TextStyle(fontWeight: FontWeight.bold)),
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
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(subCategoryProvider.notifier).fetchSubCategories();
              ref.read(categoryProvider.notifier).fetchCategories();
            },
            tooltip: isArabic ? 'تحديث' : 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: subCategoryState.when(
        data: (subCategories) {
          if (subCategories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_tree_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(isArabic ? 'لم يتم العثور على فئات فرعية.' : 'No sub-categories found.', style: const TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: subCategories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final subCategory = subCategories[index];
              final unknownLabel = isArabic ? 'غير معروف' : 'Unknown';
              final parentCategoryName = categoryState.value?.firstWhere((c) => c.id == subCategory.categoryId, orElse: () => Category(id: '', name: unknownLabel)).name ?? unknownLabel;

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(subCategory.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${isArabic ? "الفئة الرئيسية: " : "Parent: "}$parentCategoryName\n${subCategory.description ?? ""}'),
                  isThreeLine: subCategory.description != null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showSubCategoryDialog(context, ref, subCategory: subCategory),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, ref, subCategory),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('${isArabic ? "خطأ: " : "Error: "}$err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSubCategoryDialog(context, ref),
        icon: const Icon(Icons.add),
        label: Text(isArabic ? 'إضافة فئة فرعية' : 'Add Sub-Category'),
      ),
    );
  }

  void _showSubCategoryDialog(BuildContext context, WidgetRef ref, {SubCategory? subCategory}) {
    final nameController = TextEditingController(text: subCategory?.name);
    final descController = TextEditingController(text: subCategory?.description);
    String? selectedCategoryId = subCategory?.categoryId;
    final isEditing = subCategory != null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final categoryState = ref.read(categoryProvider);
            final isArabic = ref.read(localeProvider).languageCode == 'ar';

            return AlertDialog(
              title: Text(isEditing ? (isArabic ? 'تعديل فئة فرعية' : 'Edit Sub-Category') : (isArabic ? 'إضافة فئة فرعية' : 'Add Sub-Category')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  categoryState.when(
                    data: (categories) {
                      return DropdownButtonFormField<String>(
                        initialValue: selectedCategoryId,
                        decoration: InputDecoration(labelText: isArabic ? 'الفئة الرئيسية' : 'Parent Category', border: const OutlineInputBorder()),
                        items: categories.map((cat) => DropdownMenuItem(value: cat.id, child: Text(cat.name))).toList(),
                        onChanged: (val) {
                          setState(() => selectedCategoryId = val);
                        },
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (e, st) => Text(isArabic ? 'فشل تحميل الفئات' : 'Failed to load categories'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: isArabic ? 'الاسم' : 'Name', border: const OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    decoration: InputDecoration(labelText: isArabic ? 'الوصف (اختياري)' : 'Description (Optional)', border: const OutlineInputBorder()),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(isArabic ? 'إلغاء' : 'Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final desc = descController.text.trim();
                    if (name.isEmpty || selectedCategoryId == null) return;

                    bool success;
                    if (isEditing) {
                      success = await ref.read(subCategoryProvider.notifier).updateSubCategory(subCategory.id, name, selectedCategoryId!, desc.isEmpty ? null : desc);
                    } else {
                      success = await ref.read(subCategoryProvider.notifier).createSubCategory(name, selectedCategoryId!, desc.isEmpty ? null : desc);
                    }

                    if (success && context.mounted) {
                      Navigator.pop(context);
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isArabic ? 'فشل حفظ الفئة الفرعية' : 'Failed to save sub-category')));
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

  void _confirmDelete(BuildContext context, WidgetRef ref, SubCategory subCategory) {
    final isArabic = ref.read(localeProvider).languageCode == 'ar';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isArabic ? 'حذف فئة فرعية' : 'Delete Sub-Category'),
          content: Text(isArabic ? 'هل أنت تأكد من رغبتك في حذف "${subCategory.name}"؟' : 'Are you sure you want to delete "${subCategory.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isArabic ? 'إلغاء' : 'Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () async {
                final success = await ref.read(subCategoryProvider.notifier).deleteSubCategory(subCategory.id);
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
}
