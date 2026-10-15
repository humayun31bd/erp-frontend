import 'package:flutter/material.dart';

class PosHelpModal extends StatefulWidget {
  const PosHelpModal({super.key});

  @override
  State<PosHelpModal> createState() => _PosHelpModalState();
}

class _PosHelpModalState extends State<PosHelpModal>
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
        width: 800,
        height: 650,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.help_center_rounded, color: Colors.blue, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'POS Terminal Cashier Training Manual',
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
              labelColor: Colors.blue.shade700,
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: Colors.blue.shade700,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(icon: Icon(Icons.keyboard_outlined, size: 18), text: 'Shortcuts (F1-F12)'),
                Tab(icon: Icon(Icons.space_dashboard_outlined, size: 18), text: 'Panels & Buttons'),
                Tab(icon: Icon(Icons.receipt_long_outlined, size: 18), text: 'Cashier Workflow'),
                Tab(icon: Icon(Icons.published_with_changes_outlined, size: 18), text: 'Returns & Offline'),
              ],
            ),
            const Divider(height: 1),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildShortcutsTab(),
                  _buildPanelsTab(),
                  _buildWorkflowTab(),
                  _buildReturnsTab(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Intelligent ERP v2.0 • ZATCA & NBR Compliant Terminal',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Got It! Start Cashier Shift'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
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

  // ── Tab 1: Keyboard Shortcuts ──
  Widget _buildShortcutsTab() {
    final shortcuts = [
      {'key': 'F1', 'action': 'Focus Barcode Scanner / Product Search', 'desc': 'Instantly moves cursor to search bar without clicking.'},
      {'key': 'F2', 'action': 'Select Customer Directory', 'desc': 'Opens customer lookup & credit limit validation modal.'},
      {'key': 'F3', 'action': 'Suspend / Hold Sale', 'desc': 'Saves current active cart locally to serve next customer.'},
      {'key': 'F4', 'action': 'Resume Suspended Cart', 'desc': 'Reopens list of held carts for instant restoration.'},
      {'key': 'F5', 'action': 'Cash Drawer Pay-In / Pay-Out', 'desc': 'Record float additions or petty cash expenses.'},
      {'key': 'F6', 'action': 'Apply Promotional Discount', 'desc': 'Applies cart-level percentage or fixed discount.'},
      {'key': 'F7', 'action': 'Print Last Receipt', 'desc': 'Reprint duplicate ZATCA tax invoice for last customer.'},
      {'key': 'F9', 'action': 'Clear / Void Entire Cart', 'desc': 'Erases current cart after cashier confirmation.'},
      {'key': 'F10', 'action': 'Shift Reading (X-Report / Z-Report)', 'desc': 'Print mid-shift or end-of-day cash reconciliation.'},
      {'key': 'F12 / Space', 'action': 'PAY / CHECKOUT Modal', 'desc': 'Triggers multi-tender payment and tender entry screen.'},
      {'key': '+ / -', 'action': 'Adjust Quantity', 'desc': 'Increases or decreases selected cart item line quantity.'},
      {'key': 'Del / Backspace', 'action': 'Remove Line Item', 'desc': 'Deletes highlighted product from cart.'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: DataTable(
        headingRowHeight: 36,
        dataRowMaxHeight: 44,
        columns: const [
          DataColumn(label: Text('Shortcut Key', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Action / Command', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Description & Guideline', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: shortcuts.map((s) {
          return DataRow(cells: [
            DataCell(Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border.all(color: Colors.blue.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(s['key']!, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900, fontFamily: 'monospace')),
            )),
            DataCell(Text(s['action']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
            DataCell(Text(s['desc']!, style: TextStyle(fontSize: 12, color: Colors.grey.shade700))),
          ]);
        }).toList(),
      ),
    );
  }

  // ── Tab 2: Panels & Buttons ──
  Widget _buildPanelsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardSection(
            icon: Icons.search_rounded,
            title: '1. Product Search & Barcode Scanner Panel (Left)',
            description: 'Main product catalog area. Scanning any physical barcode instantly adds item to cart. Type keywords to search by name or SKU. Filter by Grocery tabs (Beverages, Fresh Produce, Household, Personal Care).',
          ),
          _buildCardSection(
            icon: Icons.shopping_cart_outlined,
            title: '2. Itemized Cart & Line Items Table (Right)',
            description: 'Displays product name, unit price, quantity [+ / -], line tax, line discount, and line total. Click the Trash Icon to void a line item.',
          ),
          _buildCardSection(
            icon: Icons.person_search_outlined,
            title: '3. Customer Selection & Credit Balance Card',
            description: 'Selects Walk-in or Corporate customer. Shows current account balance (due/credit) and customer credit limit.',
          ),
          _buildCardSection(
            icon: Icons.payments_outlined,
            title: '4. Checkout & Payment Action Bar',
            description: 'Includes Clear Cart [F9], Hold Cart [F3], Order Discount [F6], and PAY/CHECKOUT [F12]. Triggers payment tender window.',
          ),
        ],
      ),
    );
  }

  // ── Tab 3: Cashier Workflow ──
  Widget _buildWorkflowTab() {
    final steps = [
      {'step': 'Step 1', 'title': 'Open Session & Opening Float', 'desc': 'Log in with Cashier PIN → Enter opening cash float (e.g. ৳5,000) → Unlock terminal register.'},
      {'step': 'Step 2', 'title': 'Customer Identification', 'desc': 'Keep Walk-in Customer or press F2 to lookup corporate client. Verify available credit limit.'},
      {'step': 'Step 3', 'title': 'Scan Items or Search Catalog', 'desc': 'Scan barcodes with USB/Bluetooth scanner (F1). Select variants or extra modifiers if prompted.'},
      {'step': 'Step 4', 'title': 'Discounts & Line Adjustments', 'desc': 'Adjust quantities (+ / -) or apply order discount (F6) if authorized.'},
      {'step': 'Step 5', 'title': 'Multi-Tender Payment (F12)', 'desc': 'Select payment method (Cash, Card, Wallet, Credit). Enter cash received → View change due.'},
      {'step': 'Step 6', 'title': 'Print ZATCA Receipt & Cash Drawer', 'desc': 'Click Confirm. Cash drawer kicks open automatically via RJ11. ZATCA QR receipt prints.'},
      {'step': 'Step 7', 'title': 'Shift Close & Z-Report Audit (F10)', 'desc': 'Count cash drawer, enter counted breakdown, review variance, and print Z-Report.'},
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: steps.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final st = steps[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(st['step']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(st['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(st['desc']!, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Tab 4: Returns & Offline ──
  Widget _buildReturnsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardSection(
            icon: Icons.replay_rounded,
            title: 'Product Returns & Cash Refunds',
            description: 'Click Refund/Return → Scan original receipt barcode → Select return items and quantities → Select refund tender (Cash, Card Reversal, or Store Credit). System auto-posts GL reversal voucher and updates stock.',
          ),
          _buildCardSection(
            icon: Icons.sync_alt_rounded,
            title: 'Item Exchanges',
            description: 'Retrieve original transaction → Add returned item → Scan replacement item into active cart → Collect price difference via F12 or issue refund.',
          ),
          _buildCardSection(
            icon: Icons.wifi_off_rounded,
            title: 'Local-First Offline Operation',
            description: 'Operates 100% offline using local SQLite database. Pending sales and GL vouchers are queued automatically and pushed to Cloud Postgres when network reconnects.',
          ),
          _buildCardSection(
            icon: Icons.print_rounded,
            title: 'Hardware & RJ11 Cash Drawer',
            description: 'Supports 80mm/58mm thermal printers. RJ11 cable connected to printer automatically kicks cash drawer open upon payment confirmation.',
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
          Icon(icon, color: Colors.blue.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
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
