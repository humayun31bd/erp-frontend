import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app.dart';
import '../../providers/variable_provider.dart';

class VariableProductsScreen extends ConsumerWidget {
  const VariableProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final variableState = ref.watch(variableProvider);
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'إعدادات المتغيرات' : 'Variable Settings', style: const TextStyle(fontWeight: FontWeight.bold)),
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
            onPressed: () => ref.read(variableProvider.notifier).fetchVariables(),
            tooltip: isArabic ? 'تحديث' : 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: variableState.when(
        data: (variables) {
          if (variables.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.style_outlined, size: 72, color: Colors.blue[300]),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isArabic ? 'لا توجد متغيرات منتجات' : 'No Product Variables',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isArabic ? 'قم بإنشاء متناوعات مثل الحجم أو اللون لتخصيص مخزونك.' : 'Create variants like Size or Color to customize your inventory.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => _showVariableDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: Text(isArabic ? 'إضافة أول متغير' : 'Add First Variable'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: variables.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final variable = variables[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(variable.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${isArabic ? "القيم: " : "Values: "}${variable.values.map((v) => v.value).join(", ")}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showVariableDialog(context, ref, variable: variable),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, ref, variable),
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
        onPressed: () => _showVariableDialog(context, ref),
        icon: const Icon(Icons.add),
        label: Text(isArabic ? 'إضافة متغير' : 'Add Variable'),
      ),
    );
  }

  void _showVariableDialog(BuildContext context, WidgetRef ref, {VariableTemplate? variable}) {
    final nameController = TextEditingController(text: variable?.name);
    final valuesController = TextEditingController(text: variable?.values.map((v) => v.value).join(', '));
    final isEditing = variable != null;

    showDialog(
      context: context,
      builder: (context) {
        final isArabic = ref.read(localeProvider).languageCode == 'ar';

        return AlertDialog(
          title: Text(isEditing ? (isArabic ? 'تعديل المتغير' : 'Edit Variable') : (isArabic ? 'إضافة متغير' : 'Add Variable')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: isArabic ? 'الاسم (مثال: الحجم)' : 'Name (e.g., Size)',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: valuesController,
                decoration: InputDecoration(
                  labelText: isArabic ? 'القيم (مفصولة بفاصلة)' : 'Values (comma separated)',
                  hintText: isArabic ? 'صغير، متوسط، كبير' : 'Small, Medium, Large',
                  border: const OutlineInputBorder(),
                ),
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
                final valuesStr = valuesController.text.trim();
                
                if (name.isEmpty || valuesStr.isEmpty) return;

                final valuesList = valuesStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

                if (valuesList.isEmpty) return;

                bool success;
                if (isEditing) {
                  success = await ref.read(variableProvider.notifier).updateVariable(variable.id, name, valuesList);
                } else {
                  success = await ref.read(variableProvider.notifier).createVariable(name, valuesList);
                }

                if (success && context.mounted) {
                  Navigator.pop(context);
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isArabic ? 'فشل حفظ المتغير' : 'Failed to save variable')));
                }
              },
              child: Text(isArabic ? 'حفظ' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, VariableTemplate variable) {
    final isArabic = ref.read(localeProvider).languageCode == 'ar';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isArabic ? 'حذف المتغير' : 'Delete Variable'),
          content: Text(isArabic ? 'هل أنت تأكد من رغبتك في حذف "${variable.name}"؟' : 'Are you sure you want to delete "${variable.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isArabic ? 'إلغاء' : 'Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () async {
                final success = await ref.read(variableProvider.notifier).deleteVariable(variable.id);
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
