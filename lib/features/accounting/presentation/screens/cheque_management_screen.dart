import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/cheque_models.dart';
import '../../domain/accounting_models.dart';
import '../../providers/cheque_provider.dart';
import '../../providers/accounting_providers.dart';
import '../../utils/cheque_pdf_printer.dart';

class ChequeManagementScreen extends ConsumerStatefulWidget {
  const ChequeManagementScreen({super.key});

  @override
  ConsumerState<ChequeManagementScreen> createState() => _ChequeManagementScreenState();
}

class _ChequeManagementScreenState extends ConsumerState<ChequeManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedBankAccountId;
  String _selectedStatus = 'ALL';
  String _selectedPdcType = 'ALL';
  String _selectedMaturity = 'ALL';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _refreshData() {
    ref.invalidate(chequeBooksProvider);
    ref.invalidate(chequeLeavesProvider);
    ref.invalidate(pdcsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final leavesFilter = {
      'bankAccountId': _selectedBankAccountId,
      'status': _selectedStatus,
    };

    final pdcFilter = {
      'bankAccountId': _selectedBankAccountId,
      'pdcType': _selectedPdcType,
      'status': _selectedStatus,
      'maturity': _selectedMaturity,
    };

    final chequeBooksAsync = ref.watch(chequeBooksProvider(_selectedBankAccountId));
    final chequeLeavesAsync = ref.watch(chequeLeavesProvider(leavesFilter));
    final pdcsAsync = ref.watch(pdcsProvider(pdcFilter));
    final bankAccountsAsync = ref.watch(cashBankAccountsProvider('BANK'));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // App Bar Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.verified_user_outlined,
                              color: Color(0xFF2563EB),
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Cheque Management & Audit Compliance (Step 4)',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Full leaf state audit trails, maker/checker history, PDC deposit register & cheque printing designer',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _refreshData,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Refresh'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _showImportBankStatementDialog(context),
                            icon: const Icon(Icons.upload_file, size: 18, color: Color(0xFF7C3AED)),
                            label: const Text('Import Statement & Reconcile', style: TextStyle(color: Color(0xFF7C3AED))),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF7C3AED)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _showReceiveCustomerPdcDialog(context),
                            icon: const Icon(Icons.move_to_inbox, size: 18, color: Color(0xFF0D9488)),
                            label: const Text('Receive Customer PDC', style: TextStyle(color: Color(0xFF0D9488))),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF0D9488)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _showIssueChequeDialog(context),
                            icon: const Icon(Icons.assignment_turned_in, size: 18),
                            label: const Text('Issue Cheque / Reserve Leaf'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0284C7),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _showRegisterChequeBookDialog(context),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Register Book'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Summary Cards Row
                  _buildSummaryCards(chequeBooksAsync, chequeLeavesAsync, pdcsAsync),

                  const SizedBox(height: 20),

                  // Navigation Tabs
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: const Color(0xFF2563EB),
                    unselectedLabelColor: const Color(0xFF64748B),
                    indicatorColor: const Color(0xFF2563EB),
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    tabs: const [
                      Tab(
                        child: Row(
                          children: [
                            Icon(Icons.menu_book, size: 18),
                            SizedBox(width: 8),
                            Text('Cheque Books Directory'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          children: [
                            Icon(Icons.receipt_long, size: 18),
                            SizedBox(width: 8),
                            Text('Cheque Leaves Register'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          children: [
                            Icon(Icons.event_note, size: 18),
                            SizedBox(width: 8),
                            Text('PDC Register & Deposit Workflow'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Main Tab Views
          SliverFillRemaining(
            hasScrollBody: true,
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: Cheque Books Directory
                _buildChequeBooksTab(chequeBooksAsync),

                // TAB 2: Cheque Leaves Register
                _buildChequeLeavesTab(chequeLeavesAsync, bankAccountsAsync),

                // TAB 3: PDC Register & Deposit Workflow
                _buildPdcRegisterTab(pdcsAsync, bankAccountsAsync),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(
    AsyncValue<List<ChequeBookModel>> booksAsync,
    AsyncValue<List<ChequeLeafModel>> leavesAsync,
    AsyncValue<List<ChequeLeafModel>> pdcsAsync,
  ) {
    int totalBooks = booksAsync.valueOrNull?.length ?? 0;
    List<ChequeLeafModel> leaves = leavesAsync.valueOrNull ?? [];
    List<ChequeLeafModel> pdcs = pdcsAsync.valueOrNull ?? [];

    int availableCount = leaves.where((l) => l.status == 'AVAILABLE').length;
    int issuedCount = leaves.where((l) => l.status == 'ISSUED').length;
    int clearedCount = leaves.where((l) => l.status == 'CLEARED').length;
    int bouncedCount = leaves.where((l) => l.status == 'BOUNCED').length;
    int pdcHeldCount = pdcs.where((p) => p.status == 'RECEIVED' || p.status == 'PRESENTED').length;
    int overdueCount = pdcs.where((p) => p.maturityAlert == 'OVERDUE').length;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _kpiCard('Active Cheque Books', totalBooks.toString(), Icons.library_books, const Color(0xFF2563EB), const Color(0xFFEFF6FF)),
            _kpiCard('Available Leaves', availableCount.toString(), Icons.check_circle_outline, const Color(0xFF0D9488), const Color(0xFFF0FDFA)),
            _kpiCard('Issued Cheques', issuedCount.toString(), Icons.schedule, const Color(0xFFD97706), const Color(0xFFFFFBEB)),
            _kpiCard('Cleared Cheques', clearedCount.toString(), Icons.verified, const Color(0xFF16A34A), const Color(0xFFF0FDF4)),
            _kpiCard('PDC Received / Held', pdcHeldCount.toString(), Icons.inbox, const Color(0xFF0284C7), const Color(0xFFF0F9FF)),
            _kpiCard('Overdue / Bounced', (bouncedCount + overdueCount).toString(), Icons.error_outline, const Color(0xFFDC2626), const Color(0xFFFEF2F2)),
          ],
        );
      },
    );
  }

  Widget _kpiCard(String title, String value, IconData icon, Color color, Color bgColor) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: Cheque Books Directory Widget
  // ---------------------------------------------------------------------------
  Widget _buildChequeBooksTab(AsyncValue<List<ChequeBookModel>> booksAsync) {
    return booksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text('Failed to load cheque books: $err'),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _refreshData, child: const Text('Retry')),
            ],
          ),
        ),
      ),
      data: (books) {
        if (books.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.library_books_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'No Cheque Books Registered Yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Register a new cheque book to start tracking physical cheque leaves sequential numbering.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _showRegisterChequeBookDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Register Cheque Book'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            final int total = book.totalLeaves;
            final int used = book.usedLeavesCount;
            final int bounced = book.bouncedLeavesCount;
            final int available = book.availableLeavesCount;
            final double progress = total > 0 ? (used / total) : 0.0;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
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
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.account_balance, color: Color(0xFF475569)),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book.chequeBookNumber,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  book.bankAccountName ?? 'Bank Account #${book.bankAccountId}',
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: book.status == 'ACTIVE' ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            book.status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: book.status == 'ACTIVE' ? const Color(0xFF15803D) : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Leaf Series: #${book.startLeafNumber}  →  #${book.endLeafNumber}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                        ),
                        Text(
                          '$used / $total Leaves Used (${(progress * 100).toStringAsFixed(0)}%)',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress >= 0.9 ? const Color(0xFFDC2626) : const Color(0xFF2563EB),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _smallBadge('Available: $available', const Color(0xFF0D9488), const Color(0xFFF0FDFA)),
                        const SizedBox(width: 8),
                        _smallBadge('Used: $used', const Color(0xFFD97706), const Color(0xFFFFFBEB)),
                        const SizedBox(width: 8),
                        _smallBadge('Bounced: $bounced', const Color(0xFFDC2626), const Color(0xFFFEF2F2)),
                      ],
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

  Widget _smallBadge(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textColor),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: Cheque Leaves Register Widget
  // ---------------------------------------------------------------------------
  Widget _buildChequeLeavesTab(
    AsyncValue<List<ChequeLeafModel>> leavesAsync,
    AsyncValue<List<Account>> bankAccountsAsync,
  ) {
    return Column(
      children: [
        // Filter Controls Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          color: Colors.white,
          child: Row(
            children: [
              // Bank Account Selector Filter
              Expanded(
                flex: 2,
                child: bankAccountsAsync.when(
                  data: (accounts) => DropdownButtonFormField<String?>(
                    value: _selectedBankAccountId,
                    decoration: InputDecoration(
                      labelText: 'Filter by Bank Account',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Bank Accounts')),
                      ...accounts.map((acc) => DropdownMenuItem(
                            value: acc.id,
                            child: Text(acc.name),
                          )),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedBankAccountId = val);
                    },
                  ),
                  loading: () => const SizedBox(height: 40, child: Center(child: CircularProgressIndicator())),
                  error: (_, __) => const SizedBox(),
                ),
              ),
              const SizedBox(width: 16),

              // Status Filter
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Filter Status',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'ALL', child: Text('All Statuses')),
                    DropdownMenuItem(value: 'AVAILABLE', child: Text('AVAILABLE')),
                    DropdownMenuItem(value: 'ISSUED', child: Text('ISSUED')),
                    DropdownMenuItem(value: 'CLEARED', child: Text('CLEARED')),
                    DropdownMenuItem(value: 'BOUNCED', child: Text('BOUNCED')),
                    DropdownMenuItem(value: 'CANCELLED', child: Text('CANCELLED')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedStatus = val);
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Search Field
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search Leaf # or Payee...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1, color: Color(0xFFE2E8F0)),

        // Data Table area
        Expanded(
          child: leavesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error loading leaves: $err')),
            data: (leaves) {
              final filteredLeaves = leaves.where((leaf) {
                if (_searchQuery.isEmpty) return true;
                final query = _searchQuery.toLowerCase();
                final leafNumMatches = leaf.chequeNumber.toLowerCase().contains(query);
                final payeeMatches = leaf.payeeName?.toLowerCase().contains(query) ?? false;
                return leafNumMatches || payeeMatches;
              }).toList();

              if (filteredLeaves.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No cheque leaves match your filters.'),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1.2),
                      1: FlexColumnWidth(1.8),
                      2: FlexColumnWidth(1.8),
                      3: FlexColumnWidth(1.2),
                      4: FlexColumnWidth(1.2),
                      5: FlexColumnWidth(1.2),
                      6: FlexColumnWidth(2.6),
                    },
                    children: [
                      // Header Row
                      TableRow(
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        children: [
                          _tableHeader('Cheque Leaf #'),
                          _tableHeader('Bank Account'),
                          _tableHeader('Payee / Supplier'),
                          _tableHeader('Amount (SAR)'),
                          _tableHeader('Status'),
                          _tableHeader('Issue Date'),
                          _tableHeader('Actions'),
                        ],
                      ),
                      ...filteredLeaves.map((leaf) => TableRow(
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                            ),
                            children: [
                              _tableCell(leaf.chequeNumber, isBold: true),
                              _tableCell(leaf.bankAccountName ?? '-'),
                              _tableCell(leaf.payeeName ?? '-'),
                              _tableCell(
                                NumberFormat('#,##0.00').format(leaf.amount),
                                alignment: Alignment.centerRight,
                              ),
                              _tableCellBadge(leaf.status),
                              _tableCell(
                                leaf.issuedDate != null
                                    ? DateFormat('yyyy-MM-dd').format(DateTime.parse(leaf.issuedDate!))
                                    : '-',
                              ),
                              _tableActionButtons(leaf),
                            ],
                          )),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 3: PDC Register & Deposit Workflow Widget
  // ---------------------------------------------------------------------------
  Widget _buildPdcRegisterTab(
    AsyncValue<List<ChequeLeafModel>> pdcsAsync,
    AsyncValue<List<Account>> bankAccountsAsync,
  ) {
    return Column(
      children: [
        // PDC Filters
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          color: Colors.white,
          child: Row(
            children: [
              // Type Filter
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedPdcType,
                  decoration: InputDecoration(
                    labelText: 'PDC Type',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'ALL', child: Text('All PDCs')),
                    DropdownMenuItem(value: 'RECEIVED', child: Text('Customer PDCs (Received)')),
                    DropdownMenuItem(value: 'ISSUED', child: Text('Vendor PDCs (Issued)')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedPdcType = val);
                  },
                ),
              ),
              const SizedBox(width: 14),

              // Maturity Status Filter
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedMaturity,
                  decoration: InputDecoration(
                    labelText: 'Maturity Status',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'ALL', child: Text('All Due Dates')),
                    DropdownMenuItem(value: 'OVERDUE', child: Text('Overdue / Past Due')),
                    DropdownMenuItem(value: 'DUE_TODAY', child: Text('Due Today')),
                    DropdownMenuItem(value: 'DUE_THIS_WEEK', child: Text('Due Within 7 Days')),
                    DropdownMenuItem(value: 'FUTURE', child: Text('Future Maturity')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedMaturity = val);
                  },
                ),
              ),
              const SizedBox(width: 14),

              // Search Field
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search PDC # or Drawer / Payee...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1, color: Color(0xFFE2E8F0)),

        Expanded(
          child: pdcsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error loading PDC register: $err')),
            data: (pdcs) {
              final filteredPdcs = pdcs.where((pdc) {
                if (_searchQuery.isEmpty) return true;
                final query = _searchQuery.toLowerCase();
                final numMatches = pdc.chequeNumber.toLowerCase().contains(query);
                final payeeMatches = pdc.payeeName?.toLowerCase().contains(query) ?? false;
                return numMatches || payeeMatches;
              }).toList();

              if (filteredPdcs.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No Post-Dated Cheques match your current filter parameters.'),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1.2),
                      1: FlexColumnWidth(1.4),
                      2: FlexColumnWidth(1.8),
                      3: FlexColumnWidth(1.2),
                      4: FlexColumnWidth(1.2),
                      5: FlexColumnWidth(1.2),
                      6: FlexColumnWidth(2.6),
                    },
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        children: [
                          _tableHeader('PDC Cheque #'),
                          _tableHeader('PDC Type'),
                          _tableHeader('Drawer / Payee'),
                          _tableHeader('Amount (SAR)'),
                          _tableHeader('Maturity Date'),
                          _tableHeader('Status'),
                          _tableHeader('Actions'),
                        ],
                      ),
                      ...filteredPdcs.map((pdc) => TableRow(
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                            ),
                            children: [
                              _tableCell(pdc.chequeNumber, isBold: true),
                              _tablePdcTypeBadge(pdc.status),
                              _tableCell(pdc.payeeName ?? '-'),
                              _tableCell(
                                NumberFormat('#,##0.00').format(pdc.amount),
                                alignment: Alignment.centerRight,
                              ),
                              _tableMaturityCell(pdc),
                              _tableCellBadge(pdc.status),
                              _tablePdcActionButtons(pdc),
                            ],
                          )),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _tablePdcTypeBadge(String status) {
    bool isReceived = status == 'RECEIVED' || status == 'PRESENTED';
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isReceived ? const Color(0xFFEFF6FF) : const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          isReceived ? 'CUSTOMER PDC' : 'VENDOR PDC',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isReceived ? const Color(0xFF2563EB) : const Color(0xFFD97706),
          ),
        ),
      ),
    );
  }

  Widget _tableMaturityCell(ChequeLeafModel pdc) {
    String dateStr = '-';
    if (pdc.issuedDate != null) {
      dateStr = DateFormat('yyyy-MM-dd').format(DateTime.parse(pdc.issuedDate!));
    }

    Color badgeBg = Colors.transparent;
    Color badgeFg = const Color(0xFF0F172A);
    String alertLabel = '';

    if (pdc.maturityAlert == 'OVERDUE' && pdc.status != 'CLEARED') {
      badgeBg = const Color(0xFFFEF2F2);
      badgeFg = const Color(0xFFDC2626);
      alertLabel = 'OVERDUE';
    } else if (pdc.maturityAlert == 'DUE_TODAY' && pdc.status != 'CLEARED') {
      badgeBg = const Color(0xFFFFFBEB);
      badgeFg = const Color(0xFFD97706);
      alertLabel = 'DUE TODAY';
    } else if (pdc.maturityAlert == 'DUE_THIS_WEEK' && pdc.status != 'CLEARED') {
      badgeBg = const Color(0xFFF0FDFA);
      badgeFg = const Color(0xFF0D9488);
      alertLabel = 'DUE 7 DAYS';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dateStr, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          if (alertLabel.isNotEmpty) ...[
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(4)),
              child: Text(
                alertLabel,
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: badgeFg),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _tablePdcActionButtons(ChequeLeafModel pdc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.history, size: 18, color: Color(0xFF7C3AED)),
            tooltip: 'View Audit Timeline',
            onPressed: () => _showChequeAuditTimelineModal(pdc),
          ),
          IconButton(
            icon: const Icon(Icons.print, size: 18, color: Color(0xFF2563EB)),
            tooltip: 'Print Cheque Layout',
            onPressed: () => _showPrintChequeModal(pdc),
          ),
          if (pdc.status == 'RECEIVED') ...[
            ElevatedButton.icon(
              onPressed: () => _showDepositPdcDialog(pdc),
              icon: const Icon(Icons.account_balance, size: 14),
              label: const Text('Deposit', style: TextStyle(fontSize: 11)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 6),
          ],
          if (pdc.status == 'PRESENTED' || pdc.status == 'ISSUED') ...[
            ElevatedButton(
              onPressed: () => _showClearChequeDialog(pdc),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Clear', style: TextStyle(fontSize: 11)),
            ),
            const SizedBox(width: 6),
            ElevatedButton(
              onPressed: () => _showBounceChequeDialog(pdc),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Bounce', style: TextStyle(fontSize: 11)),
            ),
          ] else if (pdc.status == 'CLEARED') ...[
            const Text('Cleared', style: TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.bold, fontSize: 12)),
          ] else if (pdc.status == 'BOUNCED') ...[
            const Text('Dishonored', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold, fontSize: 12)),
          ]
        ],
      ),
    );
  }

  Widget _tableHeader(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF475569)),
      ),
    );
  }

  Widget _tableCell(String value, {bool isBold = false, Alignment alignment = Alignment.centerLeft}) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: const Color(0xFF0F172A),
        ),
      ),
    );
  }

  Widget _tableCellBadge(String status) {
    Color bg;
    Color fg;
    switch (status) {
      case 'AVAILABLE':
        bg = const Color(0xFFF0FDFA);
        fg = const Color(0xFF0D9488);
        break;
      case 'ISSUED':
        bg = const Color(0xFFFFFBEB);
        fg = const Color(0xFFD97706);
        break;
      case 'RECEIVED':
        bg = const Color(0xFFEFF6FF);
        fg = const Color(0xFF2563EB);
        break;
      case 'PRESENTED':
        bg = const Color(0xFFF0F9FF);
        fg = const Color(0xFF0284C7);
        break;
      case 'CLEARED':
        bg = const Color(0xFFF0FDF4);
        fg = const Color(0xFF16A34A);
        break;
      case 'BOUNCED':
        bg = const Color(0xFFFEF2F2);
        fg = const Color(0xFFDC2626);
        break;
      case 'CANCELLED':
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
    }

    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
        child: Text(
          status,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg),
        ),
      ),
    );
  }

  Widget _tableActionButtons(ChequeLeafModel leaf) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.history, size: 18, color: Color(0xFF7C3AED)),
            tooltip: 'View Audit Timeline',
            onPressed: () => _showChequeAuditTimelineModal(leaf),
          ),
          if (leaf.status == 'ISSUED' || leaf.status == 'CLEARED' || leaf.status == 'AVAILABLE') ...[
            IconButton(
              icon: const Icon(Icons.print, size: 18, color: Color(0xFF2563EB)),
              tooltip: 'Print Cheque Leaf',
              onPressed: () => _showPrintChequeModal(leaf),
            ),
          ],
          if (leaf.status == 'ISSUED') ...[
            ElevatedButton(
              onPressed: () => _showClearChequeDialog(leaf),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Clear', style: TextStyle(fontSize: 11)),
            ),
            const SizedBox(width: 6),
            ElevatedButton(
              onPressed: () => _showBounceChequeDialog(leaf),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Bounce', style: TextStyle(fontSize: 11)),
            ),
            const SizedBox(width: 6),
            OutlinedButton(
              onPressed: () => _showCancelChequeDialog(leaf),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF64748B),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Cancel', style: TextStyle(fontSize: 11)),
            ),
          ] else if (leaf.status == 'CLEARED') ...[
            OutlinedButton(
              onPressed: () => _showBounceChequeDialog(leaf),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                side: const BorderSide(color: Color(0xFFDC2626)),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Bounce', style: TextStyle(fontSize: 11)),
            ),
          ] else ...[
            const Text('-', style: TextStyle(color: Colors.grey)),
          ]
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Dialog 1: Register New Cheque Book
  // ---------------------------------------------------------------------------
  void _showRegisterChequeBookDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String? bankAccountId;
    final bookNumCtrl = TextEditingController();
    final startLeafCtrl = TextEditingController();
    final totalLeavesCtrl = TextEditingController(text: '25');

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Consumer(
          builder: (context, ref, _) {
            final bankAccountsAsync = ref.watch(cashBankAccountsProvider('BANK'));
            return AlertDialog(
              title: const Text('Register New Cheque Book'),
              content: Form(
                key: formKey,
                child: SizedBox(
                  width: 440,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      bankAccountsAsync.when(
                        data: (accounts) => DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Bank Account *'),
                          items: accounts
                              .map((a) => DropdownMenuItem(
                                    value: a.id,
                                    child: Text('${a.name} (${a.code})'),
                                  ))
                              .toList(),
                          validator: (v) => v == null ? 'Please select bank account' : null,
                          onChanged: (v) => bankAccountId = v,
                        ),
                        loading: () => const LinearProgressIndicator(),
                        error: (e, _) => Text('Error: $e'),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: bookNumCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Cheque Book Number / Series Name *',
                          hintText: 'e.g. Al Rajhi Book 2026-A',
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required field' : null,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: startLeafCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Starting Leaf # *',
                                hintText: 'e.g. 100101',
                              ),
                              validator: (v) => int.tryParse(v ?? '') == null ? 'Enter valid number' : null,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextFormField(
                              controller: totalLeavesCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Total Leaves *',
                                hintText: 'e.g. 25, 50',
                              ),
                              validator: (v) => int.tryParse(v ?? '') == null ? 'Enter valid number' : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      try {
                        final service = ref.read(chequeServiceProvider);
                        await service.createChequeBook(
                          bankAccountId: bankAccountId!,
                          chequeBookNumber: bookNumCtrl.text.trim(),
                          startLeafNumber: int.parse(startLeafCtrl.text.trim()),
                          totalLeaves: int.parse(totalLeavesCtrl.text.trim()),
                        );
                        if (mounted && dialogCtx.mounted) {
                          Navigator.pop(dialogCtx);
                          _refreshData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Cheque book registered successfully!')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to register cheque book: $e')),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Register Book'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Dialog 2: Issue Cheque / Auto-Assign Leaf
  // ---------------------------------------------------------------------------
  void _showIssueChequeDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String? selectedBankId;
    final payeeCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final remarksCtrl = TextEditingController();
    DateTime issueDate = DateTime.now();
    DateTime? dueDate;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Consumer(
          builder: (context, ref, _) {
            final bankAccountsAsync = ref.watch(cashBankAccountsProvider('BANK'));
            final availableLeafAsync = selectedBankId != null
                ? ref.watch(availableChequeLeafProvider(selectedBankId!))
                : const AsyncValue<ChequeLeafModel?>.data(null);

            return StatefulBuilder(
              builder: (context, setDialogState) {
                return AlertDialog(
                  title: const Text('Issue Cheque / Auto-Assign Leaf'),
                  content: Form(
                    key: formKey,
                    child: SizedBox(
                      width: 480,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          bankAccountsAsync.when(
                            data: (accounts) => DropdownButtonFormField<String>(
                              decoration: const InputDecoration(labelText: 'Bank Account *'),
                              items: accounts
                                  .map((a) => DropdownMenuItem(
                                        value: a.id,
                                        child: Text('${a.name} (${a.code})'),
                                      ))
                                  .toList(),
                              validator: (v) => v == null ? 'Please select bank account' : null,
                              onChanged: (v) {
                                setDialogState(() {
                                  selectedBankId = v;
                                });
                              },
                            ),
                            loading: () => const LinearProgressIndicator(),
                            error: (e, _) => Text('Error: $e'),
                          ),
                          const SizedBox(height: 12),

                          if (selectedBankId != null) ...[
                            availableLeafAsync.when(
                              data: (leaf) => Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: leaf != null ? const Color(0xFFF0FDFA) : const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: leaf != null ? const Color(0xFFCCFBF1) : const Color(0xFFFECACA)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      leaf != null ? Icons.check_circle : Icons.warning_amber_rounded,
                                      color: leaf != null ? const Color(0xFF0D9488) : const Color(0xFFDC2626),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      leaf != null
                                          ? 'Next Available Leaf: #${leaf.chequeNumber}'
                                          : 'No available leaves in active cheque book!',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: leaf != null ? const Color(0xFF0F766E) : const Color(0xFF991B1B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              loading: () => const LinearProgressIndicator(),
                              error: (_, __) => const SizedBox(),
                            ),
                            const SizedBox(height: 12),
                          ],

                          TextFormField(
                            controller: payeeCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Payee / Supplier Name *',
                              hintText: 'e.g. Saudi Aramco / Global Supplies Ltd',
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required field' : null,
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: amountCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Cheque Amount (SAR) *',
                              hintText: '0.00',
                            ),
                            validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0 ? 'Enter valid positive amount' : null,
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Issue Date', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                    TextButton.icon(
                                      onPressed: () async {
                                        final picked = await showDatePicker(
                                          context: context,
                                          initialDate: issueDate,
                                          firstDate: DateTime(2020),
                                          lastDate: DateTime(2030),
                                        );
                                        if (picked != null) setDialogState(() => issueDate = picked);
                                      },
                                      icon: const Icon(Icons.calendar_today, size: 16),
                                      label: Text(DateFormat('yyyy-MM-dd').format(issueDate)),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Due / Maturity Date (PDC)', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                    TextButton.icon(
                                      onPressed: () async {
                                        final picked = await showDatePicker(
                                          context: context,
                                          initialDate: dueDate ?? issueDate.add(const Duration(days: 30)),
                                          firstDate: DateTime(2020),
                                          lastDate: DateTime(2030),
                                        );
                                        if (picked != null) setDialogState(() => dueDate = picked);
                                      },
                                      icon: const Icon(Icons.event, size: 16),
                                      label: Text(dueDate != null ? DateFormat('yyyy-MM-dd').format(dueDate!) : 'None (Regular)'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: remarksCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Remarks / Payment Purpose',
                              hintText: 'e.g. Vendor Invoice #INV-8894 payment',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          try {
                            final service = ref.read(chequeServiceProvider);
                            final amountVal = double.parse(amountCtrl.text.trim());
                            await service.issueChequeLeaf(
                              bankAccountId: selectedBankId!,
                              payeeName: payeeCtrl.text.trim(),
                              amount: amountVal,
                              issueDate: issueDate.toIso8601String(),
                              dueDate: dueDate?.toIso8601String(),
                              remarks: remarksCtrl.text.trim(),
                            );
                            if (mounted && dialogCtx.mounted) {
                              Navigator.pop(dialogCtx);
                              _refreshData();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Cheque issued successfully!')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to issue cheque: $e')),
                              );
                            }
                          }
                        }
                      },
                      child: const Text('Confirm & Issue Cheque'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Dialog 3: Receive Customer PDC
  // ---------------------------------------------------------------------------
  void _showReceiveCustomerPdcDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String? selectedBankId;
    final chequeNumCtrl = TextEditingController();
    final drawerCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final remarksCtrl = TextEditingController();
    DateTime maturityDate = DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Consumer(
          builder: (context, ref, _) {
            final bankAccountsAsync = ref.watch(cashBankAccountsProvider('BANK'));

            return StatefulBuilder(
              builder: (context, setDialogState) {
                return AlertDialog(
                  title: const Text('Receive Customer Post-Dated Cheque (PDC)'),
                  content: Form(
                    key: formKey,
                    child: SizedBox(
                      width: 480,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          bankAccountsAsync.when(
                            data: (accounts) => DropdownButtonFormField<String>(
                              decoration: const InputDecoration(labelText: 'Deposit Target Bank Account *'),
                              items: accounts
                                  .map((a) => DropdownMenuItem(
                                        value: a.id,
                                        child: Text('${a.name} (${a.code})'),
                                      ))
                                  .toList(),
                              validator: (v) => v == null ? 'Please select bank account' : null,
                              onChanged: (v) => selectedBankId = v,
                            ),
                            loading: () => const LinearProgressIndicator(),
                            error: (e, _) => Text('Error: $e'),
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: chequeNumCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Cheque Number *',
                              hintText: 'e.g. 0004921',
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required field' : null,
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: drawerCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Drawer / Customer Name *',
                              hintText: 'e.g. Al Safa Supermarket Trading',
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required field' : null,
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: amountCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Cheque Amount (SAR) *',
                              hintText: '0.00',
                            ),
                            validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0 ? 'Enter valid positive amount' : null,
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              const Text('Maturity / Due Date: ', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(DateFormat('yyyy-MM-dd').format(maturityDate)),
                              IconButton(
                                icon: const Icon(Icons.calendar_today, size: 18),
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: maturityDate,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                  );
                                  if (picked != null) setDialogState(() => maturityDate = picked);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: remarksCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Remarks / Received Reference',
                              hintText: 'e.g. Received for Order #SO-1092',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          try {
                            final service = ref.read(chequeServiceProvider);
                            final amountVal = double.parse(amountCtrl.text.trim());
                            await service.recordReceivedPdc(
                              bankAccountId: selectedBankId!,
                              chequeNumber: chequeNumCtrl.text.trim(),
                              drawerName: drawerCtrl.text.trim(),
                              amount: amountVal,
                              maturityDate: maturityDate.toIso8601String(),
                              remarks: remarksCtrl.text.trim(),
                            );
                            if (mounted && dialogCtx.mounted) {
                              Navigator.pop(dialogCtx);
                              _refreshData();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Customer PDC recorded successfully!')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to record customer PDC: $e')),
                              );
                            }
                          }
                        }
                      },
                      child: const Text('Record Customer PDC'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Dialog 4: Deposit Received PDC to Bank
  // ---------------------------------------------------------------------------
  void _showDepositPdcDialog(ChequeLeafModel pdc) {
    DateTime depositDate = DateTime.now();
    final remarksCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Deposit PDC Cheque #${pdc.chequeNumber}'),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDFA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Depositing this cheque will mark its status as PRESENTED for bank clearing.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF0F766E)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('Drawer / Customer: ${pdc.payeeName ?? "-"}'),
                    Text('Amount: SAR ${NumberFormat('#,##0.00').format(pdc.amount)}'),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Text('Deposit Date: '),
                        Text(
                          DateFormat('yyyy-MM-dd').format(depositDate),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today, size: 18),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: depositDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) setDialogState(() => depositDate = picked);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: remarksCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Deposit Slip / Bank Branch Remarks',
                        hintText: 'e.g. Deposited via Bank Slip #7721',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    try {
                      final service = ref.read(chequeServiceProvider);
                      await service.depositPdc(
                        chequeLeafId: pdc.id,
                        depositDate: depositDate.toIso8601String(),
                        remarks: remarksCtrl.text.trim(),
                      );
                      if (mounted && dialogCtx.mounted) {
                        Navigator.pop(dialogCtx);
                        _refreshData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('PDC deposited to bank successfully!')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error depositing PDC: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Confirm Deposit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Dialog 5: Clear Cheque
  // ---------------------------------------------------------------------------
  void _showClearChequeDialog(ChequeLeafModel leaf) {
    DateTime selectedDate = DateTime.now();
    final remarksCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Clear Cheque Leaf #${leaf.chequeNumber}'),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bank: ${leaf.bankAccountName ?? ""}'),
                    Text('Payee / Customer: ${leaf.payeeName ?? "-"}'),
                    Text(
                      'Amount: SAR ${NumberFormat('#,##0.00').format(leaf.amount)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Clearance Date: '),
                        Text(
                          DateFormat('yyyy-MM-dd').format(selectedDate),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today, size: 18),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setDialogState(() => selectedDate = picked);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: remarksCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Clearance Remarks',
                        hintText: 'e.g. Cleared via bank statement reconciliation',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    try {
                      final service = ref.read(chequeServiceProvider);
                      await service.clearCheque(
                        chequeLeafId: leaf.id,
                        clearedDate: selectedDate.toIso8601String(),
                        remarks: remarksCtrl.text.trim(),
                      );
                      if (mounted && dialogCtx.mounted) {
                        Navigator.pop(dialogCtx);
                        _refreshData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cheque cleared successfully!')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error clearing cheque: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Confirm Clearance'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Dialog 6: Bounce Cheque
  // ---------------------------------------------------------------------------
  void _showBounceChequeDialog(ChequeLeafModel leaf) {
    DateTime selectedDate = DateTime.now();
    final penaltyFeeCtrl = TextEditingController(text: '0.00');
    final remarksCtrl = TextEditingController(text: 'Insufficient funds');

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Bounce Cheque Leaf #${leaf.chequeNumber}'),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Warning: Bouncing a cheque will create a reversal journal entry and automatically record any bank penalty fees incurred.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF991B1B)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('Payee / Customer: ${leaf.payeeName ?? "-"}'),
                    Text('Amount: SAR ${NumberFormat('#,##0.00').format(leaf.amount)}'),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Text('Bounced Date: '),
                        Text(
                          DateFormat('yyyy-MM-dd').format(selectedDate),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today, size: 18),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setDialogState(() => selectedDate = picked);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: penaltyFeeCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Bank Penalty / Bounce Fee (SAR)',
                        hintText: '0.00',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: remarksCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Bounce Reason / Remarks *',
                        hintText: 'e.g. Insufficient funds / Signature mismatch',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    try {
                      final service = ref.read(chequeServiceProvider);
                      final penaltyFee = double.tryParse(penaltyFeeCtrl.text.trim()) ?? 0.0;
                      await service.bounceCheque(
                        chequeLeafId: leaf.id,
                        bouncedDate: selectedDate.toIso8601String(),
                        penaltyFeeAmount: penaltyFee,
                        remarks: remarksCtrl.text.trim(),
                      );
                      if (mounted && dialogCtx.mounted) {
                        Navigator.pop(dialogCtx);
                        _refreshData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cheque bounced and reversal JV generated!')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error bouncing cheque: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Confirm Bounce'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Dialog 7: Cancel / Stop Payment Request
  // ---------------------------------------------------------------------------
  void _showCancelChequeDialog(ChequeLeafModel leaf) {
    final reasonCtrl = TextEditingController(text: 'Lost / Stop Payment requested');
    final stopFeeCtrl = TextEditingController(text: '50.00');

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text('Cancel / Stop Payment Leaf #${leaf.chequeNumber}'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Cancelling this leaf will set its status to CANCELLED and log any bank stop payment fee charged.',
                    style: TextStyle(fontSize: 12, color: Color(0xFFB45309)),
                  ),
                ),
                const SizedBox(height: 14),
                Text('Payee / Supplier: ${leaf.payeeName ?? "-"}'),
                Text('Amount: SAR ${NumberFormat('#,##0.00').format(leaf.amount)}'),
                const SizedBox(height: 14),
                TextField(
                  controller: stopFeeCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Bank Stop Payment Fee (SAR)',
                    hintText: 'e.g. 50.00',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reasonCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Cancellation Reason *',
                    hintText: 'e.g. Lost in transit / Duplicate issued',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF64748B),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                try {
                  final service = ref.read(chequeServiceProvider);
                  final fee = double.tryParse(stopFeeCtrl.text.trim()) ?? 0.0;
                  await service.cancelCheque(
                    chequeLeafId: leaf.id,
                    reason: reasonCtrl.text.trim(),
                    stopFeeAmount: fee,
                  );
                  if (mounted && dialogCtx.mounted) {
                    Navigator.pop(dialogCtx);
                    _refreshData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cheque cancelled & stop payment recorded!')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error cancelling cheque: $e')),
                    );
                  }
                }
              },
              child: const Text('Confirm Cancellation'),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Dialog 8: Print Cheque Modal
  // ---------------------------------------------------------------------------
  void _showPrintChequeModal(ChequeLeafModel leaf) {
    String selectedPreset = 'AL_RAJHI';

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.print, color: Color(0xFF2563EB)),
                  const SizedBox(width: 8),
                  Text('Print Cheque Leaf #${leaf.chequeNumber}'),
                ],
              ),
              content: SizedBox(
                width: 440,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Payee: ${leaf.payeeName ?? "Beneficiary"}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Amount: SAR ${NumberFormat('#,##0.00').format(leaf.amount)}'),
                          const SizedBox(height: 4),
                          Text(
                            'Amount in Words: ${ChequePdfPrinter.amountToWordsEn(leaf.amount)}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedPreset,
                      decoration: const InputDecoration(
                        labelText: 'Select Bank Cheque Format / Preset',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'AL_RAJHI', child: Text('Al Rajhi Bank (مصرف الراجحي)')),
                        DropdownMenuItem(value: 'SNB', child: Text('Saudi National Bank / SNB (الأهلي)')),
                        DropdownMenuItem(value: 'RIYAD', child: Text('Riyad Bank (بنك الرياض)')),
                        DropdownMenuItem(value: 'SABB', child: Text('SABB / Saudi Awwal Bank (الأول)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedPreset = val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(dialogCtx);
                    await ChequePdfPrinter.printCheque(leaf: leaf, bankPresetName: selectedPreset);
                  },
                  icon: const Icon(Icons.print, size: 18),
                  label: const Text('Direct Print / Preview PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Dialog 9: Import Bank Statement & Auto-Reconcile
  // ---------------------------------------------------------------------------
  void _showImportBankStatementDialog(BuildContext context) {
    String? bankAccountId;
    final csvCtrl = TextEditingController(
      text: '2026-10-01,100101,Vendor Payment Aramco,15000.00,DEBIT\n'
          '2026-10-03,0004921,Customer Deposit Al Safa,25000.00,CREDIT',
    );

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Consumer(
          builder: (context, ref, _) {
            final bankAccountsAsync = ref.watch(cashBankAccountsProvider('BANK'));
            return AlertDialog(
              title: const Text('Import Bank Statement & Auto-Reconcile'),
              content: SizedBox(
                width: 520,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    bankAccountsAsync.when(
                      data: (accounts) => DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Target Bank Account *'),
                        items: accounts
                            .map((a) => DropdownMenuItem(
                                  value: a.id,
                                  child: Text('${a.name} (${a.code})'),
                                ))
                            .toList(),
                        validator: (v) => v == null ? 'Select bank account' : null,
                        onChanged: (v) => bankAccountId = v,
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (e, _) => Text('Error: $e'),
                    ),
                    const SizedBox(height: 14),
                    const Text('Paste Statement CSV Data (Date, Reference, Description, Amount, Type):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: csvCtrl,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'YYYY-MM-DD, Cheque#, Description, Amount, DEBIT/CREDIT',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (bankAccountId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select bank account')));
                      return;
                    }
                    try {
                      final linesRaw = csvCtrl.text.trim().split('\n');
                      final List<Map<String, dynamic>> statementLines = [];

                      for (final line in linesRaw) {
                        final parts = line.split(',');
                        if (parts.length >= 4) {
                          statementLines.add({
                            'date': parts[0].trim(),
                            'reference': parts[1].trim(),
                            'description': parts[2].trim(),
                            'amount': double.tryParse(parts[3].trim()) ?? 0.0,
                            'type': parts.length >= 5 ? parts[4].trim().toUpperCase() : 'DEBIT',
                          });
                        }
                      }

                      final service = ref.read(chequeServiceProvider);
                      final result = await service.importBankStatement(
                        bankAccountId: bankAccountId!,
                        statementLines: statementLines,
                      );

                      if (mounted && dialogCtx.mounted) {
                        Navigator.pop(dialogCtx);
                        _refreshData();
                        final summary = result['summary'] ?? {};
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Reconciliation complete! Matched: ${summary['autoMatchedCount'] ?? 0}, Unmatched: ${summary['unmatchedCount'] ?? 0}',
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to reconcile statement: $e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Run Auto-Reconciliation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Dialog 10: Cheque Leaf Audit Timeline Modal (Step 4)
  // ---------------------------------------------------------------------------
  void _showChequeAuditTimelineModal(ChequeLeafModel leaf) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Consumer(
          builder: (context, ref, _) {
            final auditAsync = ref.watch(chequeAuditLogsProvider(leaf.id));

            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.verified_user, color: Color(0xFF7C3AED)),
                  const SizedBox(width: 10),
                  Text('Audit Log & History: Cheque #${leaf.chequeNumber}'),
                ],
              ),
              content: SizedBox(
                width: 540,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Payee: ${leaf.payeeName ?? "N/A"}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('Bank Account: ${leaf.bankAccountName ?? "Bank Account"}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Amount: SAR ${NumberFormat('#,##0.00').format(leaf.amount)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                              _smallBadge('Current: ${leaf.status}', const Color(0xFF0D9488), const Color(0xFFF0FDFA)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('State Transition Timeline & Audit Trail:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 10),

                    SizedBox(
                      height: 280,
                      child: auditAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, _) => Center(child: Text('Error loading audit log: $err')),
                        data: (logs) {
                          if (logs.isEmpty) {
                            return const Center(child: Text('No audit entries recorded yet.'));
                          }
                          return ListView.builder(
                            itemCount: logs.length,
                            itemBuilder: (context, index) {
                              final item = logs[index];
                              final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(item.createdAt));

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        margin: const EdgeInsets.only(top: 4),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF7C3AED),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      if (index < logs.length - 1)
                                        Container(
                                          width: 2,
                                          height: 40,
                                          color: const Color(0xFFE2E8F0),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 14),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                item.actionType.replaceAll('_', ' '),
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                                              ),
                                              Text(dateStr, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'By ${item.performedBy} ${item.previousStatus != null ? "(Status: ${item.previousStatus} → ${item.newStatus})" : "(Status: ${item.newStatus})"}',
                                            style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                                          ),
                                          if (item.remarks != null && item.remarks!.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text('Notes: ${item.remarks}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontStyle: FontStyle.italic)),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Close')),
              ],
            );
          },
        );
      },
    );
  }
}
