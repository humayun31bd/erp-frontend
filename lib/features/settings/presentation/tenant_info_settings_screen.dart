import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/providers/tenant_settings_provider.dart';
import '../domain/tenant_preset_models.dart';

class TenantInfoSettingsContent extends ConsumerStatefulWidget {
  const TenantInfoSettingsContent({super.key});

  @override
  ConsumerState<TenantInfoSettingsContent> createState() => _TenantInfoSettingsContentState();
}

class _TenantInfoSettingsContentState extends ConsumerState<TenantInfoSettingsContent> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _vatController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _codeController = TextEditingController();
  final _logoController = TextEditingController();

  // Localization & Tax Controllers
  final _currencyCodeController = TextEditingController();
  final _currencySymbolController = TextEditingController();
  final _taxRateController = TextEditingController();
  final _taxTypeController = TextEditingController();
  final _timezoneController = TextEditingController();
  final _dateFormatController = TextEditingController();
  final _decimalPlacesController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _tenantId;
  String _status = 'ACTIVE';

  CountryPreset _selectedCountry = CountryPreset.supportedCountries.first;
  BusinessType _selectedBusinessType = BusinessType.retail;
  String _selectedMarketingPlan = 'STANDARD';

  @override
  void initState() {
    super.initState();
    _fetchTenantInfo();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _vatController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _codeController.dispose();
    _logoController.dispose();
    _currencyCodeController.dispose();
    _currencySymbolController.dispose();
    _taxRateController.dispose();
    _taxTypeController.dispose();
    _timezoneController.dispose();
    _dateFormatController.dispose();
    _decimalPlacesController.dispose();
    super.dispose();
  }

  void _applyCountryPreset(CountryPreset preset, {bool overwriteTaxAndCurrency = true}) {
    setState(() {
      _selectedCountry = preset;
      if (overwriteTaxAndCurrency) {
        _currencyCodeController.text = preset.currencyCode;
        _currencySymbolController.text = preset.currencySymbol;
        _taxRateController.text = preset.defaultTaxRate.toStringAsFixed(1);
        _taxTypeController.text = preset.taxType;
        _timezoneController.text = preset.timezone;
        _dateFormatController.text = preset.dateFormat;
        _decimalPlacesController.text = preset.decimalPlaces.toString();
      }
    });
  }

  Future<void> _fetchTenantInfo() async {
    setState(() => _isLoading = true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/settings/tenant');
      if (response.data['success'] == true && response.data['tenant'] != null) {
        final tenant = response.data['tenant'];
        _tenantId = tenant['id'] as String?;
        _nameController.text = tenant['name'] as String? ?? 'Shapla Supermarket Chain Ltd';
        _vatController.text = tenant['vatNumber'] as String? ?? '1801122334455';
        _emailController.text = tenant['email'] as String? ?? 'accounts@shaplamart.com';
        _phoneController.text = tenant['whatsappNumber'] as String? ?? tenant['phone'] as String? ?? '+8801711000999';
        _addressController.text = tenant['address'] as String? ?? 'Plot 42, Dhanmondi 27, Dhaka 1209, Bangladesh';
        _codeController.text = tenant['code'] as String? ?? tenant['subdomain'] as String? ?? 'SHAPLA-GROCERY';
        _logoController.text = tenant['logoUrl'] as String? ?? '';
        _status = tenant['status'] as String? ?? 'ACTIVE';

        // Load country & locale
        final cCode = tenant['countryCode'] as String? ?? 'SA';
        _selectedCountry = CountryPreset.findByCode(cCode);

        // Load business type
        final bTypeStr = tenant['businessType'] as String? ?? 'retail';
        _selectedBusinessType = BusinessType.values.firstWhere(
          (b) => b.name.toLowerCase() == bTypeStr.toLowerCase(),
          orElse: () => BusinessType.retail,
        );

        _selectedMarketingPlan = tenant['marketingPlan'] as String? ?? 'STANDARD';

        _currencyCodeController.text = tenant['currencyCode'] as String? ?? _selectedCountry.currencyCode;
        _currencySymbolController.text = tenant['currencySymbol'] as String? ?? _selectedCountry.currencySymbol;
        _taxRateController.text = (tenant['taxRate'] != null)
            ? (tenant['taxRate'] as num).toDouble().toStringAsFixed(1)
            : _selectedCountry.defaultTaxRate.toStringAsFixed(1);
        _taxTypeController.text = tenant['taxType'] as String? ?? _selectedCountry.taxType;
        _timezoneController.text = tenant['timezone'] as String? ?? _selectedCountry.timezone;
        _dateFormatController.text = tenant['dateFormat'] as String? ?? _selectedCountry.dateFormat;
        _decimalPlacesController.text = (tenant['decimalPlaces'] != null)
            ? tenant['decimalPlaces'].toString()
            : _selectedCountry.decimalPlaces.toString();
      }
    } catch (e) {
      // Fallback defaults
      _selectedCountry = CountryPreset.findByCode('SA');
      _nameController.text = 'Intelligent Commercial Trading Co.';
      _vatController.text = '310123456700003';
      _emailController.text = 'admin@intelligent-pos.com';
      _phoneController.text = '+966501234567';
      _addressController.text = 'King Fahd Road, Riyadh 12214, Saudi Arabia';
      _codeController.text = 'INTELLIGENT-KSA';
      _applyCountryPreset(_selectedCountry, overwriteTaxAndCurrency: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveTenantInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final dio = ref.read(dioProvider);
      final payload = {
        'name': _nameController.text,
        'vatNumber': _vatController.text,
        'email': _emailController.text,
        'whatsappNumber': _phoneController.text,
        'address': _addressController.text,
        'code': _codeController.text,
        'logoUrl': _logoController.text,
        'countryCode': _selectedCountry.countryCode,
        'businessType': _selectedBusinessType.name,
        'marketingPlan': _selectedMarketingPlan,
        'currencyCode': _currencyCodeController.text,
        'currencySymbol': _currencySymbolController.text,
        'decimalPlaces': int.tryParse(_decimalPlacesController.text) ?? _selectedCountry.decimalPlaces,
        'taxRate': double.tryParse(_taxRateController.text) ?? _selectedCountry.defaultTaxRate,
        'taxType': _taxTypeController.text,
        'timezone': _timezoneController.text,
        'dateFormat': _dateFormatController.text,
        'primaryLanguage': _selectedCountry.primaryLanguage,
        'secondaryLanguage': _selectedCountry.secondaryLanguage,
      };

      await dio.put('/settings/tenant', data: payload);

      // Update Riverpod provider for real-time reactivity in POS
      ref.read(tenantSettingsProvider.notifier).updateCustomSettings(
        name: _nameController.text,
        vatNumber: _vatController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        code: _codeController.text,
        logoUrl: _logoController.text,
        currencyCode: _currencyCodeController.text,
        currencySymbol: _currencySymbolController.text,
        decimalPlaces: int.tryParse(_decimalPlacesController.text),
        taxRate: double.tryParse(_taxRateController.text),
        taxType: _taxTypeController.text,
        timezone: _timezoneController.text,
        dateFormat: _dateFormatController.text,
      );
      ref.read(tenantSettingsProvider.notifier).setBusinessType(_selectedBusinessType);
      ref.read(tenantSettingsProvider.notifier).setMarketingPlan(_selectedMarketingPlan);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tenant location, business policy & marketing plan updated successfully!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating tenant info: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Banner Card
              _buildHeaderBanner(),
              const SizedBox(height: 20),

              // 1. Location & Country Compliance Setup
              _buildLocationAndComplianceCard(),
              const SizedBox(height: 20),

              // 2. Business Type & Policy Automation
              _buildBusinessTypePolicyCard(),
              const SizedBox(height: 20),

              // 3. Marketing Plan & Entitlements
              _buildMarketingPlanCard(),
              const SizedBox(height: 20),

              // 4. Company & General Profile Details
              _buildGeneralProfileCard(),
              const SizedBox(height: 28),

              // Save Action Button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _fetchTenantInfo,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Reset to Saved'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 2,
                    ),
                    onPressed: _isSaving ? null : _saveTenantInfo,
                    icon: _isSaving
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.save_rounded, size: 20),
                    label: Text(
                      _isSaving ? 'Saving Configuration...' : 'Save Tenant Setup',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Card(
      elevation: 0,
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.business_rounded, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tenant Setup & Regional Policy Engine',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tenant ID: ${_tenantId ?? "tenant-auto"}  •  Status: $_status  •  Active Plan: $_selectedMarketingPlan',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF86EFAC)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified_rounded, color: Color(0xFF15803D), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    _selectedCountry.compliance.title,
                    style: const TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationAndComplianceCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.public_rounded, color: Color(0xFF2563EB), size: 24),
                const SizedBox(width: 10),
                const Text(
                  '1. Tenant Location & Tax Compliance Standard',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _applyCountryPreset(_selectedCountry, overwriteTaxAndCurrency: true),
                  icon: const Icon(Icons.auto_fix_high_rounded, size: 16),
                  label: const Text('Reset to Country Defaults'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Select your business country. Currency, tax rates, e-invoicing compliance, decimal places, and timezone will automatically configure.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),

            // Country Selector Dropdown
            DropdownButtonFormField<CountryPreset>(
              initialValue: _selectedCountry,
              decoration: const InputDecoration(
                labelText: 'Operating Country & Legal Tax Framework *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag_rounded),
              ),
              items: CountryPreset.supportedCountries.map((preset) {
                return DropdownMenuItem<CountryPreset>(
                  value: preset,
                  child: Row(
                    children: [
                      Text(preset.flagEmoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Text('${preset.countryName} (${preset.countryCode})'),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          preset.compliance.title,
                          style: TextStyle(fontSize: 10, color: Colors.blue.shade700, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (newPreset) {
                if (newPreset != null) {
                  _applyCountryPreset(newPreset, overwriteTaxAndCurrency: true);
                }
              },
            ),
            const SizedBox(height: 16),

            // Auto-Configured Settings Form Grid
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _currencyCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Currency Code',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.monetization_on_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _currencySymbolController,
                    decoration: const InputDecoration(
                      labelText: 'Currency Symbol',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.currency_exchange_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _decimalPlacesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Decimal Places (2 or 3)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers_rounded),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _taxRateController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Tax Rate (%) *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.percent_rounded),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Tax rate required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _taxTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Tax Type Name / Label',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.receipt_long_rounded),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _timezoneController,
                    decoration: const InputDecoration(
                      labelText: 'Time Zone',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.schedule_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _dateFormatController,
                    decoration: const InputDecoration(
                      labelText: 'Date Format Pattern',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today_rounded),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.language_rounded, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Language Preference: Primary: ${_selectedCountry.primaryLanguage.toUpperCase()} | Secondary: ${_selectedCountry.secondaryLanguage.toUpperCase()}${_selectedCountry.tertiaryLanguage != null ? " | Tertiary: ${_selectedCountry.tertiaryLanguage!.toUpperCase()}" : ""}',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.amber.shade900),
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

  Widget _buildBusinessTypePolicyCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.category_rounded, color: Color(0xFF2563EB), size: 24),
                SizedBox(width: 10),
                Text(
                  '2. Business Type & Product Policy Automation',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Select your industry segment. The POS cashier and product catalog will automatically adapt workflows and features.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),

            // Business Type Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: BusinessType.values.map((type) {
                final isSelected = _selectedBusinessType == type;
                return ChoiceChip(
                  avatar: Icon(type.icon, size: 18, color: isSelected ? Colors.white : Colors.blueGrey),
                  label: Text(type.label),
                  selected: isSelected,
                  selectedColor: const Color(0xFF2563EB),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedBusinessType = type);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Active Features for Selected Business Type
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_selectedBusinessType.icon, size: 20, color: const Color(0xFF2563EB)),
                      const SizedBox(width: 8),
                      Text(
                        'Active POS & Product Policy Features for ${_selectedBusinessType.label}:',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedBusinessType.specializedFeatures.map((feat) {
                      return Chip(
                        avatar: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16),
                        label: Text(feat, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketingPlanCard() {
    final plans = [
      {'name': 'STARTER', 'label': 'Starter Plan', 'branches': '1 Branch', 'counters': '1 Counter', 'invoices': '500 Inv/mo'},
      {'name': 'STANDARD', 'label': 'Standard Plan', 'branches': '3 Branches', 'counters': '3 Counters', 'invoices': '2,000 Inv/mo'},
      {'name': 'PRO', 'label': 'Pro / Unlimited', 'branches': 'Unlimited', 'counters': 'Unlimited', 'invoices': 'Unlimited'},
      {'name': 'AGENCY', 'label': 'Agency / Enterprise', 'branches': 'Unlimited Multi-Tenant', 'counters': 'Unlimited', 'invoices': 'Unlimited'},
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.card_membership_rounded, color: Color(0xFF2563EB), size: 24),
                SizedBox(width: 10),
                Text(
                  '3. Marketing Plan Purchased & SaaS Entitlements',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Features and quota boundaries are unlocked according to the active subscription plan.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            Row(
              children: plans.map((p) {
                final isSelected = _selectedMarketingPlan.toUpperCase() == p['name'];
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: InkWell(
                      onTap: () => setState(() => _selectedMarketingPlan = p['name']!),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  p['label']!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isSelected ? const Color(0xFF1D4ED8) : Colors.black87,
                                  ),
                                ),
                                const Spacer(),
                                if (isSelected)
                                  const Icon(Icons.check_circle_rounded, color: Color(0xFF2563EB), size: 16),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(p['branches']!, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                            Text(p['counters']!, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                            Text(p['invoices']!, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralProfileCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.store_rounded, color: Color(0xFF2563EB), size: 24),
                SizedBox(width: 10),
                Text(
                  '4. Business Entity Profile & Contact Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Company / Business Name *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.domain_rounded),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Company name required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      labelText: 'Tenant Code / Subdomain',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.fingerprint_rounded),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _vatController,
                    decoration: const InputDecoration(
                      labelText: 'VAT / Tax Registration Number (TRN/BIN) *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.receipt_long_rounded),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Tax registration number required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Official Contact Email *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_rounded),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Email required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone / WhatsApp Notification Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _logoController,
                    decoration: const InputDecoration(
                      labelText: 'Business Logo Image URL',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.image_outlined),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Main Branch / Showroom Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
