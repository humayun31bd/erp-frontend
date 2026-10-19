import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/routing/route_names.dart';
import '../domain/supplier_model.dart';
import '../providers/suppliers_provider.dart';

final supplierAgingProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, id) async {
  final api = ref.watch(supplierApiProvider);
  final data = await api.getSupplierAging(id);
  return Map<String, dynamic>.from(data as Map);
});

class SupplierDetailScreen extends ConsumerStatefulWidget {
  final String supplierId;
  final SupplierModel? supplier;

  const SupplierDetailScreen({super.key, required this.supplierId, this.supplier});

  @override
  ConsumerState<SupplierDetailScreen> createState() => _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends ConsumerState<SupplierDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  Future<void> _makePhoneCall(String phone) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final agingAsync = ref.watch(supplierAgingProvider(widget.supplierId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isArabic ? 'تفاصيل المورد وتخليل الأعمار الزمانية (AP Aging)' : 'Supplier Details & AP Aging Analysis',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF4361EE)),
            onPressed: () => ref.invalidate(supplierAgingProvider(widget.supplierId)),
            tooltip: isArabic ? 'تحديث البيانات' : 'Refresh Data',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: agingAsync.when(
        data: (data) {
          final supplierJson = data['supplier'] as Map<String, dynamic>?;
          final agingSummary = data['agingSummary'] as Map<String, dynamic>? ?? {};
          final billsList = (data['bills'] as List<dynamic>?) ?? [];

          final supplierName = supplierJson?['name'] ?? widget.supplier?.name ?? 'Supplier';
          final vatNumber = supplierJson?['vatNumber'] ?? widget.supplier?.vatNumber;
          final crNumber = supplierJson?['crNumber'] ?? widget.supplier?.crNumber;
          final phoneNumber = supplierJson?['phoneNumber'] ?? widget.supplier?.phoneNumber;
          final email = supplierJson?['email'] ?? widget.supplier?.email;
          final address = supplierJson?['address'] ?? widget.supplier?.address;
          final bankDetails = supplierJson?['bankDetails'] ?? widget.supplier?.bankDetails;
          final category = supplierJson?['category'] ?? widget.supplier?.category ?? 'MERCHANDISE';
          final supplierTier = supplierJson?['supplierTier'] ?? widget.supplier?.supplierTier ?? 'TIER_2_STANDARD';
          final paymentTerms = supplierJson?['paymentTerms'] ?? widget.supplier?.paymentTerms ?? 'NET_30';

          final totalPayable = (agingSummary['totalPayable'] as num?)?.toDouble() ?? 0.0;
          final current0to30 = (agingSummary['current0to30'] as num?)?.toDouble() ?? 0.0;
          final days31to60 = (agingSummary['days31to60'] as num?)?.toDouble() ?? 0.0;
          final days61to90 = (agingSummary['days61to90'] as num?)?.toDouble() ?? 0.0;
          final days90Plus = (agingSummary['days90Plus'] as num?)?.toDouble() ?? 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Supplier Profile Summary Card
                _buildProfileCard(
                  context,
                  isArabic,
                  supplierName: supplierName,
                  vatNumber: vatNumber,
                  crNumber: crNumber,
                  phoneNumber: phoneNumber,
                  email: email,
                  address: address,
                  bankDetails: bankDetails,
                  category: category,
                  supplierTier: supplierTier,
                  paymentTerms: paymentTerms,
                  supplierModel: widget.supplier,
                ),
                const SizedBox(height: 24),

                // 2. AP Aging Analysis Overview Title
                Row(
                  children: [
                    const Icon(Icons.analytics_rounded, color: Color(0xFF4361EE), size: 22),
                    const SizedBox(width: 8),
                    Text(
                      isArabic ? 'تحليل أعمار الديون والمستحقات (AP Aging Matrix)' : 'Accounts Payable (AP) Aging Breakdown',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // AP Aging Summary Cards Row
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 800;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildAgingMetricCard(
                          title: isArabic ? 'إجمالي المستحقات' : 'Total AP Balance',
                          amount: totalPayable,
                          color: const Color(0xFF4361EE),
                          icon: Icons.account_balance_wallet_rounded,
                          width: isWide ? (constraints.maxWidth - 48) / 5 : (constraints.maxWidth - 12) / 2,
                        ),
                        _buildAgingMetricCard(
                          title: isArabic ? 'جاري (0 - 30 يوم)' : '0–30 Days (Current)',
                          amount: current0to30,
                          color: const Color(0xFF10B981),
                          icon: Icons.check_circle_outline_rounded,
                          width: isWide ? (constraints.maxWidth - 48) / 5 : (constraints.maxWidth - 12) / 2,
                        ),
                        _buildAgingMetricCard(
                          title: isArabic ? 'متأخر (31 - 60 يوم)' : '31–60 Days Overdue',
                          amount: days31to60,
                          color: const Color(0xFFF59E0B),
                          icon: Icons.access_time_rounded,
                          width: isWide ? (constraints.maxWidth - 48) / 5 : (constraints.maxWidth - 12) / 2,
                        ),
                        _buildAgingMetricCard(
                          title: isArabic ? 'متأخر (61 - 90 يوم)' : '61–90 Days Overdue',
                          amount: days61to90,
                          color: const Color(0xFFF97316),
                          icon: Icons.warning_amber_rounded,
                          width: isWide ? (constraints.maxWidth - 48) / 5 : (constraints.maxWidth - 12) / 2,
                        ),
                        _buildAgingMetricCard(
                          title: isArabic ? 'حرج (+90 يوم متأخر)' : '90+ Days (Critical)',
                          amount: days90Plus,
                          color: const Color(0xFFEF4444),
                          icon: Icons.report_problem_rounded,
                          width: isWide ? (constraints.maxWidth - 48) / 5 : constraints.maxWidth,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // 3. Transactions & Bills Ledger Tab Section
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        labelColor: const Color(0xFF4361EE),
                        unselectedLabelColor: const Color(0xFF64748B),
                        indicatorColor: const Color(0xFF4361EE),
                        tabs: [
                          Tab(text: isArabic ? 'فواتير ومستندات الشراء (${billsList.length})' : 'Purchase Bills & Invoices (${billsList.length})'),
                          Tab(text: isArabic ? 'شروط السداد والحساب البنكي' : 'Banking & Payment Terms'),
                        ],
                      ),
                      SizedBox(
                        height: 360,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Tab 1: Bills & Invoices Table
                            _buildBillsTab(billsList, isArabic),

                            // Tab 2: Payment Terms & Bank Info
                            _buildBankingTab(isArabic, bankDetails, paymentTerms, category, supplierTier),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(isArabic ? 'حدث خطأ أثناء تحميل بيانات الأعمار الزمانية: $err' : 'Error loading supplier AP aging: $err'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(supplierAgingProvider(widget.supplierId)),
                child: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    bool isArabic, {
    required String supplierName,
    String? vatNumber,
    String? crNumber,
    String? phoneNumber,
    String? email,
    String? address,
    String? bankDetails,
    required String category,
    required String supplierTier,
    required String paymentTerms,
    SupplierModel? supplierModel,
  }) {
    final hasVat = vatNumber != null && vatNumber.isNotEmpty;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF4361EE).withValues(alpha: 0.1),
                  child: Text(
                    supplierName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF4361EE)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            supplierName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(width: 10),
                          _buildTierChip(supplierTier, isArabic),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: hasVat ? const Color(0xFF10B981).withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              hasVat ? 'VAT: $vatNumber' : (isArabic ? 'بدون رقم ضريبي' : 'No VAT Registered'),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: hasVat ? const Color(0xFF10B981) : Colors.orange.shade800,
                              ),
                            ),
                          ),
                          if (crNumber != null && crNumber.isNotEmpty)
                            Text('CR: $crNumber', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          Text('Category: $category', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          Text('Terms: $paymentTerms', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        ],
                      ),
                    ],
                  ),
                ),

                // Edit Profile Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4361EE),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    if (supplierModel != null) {
                      context.pushNamed(RouteNames.editSupplier, extra: supplierModel);
                    }
                  },
                  icon: const Icon(Icons.edit_rounded, size: 18, color: Colors.white),
                  label: Text(isArabic ? 'تعديل الملف' : 'Edit Profile', style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 12),

            // Quick Info Chips: Phone, Email, Address, Bank
            Row(
              children: [
                if (phoneNumber != null && phoneNumber.isNotEmpty)
                  InkWell(
                    onTap: () => _makePhoneCall(phoneNumber),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.phone_rounded, size: 16, color: Color(0xFF3B82F6)),
                          const SizedBox(width: 6),
                          Text(phoneNumber, style: const TextStyle(fontSize: 13, color: Color(0xFF3B82F6), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                if (email != null && email.isNotEmpty)
                  InkWell(
                    onTap: () => _sendEmail(email),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.email_rounded, size: 16, color: Color(0xFF3B82F6)),
                          const SizedBox(width: 6),
                          Text(email, style: const TextStyle(fontSize: 13, color: Color(0xFF3B82F6), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                if (address != null && address.isNotEmpty)
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFFEF4444)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(address, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierChip(String tier, bool isArabic) {
    Color color;
    String label;
    if (tier == 'TIER_1_PREFERRED') {
      color = const Color(0xFFF59E0B);
      label = isArabic ? 'فئة أ - مفضل ⭐' : 'Tier 1 Preferred ⭐';
    } else if (tier == 'TIER_3_TRIAL') {
      color = const Color(0xFF64748B);
      label = isArabic ? 'فئة ج - تجريبي' : 'Tier 3 Trial';
    } else {
      color = const Color(0xFF3B82F6);
      label = isArabic ? 'فئة ب - معتمد' : 'Tier 2 Standard';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _buildAgingMetricCard({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${amount.toStringAsFixed(2)} SAR',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: amount > 0 ? color : const Color(0xFF0F172A)),
          ),
        ],
      ),
    );
  }

  Widget _buildBillsTab(List<dynamic> bills, bool isArabic) {
    if (bills.isEmpty) {
      return Center(
        child: Text(isArabic ? 'لا توجد فواتير أو مستندات سداد لهذه المورد' : 'No purchase bills or invoices recorded for this supplier.'),
      );
    }

    return SingleChildScrollView(
      child: DataTable(
        columnSpacing: 20,
        headingRowHeight: 40,
        dataRowMinHeight: 40,
        columns: [
          DataColumn(label: Text(isArabic ? 'رقم الفاتورة' : 'Bill Number', style: const TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text(isArabic ? 'تاريخ الإصدار' : 'Issue Date', style: const TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text(isArabic ? 'تاريخ الاستحقاق' : 'Due Date', style: const TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text(isArabic ? 'أيام التأخير' : 'Overdue Days', style: const TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text(isArabic ? 'المبلغ الإجمالي' : 'Total Amount', style: const TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text(isArabic ? 'الرصيد المتبقي' : 'Balance Payable', style: const TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text(isArabic ? 'الحالة' : 'Status', style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: bills.map((b) {
          final overdueDays = (b['overdueDays'] as num?)?.toInt() ?? 0;
          final total = (b['totalAmount'] as num?)?.toDouble() ?? 0.0;
          final balance = (b['balanceAmount'] as num?)?.toDouble() ?? 0.0;
          final status = b['status'] as String? ?? 'UNPAID';

          return DataRow(cells: [
            DataCell(Text(b['billNumber'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
            DataCell(Text(b['issueDate'] != null ? b['issueDate'].toString().substring(0, 10) : '-', style: const TextStyle(fontSize: 12))),
            DataCell(Text(b['dueDate'] != null ? b['dueDate'].toString().substring(0, 10) : '-', style: const TextStyle(fontSize: 12))),
            DataCell(
              Text(
                overdueDays > 0 ? '$overdueDays days' : 'Current',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: overdueDays > 0 ? Colors.red : Colors.green),
              ),
            ),
            DataCell(Text('${total.toStringAsFixed(2)} SAR', style: const TextStyle(fontSize: 12.5))),
            DataCell(Text('${balance.toStringAsFixed(2)} SAR', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFEF4444)))),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: status == 'FULLY_PAID' ? const Color(0xFF10B981).withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: status == 'FULLY_PAID' ? const Color(0xFF10B981) : Colors.red),
                ),
              ),
            ),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildBankingTab(bool isArabic, String? bankDetails, String paymentTerms, String category, String supplierTier) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoTile(isArabic ? 'تفاصيل الحساب البنكي والآيبان (IBAN)' : 'Banking & IBAN Details', bankDetails ?? 'Not provided', Icons.account_balance_rounded),
          const SizedBox(height: 16),
          _buildInfoTile(isArabic ? 'شروط السداد (Payment Terms)' : 'Credit & Payment Terms', paymentTerms, Icons.payments_rounded),
          const SizedBox(height: 16),
          _buildInfoTile(isArabic ? 'نشاط المورد' : 'Business Category', category, Icons.storefront_rounded),
          const SizedBox(height: 16),
          _buildInfoTile(isArabic ? 'تصنيف الجودة والاعتماد' : 'Vendor Tier Rating', supplierTier, Icons.star_rounded),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4361EE), size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          ],
        ),
      ],
    );
  }
}
