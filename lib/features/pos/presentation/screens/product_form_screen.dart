import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/product_model.dart';
import '../../providers/pos_provider.dart';
import '../../../inventory/providers/category_provider.dart';
import '../../../inventory/providers/sub_category_provider.dart';
import '../../../inventory/providers/unit_provider.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final ProductModel? product;
  const ProductFormScreen({super.key, this.product});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _priceController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _marginPercentageController = TextEditingController(text: '20');
  final _taxRateController = TextEditingController(text: '15');
  String _taxType = 'Exclusive'; // 'Exclusive' or 'Inclusive'
  final _retailAdjustmentPercentageController = TextEditingController(text: '40');
  final _distributorReductionPercentageController = TextEditingController(text: '30');
  final _retailPriceController = TextEditingController();
  final _distributorPriceController = TextEditingController();
  final _specialPriceController = TextEditingController();
  final _discountedPriceController = TextEditingController();

  void _calculatePricingTiers() {
    final cost = _parseNullableDouble(_costPriceController.text) ?? 0.0;
    final margin = _parseNullableDouble(_marginPercentageController.text) ?? 0.0;
    final taxRate = _parseNullableDouble(_taxRateController.text) ?? 15.0;
    final retailAdjPct = _parseNullableDouble(_retailAdjustmentPercentageController.text) ?? 40.0;
    final distRedPct = _parseNullableDouble(_distributorReductionPercentageController.text) ?? 30.0;

    double baseSelling = cost * (1 + (margin / 100.0));
    double finalSellingPrice = baseSelling;

    if (!_isTaxExempt) {
      if (_taxType == 'Exclusive') {
        finalSellingPrice = baseSelling * (1 + (taxRate / 100.0));
      } else {
        finalSellingPrice = baseSelling;
      }
    }

    // Retail Price: Selling Price * (1 + retailAdjPct / 100)
    final retailPrice = finalSellingPrice * (1 + (retailAdjPct / 100.0));

    // Distributor Price: Retail Price * (1 - distRedPct / 100)
    final distributorPrice = retailPrice * (1 - (distRedPct / 100.0));

    if (finalSellingPrice > 0) {
      _priceController.text = finalSellingPrice.toStringAsFixed(2);
    }
    if (retailPrice > 0) {
      _retailPriceController.text = retailPrice.toStringAsFixed(2);
    }
    if (distributorPrice > 0) {
      _distributorPriceController.text = distributorPrice.toStringAsFixed(2);
    }
  }

  void _onSellingPriceChanged() {
    final sellingPrice = _parseNullableDouble(_priceController.text) ?? 0.0;
    final retailAdjPct = _parseNullableDouble(_retailAdjustmentPercentageController.text) ?? 40.0;
    final distRedPct = _parseNullableDouble(_distributorReductionPercentageController.text) ?? 30.0;

    if (sellingPrice > 0) {
      final retailPrice = sellingPrice * (1 + (retailAdjPct / 100.0));
      final distributorPrice = retailPrice * (1 - (distRedPct / 100.0));
      _retailPriceController.text = retailPrice.toStringAsFixed(2);
      _distributorPriceController.text = distributorPrice.toStringAsFixed(2);
    }
  }

  final _stockController = TextEditingController(text: '0');
  final _minStockController = TextEditingController(text: '5');
  final _minOrderQtyController = TextEditingController(text: '0');
  final _packetSizeController = TextEditingController(text: '1');
  final _weightController = TextEditingController(text: '1.0');

  // Vertical & Industry specific controllers
  final _genericNameController = TextEditingController();
  final _activeIngredientController = TextEditingController();
  final _controlledSubstanceScheduleController = TextEditingController();
  final _modelNumberController = TextEditingController();
  final _storageCapacityController = TextEditingController();
  final _ramController = TextEditingController();
  final _warrantyMonthsController = TextEditingController(text: '0');
  final _warrantyPeriodsDaysController = TextEditingController(text: '0');
  final _fiberCompositionController = TextEditingController();

  // Loyalty & Logistics controllers
  final _pointsPerProductController = TextEditingController(text: '0');
  final _returnDaysController = TextEditingController(text: '7');
  final _exchangeDaysController = TextEditingController(text: '30');
  final _promisedDeliveryDaysController = TextEditingController(text: '2');

  // Form State Flags
  bool _isLoading = false;
  bool _isActive = true;
  bool _isCategoryWiseStock = false;
  bool _isProductWiseStock = false;
  bool _isParentProduct = false;
  bool _isPacketOfPieces = false;
  bool _isWeightBased = false;

  bool _isWholesaler = false;
  bool _isDistributor = false;
  bool _isPharmacy = false;
  bool _isMedicine = false;
  bool _isElectronics = false;
  bool _isApparel = false;

  bool _isColorVariant = false;
  bool _isSizeVariant = false;

  bool _isModelNumber = false;
  bool _isColorApplicable = false;
  bool _isStorageCapacityApplicable = false;
  bool _isRamApplicable = false;
  bool _isWarrantyApplicable = false;
  bool _isImeiRequired = false;
  bool _requiresSerialTracking = false;

  bool _isGenericNameApplicable = false;
  bool _isActiveIngredientApplicable = false;
  bool _isStrengthApplicable = false;
  bool _isDosageFormApplicable = false;
  bool _isManufacturerApplicable = false;
  bool _isMarketingAuthHolderApplicable = false;
  bool _isPrescriptionRequired = false;
  bool _requiresBatchTracking = false;

  bool _isUnderwear = false;
  bool _isTaxExempt = false;

  bool _isPointsApplicable = false;
  bool _isProductDisplayPosApp = true;
  bool _isProductDisplayWebsiteApp = false;
  bool _isProductDisplayRackLabel = false;
  bool _isProductDisplayTag = false;
  bool _isProductDisplayPriceTag = false;
  bool _isProductDisplayHangingTag = false;
  bool _isProductDisplayElectronicScale = false;
  bool _isProductDisplayWeighingScale = false;

  bool _isVerifiedByBuyer = false;
  bool _isVerifiedBySupplier = false;
  bool _isOffers = false;

  bool _isPaymentAvailableCod = true;
  bool _isAcceleratedCheckoutAvailable = false;
  bool _isSubscriptionAvailable = false;

  String? _selectedCategory;
  String? _selectedSubCategory;
  String? _selectedUnit = 'PCE';
  List<BranchInventoryModel> _branchInventory = [];
  List<ProductImageModel> _productImages = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryProvider.notifier).fetchCategories();
      ref.read(subCategoryProvider.notifier).fetchSubCategories();
      ref.read(unitProvider.notifier).fetchUnits();
    });

    if (widget.product != null) {
      final p = widget.product!;
      _productImages = List.from(p.images);
      _nameController.text = p.name;
      _skuController.text = p.sku ?? '';
      _barcodeController.text = p.barcode ?? '';
      _descriptionController.text = p.description ?? '';

      _priceController.text = p.price;
      _costPriceController.text = p.costPrice ?? '';
      _marginPercentageController.text = p.marginPercentage.toString();
      _retailPriceController.text = p.retailPrice ?? '';
      _distributorPriceController.text = p.distributorPrice ?? '';
      _specialPriceController.text = p.specialPrice ?? '';
      _discountedPriceController.text = p.discountedPrice ?? '';

      _stockController.text = p.stockQuantity.toString();
      _minStockController.text = p.minStockLevel.toString();
      _minOrderQtyController.text = p.minOrderQty.toString();
      _packetSizeController.text = p.packetSize.toString();
      _weightController.text = p.weight.toString();

      _genericNameController.text = p.genericName ?? '';
      _activeIngredientController.text = p.activeIngredient ?? '';
      _controlledSubstanceScheduleController.text = p.controlledSubstanceSchedule ?? '';
      _modelNumberController.text = p.modelNumber ?? '';
      _storageCapacityController.text = p.storageCapacity ?? '';
      _ramController.text = p.ram ?? '';
      _warrantyMonthsController.text = p.warrantyMonths.toString();
      _warrantyPeriodsDaysController.text = p.warrantyPeriodsDays.toString();
      _fiberCompositionController.text = p.fiberComposition ?? '';

      _pointsPerProductController.text = p.pointsPerProduct.toString();
      _returnDaysController.text = p.returnDays.toString();
      _exchangeDaysController.text = p.exchangeDays.toString();
      _promisedDeliveryDaysController.text = p.promisedDeliveryDays.toString();

      _isActive = p.isActive;
      _isCategoryWiseStock = p.isCategoryWiseStock;
      _isProductWiseStock = p.isProductWiseStock;
      _isParentProduct = p.isParentProduct;
      _isPacketOfPieces = p.isPacketOfPieces;
      _isWeightBased = p.isWeightBased;

      _isWholesaler = p.isWholesaler;
      _isDistributor = p.isDistributor;
      _isPharmacy = p.isPharmacy;
      _isMedicine = p.isMedicine;
      _isElectronics = p.isElectronics;
      _isApparel = p.isApparel;

      _isColorVariant = p.isColorVariant;
      _isSizeVariant = p.isSizeVariant;

      _isModelNumber = p.isModelNumber;
      _isColorApplicable = p.isColorApplicable;
      _isStorageCapacityApplicable = p.isStorageCapacityApplicable;
      _isRamApplicable = p.isRamApplicable;
      _isWarrantyApplicable = p.isWarrantyApplicable;
      _isImeiRequired = p.isImeiRequired;
      _requiresSerialTracking = p.requiresSerialTracking;

      _isGenericNameApplicable = p.isGenericNameApplicable;
      _isActiveIngredientApplicable = p.isActiveIngredientApplicable;
      _isStrengthApplicable = p.isStrengthApplicable;
      _isDosageFormApplicable = p.isDosageFormApplicable;
      _isManufacturerApplicable = p.isManufacturerApplicable;
      _isMarketingAuthHolderApplicable = p.isMarketingAuthHolderApplicable;
      _isPrescriptionRequired = p.isPrescriptionRequired;
      _requiresBatchTracking = p.requiresBatchTracking;

      _isUnderwear = p.isUnderwear;
      _isTaxExempt = p.isTaxExempt;

      _isPointsApplicable = p.isPointsApplicable;
      _isProductDisplayPosApp = p.isProductDisplayPosApp;
      _isProductDisplayWebsiteApp = p.isProductDisplayWebsiteApp;
      _isProductDisplayRackLabel = p.isProductDisplayRackLabel;
      _isProductDisplayTag = p.isProductDisplayTag;
      _isProductDisplayPriceTag = p.isProductDisplayPriceTag;
      _isProductDisplayHangingTag = p.isProductDisplayHangingTag;
      _isProductDisplayElectronicScale = p.isProductDisplayElectronicScale;
      _isProductDisplayWeighingScale = p.isProductDisplayWeighingScale;

      _isVerifiedByBuyer = p.isVerifiedByBuyer;
      _isVerifiedBySupplier = p.isVerifiedBySupplier;
      _isOffers = p.isOffers;

      _isPaymentAvailableCod = p.isPaymentAvailableCod;
      _isAcceleratedCheckoutAvailable = p.isAcceleratedCheckoutAvailable;
      _isSubscriptionAvailable = p.isSubscriptionAvailable;

      _selectedCategory = p.categoryId;
      _selectedSubCategory = null;
      _selectedUnit = p.units.isNotEmpty ? p.units.first.unitCode : 'PCE';
      _branchInventory = List.from(p.branchInventory);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _costPriceController.dispose();
    _marginPercentageController.dispose();
    _retailPriceController.dispose();
    _distributorPriceController.dispose();
    _specialPriceController.dispose();
    _discountedPriceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _minOrderQtyController.dispose();
    _packetSizeController.dispose();
    _weightController.dispose();
    _genericNameController.dispose();
    _activeIngredientController.dispose();
    _controlledSubstanceScheduleController.dispose();
    _modelNumberController.dispose();
    _storageCapacityController.dispose();
    _ramController.dispose();
    _warrantyMonthsController.dispose();
    _warrantyPeriodsDaysController.dispose();
    _fiberCompositionController.dispose();
    _pointsPerProductController.dispose();
    _returnDaysController.dispose();
    _exchangeDaysController.dispose();
    _promisedDeliveryDaysController.dispose();
    super.dispose();
  }

  void _showAddImageDialog() {
    final urlCtrl = TextEditingController();
    final colorTagCtrl = TextEditingController();
    final sizeTagCtrl = TextEditingController();
    bool isPrimary = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              title: const Text('Add Variant Image'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: urlCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Image URL / Asset Path *',
                      hintText: 'https://domain.com/images/red-shirt.jpg',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: colorTagCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Color Tag (e.g. Red, Blue)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: sizeTagCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Size Tag (e.g. S, M, L)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    title: const Text('Set as Primary Image'),
                    value: isPrimary,
                    onChanged: (val) => setDlgState(() => isPrimary = val ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    final url = urlCtrl.text.trim();
                    if (url.isNotEmpty) {
                      setState(() {
                        if (isPrimary) {
                          _productImages = _productImages.map((i) => i.copyWith(isPrimary: false)).toList();
                        }
                        _productImages.add(ProductImageModel(
                          id: '',
                          productId: widget.product?.id ?? '',
                          colorId: colorTagCtrl.text.trim().isEmpty ? null : colorTagCtrl.text.trim(),
                          sizeId: sizeTagCtrl.text.trim().isEmpty ? null : sizeTagCtrl.text.trim(),
                          imageUrl: url,
                          isPrimary: isPrimary,
                          displayOrder: _productImages.length,
                        ));
                      });
                    }
                    Navigator.pop(ctx);
                  },
                  child: const Text('Add Image'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  double? _parseNullableDouble(String text) {
    final clean = text.trim().replaceAll(',', '.');
    return clean.isEmpty ? null : double.tryParse(clean);
  }

  int _parseInt(String text, {int defaultValue = 0}) {
    final clean = text.trim().replaceAll(',', '.');
    if (clean.isEmpty) return defaultValue;
    return int.tryParse(clean) ?? (double.tryParse(clean)?.toInt() ?? defaultValue);
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final api = ref.read(posApiProvider);

      final data = {
        'productName': _nameController.text.trim(),
        'sku': _skuController.text.trim().isEmpty ? (_barcodeController.text.trim().isEmpty ? null : _barcodeController.text.trim()) : _skuController.text.trim(),
        'barcode': _barcodeController.text.trim().isEmpty ? null : _barcodeController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        if (_selectedCategory != null) 'categoryId': _selectedCategory,

        // Pricing
        'baseSellingPrice': _parseNullableDouble(_priceController.text) ?? 0.0,
        'costPrice': _parseNullableDouble(_costPriceController.text),
        'marginPercentage': _parseNullableDouble(_marginPercentageController.text) ?? 20.0,
        'retailPrice': _parseNullableDouble(_retailPriceController.text),
        'distributorPrice': _parseNullableDouble(_distributorPriceController.text),
        'specialPrice': _parseNullableDouble(_specialPriceController.text),
        'discountedPrice': _parseNullableDouble(_discountedPriceController.text),
        'isTaxExempt': _isTaxExempt,

        // Inventory & Packaging
        'stockQuantity': _parseInt(_stockController.text, defaultValue: 0),
        'minStockLevel': _parseInt(_minStockController.text, defaultValue: 5),
        'minOrderQty': _parseInt(_minOrderQtyController.text, defaultValue: 0),
        'isCategoryWiseStock': _isCategoryWiseStock,
        'isProductWiseStock': _isProductWiseStock,
        'isParentProduct': _isParentProduct,
        'isPacketOfPieces': _isPacketOfPieces,
        'packetSize': _parseInt(_packetSizeController.text, defaultValue: 1),
        'isWeightBased': _isWeightBased,
        'weight': _parseNullableDouble(_weightController.text) ?? 1.0,

        // Business Vertical Flags
        'isWholesaler': _isWholesaler,
        'isDistributor': _isDistributor,
        'isPharmacy': _isPharmacy,
        'isMedicine': _isMedicine,
        'isElectronics': _isElectronics,
        'isApparel': _isApparel,

        // Pharmacy Attributes
        'isGenericNameApplicable': _isGenericNameApplicable || _genericNameController.text.trim().isNotEmpty,
        'genericName': _genericNameController.text.trim().isEmpty ? null : _genericNameController.text.trim(),
        'isActiveIngredientApplicable': _isActiveIngredientApplicable || _activeIngredientController.text.trim().isNotEmpty,
        'activeIngredient': _activeIngredientController.text.trim().isEmpty ? null : _activeIngredientController.text.trim(),
        'isStrengthApplicable': _isStrengthApplicable,
        'isDosageFormApplicable': _isDosageFormApplicable,
        'isManufacturerApplicable': _isManufacturerApplicable,
        'isMarketingAuthHolderApplicable': _isMarketingAuthHolderApplicable,
        'isPrescriptionRequired': _isPrescriptionRequired,
        'controlledSubstanceSchedule': _controlledSubstanceScheduleController.text.trim().isEmpty ? null : _controlledSubstanceScheduleController.text.trim(),
        'requiresBatchTracking': _requiresBatchTracking,

        // Electronics Attributes
        'isModelNumber': _isModelNumber || _modelNumberController.text.trim().isNotEmpty,
        'modelNumber': _modelNumberController.text.trim().isEmpty ? null : _modelNumberController.text.trim(),
        'isColorApplicable': _isColorApplicable,
        'isStorageCapacityApplicable': _isStorageCapacityApplicable || _storageCapacityController.text.trim().isNotEmpty,
        'storageCapacity': _storageCapacityController.text.trim().isEmpty ? null : _storageCapacityController.text.trim(),
        'isRamApplicable': _isRamApplicable || _ramController.text.trim().isNotEmpty,
        'ram': _ramController.text.trim().isEmpty ? null : _ramController.text.trim(),
        'isWarrantyApplicable': _isWarrantyApplicable || (_parseInt(_warrantyMonthsController.text) > 0),
        'warrantyMonths': _parseInt(_warrantyMonthsController.text, defaultValue: 0),
        'warrantyPeriodsDays': _parseInt(_warrantyPeriodsDaysController.text, defaultValue: 0),
        'isImeiRequired': _isImeiRequired,
        'requiresSerialTracking': _requiresSerialTracking,
        'isColorVariant': _isColorVariant,
        'isSizeVariant': _isSizeVariant,

        // Apparel Attributes
        'fiberComposition': _fiberCompositionController.text.trim().isEmpty ? null : _fiberCompositionController.text.trim(),
        'isUnderwear': _isUnderwear,

        // Display Targets
        'isProductDisplayPosApp': _isProductDisplayPosApp,
        'isProductDisplayWebsiteApp': _isProductDisplayWebsiteApp,
        'isProductDisplayRackLabel': _isProductDisplayRackLabel,
        'isProductDisplayTag': _isProductDisplayTag,
        'isProductDisplayPriceTag': _isProductDisplayPriceTag,
        'isProductDisplayHangingTag': _isProductDisplayHangingTag,
        'isProductDisplayElectronicScale': _isProductDisplayElectronicScale,
        'isProductDisplayWeighingScale': _isProductDisplayWeighingScale,

        // Verification & Offers
        'isVerifiedByBuyer': _isVerifiedByBuyer,
        'isVerifiedBySupplier': _isVerifiedBySupplier,
        'isOffers': _isOffers,

        // Loyalty & Logistics
        'isPointsApplicable': _isPointsApplicable,
        'pointsPerProduct': _parseInt(_pointsPerProductController.text, defaultValue: 0),
        'returnDays': _parseInt(_returnDaysController.text, defaultValue: 7),
        'exchangeDays': _parseInt(_exchangeDaysController.text, defaultValue: 30),
        'promisedDeliveryDays': _parseInt(_promisedDeliveryDaysController.text, defaultValue: 2),
        'isPaymentAvailableCod': _isPaymentAvailableCod,
        'isAcceleratedCheckoutAvailable': _isAcceleratedCheckoutAvailable,
        'isSubscriptionAvailable': _isSubscriptionAvailable,

        'isActive': _isActive,
        'images': _productImages.map((img) => img.toJson()).toList(),
        'branchInventory': _branchInventory.map((b) => b.toJson()).toList(),
      };

      if (widget.product == null) {
        await api.createProduct(data);
      } else {
        await api.updateProduct(widget.product!.id, data);
      }

      ref.invalidate(productsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.product == null ? 'Product created successfully!' : 'Product updated successfully!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving product: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoryProvider);
    final subCategoriesState = ref.watch(subCategoryProvider);
    final unitsState = ref.watch(unitProvider);

    final categoryList = categoriesState.value ?? [];
    final Map<String?, DropdownMenuItem<String?>> categoryItemMap = {
      null: const DropdownMenuItem<String?>(value: null, child: Text('None')),
    };
    for (var c in categoryList) {
      if (c.id.isNotEmpty) {
        categoryItemMap[c.id] = DropdownMenuItem<String?>(value: c.id, child: Text(c.name.isEmpty ? 'Unnamed Category' : c.name));
      }
    }
    final categoryItems = categoryItemMap.values.toList();
    final validCategoryValues = categoryItems.map((i) => i.value).toSet();
    final safeCategory = validCategoryValues.contains(_selectedCategory) ? _selectedCategory : null;

    final subCategoryList = subCategoriesState.value ?? [];
    final Map<String?, DropdownMenuItem<String?>> subCategoryItemMap = {
      null: const DropdownMenuItem<String?>(value: null, child: Text('None')),
    };
    if (safeCategory != null) {
      for (var s in subCategoryList) {
        if (s.id.isNotEmpty && s.categoryId == safeCategory) {
          subCategoryItemMap[s.id] = DropdownMenuItem<String?>(value: s.id, child: Text(s.name.isEmpty ? 'Unnamed Sub-Category' : s.name));
        }
      }
    }
    final subCategoryItems = subCategoryItemMap.values.toList();
    final validSubCatValues = subCategoryItems.map((i) => i.value).toSet();
    final safeSubCategory = validSubCatValues.contains(_selectedSubCategory) ? _selectedSubCategory : null;

    final unitList = unitsState.value ?? [];
    final Map<String?, DropdownMenuItem<String?>> unitItemMap = {
      'PCE': const DropdownMenuItem<String?>(value: 'PCE', child: Text('Piece (PCE)')),
    };
    for (var u in unitList) {
      final code = u.shortName.trim().isEmpty ? u.name.trim() : u.shortName.trim();
      if (code.isNotEmpty) {
        unitItemMap[code] = DropdownMenuItem<String?>(value: code, child: Text('${u.name} ($code)'));
      }
    }
    final unitItems = unitItemMap.values.toList();
    final validUnitValues = unitItems.map((i) => i.value).toSet();
    final safeUnit = validUnitValues.contains(_selectedUnit) 
        ? _selectedUnit 
        : (validUnitValues.contains('PCE') ? 'PCE' : unitItems.first.value);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        actions: [
          _isLoading
              ? const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())
              : IconButton(icon: const Icon(Icons.save), onPressed: _saveProduct),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 1. Basic Information
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('1. Basic Details & Classification', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          SwitchListTile(
                            dense: true,
                            title: const Text('Is Active'),
                            value: _isActive,
                            onChanged: (val) => setState(() => _isActive = val),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Product Name *', border: OutlineInputBorder()),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String?>(
                              value: safeCategory,
                              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                              items: categoryItems,
                              onChanged: (val) {
                                setState(() {
                                  _selectedCategory = val;
                                  _selectedSubCategory = null;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String?>(
                              value: safeSubCategory,
                              decoration: const InputDecoration(labelText: 'Sub-Category', border: OutlineInputBorder()),
                              items: subCategoryItems,
                              onChanged: _selectedCategory == null ? null : (val) => setState(() => _selectedSubCategory = val),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String?>(
                              value: safeUnit,
                              decoration: const InputDecoration(labelText: 'Base Unit', border: OutlineInputBorder()),
                              items: unitItems,
                              onChanged: (val) => setState(() => _selectedUnit = val ?? safeUnit),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _skuController,
                              decoration: const InputDecoration(labelText: 'SKU (Item Code)', border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _barcodeController,
                              decoration: const InputDecoration(labelText: 'Barcode (EAN/UPC)', border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: 'Description (E-commerce / Internal)', border: OutlineInputBorder()),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Pricing & Tax Tiers
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('2. Pricing & Tax Tiers (SAR)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          FilterChip(
                            label: const Text('Tax Exempt'),
                            selected: _isTaxExempt,
                            onSelected: (val) {
                              setState(() {
                                _isTaxExempt = val;
                                _calculatePricingTiers();
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Tier Sequence 1 & 2: Cost Price -> Margin % -> Tax Type -> Tax Rate %
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _costPriceController,
                              decoration: const InputDecoration(labelText: 'Cost Price', border: OutlineInputBorder()),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() => _calculatePricingTiers()),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _marginPercentageController,
                              decoration: const InputDecoration(labelText: 'Margin %', border: OutlineInputBorder()),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() => _calculatePricingTiers()),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _taxType,
                              decoration: const InputDecoration(labelText: 'Tax Type', border: OutlineInputBorder()),
                              items: const [
                                DropdownMenuItem(value: 'Exclusive', child: Text('Exclusive (Added)')),
                                DropdownMenuItem(value: 'Inclusive', child: Text('Inclusive (Built-in)')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _taxType = val;
                                    _calculatePricingTiers();
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _taxRateController,
                              decoration: const InputDecoration(labelText: 'Tax Rate %', border: OutlineInputBorder()),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() => _calculatePricingTiers()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Tier Sequence 3: Base Selling Price (Calculated from Cost + Margin + Tax)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              decoration: const InputDecoration(
                                labelText: 'Base Selling Price * (Cost + Margin + Tax)',
                                border: OutlineInputBorder(),
                                helperText: 'Auto-calculated from Cost, Margin & Tax (Editable)',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                              onChanged: (_) => setState(() => _onSellingPriceChanged()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Tier Sequence 4 & 5: Retail Adjustment % -> Retail Price -> Distributor Reduction % -> Distributor Price
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _retailAdjustmentPercentageController,
                              decoration: const InputDecoration(
                                labelText: 'Retail Adjust %',
                                border: OutlineInputBorder(),
                                helperText: 'Default 40%',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() => _onSellingPriceChanged()),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _retailPriceController,
                              decoration: const InputDecoration(
                                labelText: 'Retail Price',
                                border: OutlineInputBorder(),
                                helperText: 'Selling Price x (1 + Retail %)',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _distributorReductionPercentageController,
                              decoration: const InputDecoration(
                                labelText: 'Dist. Reduction %',
                                border: OutlineInputBorder(),
                                helperText: 'Default 30%',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() => _onSellingPriceChanged()),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _distributorPriceController,
                              decoration: const InputDecoration(
                                labelText: 'Distributor Price',
                                border: OutlineInputBorder(),
                                helperText: 'Retail Price x (1 - Dist %)',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Tier Sequence 6 & 7: Special Price -> Discounted Price
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _specialPriceController,
                              decoration: const InputDecoration(
                                labelText: 'Special Price (Management Decision)',
                                border: OutlineInputBorder(),
                                helperText: 'Custom management approved price',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _discountedPriceController,
                              decoration: const InputDecoration(
                                labelText: 'Discounted Price (Offers)',
                                border: OutlineInputBorder(),
                                helperText: 'Must NOT be less than Distributor Price',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v != null && v.trim().isNotEmpty) {
                                  final disc = _parseNullableDouble(v);
                                  final dist = _parseNullableDouble(_distributorPriceController.text);
                                  if (disc != null && dist != null && disc < dist) {
                                    return 'Discounted price cannot be less than Distributor Price (SAR ${dist.toStringAsFixed(2)})';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Stock, Packaging & Weight
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('3. Inventory & Packaging Controls', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _stockController,
                              decoration: const InputDecoration(labelText: 'Global Stock Quantity *', border: OutlineInputBorder()),
                              keyboardType: TextInputType.number,
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _minStockController,
                              decoration: const InputDecoration(labelText: 'Min Stock Level Alert', border: OutlineInputBorder()),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _minOrderQtyController,
                              decoration: const InputDecoration(labelText: 'Min Order Qty', border: OutlineInputBorder()),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilterChip(
                            label: const Text('Category-Wise Stock'),
                            selected: _isCategoryWiseStock,
                            onSelected: (val) => setState(() => _isCategoryWiseStock = val),
                          ),
                          FilterChip(
                            label: const Text('Product-Wise Stock'),
                            selected: _isProductWiseStock,
                            onSelected: (val) => setState(() => _isProductWiseStock = val),
                          ),
                          FilterChip(
                            label: const Text('Packet of Pieces'),
                            selected: _isPacketOfPieces,
                            onSelected: (val) => setState(() => _isPacketOfPieces = val),
                          ),
                          FilterChip(
                            label: const Text('Weight Based'),
                            selected: _isWeightBased,
                            onSelected: (val) => setState(() => _isWeightBased = val),
                          ),
                        ],
                      ),
                      if (_isPacketOfPieces || _isWeightBased) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            if (_isPacketOfPieces)
                              Expanded(
                                child: TextFormField(
                                  controller: _packetSizeController,
                                  decoration: const InputDecoration(labelText: 'Packet Size (Pcs per Pack)', border: OutlineInputBorder()),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            if (_isPacketOfPieces && _isWeightBased) const SizedBox(width: 16),
                            if (_isWeightBased)
                              Expanded(
                                child: TextFormField(
                                  controller: _weightController,
                                  decoration: const InputDecoration(labelText: 'Weight (KG / Unit)', border: OutlineInputBorder()),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // 4. Industry & Business Roles
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('4. Industry Verticals & Business Roles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          FilterChip(
                            label: const Text('Wholesaler Product'),
                            selected: _isWholesaler,
                            onSelected: (val) => setState(() => _isWholesaler = val),
                          ),
                          FilterChip(
                            label: const Text('Distributor Product'),
                            selected: _isDistributor,
                            onSelected: (val) => setState(() => _isDistributor = val),
                          ),
                          FilterChip(
                            label: const Text('Pharmacy / Medical'),
                            selected: _isPharmacy,
                            onSelected: (val) => setState(() => _isPharmacy = val),
                          ),
                          FilterChip(
                            label: const Text('Medicine Item'),
                            selected: _isMedicine,
                            onSelected: (val) => setState(() => _isMedicine = val),
                          ),
                          FilterChip(
                            label: const Text('Electronics'),
                            selected: _isElectronics,
                            onSelected: (val) => setState(() => _isElectronics = val),
                          ),
                          FilterChip(
                            label: const Text('Apparel / Textile'),
                            selected: _isApparel,
                            onSelected: (val) => setState(() => _isApparel = val),
                          ),
                        ],
                      ),

                      // Pharmacy Details
                      if (_isPharmacy || _isMedicine) ...[
                        const Divider(height: 24),
                        const Text('Pharmacy Specific Attributes', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _genericNameController,
                                decoration: const InputDecoration(labelText: 'Generic Name', border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _activeIngredientController,
                                decoration: const InputDecoration(labelText: 'Active Ingredient', border: OutlineInputBorder()),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _controlledSubstanceScheduleController,
                                decoration: const InputDecoration(labelText: 'Controlled Schedule (e.g. Rx/Schedule H)', border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SwitchListTile(
                                dense: true,
                                title: const Text('Prescription Required'),
                                value: _isPrescriptionRequired,
                                onChanged: (val) => setState(() => _isPrescriptionRequired = val),
                              ),
                            ),
                            Expanded(
                              child: SwitchListTile(
                                dense: true,
                                title: const Text('Batch / Expiry Tracking'),
                                value: _requiresBatchTracking,
                                onChanged: (val) => setState(() => _requiresBatchTracking = val),
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Electronics Details
                      if (_isElectronics) ...[
                        const Divider(height: 24),
                        const Text('Electronics Specific Attributes', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _modelNumberController,
                                decoration: const InputDecoration(labelText: 'Model Number', border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _storageCapacityController,
                                decoration: const InputDecoration(labelText: 'Storage Capacity (e.g., 256GB)', border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _ramController,
                                decoration: const InputDecoration(labelText: 'RAM (e.g., 12GB)', border: OutlineInputBorder()),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _warrantyMonthsController,
                                decoration: const InputDecoration(labelText: 'Warranty Months', border: OutlineInputBorder()),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _warrantyPeriodsDaysController,
                                decoration: const InputDecoration(labelText: 'Warranty Days', border: OutlineInputBorder()),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SwitchListTile(
                                dense: true,
                                title: const Text('IMEI Required'),
                                value: _isImeiRequired,
                                onChanged: (val) => setState(() => _isImeiRequired = val),
                              ),
                            ),
                            Expanded(
                              child: SwitchListTile(
                                dense: true,
                                title: const Text('Serial Tracking'),
                                value: _requiresSerialTracking,
                                onChanged: (val) => setState(() => _requiresSerialTracking = val),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          children: [
                            FilterChip(
                              label: const Text('Color Variant Item'),
                              selected: _isColorVariant,
                              onSelected: (val) => setState(() => _isColorVariant = val),
                            ),
                            FilterChip(
                              label: const Text('Size Variant Item'),
                              selected: _isSizeVariant,
                              onSelected: (val) => setState(() => _isSizeVariant = val),
                            ),
                          ],
                        ),
                      ],

                      // Apparel Details
                      if (_isApparel) ...[
                        const Divider(height: 24),
                        const Text('Apparel Specific Attributes', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _fiberCompositionController,
                                decoration: const InputDecoration(labelText: 'Fiber Composition (e.g. 100% Cotton)', border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SwitchListTile(
                                dense: true,
                                title: const Text('Is Underwear (Strict Cert)'),
                                value: _isUnderwear,
                                onChanged: (val) => setState(() => _isUnderwear = val),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // 5. Display Targets & Scale Options
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('5. Display Targets & Labeling Options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilterChip(label: const Text('POS App'), selected: _isProductDisplayPosApp, onSelected: (val) => setState(() => _isProductDisplayPosApp = val)),
                          FilterChip(label: const Text('Website App'), selected: _isProductDisplayWebsiteApp, onSelected: (val) => setState(() => _isProductDisplayWebsiteApp = val)),
                          FilterChip(label: const Text('Rack Label'), selected: _isProductDisplayRackLabel, onSelected: (val) => setState(() => _isProductDisplayRackLabel = val)),
                          FilterChip(label: const Text('Tag'), selected: _isProductDisplayTag, onSelected: (val) => setState(() => _isProductDisplayTag = val)),
                          FilterChip(label: const Text('Price Tag'), selected: _isProductDisplayPriceTag, onSelected: (val) => setState(() => _isProductDisplayPriceTag = val)),
                          FilterChip(label: const Text('Hanging Tag'), selected: _isProductDisplayHangingTag, onSelected: (val) => setState(() => _isProductDisplayHangingTag = val)),
                          FilterChip(label: const Text('Electronic Scale'), selected: _isProductDisplayElectronicScale, onSelected: (val) => setState(() => _isProductDisplayElectronicScale = val)),
                          FilterChip(label: const Text('Weighing Scale'), selected: _isProductDisplayWeighingScale, onSelected: (val) => setState(() => _isProductDisplayWeighingScale = val)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 6. Loyalty, Returns & Logistics
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('6. Loyalty, Returns & Fulfillment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: SwitchListTile(
                              dense: true,
                              title: const Text('Points Applicable'),
                              value: _isPointsApplicable,
                              onChanged: (val) => setState(() => _isPointsApplicable = val),
                            ),
                          ),
                          if (_isPointsApplicable)
                            Expanded(
                              child: TextFormField(
                                controller: _pointsPerProductController,
                                decoration: const InputDecoration(labelText: 'Points per Item', border: OutlineInputBorder()),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _returnDaysController,
                              decoration: const InputDecoration(labelText: 'Return Days', border: OutlineInputBorder()),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _exchangeDaysController,
                              decoration: const InputDecoration(labelText: 'Exchange Days', border: OutlineInputBorder()),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _promisedDeliveryDaysController,
                              decoration: const InputDecoration(labelText: 'Promised Delivery (Days)', border: OutlineInputBorder()),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          FilterChip(label: const Text('COD Available'), selected: _isPaymentAvailableCod, onSelected: (val) => setState(() => _isPaymentAvailableCod = val)),
                          FilterChip(label: const Text('Accelerated Checkout'), selected: _isAcceleratedCheckoutAvailable, onSelected: (val) => setState(() => _isAcceleratedCheckoutAvailable = val)),
                          FilterChip(label: const Text('Subscription Available'), selected: _isSubscriptionAvailable, onSelected: (val) => setState(() => _isSubscriptionAvailable = val)),
                          FilterChip(label: const Text('Buyer Verified'), selected: _isVerifiedByBuyer, onSelected: (val) => setState(() => _isVerifiedByBuyer = val)),
                          FilterChip(label: const Text('Supplier Verified'), selected: _isVerifiedBySupplier, onSelected: (val) => setState(() => _isVerifiedBySupplier = val)),
                          FilterChip(label: const Text('Special Offers'), selected: _isOffers, onSelected: (val) => setState(() => _isOffers = val)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 7. Color & Size Variant Multi-Image Gallery
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('7. Color & Size Variant Gallery', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ElevatedButton.icon(
                            onPressed: _showAddImageDialog,
                            icon: const Icon(Icons.add_a_photo),
                            label: const Text('Add Variant Image'),
                          ),
                        ],
                      ),
                      const Divider(),
                      if (_productImages.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('No variant images added yet. Click "Add Variant Image" to attach images per color or size.', style: TextStyle(color: Colors.grey)),
                        )
                      else
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            for (int i = 0; i < _productImages.length; i++)
                              Container(
                                width: 140,
                                decoration: BoxDecoration(
                                  border: Border.all(color: _productImages[i].isPrimary ? Colors.amber : Colors.grey.shade300, width: _productImages[i].isPrimary ? 2 : 1),
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey.shade50,
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            _productImages[i].imageUrl,
                                            height: 100,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              height: 100,
                                              color: Colors.grey.shade200,
                                              child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                        if (_productImages[i].isPrimary)
                                          Positioned(
                                            top: 4,
                                            left: 4,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(4)),
                                              child: const Text('Primary', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                                            ),
                                          ),
                                        Positioned(
                                          top: 2,
                                          right: 2,
                                          child: CircleAvatar(
                                            radius: 14,
                                            backgroundColor: Colors.white,
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              icon: const Icon(Icons.close, size: 16, color: Colors.red),
                                              onPressed: () => setState(() => _productImages.removeAt(i)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (_productImages[i].colorId != null)
                                      Text('Color: ${_productImages[i].colorId}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.teal)),
                                    if (_productImages[i].sizeId != null)
                                      Text('Size: ${_productImages[i].sizeId}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.indigo)),
                                    if (_productImages[i].colorId == null && _productImages[i].sizeId == null)
                                      const Text('General Image', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveProduct,
                  icon: const Icon(Icons.save),
                  label: Text(widget.product == null ? 'CREATE PRODUCT' : 'UPDATE PRODUCT', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
