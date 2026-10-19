import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/routing/route_names.dart';
import '../../providers/invoice_provider.dart';
import '../widgets/invoice_card.dart';
import '../widgets/invoice_grid_card.dart';
import '../../../../app.dart';

enum InvoiceViewMode { card, grid }

final _searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');
final _statusFilterProvider = StateProvider.autoDispose<String?>((ref) => null);
final _viewModeProvider = StateProvider.autoDispose<InvoiceViewMode>((ref) => InvoiceViewMode.card);

class InvoiceListScreen extends ConsumerWidget {
  const InvoiceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final invoiceListState = ref.watch(invoiceListProvider);
    final searchQuery = ref.watch(_searchQueryProvider);
    final statusFilter = ref.watch(_statusFilterProvider);
    final viewMode = ref.watch(_viewModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'فواتير المبيعات الضريبية' : l10n.invoices),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(124),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: isArabic ? 'البحث برقم الفاتورة أو اسم العميل...' : 'Search by invoice number or client...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) => ref.read(_searchQueryProvider.notifier).state = value,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            FilterChip(
                              label: Text(isArabic ? 'الكل' : 'All'),
                              selected: statusFilter == null,
                              onSelected: (selected) {
                                if (selected) ref.read(_statusFilterProvider.notifier).state = null;
                              },
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              label: Text(isArabic ? 'معتمدة ZATCA' : 'Cleared'),
                              selected: statusFilter == 'CLEARED',
                              onSelected: (selected) {
                                ref.read(_statusFilterProvider.notifier).state = selected ? 'CLEARED' : null;
                              },
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              label: Text(isArabic ? 'قيد الانتظار' : 'Pending'),
                              selected: statusFilter == 'PENDING',
                              onSelected: (selected) {
                                ref.read(_statusFilterProvider.notifier).state = selected ? 'PENDING' : null;
                              },
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              label: Text(isArabic ? 'مبلغ عنها' : 'Reported'),
                              selected: statusFilter == 'REPORTED',
                              onSelected: (selected) {
                                ref.read(_statusFilterProvider.notifier).state = selected ? 'REPORTED' : null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // View Switcher (Card View vs Grid View)
                    SegmentedButton<InvoiceViewMode>(
                      segments: [
                        ButtonSegment(
                          value: InvoiceViewMode.card,
                          icon: const Icon(Icons.view_agenda_outlined, size: 18),
                          tooltip: isArabic ? 'عرض قائمة البطاقات' : 'Card View (List)',
                        ),
                        ButtonSegment(
                          value: InvoiceViewMode.grid,
                          icon: const Icon(Icons.grid_view, size: 18),
                          tooltip: isArabic ? 'عرض شبكة المربعات' : 'Grid View',
                        ),
                      ],
                      selected: {viewMode},
                      onSelectionChanged: (selected) {
                        ref.read(_viewModeProvider.notifier).state = selected.first;
                      },
                      style: const ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: isArabic ? 'تحديث الفواتير' : 'Refresh',
            onPressed: () => ref.refresh(invoiceListProvider),
          ),
        ],
      ),
      body: invoiceListState.when(
        data: (invoices) {
          // Apply filtering locally
          var filtered = invoices;
          
          if (statusFilter != null) {
            filtered = filtered.where((i) => i.status.toUpperCase() == statusFilter).toList();
          }
          
          if (searchQuery.isNotEmpty) {
            final q = searchQuery.toLowerCase();
            filtered = filtered.where((i) {
              return i.invoiceNumber.toLowerCase().contains(q) || 
                     i.clientName.toLowerCase().contains(q);
            }).toList();
          }

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(isArabic ? 'لا توجد فواتير' : 'No invoices found.', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                ],
              ),
            );
          }
          
          // Render Grid View
          if (viewMode == InvoiceViewMode.grid) {
            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 360,
                mainAxisExtent: 190,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final invoice = filtered[index];
                return InvoiceGridCard(
                  invoice: invoice,
                  onTap: () {
                    context.goNamed(
                      RouteNames.invoiceDetail,
                      pathParameters: {'id': invoice.id},
                    );
                  },
                );
              },
            );
          }

          // Render Card View (Default list)
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final invoice = filtered[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InvoiceCard(
                  invoiceNumber: invoice.invoiceNumber,
                  clientName: invoice.clientName,
                  amount: invoice.totalAmount,
                  status: invoice.status,
                  onTap: () {
                    context.goNamed(
                      RouteNames.invoiceDetail,
                      pathParameters: {'id': invoice.id},
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.goNamed(RouteNames.createInvoice);
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.createInvoice),
      ),
    );
  }
}
