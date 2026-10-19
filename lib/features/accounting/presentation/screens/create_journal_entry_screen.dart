import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:erp_frontend/app.dart';
import 'package:erp_frontend/features/accounting/providers/accounting_providers.dart';
import 'package:erp_frontend/features/accounting/presentation/widgets/searchable_account_selector.dart';

class CreateJournalEntryScreen extends ConsumerStatefulWidget {
  const CreateJournalEntryScreen({super.key});

  @override
  ConsumerState<CreateJournalEntryScreen> createState() => _CreateJournalEntryScreenState();
}

class _CreateJournalEntryScreenState extends ConsumerState<CreateJournalEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController(text: DateTime.now().toIso8601String().split('T')[0]);
  
  final List<Map<String, dynamic>> _lines = [
    {'accountId': null, 'debit': 0.0, 'credit': 0.0, 'desc': '', 'costCenterId': null},
    {'accountId': null, 'debit': 0.0, 'credit': 0.0, 'desc': '', 'costCenterId': null},
  ];

  String? _globalBranchId;
  bool _isLoading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _addLine() {
    setState(() {
      _lines.add({'accountId': null, 'debit': 0.0, 'credit': 0.0, 'desc': '', 'costCenterId': null});
    });
  }

  void _removeLine(int index, bool isArabic) {
    if (_lines.length > 2) {
      setState(() {
        _lines.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic
                ? 'يجب أن يحتوي قيد اليومية على سطرين على الأقل'
                : 'A journal entry must have at least 2 lines',
          ),
        ),
      );
    }
  }

  double get _totalDebit => _lines.fold(0.0, (sum, line) => sum + (line['debit'] as double));
  double get _totalCredit => _lines.fold(0.0, (sum, line) => sum + (line['credit'] as double));
  bool get _isBalanced => _totalDebit > 0 && (_totalDebit - _totalCredit).abs() < 0.01;

  Future<void> _submit(bool isArabic) async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_isBalanced) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic
                ? 'يجب أن يتساوى إجمالي المدين مع إجمالي الدائن، وأن يكون أكبر من 0.'
                : 'Total debits must equal total credits, and be greater than 0.',
          ),
        ),
      );
      return;
    }

    if (_lines.any((l) => l['accountId'] == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic ? 'يرجى اختيار حساب لجميع الأسطر.' : 'Please select an account for all lines.',
          ),
        ),
      );
      return;
    }

    final allAccounts = ref.read(accountsProvider).value ?? [];
    for (int i = 0; i < _lines.length; i++) {
      final line = _lines[i];
      final acc = allAccounts.where((a) => a.id == line['accountId']).firstOrNull;
      if (acc != null && acc.hasCostCenter && (line['costCenterId'] == null || line['costCenterId'].toString().isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isArabic
                  ? 'السطر #${i + 1} (${acc.name}) يتطلب تحديد مركز التكلفة والمرجع.'
                  : 'Line #${i + 1} (${acc.name}) requires a Cost Center reference.',
            ),
            backgroundColor: Colors.orange.shade900,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final api = ref.read(accountingApiProvider);
      final branches = ref.read(branchesProvider).value ?? [];
      
      final effectiveBranchId = branches.length <= 1 
          ? (branches.isNotEmpty ? branches.first.id : null)
          : _globalBranchId;
      
      final linesData = _lines.map((l) => {
        'accountId': l['accountId'],
        'debit': l['debit'].toString(),
        'credit': l['credit'].toString(),
        'description': l['desc'],
        'branchId': effectiveBranchId,
        'costCenterId': l['costCenterId'],
      }).toList();

      await api.createJournalEntry({
        'entryDate': _dateController.text,
        'description': _descriptionController.text,
        'lines': linesData,
      });

      ref.invalidate(journalEntriesProvider);
      ref.invalidate(ledgerProvider);
      
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isArabic ? 'تم إنشاء قيد اليومية بنجاح (مسودة)' : 'Journal Entry created successfully (Draft)',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${isArabic ? "فشل إنشاء القيد: " : "Failed to create entry: "}$e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider);
    final branchesAsync = ref.watch(branchesProvider);
    final costCentersAsync = ref.watch(costCentersProvider);
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'سند قيد يومية جديد' : 'New Journal Entry'),
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
          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.only(right: 16.0), child: CircularProgressIndicator(strokeWidth: 2)))
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () => _submit(isArabic),
              tooltip: isArabic ? 'حفظ' : 'Save',
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: accountsAsync.when(
        data: (accounts) {
          final txAccounts = accounts.where((a) => a.isTransaction).toList();
          final branches = branchesAsync.value ?? [];
          final costCenters = costCentersAsync.value ?? [];
          
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Row(
                  children: [
                    if (branches.length > 1) ...[
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          initialValue: _globalBranchId,
                          decoration: InputDecoration(
                            labelText: isArabic ? 'الفرع' : 'Branch',
                            border: const OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem(value: null, child: Text(isArabic ? 'بدون' : 'None')),
                            ...branches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))),
                          ],
                          onChanged: (v) => setState(() => _globalBranchId = v),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    Expanded(
                      child: TextFormField(
                        controller: _dateController,
                        decoration: InputDecoration(
                          labelText: isArabic ? 'التاريخ (YYYY-MM-DD)' : 'Date (YYYY-MM-DD)',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.isEmpty ? (isArabic ? 'مطلوب' : 'Required') : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: branches.length > 1 ? 1 : 2,
                      child: TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: isArabic ? 'الوصف / البيان' : 'Description / Memo',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Lines Header
                Row(
                  children: [
                    Expanded(flex: 3, child: Text(isArabic ? 'الحساب' : 'Account', style: const TextStyle(fontWeight: FontWeight.bold))),
                    const SizedBox(width: 8),
                    Expanded(flex: 2, child: Text(isArabic ? 'الوصف' : 'Description', style: const TextStyle(fontWeight: FontWeight.bold))),
                    const SizedBox(width: 8),
                    Expanded(flex: 2, child: Text(isArabic ? 'مركز التكلفة' : 'Cost Center', style: const TextStyle(fontWeight: FontWeight.bold))),
                    const SizedBox(width: 8),
                    Expanded(flex: 1, child: Text(isArabic ? 'مدين' : 'Debit', style: const TextStyle(fontWeight: FontWeight.bold))),
                    const SizedBox(width: 8),
                    Expanded(flex: 1, child: Text(isArabic ? 'دائن' : 'Credit', style: const TextStyle(fontWeight: FontWeight.bold))),
                    const SizedBox(width: 48), // For delete icon
                  ],
                ),
                const Divider(),
                
                // Lines List
                ...List.generate(_lines.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: SearchableAccountSelector(
                            selectedAccountId: _lines[index]['accountId'],
                            accounts: txAccounts,
                            isArabic: isArabic,
                            onChanged: (v) => setState(() => _lines[index]['accountId'] = v),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            initialValue: _lines[index]['desc'],
                            decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8)),
                            onChanged: (v) => _lines[index]['desc'] = v,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: Builder(
                            builder: (context) {
                              final currentAccount = txAccounts.where((a) => a.id == _lines[index]['accountId']).firstOrNull;
                              final isCcRequired = currentAccount?.hasCostCenter ?? false;

                              return DropdownButtonFormField<String?>(
                                initialValue: _lines[index]['costCenterId'],
                                decoration: InputDecoration(
                                  labelText: isCcRequired
                                      ? (isArabic ? 'مركز التكلفة * (مطلوب)' : 'Cost Center * (Required)')
                                      : (isArabic ? 'مركز التكلفة' : 'Cost Center'),
                                  labelStyle: TextStyle(
                                    color: isCcRequired ? Colors.amber.shade900 : null,
                                    fontWeight: isCcRequired ? FontWeight.bold : null,
                                  ),
                                  enabledBorder: isCcRequired
                                      ? OutlineInputBorder(borderSide: BorderSide(color: Colors.amber.shade600, width: 1.5))
                                      : const OutlineInputBorder(),
                                  border: const OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                ),
                                isExpanded: true,
                                items: [
                                  DropdownMenuItem(value: null, child: Text(isArabic ? 'بدون' : 'None')),
                                  ...costCenters.map((c) => DropdownMenuItem(value: c.id, child: Text(c.displayNameWithRef, overflow: TextOverflow.ellipsis))),
                                ],
                                onChanged: (v) => setState(() => _lines[index]['costCenterId'] = v),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            initialValue: _lines[index]['debit'].toString(),
                            decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8)),
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                              setState(() {
                                _lines[index]['debit'] = double.tryParse(v) ?? 0.0;
                                if ((double.tryParse(v) ?? 0.0) > 0) {
                                  _lines[index]['credit'] = 0.0; // Clear credit if debit is set
                                }
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            key: ValueKey('cr_${index}_${_lines[index]['credit']}'),
                            initialValue: _lines[index]['credit'].toString(),
                            decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8)),
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                              setState(() {
                                _lines[index]['credit'] = double.tryParse(v) ?? 0.0;
                                if ((double.tryParse(v) ?? 0.0) > 0) {
                                  _lines[index]['debit'] = 0.0; // Clear debit if credit is set
                                }
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: 48,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeLine(index, isArabic),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _addLine,
                    icon: const Icon(Icons.add),
                    label: Text(isArabic ? 'إضافة سطر' : 'Add Line'),
                  ),
                ),
                
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(isArabic ? 'الإجمالي:' : 'Total:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(width: 32),
                    Text(_totalDebit.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _isBalanced ? Colors.green : Colors.red)),
                    const SizedBox(width: 32),
                    Text(_totalCredit.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _isBalanced ? Colors.green : Colors.red)),
                    const SizedBox(width: 48),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('${isArabic ? "خطأ: " : "Error: "}$err')),
      ),
    );
  }
}

