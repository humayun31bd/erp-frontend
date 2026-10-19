import 'package:flutter/material.dart';

class CoaHelpModal extends StatefulWidget {
  const CoaHelpModal({super.key});

  @override
  State<CoaHelpModal> createState() => _CoaHelpModalState();
}

class _CoaHelpModalState extends State<CoaHelpModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 820,
        height: 660,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.account_tree_rounded, color: Color(0xFF4361EE), size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Chart of Accounts (COA) Training Manual',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF4361EE),
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: const Color(0xFF4361EE),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(icon: Icon(Icons.format_list_numbered_rounded, size: 18), text: '5-Level Hierarchy'),
                Tab(icon: Icon(Icons.space_dashboard_outlined, size: 18), text: 'Panels & Controls'),
                Tab(icon: Icon(Icons.school_outlined, size: 18), text: 'Step-by-Step Examples'),
                Tab(icon: Icon(Icons.keyboard_outlined, size: 18), text: 'Shortcuts & Rules'),
              ],
            ),
            const Divider(height: 1),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildHierarchyTab(),
                  _buildPanelsTab(),
                  _buildExamplesTab(),
                  _buildShortcutsTab(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Intelligent ERP Accounting Standard • IFRS / GAAP Compliant',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Got It! Return to COA'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4361EE),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // ── Tab 1: 5-Level Hierarchy ──
  Widget _buildHierarchyTab() {
    final levels = [
      {'level': 'Level 1', 'name': 'Account Class', 'code': '1 .. 5', 'desc': '1 Assets, 2 Liabilities, 3 Equity, 4 Revenue, 5 Expenses.', 'canPost': 'No'},
      {'level': 'Level 2', 'name': 'Account Group', 'code': 'X.XX', 'desc': '1.10 Current Assets, 4.10 Sales Revenue.', 'canPost': 'No'},
      {'level': 'Level 3', 'name': 'Account Category', 'code': 'X.XX.XX', 'desc': '1.10.01 Cash & Bank, 2.10.02 VAT Payable.', 'canPost': 'No'},
      {'level': 'Level 4', 'name': 'Control Account', 'code': 'X.XX.XX.XXX', 'desc': '1.10.01.001 Cash on Hand, 4.10.01.001 In-Store Sales.', 'canPost': 'No'},
      {'level': 'Level 5', 'name': 'Sub-Account / Detail', 'code': 'X.XX.XX.XXX.XXX', 'desc': '1.10.01.001.001 Petty Cash - Dhanmondi Outlet.', 'canPost': 'YES (Txn)'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border.all(color: Colors.blue.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade800, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Core Rule: Only Level 5 Detail accounts with "Is Transaction = True" receive direct Journal Voucher postings. Levels 1–3 act as reporting roll-up parents.',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blue.shade900),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          DataTable(
            headingRowHeight: 36,
            dataRowMaxHeight: 52,
            columns: const [
              DataColumn(label: Text('Level', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Name & Code Format', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Description & Example', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Can Post JVs?', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: levels.map((l) {
              final isTxn = l['canPost'] == 'YES (Txn)';
              return DataRow(cells: [
                DataCell(Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isTxn ? Colors.green.shade50 : Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(l['level']!, style: TextStyle(fontWeight: FontWeight.bold, color: isTxn ? Colors.green.shade900 : Colors.indigo.shade900)),
                )),
                DataCell(Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('Code: ${l['code']}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontFamily: 'monospace')),
                  ],
                )),
                DataCell(Text(l['desc']!, style: TextStyle(fontSize: 12, color: Colors.grey.shade800))),
                DataCell(Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isTxn ? Colors.green.shade100 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(l['canPost']!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isTxn ? Colors.green.shade900 : Colors.grey.shade700)),
                )),
              ]);
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Tab 2: Panels & Controls ──
  Widget _buildPanelsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardSection(
            icon: Icons.account_tree_outlined,
            title: '1. Left Panel: Accounts Tree View',
            description: 'Displays all accounts organized under 5 Root Folders: ASSET (Green), LIABILITY (Amber), EQUITY (Purple), REVENUE (Blue), EXPENSE (Red). Indicates node depth and Txn status.',
          ),
          _buildCardSection(
            icon: Icons.edit_note_rounded,
            title: '2. Right Panel: Account Details & Edit Form',
            description: 'Displays 2-column form: Account Name, Account Type, Parent Account, Account Classification (Fixed Asset, Inventory, Receivables, Payables, Bank, Cash, Cost Center), and Toggles.',
          ),
          _buildCardSection(
            icon: Icons.toggle_on_outlined,
            title: '3. Classification & Feature Toggles',
            description: 'Is Active (enables system use), Is Transaction (allows GL postings), Is Cash Nature (enables Cash Book filtering), Is Bank Nature (enables Cheque Leaf & Bank Reconciliation).',
          ),
          _buildCardSection(
            icon: Icons.add_circle_outline_rounded,
            title: '4. Action Buttons (Add Sub-Account, Save, Delete)',
            description: 'Click "+ Add Account" on header to add root/group accounts. Click "Add Sub-Account" on right form footer to auto-calculate parent ID and next sequential code.',
          ),
        ],
      ),
    );
  }

  // ── Tab 3: Step-by-Step Examples ──
  Widget _buildExamplesTab() {
    final examples = [
      {
        'title': 'Example 1: Creating Level 5 Petty Cash Account',
        'steps': '1. Click ASSET → Current Assets (1.10) → Cash & Bank (1.10.01) → Cash on Hand (1.10.01.001).\n2. Click "Add Sub-Account" at bottom right.\n3. Enter Name: "Petty Cash - Dhanmondi Outlet". Classification: CASH.\n4. Enable "Is Transaction" & "Is Cash Nature". Click Save Account!',
      },
      {
        'title': 'Example 2: Creating Level 5 Sales Revenue Account',
        'steps': '1. Click REVENUE → Sales Revenue (4.10) → Merchandise Sales (4.10.01) → In-Store Sales (4.10.01.001).\n2. Click "Add Sub-Account". Auto code: 4.10.01.001.001.\n3. Enter Name: "Sales – Beverages".\n4. Enable "Is Transaction". Click Save Account!',
      },
      {
        'title': 'Example 3: Creating Operating Bank Account with Cheque Support',
        'steps': '1. Click ASSET → Current Assets (1.10) → Cash & Bank (1.10.01) → Bank Accounts (1.10.01.002).\n2. Click "Add Sub-Account". Auto code: 1.10.01.002.001.\n3. Enter Name: "DBBL Operating A/C #11029384". Classification: BANK.\n4. Enable "Is Transaction" & "Is Bank Nature". Click Save Account!',
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: examples.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final ex = examples[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.indigo.shade50.withValues(alpha: 0.5),
            border: Border.all(color: Colors.indigo.shade100),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.indigo.shade700, size: 20),
                  const SizedBox(width: 8),
                  Text(ex['title']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.indigo.shade900)),
                ],
              ),
              const SizedBox(height: 8),
              Text(ex['steps']!, style: TextStyle(fontSize: 12.5, color: Colors.grey.shade800, height: 1.5)),
            ],
          ),
        );
      },
    );
  }

  // ── Tab 4: Shortcuts & Rules ──
  Widget _buildShortcutsTab() {
    final shortcuts = [
      {'key': 'F1', 'action': 'Filter / Search Accounts Tree'},
      {'key': 'F2', 'action': 'Expand All / Collapse All Tree Nodes'},
      {'key': 'F3', 'action': 'Add New Sub-Account under selected parent'},
      {'key': 'Ctrl + S / F12', 'action': 'Save Account Changes'},
      {'key': 'Esc', 'action': 'Cancel Creation / Close Modal'},
      {'key': 'Up / Down Arrows', 'action': 'Navigate Tree Items'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Keyboard Shortcuts Reference', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A1F36))),
          const SizedBox(height: 10),
          DataTable(
            headingRowHeight: 36,
            dataRowMaxHeight: 40,
            columns: const [
              DataColumn(label: Text('Shortcut Key', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Action / Function', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: shortcuts.map((s) {
              return DataRow(cells: [
                DataCell(Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    border: Border.all(color: Colors.indigo.shade200),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(s['key']!, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade900, fontFamily: 'monospace')),
                )),
                DataCell(Text(s['action']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
              ]);
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text('Account Safety Rules', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A1F36))),
          const SizedBox(height: 8),
          _buildRuleBullet('Code Uniqueness', 'Account codes are auto-calculated to maintain mathematical hierarchy and prevent duplicate numbering.'),
          _buildRuleBullet('Parent Matching', 'Level N sub-accounts can only be assigned under Level N-1 parent accounts of the same Account Class.'),
          _buildRuleBullet('Delete Protection', 'Accounts with existing child accounts or posted JVs cannot be deleted. Deactivate them by unchecking "Is Active".'),
        ],
      ),
    );
  }

  Widget _buildRuleBullet(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 12.5, color: Colors.grey.shade800, height: 1.4),
                children: [
                  TextSpan(text: '$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: desc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSection({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50.withValues(alpha: 0.5),
        border: Border.all(color: Colors.indigo.shade100),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF4361EE), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1F36))),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(fontSize: 12, color: Colors.grey.shade800, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
