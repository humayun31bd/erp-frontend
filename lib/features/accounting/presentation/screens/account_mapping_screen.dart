import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erp_frontend/app.dart';
import 'package:erp_frontend/features/accounting/providers/accounting_providers.dart';
import 'package:erp_frontend/features/accounting/domain/accounting_models.dart';
import 'package:erp_frontend/features/accounting/domain/account_mapping_models.dart';

const _kPrimary = Color(0xFF4361EE);
const _kSurface = Color(0xFFF8F9FE);
const _kCardBg = Colors.white;
const _kDivider = Color(0xFFE8EAF6);
const _kTextPrimary = Color(0xFF1A1F36);
const _kTextSecondary = Color(0xFF6B7280);

class AccountMappingScreen extends ConsumerStatefulWidget {
  const AccountMappingScreen({super.key});

  @override
  ConsumerState<AccountMappingScreen> createState() => _AccountMappingScreenState();
}

class _AccountMappingScreenState extends ConsumerState<AccountMappingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, String> _selectedMappings = {}; // mappingKey -> accountId
  bool _isSaving = false;

  final List<Map<String, dynamic>> _modules = const [
    {
      'key': 'POS',
      'labelEn': 'POS & Sales',
      'labelAr': 'المبيعات ونقاط البيع',
      'icon': Icons.point_of_sale_rounded,
      'color': Color(0xFF10B981),
    },
    {
      'key': 'PURCHASE',
      'labelEn': 'Purchasing & AP',
      'labelAr': 'المشتريات والحسابات الدائنة',
      'icon': Icons.shopping_bag_rounded,
      'color': Color(0xFFF59E0B),
    },
    {
      'key': 'TAX',
      'labelEn': 'Tax & NBR VAT',
      'labelAr': 'الضرائب وضريبة القيمة المضافة',
      'icon': Icons.gavel_rounded,
      'color': Color(0xFFEF4444),
    },
    {
      'key': 'INVENTORY',
      'labelEn': 'Inventory & Assets',
      'labelAr': 'المخزون والأصول',
      'icon': Icons.inventory_2_rounded,
      'color': Color(0xFF8B5CF6),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _modules.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeMappings(List<AccountMapping> existingMappings) {
    for (final m in existingMappings) {
      if (!_selectedMappings.containsKey(m.mappingKey)) {
        _selectedMappings[m.mappingKey] = m.accountId;
      }
    }
  }

  void _autoDetectDefaults(List<Account> accounts, bool isArabic) {
    setState(() {
      for (final def in kSystemMappingDefinitions) {
        // Find matching transaction account by code prefix or type match
        Account? match;
        
        // 1. Try matching code prefix hint
        match = accounts.where((a) => a.isTransaction && a.code.startsWith(def.defaultCodeHint)).firstOrNull;
        
        // 2. Fallback to matching type
        match ??= accounts.where((a) => a.isTransaction && a.type == def.requiredType).firstOrNull;

        if (match != null) {
          _selectedMappings[def.mappingKey] = match.id;
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isArabic
              ? 'تم الربط التلقائي لأفضل الحسابات الافتراضية لجميع الوحدات!'
              : 'Auto-detected best Chart of Accounts (COA) defaults for all modules!',
        ),
      ),
    );
  }

  Future<void> _saveMappings(bool isArabic) async {
    setState(() => _isSaving = true);
    try {
      final List<Map<String, dynamic>> mappingsPayload = [];

      for (final def in kSystemMappingDefinitions) {
        final accountId = _selectedMappings[def.mappingKey];
        if (accountId != null && accountId.isNotEmpty) {
          mappingsPayload.add({
            'moduleKey': def.moduleKey,
            'mappingKey': def.mappingKey,
            'accountId': accountId,
          });
        }
      }

      final api = ref.read(accountingApiProvider);
      await api.updateAccountMappings({'mappings': mappingsPayload});

      ref.invalidate(accountMappingsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isArabic
                  ? 'تم حفظ ربط حسابات الوحدات بنجاح! تم ربط الوحدات بدليل الحسابات.'
                  : 'Module Account Mappings saved successfully! System modules linked to COA.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${isArabic ? "خطأ في حفظ الربط: " : "Error saving mappings: "}$e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider);
    final mappingsAsync = ref.watch(accountMappingsProvider);
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return Scaffold(
      backgroundColor: _kSurface,
      appBar: AppBar(
        backgroundColor: _kCardBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? 'ربط الوحدات وحسابات الدليل' : 'Module Integration & Account Mappings',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _kTextPrimary, letterSpacing: -0.3),
            ),
            Text(
              isArabic
                  ? 'ربط نقاط البيع، المشتريات، الضرائب، والمخزون بدليل الحسابات (COA)'
                  : 'Link POS, Purchasing, Tax & Inventory to Chart of Accounts (COA)',
              style: const TextStyle(fontSize: 12, color: _kTextSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: _kTextPrimary),
            onPressed: () {
              final current = ref.read(localeProvider);
              ref.read(localeProvider.notifier).state =
                  current.languageCode == 'en' ? const Locale('ar') : const Locale('en');
            },
            tooltip: isArabic ? 'تغيير اللغة' : 'Switch Language',
          ),
          const SizedBox(width: 8),
          accountsAsync.when(
            data: (accounts) => TextButton.icon(
              onPressed: () => _autoDetectDefaults(accounts, isArabic),
              icon: const Icon(Icons.auto_fix_high_rounded, color: _kPrimary, size: 18),
              label: Text(
                isArabic ? 'ربط تلقائي' : 'Auto-Map Defaults',
                style: const TextStyle(color: _kPrimary, fontWeight: FontWeight.w600),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _isSaving ? null : () => _saveMappings(isArabic),
            icon: _isSaving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.save_rounded, size: 18),
            label: Text(_isSaving ? (isArabic ? 'جاري الحفظ...' : 'Saving...') : (isArabic ? 'حفظ الربط' : 'Save Mappings')),
          ),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(49),
          child: Column(
            children: [
              Container(height: 1, color: _kDivider),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: _kPrimary,
                unselectedLabelColor: _kTextSecondary,
                indicatorColor: _kPrimary,
                indicatorWeight: 3,
                tabs: _modules.map((mod) {
                  final label = isArabic ? mod['labelAr'] as String : mod['labelEn'] as String;
                  return Tab(
                    child: Row(
                      children: [
                        Icon(mod['icon'] as IconData, size: 18, color: mod['color'] as Color),
                        const SizedBox(width: 8),
                        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      body: accountsAsync.when(
        data: (accounts) {
          final transactionAccounts = accounts.where((a) => a.isTransaction).toList();

          return mappingsAsync.when(
            data: (existingMappings) {
              _initializeMappings(existingMappings);

              return TabBarView(
                controller: _tabController,
                children: _modules.map((mod) {
                  final moduleKey = mod['key'] as String;
                  final definitions = kSystemMappingDefinitions.where((d) => d.moduleKey == moduleKey).toList();

                  return _buildModuleMappingList(moduleKey, definitions, transactionAccounts, isArabic);
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('${isArabic ? "خطأ في تحميل ربط الحسابات: " : "Error loading account mappings: "}$e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${isArabic ? "خطأ في تحميل الحسابات: " : "Error loading accounts: "}$e')),
      ),
    );
  }

  Widget _buildModuleMappingList(
    String moduleKey,
    List<SystemMappingDefinition> definitions,
    List<Account> transactionAccounts,
    bool isArabic,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner explanation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Colors.blue.shade700, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isArabic
                        ? 'القيود الآلية للنظام (المبيعات، المشتريات، والضرائب) تقوم ترحيل قيود اليومية تلقائياً باستخدام حسابات الدليل المحددة هذه.'
                        : 'System entries (POS checkout, Wholesale Purchases, NBR VAT/TDS Tax) automatically post journal vouchers using these selected Chart of Accounts.',
                    style: TextStyle(fontSize: 13, color: Colors.blue.shade900, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Mapping Cards List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: definitions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final def = definitions[index];
              final selectedAccountId = _selectedMappings[def.mappingKey];
              final selectedAccount = transactionAccounts.where((a) => a.id == selectedAccountId).firstOrNull;

              // Filter suggested accounts by type
              final candidateAccounts = transactionAccounts.where((a) => a.type == def.requiredType).toList();

              return Card(
                elevation: 0,
                color: _kCardBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: selectedAccount != null ? Colors.green.shade300 : _kDivider,
                    width: selectedAccount != null ? 1.5 : 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _getTypeColor(def.requiredType).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(_getTypeIcon(def.requiredType), color: _getTypeColor(def.requiredType), size: 20),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                def.label,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _kTextPrimary),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Chip(
                                label: Text(_getTypeLabel(def.requiredType, isArabic)),
                                backgroundColor: _getTypeColor(def.requiredType).withValues(alpha: 0.1),
                                side: BorderSide.none,
                                labelStyle: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _getTypeColor(def.requiredType),
                                ),
                              ),
                              const SizedBox(width: 8),
                              selectedAccount != null
                                  ? Chip(
                                      avatar: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
                                      label: Text(isArabic ? 'مرتبط' : 'Linked'),
                                      backgroundColor: const Color(0xFFDCFCE7),
                                      side: BorderSide.none,
                                      labelStyle: const TextStyle(fontSize: 11, color: Color(0xFF15803D), fontWeight: FontWeight.bold),
                                    )
                                  : Chip(
                                      avatar: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 16),
                                      label: Text(isArabic ? 'غير مرتبط' : 'Unmapped'),
                                      backgroundColor: const Color(0xFFFEF3C7),
                                      side: BorderSide.none,
                                      labelStyle: const TextStyle(fontSize: 11, color: Color(0xFFB45309), fontWeight: FontWeight.bold),
                                    ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(def.description, style: const TextStyle(fontSize: 13, color: _kTextSecondary)),
                      const SizedBox(height: 16),

                      // Dropdown Account Selector
                      DropdownButtonFormField<String>(
                        initialValue: candidateAccounts.any((a) => a.id == selectedAccountId) ? selectedAccountId : null,
                        decoration: InputDecoration(
                          labelText: isArabic
                              ? 'اختر حساب ${_getTypeLabel(def.requiredType, isArabic)}'
                              : 'Select ${def.requiredType} Account',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          prefixIcon: const Icon(Icons.account_tree_outlined, size: 20),
                        ),
                        hint: Text(
                          isArabic
                              ? 'اختر حساب الدليل (تلميح: الرمز ${def.defaultCodeHint})'
                              : 'Choose COA Account (Hint: Code ${def.defaultCodeHint})',
                        ),
                        items: candidateAccounts.map((account) {
                          return DropdownMenuItem<String>(
                            value: account.id,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    account.code,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(account.name, style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedMappings[def.mappingKey] = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(String type, bool isArabic) {
    if (!isArabic) return type;
    switch (type) {
      case 'ASSET': return 'أصول';
      case 'LIABILITY': return 'التزامات';
      case 'EQUITY': return 'حقوق الملكية';
      case 'REVENUE': return 'إيرادات';
      case 'EXPENSE': return 'مصروفات';
      default: return type;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'ASSET':
        return const Color(0xFF10B981);
      case 'LIABILITY':
        return const Color(0xFFF59E0B);
      case 'EQUITY':
        return const Color(0xFF8B5CF6);
      case 'REVENUE':
        return const Color(0xFF3B82F6);
      case 'EXPENSE':
        return const Color(0xFFEF4444);
      default:
        return _kPrimary;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'ASSET':
        return Icons.account_balance_wallet_rounded;
      case 'LIABILITY':
        return Icons.credit_card_rounded;
      case 'EQUITY':
        return Icons.pie_chart_rounded;
      case 'REVENUE':
        return Icons.trending_up_rounded;
      case 'EXPENSE':
        return Icons.shopping_cart_rounded;
      default:
        return Icons.account_balance_rounded;
    }
  }
}

