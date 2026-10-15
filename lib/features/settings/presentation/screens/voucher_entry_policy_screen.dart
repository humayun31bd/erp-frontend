import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:erp_frontend/core/routing/route_names.dart';
import 'package:erp_frontend/core/network/dio_client.dart';
import 'package:erp_frontend/features/accounting/utils/voucher_number_helper.dart';
import 'package:erp_frontend/app.dart';

class VoucherEntryPolicyScreen extends StatelessWidget {
  const VoucherEntryPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: VoucherEntryPolicyContent(),
      ),
    );
  }
}

class VoucherEntryPolicyContent extends ConsumerStatefulWidget {
  const VoucherEntryPolicyContent({super.key});

  @override
  ConsumerState<VoucherEntryPolicyContent> createState() => _VoucherEntryPolicyContentState();
}

class _VoucherEntryPolicyContentState extends ConsumerState<VoucherEntryPolicyContent> {
  bool _isLoading = true;
  bool _isSaving = false;

  bool _requireCashierApproval = true;
  String _posVoucherControl = 'ACCOUNTANT_APPROVAL'; // 'DIRECT_POST' | 'ACCOUNTANT_APPROVAL'
  bool _directPostSystemVouchers = true;

  final TextEditingController _pvController = TextEditingController(text: 'PV');
  final TextEditingController _rvController = TextEditingController(text: 'RV');
  final TextEditingController _cvController = TextEditingController(text: 'CV');
  final TextEditingController _jvController = TextEditingController(text: 'JV');

  String _numberingFormula = '{TYPE}-{YYYY}-{MM}-{DD}-{SEQ}';
  String _resetPeriod = 'YEARLY'; // 'YEARLY' | 'QUARTERLY' | 'MONTHLY' | 'NEVER'
  int _seqPadding = 6;

  @override
  void initState() {
    super.initState();
    _fetchPolicy();
  }

  @override
  void dispose() {
    _pvController.dispose();
    _rvController.dispose();
    _cvController.dispose();
    _jvController.dispose();
    super.dispose();
  }

  Future<void> _fetchPolicy() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/accounting/voucher-policy');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final policy = response.data['policy'];
        if (policy != null) {
          setState(() {
            _requireCashierApproval = policy['requireCashierApproval'] ?? true;
            _posVoucherControl = policy['posVoucherControl'] ?? 'ACCOUNTANT_APPROVAL';
            _directPostSystemVouchers = policy['directPostSystemVouchers'] ?? true;

            _pvController.text = policy['pvCode'] ?? 'PV';
            _rvController.text = policy['rvCode'] ?? 'RV';
            _cvController.text = policy['cvCode'] ?? 'CV';
            _jvController.text = policy['jvCode'] ?? 'JV';

            _numberingFormula = policy['numberingFormula'] ?? '{TYPE}-{YYYY}-{MM}-{DD}-{SEQ}';
            _resetPeriod = policy['resetPeriod'] ?? 'YEARLY';
            _seqPadding = policy['seqPadding'] ?? 6;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching voucher policy: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _savePolicy(bool isArabic) async {
    setState(() => _isSaving = true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/accounting/voucher-policy', data: {
        'requireCashierApproval': _requireCashierApproval,
        'posVoucherControl': _posVoucherControl,
        'directPostSystemVouchers': _directPostSystemVouchers,
        'pvCode': _pvController.text.trim().toUpperCase(),
        'rvCode': _rvController.text.trim().toUpperCase(),
        'cvCode': _cvController.text.trim().toUpperCase(),
        'jvCode': _jvController.text.trim().toUpperCase(),
        'numberingFormula': _numberingFormula,
        'resetPeriod': _resetPeriod,
        'seqPadding': _seqPadding,
      });

      if (mounted) {
        if (response.statusCode == 200 && response.data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isArabic
                    ? 'تم حفظ صيغة ورقم السندات وسياسة الاعتماد بنجاح'
                    : 'Voucher Numbering Formula & Policy saved successfully!',
              ),
              backgroundColor: Colors.green.shade800,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${isArabic ? "فشل حفظ السياسة: " : "Failed to save policy: "}$e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade900, Colors.blue.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade900.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.policy_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'سياسة إدخال واعتماد السندات المالية' : 'Voucher Entry & Approval Policy',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isArabic
                            ? 'إدارة قواعد اعتماد سندات الكاشير ومبيعات POS والقيد المباشر في الأستاذ العام'
                            : 'Configure Maker-Checker approval rules for Cashier entries, POS Day-End vouchers, and direct GL posting.',
                        style: TextStyle(color: Colors.blue.shade100, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => context.goNamed(RouteNames.voucherApproval),
                  icon: const Icon(Icons.rule_folder_rounded, size: 18),
                  label: Text(isArabic ? 'مركز الاعتماد' : 'Approval Queue'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.indigo.shade900,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Section 1: Cashier & Manual Voucher Rule
          Text(
            isArabic ? '1. سياسة السندات اليدوية والكاشير' : '1. Manual & Cashier Voucher Policy',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 8),
          Text(
            isArabic
                ? 'تحديد ما إذا كانت السندات المدخلة بواسطة الكاشير تتطلب اعتماد المحاسب قبل تحديث رصيد الأستاذ.'
                : 'Control whether vouchers entered by cashiers require Accountant approval before updating General Ledger balances.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPolicyCard(
                  title: isArabic ? 'اعتماد المحاسب مطلوب (Maker-Checker)' : 'Require Accountant Approval',
                  subtitle: isArabic
                      ? 'يتم حفظ القيد كمسودة (DRAFT). لا يتأثر الأستاذ العام إلا بعد اعتماد المحاسب.'
                      : 'Voucher is saved as DRAFT. Ledger balance updates ONLY after Accountant approval.',
                  icon: Icons.admin_panel_settings_rounded,
                  color: Colors.amber.shade800,
                  isSelected: _requireCashierApproval,
                  onTap: () => setState(() => _requireCashierApproval = true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPolicyCard(
                  title: isArabic ? 'ترحيل مباشر تلقائي' : 'Direct Auto-Posting',
                  subtitle: isArabic
                      ? 'يتم ترحيل السند فوراً إلى الأستاذ العام بمجرد حفظه بواسطة الكاشير.'
                      : 'Voucher posts immediately to General Ledger upon creation.',
                  icon: Icons.bolt_rounded,
                  color: Colors.green.shade700,
                  isSelected: !_requireCashierApproval,
                  onTap: () => setState(() => _requireCashierApproval = false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Section 2: POS Transaction Vouchers
          Text(
            isArabic ? '2. سندات مبيعات نقطة البيع (POS Day-End)' : '2. POS Transaction Day-End Vouchers',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 8),
          Text(
            isArabic
                ? 'التحكم في سندات التسوية اليومية الناتجة عن إغلاق ورديات نقطة البيع (POS).'
                : 'Control approval requirements for POS shift closure and day-end vouchers.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPolicyCard(
                  title: isArabic ? 'تحكم المحاسب بالتدقيق والاعتماد' : 'Accountant Control & Audit',
                  subtitle: isArabic
                      ? 'سندات الوردية اليومية للـ POS تتطلب مراجعة واعتماد المحاسب قبل الترحيل.'
                      : 'POS shift day-end vouchers require Accountant review & approval before posting to GL.',
                  icon: Icons.fact_check_rounded,
                  color: Colors.purple.shade700,
                  isSelected: _posVoucherControl == 'ACCOUNTANT_APPROVAL',
                  onTap: () => setState(() => _posVoucherControl = 'ACCOUNTANT_APPROVAL'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPolicyCard(
                  title: isArabic ? 'ترحيل مباشر لسندات الـ POS' : 'Direct Post POS Vouchers',
                  subtitle: isArabic
                      ? 'ترحيل تلقائي ومباشر لسندات الـ POS إلى الأستاذ العام عند إغلاق الورديات.'
                      : 'Automated direct posting of POS vouchers to GL upon shift close.',
                  icon: Icons.sync_alt_rounded,
                  color: Colors.blue.shade700,
                  isSelected: _posVoucherControl == 'DIRECT_POST',
                  onTap: () => setState(() => _posVoucherControl = 'DIRECT_POST'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Section 3: Automated Module Vouchers (Invoices, Purchases, Stock)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.apps_rounded, color: Colors.blue.shade700),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic ? 'سندات الأنظمة التلقائية الأخرى' : 'Automated System & Module Vouchers',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isArabic
                              ? 'السندات المولدة تلقائياً من المشتريات، فواتير المبيعات، وحركات المخزون يتم ترحيلها مباشرة.'
                              : 'Vouchers auto-generated from Sales Invoices, Purchase Orders, and Stock Movements directly post to GL.',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _directPostSystemVouchers,
                    onChanged: (v) => setState(() => _directPostSystemVouchers = v),
                    activeThumbColor: Colors.blue.shade700,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Section 4: Voucher Numbering Formula & Sequence Reset Settings
          Text(
            isArabic ? '4. معادلة ورقم السند وتصفير السلسلة (Voucher Number Formula & Reset)' : '4. Voucher Number Formula & Sequence Reset Settings',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 8),
          Text(
            isArabic
                ? 'إعداد صيغة الترقيم (رمز السند - السنة - الشهر - اليوم - الرقم التسلسلي 6 خانات) وتحديد فترة تصفير السلسلة.'
                : 'Configure the voucher numbering formula (Type Code - Year - Month - Day - 6 Digit Sequence) and sequence reset frequency.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type Codes Grid
                  Text(
                    isArabic ? 'رموز أنواع السندات (Voucher Type Codes):' : 'Voucher Type Codes (PV, RV, CV, JV):',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _pvController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: isArabic ? 'سند صرف (PV)' : 'Payment Voucher Code',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.north_east_rounded, color: Colors.red),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _rvController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: isArabic ? 'سند قبض (RV)' : 'Receipt Voucher Code',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.south_west_rounded, color: Colors.green),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _cvController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: isArabic ? 'سند تحويل (CV)' : 'Contra Voucher Code',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.swap_horiz_rounded, color: Colors.purple),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _jvController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: isArabic ? 'قيد يومية (JV)' : 'Journal Voucher Code',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.auto_stories_rounded, color: Colors.amber),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Reset Frequency & Sequence Digits
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic ? 'إعادة تصفير السلسلة (Sequence Reset Period):' : 'Sequence Reset Period (Yearly / Quarterly / Monthly):',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: _resetPeriod,
                              decoration: const InputDecoration(border: OutlineInputBorder()),
                              items: [
                                DropdownMenuItem(
                                  value: 'DAILY',
                                  child: Text(isArabic ? 'يومي (Daily - Resets midnight)' : 'Daily (Resets midnight every day)'),
                                ),
                                DropdownMenuItem(
                                  value: 'MONTHLY',
                                  child: Text(isArabic ? 'شهري (Monthly - 01 of every Month)' : 'Monthly (Resets 1st of every Month)'),
                                ),
                                DropdownMenuItem(
                                  value: 'QUARTERLY',
                                  child: Text(isArabic ? 'ربعي (Quarterly - Every 3 Months)' : 'Quarterly (Resets every 3 Months)'),
                                ),
                                DropdownMenuItem(
                                  value: 'YEARLY',
                                  child: Text(isArabic ? 'سنوي (Yearly - 01 Jan)' : 'Yearly (Resets every 01 Jan)'),
                                ),
                                DropdownMenuItem(
                                  value: 'NEVER',
                                  child: Text(isArabic ? 'مستمر بدون تصفير (Continuous)' : 'Continuous (Never resets)'),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _resetPeriod = val);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic ? 'عدد خانات الرقم التسلسلي (Digit Padding):' : 'Sequence Padding (Digit Length):',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<int>(
                              initialValue: _seqPadding,
                              decoration: const InputDecoration(border: OutlineInputBorder()),
                              items: const [
                                DropdownMenuItem(value: 6, child: Text('6-Digit Sequence (e.g. 000001)')),
                                DropdownMenuItem(value: 4, child: Text('4-Digit Sequence (e.g. 0001)')),
                                DropdownMenuItem(value: 8, child: Text('8-Digit Sequence (e.g. 00000001)')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _seqPadding = val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Live Preview Container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.preview_rounded, color: Colors.amber, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              isArabic ? 'معاينة حية لصيغة أرقام السندات (Live Voucher Formula Preview):' : 'Live Formula Voucher Number Preview:',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            _buildPreviewBadge(
                              'PV Sample:',
                              VoucherNumberHelper.formatPreview(
                                formula: _numberingFormula,
                                typeCode: _pvController.text.trim(),
                                seqPadding: _seqPadding,
                                sequence: 1,
                              ),
                              Colors.red.shade300,
                            ),
                            _buildPreviewBadge(
                              'RV Sample:',
                              VoucherNumberHelper.formatPreview(
                                formula: _numberingFormula,
                                typeCode: _rvController.text.trim(),
                                seqPadding: _seqPadding,
                                sequence: 1,
                              ),
                              Colors.green.shade300,
                            ),
                            _buildPreviewBadge(
                              'CV Sample:',
                              VoucherNumberHelper.formatPreview(
                                formula: _numberingFormula,
                                typeCode: _cvController.text.trim(),
                                seqPadding: _seqPadding,
                                sequence: 1,
                              ),
                              Colors.purple.shade300,
                            ),
                            _buildPreviewBadge(
                              'JV Sample:',
                              VoucherNumberHelper.formatPreview(
                                formula: _numberingFormula,
                                typeCode: _jvController.text.trim(),
                                seqPadding: _seqPadding,
                                sequence: 1,
                              ),
                              Colors.amber.shade300,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Save Button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : () => _savePolicy(isArabic),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: _isSaving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save_rounded),
              label: Text(
                isArabic ? 'حفظ السياسة والصيغة' : 'Save Formula & Policy',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: isSelected ? color : Colors.grey.shade600, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : Colors.grey.shade900,
                    ),
                  ),
                ),
                Icon(
                  isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                  color: isSelected ? color : Colors.grey.shade400,
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewBadge(String label, String value, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accentColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(color: accentColor, fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
