import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/procurement_models.dart';
import '../../utils/procurement_document_formatter.dart';
import '../../../../core/utils/document_sequence_formatter.dart';
import '../../providers/procurement_provider.dart';
import '../../../pos/providers/pos_provider.dart';
import '../../../suppliers/providers/suppliers_provider.dart';
import '../../../suppliers/domain/supplier_model.dart';

class _GrnLineItemInput {
  String? productId;
  final TextEditingController descController;
  final TextEditingController orderedQtyController;
  final TextEditingController receivedQtyController;
  final TextEditingController unitPriceController;

  _GrnLineItemInput({
    this.productId,
    String description = '',
    double orderedQty = 1.0,
    double receivedQty = 1.0,
    double unitPrice = 0.0,
  })  : descController = TextEditingController(text: description),
        orderedQtyController = TextEditingController(text: orderedQty > 0 ? orderedQty.toStringAsFixed(1) : '1.0'),
        receivedQtyController = TextEditingController(text: receivedQty > 0 ? receivedQty.toStringAsFixed(1) : '1.0'),
        unitPriceController = TextEditingController(text: unitPrice > 0 ? unitPrice.toStringAsFixed(2) : '0.00');

  double get orderedQuantity => double.tryParse(orderedQtyController.text) ?? 0.0;
  double get receivedQuantity => double.tryParse(receivedQtyController.text) ?? 0.0;
  double get unitPrice => double.tryParse(unitPriceController.text) ?? 0.0;
  double get totalValue => receivedQuantity * unitPrice;
  double get diff => receivedQuantity - orderedQuantity;

  void dispose() {
    descController.dispose();
    orderedQtyController.dispose();
    receivedQtyController.dispose();
    unitPriceController.dispose();
  }
}

class ReceiveGoodsDialog extends ConsumerStatefulWidget {
  final PurchaseOrderModel? preselectedPo;
  final bool isArabic;

  const ReceiveGoodsDialog({
    super.key,
    this.preselectedPo,
    this.isArabic = false,
  });

  @override
  ConsumerState<ReceiveGoodsDialog> createState() => _ReceiveGoodsDialogState();
}

class _ReceiveGoodsDialogState extends ConsumerState<ReceiveGoodsDialog> {
  final _formKey = GlobalKey<FormState>();

  bool _isFromPo = true;
  PurchaseOrderModel? _selectedPo;

  SupplierModel? _selectedSupplier;
  final _deliveryNoteController = TextEditingController();
  final _remarksController = TextEditingController();
  late TextEditingController _grnNumberController;

  String _selectedWarehouse = 'Central Warehouse';
  final List<String> _warehouses = [
    'Central Warehouse',
    'Main Store - Riyadh',
    'Jeddah Logistics Hub',
    'Dammam Depot',
    'Raw Materials Storage',
  ];

  DateTime _receivedDate = DateTime.now();
  final List<_GrnLineItemInput> _lineItems = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final defaultGrnNumber = DocumentSequenceFormatter.grnNumber(date: _receivedDate, sequence: 1);
    _grnNumberController = TextEditingController(text: defaultGrnNumber);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(procurementServiceProvider).fetchNextDocumentNumber('GRN').then((docNum) {
        if (mounted && (_grnNumberController.text == defaultGrnNumber || _grnNumberController.text.isEmpty)) {
          setState(() {
            _grnNumberController.text = docNum;
          });
        }
      });
    });

    if (widget.preselectedPo != null) {
      _isFromPo = true;
      _applyPurchaseOrder(widget.preselectedPo!);
    } else {
      _lineItems.add(_GrnLineItemInput(description: 'Consignment Item 1', orderedQty: 10, receivedQty: 10, unitPrice: 50));
    }
  }

  @override
  void dispose() {
    _grnNumberController.dispose();
    _deliveryNoteController.dispose();
    _remarksController.dispose();
    for (final item in _lineItems) {
      item.dispose();
    }
    super.dispose();
  }

  void _applyPurchaseOrder(PurchaseOrderModel po) {
    setState(() {
      _selectedPo = po;
      for (final item in _lineItems) {
        item.dispose();
      }
      _lineItems.clear();

      if (po.items.isNotEmpty) {
        for (final item in po.items) {
          _lineItems.add(
            _GrnLineItemInput(
              productId: item.productId,
              description: item.description,
              orderedQty: item.quantity,
              receivedQty: item.quantity,
              unitPrice: item.unitPrice,
            ),
          );
        }
      } else {
        _lineItems.add(
          _GrnLineItemInput(
            description: 'PO ${po.poNumber} Goods',
            orderedQty: 1.0,
            receivedQty: 1.0,
            unitPrice: double.tryParse(po.subtotalAmount) ?? 0.0,
          ),
        );
      }
    });
  }

  void _receiveAllOrdered() {
    setState(() {
      for (final item in _lineItems) {
        item.receivedQtyController.text = item.orderedQtyController.text;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isArabic ? 'تم ضبط الكمية المستلمة مطابقة للمطلوبة لجميع البنود' : 'All received quantities synced to ordered quantities',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  double get _totalOrderedQty => _lineItems.fold(0.0, (acc, i) => acc + i.orderedQuantity);
  double get _totalReceivedQty => _lineItems.fold(0.0, (acc, i) => acc + i.receivedQuantity);
  double get _totalReceivedVal => _lineItems.fold(0.0, (acc, i) => acc + i.totalValue);
  double get _fulfillmentRate => _totalOrderedQty > 0 ? (_totalReceivedQty / _totalOrderedQty) * 100 : 100.0;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _receivedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _receivedDate = picked);
    }
  }

  Future<void> _submitGrn() async {
    if (!_formKey.currentState!.validate()) return;

    if (_lineItems.isEmpty) {
      _showToast(widget.isArabic ? 'يرجى إضافة بند واحد على الأقل' : 'Please add at least one line item');
      return;
    }

    String supplierId;
    if (_isFromPo) {
      if (_selectedPo == null) {
        _showToast(widget.isArabic ? 'يرجى اختيار أمر الشراء' : 'Please select a purchase order');
        return;
      }
      supplierId = _selectedPo!.supplierId;
    } else {
      if (_selectedSupplier == null) {
        _showToast(widget.isArabic ? 'يرجى اختيار المورد' : 'Please select a supplier');
        return;
      }
      supplierId = _selectedSupplier!.id;
    }

    setState(() => _isSubmitting = true);

    try {
      final payload = {
        'grnNumber': _grnNumberController.text.trim(),
        'poId': _isFromPo ? _selectedPo?.id : null,
        'poNumber': _isFromPo ? _selectedPo?.poNumber : null,
        'supplierId': supplierId,
        'warehouseId': _selectedWarehouse,
        'receivedDate': _receivedDate.toIso8601String(),
        'deliveryNoteNumber': _deliveryNoteController.text.trim(),
        'remarks': _remarksController.text.trim(),
        'items': _lineItems.map((item) {
          return {
            'productId': item.productId,
            'description': item.descController.text.trim().isEmpty ? 'Goods Item' : item.descController.text.trim(),
            'orderedQuantity': item.orderedQuantity,
            'receivedQuantity': item.receivedQuantity,
            'unitPrice': item.unitPrice,
          };
        }).toList(),
      };

      await ref.read(procurementServiceProvider).createGoodsReceivedNote(payload);
      ref.invalidate(goodsReceivedNotesProvider);
      ref.invalidate(purchaseOrdersProvider);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isArabic ? 'تم حفظ إذن الاستلام بنجاح' : 'Goods Received Note recorded successfully!',
            ),
            backgroundColor: Colors.teal.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showToast(widget.isArabic ? 'فشل الحفظ: $e' : 'Failed to record GRN: $e');
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
    final poAsync = ref.watch(purchaseOrdersProvider);
    final suppliersAsync = ref.watch(suppliersProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 920,
        constraints: const BoxConstraints(maxHeight: 820),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  border: Border(bottom: BorderSide(color: theme.dividerColor)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.move_to_inbox_rounded, color: Colors.teal, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAr ? 'تسجيل إذن استلام بضائع جديد (GRN)' : 'Receive Goods Note (GRN Entry)',
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            isAr
                                ? 'استلام الشحنات وتوثيق الكميات الفعلية ومطابقتها مع أمر الشراء'
                                : 'Record inbound consignment, verify physical count against PO, and update inventory',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Body Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Source Selection: From PO vs Direct
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            Text(
                              isAr ? 'مصدر الاستلام:' : 'Receiving Source:',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(width: 16),
                            SegmentedButton<bool>(
                              segments: [
                                ButtonSegment<bool>(
                                  value: true,
                                  label: Text(isAr ? 'من أمر شراء (موصى به)' : 'Against Purchase Order (Best)'),
                                  icon: const Icon(Icons.assignment_turned_in_rounded, size: 18),
                                ),
                                ButtonSegment<bool>(
                                  value: false,
                                  label: Text(isAr ? 'استلام مباشر (بدون PO)' : 'Direct Receiving (No PO)'),
                                  icon: const Icon(Icons.post_add_rounded, size: 18),
                                ),
                              ],
                              selected: {_isFromPo},
                              onSelectionChanged: (set) {
                                setState(() {
                                  _isFromPo = set.first;
                                  if (!_isFromPo) {
                                    _selectedPo = null;
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // PO Selector or Supplier Selector
                      if (_isFromPo) ...[
                        poAsync.when(
                          data: (pos) {
                            return DropdownButtonFormField<PurchaseOrderModel>(
                              initialValue: _selectedPo,
                              decoration: InputDecoration(
                                labelText: isAr ? 'اختر أمر الشراء (PO) *' : 'Select Purchase Order (PO) *',
                                prefixIcon: const Icon(Icons.receipt_long_rounded, color: Colors.blue),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                helperText: isAr
                                    ? 'سيتم استيراد كافة بنود ومورد أمر الشراء تلقائياً'
                                    : 'Supplier and line items will be auto-imported from PO',
                              ),
                              items: pos.map((po) {
                                return DropdownMenuItem<PurchaseOrderModel>(
                                  value: po,
                                  child: Text(
                                    '${po.poNumber} — ${po.supplierName} (Total: SAR ${po.totalAmount}) [${po.status}]',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (po) {
                                if (po != null) _applyPurchaseOrder(po);
                              },
                              validator: (val) {
                                if (_isFromPo && val == null && _selectedPo == null) {
                                  return isAr ? 'يرجى اختيار أمر شراء' : 'Please select a purchase order';
                                }
                                return null;
                              },
                            );
                          },
                          loading: () => const LinearProgressIndicator(),
                          error: (e, _) => Text('Error loading POs: $e', style: const TextStyle(color: Colors.red)),
                        ),
                      ] else ...[
                        suppliersAsync.when(
                          data: (suppliers) {
                            return DropdownButtonFormField<SupplierModel>(
                              initialValue: _selectedSupplier,
                              decoration: InputDecoration(
                                labelText: isAr ? 'المورد / جهة التوريد *' : 'Supplier / Vendor *',
                                prefixIcon: const Icon(Icons.storefront_rounded, color: Colors.blue),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              items: suppliers.map((sup) {
                                return DropdownMenuItem<SupplierModel>(
                                  value: sup,
                                  child: Text('${sup.name} (${ProcurementDocumentFormatter.formatSupplierCode(sup.id)})'),
                                );
                              }).toList(),
                              onChanged: (sup) => setState(() => _selectedSupplier = sup),
                              validator: (val) {
                                if (!_isFromPo && val == null) {
                                  return isAr ? 'يرجى اختيار المورد' : 'Please select a supplier';
                                }
                                return null;
                              },
                            );
                          },
                          loading: () => const LinearProgressIndicator(),
                          error: (e, _) => Text('Error loading suppliers: $e', style: const TextStyle(color: Colors.red)),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Metadata Grid (GRN #, Delivery Note #, Warehouse, Date)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _grnNumberController,
                              decoration: InputDecoration(
                                labelText: isAr ? 'رقم إذن الاستلام (GRN #) *' : 'GRN Number *',
                                prefixIcon: const Icon(Icons.tag_rounded),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _deliveryNoteController,
                              decoration: InputDecoration(
                                labelText: isAr ? 'رقم إشعار التسليم / البوليصة' : 'Delivery Note # / Waybill',
                                prefixIcon: const Icon(Icons.local_shipping_outlined),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedWarehouse,
                              decoration: InputDecoration(
                                labelText: isAr ? 'المستودع المستلم *' : 'Receiving Warehouse *',
                                prefixIcon: const Icon(Icons.warehouse_rounded),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              items: _warehouses.map((w) => DropdownMenuItem(value: w, child: Text(w))).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedWarehouse = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: _pickDate,
                              borderRadius: BorderRadius.circular(10),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: isAr ? 'تاريخ الاستلام *' : 'Received Date *',
                                  prefixIcon: const Icon(Icons.calendar_today_rounded),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: Text(
                                  DateFormat('yyyy-MM-dd').format(_receivedDate),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Items Section Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAr ? 'قائمة الأصناف ومطابقة الكميات' : 'Consignment Line Items Verification',
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                isAr
                                    ? 'سجّل الكمية المستلمة الفعلية مقارنة بالمطلوبة'
                                    : 'Verify actual physical count against ordered quantity',
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              if (_isFromPo && _lineItems.isNotEmpty)
                                TextButton.icon(
                                  icon: const Icon(Icons.done_all_rounded, size: 18),
                                  label: Text(isAr ? 'استلام الكل (مكتمل)' : 'Sync All = Ordered'),
                                  onPressed: _receiveAllOrdered,
                                ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.add_rounded, size: 18),
                                label: Text(isAr ? 'إضافة بند يدوي' : 'Add Custom Item'),
                                onPressed: () {
                                  setState(() {
                                    _lineItems.add(_GrnLineItemInput());
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Line items list
                      ...List.generate(_lineItems.length, (index) {
                        final item = _lineItems[index];
                        final diff = item.diff;

                        return Container(
                          key: ValueKey('grn_item_$index'),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: diff < 0
                                  ? Colors.red.withValues(alpha: 0.4)
                                  : (diff > 0 ? Colors.amber.withValues(alpha: 0.4) : theme.dividerColor),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: Colors.teal.withValues(alpha: 0.15),
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Description & Product Catalog Button
                                  Expanded(
                                    flex: 4,
                                    child: Column(
                                      children: [
                                        TextFormField(
                                          controller: item.descController,
                                          decoration: InputDecoration(
                                            labelText: isAr ? 'وصف الصنف / المنتج *' : 'Item Description *',
                                            isDense: true,
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                            suffixIcon: IconButton(
                                              icon: const Icon(Icons.inventory_2_outlined, size: 18),
                                              tooltip: isAr ? 'اختيار من الكتالوج' : 'Pick from Catalog',
                                              onPressed: () => _pickProductFromCatalog(item),
                                            ),
                                          ),
                                          onChanged: (_) => setState(() {}),
                                          validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Ordered Qty (READ-ONLY / NOT EDITABLE)
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      controller: item.orderedQtyController,
                                      readOnly: true,
                                      style: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: isAr ? 'المطلوب (أمر الشراء)' : 'Ordered Qty',
                                        prefixIcon: const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
                                        fillColor: Colors.grey.shade100,
                                        filled: true,
                                        isDense: true,
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(color: Colors.grey.shade300),
                                        ),
                                        helperText: isAr ? 'ثابت من أمر الشراء' : 'Locked from PO',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Received Qty
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      controller: item.receivedQtyController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: InputDecoration(
                                        labelText: isAr ? 'المستلم فعلياً *' : 'Received Qty *',
                                        isDense: true,
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: const BorderSide(color: Colors.teal, width: 2),
                                        ),
                                      ),
                                      onChanged: (val) {
                                        if (!_isFromPo) {
                                          item.orderedQtyController.text = val;
                                        }
                                        setState(() {});
                                      },
                                      validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Unit Price
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      controller: item.unitPriceController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: InputDecoration(
                                        labelText: isAr ? 'سعر الوحدة' : 'Unit Cost',
                                        prefixText: 'SAR ',
                                        isDense: true,
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Total value display
                                  Container(
                                    width: 100,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.teal.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          isAr ? 'الإجمالي' : 'Line Total',
                                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                                        ),
                                        Text(
                                          'SAR ${item.totalValue.toStringAsFixed(2)}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  // Remove Button
                                  if (_lineItems.length > 1)
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          final removed = _lineItems.removeAt(index);
                                          removed.dispose();
                                        });
                                      },
                                    ),
                                ],
                              ),
                              // Discrepancy indicator bar
                              if (diff != 0) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const SizedBox(width: 40),
                                    Icon(
                                      diff < 0 ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
                                      size: 14,
                                      color: diff < 0 ? Colors.red.shade700 : Colors.amber.shade900,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      diff < 0
                                          ? '${isAr ? "عجز بمقدار" : "Shortage of"} ${(-diff).toStringAsFixed(1)} ${isAr ? "وحدة" : "units"}'
                                          : '${isAr ? "فائض بمقدار" : "Over-delivered by"} ${diff.toStringAsFixed(1)} ${isAr ? "وحدة" : "units"}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: diff < 0 ? Colors.red.shade700 : Colors.amber.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 12),

                      // Remarks input
                      TextFormField(
                        controller: _remarksController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: isAr ? 'ملاحظات الفحص والاستلام / تفاصيل الشحن' : 'Receiving Remarks / Package Condition',
                          hintText: isAr
                              ? 'مثال: تم فحص الكراتين، البضاعة بحالة ممتازة، رقم السيارة 1234'
                              : 'e.g., Consignment inspected, all cartons sound, carrier truck # 4821',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Live Summary Panel
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.teal.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.teal.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSummaryItem(
                              label: isAr ? 'إجمالي الأصناف' : 'Total Items',
                              value: '${_lineItems.length}',
                              color: Colors.blue,
                            ),
                            _buildSummaryItem(
                              label: isAr ? 'المطلوب كلياً' : 'Total Ordered',
                              value: _totalOrderedQty.toStringAsFixed(1),
                              color: Colors.indigo,
                            ),
                            _buildSummaryItem(
                              label: isAr ? 'المستلم كلياً' : 'Total Received',
                              value: _totalReceivedQty.toStringAsFixed(1),
                              color: Colors.teal.shade800,
                            ),
                            _buildSummaryItem(
                              label: isAr ? 'نسبة الاستيفاء' : 'Fulfillment',
                              value: '${_fulfillmentRate.toStringAsFixed(0)}%',
                              color: _fulfillmentRate >= 100 ? Colors.green : Colors.amber.shade900,
                            ),
                            _buildSummaryItem(
                              label: isAr ? 'القيمة التقديرية (ر.س)' : 'Total Value (SAR)',
                              value: 'SAR ${_totalReceivedVal.toStringAsFixed(2)}',
                              color: Colors.teal.shade900,
                              isBold: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Actions
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                  border: Border(top: BorderSide(color: theme.dividerColor)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                      child: Text(isAr ? 'إلغاء' : 'Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      icon: _isSubmitting
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.check_circle_rounded, size: 20),
                      label: Text(
                        _isSubmitting
                            ? (isAr ? 'جاري الحفظ...' : 'Saving GRN...')
                            : (isAr ? 'حفظ إذن الاستلام' : 'Confirm & Save GRN'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: _isSubmitting ? null : _submitGrn,
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

  Widget _buildSummaryItem({
    required String label,
    required String value,
    required Color color,
    bool isBold = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  void _pickProductFromCatalog(_GrnLineItemInput lineItem) {
    showDialog(
      context: context,
      builder: (ctx) => Consumer(
        builder: (context, ref, child) {
          final productsAsync = ref.watch(productsProvider);
          return AlertDialog(
            title: Text(widget.isArabic ? 'اختر المنتج من الكتالوج' : 'Pick Product from Catalog'),
            content: SizedBox(
              width: 500,
              height: 400,
              child: productsAsync.when(
                data: (products) {
                  return ListView.separated(
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, idx) {
                      final p = products[idx];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal.withValues(alpha: 0.15),
                          child: const Icon(Icons.inventory_2_outlined, color: Colors.teal, size: 18),
                        ),
                        title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('SKU: ${p.sku} | Cost: SAR ${p.costPrice}'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          setState(() {
                            lineItem.productId = p.id;
                            lineItem.descController.text = p.name;
                            lineItem.unitPriceController.text = p.costPrice ?? p.price;
                          });
                          Navigator.of(ctx).pop();
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(widget.isArabic ? 'إلغاء' : 'Cancel'),
              ),
            ],
          );
        },
      ),
    );
  }
}
