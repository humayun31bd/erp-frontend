import 'package:flutter/material.dart';
import 'package:erp_frontend/features/accounting/domain/accounting_models.dart';

class SearchableAccountSelector extends StatelessWidget {
  final String? selectedAccountId;
  final List<Account> accounts;
  final ValueChanged<String?> onChanged;
  final String? labelText;
  final bool isArabic;
  final String? errorText;

  const SearchableAccountSelector({
    super.key,
    required this.selectedAccountId,
    required this.accounts,
    required this.onChanged,
    this.labelText,
    this.isArabic = false,
    this.errorText,
  });

  Account? get _selectedAccount {
    if (selectedAccountId == null) return null;
    return accounts.where((a) => a.id == selectedAccountId).firstOrNull;
  }

  void _openSearchDialog(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (context) => _AccountSearchModal(
        accounts: accounts,
        selectedAccountId: selectedAccountId,
        isArabic: isArabic,
      ),
    ).then((selectedId) {
      if (selectedId != null) {
        onChanged(selectedId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedAcc = _selectedAccount;
    final label = labelText ?? (isArabic ? 'اختر الحساب' : 'Select Account');

    return InkWell(
      onTap: () => _openSearchDialog(context),
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          suffixIcon: IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.indigo),
            tooltip: isArabic ? 'بحث في الحسابات' : 'Search Accounts',
            onPressed: () => _openSearchDialog(context),
          ),
        ),
        child: Text(
          selectedAcc != null ? selectedAcc.name : (isArabic ? 'اضغط للبحث واختيار الحساب...' : 'Click to search & select account...'),
          style: TextStyle(
            color: selectedAcc != null ? Colors.grey.shade900 : Colors.grey.shade500,
            fontWeight: selectedAcc != null ? FontWeight.w500 : FontWeight.normal,
            fontSize: 13,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _AccountSearchModal extends StatefulWidget {
  final List<Account> accounts;
  final String? selectedAccountId;
  final bool isArabic;

  const _AccountSearchModal({
    required this.accounts,
    required this.selectedAccountId,
    required this.isArabic,
  });

  @override
  State<_AccountSearchModal> createState() => _AccountSearchModalState();
}

class _AccountSearchModalState extends State<_AccountSearchModal> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Account> get _filteredAccounts {
    if (_searchQuery.trim().isEmpty) return widget.accounts;
    final q = _searchQuery.trim().toLowerCase();
    return widget.accounts.where((a) {
      final nameMatches = a.name.toLowerCase().contains(q);
      final codeMatches = a.code.toLowerCase().contains(q);
      final typeMatches = a.type.toLowerCase().contains(q);
      return nameMatches || codeMatches || typeMatches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredAccounts;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 600),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_rounded, color: Colors.indigo),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.isArabic ? 'البحث عن حساب وتحديده' : 'Search & Select Account',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: widget.isArabic ? 'ابحث باسم الحساب، الرمز أو النوع...' : 'Search by account name, code, or type...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        widget.isArabic ? 'لا توجد نتائج مطابقة' : 'No matching accounts found',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final acc = filtered[i];
                        final isSelected = acc.id == widget.selectedAccountId;

                        return ListTile(
                          selected: isSelected,
                          selectedTileColor: Colors.indigo.shade50,
                          onTap: () => Navigator.pop(context, acc.id),
                          leading: CircleAvatar(
                            backgroundColor: isSelected ? Colors.indigo : Colors.grey.shade200,
                            foregroundColor: isSelected ? Colors.white : Colors.grey.shade800,
                            radius: 16,
                            child: Icon(_getAccountTypeIcon(acc.type), size: 16),
                          ),
                          title: Text(
                            acc.name,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            'Code: ${acc.code} • Type: ${acc.type}',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                          trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: Colors.indigo) : null,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAccountTypeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'ASSET':
        return Icons.account_balance_rounded;
      case 'LIABILITY':
        return Icons.request_quote_rounded;
      case 'EQUITY':
        return Icons.pie_chart_rounded;
      case 'REVENUE':
        return Icons.trending_up_rounded;
      case 'EXPENSE':
        return Icons.trending_down_rounded;
      default:
        return Icons.account_box_rounded;
    }
  }
}
