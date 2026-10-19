import 'package:flutter/material.dart';

class VouchersHelpModal extends StatefulWidget {
  const VouchersHelpModal({super.key});

  @override
  State<VouchersHelpModal> createState() => _VouchersHelpModalState();
}

class _VouchersHelpModalState extends State<VouchersHelpModal>
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
                    Icon(Icons.receipt_long_rounded, color: Color(0xFF2563EB), size: 28),
                    SizedBox(width: 12),
                    Text(
                      'General Ledger Vouchers Training Manual',
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
              labelColor: const Color(0xFF2563EB),
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: const Color(0xFF2563EB),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(icon: Icon(Icons.style_outlined, size: 18), text: 'Voucher Types (RV,PV,CV,JV)'),
                Tab(icon: Icon(Icons.space_dashboard_outlined, size: 18), text: 'Panels & Controls'),
                Tab(icon: Icon(Icons.school_outlined, size: 18), text: 'Step-by-Step Examples'),
                Tab(icon: Icon(Icons.keyboard_outlined, size: 18), text: 'Shortcuts & Audit Rules'),
              ],
            ),
            const Divider(height: 1),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTypesTab(),
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
                  'Intelligent ERP Accounting Standard • Maker-Checker & Outbox Sync Enabled',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Got It! Return to Vouchers'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
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

  // ── Tab 1: Voucher Types ──
  Widget _buildTypesTab() {
    final types = [
      {'type': 'Receipt Voucher (RV)', 'code': 'RV', 'desc': 'Money received into Cash or Bank (Customer AR collections, retail sales, capital additions).', 'route': 'Header: Cash/Bank (DEBIT) | Lines: Revenue / Customer AR (CREDIT)'},
      {'type': 'Payment Voucher (PV)', 'code': 'PV', 'desc': 'Money paid out from Cash or Bank (Vendor payments, expenses, payroll, NBR TDS/VDS deductions).', 'route': 'Header: Cash/Bank (CREDIT) | Lines: Expense / Vendor AP (DEBIT)'},
      {'type': 'Contra Voucher (CV)', 'code': 'CV', 'desc': 'Internal transfers between Cash & Bank (Vault deposits, ATM cash withdrawals). Requires Header Account != Line Account.', 'route': 'Header: Cash/Bank (DEBIT - Receiving) | Lines: Cash/Bank (CREDIT - Transferring)'},
      {'type': 'Journal Voucher (JV)', 'code': 'JV', 'desc': 'Non-cash adjustments & accruals (Managed under dedicated Journal Entries screen).', 'route': 'Lines: Expense/Asset (DEBIT) | Lines: Acc. Dep / Income (CREDIT)'},
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
                Icon(Icons.gavel_rounded, color: Colors.blue.shade800, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Double-Entry Rules: PV Header is Credit (Lines Debit); RV Header is Debit (Lines Credit); CV Header is Debit (Lines Credit). Contra Vouchers block selecting the same Cash/Bank account.',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blue.shade900),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          DataTable(
            headingRowHeight: 36,
            dataRowMaxHeight: 64,
            columns: const [
              DataColumn(label: Text('Voucher Type', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Description & Usage', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Default Account Routing', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: types.map((t) {
              return DataRow(cells: [
                DataCell(Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(t['type']!, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
                )),
                DataCell(Text(t['desc']!, style: TextStyle(fontSize: 12, color: Colors.grey.shade800))),
                DataCell(Text(t['route']!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade900, fontFamily: 'monospace'))),
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
            icon: Icons.tab_rounded,
            title: '1. Top Voucher Type Selector & Sync Status Panel',
            description: 'Selects active voucher mode (RV, PV, CV, JV). Shows offline/online sync state (SYNCED, PENDING, SYNCING) and unpushed outbox item count.',
          ),
          _buildCardSection(
            icon: Icons.edit_note_rounded,
            title: '2. Voucher Header Form Panel',
            description: 'Displays Auto Voucher #, Date, Fiscal Year, Period #, Cost Center tag, Cheque Leaf Reference (auto-selects next AVAILABLE leaf), Payee Name, and Narration.',
          ),
          _buildCardSection(
            icon: Icons.table_chart_outlined,
            title: '3. Double-Entry Lines & Live Balance Indicator',
            description: 'Selects Level 5 CoA transaction accounts, Branch tags, Debit (৳), Credit (৳). Live Balance Indicator widget shows BALANCED (৳0.00 Diff) or UNBALANCED (৳X Diff).',
          ),
          _buildCardSection(
            icon: Icons.print_outlined,
            title: '4. Action Buttons (Preview, Print PDF, Approve)',
            description: 'Click Live Preview (👁️) to inspect formatted voucher. Click Print PDF (🖨️) to export printable tax voucher with 4-tier signature block.',
          ),
        ],
      ),
    );
  }

  // ── Tab 3: Step-by-Step Examples ──
  Widget _buildExamplesTab() {
    final examples = [
      {
        'title': 'Example 1: Payment Voucher (PV) with NBR Tax (TDS/VDS) Auto-Deduction',
        'steps': '1. Click Payment Voucher (PV) tab.\n2. Enter Payee: TechSupply Ltd. Select Cheque: CHQ-007001.\n3. Line 1: Select 5.10.01 IT Equipment → Debit ৳250,000.\n4. Click "Calculate TDS/VDS" (F6). Auto splits into Bank (Credit ৳212,500), TDS Payable (Credit ৳25,000), VDS Payable (Credit ৳12,500).\n5. Live Balance: BALANCED. Click Approve & Post!',
      },
      {
        'title': 'Example 2: Receipt Voucher (RV) for Daily POS Counter Collection',
        'steps': '1. Click Receipt Voucher (RV) tab.\n2. Narration: Daily Sales Counter Collection - Dhanmondi Outlet.\n3. Line 1: 1.10.01.001 Cash Float → Debit ৳180,000.\n4. Line 2: 4.10.01.001 Sales Revenue → Credit ৳180,000.\n5. Click Approve & Post!',
      },
      {
        'title': 'Example 3: Contra Voucher (CV) for Bank Cash Withdrawal',
        'steps': '1. Click Contra Voucher (CV) tab.\n2. Select Cheque: CHQ-007002.\n3. Line 1: 1.10.01.001 Cash on Hand → Debit ৳50,000.\n4. Line 2: 1.10.01.002 Bank Operating A/C → Credit ৳50,000.\n5. Click Approve & Post! Cheque Leaf status updates to PRESENTED.',
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
            color: Colors.blue.shade50.withValues(alpha: 0.5),
            border: Border.all(color: Colors.blue.shade100),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Text(ex['title']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue.shade900)),
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
      {'key': 'F1', 'action': 'Focus Account Selector in Line Item'},
      {'key': 'F2', 'action': 'Open Cheque Leaf Picker Modal'},
      {'key': 'F3', 'action': 'Add New Line Item Row'},
      {'key': 'F4', 'action': 'Switch Voucher Type Tab (RV → PV → CV → JV)'},
      {'key': 'F6', 'action': 'Auto-Calculate Tax Deduction (TDS/VDS)'},
      {'key': 'F7', 'action': 'Open Live Voucher Preview Modal'},
      {'key': 'F8', 'action': 'Export Print-Ready PDF Voucher Document'},
      {'key': 'Ctrl + S / F12', 'action': 'Save / Approve & Post Voucher'},
      {'key': 'Esc', 'action': 'Close Overlay Modal / Cancel'},
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
                    color: Colors.blue.shade50,
                    border: Border.all(color: Colors.blue.shade200),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(s['key']!, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900, fontFamily: 'monospace')),
                )),
                DataCell(Text(s['action']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
              ]);
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text('Maker-Checker & Audit Rules', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A1F36))),
          const SizedBox(height: 8),
          _buildRuleBullet('Maker-Checker Lifecycle', 'Vouchers follow DRAFT (Maker) → CHECKED (Checker) → APPROVED (Approver).'),
          _buildRuleBullet('Signature Block', 'PDF export features 4 signatures: Prepared By, Checked By, Approved By, and Payee Signature.'),
          _buildRuleBullet('Auditor Read-Only Portal', 'Internal and External Auditors can inspect all vouchers, view line items, and attach audit queries/observations.'),
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
        color: Colors.blue.shade50.withValues(alpha: 0.5),
        border: Border.all(color: Colors.blue.shade100),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2563EB), size: 24),
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
