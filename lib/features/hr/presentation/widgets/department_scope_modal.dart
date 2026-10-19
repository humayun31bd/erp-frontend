import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/employee_model.dart';
import '../../providers/employees_provider.dart';
import '../../utils/hr_constants.dart';

class DepartmentScopeInfo {
  final String key; // 'ALL' or department name
  final String displayName;
  final String code;
  final int activeEmployees;
  final int totalEmployees;
  final IconData icon;
  final Color color;
  final String category;
  final String description;

  const DepartmentScopeInfo({
    required this.key,
    required this.displayName,
    required this.code,
    required this.activeEmployees,
    required this.totalEmployees,
    required this.icon,
    required this.color,
    required this.category,
    required this.description,
  });
}

/// Helper to resolve icon and theme color for department names
Map<String, dynamic> _getDepartmentMeta(String deptName) {
  final lower = deptName.toLowerCase();
  if (lower.contains('human resource') || lower.contains('hr')) {
    return {
      'icon': Icons.badge_rounded,
      'color': Colors.blue.shade700,
      'code': 'HR',
      'category': 'Management',
      'desc': 'Personnel, recruitment & employee benefits',
    };
  } else if (lower.contains('tech') || lower.contains('it') || lower.contains('software')) {
    return {
      'icon': Icons.terminal_rounded,
      'color': Colors.indigo.shade700,
      'code': 'IT',
      'category': 'Technology',
      'desc': 'Software, infrastructure & digital systems',
    };
  } else if (lower.contains('finance') || lower.contains('account')) {
    return {
      'icon': Icons.account_balance_rounded,
      'color': Colors.teal.shade700,
      'code': 'FIN',
      'category': 'Corporate',
      'desc': 'Accounting, financial records & budgeting',
    };
  } else if (lower.contains('sales') || lower.contains('market')) {
    return {
      'icon': Icons.trending_up_rounded,
      'color': Colors.orange.shade800,
      'code': 'SALES',
      'category': 'Commercial',
      'desc': 'Revenue growth, client acquisition & marketing',
    };
  } else if (lower.contains('operat') || lower.contains('logistic') || lower.contains('supply')) {
    return {
      'icon': Icons.local_shipping_rounded,
      'color': Colors.deepPurple.shade700,
      'code': 'OPS',
      'category': 'Operations',
      'desc': 'Logistics, delivery & field coordination',
    };
  } else if (lower.contains('support') || lower.contains('customer') || lower.contains('client')) {
    return {
      'icon': Icons.support_agent_rounded,
      'color': Colors.cyan.shade800,
      'code': 'CS',
      'category': 'Operations',
      'desc': 'Helpdesk, customer relations & assistance',
    };
  } else if (lower.contains('legal') || lower.contains('complian')) {
    return {
      'icon': Icons.gavel_rounded,
      'color': Colors.brown.shade700,
      'code': 'LEGAL',
      'category': 'Governance',
      'desc': 'Contracts, statutory compliance & labor law',
    };
  } else if (lower.contains('admin')) {
    return {
      'icon': Icons.corporate_fare_rounded,
      'color': Colors.blueGrey.shade700,
      'code': 'ADM',
      'category': 'Administration',
      'desc': 'Facilities, office management & supplies',
    };
  } else if (lower.contains('research') || lower.contains('development') || lower.contains('r&d')) {
    return {
      'icon': Icons.science_rounded,
      'color': Colors.pink.shade700,
      'code': 'R&D',
      'category': 'Innovation',
      'desc': 'Product innovation, experiments & patents',
    };
  }

  return {
    'icon': Icons.business_center_rounded,
    'color': Colors.indigo.shade600,
    'code': deptName.length > 3 ? deptName.substring(0, 3).toUpperCase() : deptName.toUpperCase(),
    'category': 'General',
    'desc': 'General business unit & departmental operations',
  };
}

/// Builds full list of DepartmentScopeInfo aggregating active employee data
List<DepartmentScopeInfo> buildDepartmentScopes(List<Employee> employees) {
  // Map of department key to employee list
  final Map<String, List<Employee>> map = {};

  for (final emp in employees) {
    final rawDept = emp.departmentName?.trim() ?? '';
    if (rawDept.isNotEmpty) {
      final cleanDept = rawDept.split(' (')[0].trim();
      map.putIfAbsent(cleanDept, () => []).add(emp);
    }
  }

  // Ensure all standard departments are included even if zero employees
  for (final d in HrConstants.departments) {
    final cleanDept = d.split(' (')[0].trim();
    map.putIfAbsent(cleanDept, () => []);
  }

  final totalActiveCompany = employees.where((e) => e.status.toUpperCase() == 'ACTIVE').length;
  final totalCompany = employees.length;

  final allScope = DepartmentScopeInfo(
    key: 'ALL',
    displayName: 'All Departments (Company-Wide)',
    code: 'ENTERPRISE',
    activeEmployees: totalActiveCompany,
    totalEmployees: totalCompany,
    icon: Icons.domain_rounded,
    color: Colors.indigo.shade800,
    category: 'Enterprise',
    description: 'Process & inspect payroll for all active employees across all company departments.',
  );

  final List<DepartmentScopeInfo> list = [allScope];

  final sortedKeys = map.keys.toList()..sort((a, b) => a.compareTo(b));
  for (final key in sortedKeys) {
    final emps = map[key] ?? [];
    final activeCount = emps.where((e) => e.status.toUpperCase() == 'ACTIVE').length;
    final meta = _getDepartmentMeta(key);

    list.add(DepartmentScopeInfo(
      key: key,
      displayName: key,
      code: meta['code'] as String,
      activeEmployees: activeCount,
      totalEmployees: emps.length,
      icon: meta['icon'] as IconData,
      color: meta['color'] as Color,
      category: meta['category'] as String,
      description: meta['desc'] as String,
    ));
  }

  return list;
}

/// Advanced Department Scope Modal with Search, Filter Chips, Interactive Grid & Quick Selection
class DepartmentScopeModal extends ConsumerStatefulWidget {
  final String currentSelection;
  final ValueChanged<String>? onSelected;

  const DepartmentScopeModal({
    super.key,
    required this.currentSelection,
    this.onSelected,
  });

  static Future<String?> show(BuildContext context, {required String currentSelection}) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => DepartmentScopeModal(currentSelection: currentSelection),
    );
  }

  @override
  ConsumerState<DepartmentScopeModal> createState() => _DepartmentScopeModalState();
}

class _DepartmentScopeModalState extends ConsumerState<DepartmentScopeModal> {
  late String _selectedDept;
  final TextEditingController _searchCtrl = TextEditingController();
  String _activeTabFilter = 'ALL'; // 'ALL', 'ACTIVE_ONLY', 'SORT_SIZE', 'SORT_NAME'
  String _selectedCategory = 'ALL'; // 'ALL' or specific category

  @override
  void initState() {
    super.initState();
    _selectedDept = widget.currentSelection;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<DepartmentScopeInfo> _filterAndSort(List<DepartmentScopeInfo> scopes) {
    final query = _searchCtrl.text.trim().toLowerCase();

    var filtered = scopes.where((s) {
      if (s.key == 'ALL') return true; // Keep Enterprise option readily accessible

      // Text query match
      final matchesSearch = query.isEmpty ||
          s.displayName.toLowerCase().contains(query) ||
          s.code.toLowerCase().contains(query) ||
          s.category.toLowerCase().contains(query) ||
          s.description.toLowerCase().contains(query);

      if (!matchesSearch) return false;

      // Category filter
      if (_selectedCategory != 'ALL' && s.category != _selectedCategory) {
        return false;
      }

      // Active only filter
      if (_activeTabFilter == 'ACTIVE_ONLY' && s.activeEmployees == 0) {
        return false;
      }

      return true;
    }).toList();

    // Sort order
    if (_activeTabFilter == 'SORT_SIZE') {
      filtered.sort((a, b) {
        if (a.key == 'ALL') return -1;
        if (b.key == 'ALL') return 1;
        return b.activeEmployees.compareTo(a.activeEmployees);
      });
    } else if (_activeTabFilter == 'SORT_NAME') {
      filtered.sort((a, b) {
        if (a.key == 'ALL') return -1;
        if (b.key == 'ALL') return 1;
        return a.displayName.compareTo(b.displayName);
      });
    }

    return filtered;
  }

  void _confirmSelection(String key) {
    widget.onSelected?.call(key);
    Navigator.of(context).pop(key);
  }

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(employeesProvider);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isCompact = size.width < 700;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 12,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isCompact ? 16 : 32,
        vertical: isCompact ? 20 : 36,
      ),
      child: Container(
        width: 900,
        height: isCompact ? size.height * 0.9 : 680,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: theme.scaffoldBackgroundColor,
        ),
        child: employeesAsync.when(
          data: (employees) {
            final allScopes = buildDepartmentScopes(employees);
            final filteredScopes = _filterAndSort(allScopes);

            // Extract distinct categories
            final categories = ['ALL', ...allScopes.where((s) => s.key != 'ALL').map((s) => s.category).toSet().toList()..sort()];

            // Currently selected scope info
            final selectedInfo = allScopes.firstWhere(
              (s) => s.key.toLowerCase() == _selectedDept.toLowerCase(),
              orElse: () => allScopes.first,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ══════════════════════════════════════════════════════════════
                // MODAL HEADER
                // ══════════════════════════════════════════════════════════════
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    border: Border(bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.6))),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3F51B5), Color(0xFF673AB7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.indigo.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.corporate_fare_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Text(
                                  'Payroll Engine Scope',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.3),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '• Department Selection',
                                  style: TextStyle(fontSize: 14, color: Colors.indigo, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Select target department scope for payroll calculation, salary components and payslips.',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                        tooltip: 'Close',
                        splashRadius: 20,
                      ),
                    ],
                  ),
                ),

                // ══════════════════════════════════════════════════════════════
                // SEARCH & FILTER TOOLBAR
                // ══════════════════════════════════════════════════════════════
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                  color: theme.cardColor.withValues(alpha: 0.6),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Search field
                          Expanded(
                            child: SizedBox(
                              height: 42,
                              child: TextField(
                                controller: _searchCtrl,
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  hintText: 'Search department name, code, or keyword...',
                                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                                  suffixIcon: _searchCtrl.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear_rounded, size: 18),
                                          onPressed: () => setState(() => _searchCtrl.clear()),
                                        )
                                      : null,
                                  filled: true,
                                  fillColor: theme.scaffoldBackgroundColor,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: theme.dividerColor),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.8)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Quick Reset to Enterprise / All
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedDept = 'ALL';
                                _searchCtrl.clear();
                                _activeTabFilter = 'ALL';
                                _selectedCategory = 'ALL';
                              });
                            },
                            icon: const Icon(Icons.all_inclusive_rounded, size: 16),
                            label: const Text('Reset All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.indigo,
                              side: BorderSide(color: Colors.indigo.withValues(alpha: 0.4)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Filter Pills & Quick Category Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // Filter preset chips
                            _buildFilterChip(
                              label: 'All Departments (${allScopes.length})',
                              isSelected: _activeTabFilter == 'ALL' && _selectedCategory == 'ALL',
                              icon: Icons.grid_view_rounded,
                              onTap: () => setState(() {
                                _activeTabFilter = 'ALL';
                                _selectedCategory = 'ALL';
                              }),
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              label: 'With Active Staff',
                              isSelected: _activeTabFilter == 'ACTIVE_ONLY',
                              icon: Icons.people_alt_rounded,
                              onTap: () => setState(() => _activeTabFilter = _activeTabFilter == 'ACTIVE_ONLY' ? 'ALL' : 'ACTIVE_ONLY'),
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              label: 'Sort by Headcount',
                              isSelected: _activeTabFilter == 'SORT_SIZE',
                              icon: Icons.sort_rounded,
                              onTap: () => setState(() => _activeTabFilter = _activeTabFilter == 'SORT_SIZE' ? 'ALL' : 'SORT_SIZE'),
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              label: 'Sort A-Z',
                              isSelected: _activeTabFilter == 'SORT_NAME',
                              icon: Icons.sort_by_alpha_rounded,
                              onTap: () => setState(() => _activeTabFilter = _activeTabFilter == 'SORT_NAME' ? 'ALL' : 'SORT_NAME'),
                            ),
                            if (categories.length > 2) ...[
                              Container(
                                height: 20,
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                width: 1,
                                color: Colors.grey.shade300,
                              ),
                              // Category chips
                              ...categories.where((c) => c != 'ALL').map((cat) => Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: _buildCategoryChip(
                                  label: cat,
                                  isSelected: _selectedCategory == cat,
                                  onTap: () => setState(() {
                                    _selectedCategory = _selectedCategory == cat ? 'ALL' : cat;
                                  }),
                                ),
                              )),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // ══════════════════════════════════════════════════════════════
                // GRID OF DEPARTMENT SCOPE CARDS
                // ══════════════════════════════════════════════════════════════
                Expanded(
                  child: filteredScopes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_rounded, size: 54, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text('No departments found matching "${_searchCtrl.text}"',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                              const SizedBox(height: 6),
                              Text('Try adjusting your search terms or filters',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => setState(() {
                                  _searchCtrl.clear();
                                  _activeTabFilter = 'ALL';
                                  _selectedCategory = 'ALL';
                                }),
                                child: const Text('Clear Filters'),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(18),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isCompact ? 1 : (size.width > 1050 ? 3 : 2),
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            mainAxisExtent: 130,
                          ),
                          itemCount: filteredScopes.length,
                          itemBuilder: (context, index) {
                            final scope = filteredScopes[index];
                            final isSelected = _selectedDept.toLowerCase() == scope.key.toLowerCase();
                            return _buildScopeCard(scope, isSelected, theme);
                          },
                        ),
                ),

                const Divider(height: 1),

                // ══════════════════════════════════════════════════════════════
                // MODAL FOOTER
                // ══════════════════════════════════════════════════════════════
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      // Selected badge preview
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: selectedInfo.color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(selectedInfo.icon, size: 18, color: selectedInfo.color),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      const Text('Active Selection: ',
                                          style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                                      Flexible(
                                        child: Text(
                                          selectedInfo.displayName,
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    selectedInfo.key == 'ALL'
                                        ? '${selectedInfo.activeEmployees} Total active company employees included'
                                        : '${selectedInfo.activeEmployees} active staff in this department',
                                    style: TextStyle(fontSize: 11, color: selectedInfo.color, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Cancel
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        ),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),

                      // Apply Button
                      ElevatedButton.icon(
                        onPressed: () => _confirmSelection(_selectedDept),
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text('Apply Department Scope', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading department workforce data...', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text('Failed to load department metrics: $err'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(employeesProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SCOPE CARD WIDGET
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildScopeCard(DepartmentScopeInfo scope, bool isSelected, ThemeData theme) {
    final isEnterprise = scope.key == 'ALL';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() => _selectedDept = scope.key);
        },
        onDoubleTap: () => _confirmSelection(scope.key),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: isSelected
                ? (isEnterprise ? Colors.indigo.shade50 : scope.color.withValues(alpha: 0.08))
                : theme.cardColor,
            border: Border.all(
              color: isSelected
                  ? (isEnterprise ? Colors.indigo : scope.color)
                  : theme.dividerColor.withValues(alpha: 0.7),
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: (isEnterprise ? Colors.indigo : scope.color).withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top row: Icon + Code/Category + Radio/Check Icon
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isEnterprise
                          ? Colors.indigo
                          : (isSelected ? scope.color : scope.color.withValues(alpha: 0.12)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      scope.icon,
                      size: 20,
                      color: isEnterprise ? Colors.white : (isSelected ? Colors.white : scope.color),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: (isSelected ? scope.color : Colors.grey.shade400).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                scope.code,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? scope.color : Colors.grey.shade700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              scope.category,
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          scope.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? (isEnterprise ? Colors.indigo.shade900 : scope.color) : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Checked indicator
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? (isEnterprise ? Colors.indigo : scope.color) : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? (isEnterprise ? Colors.indigo : scope.color)
                            : Colors.grey.shade400,
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ],
              ),

              // Bottom row: Metrics (Active staff count & Description)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: scope.activeEmployees > 0
                          ? Colors.green.shade50
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: scope.activeEmployees > 0
                            ? Colors.green.shade200
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person,
                          size: 13,
                          color: scope.activeEmployees > 0 ? Colors.green.shade700 : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${scope.activeEmployees} Active',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: scope.activeEmployees > 0 ? Colors.green.shade800 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isEnterprise)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Enterprise All',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                    )
                  else
                    Text(
                      'Double-click to apply',
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade400, fontStyle: FontStyle.italic),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CHIP HELPERS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.indigo : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.indigo : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? Colors.white : Colors.grey.shade700),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.deepPurple : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

/// A premium, interactive Department Scope Selection Display Card for the Initial Parameters Screen
class DepartmentScopeSelectionCard extends ConsumerWidget {
  final String selectedDepartment;
  final ValueChanged<String> onDepartmentChanged;

  const DepartmentScopeSelectionCard({
    super.key,
    required this.selectedDepartment,
    required this.onDepartmentChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesAsync = ref.watch(employeesProvider);
    final theme = Theme.of(context);

    return employeesAsync.when(
      data: (employees) {
        final allScopes = buildDepartmentScopes(employees);
        final selectedInfo = allScopes.firstWhere(
          (s) => s.key.toLowerCase() == selectedDepartment.toLowerCase(),
          orElse: () => allScopes.first,
        );

        final isEnterprise = selectedInfo.key == 'ALL';

        return InkWell(
          onTap: () async {
            final picked = await DepartmentScopeModal.show(context, currentSelection: selectedDepartment);
            if (picked != null) {
              onDepartmentChanged(picked);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isEnterprise
                  ? Colors.indigo.shade50.withValues(alpha: 0.5)
                  : selectedInfo.color.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isEnterprise
                    ? Colors.indigo.withValues(alpha: 0.4)
                    : selectedInfo.color.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                // Icon Avatar
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isEnterprise ? Colors.indigo : selectedInfo.color,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (isEnterprise ? Colors.indigo : selectedInfo.color).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(selectedInfo.icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Department Scope: ',
                            style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (isEnterprise ? Colors.indigo : selectedInfo.color).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              selectedInfo.code,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isEnterprise ? Colors.indigo : selectedInfo.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedInfo.displayName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isEnterprise ? Colors.indigo.shade900 : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.group_rounded,
                            size: 14,
                            color: isEnterprise ? Colors.indigo : selectedInfo.color,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isEnterprise
                                ? '${selectedInfo.activeEmployees} active employees enterprise-wide'
                                : '${selectedInfo.activeEmployees} active staff in this department',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isEnterprise ? Colors.indigo.shade700 : selectedInfo.color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Change Scope Button Action
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.dividerColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_rounded, size: 16, color: Colors.indigo),
                      SizedBox(width: 6),
                      Text(
                        'Change Scope',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_right_rounded, size: 16, color: Colors.indigo),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Container(
        height: 80,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, __) => ListTile(
        title: Text(selectedDepartment == 'ALL' ? 'ALL Departments' : selectedDepartment),
        trailing: const Icon(Icons.arrow_drop_down),
      ),
    );
  }
}
