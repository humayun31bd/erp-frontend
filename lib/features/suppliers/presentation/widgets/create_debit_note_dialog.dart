import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/supplier_model.dart';
import '../../domain/supplier_return_model.dart';
import '../../providers/suppliers_provider.dart';
import '../../../purchases/domain/procurement_models.dart';
import '../../../purchases/providers/procurement_provider.dart';
import '../../../purchases/presentation/widgets/supplier_selection_modal.dart';

class _DebitNoteItemDraft {
  String? productId;
  String? grnNumber;
  String? poNumber;
  final TextEditingController descriptionController;
  final TextEditingController quantityController;
  final TextEditingController unitPriceController;
  String reason;

  _DebitNoteItemDraft({
    this.productId,
    this.grnNumber,
    this.poNumber,
    required String description,
    required double quantity,
    required double unitPrice,
    this.reason = 'DEFECTIVE',
  })  : descriptionController = TextEditingController(text: description),
        quantityController = TextEditingController(text: quantity.toString()),
        unitPriceController = TextEditingController(text: unitPrice.toString());

  double get quantity => double.tryParse(quantityController.text) ?? 0.0;
  double get unitPrice => double.tryParse(unitPriceController.text) ?? 0.0;
  double get subtotal => quantity * unitPrice;
  double get vatAmount => subtotal * 0.15;
  double get totalAmount => subtotal + vatAmount;

  void dispose() {
    descriptionController.dispose();
    quantityController.dispose();
    unitPriceController.dispose();
  }
}

class CreateDebitNoteDialog extends ConsumerStatefulWidget {
  final bool isArabic;
  final SupplierModel? initialSupplier;
  final ValueChanged<SupplierReturnModel> onReturnCreated;

  const CreateDebitNoteDialog({
    super.key,
    required this.isArabic,
    this.initialSupplier,
    required this.onReturnCreated,
  });

  @override
  ConsumerState<CreateDebitNoteDialog> createState() => _CreateDebitNoteDialogState();
}

class _CreateDebitNoteDialogState extends ConsumerState<CreateDebitNoteDialog> {
  final _formKey = GlobalKey<FormState>();

  SupplierModel? _selectedSupplier;
  late TextEditingController _debitNoteNumberController;
  late TextEditingController _returnNumberController;
  late TextEditingController _billRefController;
  late TextEditingController _remarksController;

  final DateTime _returnDate = DateTime.now();
  String _overallReason = 'DEFECTIVE';
  final List<_DebitNoteItemDraft> _items = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    _debitNoteNumberController = TextEditingController(text: 'DN-2026-$timestamp');
    _returnNumberController = TextEditingController(text: 'PRN-2026-$timestamp');
    _billRefController = TextEditingController();
    _remarksController = TextEditingController();

    if (widget.initialSupplier != null) {
      _selectedSupplier = widget.initialSupplier;
    }
  }

  @override
  void dispose() {
    _debitNoteNumberController.dispose();
    _returnNumberController.dispose();
    _billRefController.dispose();
    _remarksController.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  double get _grossSubtotal => _items.fold(0.0, (sum, i) => sum + i.subtotal);
  double get _totalVat => _items.fold(0.0, (sum, i) => sum + i.vatAmount);
  double get _grandTotal => _items.fold(0.0, (sum, i) => sum + i.totalAmount);

  // --- Supplier Modal Opener ---
  void _openSupplierModal() {
    showDialog(
      context: context,
      builder: (ctx) => SupplierSelectionModal(
        isArabic: widget.isArabic,
        currentSelectedSupplierId: _selectedSupplier?.id,
        onSelected: (supplier) {
          if (supplier != null && supplier.id != _selectedSupplier?.id) {
            setState(() {
              _selectedSupplier = supplier;
              // Clear previous items from another supplier if any
              if (_items.isNotEmpty) {
                _items.clear();
              }
            });
          }
        },
      ),
    );
  }

  // --- Add Manual Item ---
  void _addManualItem() {
    setState(() {
      _items.add(
        _DebitNoteItemDraft(
          description: widget.isArabic ? 'بند مرتجع يدوي' : 'Manual Return Item',
          quantity: 1.0,
          unitPrice: 100.0,
          reason: _overallReason,
        ),
      );
    });
  }

  // --- Add Items from GRN Modal ---
  void _openGrnItemPicker() {
    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isArabic
                ? 'يرجى اختيار المورد أولاً لتحميل إشعارات الاستلام (GRN) الخاصة به'
                : 'Please select a supplier first to load their Goods Received Notes (GRNs)',
          ),
          backgroundColor: Colors.amber.shade900,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => _GrnItemPickerModal(
        isArabic: widget.isArabic,
        supplier: _selectedSupplier!,
        onItemsSelected: (selectedDrafts) {
          setState(() {
            _items.addAll(selectedDrafts);
            // Auto fill original bill/po ref if empty
            if (_billRefController.text.isEmpty && selectedDrafts.isNotEmpty) {
              final firstGrn = selectedDrafts.first.grnNumber;
              if (firstGrn != null) {
                _billRefController.text = firstGrn;
              }
            }
          });
        },
      ),
    );
  }

  // --- Submit Debit Note ---
  Future<void> _submitDebitNote() async {
    final isAr = widget.isArabic;

    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAr ? 'يرجى اختيار المورد' : 'Please select a supplier'),
          backgroundColor: Colors.red.shade800,
        ),
      );
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr
                ? 'يرجى إضافة بند واحد على الأقل من إشعار الاستلام (GRN) أو يدوياً'
                : 'Please add at least one line item from GRN or manually',
          ),
          backgroundColor: Colors.red.shade800,
        ),
      );
      return;
    }

    // Check valid quantities & prices
    for (final it in _items) {
      if (it.quantity <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAr
                  ? 'يجب أن تكون كمية الإرجاع أكبر من الصفر للبند: ${it.descriptionController.text}'
                  : 'Return quantity must be greater than zero for: ${it.descriptionController.text}',
            ),
            backgroundColor: Colors.red.shade800,
          ),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      final now = DateTime.now();
      final returnId = 'ret-${now.millisecondsSinceEpoch}';

      final List<SupplierReturnItemModel> returnItems = _items.asMap().entries.map((entry) {
        final idx = entry.key;
        final d = entry.value;
        return SupplierReturnItemModel(
          id: 'item-$returnId-$idx',
          productId: d.productId,
          itemDescription: d.descriptionController.text.trim(),
          unitPrice: d.unitPrice,
          quantity: d.quantity,
          vatRate: 15.0,
          vatAmount: d.vatAmount,
          totalAmount: d.totalAmount,
          reason: d.reason,
        );
      }).toList();

      final newReturn = SupplierReturnModel(
        id: returnId,
        tenantId: '336eaf82-a524-4b0a-9326-7197b1e5459e',
        returnNumber: _returnNumberController.text.trim(),
        debitNoteNumber: _debitNoteNumberController.text.trim(),
        supplierId: _selectedSupplier!.id,
        supplierName: _selectedSupplier!.name,
        billNumber: _billRefController.text.trim().isNotEmpty ? _billRefController.text.trim() : null,
        returnDate: _returnDate.toIso8601String(),
        reason: _overallReason,
        subtotalAmount: _grossSubtotal,
        vatAmount: _totalVat,
        totalAmount: _grandTotal,
        status: 'APPROVED',
        refundStatus: 'PENDING',
        remarks: _remarksController.text.trim(),
        createdAt: now.toIso8601String(),
        items: returnItems,
      );

      final api = ref.read(supplierApiProvider);
      await api.createSupplierReturn(newReturn.toJson());

      widget.onReturnCreated(newReturn);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAr
                  ? 'تم إنشاء واعتماد الإشعار المدين بنجاح (${newReturn.debitNoteNumber})'
                  : 'Debit Note issued and approved successfully (${newReturn.debitNoteNumber})',
            ),
            backgroundColor: Colors.green.shade800,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isAr ? 'فشل حفظ الإشعار المدين: $e' : 'Failed to save debit note: $e'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isArabic;
    final suppliersList = ref.watch(suppliersProvider).value ?? [];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Container(
        width: 1050,
        height: 780,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Dialog Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  border: Border(bottom: BorderSide(color: Colors.blue.shade100)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue.shade700,
                      radius: 20,
                      child: const Icon(Icons.assignment_return_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                isAr ? 'إنشاء إشعار مدين للمورد (مرتجع مشتريات)' : 'Create Supplier Debit Note (Purchase Return)',
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.blue.shade300),
                                ),
                                child: Text(
                                  _debitNoteNumberController.text,
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isAr
                                ? 'إشعار ضريبي مدين معتمد من هيئة الزكاة (ZATCA Phase 2) مع ربط واستيراد بنود إشعار الاستلام (GRN)'
                                : 'ZATCA-compliant Tax Debit Note with 15% VAT adjustment & Goods Received Note (GRN) reconciliation',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
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

              // Scrollable Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Supplier Selection & Info Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.business_rounded, color: Colors.blue.shade800, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      isAr ? 'بيانات المورد (Supplier Details) *' : 'Supplier Details *',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                                    ),
                                  ],
                                ),
                                // Supplier Popup Modal Button
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  icon: const Icon(Icons.person_search_rounded, size: 18),
                                  label: Text(
                                    isAr ? 'دليل وبحث الموردين (نافذة)' : 'Supplier Modal (Search & Grid)',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  onPressed: _openSupplierModal,
                                ),
                              ],
                            ),
                            const Divider(height: 20),

                            Row(
                              children: [
                                // Quick Dropdown
                                Expanded(
                                  flex: 3,
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _selectedSupplier?.id,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      labelText: isAr ? 'اختيار المورد المعتمد بالاسم' : 'Select Approved Supplier',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      isDense: true,
                                    ),
                                    items: [
                                      DropdownMenuItem<String>(
                                        value: null,
                                        child: Text(isAr ? '-- اختر اسم المورد --' : '-- Select Supplier --'),
                                      ),
                                      ...suppliersList.map(
                                        (s) => DropdownMenuItem(
                                          value: s.id,
                                          child: Text(s.name, overflow: TextOverflow.ellipsis),
                                        ),
                                      ),
                                    ],
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedSupplier = suppliersList.where((s) => s.id == val).firstOrNull;
                                        if (_items.isNotEmpty) _items.clear();
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Supplier Details Chips
                                Expanded(
                                  flex: 4,
                                  child: _selectedSupplier != null
                                      ? Wrap(
                                          spacing: 8,
                                          runSpacing: 6,
                                          children: [
                                            Chip(
                                              avatar: const Icon(Icons.category, size: 14),
                                              label: Text(_selectedSupplier!.category, style: const TextStyle(fontSize: 11)),
                                              backgroundColor: Colors.white,
                                              side: BorderSide(color: Colors.grey.shade300),
                                            ),
                                            Chip(
                                              avatar: const Icon(Icons.star, size: 14, color: Colors.amber),
                                              label: Text(_selectedSupplier!.supplierTier, style: const TextStyle(fontSize: 11)),
                                              backgroundColor: Colors.white,
                                              side: BorderSide(color: Colors.grey.shade300),
                                            ),
                                            if ((_selectedSupplier!.vatNumber ?? '').isNotEmpty)
                                              Chip(
                                                avatar: const Icon(Icons.receipt_outlined, size: 14),
                                                label: Text('VAT: ${_selectedSupplier!.vatNumber}', style: const TextStyle(fontSize: 11)),
                                                backgroundColor: Colors.white,
                                                side: BorderSide(color: Colors.grey.shade300),
                                              ),
                                          ],
                                        )
                                      : Text(
                                          isAr
                                              ? 'لم يتم تحديد مورد بعد. انقر على زر "دليل وبحث الموردين" لاختيار مورد.'
                                              : 'No supplier selected yet. Click "Supplier Modal" to pick a vendor.',
                                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                                        ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Section 2: Metadata Fields
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _debitNoteNumberController,
                              decoration: InputDecoration(
                                labelText: isAr ? 'رقم الإشعار المدين *' : 'Debit Note # *',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextFormField(
                              controller: _returnNumberController,
                              decoration: InputDecoration(
                                labelText: isAr ? 'رقم المرتجع (PRN) *' : 'Return Ref # *',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextFormField(
                              controller: _billRefController,
                              decoration: InputDecoration(
                                labelText: isAr ? 'رقم الفاتورة الأصلية / إشعار GRN' : 'Original Bill # / GRN Ref',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _overallReason,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: isAr ? 'سبب الإرجاع العام *' : 'General Reason *',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                isDense: true,
                              ),
                              items: [
                                DropdownMenuItem(value: 'DEFECTIVE', child: Text(isAr ? 'منتج معيب / Defective' : 'Defective Product')),
                                DropdownMenuItem(value: 'DAMAGED_GOODS', child: Text(isAr ? 'تالف في الشحن / Damaged' : 'Damaged Goods')),
                                DropdownMenuItem(value: 'WRONG_ITEM', child: Text(isAr ? 'صنف غير مطابق / Wrong Item' : 'Wrong Item Delivered')),
                                DropdownMenuItem(value: 'OVER_DELIVERY', child: Text(isAr ? 'كمية زائدة / Over Delivery' : 'Over Delivery')),
                                DropdownMenuItem(value: 'PRICE_DIFFERENCE', child: Text(isAr ? 'فروقات تسعير / Price Diff' : 'Pricing Discrepancy')),
                                DropdownMenuItem(value: 'QUALITY_REJECT', child: Text(isAr ? 'مرفوض بالفحص / QC Reject' : 'QC Inspection Rejected')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _overallReason = val;
                                    for (final item in _items) {
                                      item.reason = val;
                                    }
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Section 3: Line Items Section (Add from GRN & Manual)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.list_alt_rounded, color: Colors.blue.shade900, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  isAr ? 'بنود الإشعار المدين المرتجعة' : 'Debit Note Returned Line Items',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue.shade900),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade700,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${_items.length} ${isAr ? 'بنود' : 'Items'}',
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),

                            // Actions: Import from GRN + Add Manual
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF047857), // emerald green
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  icon: const Icon(Icons.playlist_add_check_rounded, size: 18),
                                  label: Text(
                                    isAr ? 'استيراد بنود من إشعار الاستلام (GRN)' : 'Add Items from GRN',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  onPressed: _openGrnItemPicker,
                                ),
                                const SizedBox(width: 10),
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  icon: const Icon(Icons.add, size: 16),
                                  label: Text(isAr ? 'إضافة بند يدوياً' : 'Add Manual Item', style: const TextStyle(fontSize: 12)),
                                  onPressed: _addManualItem,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Line Items Table / List
                      if (_items.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(32),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 44, color: Colors.grey.shade400),
                              const SizedBox(height: 10),
                              Text(
                                isAr
                                    ? 'لم تتم إضافة أي بنود بعد. انقر على "استيراد بنود من إشعار الاستلام (GRN)" لتحديد المنتجات المستلمة من هذا المورد.'
                                    : 'No items added yet. Click "Add Items from GRN" to pick products received from this vendor.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Table(
                            columnWidths: const {
                              0: FlexColumnWidth(0.5), // #
                              1: FlexColumnWidth(2.8), // Description
                              2: FlexColumnWidth(1.4), // GRN Ref
                              3: FlexColumnWidth(1.2), // Return Qty
                              4: FlexColumnWidth(1.2), // Unit Price
                              5: FlexColumnWidth(1.2), // Subtotal
                              6: FlexColumnWidth(1.2), // VAT 15%
                              7: FlexColumnWidth(1.4), // Total
                              8: FlexColumnWidth(1.8), // Reason
                              9: FlexColumnWidth(0.6), // Delete
                            },
                            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                            children: [
                              // Header
                              TableRow(
                                decoration: BoxDecoration(color: Colors.grey.shade100),
                                children: [
                                  _tableHeaderCell('#'),
                                  _tableHeaderCell(isAr ? 'الصنف / الوصف' : 'Description'),
                                  _tableHeaderCell(isAr ? 'إشعار GRN' : 'GRN Ref'),
                                  _tableHeaderCell(isAr ? 'الكمية' : 'Qty'),
                                  _tableHeaderCell(isAr ? 'السعر (ر.س)' : 'Price'),
                                  _tableHeaderCell(isAr ? 'المجموع' : 'Subtotal'),
                                  _tableHeaderCell(isAr ? 'ضريبة 15%' : 'VAT 15%'),
                                  _tableHeaderCell(isAr ? 'الإجمالي' : 'Total'),
                                  _tableHeaderCell(isAr ? 'سبب الإرجاع' : 'Reason'),
                                  _tableHeaderCell(''),
                                ],
                              ),

                              // Item Rows
                              ..._items.asMap().entries.map((entry) {
                                final idx = entry.key;
                                final item = entry.value;

                                return TableRow(
                                  decoration: BoxDecoration(
                                    color: idx.isOdd ? Colors.grey.shade50 : Colors.white,
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                      child: Center(child: Text('${idx + 1}', style: const TextStyle(fontWeight: FontWeight.bold))),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: TextField(
                                        controller: item.descriptionController,
                                        style: const TextStyle(fontSize: 12),
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: item.grnNumber != null ? Colors.blue.shade50 : Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          item.grnNumber ?? (isAr ? 'يدوي' : 'Manual'),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: item.grnNumber != null ? Colors.blue.shade900 : Colors.grey.shade700,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: TextField(
                                        controller: item.quantityController,
                                        keyboardType: TextInputType.number,
                                        style: const TextStyle(fontSize: 12),
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                        ),
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: TextField(
                                        controller: item.unitPriceController,
                                        keyboardType: TextInputType.number,
                                        style: const TextStyle(fontSize: 12),
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                        ),
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                                      child: Text(
                                        item.subtotal.toStringAsFixed(2),
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                                      child: Text(
                                        item.vatAmount.toStringAsFixed(2),
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                                      child: Text(
                                        item.totalAmount.toStringAsFixed(2),
                                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900, fontSize: 12),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: DropdownButton<String>(
                                        value: item.reason,
                                        isExpanded: true,
                                        underline: const SizedBox(),
                                        style: const TextStyle(fontSize: 11, color: Colors.black87),
                                        items: [
                                          DropdownMenuItem(value: 'DEFECTIVE', child: Text(isAr ? 'معيب' : 'Defective')),
                                          DropdownMenuItem(value: 'DAMAGED_GOODS', child: Text(isAr ? 'تالف' : 'Damaged')),
                                          DropdownMenuItem(value: 'WRONG_ITEM', child: Text(isAr ? 'غير مطابق' : 'Wrong Item')),
                                          DropdownMenuItem(value: 'OVER_DELIVERY', child: Text(isAr ? 'زائد' : 'Over Qty')),
                                        ],
                                        onChanged: (val) {
                                          if (val != null) setState(() => item.reason = val);
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                      onPressed: () {
                                        setState(() {
                                          item.dispose();
                                          _items.removeAt(idx);
                                        });
                                      },
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),

                      // Section 4: Totals & Summary Card
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Remarks
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _remarksController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                labelText: isAr ? 'ملاحظات الفحص وسبب إشعار الخصم' : 'Inspection Notes & Debit Justification',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),

                          // Calculation Box
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(isAr ? 'المجموع قبل الضريبة:' : 'Subtotal Excl. VAT:'),
                                      Text('SAR ${_grossSubtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(isAr ? 'ضريبة القيمة المضافة (15%):' : 'VAT Amount (15%):'),
                                      Text('SAR ${_totalVat.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  const Divider(height: 18),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        isAr ? 'إجمالي الإشعار المدين:' : 'Total Debit Note:',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      Text(
                                        'SAR ${_grandTotal.toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E3A8A)),
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

              // Footer Actions
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${isAr ? 'إجمالي البنود:' : 'Total Items:'} ${_items.length} | ${isAr ? 'قيمة الإشعار:' : 'Debit Value:'} SAR ${_grandTotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                          child: Text(isAr ? 'إلغاء' : 'Cancel'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: _isSubmitting
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.check_circle_rounded, size: 18),
                          label: Text(
                            isAr ? 'حفظ وإصدار الإشعار المدين' : 'Save & Issue Debit Note',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: _isSubmitting ? null : _submitDebitNote,
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
    );
  }

  Widget _tableHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey.shade800),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ==========================================
// GRN ITEM PICKER MODAL (FILTERED BY SUPPLIER)
// ==========================================
class _GrnItemPickerModal extends ConsumerStatefulWidget {
  final bool isArabic;
  final SupplierModel supplier;
  final ValueChanged<List<_DebitNoteItemDraft>> onItemsSelected;

  const _GrnItemPickerModal({
    required this.isArabic,
    required this.supplier,
    required this.onItemsSelected,
  });

  @override
  ConsumerState<_GrnItemPickerModal> createState() => _GrnItemPickerModalState();
}

class _GrnCandidateItem {
  final GoodsReceivedNoteModel grn;
  final GrnItemModel item;
  bool isSelected = true;
  late TextEditingController qtyController;
  String reason = 'DEFECTIVE';

  _GrnCandidateItem({
    required this.grn,
    required this.item,
  }) {
    qtyController = TextEditingController(text: item.receivedQuantity.toString());
  }

  double get quantity => double.tryParse(qtyController.text) ?? item.receivedQuantity;
}

class _GrnItemPickerModalState extends ConsumerState<_GrnItemPickerModal> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedGrnFilter = 'ALL';
  List<_GrnCandidateItem> _candidates = [];
  bool _isInitialized = false;

  @override
  void dispose() {
    _searchController.dispose();
    for (final c in _candidates) {
      c.qtyController.dispose();
    }
    super.dispose();
  }

  void _initializeCandidates(List<GoodsReceivedNoteModel> grns) {
    if (_isInitialized) return;

    // Filter GRNs by this supplier only
    final supplierGrns = grns.where((g) => g.supplierId == widget.supplier.id).toList();

    _candidates = [];
    for (final grn in supplierGrns) {
      for (final item in grn.items) {
        _candidates.add(_GrnCandidateItem(grn: grn, item: item));
      }
    }
    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isArabic;
    final grnsAsync = ref.watch(goodsReceivedNotesProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Container(
        width: 950,
        height: 680,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFFECFDF5), // light emerald
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(bottom: BorderSide(color: Color(0xFFA7F3D0))),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFF047857),
                    radius: 18,
                    child: Icon(Icons.playlist_add_check_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'استيراد بنود من إشعارات الاستلام (GRN)' : 'Import Items from Goods Received Notes (GRN)',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                        ),
                        Text(
                          isAr
                              ? 'عرض البنود والكميات المستلمة الخاصة بالمورد: ${widget.supplier.name}'
                              : 'Showing delivered items received from supplier: ${widget.supplier.name}',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
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

            // Toolbar: Search + Filter + Select All
            grnsAsync.when(
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
              data: (allGrns) {
                _initializeCandidates(allGrns);
                final uniqueGrnNumbers = _candidates.map((c) => c.grn.grnNumber).toSet().toList();

                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Search
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: isAr ? 'بحث بالصنف، رقم إشعار GRN أو أمر الشراء PO...' : 'Search by item, GRN #, or PO #...',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Filter by GRN
                      if (uniqueGrnNumbers.isNotEmpty) ...[
                        DropdownButton<String>(
                          value: _selectedGrnFilter,
                          items: [
                            DropdownMenuItem(value: 'ALL', child: Text(isAr ? 'كل إشعارات GRN' : 'All GRNs')),
                            ...uniqueGrnNumbers.map((g) => DropdownMenuItem(value: g, child: Text(g))),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedGrnFilter = val);
                          },
                        ),
                        const SizedBox(width: 10),
                      ],

                      // Toggle Select All
                      TextButton.icon(
                        icon: const Icon(Icons.select_all, size: 16),
                        label: Text(isAr ? 'تحديد الكل' : 'Select All'),
                        onPressed: () {
                          setState(() {
                            for (final c in _candidates) {
                              c.isSelected = true;
                            }
                          });
                        },
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.deselect, size: 16),
                        label: Text(isAr ? 'إلغاء التحديد' : 'Deselect All'),
                        onPressed: () {
                          setState(() {
                            for (final c in _candidates) {
                              c.isSelected = false;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),

            // Content Area
            Expanded(
              child: grnsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
                data: (allGrns) {
                  _initializeCandidates(allGrns);

                  final filtered = _candidates.where((c) {
                    final q = _searchQuery;
                    final matchSearch = q.isEmpty ||
                        c.item.description.toLowerCase().contains(q) ||
                        c.grn.grnNumber.toLowerCase().contains(q) ||
                        (c.grn.poNumber ?? '').toLowerCase().contains(q);

                    final matchGrn = _selectedGrnFilter == 'ALL' || c.grn.grnNumber == _selectedGrnFilter;

                    return matchSearch && matchGrn;
                  }).toList();

                  if (_candidates.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            isAr
                                ? 'لا توجد إشعارات استلام (GRN) مسجلة لهذا المورد (${widget.supplier.name})'
                                : 'No Goods Received Notes (GRN) found for supplier (${widget.supplier.name})',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  }

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(isAr ? 'لا توجد بنود تطابق شروط البحث' : 'No items match your filter criteria'),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, idx) {
                      final candidate = filtered[idx];
                      final item = candidate.item;
                      final grn = candidate.grn;

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: candidate.isSelected ? const Color(0xFFF0FDF4) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: candidate.isSelected ? const Color(0xFF10B981) : Colors.grey.shade300,
                            width: candidate.isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: candidate.isSelected,
                              activeColor: const Color(0xFF047857),
                              onChanged: (val) {
                                setState(() => candidate.isSelected = val ?? false);
                              },
                            ),
                            const SizedBox(width: 8),

                            // Item details
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.description,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: Colors.blue.shade200),
                                        ),
                                        child: Text(
                                          'GRN: ${grn.grnNumber}',
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                                        ),
                                      ),
                                      if (grn.poNumber != null) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.indigo.shade50,
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: Colors.indigo.shade200),
                                          ),
                                          child: Text(
                                            'PO: ${grn.poNumber}',
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.indigo.shade900),
                                          ),
                                        ),
                                      ],
                                      const SizedBox(width: 10),
                                      Text(
                                        '${isAr ? 'الكمية المستلمة:' : 'Received Qty:'} ${item.receivedQuantity}',
                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'SAR ${item.unitPrice.toStringAsFixed(2)} / unit',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Quantity to return input
                            SizedBox(
                              width: 130,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isAr ? 'كمية الإرجاع:' : 'Return Qty:',
                                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                  ),
                                  const SizedBox(height: 2),
                                  TextField(
                                    controller: candidate.qtyController,
                                    keyboardType: TextInputType.number,
                                    enabled: candidate.isSelected,
                                    style: const TextStyle(fontSize: 12),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Reason dropdown
                            SizedBox(
                              width: 150,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isAr ? 'سبب الإرجاع:' : 'Return Reason:',
                                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                  ),
                                  const SizedBox(height: 2),
                                  DropdownButton<String>(
                                    value: candidate.reason,
                                    isExpanded: true,
                                    style: const TextStyle(fontSize: 11, color: Colors.black87),
                                    items: [
                                      DropdownMenuItem(value: 'DEFECTIVE', child: Text(isAr ? 'معيب' : 'Defective')),
                                      DropdownMenuItem(value: 'DAMAGED_GOODS', child: Text(isAr ? 'تالف' : 'Damaged')),
                                      DropdownMenuItem(value: 'WRONG_ITEM', child: Text(isAr ? 'غير مطابق' : 'Wrong Item')),
                                      DropdownMenuItem(value: 'OVER_DELIVERY', child: Text(isAr ? 'زائد' : 'Over Qty')),
                                    ],
                                    onChanged: candidate.isSelected
                                        ? (val) {
                                            if (val != null) setState(() => candidate.reason = val);
                                          }
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Modal Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${isAr ? 'البنود المحددة:' : 'Selected:'} ${_candidates.where((c) => c.isSelected).length} / ${_candidates.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(isAr ? 'إلغاء' : 'Cancel'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF047857),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.check, size: 18),
                        label: Text(
                          isAr ? 'استيراد البنود المحددة' : 'Import Selected Items',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          final selected = _candidates.where((c) => c.isSelected).map((c) {
                            return _DebitNoteItemDraft(
                              productId: c.item.productId,
                              grnNumber: c.grn.grnNumber,
                              poNumber: c.grn.poNumber,
                              description: '${c.item.description} (GRN: ${c.grn.grnNumber})',
                              quantity: c.quantity > 0 ? c.quantity : c.item.receivedQuantity,
                              unitPrice: c.item.unitPrice,
                              reason: c.reason,
                            );
                          }).toList();

                          if (selected.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isAr ? 'يرجى تحديد بند واحد على الأقل' : 'Please select at least one item'),
                              ),
                            );
                            return;
                          }

                          widget.onItemsSelected(selected);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
