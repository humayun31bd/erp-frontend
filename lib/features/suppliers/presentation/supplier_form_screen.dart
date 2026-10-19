import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/supplier_model.dart';
import '../providers/suppliers_provider.dart';

class SupplierFormScreen extends ConsumerStatefulWidget {
  final String? supplierId;
  final SupplierModel? supplier;

  const SupplierFormScreen({super.key, this.supplierId, this.supplier});

  @override
  ConsumerState<SupplierFormScreen> createState() => _SupplierFormScreenState();
}

class _SupplierFormScreenState extends ConsumerState<SupplierFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _vatController = TextEditingController();
  final _crController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bankDetailsController = TextEditingController();

  String _category = 'MERCHANDISE';
  String _supplierTier = 'TIER_2_STANDARD';
  String _paymentTerms = 'NET_30';

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.supplier != null) {
      _populateFields(widget.supplier!);
    }
  }

  void _populateFields(SupplierModel s) {
    _nameController.text = s.name;
    _vatController.text = s.vatNumber ?? '';
    _crController.text = s.crNumber ?? '';
    _addressController.text = s.address ?? '';
    _emailController.text = s.email ?? '';
    _phoneController.text = s.phoneNumber ?? '';
    _bankDetailsController.text = s.bankDetails ?? '';
    _category = s.category;
    _supplierTier = s.supplierTier;
    _paymentTerms = s.paymentTerms;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _vatController.dispose();
    _crController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bankDetailsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final api = ref.read(supplierApiProvider);
      final payload = {
        'name': _nameController.text.trim(),
        'vatNumber': _vatController.text.trim().isEmpty ? null : _vatController.text.trim(),
        'crNumber': _crController.text.trim().isEmpty ? null : _crController.text.trim(),
        'address': _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        'phoneNumber': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        'bankDetails': _bankDetailsController.text.trim().isEmpty ? null : _bankDetailsController.text.trim(),
        'category': _category,
        'supplierTier': _supplierTier,
        'paymentTerms': _paymentTerms,
      };

      final targetId = widget.supplierId ?? widget.supplier?.id;
      if (targetId != null) {
        await api.updateSupplier(targetId, payload);
      } else {
        await api.createSupplier(payload);
      }

      ref.invalidate(suppliersProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(targetId != null ? 'Supplier profile updated successfully' : 'Supplier profile created successfully'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isEditing = widget.supplierId != null || widget.supplier != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isArabic
              ? (isEditing ? 'تعديل تصنيف وبيانات المورد' : 'إضافة مورد وتصنيفه')
              : (isEditing ? 'Edit Supplier Profile & Classification' : 'Add Supplier & Classification'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Classification & Tier Matrix Section (BEST OPTION)
              _buildSectionTitle(isArabic ? 'تصنيف المورد وفئة التعامل' : 'Supplier Classification & Vendor Tier', Icons.category_rounded),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Supplier Business Category Dropdown
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _category,
                              decoration: InputDecoration(
                                labelText: isArabic ? 'تصنيف النشاط التجاري *' : 'Business Category *',
                                prefixIcon: const Icon(Icons.storefront_rounded, color: Color(0xFF4361EE)),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              items: [
                                DropdownMenuItem(value: 'MERCHANDISE', child: Text(isArabic ? 'بضائع وتجزئة (Merchandise)' : 'Merchandise Goods')),
                                DropdownMenuItem(value: 'RAW_MATERIAL', child: Text(isArabic ? 'مواد خام وتصنيع (Raw Materials)' : 'Raw Materials & Mfg')),
                                DropdownMenuItem(value: 'WHOLESALER', child: Text(isArabic ? 'تاجر جملة وموزع (Wholesaler)' : 'Wholesale Distributor')),
                                DropdownMenuItem(value: 'SERVICES', child: Text(isArabic ? 'خدمات واستشارات (Services)' : 'Corporate Services')),
                                DropdownMenuItem(value: 'LOGISTICS', child: Text(isArabic ? 'شحن وخدمات لوجستية (Logistics)' : 'Logistics & Freight')),
                                DropdownMenuItem(value: 'UTILITIES', child: Text(isArabic ? 'مرافق وصيانة (Utilities)' : 'Utilities & Maintenance')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _category = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Vendor Tier Rating Dropdown
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _supplierTier,
                              decoration: InputDecoration(
                                labelText: isArabic ? 'درجة المورد (Vendor Tier) *' : 'Supplier Tier Rating *',
                                prefixIcon: const Icon(Icons.star_rounded, color: Color(0xFFF59E0B)),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              items: [
                                DropdownMenuItem(value: 'TIER_1_PREFERRED', child: Text(isArabic ? 'فئة أ - مورد مفضل (Tier 1 Preferred ⭐)' : 'Tier 1 - Strategic Preferred ⭐')),
                                DropdownMenuItem(value: 'TIER_2_STANDARD', child: Text(isArabic ? 'فئة ب - مورد معتمد (Tier 2 Standard)' : 'Tier 2 - Standard Approved')),
                                DropdownMenuItem(value: 'TIER_3_TRIAL', child: Text(isArabic ? 'فئة ج - مورد تجريبي (Tier 3 Trial)' : 'Tier 3 - Secondary / Trial')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _supplierTier = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Payment Terms Credit Policy Dropdown
                      DropdownButtonFormField<String>(
                        value: _paymentTerms,
                        decoration: InputDecoration(
                          labelText: isArabic ? 'سياسة وشروط الدفع (Payment Terms) *' : 'Default Credit & Payment Terms *',
                          prefixIcon: const Icon(Icons.payments_rounded, color: Color(0xFF10B981)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        items: [
                          DropdownMenuItem(value: 'COD', child: Text(isArabic ? 'دفع نقدي عند الاستلام (Cash on Delivery - COD)' : 'Cash on Delivery (COD)')),
                          DropdownMenuItem(value: 'NET_15', child: Text(isArabic ? 'آجل خلال 15 يوماً (Net 15 Days)' : 'Net 15 Days')),
                          DropdownMenuItem(value: 'NET_30', child: Text(isArabic ? 'آجل خلال 30 يوماً (Net 30 Days)' : 'Net 30 Days')),
                          DropdownMenuItem(value: 'NET_60', child: Text(isArabic ? 'آجل خلال 60 يوماً (Net 60 Days)' : 'Net 60 Days')),
                          DropdownMenuItem(value: 'PREPAID', child: Text(isArabic ? 'دفع مقدم كامل (Advance Prepaid)' : 'Advance / Prepaid Full')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _paymentTerms = val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 2. Basic Information Section
              _buildSectionTitle(isArabic ? 'المعلومات الأساسية والامتثال' : 'Basic Company & ZATCA Registration', Icons.business_rounded),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: isArabic ? 'اسم الشركة / المورد *' : 'Supplier / Company Name *',
                          prefixIcon: const Icon(Icons.domain_rounded, color: Color(0xFF4361EE)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? (isArabic ? 'هذا الحقل مطلوب' : 'Required field') : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _vatController,
                              decoration: InputDecoration(
                                labelText: isArabic ? 'الرقم الضريبي (15 رقم ZATCA)' : 'VAT Registration No. (15 digits)',
                                prefixIcon: const Icon(Icons.receipt_long_rounded, color: Color(0xFF10B981)),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _crController,
                              decoration: InputDecoration(
                                labelText: isArabic ? 'رقم السجل التجاري (10 أرقام)' : 'Commercial Registration (CR No.)',
                                prefixIcon: const Icon(Icons.badge_rounded, color: Color(0xFF8B5CF6)),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 3. Contact & Address Section
              _buildSectionTitle(isArabic ? 'معلومات الاتصال والعنوان' : 'Contact & Address Details', Icons.contact_mail_rounded),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                labelText: isArabic ? 'رقم الهاتف' : 'Phone Number',
                                prefixIcon: const Icon(Icons.phone_rounded, color: Color(0xFF3B82F6)),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: isArabic ? 'البريد الإلكتروني' : 'Email Address',
                                prefixIcon: const Icon(Icons.email_rounded, color: Color(0xFF3B82F6)),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: isArabic ? 'العنوان الوطني / التفصيلي' : 'National Address / Location',
                          prefixIcon: const Icon(Icons.location_on_rounded, color: Color(0xFFEF4444)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 4. Financial & Bank Details Section
              _buildSectionTitle(isArabic ? 'الحسابات البنكية والآيبان' : 'Banking & IBAN Details', Icons.account_balance_rounded),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: _bankDetailsController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: isArabic ? 'تفاصيل الحساب البنكي والآيبان (IBAN)' : 'Bank Name, Account No & IBAN',
                      prefixIcon: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFFF59E0B)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      hintText: 'e.g. Al-Rajhi Bank | IBAN: SA8820000012345678901234',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save Action Button
              SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4361EE),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : _submit,
                  icon: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.check_circle_rounded, color: Colors.white),
                  label: Text(
                    isArabic ? (isEditing ? 'حفظ التعديلات' : 'حفظ المورد والتصنيف') : (isEditing ? 'Update Supplier Profile' : 'Save Supplier & Classification'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF4361EE)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
        ),
      ],
    );
  }
}
