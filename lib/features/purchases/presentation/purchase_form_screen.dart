import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:erp_frontend/app.dart';
import '../providers/purchases_provider.dart';
import '../../suppliers/providers/suppliers_provider.dart';
import '../../pos/providers/pos_provider.dart';
import '../domain/purchase_model.dart';
import '../utils/procurement_document_formatter.dart';

class PurchaseFormScreen extends ConsumerStatefulWidget {
  const PurchaseFormScreen({super.key});

  @override
  ConsumerState<PurchaseFormScreen> createState() => _PurchaseFormScreenState();
}

class _PurchaseFormScreenState extends ConsumerState<PurchaseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedSupplierId;
  final _invoiceNumberController = TextEditingController();
  String _paymentStatus = 'UNPAID';
  String _selectedCurrency = 'SAR';
  double _exchangeRate = 1.0;

  final List<PurchaseLineItemModel> _lineItems = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    super.dispose();
  }

  void _addLineItem(bool isArabic) {
    showDialog(
      context: context,
      builder: (ctx) => _AddPurchaseLineItemDialog(
        isArabic: isArabic,
        onAdd: (item) {
          setState(() {
            _lineItems.add(item);
          });
        },
      ),
    );
  }

  double get _subtotal => _lineItems.fold(0, (sum, item) => sum + item.subtotalAmount);
  double get _totalVat => _lineItems.fold(0, (sum, item) => sum + item.vatAmount);
  double get _total => _lineItems.fold(0, (sum, item) => sum + item.totalAmount);

  Future<void> _submit(bool isArabic) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSupplierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isArabic ? 'يرجى اختيار المورد' : 'Please select a supplier')),
      );
      return;
    }
    if (_lineItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isArabic ? 'يرجى إضافة صنف واحد على الأقل' : 'Please add at least one line item')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final api = ref.read(purchaseApiProvider);
      
      final payload = {
        'supplierId': _selectedSupplierId,
        'invoiceNumber': _invoiceNumberController.text,
        'issueDate': DateTime.now().toIso8601String(),
        'subtotalAmount': _subtotal.toStringAsFixed(2),
        'totalVatAmount': _totalVat.toStringAsFixed(2),
        'totalAmount': _total.toStringAsFixed(2),
        'paymentStatus': _paymentStatus,
        'currency': _selectedCurrency,
        'exchangeRate': _exchangeRate,
        'lineItems': _lineItems.map((item) => {
          'productId': item.productId,
          'description': item.description,
          'quantity': item.quantity.toString(),
          'unitPrice': item.unitPrice.toString(),
          'vatRate': item.vatRate.toString(),
          'subtotalAmount': item.subtotalAmount.toString(),
          'vatAmount': item.vatAmount.toString(),
          'totalAmount': item.totalAmount.toString(),
        }).toList(),
      };

      await api.createPurchase(payload);

      ref.invalidate(purchasesProvider);
      ref.invalidate(productsProvider);
      
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${isArabic ? "خطأ: " : "Error: "}$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final suppliersState = ref.watch(suppliersProvider);
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final currency = isArabic ? 'ر.س ' : 'SAR ';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'إضافة فاتورة شراء جديدة' : 'Add Purchase Invoice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              final current = ref.read(localeProvider);
              ref.read(localeProvider.notifier).state =
                  current.languageCode == 'en' ? const Locale('ar') : const Locale('en');
            },
            tooltip: isArabic ? 'تغيير اللغة' : 'Switch Language',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'تفاصيل الفاتورة' : 'Invoice Details',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    suppliersState.when(
                      data: (suppliers) => DropdownButtonFormField<String>(
                        initialValue: _selectedSupplierId,
                        decoration: InputDecoration(
                          labelText: isArabic ? 'المورد *' : 'Supplier *',
                          border: const OutlineInputBorder(),
                        ),
                        items: suppliers.map((s) => DropdownMenuItem(value: s.id, child: Text('${s.name} (${ProcurementDocumentFormatter.formatSupplierCode(s.id)})'))).toList(),
                        onChanged: (val) => setState(() => _selectedSupplierId = val),
                        validator: (val) => val == null ? (isArabic ? 'حقل مطلوب' : 'Required field') : null,
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (e, s) => Text('${isArabic ? "خطأ في تحميل الموردين: " : "Error loading suppliers: "}$e'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _invoiceNumberController,
                            decoration: InputDecoration(
                              labelText: isArabic ? 'رقم الفاتورة *' : 'Invoice Number *',
                              border: const OutlineInputBorder(),
                            ),
                            validator: (val) => val == null || val.isEmpty ? (isArabic ? 'حقل مطلوب' : 'Required field') : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _paymentStatus,
                            decoration: InputDecoration(
                              labelText: isArabic ? 'حالة الدفع' : 'Payment Status',
                              border: const OutlineInputBorder(),
                            ),
                            items: [
                              DropdownMenuItem(value: 'UNPAID', child: Text(isArabic ? 'غير مدفوع' : 'Unpaid')),
                              DropdownMenuItem(value: 'PAID', child: Text(isArabic ? 'مدفوع' : 'Paid')),
                              DropdownMenuItem(value: 'PARTIAL', child: Text(isArabic ? 'جزئي' : 'Partial')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _paymentStatus = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedCurrency,
                            decoration: InputDecoration(
                              labelText: isArabic ? 'عملة الشراء' : 'Purchase Currency',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.monetization_on_outlined),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'SAR', child: Text('SAR (ر.س)')),
                              DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
                              DropdownMenuItem(value: 'EUR', child: Text('EUR (€)')),
                              DropdownMenuItem(value: 'AED', child: Text('AED (د.إ)')),
                              DropdownMenuItem(value: 'BDT', child: Text('BDT (৳)')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedCurrency = val;
                                  if (val == 'USD') {
                                    _exchangeRate = 3.75;
                                  } else if (val == 'EUR') {
                                    _exchangeRate = 4.10;
                                  } else if (val == 'AED') {
                                    _exchangeRate = 1.02;
                                  } else if (val == 'BDT') {
                                    _exchangeRate = 0.031;
                                  } else {
                                    _exchangeRate = 1.0;
                                  }
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isArabic ? 'أصناف الفاتورة' : 'Line Items',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _addLineItem(isArabic),
                          icon: const Icon(Icons.add),
                          label: Text(isArabic ? 'إضافة صنف' : 'Add Item'),
                        ),
                      ],
                    ),
                    const Divider(),
                    if (_lineItems.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            isArabic ? 'لم يتم إضافة أصناف بعد' : 'No items added yet',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    for (var i = 0; i < _lineItems.length; i++)
                      ListTile(
                        title: Text(_lineItems[i].description),
                        subtitle: Text('${_lineItems[i].quantity} x $currency${_lineItems[i].unitPrice.toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$currency${_lineItems[i].totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _lineItems.removeAt(i);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isArabic ? 'المبلغ الصافي:' : 'Subtotal:'),
                        Text('$currency${_subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isArabic ? 'ضريبة القيمة المضافة (15%):' : 'VAT (15%):'),
                        Text('$currency${_totalVat.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isArabic ? 'الإجمالي النهائي:' : 'Total Amount:',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text(
                          '$currency${_total.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _submit(isArabic),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                        isArabic ? 'حفظ فاتورة الشراء' : 'Save Purchase Invoice',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPurchaseLineItemDialog extends ConsumerStatefulWidget {
  final bool isArabic;
  final void Function(PurchaseLineItemModel) onAdd;
  const _AddPurchaseLineItemDialog({required this.isArabic, required this.onAdd});

  @override
  ConsumerState<_AddPurchaseLineItemDialog> createState() => _AddPurchaseLineItemDialogState();
}

class _AddPurchaseLineItemDialogState extends ConsumerState<_AddPurchaseLineItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');
  final _priceCtrl = TextEditingController(text: '0.00');
  final _discountCtrl = TextEditingController(text: '0.00');
  
  String? _selectedProductId;
  String _selectedUnit = 'PCS';
  double _vatRate = 15.0;

  final List<Map<String, String>> _units = [
    {'code': 'PCS', 'en': 'Pieces (Pcs)', 'ar': 'قطع (Pcs)'},
    {'code': 'KG', 'en': 'Kilograms (Kg)', 'ar': 'كيلوجرام (Kg)'},
    {'code': 'BOX', 'en': 'Boxes (Box)', 'ar': 'صناديق (Box)'},
    {'code': 'METER', 'en': 'Meters (m)', 'ar': 'أمتار (متر)'},
    {'code': 'TON', 'en': 'Tons (Ton)', 'ar': 'أطنان (طن)'},
    {'code': 'SERVICE', 'en': 'Service / Work', 'ar': 'خدمة / عمل'},
  ];

  @override
  void dispose() {
    _descCtrl.dispose();
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    _discountCtrl.dispose();
    super.dispose();
  }

  double get _qty => double.tryParse(_qtyCtrl.text) ?? 1.0;
  double get _unitPrice => double.tryParse(_priceCtrl.text) ?? 0.0;
  double get _discount => double.tryParse(_discountCtrl.text) ?? 0.0;

  double get _grossSubtotal => _qty * _unitPrice;
  double get _netSubtotal => (_grossSubtotal - _discount).clamp(0.0, double.infinity);
  double get _vatAmount => _netSubtotal * (_vatRate / 100.0);
  double get _totalLineAmount => _netSubtotal + _vatAmount;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_descCtrl.text.trim().isEmpty) return;

    widget.onAdd(PurchaseLineItemModel(
      productId: _selectedProductId,
      description: '${_descCtrl.text.trim()}${_selectedUnit != "PCS" ? " ($_selectedUnit)" : ""}',
      quantity: _qty,
      unitPrice: _unitPrice,
      vatRate: _vatRate,
      subtotalAmount: _netSubtotal,
      vatAmount: _vatAmount,
      totalAmount: _totalLineAmount,
    ));
    Navigator.pop(context);
  }

  void _adjustQty(double delta) {
    final current = _qty;
    final next = (current + delta).clamp(1.0, 99999.0);
    setState(() {
      _qtyCtrl.text = next.toStringAsFixed(next % 1 == 0 ? 0 : 2);
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsProvider);
    final isArabic = widget.isArabic;
    final theme = Theme.of(context);
    final currency = isArabic ? 'ر.س' : 'SAR';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 540,
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.add_shopping_cart, color: theme.primaryColor),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic ? 'إضافة صنف للشراء' : 'Add Purchase Item',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              isArabic ? 'اختر منتج من القائمة أو أدخل صنف مخصص' : 'Select product or enter custom purchase item',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),

                // Product Catalog Selector
                Text(
                  isArabic ? 'اختيار منتج من المخزون (اختياري)' : 'Select Catalog Product (Optional)',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 8),
                productsState.when(
                  data: (products) => DropdownButtonFormField<String>(
                    initialValue: _selectedProductId,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.inventory_2_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    hint: Text(isArabic ? '-- اختر صنف متاح بالكاتالوج --' : '-- Select catalog item --'),
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text(
                          isArabic ? '✨ صنف مخصص / مادة خام جديدة' : '✨ Custom Purchase Item / Raw Material',
                          style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...products.map((p) {
                        return DropdownMenuItem<String>(
                          value: p.id,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${p.name} (${p.sku ?? "No SKU"})'),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${p.stockQuantity} ${isArabic ? "بالمخزن" : "in stock"}',
                                  style: const TextStyle(fontSize: 11, color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                    ],
                    onChanged: (val) {
                      setState(() {
                        _selectedProductId = val;
                        if (val != null) {
                          final p = products.firstWhere((element) => element.id == val);
                          _descCtrl.text = p.name;
                          final priceStr = p.costPrice ?? p.price;
                          _priceCtrl.text = (double.tryParse(priceStr) ?? 0.0).toStringAsFixed(2);
                        }
                      });
                    },
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, s) => Text(isArabic ? 'خطأ في تحميل المنتجات' : 'Error loading catalog'),
                ),
                const SizedBox(height: 16),

                // Description Field
                Text(
                  isArabic ? 'اسم الصنف / البيان *' : 'Item Description / Name *',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descCtrl,
                  decoration: InputDecoration(
                    hintText: isArabic ? 'مثال: حديد تسليح 12 ملم / أوراق طباعة A4' : 'e.g., Raw Steel 12mm / Office Supplies',
                    prefixIcon: const Icon(Icons.label_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (val) => (val == null || val.trim().isEmpty)
                      ? (isArabic ? 'يرجى كتابة بيان الصنف' : 'Item description is required')
                      : null,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),

                // Quantity & Unit of Measure Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quantity Counter
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? 'الكمية *' : 'Quantity *',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              IconButton.outlined(
                                icon: const Icon(Icons.remove),
                                onPressed: () => _adjustQty(-1),
                                visualDensity: VisualDensity.compact,
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller: _qtyCtrl,
                                  textAlign: TextAlign.center,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              IconButton.outlined(
                                icon: const Icon(Icons.add),
                                onPressed: () => _adjustQty(1),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Unit selector
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? 'وحدة القياس' : 'Unit of Measure',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedUnit,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                            ),
                            items: _units.map((u) {
                              return DropdownMenuItem<String>(
                                value: u['code'],
                                child: Text(isArabic ? u['ar']! : u['en']!),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedUnit = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Unit Price & Discount Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? 'سعر الوحدة الشراء *' : 'Unit Purchase Price *',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _priceCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.attach_money),
                              suffixText: currency,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? 'خصم ممرّر (مبلغ)' : 'Discount Amount',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _discountCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.money_off),
                              suffixText: currency,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Tax VAT Rate Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isArabic ? 'نسبة ضريبة القيمة المضافة (ZATCA VAT):' : 'ZATCA VAT Rate:',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    SegmentedButton<double>(
                      segments: [
                        ButtonSegment(
                          value: 15.0,
                          label: Text(isArabic ? '15% أساسي' : '15% Standard'),
                        ),
                        ButtonSegment(
                          value: 0.0,
                          label: Text(isArabic ? '0% معفى' : '0% Exempt'),
                        ),
                      ],
                      selected: {_vatRate},
                      onSelectionChanged: (set) {
                        setState(() => _vatRate = set.first);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Live Impact Summary Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.primaryColor.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(isArabic ? 'المجموع الخاضع للضريبة:' : 'Taxable Subtotal:'),
                          Text(
                            '$currency ${_netSubtotal.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(isArabic ? 'ضريبة القيمة المضافة (15%):' : 'VAT Amount (15%):'),
                          Text(
                            '$currency ${_vatAmount.toStringAsFixed(2)}',
                            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.amber.shade900),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isArabic ? 'إجمالي الصنف الصافي:' : 'Item Total Amount:',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Text(
                            '$currency ${_totalLineAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(isArabic ? 'إلغاء' : 'Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.add_task),
                      label: Text(isArabic ? 'إضافة إلى الفاتورة' : 'Add to Invoice'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

