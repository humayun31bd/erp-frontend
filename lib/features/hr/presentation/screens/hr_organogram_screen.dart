import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/employees_provider.dart';
import '../../domain/employee_model.dart';
import '../../utils/hr_constants.dart';

class HrOrganogramScreen extends ConsumerStatefulWidget {
  const HrOrganogramScreen({super.key});

  @override
  ConsumerState<HrOrganogramScreen> createState() => _HrOrganogramScreenState();
}

class _HrOrganogramScreenState extends ConsumerState<HrOrganogramScreen> {
  String _selectedDepartment = 'ALL';
  String _searchQuery = '';
  final _searchController = TextEditingController();
  bool _isTreeView = true;
  final Set<String> _collapsedNodes = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleExpand(String id) {
    setState(() {
      if (_collapsedNodes.contains(id)) {
        _collapsedNodes.remove(id);
      } else {
        _collapsedNodes.add(id);
      }
    });
  }

  void _showEmployeeDetails(Employee emp, List<Employee> allEmployees) {
    final directReports = allEmployees.where((e) => e.managerId == emp.id).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                    backgroundImage: (emp.profilePicture != null && emp.profilePicture!.isNotEmpty)
                        ? NetworkImage(emp.profilePicture!)
                        : null,
                    child: (emp.profilePicture == null || emp.profilePicture!.isEmpty)
                        ? Text(emp.firstName.isNotEmpty ? emp.firstName[0].toUpperCase() : 'E',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.primaryColor))
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${emp.firstName} ${emp.lastName}',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('${emp.designationName ?? 'No Title'} • ${emp.departmentName ?? 'General'}',
                            style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        Chip(
                          visualDensity: VisualDensity.compact,
                          backgroundColor: emp.status == 'ACTIVE' ? Colors.green[100] : Colors.amber[100],
                          label: Text(emp.status, style: TextStyle(color: emp.status == 'ACTIVE' ? Colors.green[900] : Colors.amber[900], fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              ListTile(
                dense: true,
                leading: const Icon(Icons.account_tree_outlined),
                title: const Text('Reports To (Direct Manager)'),
                subtitle: Text(emp.managerName ?? 'No Direct Manager (Top Level Executive)'),
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.email),
                title: const Text('Email'),
                subtitle: Text(emp.email ?? 'Not specified'),
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.phone),
                title: const Text('Phone'),
                subtitle: Text(emp.phone ?? 'Not specified'),
              ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.people_outline),
                title: Text('Direct Reports (${directReports.length})'),
                subtitle: directReports.isEmpty
                    ? const Text('No direct reports')
                    : Text(directReports.map((r) => '${r.firstName} ${r.lastName}').join(', ')),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.pushNamed('hrEmployeeDetail', pathParameters: {'id': emp.id});
                      },
                      icon: const Icon(Icons.person),
                      label: const Text('View Full Master Profile'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final employeesAsync = ref.watch(employeesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizational Hierarchy (Organogram)'),
        elevation: 1,
        actions: [
          IconButton(
            tooltip: _isTreeView ? 'Switch to Column View' : 'Switch to Tree View',
            icon: Icon(_isTreeView ? Icons.view_column_rounded : Icons.account_tree_rounded),
            onPressed: () => setState(() => _isTreeView = !_isTreeView),
          ),
          IconButton(
            tooltip: 'Refresh Hierarchy',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(employeesProvider),
          ),
        ],
      ),
      body: employeesAsync.when(
        data: (employees) {
          if (employees.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_tree_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No employees found to generate organogram', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.pushNamed('hrAddEmployee'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Employee'),
                  ),
                ],
              ),
            );
          }

          // Filter by Department & Search
          var filtered = employees;
          if (_selectedDepartment != 'ALL') {
            filtered = filtered
                .where((e) => (e.departmentName ?? '').toLowerCase().contains(_selectedDepartment.toLowerCase()))
                .toList();
          }

          if (_searchQuery.isNotEmpty) {
            final q = _searchQuery.toLowerCase();
            filtered = filtered
                .where((e) =>
                    '${e.firstName} ${e.lastName}'.toLowerCase().contains(q) ||
                    (e.designationName ?? '').toLowerCase().contains(q) ||
                    (e.departmentName ?? '').toLowerCase().contains(q))
                .toList();
          }

          // Build roots (Employees with no manager or manager not in list)
          final employeeIds = employees.map((e) => e.id).toSet();
          final rootEmployees = filtered.where((e) => e.managerId == null || !employeeIds.contains(e.managerId)).toList();

          return Column(
            children: [
              // Header Controls (Search & Filter)
              Container(
                padding: const EdgeInsets.all(16),
                color: theme.cardColor,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) => setState(() => _searchQuery = val),
                            decoration: InputDecoration(
                              hintText: 'Search employee in hierarchy...',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                    )
                                  : null,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<String>(
                          value: _selectedDepartment,
                          underline: const SizedBox(),
                          items: [
                            const DropdownMenuItem(value: 'ALL', child: Text('All Departments')),
                            ...HrConstants.departments.map(
                              (d) => DropdownMenuItem(value: d.split(' (')[0], child: Text(d.split(' (')[0])),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedDepartment = val);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Organogram Canvas / Tree View
              Expanded(
                child: _isTreeView
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ...rootEmployees.map((root) => _buildTreeNode(root, employees, 0)),
                              if (rootEmployees.isEmpty && filtered.isNotEmpty)
                                ...filtered.map((emp) => _buildTreeNode(emp, employees, 0)),
                            ],
                          ),
                        ),
                      )
                    : _buildDepartmentalColumnsView(filtered, theme),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading organogram: $err')),
      ),
    );
  }

  // --- Tree View Node Widget ---
  Widget _buildTreeNode(Employee emp, List<Employee> allEmployees, int level, [Set<String>? visited]) {
    final currentVisited = Set<String>.from(visited ?? <String>{});
    if (currentVisited.contains(emp.id)) {
      // Guard against circular manager relationships (A -> B -> A)
      return const SizedBox();
    }
    currentVisited.add(emp.id);

    final directReports = allEmployees
        .where((e) => e.managerId == emp.id && e.id != emp.id && !currentVisited.contains(e.id))
        .toList();
    final isCollapsed = _collapsedNodes.contains(emp.id);

    return Column(
      children: [
        // Employee Node Card
        GestureDetector(
          onTap: () => _showEmployeeDetails(emp, allEmployees),
          child: Container(
            width: 260,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: level == 0 ? Theme.of(context).primaryColor : Colors.grey[300]!, width: level == 0 ? 2 : 1),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      backgroundImage: (emp.profilePicture != null && emp.profilePicture!.isNotEmpty)
                          ? NetworkImage(emp.profilePicture!)
                          : null,
                      child: (emp.profilePicture == null || emp.profilePicture!.isEmpty)
                          ? Text(emp.firstName.isNotEmpty ? emp.firstName[0].toUpperCase() : 'E',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor))
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${emp.firstName} ${emp.lastName}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            emp.designationName ?? 'No Designation',
                            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      visualDensity: VisualDensity.compact,
                      labelStyle: const TextStyle(fontSize: 10),
                      label: Text(emp.departmentName ?? 'General'),
                      backgroundColor: Colors.blue[50],
                    ),
                    if (directReports.isNotEmpty)
                      GestureDetector(
                        onTap: () => _toggleExpand(emp.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.purple[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(isCollapsed ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up, size: 14, color: Colors.purple),
                              const SizedBox(width: 2),
                              Text('${directReports.length} Reports', style: const TextStyle(fontSize: 10, color: Colors.purple, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Vertical Connecting Line
        if (directReports.isNotEmpty && !isCollapsed) ...[
          Container(width: 2, height: 20, color: Colors.grey[400]),

          // Sub-tree direct reports
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: directReports.map((report) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: _buildTreeNode(report, allEmployees, level + 1, currentVisited),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  // --- Departmental Column View ---
  Widget _buildDepartmentalColumnsView(List<Employee> employees, ThemeData theme) {
    final Map<String, List<Employee>> deptMap = {};
    for (var emp in employees) {
      final dept = emp.departmentName ?? 'Unassigned';
      deptMap.putIfAbsent(dept, () => []).add(emp);
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: deptMap.entries.map((entry) {
        final dept = entry.key;
        final emps = entry.value;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            initiallyExpanded: true,
            leading: const Icon(Icons.business, color: Colors.blue),
            title: Text(dept, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Text('${emps.length} Employees'),
            children: [
              const Divider(height: 1),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: emps.length,
                itemBuilder: (context, idx) {
                  final emp = emps[idx];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: (emp.profilePicture != null && emp.profilePicture!.isNotEmpty)
                          ? NetworkImage(emp.profilePicture!)
                          : null,
                      child: (emp.profilePicture == null || emp.profilePicture!.isEmpty)
                          ? Text(emp.firstName.isNotEmpty ? emp.firstName[0].toUpperCase() : 'E')
                          : null,
                    ),
                    title: Text('${emp.firstName} ${emp.lastName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${emp.designationName ?? 'No Title'}${emp.managerName != null ? ' • Reports to: ${emp.managerName}' : ''}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showEmployeeDetails(emp, employees),
                  );
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
