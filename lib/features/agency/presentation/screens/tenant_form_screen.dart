import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/agency_provider.dart';

class TenantFormScreen extends ConsumerStatefulWidget {
  const TenantFormScreen({super.key});

  @override
  ConsumerState<TenantFormScreen> createState() => _TenantFormScreenState();
}

class _TenantFormScreenState extends ConsumerState<TenantFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _vatController = TextEditingController();
  final _emailController = TextEditingController();
  final _subdomainController = TextEditingController();
  final _adminEmailController = TextEditingController();
  final _adminPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _vatController.dispose();
    _emailController.dispose();
    _subdomainController.dispose();
    _adminEmailController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'name': _nameController.text.trim(),
        'vatNumber': _vatController.text.trim(),
        'email': _emailController.text.trim(),
        'subdomain': _subdomainController.text.trim(),
        'adminEmail': _adminEmailController.text.trim(),
        'adminPassword': _adminPasswordController.text.trim(),
      };

      try {
        await ref.read(agencyNotifierProvider.notifier).provisionTenant(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tenant provisioned successfully!')),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(agencyNotifierProvider).isLoading;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'إضافة عميل جديد' : 'Provision New Tenant'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isArabic ? 'معلومات الشركة' : 'Company Information', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Company Name', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _vatController,
                decoration: const InputDecoration(labelText: 'VAT Number (15 digits)', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.length != 15) ? 'Must be 15 digits' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Company Email', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subdomainController,
                decoration: const InputDecoration(labelText: 'Subdomain (e.g. client1)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 32),
              Text(isArabic ? 'معلومات حساب المسؤول' : 'Admin Account Info', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _adminEmailController,
                decoration: const InputDecoration(labelText: 'Admin Email', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _adminPasswordController,
                decoration: const InputDecoration(labelText: 'Admin Password', border: OutlineInputBorder()),
                obscureText: true,
                validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : Text(isArabic ? 'حفظ' : 'Provision Tenant'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
