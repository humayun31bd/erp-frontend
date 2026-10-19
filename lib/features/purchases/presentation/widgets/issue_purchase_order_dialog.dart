import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../pos/providers/pos_provider.dart';
import '../../../suppliers/providers/suppliers_provider.dart';
import '../../../suppliers/domain/supplier_model.dart';
import '../../../../core/utils/document_sequence_formatter.dart';
import '../../providers/procurement_provider.dart';
import '../../utils/procurement_document_formatter.dart';

class IssuePurchaseOrderDialog extends ConsumerStatefulWidget {
  final bool isArabic;

  const IssuePurchaseOrderDialog({
    super.key,
    required this.isArabic,
  });

  @override
  ConsumerState<IssuePurchaseOrderDialog> createState() => _IssuePurchaseOrderDialogState();
}

class _PoLineItemInput {
  String? productId;
  final TextEditingController descController = TextEditingController();
  final TextEditingController qtyController = TextEditingController(text: '1');
  final TextEditingController priceController = TextEditingController(text: '0');
  double vatRate = 15.0;

  _PoLineItemInput();

  double get quantity => double.tryParse(qtyController.text) ?? 1.0;
  double get unitPrice => double.tryParse(priceController.text) ?? 0.0;
  double get subtotal => quantity * unitPrice;
  double get vatAmount => subtotal * (vatRate / 100);
  double get totalAmount => subtotal + vatAmount;

  void dispose() {
    descController.dispose;
    qtyController.dispose;
    priceController.dispose;
  }
}

class _IssuePurchaseOrderDialogState extends ConsumerState<IssuePurchaseOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _poNumberController;
  final _notesController = TextEditingController();

  SupplierModel? _selectedSupplier;
  final _customSupplierNameController = TextEditingController();
  final _customSupplierIdController = TextEditingController();
  bool _useCustomSupplier = false;

  DateTime _issueDate = DateTime.now();
  DateTime? _expectedDeliveryDate;

  final List<_PoLineItemInput> _lineItems = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final defaultPoNumber = DocumentSequenceFormatter.poNumber(date: _issueDate, sequence: 1);
    _poNumberController = TextEditingController(text: defaultPoNumber);
    _lineItems.add(_PoLineItemInput());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(procurementServiceProvider).fetchNextDocumentNumber('PO').then((docNum) {
        if (mounted && (_poNumberController.text == defaultPoNumber || _poNumberController.text.isEmpty)) {
          setState(() {
            _poNumberController.text = docNum;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _poNumberController.dispose();
    _notesController.dispose();
    _customSupplierNameController.dispose();
    _customSupplierIdController.dispose();
    for (final item in _lineItems) {
      item.dispose();
    }
    super.dispose();
  }

  double get _computedSubtotal => _lineItems.fold(0.0, (acc, i) => acc + i.subtotal);
  double get _computedVat => _lineItems.fold(0.0, (acc, i) => acc + i.vatAmount);
  double get _computedTotal => _lineItems.fold(0.0, (acc, i) => acc + i.totalAmount);

  Future<void> _pickDate({required bool isDelivery}) async {
    final initial = isDelivery ? (_expectedDeliveryDate ?? DateTime.now().add(const Duration(days: 7))) : _issueDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        if (isDelivery) {
          _expectedDeliveryDate = picked;
        } else {
          _issueDate = picked;
        }
      });
    }
  }

  Future<void> _submitPo() async {
    if (!_formKey.currentState!.validate()) return;

    String supplierId;
    String supplierName;

    if (_useCustomSupplier) {
      if (_customSupplierNameController.text.trim().isEmpty) {
        _showToast(widget.isArabic ? 'يرجى كتابة اسم المورد' : 'Please provide supplier name');
        return;
      }
      supplierName = _customSupplierNameController.text.trim();
      supplierId = _customSupplierIdController.text.trim().isEmpty
          ? 'SUP-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}'
          : _customSupplierIdController.text.trim();
    } else {
      if (_selectedSupplier == null) {
        _showToast(widget.isArabic ? 'يرجى اختيار المورد من القائمة' : 'Please select a supplier');
        return;
      }
      supplierId = _selectedSupplier!.id;
      supplierName = _selectedSupplier!.name;
    }

    if (_lineItems.isEmpty) {
      _showToast(widget.isArabic ? 'يجب إضافة صنف واحد على الأقل' : 'Please add at least one line item');
      return;
    }

    for (int i = 0; i < _lineItems.length; i++) {
      if (_lineItems[i].descController.text.trim().isEmpty) {
        _showToast(widget.isArabic ? 'يرجى إدخال وصف الصنف رقم ${i + 1}' : 'Please enter description for line ${i + 1}');
        return;
      }
    }

    setState(() => _isSubmitting = true);

    final payload = {
      'poNumber': _poNumberController.text.trim(),
      'supplierId': supplierId,
      'supplierName': supplierName,
      'issueDate': _issueDate.toIso8601String(),
      'expectedDeliveryDate': _expectedDeliveryDate?.toIso8601String(),
      'notes': _notesController.text.trim(),
      'status': 'ISSUED',
      'items': _lineItems.map((item) {
        return {
          'productId': item.productId,
          'description': item.descController.text.trim(),
          'quantity': item.quantity,
          'unitPrice': item.unitPrice,
          'vatRate': item.vatRate,
        };
      }).toList(),
    };

    try {
      await ref.read(procurementServiceProvider).createPurchaseOrder(payload);
      ref.invalidate(purchaseOrdersProvider);
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isArabic ? 'تم إصدار أمر الشراء بنجاح!' : 'Purchase Order ${_poNumberController.text} issued successfully!',
            ),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showToast(widget.isArabic ? 'فشل إصدار أمر الشراء: $e' : 'Failed to issue PO: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = widget.isArabic;
    final suppliersAsync = ref.watch(suppliersProvider);
    final productsAsync = ref.watch(productsProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 880,
        constraints: const BoxConstraints(maxHeight: 820),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAr ? 'إصدار أمر شراء رسمي جديد (Issue PO)' : 'Issue New Purchase Order (PO)',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            isAr ? 'أدخل تفاصيل المورد والبنود والكميات والأسعار' : 'Configure vendor, items, quantities, and delivery schedule',
                            style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Form Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Supplier Section
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      isAr ? 'المورد المعتمد *' : 'Vendor / Supplier *',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _useCustomSupplier = !_useCustomSupplier;
                                          _selectedSupplier = null;
                                        });
                                      },
                                      child: Text(
                                        _useCustomSupplier
                                            ? (isAr ? 'اختر من الدليل' : 'Pick from Directory')
                                            : (isAr ? '+ مورد يدوي' : '+ Custom Vendor'),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                                if (!_useCustomSupplier)
                                  suppliersAsync.when(
                                    data: (suppliers) {
                                      return DropdownButtonFormField<SupplierModel>(
                                        initialValue: _selectedSupplier,
                                        isExpanded: true,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                          hintText: isAr ? 'اختر المورد...' : 'Select Supplier...',
                                          prefixIcon: const Icon(Icons.business, size: 20),
                                        ),
                                        items: suppliers.map((s) {
                                          return DropdownMenuItem<SupplierModel>(
                                            value: s,
                                            child: Text('${s.name} (${s.vatNumber ?? ProcurementDocumentFormatter.formatSupplierCode(s.id)})', overflow: TextOverflow.ellipsis),
                                          );
                                        }).toList(),
                                        onChanged: (val) => setState(() => _selectedSupplier = val),
                                        validator: (val) => val == null && !_useCustomSupplier ? (isAr ? 'حقل مطلوب' : 'Required') : null,
                                      );
                                    },
                                    loading: () => const LinearProgressIndicator(),
                                    error: (err, _) => Text('Error loading suppliers: $err', style: const TextStyle(color: Colors.red)),
                                  )
                                else
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: TextFormField(
                                          controller: _customSupplierNameController,
                                          decoration: InputDecoration(
                                            labelText: isAr ? 'اسم المورد *' : 'Supplier Name *',
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                          ),
                                          validator: (v) => _useCustomSupplier && (v == null || v.trim().isEmpty) ? (isAr ? 'مطلوب' : 'Required') : null,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _customSupplierIdController,
                                          decoration: InputDecoration(
                                            labelText: isAr ? 'رمز المورد (اختياري)' : 'Supplier Code',
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(isAr ? 'رقم أمر الشراء *' : 'PO Number *', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _poNumberController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    prefixIcon: const Icon(Icons.tag, size: 20),
                                  ),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? (isAr ? 'مطلوب' : 'Required') : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Dates row
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _pickDate(isDelivery: false),
                              borderRadius: BorderRadius.circular(10),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: isAr ? 'تاريخ الإصدار' : 'Issue Date',
                                  prefixIcon: const Icon(Icons.today, size: 20),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                ),
                                child: Text(DateFormat('yyyy-MM-dd').format(_issueDate)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () => _pickDate(isDelivery: true),
                              borderRadius: BorderRadius.circular(10),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: isAr ? 'تاريخ التوريد المتوقع' : 'Expected Delivery Date',
                                  prefixIcon: const Icon(Icons.event, size: 20),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                ),
                                child: Text(
                                  _expectedDeliveryDate != null
                                      ? DateFormat('yyyy-MM-dd').format(_expectedDeliveryDate!)
                                      : (isAr ? 'اختر تاريخ التوريد' : 'Select Delivery Date'),
                                  style: TextStyle(
                                    color: _expectedDeliveryDate == null ? theme.textTheme.bodySmall?.color : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Line Items Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isAr ? 'بنود وأصناف أمر الشراء' : 'Order Line Items',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.add_circle_outline, size: 18),
                            label: Text(isAr ? 'إضافة سطر صنف' : 'Add Line Item'),
                            onPressed: () {
                              setState(() {
                                _lineItems.add(_PoLineItemInput());
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Line items list
                      ..._lineItems.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: theme.colorScheme.primaryContainer,
                                    child: Text('${idx + 1}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                                  ),
                                  const SizedBox(width: 8),
                                  // Product quick selector
                                  Expanded(
                                    flex: 3,
                                    child: productsAsync.when(
                                      data: (products) {
                                        return DropdownButton<String?>(
                                          value: item.productId,
                                          isExpanded: true,
                                          underline: const SizedBox.shrink(),
                                          hint: Text(isAr ? 'اختر من المنتجات (اختياري)' : 'Select Catalog Product (Optional)', style: const TextStyle(fontSize: 12)),
                                          items: [
                                            DropdownMenuItem<String?>(value: null, child: Text(isAr ? '-- وصف حر --' : '-- Custom Item --', style: const TextStyle(fontSize: 12))),
                                            ...products.map((p) => DropdownMenuItem<String?>(
                                                  value: p.id,
                                                  child: Text('${p.name} (SAR ${p.costPrice ?? p.price})', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                                                )),
                                          ],
                                          onChanged: (prodId) {
                                            setState(() {
                                              item.productId = prodId;
                                              if (prodId != null) {
                                                final found = products.where((p) => p.id == prodId).firstOrNull;
                                                if (found != null) {
                                                  item.descController.text = found.name;
                                                  final cost = found.costPrice ?? found.price;
                                                  item.priceController.text = cost;
                                                }
                                              }
                                            });
                                          },
                                        );
                                      },
                                      loading: () => const SizedBox.shrink(),
                                      error: (_, __) => const SizedBox.shrink(),
                                    ),
                                  ),
                                  if (_lineItems.length > 1)
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                      tooltip: isAr ? 'حذف السطر' : 'Remove item',
                                      onPressed: () {
                                        setState(() {
                                          _lineItems.removeAt(idx);
                                        });
                                      },
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  // Description
                                  Expanded(
                                    flex: 4,
                                    child: TextFormField(
                                      controller: item.descController,
                                      decoration: InputDecoration(
                                        labelText: isAr ? 'وصف الصنف / البند *' : 'Description *',
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                        isDense: true,
                                      ),
                                      validator: (v) => (v == null || v.trim().isEmpty) ? (isAr ? 'مطلوب' : 'Required') : null,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Quantity
                                  SizedBox(
                                    width: 90,
                                    child: TextFormField(
                                      controller: item.qtyController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: InputDecoration(
                                        labelText: isAr ? 'الكمية' : 'Qty',
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                        isDense: true,
                                      ),
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Price
                                  SizedBox(
                                    width: 120,
                                    child: TextFormField(
                                      controller: item.priceController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: InputDecoration(
                                        labelText: isAr ? 'السعر (ر.س)' : 'Price (SAR)',
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                        isDense: true,
                                      ),
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Line Total
                                  Container(
                                    width: 130,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'SAR ${item.totalAmount.toStringAsFixed(2)}',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.colorScheme.primary),
                                        ),
                                        Text('VAT: ${item.vatRate.toStringAsFixed(0)}%', style: TextStyle(fontSize: 10, color: theme.textTheme.bodySmall?.color)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 16),

                      // Notes & Financial Totals
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _notesController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: isAr ? 'تعليمات التوريد والشروط / الملاحظات' : 'Delivery Instructions / Payment Terms',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.all(12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(isAr ? 'المجموع الفرعي:' : 'Subtotal:', style: const TextStyle(fontSize: 12)),
                                      Text('SAR ${_computedSubtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(isAr ? 'ضريبة القيمة المضافة (15%):' : 'VAT (15%):', style: const TextStyle(fontSize: 12)),
                                      Text('SAR ${_computedVat.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                  const Divider(height: 14),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        isAr ? 'الإجمالي العام:' : 'Grand Total:',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: theme.colorScheme.primary),
                                      ),
                                      Text(
                                        'SAR ${_computedTotal.toStringAsFixed(2)}',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.primary),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                      child: Text(isAr ? 'إلغاء' : 'Cancel'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      icon: _isSubmitting
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.send_rounded, size: 18),
                      label: Text(
                        _isSubmitting
                            ? (isAr ? 'جاري الإصدار...' : 'Issuing PO...')
                            : (isAr ? 'إصدار أمر الشراء الآن' : 'Issue Purchase Order'),
                      ),
                      onPressed: _isSubmitting ? null : _submitPo,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
