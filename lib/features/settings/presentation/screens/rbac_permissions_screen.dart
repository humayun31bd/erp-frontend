import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RbacPermissionsScreen extends ConsumerStatefulWidget {
  const RbacPermissionsScreen({super.key});

  @override
  ConsumerState<RbacPermissionsScreen> createState() => _RbacPermissionsScreenState();
}

class _RbacPermissionsScreenState extends ConsumerState<RbacPermissionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedRole = 'MAKER';

  // 8 Core Enterprise Roles
  final List<String> _roles = [
    'Sys Admin',
    'MAKER',
    'CHECKER',
    'APPROVER',
    'Budget Off.',
    'Int. Auditor',
    'Ext. Auditor',
    'Mgmt (DG)',
  ];

  // Modules & Permissions Map: moduleKey -> { C: bool, R: bool, U: bool, A: bool, P: bool }
  final Map<String, Map<String, Map<String, bool>>> _matrixPermissions = {
    'MAKER': {
      'Vouchers & General Ledger (PV, RV, JV, CV)': {'C': true, 'R': true, 'U': true, 'A': false, 'P': false},
      'Chart of Accounts & Mappings': {'C': false, 'R': true, 'U': false, 'A': false, 'P': false},
      'POS Checkout & Sales Invoices': {'C': true, 'R': true, 'U': true, 'A': false, 'P': false},
      'Purchases & Vendor Bills': {'C': true, 'R': true, 'U': true, 'A': false, 'P': false},
      'Inventory Stock Management': {'C': false, 'R': true, 'U': false, 'A': false, 'P': false},
      'HR & Payroll Management': {'C': true, 'R': true, 'U': false, 'A': false, 'P': false},
      'Financial Years & Period Lock': {'C': false, 'R': true, 'U': false, 'A': false, 'P': false},
      'Financial Reports & Auditor Portal': {'C': false, 'R': true, 'U': false, 'A': false, 'P': false},
    },
    'CHECKER': {
      'Vouchers & General Ledger (PV, RV, JV, CV)': {'C': false, 'R': true, 'U': true, 'A': true, 'P': false},
      'Chart of Accounts & Mappings': {'C': false, 'R': true, 'U': false, 'A': false, 'P': false},
      'POS Checkout & Sales Invoices': {'C': false, 'R': true, 'U': false, 'A': true, 'P': false},
      'Purchases & Vendor Bills': {'C': false, 'R': true, 'U': true, 'A': true, 'P': false},
      'Inventory Stock Management': {'C': false, 'R': true, 'U': false, 'A': false, 'P': false},
      'HR & Payroll Management': {'C': false, 'R': true, 'U': true, 'A': true, 'P': false},
      'Financial Years & Period Lock': {'C': false, 'R': true, 'U': false, 'A': false, 'P': false},
      'Financial Reports & Auditor Portal': {'C': false, 'R': true, 'U': false, 'A': false, 'P': false},
    },
    'APPROVER': {
      'Vouchers & General Ledger (PV, RV, JV, CV)': {'C': false, 'R': true, 'U': false, 'A': true, 'P': true},
      'Chart of Accounts & Mappings': {'C': true, 'R': true, 'U': true, 'A': true, 'P': true},
      'POS Checkout & Sales Invoices': {'C': false, 'R': true, 'U': false, 'A': true, 'P': true},
      'Purchases & Vendor Bills': {'C': false, 'R': true, 'U': false, 'A': true, 'P': true},
      'Inventory Stock Management': {'C': true, 'R': true, 'U': true, 'A': true, 'P': true},
      'HR & Payroll Management': {'C': false, 'R': true, 'U': false, 'A': true, 'P': true},
      'Financial Years & Period Lock': {'C': false, 'R': true, 'U': false, 'A': true, 'P': true},
      'Financial Reports & Auditor Portal': {'C': false, 'R': true, 'U': false, 'A': true, 'P': true},
    },
  };

  // User Role Assignments
  final List<Map<String, String>> _usersList = [
    {'email': 'accounts@shaplamart.com', 'role': 'TENANT_ADMIN', 'name': 'Finance Lead (Shapla Supermarket)'},
    {'email': 'maker-1@shaplamart.com', 'role': 'MAKER', 'name': 'Voucher Data Entry Officer'},
    {'email': 'checker-1@shaplamart.com', 'role': 'CHECKER', 'name': 'Accounting Verification Officer'},
    {'email': 'approver-1@shaplamart.com', 'role': 'APPROVER', 'name': 'CFO & Financial Approver'},
    {'email': 'auditor-1@shaplamart.com', 'role': 'INTERNAL_AUDITOR', 'name': 'Internal Compliance Auditor'},
    {'email': 'cashier-1@shaplamart.com', 'role': 'TENANT_USER', 'name': 'Dhanmondi POS Cashier'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Banner
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF2563EB), size: 28),
                        SizedBox(width: 10),
                        Text(
                          'Role-Based Access Control (RBAC) & Menu Permissions',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Configure granular C/R/U/A/P module permissions matrix & assign enterprise roles to users.',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  icon: const Icon(Icons.save_rounded, size: 18),
                  label: const Text('Save Permission Policy'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('RBAC Menu Permission Policy saved & applied across all user sessions!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Tabs Header
          Container(
            color: Colors.grey.shade50,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue.shade800,
              unselectedLabelColor: Colors.grey.shade700,
              indicatorColor: Colors.blue.shade800,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(icon: Icon(Icons.grid_on_rounded, size: 18), text: 'RBAC Permission Matrix (C/R/U/A/P)'),
                Tab(icon: Icon(Icons.manage_accounts_rounded, size: 18), text: 'User Role Assignments'),
              ],
            ),
          ),
          const Divider(height: 1),

          // Tab Body
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPermissionMatrixTab(),
                _buildUserAssignmentsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // TAB 1: PERMISSION MATRIX (C/R/U/A/P)
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildPermissionMatrixTab() {
    final Map<String, Map<String, bool>> rolePerms = _matrixPermissions[_selectedRole] ?? _matrixPermissions['MAKER']!;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Role Selection & Presets Toolbar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('Select Role to Configure: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedRole,
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                        items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedRole = val;
                              if (!_matrixPermissions.containsKey(val)) {
                                _matrixPermissions[val] = {
                                  'Vouchers & General Ledger (PV, RV, JV, CV)': {'C': false, 'R': true, 'U': false, 'A': false, 'P': false},
                                  'Chart of Accounts & Mappings': {'C': false, 'R': true, 'U': false, 'A': false, 'P': false},
                                  'POS Checkout & Sales Invoices': {'C': false, 'R': true, 'U': false, 'A': false, 'P': false},
                                  'Purchases & Vendor Bills': {'C': false, 'R': true, 'U': false, 'A': false, 'P': false},
                                  'Inventory Stock Management': {'C': false, 'R': true, 'U': false, 'A': false, 'P': false},
                                  'HR & Payroll Management': {'C': false, 'R': true, 'U': false, 'A': false, 'P': false},
                                  'Financial Years & Period Lock': {'C': false, 'R': true, 'U': false, 'A': false, 'P': false},
                                  'Financial Reports & Auditor Portal': {'C': false, 'R': true, 'U': false, 'A': false, 'P': false},
                                };
                              }
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),

              // Presets Toolbar
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _applyPreset('MAKER'),
                    icon: const Icon(Icons.edit_note_rounded, size: 16),
                    label: const Text('Maker Preset'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _applyPreset('CHECKER'),
                    icon: const Icon(Icons.rule_rounded, size: 16),
                    label: const Text('Checker Preset'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _applyPreset('APPROVER'),
                    icon: const Icon(Icons.verified_user_rounded, size: 16),
                    label: const Text('Approver Preset'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _applyPreset('AUDITOR'),
                    icon: const Icon(Icons.find_in_page_rounded, size: 16),
                    label: const Text('Auditor (Read-Only)'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Legend
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 18),
                SizedBox(width: 8),
                Text(
                  'C = Create Draft  |  R = Read/View  |  U = Update Draft  |  A = Checker Approve  |  P = Post / Period Lock',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Permission Matrix Data Table
          Expanded(
            child: SingleChildScrollView(
              child: Table(
                border: TableBorder.all(color: Colors.grey.shade300, width: 1),
                columnWidths: const {
                  0: FlexColumnWidth(4),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                  3: FlexColumnWidth(1),
                  4: FlexColumnWidth(1),
                  5: FlexColumnWidth(1),
                },
                children: [
                  // Table Header
                  TableRow(
                    decoration: BoxDecoration(color: Colors.blue.shade900),
                    children: const [
                      Padding(padding: EdgeInsets.all(10), child: Text('System Module / Menu Access', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      Padding(padding: EdgeInsets.all(10), child: Text('C (Create)', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      Padding(padding: EdgeInsets.all(10), child: Text('R (Read)', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      Padding(padding: EdgeInsets.all(10), child: Text('U (Update)', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      Padding(padding: EdgeInsets.all(10), child: Text('A (Approve)', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      Padding(padding: EdgeInsets.all(10), child: Text('P (Post)', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    ],
                  ),
                  // Rows
                  ...rolePerms.entries.map((entry) {
                    final moduleName = entry.key;
                    final perms = entry.value;

                    return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(moduleName, style: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        _buildCheckboxCell(perms, 'C'),
                        _buildCheckboxCell(perms, 'R'),
                        _buildCheckboxCell(perms, 'U'),
                        _buildCheckboxCell(perms, 'A'),
                        _buildCheckboxCell(perms, 'P'),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxCell(Map<String, bool> perms, String key) {
    return Center(
      child: Checkbox(
        value: perms[key] ?? false,
        activeColor: Colors.blue.shade700,
        onChanged: (val) {
          setState(() {
            perms[key] = val ?? false;
          });
        },
      ),
    );
  }

  void _applyPreset(String presetType) {
    setState(() {
      final perms = _matrixPermissions[_selectedRole] ?? {};
      if (presetType == 'MAKER') {
        perms.forEach((key, val) {
          val['C'] = true;
          val['R'] = true;
          val['U'] = true;
          val['A'] = false;
          val['P'] = false;
        });
      } else if (presetType == 'CHECKER') {
        perms.forEach((key, val) {
          val['C'] = false;
          val['R'] = true;
          val['U'] = true;
          val['A'] = true;
          val['P'] = false;
        });
      } else if (presetType == 'APPROVER') {
        perms.forEach((key, val) {
          val['C'] = false;
          val['R'] = true;
          val['U'] = false;
          val['A'] = true;
          val['P'] = true;
        });
      } else if (presetType == 'AUDITOR') {
        perms.forEach((key, val) {
          val['C'] = false;
          val['R'] = true;
          val['U'] = false;
          val['A'] = false;
          val['P'] = false;
        });
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Applied "$presetType" permission preset for $_selectedRole')),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // TAB 2: USER ROLE ASSIGNMENTS
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildUserAssignmentsTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('User Account Role Assignments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Assign enterprise RBAC security profiles to registered system users.', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _usersList.length,
              itemBuilder: (context, index) {
                final u = _usersList[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(u['email']![0].toUpperCase(), style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(u['email']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(u['name']!),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: u['role'],
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900, fontSize: 13),
                          items: [
                            'SUPERADMIN',
                            'TENANT_ADMIN',
                            'MAKER',
                            'CHECKER',
                            'APPROVER',
                            'BUDGET_OFFICER',
                            'INTERNAL_AUDITOR',
                            'TENANT_USER',
                          ].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                u['role'] = val;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Updated ${u['email']} role to $val')),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
