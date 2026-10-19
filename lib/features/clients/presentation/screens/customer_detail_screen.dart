import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app.dart';
import '../../providers/client_provider.dart';
import '../../../invoicing/providers/invoice_provider.dart';
import '../../../invoicing/domain/invoice_model.dart';
import '../../domain/client_model.dart';
import '../widgets/customer_help_modal.dart';

enum AgingBucket {
  all('All Periods', 'جميع الفترات', 0, 99999),
  current('0 - 30 Days (Current)', '0 - 30 يوم (الحالية)', 0, 30),
  days31to60('31 - 60 Days', '31 - 60 يوم', 31, 60),
  days61to90('61 - 90 Days', '61 - 90 يوم', 61, 90),
  days91to120('91 - 120 Days', '91 - 120 يوم', 91, 120),
  days120plus('120+ Days (Critical)', 'أكثر من 120 يوم (حرجة)', 121, 99999);

  final String labelEn;
  final String labelAr;
  final int minDays;
  final int maxDays;
  const AgingBucket(this.labelEn, this.labelAr, this.minDays, this.maxDays);

  String getLabel(bool isArabic) => isArabic ? labelAr : labelEn;
}

class CustomerDetailScreen extends ConsumerStatefulWidget {
  final String customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  ConsumerState<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends ConsumerState<CustomerDetailScreen> {
  final TextEditingController _invoiceSearchCtrl = TextEditingController();
  String _invoiceFilter = '';
  int _selectedStatusTab = 0; // 0: All, 1: Pending / Dues Only, 2: Paid
  AgingBucket _selectedAgingBucket = AgingBucket.all;

  @override
  void initState() {
    super.initState();
    _invoiceSearchCtrl.addListener(() {
      setState(() {
        _invoiceFilter = _invoiceSearchCtrl.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _invoiceSearchCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    final d = dt.toLocal();
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${pad(d.month)}-${pad(d.day)} ${pad(d.hour)}:${pad(d.minute)}';
  }

  int _getDaysOld(DateTime issueDate) {
    final diff = DateTime.now().difference(issueDate.toLocal()).inDays;
    return diff < 0 ? 0 : diff;
  }

  AgingBucket _getBucketForDays(int days) {
    if (days <= 30) return AgingBucket.current;
    if (days <= 60) return AgingBucket.days31to60;
    if (days <= 90) return AgingBucket.days61to90;
    if (days <= 120) return AgingBucket.days91to120;
    return AgingBucket.days120plus;
  }

  Color _getBucketColor(AgingBucket bucket) {
    switch (bucket) {
      case AgingBucket.current:
        return Colors.green.shade700;
      case AgingBucket.days31to60:
        return Colors.amber.shade800;
      case AgingBucket.days61to90:
        return Colors.orange.shade800;
      case AgingBucket.days91to120:
        return const Color(0xFFEA580C); // Deep coral
      case AgingBucket.days120plus:
        return Colors.red.shade800;
      case AgingBucket.all:
        return Colors.indigo.shade700;
    }
  }

  Color _getBucketBg(AgingBucket bucket) {
    switch (bucket) {
      case AgingBucket.current:
        return Colors.green.shade50;
      case AgingBucket.days31to60:
        return Colors.amber.shade50;
      case AgingBucket.days61to90:
        return Colors.orange.shade50;
      case AgingBucket.days91to120:
        return const Color(0xFFFFF7ED);
      case AgingBucket.days120plus:
        return Colors.red.shade50;
      case AgingBucket.all:
        return Colors.indigo.shade50;
    }
  }

  Color _getZatcaStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'CLEARED':
      case 'PAID':
        return Colors.green.shade700;
      case 'REPORTED':
        return Colors.teal.shade700;
      case 'PENDING':
      case 'DRAFT':
        return Colors.orange.shade800;
      case 'REJECTED':
      case 'CANCELLED':
      case 'FAILED':
        return Colors.red.shade700;
      default:
        return Colors.blueGrey.shade700;
    }
  }

  Color _getZatcaStatusBg(String status) {
    switch (status.toUpperCase()) {
      case 'CLEARED':
      case 'PAID':
        return Colors.green.shade50;
      case 'REPORTED':
        return Colors.teal.shade50;
      case 'PENDING':
      case 'DRAFT':
        return Colors.orange.shade50;
      case 'REJECTED':
      case 'CANCELLED':
      case 'FAILED':
        return Colors.red.shade50;
      default:
        return Colors.blueGrey.shade50;
    }
  }

  bool _isInvoiceDue(InvoiceModel invoice) {
    final payStatus = invoice.paymentStatus.toUpperCase();
    if (payStatus == 'PAID') return false;
    if (payStatus == 'UNPAID' || payStatus == 'PARTIAL') return true;
    // Default: if status is PENDING and not PAID, consider due
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final clientsState = ref.watch(clientsProvider);
    final invoicesState = ref.watch(customerInvoicesProvider(widget.customerId));
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.indigo),
          tooltip: isArabic ? 'العودة لقائمة العملاء' : 'Back to Customers',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/customers');
            }
          },
        ),
        title: Text(
          isArabic ? 'تفاصيل العميل وتحليل الأعمار' : 'Customer Details & Aging Analysis',
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(isArabic ? Icons.g_translate : Icons.language, color: Colors.indigo),
            tooltip: isArabic ? 'تغيير اللغة إلى الإنجليزية' : 'Switch Language to Arabic',
            onPressed: () {
              ref.read(localeProvider.notifier).state =
                  isArabic ? const Locale('en') : const Locale('ar');
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.indigo),
            tooltip: isArabic ? 'تحديث البيانات' : 'Reload Customer & Invoices',
            onPressed: () {
              ref.invalidate(clientsProvider);
              ref.invalidate(customerInvoicesProvider(widget.customerId));
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.indigo),
            tooltip: isArabic ? 'دليل مساعدة العملاء' : 'Customer Help & Guide',
            onPressed: () => showDialog(
              context: context,
              builder: (ctx) => const CustomerHelpModal(),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: clientsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(isArabic ? 'خطأ في تحميل بيانات العميل: $err' : 'Error loading customer: $err'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: Text(isArabic ? 'إعادة المحاولة' : 'Try Again'),
                onPressed: () => ref.invalidate(clientsProvider),
              ),
            ],
          ),
        ),
        data: (clients) {
          final customer = clients.where((c) => c.id == widget.customerId).firstOrNull;
          if (customer == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_off_outlined, size: 56, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(isArabic ? 'العميل غير موجود' : 'Customer not found', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('ID: ${widget.customerId}', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => context.go('/customers'),
                    child: Text(isArabic ? 'العودة لقائمة العملاء' : 'Return to Customer List'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Customer Overview Card
                _buildCustomerCard(context, customer, isArabic),
                const SizedBox(height: 24),

                // 2. AR Aging Analysis Report (30/60/90/120+)
                invoicesState.when(
                  loading: () => const Center(child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  )),
                  error: (e, _) => const SizedBox.shrink(),
                  data: (invoices) => _buildAgingAnalysisCard(context, customer, invoices, isArabic),
                ),
                const SizedBox(height: 24),

                // 3. Invoices List with Dues & Filter Tabs
                _buildInvoicesSection(context, customer, invoicesState, isArabic),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, ClientModel customer, bool isArabic) {
    final availableCredit = (customer.creditLimit - (customer.dues ?? 0.0)).clamp(0.0, 9999999.0);
    final currency = isArabic ? 'ر.س' : 'SAR';
    final notProvided = isArabic ? 'غير مدخل' : 'Not provided';
    final notAvailable = isArabic ? 'غير محدد' : 'N/A';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.indigo.shade50,
                  child: Text(
                    customer.name.isNotEmpty ? customer.name.substring(0, 1).toUpperCase() : '?',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo.shade800),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              customer.name,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.indigo.shade200),
                            ),
                            child: Text(
                              customer.customerType?.toUpperCase() ?? (isArabic ? 'قياسي' : 'STANDARD'),
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.indigo.shade700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isArabic
                            ? 'معرف العميل: ${customer.id} • تاريخ الإنشاء: ${_formatDate(customer.createdAt)}'
                            : 'Customer ID: ${customer.id} • Created: ${_formatDate(customer.createdAt)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.edit, size: 16),
                  label: Text(isArabic ? 'تعديل البيانات' : 'Edit Details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.indigo,
                    side: BorderSide(color: Colors.indigo.shade300),
                  ),
                  onPressed: () => context.go('/customers/${customer.id}/edit'),
                ),
              ],
            ),
            const Divider(height: 32),

            // Contact & Details
            Wrap(
              spacing: 32,
              runSpacing: 16,
              children: [
                _infoItem(Icons.phone_outlined, isArabic ? 'الهاتف' : 'Phone', customer.phoneNumber ?? notProvided),
                _infoItem(Icons.email_outlined, isArabic ? 'البريد الإلكتروني' : 'Email', customer.email ?? notProvided),
                _infoItem(
                  Icons.location_on_outlined,
                  isArabic ? 'العنوان' : 'Address',
                  [customer.address, customer.city, customer.state, customer.country]
                      .where((e) => e != null && e.trim().isNotEmpty)
                      .join(', ')
                      .ifEmpty(notProvided),
                ),
                _infoItem(Icons.badge_outlined, isArabic ? 'الرقم الضريبي' : 'VAT Number', customer.vatNumber ?? notAvailable),
              ],
            ),
            const SizedBox(height: 24),

            // Financial Status Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _metricBox(
                      isArabic ? 'الائتمان' : 'Permit Credit',
                      customer.permitCredit
                          ? (isArabic ? 'مسموح' : 'PERMITTED')
                          : (isArabic ? 'معطل' : 'DISABLED'),
                      customer.permitCredit ? Colors.green.shade700 : Colors.red.shade700,
                      Icons.credit_score,
                    ),
                  ),
                  _vDivider(),
                  Expanded(
                    child: _metricBox(
                      isArabic ? 'حد الائتمان' : 'Credit Limit',
                      '$currency ${customer.creditLimit.toStringAsFixed(2)}',
                      Colors.indigo.shade800,
                      Icons.account_balance_wallet_outlined,
                    ),
                  ),
                  _vDivider(),
                  Expanded(
                    child: _metricBox(
                      isArabic ? 'المستحقات المكتوبة' : 'Recorded Dues',
                      '$currency ${(customer.dues ?? 0.0).toStringAsFixed(2)}',
                      (customer.dues ?? 0) > 0 ? Colors.orange.shade800 : Colors.grey.shade800,
                      Icons.money_off_csred_outlined,
                    ),
                  ),
                  _vDivider(),
                  Expanded(
                    child: _metricBox(
                      isArabic ? 'الائتمان المتاح' : 'Available Credit',
                      '$currency ${availableCredit.toStringAsFixed(2)}',
                      availableCredit > 0 ? Colors.teal.shade800 : Colors.grey.shade600,
                      Icons.check_circle_outline,
                    ),
                  ),
                  _vDivider(),
                  Expanded(
                    child: _metricBox(
                      isArabic ? 'الرصيد المودع' : 'Pre-deposited Funds',
                      '$currency ${(customer.funds ?? 0.0).toStringAsFixed(2)}',
                      Colors.blue.shade800,
                      Icons.savings_outlined,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgingAnalysisCard(BuildContext context, ClientModel customer, List<InvoiceModel> invoices, bool isArabic) {
    final currency = isArabic ? 'ر.س' : 'SAR';
    // Separate into due vs paid
    final dueInvoices = invoices.where(_isInvoiceDue).toList();
    final paidInvoices = invoices.where((inv) => !_isInvoiceDue(inv)).toList();

    double totalDueAmount = 0.0;
    final Map<AgingBucket, double> bucketAmounts = {
      AgingBucket.current: 0.0,
      AgingBucket.days31to60: 0.0,
      AgingBucket.days61to90: 0.0,
      AgingBucket.days91to120: 0.0,
      AgingBucket.days120plus: 0.0,
    };
    final Map<AgingBucket, int> bucketCounts = {
      AgingBucket.current: 0,
      AgingBucket.days31to60: 0,
      AgingBucket.days61to90: 0,
      AgingBucket.days91to120: 0,
      AgingBucket.days120plus: 0,
    };

    int maxAgeDays = 0;
    int totalAgeDays = 0;

    for (final inv in dueInvoices) {
      final days = _getDaysOld(inv.issueDate);
      final bucket = _getBucketForDays(days);
      bucketAmounts[bucket] = (bucketAmounts[bucket] ?? 0.0) + inv.totalAmount;
      bucketCounts[bucket] = (bucketCounts[bucket] ?? 0) + 1;
      totalDueAmount += inv.totalAmount;
      totalAgeDays += days;
      if (days > maxAgeDays) maxAgeDays = days;
    }

    final avgAgeDays = dueInvoices.isNotEmpty ? (totalAgeDays / dueInvoices.length).round() : 0;
    final highRiskAmount = (bucketAmounts[AgingBucket.days91to120] ?? 0.0) + (bucketAmounts[AgingBucket.days120plus] ?? 0.0);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title & Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.analytics_outlined, color: Colors.indigo, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic
                          ? 'تقرير أعمار الحسابات المدينة (AR)'
                          : 'Accounts Receivable (AR) Aging Analysis Report',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    Text(
                      isArabic
                          ? 'تفصيل أعمار أرصدة الفواتير غير المسددة: الحالية (0-30)، 31-60، 61-90، 91-120، وأكثر من 120 يوماً'
                          : 'Outstanding invoice balance aging breakdown: Current (0-30), 31-60, 61-90, 91-120, and 120+ days',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const Spacer(),
                // Quick Summary Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: totalDueAmount > 0 ? Colors.red.shade50 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: totalDueAmount > 0 ? Colors.red.shade200 : Colors.green.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        totalDueAmount > 0 ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                        size: 16,
                        color: totalDueAmount > 0 ? Colors.red.shade700 : Colors.green.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isArabic
                            ? 'إجمالي المستحقات: $currency ${totalDueAmount.toStringAsFixed(2)} (${dueInvoices.length} غير مسدد)'
                            : 'Total Dues: SAR ${totalDueAmount.toStringAsFixed(2)} (${dueInvoices.length} unpaid)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: totalDueAmount > 0 ? Colors.red.shade800 : Colors.green.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 28),

            // Summary Metrics Bar
            Row(
              children: [
                _agingSummaryBox(
                  isArabic ? 'إجمالي الفواتير' : 'Total Invoices',
                  isArabic ? '${invoices.length} إجمالي' : '${invoices.length} total',
                  isArabic
                      ? '${paidInvoices.length} مسددة / ${dueInvoices.length} معلقة'
                      : '${paidInvoices.length} settled / ${dueInvoices.length} pending',
                  Colors.blueGrey.shade800,
                  Icons.receipt_long,
                ),
                const SizedBox(width: 16),
                _agingSummaryBox(
                  isArabic ? 'المستحقات القائمة' : 'Outstanding Dues',
                  '$currency ${totalDueAmount.toStringAsFixed(2)}',
                  totalDueAmount > 0
                      ? (isArabic ? 'تتطلب تحصيل' : 'Requires collection')
                      : (isArabic ? 'مسددة بالكامل' : 'Fully paid'),
                  totalDueAmount > 0 ? Colors.red.shade700 : Colors.green.shade700,
                  Icons.payments_outlined,
                ),
                const SizedBox(width: 16),
                _agingSummaryBox(
                  isArabic ? 'متوسط عمر الفاتورة' : 'Average Invoice Age',
                  isArabic ? '$avgAgeDays يوم' : '$avgAgeDays days',
                  dueInvoices.isNotEmpty
                      ? (isArabic ? 'عبر الفواتير المعلقة' : 'Across pending invoices')
                      : (isArabic ? 'لا توجد فواتير متأخرة' : 'No overdue invoices'),
                  Colors.indigo.shade800,
                  Icons.schedule,
                ),
                const SizedBox(width: 16),
                _agingSummaryBox(
                  isArabic ? 'مخاطر عالية (>90 يوم)' : 'High Risk (>90 Days)',
                  '$currency ${highRiskAmount.toStringAsFixed(2)}',
                  maxAgeDays > 90
                      ? (isArabic ? 'الأقدم: منذ $maxAgeDays يوم' : 'Oldest: $maxAgeDays days ago')
                      : (isArabic ? 'لا توجد أرصدة عالية المخاطر' : 'No high risk balances'),
                  highRiskAmount > 0 ? Colors.red.shade900 : Colors.teal.shade700,
                  Icons.priority_high,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Aging Buckets Row (30 / 60 / 90 / 120+)
            Text(
              isArabic
                  ? 'فترات التعتيق (انقر لتصفية الفواتير حسب الفترة):'
                  : 'Aging Buckets (Click to filter invoices by period):',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                // 0 - 30 Days
                Expanded(
                  child: _bucketCard(
                    bucket: AgingBucket.current,
                    amount: bucketAmounts[AgingBucket.current] ?? 0.0,
                    count: bucketCounts[AgingBucket.current] ?? 0,
                    totalDue: totalDueAmount,
                    isArabic: isArabic,
                  ),
                ),
                const SizedBox(width: 12),
                // 31 - 60 Days
                Expanded(
                  child: _bucketCard(
                    bucket: AgingBucket.days31to60,
                    amount: bucketAmounts[AgingBucket.days31to60] ?? 0.0,
                    count: bucketCounts[AgingBucket.days31to60] ?? 0,
                    totalDue: totalDueAmount,
                    isArabic: isArabic,
                  ),
                ),
                const SizedBox(width: 12),
                // 61 - 90 Days
                Expanded(
                  child: _bucketCard(
                    bucket: AgingBucket.days61to90,
                    amount: bucketAmounts[AgingBucket.days61to90] ?? 0.0,
                    count: bucketCounts[AgingBucket.days61to90] ?? 0,
                    totalDue: totalDueAmount,
                    isArabic: isArabic,
                  ),
                ),
                const SizedBox(width: 12),
                // 91 - 120 Days
                Expanded(
                  child: _bucketCard(
                    bucket: AgingBucket.days91to120,
                    amount: bucketAmounts[AgingBucket.days91to120] ?? 0.0,
                    count: bucketCounts[AgingBucket.days91to120] ?? 0,
                    totalDue: totalDueAmount,
                    isArabic: isArabic,
                  ),
                ),
                const SizedBox(width: 12),
                // 120+ Days
                Expanded(
                  child: _bucketCard(
                    bucket: AgingBucket.days120plus,
                    amount: bucketAmounts[AgingBucket.days120plus] ?? 0.0,
                    count: bucketCounts[AgingBucket.days120plus] ?? 0,
                    totalDue: totalDueAmount,
                    isArabic: isArabic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _agingSummaryBox(String title, String mainValue, String subValue, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(mainValue, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(height: 1),
                  Text(subValue, style: TextStyle(fontSize: 10, color: Colors.grey.shade500), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bucketCard({
    required AgingBucket bucket,
    required double amount,
    required int count,
    required double totalDue,
    required bool isArabic,
  }) {
    final isSelected = _selectedAgingBucket == bucket;
    final color = _getBucketColor(bucket);
    final bg = _getBucketBg(bucket);
    final percent = totalDue > 0 ? (amount / totalDue) * 100 : 0.0;
    final currency = isArabic ? 'ر.س' : 'SAR';

    return InkWell(
      onTap: () {
        setState(() {
          _selectedAgingBucket = isSelected ? AgingBucket.all : bucket;
          // If a specific aging bucket is clicked, switch view to Pending/Dues tab automatically
          if (!isSelected) {
            _selectedStatusTab = 1; // Pending / Dues only
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? bg : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 3))]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    bucket.getLabel(isArabic),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : const Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected)
                  Icon(Icons.filter_alt, size: 14, color: color),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$currency ${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: amount > 0 ? color : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isArabic ? '$count فاتورة' : '$count invoice${count == 1 ? '' : 's'}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                Text(
                  '${percent.toStringAsFixed(1)}%',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (percent / 100.0).clamp(0.0, 1.0),
                backgroundColor: Colors.grey.shade200,
                color: color,
                minHeight: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoicesSection(
      BuildContext context, ClientModel customer, AsyncValue<List<InvoiceModel>> invoicesState, bool isArabic) {
    final currency = isArabic ? 'ر.س' : 'SAR';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar: Tabs & Search
            Row(
              children: [
                // Filter Tabs: All / Pending Dues / Paid
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Row(
                    children: [
                      _statusTabButton(0, isArabic ? 'جميع الفواتير' : 'All Invoices'),
                      _statusTabButton(1, isArabic ? 'المستحقات والمعلقة فقط' : 'Pending / Dues Only'),
                      _statusTabButton(2, isArabic ? 'المسددة والمدفوعة' : 'Settled & Paid'),
                    ],
                  ),
                ),
                const Spacer(),
                // Aging Filter Reset
                if (_selectedAgingBucket != AgingBucket.all) ...[
                  InputChip(
                    label: Text(
                      isArabic
                          ? 'الفترة: ${_selectedAgingBucket.getLabel(true)}'
                          : 'Bucket: ${_selectedAgingBucket.labelEn}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    onDeleted: () => setState(() => _selectedAgingBucket = AgingBucket.all),
                    deleteIconColor: _getBucketColor(_selectedAgingBucket),
                    backgroundColor: _getBucketBg(_selectedAgingBucket),
                  ),
                  const SizedBox(width: 12),
                ],
                // Search Input
                SizedBox(
                  width: 250,
                  height: 38,
                  child: TextField(
                    controller: _invoiceSearchCtrl,
                    decoration: InputDecoration(
                      hintText: isArabic ? 'بحث في الفواتير...' : 'Search invoices...',
                      prefixIcon: const Icon(Icons.search, size: 18),
                      suffixIcon: _invoiceFilter.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 16),
                              onPressed: () => _invoiceSearchCtrl.clear(),
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 28),

            // Invoices Data
            invoicesState.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isArabic ? 'فشل تحميل الفواتير: $err' : 'Failed to load invoices: $err',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(customerInvoicesProvider(widget.customerId)),
                      child: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
                    ),
                  ],
                ),
              ),
              data: (invoices) {
                // 1. Status Filter Tab
                List<InvoiceModel> list = invoices;
                if (_selectedStatusTab == 1) {
                  // Pending / Dues only
                  list = list.where(_isInvoiceDue).toList();
                } else if (_selectedStatusTab == 2) {
                  // Paid only
                  list = list.where((inv) => !_isInvoiceDue(inv)).toList();
                }

                // 2. Aging Bucket Filter
                if (_selectedAgingBucket != AgingBucket.all) {
                  list = list.where((inv) {
                    final days = _getDaysOld(inv.issueDate);
                    return days >= _selectedAgingBucket.minDays && days <= _selectedAgingBucket.maxDays;
                  }).toList();
                }

                // 3. Search Query Filter
                final filtered = list.where((inv) {
                  if (_invoiceFilter.isEmpty) return true;
                  return inv.invoiceNumber.toLowerCase().contains(_invoiceFilter) ||
                      inv.status.toLowerCase().contains(_invoiceFilter) ||
                      inv.paymentStatus.toLowerCase().contains(_invoiceFilter) ||
                      inv.totalAmount.toString().contains(_invoiceFilter);
                }).toList();

                if (invoices.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.receipt_outlined, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            isArabic ? 'لا توجد فواتير مسجلة' : 'No Invoices Recorded',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isArabic
                                ? 'لم يتم إصدار أي فواتير مبيعات أو ضريبية للعميل "${customer.name}" بعد.'
                                : 'No sales or tax invoices have been billed to "${customer.name}" yet.',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (filtered.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    child: Center(
                      child: Text(
                        isArabic
                            ? 'لا توجد فواتير تطابق الحالة المحددة أو الفترة أو فلتر البحث.'
                            : 'No invoices match your selected status, aging bucket, or search filter.',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  );
                }

                final totalFiltered = filtered.fold<double>(0.0, (sum, inv) => sum + inv.totalAmount);

                return Column(
                  children: [
                    // Summary Banner above list
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isArabic
                                ? 'عرض ${filtered.length} من أصل ${invoices.length} فاتورة'
                                : 'Showing ${filtered.length} of ${invoices.length} invoices',
                            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.indigo.shade900),
                          ),
                          Text(
                            isArabic
                                ? 'المجموع الفرعي: $currency ${totalFiltered.toStringAsFixed(2)}'
                                : 'Subtotal: SAR ${totalFiltered.toStringAsFixed(2)}',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade900),
                          ),
                        ],
                      ),
                    ),

                    // Invoices List
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final invoice = filtered[index];
                        final daysOld = _getDaysOld(invoice.issueDate);
                        final bucket = _getBucketForDays(daysOld);
                        final isDue = _isInvoiceDue(invoice);

                        final zatcaColor = _getZatcaStatusColor(invoice.status);
                        final zatcaBg = _getZatcaStatusBg(invoice.status);
                        final bucketColor = _getBucketColor(bucket);
                        final bucketBg = _getBucketBg(bucket);

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isDue ? Colors.red.shade50 : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDue ? Colors.red.shade200 : Colors.green.shade200,
                              ),
                            ),
                            child: Icon(
                              isDue ? Icons.money_off_csred_outlined : Icons.receipt_outlined,
                              color: isDue ? Colors.red.shade700 : Colors.green.shade700,
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                invoice.invoiceNumber,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(width: 8),
                              // Payment Status Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isDue ? Colors.red.shade50 : Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDue ? Colors.red.shade300 : Colors.green.shade300,
                                  ),
                                ),
                                child: Text(
                                  isDue
                                      ? (isArabic ? 'غير مسدد' : 'UNPAID')
                                      : (isArabic ? 'مدفوع' : 'PAID'),
                                  style: TextStyle(
                                    color: isDue ? Colors.red.shade800 : Colors.green.shade800,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              // ZATCA Status Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: zatcaBg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: zatcaColor.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  'ZATCA: ${invoice.status}',
                                  style: TextStyle(color: zatcaColor, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Aging Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: bucketBg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: bucketColor.withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  isArabic
                                      ? '$daysOld يوم (${bucket.getLabel(true).split(' ')[0]})'
                                      : '$daysOld days (${bucket.labelEn.split(' ')[0]})',
                                  style: TextStyle(color: bucketColor, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              children: [
                                Text(
                                  isArabic
                                      ? 'تاريخ الإصدار: ${_formatDate(invoice.issueDate)}'
                                      : 'Issued: ${_formatDate(invoice.issueDate)}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  isArabic
                                      ? 'الضريبة (15%): $currency ${invoice.vatAmount.toStringAsFixed(2)}'
                                      : 'VAT (15%): SAR ${invoice.vatAmount.toStringAsFixed(2)}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                                if (isDue) ...[
                                  const SizedBox(width: 16),
                                  Text(
                                    isArabic
                                        ? 'المبلغ المستحق: $currency ${invoice.totalAmount.toStringAsFixed(2)}'
                                        : 'Due Amount: SAR ${invoice.totalAmount.toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red.shade800),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '$currency ${invoice.totalAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isDue
                                        ? (isArabic ? 'غير محصل' : 'UNCOLLECTED')
                                        : (isArabic ? 'مدفوع' : 'PAID'),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isDue ? Colors.red.shade700 : Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.visibility_outlined, size: 16),
                                label: Text(isArabic ? 'عرض' : 'View'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  foregroundColor: Colors.indigo,
                                ),
                                onPressed: () => context.go('/invoices/${invoice.id}'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusTabButton(int index, String label) {
    final isSelected = _selectedStatusTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedStatusTab = index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.indigo.shade900 : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
          ],
        ),
      ],
    );
  }

  Widget _metricBox(String title, String value, Color color, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _vDivider() {
    return Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.grey.shade300,
    );
  }
}

extension _StringEmptyExt on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}
