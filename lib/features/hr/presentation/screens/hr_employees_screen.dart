import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/employees_provider.dart';
import '../../domain/employee_model.dart';
import '../../utils/hr_constants.dart';

// ──────────────────────────────────────────────
// Local filter/sort state
// ──────────────────────────────────────────────
enum _SortField { name, email, salary, status, joiningDate }
enum _SortDir { asc, desc }

class HrEmployeesScreen extends ConsumerStatefulWidget {
  const HrEmployeesScreen({super.key});

  @override
  ConsumerState<HrEmployeesScreen> createState() => _HrEmployeesScreenState();
}

class _HrEmployeesScreenState extends ConsumerState<HrEmployeesScreen> {
  // Search
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // Filter
  String _statusFilter = 'ALL'; // ALL, ACTIVE, INACTIVE, LEFT
  String _paymentFilter = 'ALL'; // ALL, BANK, CASH
  String _departmentFilter = 'ALL';
  String _designationFilter = 'ALL';
  String _shiftFilter = 'ALL';

  // Sort
  _SortField _sortField = _SortField.name;
  _SortDir _sortDir = _SortDir.asc;

  // View
  bool _isGridView = false;

  // Import
  bool _isImporting = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Filtering & sorting logic ──
  List<Employee> _processEmployees(List<Employee> employees) {
    var result = List<Employee>.from(employees);

    // Search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((e) {
        final fullName = '${e.firstName} ${e.lastName}'.toLowerCase();
        final email = (e.email ?? '').toLowerCase();
        final phone = (e.phone ?? '').toLowerCase();
        final nationalId = (e.nationalId ?? '').toLowerCase();
        final dept = (e.departmentName ?? '').toLowerCase();
        final desig = (e.designationName ?? '').toLowerCase();
        return fullName.contains(q) ||
            email.contains(q) ||
            phone.contains(q) ||
            nationalId.contains(q) ||
            dept.contains(q) ||
            desig.contains(q);
      }).toList();
    }

    // Status filter
    if (_statusFilter != 'ALL') {
      result = result.where((e) => e.status == _statusFilter).toList();
    }

    // Payment method filter
    if (_paymentFilter != 'ALL') {
      result = result.where((e) => e.paymentMethod == _paymentFilter).toList();
    }

    // Department filter
    if (_departmentFilter != 'ALL') {
      result = result.where((e) => (e.departmentName ?? '').toLowerCase().contains(_departmentFilter.toLowerCase())).toList();
    }

    // Designation filter
    if (_designationFilter != 'ALL') {
      result = result.where((e) => (e.designationName ?? '').toLowerCase().contains(_designationFilter.toLowerCase())).toList();
    }

    // Shift filter
    if (_shiftFilter != 'ALL') {
      result = result.where((e) => (e.workingHours ?? e.shiftInfo ?? '').toLowerCase().contains(_shiftFilter.toLowerCase())).toList();
    }

    // Sort
    result.sort((a, b) {
      int cmp;
      switch (_sortField) {
        case _SortField.name:
          cmp = '${a.firstName} ${a.lastName}'
              .compareTo('${b.firstName} ${b.lastName}');
        case _SortField.email:
          cmp = (a.email ?? '').compareTo(b.email ?? '');
        case _SortField.salary:
          final sa = double.tryParse(a.basicSalary ?? '0') ?? 0;
          final sb = double.tryParse(b.basicSalary ?? '0') ?? 0;
          cmp = sa.compareTo(sb);
        case _SortField.status:
          cmp = a.status.compareTo(b.status);
        case _SortField.joiningDate:
          cmp = (a.joiningDate ?? '').compareTo(b.joiningDate ?? '');
      }
      return _sortDir == _SortDir.asc ? cmp : -cmp;
    });

    return result;
  }

  // ── CSV Import ──
  Future<void> _importCsv() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      setState(() => _isImporting = true);

      final bytes = result.files.first.bytes;
      if (bytes == null) {
        _showSnackBar('Could not read file', isError: true);
        return;
      }

      final csvString = utf8.decode(bytes);
      final rows = Csv().decode(csvString);

      if (rows.length < 2) {
        _showSnackBar('CSV file must have a header row and at least one data row', isError: true);
        return;
      }

      // Parse header to find column indices
      final header = rows.first.map((e) => e.toString().toLowerCase().trim()).toList();
      final firstNameIdx = header.indexOf('first_name');
      final lastNameIdx = header.indexOf('last_name');

      if (firstNameIdx == -1 || lastNameIdx == -1) {
        _showSnackBar('CSV must have "first_name" and "last_name" columns', isError: true);
        return;
      }

      final emailIdx = header.indexOf('email');
      final phoneIdx = header.indexOf('phone');
      final nationalIdIdx = header.indexOf('national_id');
      final salaryIdx = header.indexOf('basic_salary');
      final paymentIdx = header.indexOf('payment_method');

      final api = ref.read(hrApiProvider);
      int successCount = 0;
      int errorCount = 0;

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        try {
          final body = <String, dynamic>{
            'firstName': row[firstNameIdx].toString(),
            'lastName': row[lastNameIdx].toString(),
          };
          if (emailIdx != -1 && emailIdx < row.length) {
            body['email'] = row[emailIdx].toString();
          }
          if (phoneIdx != -1 && phoneIdx < row.length) {
            body['phone'] = row[phoneIdx].toString();
          }
          if (nationalIdIdx != -1 && nationalIdIdx < row.length) {
            body['nationalId'] = row[nationalIdIdx].toString();
          }
          if (salaryIdx != -1 && salaryIdx < row.length) {
            body['basicSalary'] = row[salaryIdx].toString();
          }
          if (paymentIdx != -1 && paymentIdx < row.length) {
            body['paymentMethod'] = row[paymentIdx].toString();
          }

          await api.createEmployee(body);
          successCount++;
        } catch (_) {
          errorCount++;
        }
      }

      ref.invalidate(employeesProvider);
      _showSnackBar(
        'Imported $successCount employees${errorCount > 0 ? ', $errorCount failed' : ''}',
        isError: errorCount > 0,
      );
    } catch (e) {
      _showSnackBar('Import failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showManageItemsDialog({
    required String title,
    required List<String> items,
    required Function(String) onAdd,
    required Function(String) onDelete,
  }) {
    showDialog(
      context: context,
      builder: (ctx) {
        String query = '';
        final addController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filtered = items.where((i) => i.toLowerCase().contains(query.toLowerCase())).toList();

            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Manage $title (${items.length})'),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              content: SizedBox(
                width: 500,
                height: 450,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: addController,
                            decoration: InputDecoration(
                              hintText: 'New $title name...',
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (addController.text.trim().isNotEmpty) {
                              onAdd(addController.text.trim());
                              addController.clear();
                              setState(() {});
                              setDialogState(() {});
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      onChanged: (val) => setDialogState(() => query = val),
                      decoration: const InputDecoration(
                        hintText: 'Filter existing items...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (ctx, idx) {
                          final item = filtered[idx];
                          return ListTile(
                            dense: true,
                            title: Text(item, style: const TextStyle(fontWeight: FontWeight.w500)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              onPressed: () {
                                onDelete(item);
                                setState(() {});
                                setDialogState(() {});
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(employeesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Top header bar ──
          _buildHeader(theme),

          // ── Filter & sort chips ──
          _buildFilterBar(theme),

          // ── Data area ──
          Expanded(
            child: employeesAsync.when(
              data: (employees) {
                final processed = _processEmployees(employees);
                if (processed.isEmpty && employees.isNotEmpty) {
                  return _buildEmptyFilterResult();
                }
                if (processed.isEmpty) {
                  return _buildEmptyState();
                }
                return _isGridView
                    ? _buildGrid(processed, theme)
                    : _buildDataTable(processed, theme);
              },
              loading: () => _buildLoadingSkeleton(),
              error: (error, _) => _buildErrorState(error),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  // HEADER: title, search, actions
  // ══════════════════════════════════════════
  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Employees',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Consumer(builder: (context, ref, _) {
                      final count = ref.watch(employeesProvider).valueOrNull?.length ?? 0;
                      return Text(
                        '$count total employees',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              // View toggle
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ViewToggleButton(
                      icon: Icons.table_rows_rounded,
                      isActive: !_isGridView,
                      onTap: () => setState(() => _isGridView = false),
                    ),
                    _ViewToggleButton(
                      icon: Icons.grid_view_rounded,
                      isActive: _isGridView,
                      onTap: () => setState(() => _isGridView = true),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Manage Departments
              OutlinedButton.icon(
                onPressed: () => _showManageItemsDialog(
                  title: 'Department',
                  items: HrConstants.departments,
                  onAdd: (n) => HrConstants.addDepartment(n),
                  onDelete: (item) => setState(() => HrConstants.departments.remove(item)),
                ),
                icon: const Icon(Icons.business_rounded, size: 18),
                label: const Text('Manage Depts'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 8),
              // Manage Designations
              OutlinedButton.icon(
                onPressed: () => _showManageItemsDialog(
                  title: 'Designation',
                  items: HrConstants.designations,
                  onAdd: (n) => HrConstants.addDesignation(n),
                  onDelete: (item) => setState(() => HrConstants.designations.remove(item)),
                ),
                icon: const Icon(Icons.work_outline_rounded, size: 18),
                label: const Text('Manage Designations'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 8),
              // Import CSV
              OutlinedButton.icon(
                onPressed: _isImporting ? null : _importCsv,
                icon: _isImporting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload_file_rounded, size: 18),
                label: const Text('Import CSV'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 8),
              // Organogram Chart
              OutlinedButton.icon(
                onPressed: () => context.pushNamed('hrOrganogram'),
                icon: const Icon(Icons.account_tree_rounded, size: 18),
                label: const Text('Organogram'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 8),
              // Add Employee
              FilledButton.icon(
                onPressed: () => context.pushNamed('hrAddEmployee'),
                icon: const Icon(Icons.person_add_alt_rounded, size: 18),
                label: const Text('Add Employee'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Search bar
          SizedBox(
            height: 44,
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search by name, email, phone, or national ID…',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  // FILTER & SORT BAR
  // ══════════════════════════════════════════
  Widget _buildFilterBar(ThemeData theme) {
    final depts = ['ALL', ...HrConstants.departments.map((d) => d.split(' (')[0])];
    final desigs = ['ALL', 'Software Engineer', 'HR Manager', 'Accountant', 'Sales Executive', 'Operations Manager'];
    final shifts = ['ALL', 'Day Shift', 'Morning Shift', 'Evening Shift', 'Night Shift', 'Rotational'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      height: 44,
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Department filter
                  _FilterChip(
                    label: 'Dept: $_departmentFilter',
                    icon: Icons.business,
                    onTap: () {
                      final currentIdx = depts.indexOf(_departmentFilter);
                      setState(() {
                        _departmentFilter = depts[(currentIdx + 1) % depts.length];
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  // Designation filter
                  _FilterChip(
                    label: 'Role: $_designationFilter',
                    icon: Icons.work_outline,
                    onTap: () {
                      final currentIdx = desigs.indexOf(_designationFilter);
                      setState(() {
                        _designationFilter = desigs[(currentIdx + 1) % desigs.length];
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  // Shift filter
                  _FilterChip(
                    label: 'Shift: $_shiftFilter',
                    icon: Icons.access_time,
                    onTap: () {
                      final currentIdx = shifts.indexOf(_shiftFilter);
                      setState(() {
                        _shiftFilter = shifts[(currentIdx + 1) % shifts.length];
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  // Status filter
                  _FilterChip(
                    label: 'Status: $_statusFilter',
                    icon: Icons.circle,
                    iconColor: _statusColor(_statusFilter),
                    onTap: () {
                      final statuses = ['ALL', 'ACTIVE', 'INACTIVE', 'LEFT'];
                      final currentIdx = statuses.indexOf(_statusFilter);
                      setState(() {
                        _statusFilter = statuses[(currentIdx + 1) % statuses.length];
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  // Payment filter
                  _FilterChip(
                    label: 'Payment: $_paymentFilter',
                    icon: Icons.payment_rounded,
                    onTap: () {
                      final methods = ['ALL', 'BANK', 'CASH'];
                      final currentIdx = methods.indexOf(_paymentFilter);
                      setState(() {
                        _paymentFilter = methods[(currentIdx + 1) % methods.length];
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Sort dropdown
          PopupMenuButton<_SortField>(
            onSelected: (field) {
              setState(() {
                if (_sortField == field) {
                  _sortDir = _sortDir == _SortDir.asc
                      ? _SortDir.desc
                      : _SortDir.asc;
                } else {
                  _sortField = field;
                  _sortDir = _SortDir.asc;
                }
              });
            },
            itemBuilder: (_) => [
              _sortMenuItem(_SortField.name, 'Name', Icons.sort_by_alpha_rounded),
              _sortMenuItem(_SortField.email, 'Email', Icons.email_outlined),
              _sortMenuItem(_SortField.salary, 'Salary', Icons.attach_money_rounded),
              _sortMenuItem(_SortField.status, 'Status', Icons.flag_outlined),
              _sortMenuItem(_SortField.joiningDate, 'Joining Date', Icons.calendar_today_rounded),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sort_rounded, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Sort: ${_sortField.name}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _sortDir == _SortDir.asc
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<_SortField> _sortMenuItem(
      _SortField field, String label, IconData icon) {
    final isSelected = _sortField == field;
    return PopupMenuItem(
      value: field,
      child: Row(
        children: [
          Icon(icon, size: 16, color: isSelected ? Theme.of(context).colorScheme.primary : null),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : null)),
          if (isSelected) ...[
            const Spacer(),
            Icon(
              _sortDir == _SortDir.asc
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              size: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ACTIVE': return const Color(0xFF059669);
      case 'INACTIVE': return const Color(0xFFF59E0B);
      case 'LEFT': return const Color(0xFFEF4444);
      default: return const Color(0xFF94A3B8);
    }
  }

  // ══════════════════════════════════════════
  // DATA TABLE VIEW
  // ══════════════════════════════════════════
  Widget _buildDataTable(List<Employee> employees, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            ),
            headingTextStyle: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            dataRowMinHeight: 56,
            dataRowMaxHeight: 56,
            columnSpacing: 24,
            horizontalMargin: 20,
            columns: const [
              DataColumn(label: Text('EMPLOYEE')),
              DataColumn(label: Text('EMAIL')),
              DataColumn(label: Text('PHONE')),
              DataColumn(label: Text('NATIONAL ID')),
              DataColumn(label: Text('SALARY'), numeric: true),
              DataColumn(label: Text('PAYMENT')),
              DataColumn(label: Text('STATUS')),
              DataColumn(label: Text('')),
            ],
            rows: employees.map((emp) {
              return DataRow(
                onSelectChanged: (_) {
                  context.pushNamed(
                    'hrEmployeeDetail',
                    queryParameters: {'id': emp.id},
                  );
                },
                cells: [
                  // Employee name + avatar
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _EmployeeAvatar(employee: emp, size: 34),
                        const SizedBox(width: 10),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${emp.firstName} ${emp.lastName}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            if (emp.joiningDate != null)
                              Text(
                                'Joined ${emp.joiningDate!.split('T').first}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  DataCell(Text(emp.email ?? '—',
                      style: const TextStyle(fontSize: 13))),
                  DataCell(Text(emp.phone ?? '—',
                      style: const TextStyle(fontSize: 13))),
                  DataCell(Text(emp.nationalId ?? '—',
                      style: const TextStyle(fontSize: 13))),
                  DataCell(Text(
                    emp.basicSalary != null
                        ? 'SAR ${double.tryParse(emp.basicSalary!)?.toStringAsFixed(0) ?? emp.basicSalary}'
                        : '—',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  )),
                  DataCell(_PaymentBadge(method: emp.paymentMethod)),
                  DataCell(_StatusBadge(status: emp.status)),
                  DataCell(
                    PopupMenuButton<String>(
                      iconSize: 18,
                      onSelected: (action) {
                        if (action == 'view') {
                          context.pushNamed(
                            'hrEmployeeDetail',
                            queryParameters: {'id': emp.id},
                          );
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'view',
                          child: Row(
                            children: [
                              Icon(Icons.visibility_outlined, size: 16),
                              SizedBox(width: 8),
                              Text('View Details'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════
  // GRID VIEW (cards)
  // ══════════════════════════════════════════
  Widget _buildGrid(List<Employee> employees, ThemeData theme) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 320,
        childAspectRatio: 1.1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final emp = employees[index];
        return _EmployeeCard(
          employee: emp,
          onTap: () {
            context.pushNamed(
              'hrEmployeeDetail',
              queryParameters: {'id': emp.id},
            );
          },
        );
      },
    );
  }

  // ══════════════════════════════════════════
  // LOADING SKELETON
  // ══════════════════════════════════════════
  Widget _buildLoadingSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: List.generate(6, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SkeletonRow(delay: i * 100),
          );
        }),
      ),
    );
  }

  // ══════════════════════════════════════════
  // EMPTY / ERROR STATES
  // ══════════════════════════════════════════
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No employees yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first employee or import from CSV',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton.icon(
                onPressed: _importCsv,
                icon: const Icon(Icons.upload_file_rounded, size: 18),
                label: const Text('Import CSV'),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => context.pushNamed('hrAddEmployee'),
                icon: const Icon(Icons.person_add_alt_rounded, size: 18),
                label: const Text('Add Employee'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFilterResult() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.filter_list_off, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'No employees match your filters',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() {
                _searchController.clear();
                _searchQuery = '';
                _statusFilter = 'ALL';
                _paymentFilter = 'ALL';
              });
            },
            child: const Text('Clear all filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
          const SizedBox(height: 12),
          Text(
            'Failed to load employees',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => ref.invalidate(employeesProvider),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// SUBWIDGETS
// ══════════════════════════════════════════════

// ── Employee Avatar ──
class _EmployeeAvatar extends StatelessWidget {
  final Employee employee;
  final double size;

  const _EmployeeAvatar({required this.employee, this.size = 40});

  Color _colorForName(String name) {
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF059669),
      const Color(0xFFD946EF),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF6366F1),
      const Color(0xFF14B8A6),
      const Color(0xFFF97316),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final initials =
        '${employee.firstName.isNotEmpty ? employee.firstName[0] : ''}${employee.lastName.isNotEmpty ? employee.lastName[0] : ''}'
            .toUpperCase();
    final bgColor = _colorForName('${employee.firstName}${employee.lastName}');

    if (employee.profilePicture != null && employee.profilePicture!.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(employee.profilePicture!),
      );
    }

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: bgColor.withValues(alpha: 0.15),
      child: Text(
        initials,
        style: TextStyle(
          color: bgColor,
          fontSize: size * 0.35,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ── Status Badge ──
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (status) {
      case 'ACTIVE':
        bg = const Color(0xFF059669).withValues(alpha: 0.12);
        fg = const Color(0xFF059669);
      case 'INACTIVE':
        bg = const Color(0xFFF59E0B).withValues(alpha: 0.12);
        fg = const Color(0xFFF59E0B);
      case 'LEFT':
        bg = const Color(0xFFEF4444).withValues(alpha: 0.12);
        fg = const Color(0xFFEF4444);
      default:
        bg = Colors.grey.withValues(alpha: 0.12);
        fg = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Payment Badge ──
class _PaymentBadge extends StatelessWidget {
  final String method;
  const _PaymentBadge({required this.method});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          method == 'BANK' ? Icons.account_balance_rounded : Icons.money_rounded,
          size: 14,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 4),
        Text(method, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

// ── Employee Card (Grid view) ──
class _EmployeeCard extends StatefulWidget {
  final Employee employee;
  final VoidCallback onTap;

  const _EmployeeCard({required this.employee, required this.onTap});

  @override
  State<_EmployeeCard> createState() => _EmployeeCardState();
}

class _EmployeeCardState extends State<_EmployeeCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final emp = widget.employee;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovering
                  ? theme.colorScheme.primary.withValues(alpha: 0.4)
                  : theme.dividerColor,
            ),
            boxShadow: _isHovering
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _EmployeeAvatar(employee: emp, size: 52),
                const SizedBox(height: 12),
                Text(
                  '${emp.firstName} ${emp.lastName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  emp.email ?? 'No email',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatusBadge(status: emp.status),
                    Text(
                      emp.basicSalary != null
                          ? 'SAR ${double.tryParse(emp.basicSalary!)?.toStringAsFixed(0) ?? '-'}'
                          : '',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── View Toggle Button ──
class _ViewToggleButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ViewToggleButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

// ── Filter Chip ──
class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: iconColor ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            Icon(Icons.expand_more_rounded, size: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }
}

// ── Skeleton Loading Row ──
class _SkeletonRow extends StatefulWidget {
  final int delay;
  const _SkeletonRow({this.delay = 0});

  @override
  State<_SkeletonRow> createState() => _SkeletonRowState();
}

class _SkeletonRowState extends State<_SkeletonRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = 0.15 + (_controller.value * 0.15);
        return Container(
          height: 56,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }
}
