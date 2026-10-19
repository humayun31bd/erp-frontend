import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:erp_frontend/app.dart';
import 'package:erp_frontend/core/routing/route_names.dart';
import 'package:erp_frontend/features/accounting/providers/accounting_providers.dart';

class JournalEntriesScreen extends ConsumerWidget {
  const JournalEntriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalEntriesAsync = ref.watch(journalEntriesProvider);
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'قيود اليومية والموافقات' : 'Journal Entries & Approvals'),
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
          const SizedBox(width: 8),
        ],
      ),
      body: journalEntriesAsync.when(
        data: (entries) {
          if (entries.isEmpty) {
            return Center(
              child: Text(
                isArabic ? 'لم يتم العثور على قيود يومية' : 'No Journal Entries Found',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final statusText = entry.status == 'POSTED'
                  ? (isArabic ? 'مرحل' : 'POSTED')
                  : (isArabic ? 'مسودة' : 'DRAFT');

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(entry.entryNumber),
                  subtitle: Text('${entry.entryDate}\n${entry.description ?? ""}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Chip(
                        label: Text(statusText),
                        backgroundColor: entry.status == 'POSTED' ? Colors.green.shade100 : Colors.orange.shade100,
                      ),
                      if (entry.status == 'DRAFT')
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          tooltip: isArabic ? 'اعتماد وترحيل' : 'Approve & Post',
                          onPressed: () async {
                            final api = ref.read(accountingApiProvider);
                            try {
                              await api.updateJournalEntryStatus(entry.id, {'status': 'POSTED'});
                              ref.invalidate(journalEntriesProvider);
                              ref.invalidate(ledgerProvider);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(isArabic ? 'تم اعتماد وترحيل السند بنجاح!' : 'Voucher Approved & Posted!'),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${isArabic ? "خطأ: " : "Error: "}$e'),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('${isArabic ? "خطأ: " : "Error: "}$err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed(RouteNames.accountingCreateJournal);
        },
        tooltip: isArabic ? 'إنشاء قيد يومية' : 'Create Journal Entry',
        child: const Icon(Icons.add),
      ),
    );
  }
}

