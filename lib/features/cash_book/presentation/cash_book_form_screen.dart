import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/cash_book_provider.dart';

class CashBookFormScreen extends ConsumerStatefulWidget {
  const CashBookFormScreen({super.key});

  @override
  ConsumerState<CashBookFormScreen> createState() => _CashBookFormScreenState();
}

class _CashBookFormScreenState extends ConsumerState<CashBookFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _type = 'IN';

  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final api = ref.read(cashBookApiProvider);
      final payload = {
        'type': _type,
        'amount': _amountController.text,
        'description': _descriptionController.text.isEmpty ? null : _descriptionController.text,
        'entryDate': DateTime.now().toIso8601String(),
      };

      await api.createCashBookEntry(payload);

      ref.invalidate(cashBookEntriesProvider);
      ref.invalidate(cashBookSummaryProvider);
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'إضافة حركة نقدية' : 'Add Cash Entry'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: InputDecoration(
                labelText: isArabic ? 'نوع الحركة' : 'Entry Type',
                border: const OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'IN', child: Text('Cash In')),
                DropdownMenuItem(value: 'OUT', child: Text('Cash Out')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _type = val);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: isArabic ? 'المبلغ *' : 'Amount *',
                border: const OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (val) => val == null || val.isEmpty ? (isArabic ? 'هذا الحقل مطلوب' : 'Required field') : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: isArabic ? 'الوصف' : 'Description',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading 
                    ? const CircularProgressIndicator()
                    : Text(isArabic ? 'حفظ' : 'Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
