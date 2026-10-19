import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/client_provider.dart';
import '../../domain/customer_enums.dart';
import '../widgets/customer_help_modal.dart';
import '../../../../app.dart';

class ClientFormScreen extends ConsumerStatefulWidget {
  const ClientFormScreen({super.key});

  @override
  ConsumerState<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends ConsumerState<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  String? _email;
  String? _phoneNumber;
  String? _country;
  String? _state;
  String? _city;
  String? _address;
  CustomerType _type = CustomerType.newCustomer;
  double _funds = 0;
  double _dues = 0;
  bool _permitCredit = false;
  double _creditLimit = 0;

  void _submit() async {
    final isArabic = ref.read(localeProvider).languageCode == 'ar';
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await ref.read(clientNotifierProvider.notifier).createClient({
          'name': _name,
          if (_email?.isNotEmpty == true) 'email': _email,
          if (_phoneNumber?.isNotEmpty == true) 'phoneNumber': _phoneNumber,
          if (_country?.isNotEmpty == true) 'country': _country,
          if (_state?.isNotEmpty == true) 'state': _state,
          if (_city?.isNotEmpty == true) 'city': _city,
          if (_address?.isNotEmpty == true) 'address': _address,
          'customerType': _type.name,
          'funds': _funds,
          'dues': _dues,
          'permitCredit': _permitCredit,
          'creditLimit': _creditLimit,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isArabic ? 'تم إنشاء العميل بنجاح' : 'Customer created successfully')),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isArabic ? 'فشل إنشاء العميل: $e' : 'Failed to create customer: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(clientNotifierProvider).isLoading;
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    InputDecoration dec(String label, {String? hint}) => InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'إضافة عميل جديد' : 'Add Customer', style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(isArabic ? Icons.language : Icons.g_translate),
            tooltip: isArabic ? 'Switch to English' : 'التحويل للعربية',
            onPressed: () {
              ref.read(localeProvider.notifier).state =
                  isArabic ? const Locale('en') : const Locale('ar');
            },
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            icon: const Icon(Icons.help_outline, size: 18),
            label: Text(isArabic ? 'دليل الإدخال' : 'Input Guide'),
            onPressed: () => showDialog(
              context: context,
              builder: (ctx) => const CustomerHelpModal(initialTab: 1),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // ── Section: Basic Info ──
                  _sectionHeader(isArabic ? 'البيانات الأساسية' : 'Basic Information'),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: TextFormField(
                        decoration: dec(isArabic ? 'اسم العميل *' : 'Customer Name *'),
                        validator: (v) => v == null || v.isEmpty ? (isArabic ? 'هذا الحقل مطلوب' : 'Required') : null,
                        onSaved: (v) => _name = v!,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<CustomerType>(
                        initialValue: _type,
                        decoration: dec(isArabic ? 'فئة العميل' : 'Customer Type'),
                        items: CustomerType.values
                            .map((t) => DropdownMenuItem(value: t, child: Text(t.getLabel(isArabic))))
                            .toList(),
                        onChanged: (v) => setState(() => _type = v!),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(
                      child: TextFormField(
                        decoration: dec(isArabic ? 'البريد الإلكتروني' : 'Email Address'),
                        keyboardType: TextInputType.emailAddress,
                        onSaved: (v) => _email = v,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: dec(isArabic ? 'رقم الهاتف' : 'Phone Number'),
                        keyboardType: TextInputType.phone,
                        onSaved: (v) => _phoneNumber = v,
                      ),
                    ),
                  ]),

                  const SizedBox(height: 24),
                  // ── Section: Location ──
                  _sectionHeader(isArabic ? 'العنوان والموقع' : 'Location'),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: TextFormField(
                        decoration: dec(isArabic ? 'الدولة' : 'Country'),
                        onSaved: (v) => _country = v,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: dec(isArabic ? 'المنطقة / المحافظة' : 'State / Province'),
                        onSaved: (v) => _state = v,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(
                      child: TextFormField(
                        decoration: dec(isArabic ? 'المدينة' : 'City'),
                        onSaved: (v) => _city = v,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: dec(isArabic ? 'العنوان التفصيلي' : 'Address'),
                        onSaved: (v) => _address = v,
                      ),
                    ),
                  ]),

                  const SizedBox(height: 24),
                  // ── Section: Financial ──
                  _sectionHeader(isArabic ? 'البيانات المالية والائتمان' : 'Financial'),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: TextFormField(
                        decoration: dec(isArabic ? 'الرصيد الدائن المسبق' : 'Funds (Credit Balance)', hint: '0.00'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onSaved: (v) => _funds = double.tryParse(v ?? '') ?? 0,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: dec(isArabic ? 'المستحقات (الذمم المعلقة)' : 'Dues (Outstanding)', hint: '0.00'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onSaved: (v) => _dues = double.tryParse(v ?? '') ?? 0,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade50,
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(isArabic ? 'السماح بالبيع الآجل (على الحساب)' : 'Permit Credit (On Account)',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text(
                              isArabic ? 'السماح لهذا العميل بالشراء بالأجل حتى الحد الائتماني' : 'Allow this customer to purchase on credit / invoice balance',
                              style: const TextStyle(fontSize: 12)),
                          value: _permitCredit,
                          activeThumbColor: Colors.indigo,
                          activeTrackColor: Colors.indigo.shade200,
                          onChanged: (val) => setState(() => _permitCredit = val),
                        ),
                        if (_permitCredit) ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            decoration: dec(isArabic ? 'سقف الحد الائتماني (ر.س)' : 'Credit Limit Amount (SAR)', hint: isArabic ? 'مثال: 5000.00' : 'e.g. 5000.00'),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (v) {
                              if (_permitCredit) {
                                final n = double.tryParse(v ?? '');
                                if (n == null || n < 0) return isArabic ? 'يرجى إدخال حد ائتماني صحيح' : 'Please enter a valid credit limit';
                              }
                              return null;
                            },
                            onSaved: (v) => _creditLimit = double.tryParse(v ?? '') ?? 0,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.person_add, color: Colors.white),
                      label: Text(
                        isLoading
                            ? (isArabic ? 'جاري الحفظ...' : 'Saving...')
                            : (isArabic ? 'حفظ العميل' : 'Save Customer'),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: isLoading ? null : _submit,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) => Row(
        children: [
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.indigo)),
          const SizedBox(width: 12),
          Expanded(child: Divider(color: Colors.indigo[100])),
        ],
      );
}

