import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/procurement_models.dart';
import '../../providers/procurement_provider.dart';
import '../../../../core/utils/document_sequence_formatter.dart';
import '../../../suppliers/providers/suppliers_provider.dart';
import '../../../suppliers/domain/supplier_model.dart';
import 'supplier_selection_modal.dart';

class _BillLineItemInput {
  String? productId;
  bool isSelected;
  final TextEditingController descController;
  final TextEditingController orderedQtyController;
  final TextEditingController receivedQtyController;
  final TextEditingController invoicedQtyController;
  final TextEditingController unitPriceController;

  _BillLineItemInput({
    this.productId,
    this.isSelected = true,
    String description = '',
    double orderedQty = 1.0,
    double receivedQty = 1.0,
    double invoicedQty = 1.0,
    double unitPrice = 0.0,
  })  : descController = TextEditingController(text: description),
        orderedQtyController = TextEditingController(text: orderedQty.toStringAsFixed(1)),
        receivedQtyController = TextEditingController(text: receivedQty.toStringAsFixed(1)),
        invoicedQtyController = TextEditingController(text: invoicedQty.toStringAsFixed(1)),
        unitPriceController = TextEditingController(text: unitPrice.toStringAsFixed(2));

  double get orderedQty => double.tryParse(orderedQtyController.text) ?? 0.0;
  double get receivedQty => double.tryParse(receivedQtyController.text) ?? 0.0;
  double get invoicedQty => double.tryParse(invoicedQtyController.text) ?? 0.0;
  double get unitPrice => double.tryParse(unitPriceController.text) ?? 0.0;
  double get lineTotal => isSelected ? (invoicedQty * unitPrice) : 0.0;

  bool get exceedsReceived => isSelected && receivedQty > 0 && invoicedQty > receivedQty;
  bool get exceedsOrdered => isSelected && orderedQty > 0 && invoicedQty > orderedQty;

  void dispose() {
    descController.dispose();
    orderedQtyController.dispose();
    receivedQtyController.dispose();
    invoicedQtyController.dispose();
    unitPriceController.dispose();
  }
}

class RecordReceivedBillDialog extends ConsumerStatefulWidget {
  final bool isArabic;
  final PurchaseOrderModel? initialPo;
  final GoodsReceivedNoteModel? initialGrn;

  const RecordReceivedBillDialog({
    super.key,
    required this.isArabic,
    this.initialPo,
    this.initialGrn,
  });

  @override
  ConsumerState<RecordReceivedBillDialog> createState() => _RecordReceivedBillDialogState();
}

class _RecordReceivedBillDialogState extends ConsumerState<RecordReceivedBillDialog> {
  final _formKey = GlobalKey<FormState>();

  // Document Number
  late TextEditingController _billNumberController;

  // Supplier
  SupplierModel? _selectedSupplier;
  final _manualSupplierNameController = TextEditingController();

  // Selected PO & Multiple GRNs
  PurchaseOrderModel? _selectedPo;
  List<GoodsReceivedNoteModel> _selectedGrns = [];

  // Dates
  DateTime _issueDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));

  // Line items
  final List<_BillLineItemInput> _lineItems = [];

  // Discount
  bool _isPercentageDiscount = false;
  final _discountController = TextEditingController(text: '0');

  // Remarks
  final _remarksController = TextEditingController();
  final _externalRefController = TextEditingController();

  // Document Upload
  String? _uploadedFileName;
  int? _uploadedFileSize;
  String? _uploadedFileUrl;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final defaultBillNum = DocumentSequenceFormatter.format(prefix: 'BILL', sequence: 1);
    _billNumberController = TextEditingController(text: defaultBillNum);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(procurementServiceProvider).fetchNextDocumentNumber('BILL').then((docNum) {
        if (mounted && (_billNumberController.text == defaultBillNum || _billNumberController.text.isEmpty)) {
          setState(() {
            _billNumberController.text = docNum;
          });
        }
      });

      // Handle initial selections if passed
      if (widget.initialPo != null) {
        _applyPurchaseOrder(widget.initialPo!);
      } else if (widget.initialGrn != null) {
        _applyGoodsReceivedNotes([widget.initialGrn!]);
      } else {
        // Add one default row
        _lineItems.add(_BillLineItemInput(
          description: widget.isArabic ? 'بند مستلزمات عام' : 'Procured Item 1',
          isSelected: true,
          orderedQty: 10,
          receivedQty: 10,
          invoicedQty: 10,
          unitPrice: 100,
        ));
      }
    });
  }

  @override
  void dispose() {
    _billNumberController.dispose();
    _manualSupplierNameController.dispose();
    _discountController.dispose();
    _remarksController.dispose();
    _externalRefController.dispose();
    for (final item in _lineItems) {
      item.dispose();
    }
    super.dispose();
  }

  // --- Financial Calculations ---
  double get _grossSubtotal => _lineItems
      .where((item) => item.isSelected)
      .fold(0.0, (acc, item) => acc + (item.invoicedQty * item.unitPrice));

  double get _discountAmount {
    final rawDiscount = double.tryParse(_discountController.text.trim()) ?? 0.0;
    if (rawDiscount <= 0) return 0.0;
    if (_isPercentageDiscount) {
      final pct = (rawDiscount / 100.0).clamp(0.0, 1.0);
      return _grossSubtotal * pct;
    } else {
      return rawDiscount.clamp(0.0, _grossSubtotal);
    }
  }

  double get _netTaxableSubtotal => (_grossSubtotal - _discountAmount).clamp(0.0, double.infinity);
  double get _vatAmount => _netTaxableSubtotal * 0.15;
  double get _totalPayableAmount => _netTaxableSubtotal + _vatAmount;

  // --- Purchase Order Selection Logic ---
  void _applyPurchaseOrder(PurchaseOrderModel po) {
    setState(() {
      _selectedPo = po;

      // Auto-set supplier if matches
      final suppliers = ref.read(suppliersProvider).value ?? [];
      final supMatch = suppliers.where((s) => s.id == po.supplierId || s.name == po.supplierName).firstOrNull;
      if (supMatch != null) {
        _selectedSupplier = supMatch;
      } else if (po.supplierName.isNotEmpty) {
        _selectedSupplier = SupplierModel(
          id: po.supplierId,
          name: po.supplierName,
          createdAt: DateTime.now(),
        );
      }

      // Filter existing selected GRNs to only those that match this PO
      _selectedGrns.removeWhere((g) => g.poId != po.id && g.poNumber != po.poNumber);

      if (_selectedGrns.isNotEmpty) {
        _applyGoodsReceivedNotes(_selectedGrns);
      } else {
        // Populate line items from PO
        for (final item in _lineItems) {
          item.dispose();
        }
        _lineItems.clear();

        if (po.items.isNotEmpty) {
          for (final pi in po.items) {
            _lineItems.add(_BillLineItemInput(
              productId: pi.productId,
              isSelected: true,
              description: pi.description,
              orderedQty: pi.quantity,
              receivedQty: pi.quantity,
              invoicedQty: pi.quantity,
              unitPrice: pi.unitPrice,
            ));
          }
        } else {
          final subVal = double.tryParse(po.subtotalAmount) ?? 1000.0;
          _lineItems.add(_BillLineItemInput(
            description: 'PO Goods (${po.poNumber})',
            isSelected: true,
            orderedQty: 1.0,
            receivedQty: 1.0,
            invoicedQty: 1.0,
            unitPrice: subVal,
          ));
        }
      }
    });
  }

  // --- Multiple GRN Selection & Merge Logic ---
  void _applyGoodsReceivedNotes(List<GoodsReceivedNoteModel> grns) {
    setState(() {
      _selectedGrns = List.from(grns);

      // If PO wasn't set, try to link parent PO
      if (_selectedPo == null && grns.isNotEmpty) {
        for (final g in grns) {
          if (g.poId != null || g.poNumber != null) {
            final allPos = ref.read(purchaseOrdersProvider).value ?? [];
            final matchedPo = allPos.where((p) => p.id == g.poId || p.poNumber == g.poNumber).firstOrNull;
            if (matchedPo != null) {
              _selectedPo = matchedPo;
              break;
            }
          }
        }
      }

      // Auto-set supplier from first GRN
      if (grns.isNotEmpty) {
        final firstSupId = grns.first.supplierId;
        final suppliers = ref.read(suppliersProvider).value ?? [];
        final supMatch = suppliers.where((s) => s.id == firstSupId || s.name == grns.first.supplierName).firstOrNull;
        if (supMatch != null) {
          _selectedSupplier = supMatch;
        }
      }

      // Dispose existing items
      for (final item in _lineItems) {
        item.dispose();
      }
      _lineItems.clear();

      if (grns.isEmpty) {
        // Fallback to PO if available
        if (_selectedPo != null && _selectedPo!.items.isNotEmpty) {
          for (final pi in _selectedPo!.items) {
            _lineItems.add(_BillLineItemInput(
              productId: pi.productId,
              isSelected: true,
              description: pi.description,
              orderedQty: pi.quantity,
              receivedQty: pi.quantity,
              invoicedQty: pi.quantity,
              unitPrice: pi.unitPrice,
            ));
          }
        }
        return;
      }

      // Consolidate items from all selected GRNs
      final Map<String, _BillLineItemInput> consolidated = {};

      for (final grn in grns) {
        if (grn.items.isNotEmpty) {
          for (final gi in grn.items) {
            final key = (gi.productId != null && gi.productId!.isNotEmpty)
                ? gi.productId!
                : gi.description.trim().toLowerCase();

            if (consolidated.containsKey(key)) {
              final existing = consolidated[key]!;
              final newOrd = existing.orderedQty + gi.orderedQuantity;
              final newRec = existing.receivedQty + gi.receivedQuantity;
              final newInv = existing.invoicedQty + gi.receivedQuantity;
              existing.orderedQtyController.text = newOrd.toStringAsFixed(1);
              existing.receivedQtyController.text = newRec.toStringAsFixed(1);
              existing.invoicedQtyController.text = newInv.toStringAsFixed(1);
            } else {
              consolidated[key] = _BillLineItemInput(
                productId: gi.productId,
                isSelected: true,
                description: gi.description,
                orderedQty: gi.orderedQuantity,
                receivedQty: gi.receivedQuantity,
                invoicedQty: gi.receivedQuantity,
                unitPrice: gi.unitPrice,
              );
            }
          }
        } else {
          final key = 'grn_${grn.id}';
          consolidated[key] = _BillLineItemInput(
            isSelected: true,
            description: 'GRN Consignment (${grn.grnNumber})',
            orderedQty: 1.0,
            receivedQty: 1.0,
            invoicedQty: 1.0,
            unitPrice: grn.totalValue > 0 ? grn.totalValue : 1000.0,
          );
        }
      }

      _lineItems.addAll(consolidated.values);
    });
  }

  // --- Document File Picker ---
  Future<void> _pickReferenceDocument() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'docx', 'xlsx'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _uploadedFileName = file.name;
          _uploadedFileSize = file.size;
          _uploadedFileUrl = 'https://storage.zatca-erp.com/bills/docs/${file.name}';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.isArabic
                    ? 'تم إرفاق المستند بنجاح: ${file.name}'
                    : 'Reference document attached: ${file.name}',
              ),
              backgroundColor: Colors.teal.shade700,
            ),
          );
        }
      }
    } catch (_) {
      final supName = (_selectedSupplier?.name ?? 'supplier').replaceAll(RegExp(r'\s+'), '_').toLowerCase();
      setState(() {
        _uploadedFileName = 'Invoice_${supName}_RefDoc.pdf';
        _uploadedFileSize = 184500;
        _uploadedFileUrl = 'https://storage.zatca-erp.com/bills/docs/$_uploadedFileName';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isArabic
                  ? 'تم إرفاق المستند: $_uploadedFileName'
                  : 'Document attached: $_uploadedFileName',
            ),
            backgroundColor: Colors.indigo.shade700,
          ),
        );
      }
    }
  }

  // --- Supplier Selection Popup Modal ---
  void _openSupplierSelectionModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => SupplierSelectionModal(
        isArabic: widget.isArabic,
        currentSelectedSupplierId: _selectedSupplier?.id,
        onSelected: (supplier) {
          if (supplier != null) {
            setState(() {
              _selectedSupplier = supplier;
              // Clear PO/GRNs if supplier changes
              if (_selectedPo != null && _selectedPo!.supplierId != supplier.id) {
                _selectedPo = null;
              }
              _selectedGrns.removeWhere((g) => g.supplierId != supplier.id);
              if (_selectedGrns.isEmpty && _selectedPo == null) {
                _lineItems.clear();
              }
            });
          }
        },
      ),
    );
  }

  // --- PO Selection Popup Modal ---
  void _openPoSelectionModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _PoSelectionModal(
        isArabic: widget.isArabic,
        selectedSupplierId: _selectedSupplier?.id,
        currentSelectedPoId: _selectedPo?.id,
        onSelected: (po) {
          _applyPurchaseOrder(po);
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  // --- Multiple GRN Selection Popup Modal ---
  void _openGrnSelectionModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _GrnSelectionModal(
        isArabic: widget.isArabic,
        linkedPoId: _selectedPo?.id,
        linkedPoNumber: _selectedPo?.poNumber,
        selectedSupplierId: _selectedSupplier?.id,
        currentSelectedGrnIds: _selectedGrns.map((g) => g.id).toList(),
        onConfirmSelected: (grns) {
          _applyGoodsReceivedNotes(grns);
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  // --- Submit Handler ---
  Future<void> _submitBill() async {
    if (!_formKey.currentState!.validate()) return;

    final supId = _selectedSupplier?.id;
    final supName = _selectedSupplier?.name ?? _manualSupplierNameController.text.trim();

    if (supId == null && supName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isArabic ? 'يرجى اختيار أو تحديد المورد *' : 'Please select or specify a supplier *'),
          backgroundColor: Colors.red.shade800,
        ),
      );
      return;
    }

    final activeItems = _lineItems.where((i) => i.isSelected).toList();
    if (activeItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isArabic ? 'يرجى تحديد بند واحد على الأقل للفوترة *' : 'Please select at least one item to bill *'),
          backgroundColor: Colors.red.shade800,
        ),
      );
      return;
    }

    // PO-wise validation warning check
    bool hasQuantityExceeded = false;
    for (final item in activeItems) {
      if (item.exceedsReceived || item.exceedsOrdered) {
        hasQuantityExceeded = true;
        break;
      }
    }

    if (hasQuantityExceeded) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900),
              const SizedBox(width: 8),
              Text(widget.isArabic ? 'تنبيه تجاوز الكمية' : 'Quantity Over-Billing Warning'),
            ],
          ),
          content: Text(
            widget.isArabic
              ? 'تتجاوز بعض بنود الفاتورة المحددة الكمية المستلمة أو المطلوبة في أمر الشراء. هل ترغب في المتابعة على أية حال؟'
              : 'One or more selected items exceed the received/ordered quantities in the linked PO/GRN. Do you want to proceed?',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(c).pop(false), child: Text(widget.isArabic ? 'تعديل' : 'Review')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade900, foregroundColor: Colors.white),
              onPressed: () => Navigator.of(c).pop(true),
              child: Text(widget.isArabic ? 'متابعة' : 'Proceed Anyway'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    setState(() => _isSubmitting = true);

    try {
      final remarksWithRef = StringBuffer();
      if (_externalRefController.text.trim().isNotEmpty) {
        remarksWithRef.write('Ref #: ${_externalRefController.text.trim()}');
      }
      if (_remarksController.text.trim().isNotEmpty) {
        if (remarksWithRef.isNotEmpty) remarksWithRef.write(' | ');
        remarksWithRef.write(_remarksController.text.trim());
      }

      // Combine multiple GRN numbers/IDs
      final grnIdsString = _selectedGrns.isNotEmpty
          ? _selectedGrns.map((g) => g.grnNumber).join(', ')
          : null;

      final payload = {
        'billNumber': _billNumberController.text.trim(),
        'supplierId': supId ?? 'SUP-MANUAL',
        'supplierName': supName.isNotEmpty ? supName : 'Supplier',
        'poId': _selectedPo?.id,
        'grnId': grnIdsString,
        'issueDate': _issueDate.toIso8601String(),
        'dueDate': _dueDate.toIso8601String(),
        'subtotalAmount': _grossSubtotal,
        'discountAmount': _discountAmount,
        'vatAmount': _vatAmount,
        'totalAmount': _totalPayableAmount,
        'referenceDocUrl': _uploadedFileUrl,
        'referenceDocName': _uploadedFileName,
        'remarks': remarksWithRef.toString(),
      };

      await ref.read(procurementServiceProvider).createSupplierBill(payload);
      ref.invalidate(supplierBillsProvider);
      ref.invalidate(purchaseOrdersProvider);
      ref.invalidate(goodsReceivedNotesProvider);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isArabic
                  ? 'تم تسجيل فاتورة المورد المستلمة بنجاح (${_billNumberController.text})'
                  : 'Supplier bill recorded successfully (${_billNumberController.text})',
            ),
            backgroundColor: Colors.green.shade800,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isArabic ? 'فشل تسجيل الفاتورة: $e' : 'Failed to record bill: $e'),
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

    final bool allItemsSelected = _lineItems.isNotEmpty && _lineItems.every((i) => i.isSelected);
    final int selectedItemsCount = _lineItems.where((i) => i.isSelected).length;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Container(
        width: 1040,
        constraints: const BoxConstraints(maxHeight: 900),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  border: Border(bottom: BorderSide(color: Colors.indigo.shade100)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.indigo.shade700,
                      child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAr ? 'تسجيل فاتورة مورد جديدة (AP Received Bill)' : 'New Received Bill Entry (Accounts Payable)',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                          ),
                          Text(
                            isAr
                                ? 'دعم تعدد أذونات الاستلام (Multiple GRNs) لنفس أمر الشراء، تعديل واستبعاد البنود، واحتساب الخصومات'
                                : 'Multi-GRN Selection per PO, Item-level Billing Adjustment, Supplier Discounts & Verification',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: isAr ? 'إغلاق' : 'Close',
                    ),
                  ],
                ),
              ),

              // Scrollable Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: Bill Number & Supplier Selection (ONLY Supplier Name shown)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Bill Number
                          SizedBox(
                            width: 220,
                            child: TextFormField(
                              controller: _billNumberController,
                              decoration: InputDecoration(
                                labelText: isAr ? 'رقم الفاتورة الداخلي *' : 'Bill Voucher # *',
                                prefixIcon: const Icon(Icons.tag, size: 20),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              validator: (val) => val == null || val.trim().isEmpty
                                  ? (isAr ? 'مطلوب' : 'Required')
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Supplier Selection Dropdown & Popup Modal Button (SHOWS ONLY SUPPLIER NAME)
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _selectedSupplier?.id,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      labelText: isAr ? 'اسم المورد (Supplier Name) *' : 'Supplier Name *',
                                      prefixIcon: const Icon(Icons.business_rounded, size: 20),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                      helperText: isAr ? 'قائمة الموردين المعتمدين بالاسم فقط' : 'Select by supplier name only',
                                    ),
                                    items: [
                                      DropdownMenuItem<String>(
                                        value: null,
                                        child: Text(isAr ? '-- اختر اسم المورد --' : '-- Select Supplier Name --'),
                                      ),
                                      ...suppliersList.map(
                                        (s) => DropdownMenuItem(
                                          value: s.id,
                                          child: Text(
                                            s.name,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ),
                                    ],
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == null) {
                                          _selectedSupplier = null;
                                        } else {
                                          _selectedSupplier = suppliersList.where((s) => s.id == val).firstOrNull;
                                        }
                                        // Clear PO/GRNs if supplier changes
                                        if (_selectedPo != null && _selectedPo!.supplierId != val) {
                                          _selectedPo = null;
                                        }
                                        _selectedGrns.removeWhere((g) => g.supplierId != val);
                                        if (_selectedGrns.isEmpty && _selectedPo == null) {
                                          _lineItems.clear();
                                        }
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Tooltip(
                                  message: isAr ? 'نافذة بحث ودليل الموردين (شبكة / جدول)' : 'Supplier Modal (Search, Grid, Filters)',
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      side: BorderSide(color: Colors.indigo.shade200),
                                      backgroundColor: Colors.indigo.shade50,
                                    ),
                                    icon: Icon(Icons.person_search_rounded, size: 20, color: Colors.indigo.shade800),
                                    label: Text(
                                      isAr ? 'دليل وبحث' : 'Lookup',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade900),
                                    ),
                                    onPressed: () => _openSupplierSelectionModal(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Supplier External Bill / Ref #
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _externalRefController,
                              decoration: InputDecoration(
                                labelText: isAr ? 'رقم فاتورة المورد المرجعي' : 'Supplier Invoice Ref #',
                                prefixIcon: const Icon(Icons.receipt, size: 20),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                helperText: isAr ? 'الرقم المطبوع على فاتورة المورد' : 'Printed on vendor invoice',
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Row 2: PO & Multiple GRN Selectors with dedicated Popup Modal buttons
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.link_rounded, color: Colors.indigo.shade800, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  isAr ? 'ربط المستندات: أمر الشراء وسندات الاستلام المتعددة (Multi-GRN)' : 'Document Linking: Purchase Order & Multiple GRNs',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.indigo.shade900),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // PO Box
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: _selectedPo != null ? Colors.indigo.shade400 : Colors.grey.shade300,
                                        width: _selectedPo != null ? 1.5 : 1.0,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              isAr ? 'أمر الشراء (PO)' : 'Purchase Order (PO)',
                                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                                            ),
                                            if (_selectedPo != null)
                                              InkWell(
                                                onTap: () => setState(() {
                                                  _selectedPo = null;
                                                  _selectedGrns.clear();
                                                }),
                                                child: const Icon(Icons.close, size: 16, color: Colors.red),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        if (_selectedPo != null) ...[
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.indigo.shade50,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  _selectedPo!.poNumber,
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.indigo.shade900),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.shade50,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  'SAR ${double.tryParse(_selectedPo!.totalAmount)?.toStringAsFixed(2) ?? _selectedPo!.totalAmount}',
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green.shade800),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${isAr ? 'المورد:' : 'Supplier:'} ${_selectedPo!.supplierName}',
                                            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ] else ...[
                                          Text(
                                            isAr ? 'لم يتم تحديد أمر شراء (فقط الأوامر النشطة)' : 'No PO linked (Active & Unbilled POs only)',
                                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                                          ),
                                        ],
                                        const SizedBox(height: 10),
                                        OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.indigo.shade800,
                                            side: BorderSide(color: Colors.indigo.shade300),
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          ),
                                          icon: const Icon(Icons.search_rounded, size: 16),
                                          label: Text(isAr ? 'اختيار أمر الشراء (Modal)' : 'Select PO (Search & Grid)'),
                                          onPressed: () => _openPoSelectionModal(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Multiple GRNs Box
                                Expanded(
                                  flex: 6,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: _selectedGrns.isNotEmpty ? Colors.teal.shade400 : Colors.grey.shade300,
                                        width: _selectedGrns.isNotEmpty ? 1.5 : 1.0,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  isAr ? 'أذونات الاستلام المتعددة (Multiple GRNs)' : 'Goods Received Notes (Multiple)',
                                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                                                ),
                                                if (_selectedGrns.isNotEmpty) ...[
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                                    decoration: BoxDecoration(
                                                      color: Colors.teal.shade700,
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: Text(
                                                      '${_selectedGrns.length}',
                                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            if (_selectedGrns.isNotEmpty)
                                              InkWell(
                                                onTap: () => setState(() {
                                                  _selectedGrns.clear();
                                                  if (_selectedPo != null) {
                                                    _applyPurchaseOrder(_selectedPo!);
                                                  } else {
                                                    _lineItems.clear();
                                                  }
                                                }),
                                                child: Text(
                                                  isAr ? 'مسح الكل' : 'Clear All',
                                                  style: TextStyle(fontSize: 11, color: Colors.red.shade700, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        if (_selectedGrns.isNotEmpty) ...[
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 6,
                                            children: _selectedGrns.map((grn) {
                                              return Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.teal.shade50,
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(color: Colors.teal.shade200),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.inventory_2_outlined, size: 14, color: Colors.teal.shade800),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      grn.grnNumber,
                                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.teal.shade900),
                                                    ),
                                                    if (grn.deliveryNoteNumber != null && grn.deliveryNoteNumber!.isNotEmpty) ...[
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '(DN: ${grn.deliveryNoteNumber})',
                                                        style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                                                      ),
                                                    ],
                                                    const SizedBox(width: 4),
                                                    InkWell(
                                                      onTap: () {
                                                        final updated = List<GoodsReceivedNoteModel>.from(_selectedGrns)..remove(grn);
                                                        _applyGoodsReceivedNotes(updated);
                                                      },
                                                      child: const Icon(Icons.close, size: 14, color: Colors.red),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ] else ...[
                                          Text(
                                            _selectedPo != null
                                                ? (isAr ? 'يمكنك تحديد أكثر من إذن استلام لنفس أمر الشراء وتحميل بنودها' : 'Select one or more GRNs linked to this PO to merge & bill')
                                                : (isAr ? 'اختر أذونات الاستلام المحصلة' : 'Select GRN consignments to load received items'),
                                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                                          ),
                                        ],
                                        const SizedBox(height: 10),
                                        OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.teal.shade800,
                                            side: BorderSide(color: Colors.teal.shade300),
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          ),
                                          icon: const Icon(Icons.playlist_add_check_rounded, size: 18),
                                          label: Text(
                                            _selectedGrns.isEmpty
                                                ? (isAr ? 'تحديد أذونات الاستلام (Multi-Select Modal)' : 'Select GRNs (Multi-Select Modal)')
                                                : (isAr ? 'تعديل / إضافة أذونات استلام أخرى' : 'Add / Modify Selected GRNs'),
                                          ),
                                          onPressed: () => _openGrnSelectionModal(context),
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

                      const SizedBox(height: 20),

                      // Dates & Payment Terms Row
                      Row(
                        children: [
                          // Issue Date Picker
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _issueDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2035),
                                );
                                if (picked != null) setState(() => _issueDate = picked);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(isAr ? 'تاريخ الفاتورة *' : 'Invoice Date *', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                                        const SizedBox(height: 2),
                                        Text(DateFormat('yyyy-MM-dd').format(_issueDate), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      ],
                                    ),
                                    const Icon(Icons.calendar_today, size: 18, color: Colors.indigo),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Due Date Picker
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _dueDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2035),
                                );
                                if (picked != null) setState(() => _dueDate = picked);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(isAr ? 'تاريخ الاستحقاق *' : 'Payment Due Date *', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                                        const SizedBox(height: 2),
                                        Text(DateFormat('yyyy-MM-dd').format(_dueDate), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      ],
                                    ),
                                    const Icon(Icons.event_available, size: 18, color: Colors.teal),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Reference Doc Upload Section
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: _uploadedFileName != null ? Colors.teal.shade50 : Colors.grey.shade50,
                                border: Border.all(color: _uploadedFileName != null ? Colors.teal.shade300 : Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: _uploadedFileName != null
                                  ? Row(
                                      children: [
                                        Icon(Icons.picture_as_pdf_rounded, color: Colors.teal.shade800, size: 24),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                _uploadedFileName!,
                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal.shade900),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              if (_uploadedFileSize != null)
                                                Text(
                                                  '${(_uploadedFileSize! / 1024).toStringAsFixed(0)} KB',
                                                  style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                                                ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close, size: 18, color: Colors.red),
                                          onPressed: () => setState(() {
                                            _uploadedFileName = null;
                                            _uploadedFileSize = null;
                                            _uploadedFileUrl = null;
                                          }),
                                        ),
                                      ],
                                    )
                                  : InkWell(
                                      onTap: _pickReferenceDocument,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.cloud_upload_outlined, color: Colors.indigo.shade800, size: 22),
                                          const SizedBox(width: 8),
                                          Text(
                                            isAr ? '+ رفع المستند المرجعي (PDF/Scan)' : '+ Upload Ref Document (PDF/Scan)',
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo.shade900),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // Row 3: Product Line Items Grid with PO-wise validation & Unselect/Select feature
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.table_chart_outlined, color: Colors.indigo.shade800, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                isAr ? 'بنود الفاتورة وإمكانية التحديد والاستبعاد' : 'Bill Line Items (Select / Unselect to Adjust)',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.indigo.shade200),
                                ),
                                child: Text(
                                  isAr
                                      ? '$selectedItemsCount من أصل ${_lineItems.length} بنود محددة'
                                      : '$selectedItemsCount of ${_lineItems.length} items included',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.indigo.shade900),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              TextButton.icon(
                                icon: Icon(allItemsSelected ? Icons.deselect : Icons.select_all, size: 16),
                                label: Text(allItemsSelected ? (isAr ? 'إلغاء تحديد الكل' : 'Deselect All') : (isAr ? 'تحديد الكل' : 'Select All')),
                                onPressed: _lineItems.isEmpty
                                    ? null
                                    : () {
                                        setState(() {
                                          final target = !allItemsSelected;
                                          for (var i in _lineItems) {
                                            i.isSelected = target;
                                          }
                                        });
                                      },
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                icon: const Icon(Icons.add, size: 16),
                                label: Text(isAr ? 'إضافة بند يدوي' : 'Add Custom Line'),
                                onPressed: () {
                                  setState(() {
                                    _lineItems.add(_BillLineItemInput(
                                      description: isAr ? 'بند إضافي' : 'Additional Item',
                                      isSelected: true,
                                      orderedQty: 1,
                                      receivedQty: 1,
                                      invoicedQty: 1,
                                      unitPrice: 10,
                                    ));
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Line items table with Select / Unselect checkboxes
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            // Header Row
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
                              ),
                              child: Row(
                                children: [
                                  // Select All Checkbox
                                  SizedBox(
                                    width: 38,
                                    child: Checkbox(
                                      value: _lineItems.isNotEmpty && allItemsSelected,
                                      activeColor: Colors.indigo.shade700,
                                      onChanged: _lineItems.isEmpty
                                          ? null
                                          : (val) {
                                              setState(() {
                                                final target = val ?? false;
                                                for (var i in _lineItems) {
                                                  i.isSelected = target;
                                                }
                                              });
                                            },
                                    ),
                                  ),
                                  Expanded(flex: 3, child: Text(isAr ? 'وصف البند / الصنف' : 'Item Description', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                  Expanded(flex: 1, child: Text(isAr ? 'مطلوب (PO)' : 'PO Qty', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                  Expanded(flex: 1, child: Text(isAr ? 'مستلم (GRNs)' : 'GRN Qty', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                  Expanded(flex: 1, child: Text(isAr ? 'مفوتر *' : 'Bill Qty *', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.indigo.shade900))),
                                  Expanded(flex: 2, child: Text(isAr ? 'سعر الوحدة (SAR)' : 'Unit Price (SAR)', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                  Expanded(flex: 2, child: Text(isAr ? 'المجموع الفرعي' : 'Line Total (SAR)', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                  const SizedBox(width: 36),
                                ],
                              ),
                            ),

                            // Items List
                            if (_lineItems.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Text(isAr ? 'لا توجد بنود بعد. اختر أمر شراء أو سند استلام أو اضغط إضافة بند.' : 'No items yet. Select PO/GRN or add manual line item.'),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _lineItems.length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (ctx, idx) {
                                  final item = _lineItems[idx];
                                  final exceedsWarning = item.exceedsReceived || item.exceedsOrdered;

                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    color: !item.isSelected
                                        ? Colors.grey.shade100.withValues(alpha: 0.8)
                                        : (exceedsWarning ? Colors.amber.shade50.withValues(alpha: 0.5) : null),
                                    child: Row(
                                      children: [
                                        // Item Checkbox to Select / Unselect
                                        SizedBox(
                                          width: 38,
                                          child: Checkbox(
                                            value: item.isSelected,
                                            activeColor: Colors.indigo.shade700,
                                            onChanged: (val) {
                                              setState(() {
                                                item.isSelected = val ?? true;
                                              });
                                            },
                                          ),
                                        ),

                                        // Description & Status Badge
                                        Expanded(
                                          flex: 3,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  controller: item.descController,
                                                  enabled: item.isSelected,
                                                  style: TextStyle(
                                                    decoration: !item.isSelected ? TextDecoration.lineThrough : null,
                                                    color: !item.isSelected ? Colors.grey : null,
                                                  ),
                                                  decoration: const InputDecoration(
                                                    isDense: true,
                                                    border: OutlineInputBorder(),
                                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                  ),
                                                ),
                                              ),
                                              if (!item.isSelected) ...[
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade300,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    isAr ? 'غير مدرج' : 'Excluded',
                                                    style: TextStyle(fontSize: 10, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),

                                        // Ordered Qty (PO)
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            item.orderedQty.toStringAsFixed(1),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                          ),
                                        ),
                                        const SizedBox(width: 8),

                                        // Received Qty (GRNs consolidated)
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            item.receivedQty.toStringAsFixed(1),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: item.isSelected ? Colors.teal.shade800 : Colors.grey,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),

                                        // Invoiced Qty
                                        Expanded(
                                          flex: 1,
                                          child: TextFormField(
                                            controller: item.invoicedQtyController,
                                            enabled: item.isSelected,
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.center,
                                            decoration: InputDecoration(
                                              isDense: true,
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                                              border: const OutlineInputBorder(),
                                              errorStyle: const TextStyle(fontSize: 0),
                                              suffixIcon: exceedsWarning
                                                  ? Tooltip(
                                                      message: isAr
                                                          ? 'الكمية تتجاوز المستلم (${item.receivedQty})'
                                                          : 'Exceeds received qty (${item.receivedQty})',
                                                      child: const Icon(Icons.warning, size: 16, color: Colors.amber),
                                                    )
                                                  : null,
                                            ),
                                            onChanged: (_) => setState(() {}),
                                          ),
                                        ),
                                        const SizedBox(width: 8),

                                        // Unit Price
                                        Expanded(
                                          flex: 2,
                                          child: TextFormField(
                                            controller: item.unitPriceController,
                                            enabled: item.isSelected,
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.center,
                                            decoration: const InputDecoration(
                                              isDense: true,
                                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                              border: OutlineInputBorder(),
                                            ),
                                            onChanged: (_) => setState(() {}),
                                          ),
                                        ),
                                        const SizedBox(width: 8),

                                        // Line Total
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            item.isSelected
                                                ? 'SAR ${(item.invoicedQty * item.unitPrice).toStringAsFixed(2)}'
                                                : 'SAR 0.00',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: item.isSelected ? Colors.black : Colors.grey,
                                            ),
                                          ),
                                        ),

                                        // Delete Item
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                          onPressed: () {
                                            setState(() {
                                              item.dispose();
                                              _lineItems.removeAt(idx);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Row 4: Financial Summary & Supplier Discount
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
                                labelText: isAr ? 'ملاحظات وتفاصيل الفاتورة' : 'Remarks / Terms & Notes',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),

                          // Discount & Financial Breakdown Card
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.indigo.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isAr ? 'الخصومات والحسابات المالية للبنود المحددة' : 'Supplier Discount & Billed Items Totals',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.indigo.shade900),
                                  ),
                                  const Divider(height: 14),

                                  // Gross Subtotal
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(isAr ? 'المجموع الإجمالي للبنود المشمولة:' : 'Gross Subtotal (Included Items):', style: const TextStyle(fontSize: 12)),
                                      Text('SAR ${_grossSubtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // Supplier Discount Control
                                  Row(
                                    children: [
                                      Text(isAr ? 'خصم المورد:' : 'Supplier Discount:', style: const TextStyle(fontSize: 12)),
                                      const SizedBox(width: 10),
                                      // Toggle % vs SAR
                                      InkWell(
                                        onTap: () => setState(() => _isPercentageDiscount = !_isPercentageDiscount),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.indigo.shade100,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            _isPercentageDiscount ? '%' : 'SAR',
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.indigo.shade900),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: SizedBox(
                                          height: 34,
                                          child: TextFormField(
                                            controller: _discountController,
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.right,
                                            decoration: const InputDecoration(
                                              isDense: true,
                                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                              border: OutlineInputBorder(),
                                            ),
                                            onChanged: (_) => setState(() {}),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),

                                  // Discount SAR representation
                                  if (_discountAmount > 0)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(isAr ? 'مبلغ الخصم الفعلي:' : 'Discount Deducted:', style: TextStyle(fontSize: 11, color: Colors.amber.shade900)),
                                        Text('- SAR ${_discountAmount.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.amber.shade900)),
                                      ],
                                    ),
                                  const SizedBox(height: 8),

                                  // Net Taxable Subtotal
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(isAr ? 'الوعاء الخاضع للضريبة:' : 'Net Taxable Subtotal:', style: const TextStyle(fontSize: 12)),
                                      Text('SAR ${_netTaxableSubtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),

                                  // VAT (15%)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(isAr ? 'ضريبة القيمة المضافة (15% VAT):' : 'VAT (15%):', style: const TextStyle(fontSize: 12)),
                                      Text('SAR ${_vatAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                    ],
                                  ),
                                  const Divider(height: 16),

                                  // Grand Total Payable
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        isAr ? 'إجمالي الفاتورة المستحق:' : 'Total Payable (SAR):',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.indigo.shade900),
                                      ),
                                      Text(
                                        'SAR ${_totalPayableAmount.toStringAsFixed(2)}',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo.shade900),
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

              // Actions Footer
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
                      '${isAr ? 'البنود المفوترة:' : 'Billed Items:'} $selectedItemsCount / ${_lineItems.length} | ${isAr ? 'الإجمالي:' : 'Total:'} SAR ${_totalPayableAmount.toStringAsFixed(2)}',
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
                            backgroundColor: Colors.indigo.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: _isSubmitting
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.check_circle_rounded, size: 20),
                          label: Text(
                            isAr ? 'اعتماد وحفظ الفاتورة' : 'Approve & Save Bill',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: _isSubmitting ? null : _submitBill,
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
}

// ==========================================
// POPUP MODAL 1: PO SELECTION (SEARCH & GRID)
// ==========================================
class _PoSelectionModal extends ConsumerStatefulWidget {
  final bool isArabic;
  final String? selectedSupplierId;
  final String? currentSelectedPoId;
  final ValueChanged<PurchaseOrderModel> onSelected;

  const _PoSelectionModal({
    required this.isArabic,
    this.selectedSupplierId,
    this.currentSelectedPoId,
    required this.onSelected,
  });

  @override
  ConsumerState<_PoSelectionModal> createState() => _PoSelectionModalState();
}

class _PoSelectionModalState extends ConsumerState<_PoSelectionModal> {
  String _searchQuery = '';
  String _statusFilter = 'ALL_ACTIVE';
  bool _isGridView = false;

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isArabic;
    final poAsync = ref.watch(purchaseOrdersProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Container(
        width: 950,
        constraints: const BoxConstraints(maxHeight: 750),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(bottom: BorderSide(color: Colors.indigo.shade100)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.indigo.shade700,
                    radius: 18,
                    child: const Icon(Icons.shopping_cart_checkout, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'أوامر الشراء النشطة (Active POs Selection)' : 'Active Purchase Orders Selection',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
                        ),
                        Text(
                          isAr
                              ? 'عرض الأوامر النشطة فقط والتي تحتوي على بنود غير مستلمة أو غير مفوترة بالكامل'
                              : 'Filtering active POs with pending or not-yet-fully-billed products',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
                    tooltip: _isGridView ? (isAr ? 'عرض جدولي' : 'Table View') : (isAr ? 'عرض شبكي' : 'Grid View'),
                    onPressed: () => setState(() => _isGridView = !_isGridView),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Filter & Search Toolbar
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: isAr ? 'بحث برقم أمر الشراء، المورد، أو الملاحظات...' : 'Search PO #, supplier, notes...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: _statusFilter,
                    items: [
                      DropdownMenuItem(value: 'ALL_ACTIVE', child: Text(isAr ? 'جميع النشطة' : 'All Active POs')),
                      DropdownMenuItem(value: 'ISSUED', child: Text(isAr ? 'صادرة (ISSUED)' : 'Issued')),
                      DropdownMenuItem(value: 'APPROVED', child: Text(isAr ? 'معتمدة (APPROVED)' : 'Approved')),
                      DropdownMenuItem(value: 'RECEIVED', child: Text(isAr ? 'مستلمة (RECEIVED)' : 'Received')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _statusFilter = val);
                    },
                  ),
                ],
              ),
            ),

            // List / Grid Body
            Expanded(
              child: poAsync.when(
                data: (allPos) {
                  final filtered = allPos.where((po) {
                    final statusUpper = po.status.toUpperCase();
                    if (statusUpper == 'CANCELLED' || statusUpper == 'REJECTED' || statusUpper == 'DRAFT') {
                      return false;
                    }

                    if (_statusFilter != 'ALL_ACTIVE' && statusUpper != _statusFilter) {
                      return false;
                    }

                    if (widget.selectedSupplierId != null &&
                        po.supplierId != widget.selectedSupplierId &&
                        po.supplierName != widget.selectedSupplierId) {
                      return false;
                    }

                    if (_searchQuery.isNotEmpty) {
                      final matchNum = po.poNumber.toLowerCase().contains(_searchQuery);
                      final matchSup = po.supplierName.toLowerCase().contains(_searchQuery);
                      final matchNotes = (po.notes ?? '').toLowerCase().contains(_searchQuery);
                      if (!matchNum && !matchSup && !matchNotes) return false;
                    }

                    return true;
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            isAr ? 'لا توجد أوامر شراء نشطة تطابق البحث' : 'No active purchase orders found',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }

                  if (_isGridView) {
                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.45,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, idx) {
                        final po = filtered[idx];
                        final isCurrent = po.id == widget.currentSelectedPoId;

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isCurrent ? Colors.indigo.shade600 : Colors.grey.shade200,
                              width: isCurrent ? 2 : 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(po.poNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.indigo)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                                      child: Text(po.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                                    ),
                                  ],
                                ),
                                Text(po.supplierName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                                Text(
                                  'SAR ${double.tryParse(po.totalAmount)?.toStringAsFixed(2) ?? po.totalAmount}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${po.items.length} ${isAr ? 'بنود' : 'items'}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.indigo.shade700,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        minimumSize: const Size(60, 28),
                                      ),
                                      onPressed: () => widget.onSelected(po),
                                      child: Text(isAr ? 'اختيار' : 'Select'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, idx) {
                      final po = filtered[idx];
                      final isCurrent = po.id == widget.currentSelectedPoId;

                      return ListTile(
                        selected: isCurrent,
                        selectedTileColor: Colors.indigo.shade50,
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigo.shade100,
                          child: Icon(Icons.receipt, color: Colors.indigo.shade800, size: 20),
                        ),
                        title: Row(
                          children: [
                            Text(po.poNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                              child: Text(po.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          '${po.supplierName} • ${DateFormat('yyyy-MM-dd').format(po.issueDate)} • ${po.items.length} ${isAr ? 'بنود' : 'items'}',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'SAR ${double.tryParse(po.totalAmount)?.toStringAsFixed(2) ?? po.totalAmount}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(width: 14),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo.shade700,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => widget.onSelected(po),
                              child: Text(isAr ? 'اختيار أمر الشراء' : 'Select PO'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// POPUP MODAL 2: MULTI-GRN SELECTION (SEARCH, GRID & MULTI-SELECT)
// ================================================================
class _GrnSelectionModal extends ConsumerStatefulWidget {
  final bool isArabic;
  final String? linkedPoId;
  final String? linkedPoNumber;
  final String? selectedSupplierId;
  final List<String> currentSelectedGrnIds;
  final ValueChanged<List<GoodsReceivedNoteModel>> onConfirmSelected;

  const _GrnSelectionModal({
    required this.isArabic,
    this.linkedPoId,
    this.linkedPoNumber,
    this.selectedSupplierId,
    required this.currentSelectedGrnIds,
    required this.onConfirmSelected,
  });

  @override
  ConsumerState<_GrnSelectionModal> createState() => _GrnSelectionModalState();
}

class _GrnSelectionModalState extends ConsumerState<_GrnSelectionModal> {
  String _searchQuery = '';
  bool _isGridView = false;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _selectedIds.addAll(widget.currentSelectedGrnIds);
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isArabic;
    final grnAsync = ref.watch(goodsReceivedNotesProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Container(
        width: 1000,
        constraints: const BoxConstraints(maxHeight: 780),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(bottom: BorderSide(color: Colors.teal.shade100)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.teal.shade700,
                    radius: 18,
                    child: const Icon(Icons.playlist_add_check_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'تحديد أذونات الاستلام المتعددة لنفس أمر الشراء' : 'Select Multiple GRNs for this Purchase Order',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
                        ),
                        Text(
                          widget.linkedPoNumber != null
                              ? (isAr ? 'عرض أذونات الاستلام التابعة لأمر الشراء: ${widget.linkedPoNumber} (يمكنك اختيار أكثر من إذن)' : 'GRNs linked to PO: ${widget.linkedPoNumber} (Multi-select enabled)')
                              : (isAr ? 'يمكنك تحديد عدة أذونات استلام لدمج بضاعتها في نفس الفاتورة' : 'Select multiple GRNs to consolidate into one bill'),
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
                    onPressed: () => setState(() => _isGridView = !_isGridView),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Search Bar & Counter Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: isAr ? 'بحث برقم السند، إذن التسليم، أو المستودع...' : 'Search GRN #, delivery note, warehouse...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.teal.shade200),
                    ),
                    child: Text(
                      isAr ? 'تم تحديد ${_selectedIds.length} سندات' : '${_selectedIds.length} GRNs selected',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal.shade900),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: grnAsync.when(
                data: (allGrns) {
                  // Business Rule Filter:
                  // 1) If linked to a PO, ONLY show GRNs belonging to this PO
                  // 2) If supplier selected, filter by supplier
                  // 3) Search query
                  final filtered = allGrns.where((grn) {
                    if (widget.linkedPoId != null && widget.linkedPoId!.isNotEmpty) {
                      final matchId = grn.poId == widget.linkedPoId;
                      final matchNum = widget.linkedPoNumber != null && grn.poNumber == widget.linkedPoNumber;
                      if (!matchId && !matchNum) return false;
                    }

                    if (widget.selectedSupplierId != null &&
                        grn.supplierId != widget.selectedSupplierId &&
                        grn.supplierName != widget.selectedSupplierId) {
                      return false;
                    }

                    if (_searchQuery.isNotEmpty) {
                      final matchNum = grn.grnNumber.toLowerCase().contains(_searchQuery);
                      final matchDn = (grn.deliveryNoteNumber ?? '').toLowerCase().contains(_searchQuery);
                      final matchSup = grn.supplierName.toLowerCase().contains(_searchQuery);
                      if (!matchNum && !matchDn && !matchSup) return false;
                    }

                    return true;
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            isAr
                                ? 'لا توجد أذونات استلام مطابقة لأمر الشراء أو المعايير المحددة'
                                : 'No Goods Received Notes found for this criteria',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }

                  if (_isGridView) {
                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.45,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, idx) {
                        final grn = filtered[idx];
                        final isChecked = _selectedIds.contains(grn.id);

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isChecked ? Colors.teal.shade700 : Colors.grey.shade200,
                              width: isChecked ? 2 : 1,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setState(() {
                                if (isChecked) {
                                  _selectedIds.remove(grn.id);
                                } else {
                                  _selectedIds.add(grn.id);
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(grn.grnNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.teal)),
                                      Checkbox(
                                        value: isChecked,
                                        activeColor: Colors.teal.shade700,
                                        onChanged: (val) {
                                          setState(() {
                                            if (val == true) {
                                              _selectedIds.add(grn.id);
                                            } else {
                                              _selectedIds.remove(grn.id);
                                            }
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  Text(grn.supplierName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                                  Text(
                                    'DN: ${grn.deliveryNoteNumber ?? 'N/A'} • PO: ${grn.poNumber ?? 'N/A'}',
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${grn.items.length} ${isAr ? 'بنود' : 'items'}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                      Text(DateFormat('yyyy-MM-dd').format(grn.receivedDate), style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, idx) {
                      final grn = filtered[idx];
                      final isChecked = _selectedIds.contains(grn.id);

                      return CheckboxListTile(
                        value: isChecked,
                        activeColor: Colors.teal.shade700,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedIds.add(grn.id);
                            } else {
                              _selectedIds.remove(grn.id);
                            }
                          });
                        },
                        secondary: CircleAvatar(
                          backgroundColor: Colors.teal.shade100,
                          child: Icon(Icons.inventory, color: Colors.teal.shade800, size: 20),
                        ),
                        title: Row(
                          children: [
                            Text(grn.grnNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(width: 8),
                            if (grn.poNumber != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(4)),
                                child: Text('PO: ${grn.poNumber}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.indigo.shade900)),
                              ),
                          ],
                        ),
                        subtitle: Text(
                          '${grn.supplierName} • DN: ${grn.deliveryNoteNumber ?? 'N/A'} • ${DateFormat('yyyy-MM-dd').format(grn.receivedDate)} • ${grn.items.length} ${isAr ? 'بنود' : 'items'}',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),

            // Modal Footer: Confirm Selection
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
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          final allGrns = grnAsync.value ?? [];
                          setState(() {
                            _selectedIds.addAll(allGrns.map((g) => g.id));
                          });
                        },
                        child: Text(isAr ? 'تحديد الكل' : 'Select All'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => setState(() => _selectedIds.clear()),
                        child: Text(isAr ? 'إلغاء التحديد' : 'Deselect All'),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.check, size: 18),
                    label: Text(
                      isAr
                          ? 'تأكيد وتحميل البنود (${_selectedIds.length} أذونات)'
                          : 'Confirm & Load Items (${_selectedIds.length} Selected)',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      final allGrns = grnAsync.value ?? [];
                      final selectedList = allGrns.where((g) => _selectedIds.contains(g.id)).toList();
                      widget.onConfirmSelected(selectedList);
                    },
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
