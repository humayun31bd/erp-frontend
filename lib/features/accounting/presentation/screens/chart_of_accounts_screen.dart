import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:erp_frontend/app.dart';
import 'package:erp_frontend/features/accounting/providers/accounting_providers.dart';
import 'package:erp_frontend/features/accounting/presentation/widgets/coa_help_modal.dart';

// ─── Color palette & helpers ──────────────────────────────────────────────────
const _kPrimary = Color(0xFF4361EE);
const _kSurface = Color(0xFFF8F9FE);
const _kCardBg  = Colors.white;
const _kDivider = Color(0xFFE8EAF6);
const _kTextPrimary   = Color(0xFF1A1F36);
const _kTextSecondary = Color(0xFF6B7280);

Color _typeColor(String type) {
  switch (type) {
    case 'ASSET':     return const Color(0xFF10B981);
    case 'LIABILITY': return const Color(0xFFF59E0B);
    case 'EQUITY':    return const Color(0xFF8B5CF6);
    case 'REVENUE':   return const Color(0xFF3B82F6);
    case 'EXPENSE':   return const Color(0xFFEF4444);
    default:          return _kPrimary;
  }
}

String _typeLabel(String type, bool isArabic) {
  if (!isArabic) return type;
  switch (type) {
    case 'ASSET':     return 'أصول';
    case 'LIABILITY': return 'التزامات';
    case 'EQUITY':    return 'حقوق الملكية';
    case 'REVENUE':   return 'إيرادات';
    case 'EXPENSE':   return 'مصروفات';
    default:          return type;
  }
}

IconData _typeIcon(String type) {
  switch (type) {
    case 'ASSET':     return Icons.account_balance_wallet_rounded;
    case 'LIABILITY': return Icons.credit_card_rounded;
    case 'EQUITY':    return Icons.pie_chart_rounded;
    case 'REVENUE':   return Icons.trending_up_rounded;
    case 'EXPENSE':   return Icons.shopping_cart_rounded;
    default:          return Icons.account_balance_rounded;
  }
}

// ─── Main Screen ──────────────────────────────────────────────────────────────
class ChartOfAccountsScreen extends ConsumerStatefulWidget {
  const ChartOfAccountsScreen({super.key});

  @override
  ConsumerState<ChartOfAccountsScreen> createState() => _ChartOfAccountsScreenState();
}

class _ChartOfAccountsScreenState extends ConsumerState<ChartOfAccountsScreen> {
  Account? _selectedAccount;
  bool _isCreatingNew = false;
  final int _maxDepth = 5;
  bool _isExpandAll = false;
  int _treeKey = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Account> _filterAccounts(List<Account> accounts, String query) {
    if (query.trim().isEmpty) return accounts;
    final q = query.trim().toLowerCase();

    final matchingIds = <String>{};
    for (final a in accounts) {
      if (a.name.toLowerCase().contains(q) || a.code.toLowerCase().contains(q)) {
        matchingIds.add(a.id);
        String? parentId = a.parentId;
        while (parentId != null) {
          matchingIds.add(parentId);
          final parent = accounts.firstWhere((p) => p.id == parentId, orElse: () => a);
          if (parent.id == parentId) {
            parentId = parent.parentId;
          } else {
            break;
          }
        }
      }
    }

    return accounts.where((a) => matchingIds.contains(a.id)).toList();
  }

  Map<String?, List<Account>> _buildTree(List<Account> accounts) {
    final filtered = _filterAccounts(accounts, _searchQuery);
    final Map<String?, List<Account>> tree = {};
    for (final account in filtered) {
      if (!tree.containsKey(account.parentId)) {
        tree[account.parentId] = [];
      }
      tree[account.parentId]!.add(account);
    }
    for (final key in tree.keys) {
      tree[key]!.sort((a, b) => a.code.compareTo(b.code));
    }
    return tree;
  }

  Widget _buildNode(Account account, Map<String?, List<Account>> tree) {
    final children = tree[account.id] ?? [];
    final isSelected = _selectedAccount?.id == account.id;
    final indent = 12.0 + 16.0 * (account.level - 1);

    final icon = Icon(
      children.isNotEmpty ? Icons.folder_rounded : Icons.receipt_long_rounded,
      size: 18,
      color: isSelected ? _kPrimary : _typeColor(account.type).withValues(alpha: 0.7),
    );

    final titleWidget = Text(
      account.name,
      style: TextStyle(
        fontSize: 13.5,
        fontWeight: account.level <= 2 ? FontWeight.w600 : FontWeight.w400,
        color: isSelected ? _kPrimary : _kTextPrimary,
      ),
    );

    final txnChip = account.isTransaction
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: _kPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('Txn', style: TextStyle(fontSize: 10, color: _kPrimary, fontWeight: FontWeight.w600)),
          )
        : null;

    final ccChip = account.hasCostCenter
        ? Container(
            margin: const EdgeInsets.only(left: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.amber.shade700.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('CC Ref', style: TextStyle(fontSize: 10, color: Colors.amber.shade900, fontWeight: FontWeight.bold)),
          )
        : null;

    if (children.isEmpty) {
      return InkWell(
        onTap: () => setState(() { _selectedAccount = account; _isCreatingNew = false; }),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: EdgeInsets.only(left: indent, right: 8, top: 1, bottom: 1),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? _kPrimary.withValues(alpha: 0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? Border.all(color: _kPrimary.withValues(alpha: 0.2)) : null,
          ),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 8),
              Expanded(child: titleWidget),
              if (txnChip != null) txnChip,
              if (ccChip != null) ccChip,
            ],
          ),
        ),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: PageStorageKey('${account.id}_$_treeKey'),
        tilePadding: EdgeInsets.only(left: indent, right: 12),
        leading: icon,
        title: titleWidget,
        initiallyExpanded: _isExpandAll || _searchQuery.isNotEmpty || account.level == 1 ||
            (_selectedAccount != null && _isDescendant(account, _selectedAccount!, tree)),
        children: children.map((child) => _buildNode(child, tree)).toList(),
        onExpansionChanged: (expanded) {
          if (expanded) {
            setState(() { _selectedAccount = account; _isCreatingNew = false; });
          }
        },
      ),
    );
  }

  bool _isDescendant(Account parent, Account target, Map<String?, List<Account>> tree) {
    if (parent.id == target.parentId) return true;
    final children = tree[parent.id] ?? [];
    for (final child in children) {
      if (_isDescendant(child, target, tree)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider);
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return Scaffold(
      backgroundColor: _kSurface,
      appBar: AppBar(
        backgroundColor: _kCardBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          isArabic ? 'دليل الحسابات' : 'Chart of Accounts',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _kTextPrimary, letterSpacing: -0.3),
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
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: _kPrimary),
            tooltip: isArabic ? 'دليل تعليمات الحسابات' : 'COA Training Guide',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const CoaHelpModal(),
              );
            },
          ),
          const SizedBox(width: 12),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _kDivider),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Left Panel ──────────────────────────────────────────────────
            SizedBox(
              width: 340,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 2))],
                ),
                child: Material(
                  color: _kCardBg,
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: accountsAsync.when(
                  data: (accounts) {
                    if (accounts.isEmpty) {
                      return Center(
                        child: Text(
                          isArabic ? 'لم يتم العثور على حسابات.' : 'No accounts found.',
                          style: const TextStyle(color: _kTextSecondary),
                        ),
                      );
                    }
                    final tree = _buildTree(accounts);
                    final rootNodes = tree[null] ?? [];

                    return Column(
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 8, 6),
                          child: Row(
                            children: [
                              const Icon(Icons.account_tree_rounded, size: 18, color: _kPrimary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  isArabic ? 'شجرة الحسابات' : 'Accounts Tree',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kTextPrimary),
                                ),
                              ),
                              _TreeIconBtn(
                                icon: Icons.unfold_more_rounded,
                                tooltip: isArabic ? 'توسيع الكل' : 'Expand All',
                                onTap: () => setState(() { _isExpandAll = true; _treeKey++; }),
                              ),
                              _TreeIconBtn(
                                icon: Icons.unfold_less_rounded,
                                tooltip: isArabic ? 'طوي الكل' : 'Collapse All',
                                onTap: () => setState(() { _isExpandAll = false; _treeKey++; }),
                              ),
                            ],
                          ),
                        ),

                        // Search / Filter Input Bar
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
                          child: SizedBox(
                            height: 38,
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(fontSize: 13, color: _kTextPrimary),
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: isArabic ? 'البحث عن رمز أو اسم الحساب...' : 'Search account code or name...',
                                hintStyle: const TextStyle(fontSize: 12.5, color: _kTextSecondary),
                                prefixIcon: const Icon(Icons.search_rounded, size: 18, color: _kPrimary),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(Icons.clear_rounded, size: 16, color: _kTextSecondary),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {
                                            _searchQuery = '';
                                            _treeKey++;
                                          });
                                        },
                                      )
                                    : null,
                                filled: true,
                                fillColor: _kSurface,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: _kDivider),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: _kDivider),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: _kPrimary, width: 1.5),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                  _treeKey++;
                                });
                              },
                            ),
                          ),
                        ),

                        const Divider(height: 1, color: _kDivider),
                        // Tree
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            children: ['ASSET', 'LIABILITY', 'EQUITY', 'REVENUE', 'EXPENSE'].map((type) {
                              final typeRootNodes = rootNodes.where((a) => a.type == type).toList();
                              final color = _typeColor(type);
                              return Theme(
                                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                child: ExpansionTile(
                                  key: PageStorageKey('type_$type$_treeKey'),
                                  tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                                  leading: Container(
                                    width: 32, height: 32,
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(_typeIcon(type), size: 17, color: color),
                                  ),
                                  title: Row(
                                    children: [
                                      Text(
                                        _typeLabel(type, isArabic),
                                        style: TextStyle(
                                          fontSize: 13,

                                          fontWeight: FontWeight.w700,
                                          color: color,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const Spacer(),
                                      TextButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            _selectedAccount = Account(
                                              id: '',
                                              code: '',
                                              name: '',
                                              type: type,
                                              level: 0,
                                              isControl: false,
                                              isTransaction: false,
                                              isActive: true,
                                            );
                                            _isCreatingNew = true;
                                          });
                                        },
                                        icon: const Icon(Icons.add, size: 14),
                                        label: const Text('Add Account', style: TextStyle(fontSize: 11)),
                                        style: TextButton.styleFrom(
                                          foregroundColor: color,
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                          minimumSize: const Size(0, 24),
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      )
                                    ]
                                  ),
                                  initiallyExpanded: _isExpandAll,
                                  children: typeRootNodes.map((child) => _buildNode(child, tree)).toList(),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
                ),
              ),
            ),
          ),

            const SizedBox(width: 20),

            // ── Right Panel ─────────────────────────────────────────────────
            Expanded(
              child: accountsAsync.when(
                data: (accounts) {
                  // Sync _selectedAccount with fresh data from provider
                  if (_selectedAccount != null && _selectedAccount!.id.isNotEmpty) {
                    final fresh = accounts.where((a) => a.id == _selectedAccount!.id).firstOrNull;
                    if (fresh != null && fresh != _selectedAccount) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) setState(() => _selectedAccount = fresh);
                      });
                    }
                  }

                  if (_selectedAccount == null) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(
                              color: _kPrimary.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.touch_app_rounded, size: 38, color: _kPrimary),
                          ),
                          const SizedBox(height: 16),
                          const Text('Select an account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _kTextPrimary)),
                          const SizedBox(height: 6),
                          const Text('Click any account from the tree to view or edit its details.', style: TextStyle(color: _kTextSecondary, fontSize: 13)),
                        ],
                      ),
                    );
                  }

                  return _AccountFormPanel(
                    key: ValueKey('${_selectedAccount!.id}_${_isCreatingNew}_${_selectedAccount!.parentId}_${_selectedAccount!.accountSubtype}'),
                    account: _selectedAccount!,
                    isCreatingNew: _isCreatingNew,
                    allAccounts: accounts,
                    onSaveCompleted: () => setState(() => _isCreatingNew = false),
                    onCancel: () => setState(() => _isCreatingNew = false),
                    onAddSubAccount: (_selectedAccount!.level < _maxDepth && !_selectedAccount!.isTransaction)
                        ? () => setState(() => _isCreatingNew = true)
                        : null,
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (err, _) => const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Small helper icon button ──────────────────────────────────────────────────
class _TreeIconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _TreeIconBtn({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 20, color: _kTextSecondary),
        ),
      ),
    );
  }
}

// ─── Account Form Panel ────────────────────────────────────────────────────────
class _AccountFormPanel extends ConsumerStatefulWidget {
  final Account account;
  final bool isCreatingNew;
  final List<Account> allAccounts;
  final VoidCallback onSaveCompleted;
  final VoidCallback onCancel;
  final VoidCallback? onAddSubAccount;

  const _AccountFormPanel({
    super.key,
    required this.account,
    required this.isCreatingNew,
    required this.allAccounts,
    required this.onSaveCompleted,
    required this.onCancel,
    this.onAddSubAccount,
  });

  @override
  ConsumerState<_AccountFormPanel> createState() => _AccountFormPanelState();
}

class _AccountFormPanelState extends ConsumerState<_AccountFormPanel> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _nameController;

  late String _type;
  late int _level;
  String? _parentId;
  late bool _isActive;
  late bool _isControl;
  late bool _isTransaction;
  late bool _isCashNature;
  late bool _isBankNature;
  late bool _hasCostCenter;
  String? _accountSubtype;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initFields();
  }

  void _initFields() {
    if (widget.isCreatingNew) {
      _level = widget.account.level + 1;
      _type = widget.account.type;
      _parentId = _level == 1 ? null : widget.account.id;
      final newCode = _generateNextCode(widget.account.code, _level, _parentId);
      _codeController = TextEditingController(text: newCode);
      _nameController = TextEditingController();
      _isActive = true;
      _isControl = false;
      _isTransaction = _level == 4 || _level == 5;
      _isCashNature = false;
      _isBankNature = false;
      _hasCostCenter = false;
      _accountSubtype = null;
    } else {
      _level = widget.account.level;
      _type = widget.account.type;
      _parentId = widget.account.parentId;
      _codeController = TextEditingController(text: widget.account.code);
      _nameController = TextEditingController(text: widget.account.name);
      _isActive = widget.account.isActive;
      _isControl = widget.account.isControl;
      _isTransaction = widget.account.isTransaction;
      _isCashNature = widget.account.isCashNature;
      _isBankNature = widget.account.isBankNature;
      _hasCostCenter = widget.account.hasCostCenter;
      _accountSubtype = widget.account.accountSubtype;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String _generateNextCode(String parentCode, int newLevel, String? parentId) {
    if (newLevel == 1) {
      // Level 1 logic: code should just be '1', '2', '3', '4', '5' depending on type maybe?
      // Or just find the max level 1 code and add 1.
      final children = widget.allAccounts.where((a) => a.level == 1 && a.type == widget.account.type).toList();
      if (children.isEmpty) {
        switch (widget.account.type) {
          case 'ASSET': return '1';
          case 'LIABILITY': return '2';
          case 'EQUITY': return '3';
          case 'REVENUE': return '4';
          case 'EXPENSE': return '5';
          default: return '9';
        }
      }
      int maxVal = 0;
      for (var c in children) {
        final val = int.tryParse(c.code) ?? 0;
        if (val > maxVal) maxVal = val;
      }
      return (maxVal + 1).toString();
    }

    if (parentId == null) return '$parentCode.';
    final children = widget.allAccounts.where((a) => a.parentId == parentId).toList();
    if (children.isEmpty) {
      if (newLevel == 2) return '$parentCode.10';
      if (newLevel == 3) return '$parentCode.01';
      return '$parentCode.001';
    }

    int maxVal = 0;
    for (var c in children) {
      final parts = c.code.split('.');
      if (parts.isNotEmpty) {
        final last = int.tryParse(parts.last) ?? 0;
        if (last > maxVal) maxVal = last;
      }
    }

    final nextVal = maxVal + 1;
    if (newLevel == 2) {
      return '$parentCode.${nextVal.toString().padLeft(2, '0')}';
    } else if (newLevel == 3) {
      return '$parentCode.${nextVal.toString().padLeft(2, '0')}';
    } else {
      return '$parentCode.${nextVal.toString().padLeft(3, '0')}';
    }
  }

  Future<void> _submit({bool addAnother = false}) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final api = ref.read(accountingApiProvider);

      final payload = {
        'code': _codeController.text,
        'name': _nameController.text,
        'type': _type,
        'level': _level,
        'parentId': _parentId,
        'isActive': _isActive,
        'isControl': _isControl,
        'isTransaction': _isTransaction,
        'isCashNature': _isCashNature,
        'isBankNature': _isBankNature,
        'hasCostCenter': _hasCostCenter,
        'accountSubtype': _accountSubtype,
      };

      if (widget.isCreatingNew) {
        await api.createAccount(payload);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Account Created'), backgroundColor: Colors.green.shade600),
          );
        }
        ref.invalidate(accountsProvider);
        if (addAnother) {
          _nameController.clear();
          _codeController.text = _generateNextCode(widget.account.code, _level, _parentId);
        } else {
          widget.onSaveCompleted();
        }
      } else {
        await api.updateAccount(widget.account.id, payload);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Account Updated'), backgroundColor: Colors.blue.shade700),
          );
        }
        ref.invalidate(accountsProvider);
        widget.onSaveCompleted();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete this account? This cannot be undone and will fail if the account has journal entries or sub-accounts.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final api = ref.read(accountingApiProvider);
      await api.deleteAccount(widget.account.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account Deleted Successfully'), backgroundColor: Colors.green),
        );
      }
      ref.invalidate(accountsProvider);
      widget.onCancel();
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? e.message;
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $msg'), backgroundColor: Colors.red));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLevel5 = _level == 5;
    const canEditName = true;
    final canEditParent = _level > 1 && !isLevel5;
    final canEditActive = _level > 1;
    final canEditLevel3Subtype = _level >= 3;
    final accentColor = _typeColor(_type);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Header ────────────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_typeIcon(_type), size: 22, color: accentColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isCreatingNew ? 'New Sub-Account' : 'Edit Account',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _kTextPrimary, letterSpacing: -0.3),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('Level $_level', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: accentColor)),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _kDivider,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(_type, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _kTextSecondary)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(color: _kDivider, height: 1),
            const SizedBox(height: 16),

            // Hidden code field
            Visibility(
              visible: false,
              child: TextFormField(controller: _codeController),
            ),

            // ── Form Fields (2-Column Layout) ───────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Name & Type
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel(label: 'Account Name', required: true),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _nameController,
                        enabled: canEditName,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _kTextPrimary),
                        decoration: _inputDecoration('e.g. Cash and Cash Equivalents'),
                        validator: (v) => v == null || v.isEmpty ? 'Account name is required' : null,
                      ),
                      const SizedBox(height: 12),
                      
                      const _FieldLabel(label: 'Account Type'),
                      const SizedBox(height: 4),
                      if (_level == 1 && widget.isCreatingNew)
                        DropdownButtonFormField<String>(
                          initialValue: _type,
                          style: const TextStyle(fontSize: 14, color: _kTextPrimary),
                          decoration: _inputDecoration('Select type'),
                          items: ['ASSET', 'LIABILITY', 'EQUITY', 'REVENUE', 'EXPENSE']
                              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                              .toList(),
                          onChanged: (v) => setState(() => _type = v!),
                        )
                      else
                        TextFormField(
                          initialValue: _type,
                          enabled: false,
                          style: const TextStyle(fontSize: 14, color: _kTextSecondary),
                          decoration: _inputDecoration(''),
                        ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                
                const SizedBox(width: 20),
                
                // Right Column: Parent & Classification
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel(label: 'Parent Account'),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String?>(
                        initialValue: _parentId,
                        style: const TextStyle(fontSize: 14, color: _kTextPrimary),
                        decoration: _inputDecoration('Select parent'),
                        items: _level == 1
                            ? [DropdownMenuItem(value: null, child: Text('$_type (Level 0)'))]
                            : widget.allAccounts
                                .where((a) => a.level == _level - 1 && a.type == _type)
                                .map((a) => DropdownMenuItem(value: a.id, child: Text(a.name)))
                                .toList(),
                        onChanged: canEditParent ? (v) => setState(() => _parentId = v) : null,
                      ),
                      const SizedBox(height: 12),
                      if (canEditLevel3Subtype) ...[
                        const _FieldLabel(label: 'Account Classification'),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String?>(
                          initialValue: _accountSubtype,
                          style: const TextStyle(fontSize: 14, color: _kTextPrimary),
                          decoration: _inputDecoration('None'),
                          items: const [
                            DropdownMenuItem(value: null, child: Text('None')),
                            DropdownMenuItem(value: 'FIXED_ASSET', child: Text('Fixed Asset')),
                            DropdownMenuItem(value: 'INVENTORY', child: Text('Inventory')),
                            DropdownMenuItem(value: 'RECEIVABLES', child: Text('Receivables')),
                            DropdownMenuItem(value: 'PAYABLES', child: Text('Payables')),
                            DropdownMenuItem(value: 'BANK', child: Text('Bank')),
                            DropdownMenuItem(value: 'CASH', child: Text('Cash')),
                            DropdownMenuItem(value: 'COST_CENTER', child: Text('Cost Center')),
                          ],
                          onChanged: (v) => setState(() => _accountSubtype = v),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            // ── Toggles ────────────────────────────────────────────────────
            _SectionCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _ToggleRow(
                          title: 'Is Active',
                          subtitle: 'Account is in use',
                          value: _isActive,
                          onChanged: canEditActive ? (v) => setState(() => _isActive = v) : null,
                        ),
                      ),
                      Container(width: 1, height: 52, color: _kDivider),
                      Expanded(
                        child: _ToggleRow(
                          title: 'Is Transaction',
                          subtitle: 'Allows journal entries',
                          value: _isTransaction,
                          onChanged: (v) => setState(() => _isTransaction = v),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  _ToggleRow(
                    title: 'Requires Cost Center & Ref',
                    subtitle: 'Mandatory cost center reference (Employee, Vehicle, Branch, Project, etc.) in vouchers',
                    value: _hasCostCenter,
                    onChanged: (v) => setState(() => _hasCostCenter = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Action Buttons ─────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!widget.isCreatingNew) ...[
                  OutlinedButton(
                    onPressed: _isLoading ? null : _deleteAccount,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Delete', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 12),
                ],
                OutlinedButton(
                  onPressed: widget.onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _kTextSecondary,
                    side: const BorderSide(color: _kDivider),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Cancel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
                if (widget.isCreatingNew) ...[
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : () => _submit(addAnother: true),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Add Another', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kPrimary,
                      side: BorderSide(color: _kPrimary.withValues(alpha: 0.4)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: _isLoading ? null : () => _submit(addAnother: false),
                  style: FilledButton.styleFrom(
                    backgroundColor: _kPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Save Account', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
                if (!widget.isCreatingNew && widget.onAddSubAccount != null) ...[
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    onPressed: widget.onAddSubAccount,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Add Sub-Account', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    style: FilledButton.styleFrom(
                      backgroundColor: _kPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: _kTextSecondary),
      filled: true,
      fillColor: _kSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kDivider)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kDivider)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _kPrimary, width: 1.5)),
      disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _kDivider.withValues(alpha: 0.5))),
    );
  }
}

// ─── Small reusable widgets ────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String label;
  final bool required;
  const _FieldLabel({required this.label, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kTextSecondary, letterSpacing: 0.3)),
        if (required) const Text(' *', style: TextStyle(color: Colors.red, fontSize: 12)),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kDivider),
      ),
      child: child,
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  const _ToggleRow({required this.title, required this.subtitle, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _kTextPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: _kTextSecondary)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: _kPrimary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}
