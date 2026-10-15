// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ProductModel _$$_ProductModelFromJson(Map<String, dynamic> json) =>
    _$_ProductModel(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String?,
      sku: json['sku'] as String?,
      name: json['productName'] as String,
      barcode: json['barcode'] as String?,
      description: json['description'] as String?,
      price: _toString(json['baseSellingPrice']),
      costPrice: _toStringNullable(json['costPrice']),
      discountAmount: json['discountAmount'] == null
          ? '0'
          : _toString(json['discountAmount']),
      stockQuantity:
          json['stockQuantity'] == null ? 0 : _toInt(json['stockQuantity']),
      minStockLevel: json['minStockLevel'] == null
          ? 5
          : _toIntDefaultFive(json['minStockLevel']),
      parentProductId: json['parentProductId'] as String?,
      brandId: json['brandId'] as String?,
      productTypeId: json['productTypeId'] as String?,
      unitId: json['unitId'] as String?,
      sizeId: json['sizeId'] as String?,
      colorId: json['colorId'] as String?,
      taxCategoryId: json['taxCategoryId'] as String?,
      modelNumber: json['modelNumber'] as String?,
      storageCapacity: json['storageCapacity'] as String?,
      ram: json['ram'] as String?,
      genericName: json['genericName'] as String?,
      activeIngredient: json['activeIngredient'] as String?,
      strengthId: json['strengthId'] as String?,
      dosageFormId: json['dosageFormId'] as String?,
      manufacturerId: json['manufacturerId'] as String?,
      marketingAuthHolderId: json['marketingAuthHolderId'] as String?,
      storageConditionId: json['storageConditionId'] as String?,
      apparelProductTypeId: json['apparelProductTypeId'] as String?,
      fiberComposition: json['fiberComposition'] as String?,
      genderId: json['genderId'] as String?,
      ageGroupId: json['ageGroupId'] as String?,
      isCategoryWiseStock: json['isCategoryWiseStock'] as bool? ?? false,
      isProductWiseStock: json['isProductWiseStock'] as bool? ?? false,
      isParentProduct: json['isParentProduct'] as bool? ?? false,
      isPacketOfPieces: json['isPacketOfPieces'] as bool? ?? false,
      packetSize: json['packetSize'] as int? ?? 1,
      isWeightBased: json['isWeightBased'] as bool? ?? false,
      weight: (json['weight'] as num?)?.toDouble() ?? 1.0,
      marginPercentage: (json['marginPercentage'] as num?)?.toDouble() ?? 20.0,
      retailPrice: _toStringNullable(json['retailPrice']),
      distributorPrice: _toStringNullable(json['distributorPrice']),
      specialPrice: _toStringNullable(json['specialPrice']),
      discountedPrice: _toStringNullable(json['discountedPrice']),
      stockInHand: json['stockInHand'] as int? ?? 0,
      minOrderQty: json['minOrderQty'] as int? ?? 0,
      isWholesaler: json['isWholesaler'] as bool? ?? false,
      isDistributor: json['isDistributor'] as bool? ?? false,
      isPharmacy: json['isPharmacy'] as bool? ?? false,
      isElectronics: json['isElectronics'] as bool? ?? false,
      isModelNumber: json['isModelNumber'] as bool? ?? false,
      isColorApplicable: json['isColorApplicable'] as bool? ?? false,
      isStorageCapacityApplicable:
          json['isStorageCapacityApplicable'] as bool? ?? false,
      storageCapacityId: json['storageCapacityId'] as String?,
      isRamApplicable: json['isRamApplicable'] as bool? ?? false,
      ramId: json['ramId'] as String?,
      isWarrantyApplicable: json['isWarrantyApplicable'] as bool? ?? false,
      warrantyMonths: json['warrantyMonths'] as int? ?? 0,
      warrantyPeriodsDays: json['warrantyPeriodsDays'] as int? ?? 0,
      warrantyProviderId: json['warrantyProviderId'] as String?,
      isImeiRequired: json['isImeiRequired'] as bool? ?? false,
      requiresSerialTracking: json['requiresSerialTracking'] as bool? ?? false,
      isColorVariant: json['isColorVariant'] as bool? ?? false,
      colorVariantId: json['colorVariantId'] as String?,
      isSizeVariant: json['isSizeVariant'] as bool? ?? false,
      sizeVariantId: json['sizeVariantId'] as String?,
      sizeVariantIds: json['sizeVariantIds'] == null
          ? const []
          : _toStringList(json['sizeVariantIds']),
      isMedicine: json['isMedicine'] as bool? ?? false,
      isGenericNameApplicable:
          json['isGenericNameApplicable'] as bool? ?? false,
      isActiveIngredientApplicable:
          json['isActiveIngredientApplicable'] as bool? ?? false,
      isStrengthApplicable: json['isStrengthApplicable'] as bool? ?? false,
      isDosageFormApplicable: json['isDosageFormApplicable'] as bool? ?? false,
      isManufacturerApplicable:
          json['isManufacturerApplicable'] as bool? ?? false,
      isMarketingAuthHolderApplicable:
          json['isMarketingAuthHolderApplicable'] as bool? ?? false,
      isPrescriptionRequired: json['isPrescriptionRequired'] as bool? ?? false,
      controlledSubstanceSchedule:
          json['controlledSubstanceSchedule'] as String?,
      requiresBatchTracking: json['requiresBatchTracking'] as bool? ?? false,
      isApparel: json['isApparel'] as bool? ?? false,
      isUnderwear: json['isUnderwear'] as bool? ?? false,
      isTaxExempt: json['isTaxExempt'] as bool? ?? false,
      isPointsApplicable: json['isPointsApplicable'] as bool? ?? false,
      pointsPerProduct: json['pointsPerProduct'] as int? ?? 0,
      isProductDisplayPosApp: json['isProductDisplayPosApp'] as bool? ?? true,
      isProductDisplayWebsiteApp:
          json['isProductDisplayWebsiteApp'] as bool? ?? false,
      isProductDisplayRackLabel:
          json['isProductDisplayRackLabel'] as bool? ?? false,
      isProductDisplayTag: json['isProductDisplayTag'] as bool? ?? false,
      isProductDisplayPriceTag:
          json['isProductDisplayPriceTag'] as bool? ?? false,
      isProductDisplayHangingTag:
          json['isProductDisplayHangingTag'] as bool? ?? false,
      isProductDisplayElectronicScale:
          json['isProductDisplayElectronicScale'] as bool? ?? false,
      isProductDisplayWeighingScale:
          json['isProductDisplayWeighingScale'] as bool? ?? false,
      isVerifiedByBuyer: json['isVerifiedByBuyer'] as bool? ?? false,
      isVerifiedBySupplier: json['isVerifiedBySupplier'] as bool? ?? false,
      isOffers: json['isOffers'] as bool? ?? false,
      returnDays: json['returnDays'] as int? ?? 7,
      exchangeDays: json['exchangeDays'] as int? ?? 30,
      promisedDeliveryDays: json['promisedDeliveryDays'] as int? ?? 2,
      isPaymentAvailableCod: json['isPaymentAvailableCod'] as bool? ?? true,
      isAcceleratedCheckoutAvailable:
          json['isAcceleratedCheckoutAvailable'] as bool? ?? false,
      isSubscriptionAvailable:
          json['isSubscriptionAvailable'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      units: json['units'] == null ? const [] : _toUnitsList(json['units']),
      branchInventory: json['branchInventory'] == null
          ? const []
          : _toBranchInventoryList(json['branchInventory']),
      images: json['images'] == null ? const [] : _toImagesList(json['images']),
    );

Map<String, dynamic> _$$_ProductModelToJson(_$_ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'categoryId': instance.categoryId,
      'sku': instance.sku,
      'productName': instance.name,
      'barcode': instance.barcode,
      'description': instance.description,
      'baseSellingPrice': instance.price,
      'costPrice': instance.costPrice,
      'discountAmount': instance.discountAmount,
      'stockQuantity': instance.stockQuantity,
      'minStockLevel': instance.minStockLevel,
      'parentProductId': instance.parentProductId,
      'brandId': instance.brandId,
      'productTypeId': instance.productTypeId,
      'unitId': instance.unitId,
      'sizeId': instance.sizeId,
      'colorId': instance.colorId,
      'taxCategoryId': instance.taxCategoryId,
      'modelNumber': instance.modelNumber,
      'storageCapacity': instance.storageCapacity,
      'ram': instance.ram,
      'genericName': instance.genericName,
      'activeIngredient': instance.activeIngredient,
      'strengthId': instance.strengthId,
      'dosageFormId': instance.dosageFormId,
      'manufacturerId': instance.manufacturerId,
      'marketingAuthHolderId': instance.marketingAuthHolderId,
      'storageConditionId': instance.storageConditionId,
      'apparelProductTypeId': instance.apparelProductTypeId,
      'fiberComposition': instance.fiberComposition,
      'genderId': instance.genderId,
      'ageGroupId': instance.ageGroupId,
      'isCategoryWiseStock': instance.isCategoryWiseStock,
      'isProductWiseStock': instance.isProductWiseStock,
      'isParentProduct': instance.isParentProduct,
      'isPacketOfPieces': instance.isPacketOfPieces,
      'packetSize': instance.packetSize,
      'isWeightBased': instance.isWeightBased,
      'weight': instance.weight,
      'marginPercentage': instance.marginPercentage,
      'retailPrice': instance.retailPrice,
      'distributorPrice': instance.distributorPrice,
      'specialPrice': instance.specialPrice,
      'discountedPrice': instance.discountedPrice,
      'stockInHand': instance.stockInHand,
      'minOrderQty': instance.minOrderQty,
      'isWholesaler': instance.isWholesaler,
      'isDistributor': instance.isDistributor,
      'isPharmacy': instance.isPharmacy,
      'isElectronics': instance.isElectronics,
      'isModelNumber': instance.isModelNumber,
      'isColorApplicable': instance.isColorApplicable,
      'isStorageCapacityApplicable': instance.isStorageCapacityApplicable,
      'storageCapacityId': instance.storageCapacityId,
      'isRamApplicable': instance.isRamApplicable,
      'ramId': instance.ramId,
      'isWarrantyApplicable': instance.isWarrantyApplicable,
      'warrantyMonths': instance.warrantyMonths,
      'warrantyPeriodsDays': instance.warrantyPeriodsDays,
      'warrantyProviderId': instance.warrantyProviderId,
      'isImeiRequired': instance.isImeiRequired,
      'requiresSerialTracking': instance.requiresSerialTracking,
      'isColorVariant': instance.isColorVariant,
      'colorVariantId': instance.colorVariantId,
      'isSizeVariant': instance.isSizeVariant,
      'sizeVariantId': instance.sizeVariantId,
      'sizeVariantIds': instance.sizeVariantIds,
      'isMedicine': instance.isMedicine,
      'isGenericNameApplicable': instance.isGenericNameApplicable,
      'isActiveIngredientApplicable': instance.isActiveIngredientApplicable,
      'isStrengthApplicable': instance.isStrengthApplicable,
      'isDosageFormApplicable': instance.isDosageFormApplicable,
      'isManufacturerApplicable': instance.isManufacturerApplicable,
      'isMarketingAuthHolderApplicable':
          instance.isMarketingAuthHolderApplicable,
      'isPrescriptionRequired': instance.isPrescriptionRequired,
      'controlledSubstanceSchedule': instance.controlledSubstanceSchedule,
      'requiresBatchTracking': instance.requiresBatchTracking,
      'isApparel': instance.isApparel,
      'isUnderwear': instance.isUnderwear,
      'isTaxExempt': instance.isTaxExempt,
      'isPointsApplicable': instance.isPointsApplicable,
      'pointsPerProduct': instance.pointsPerProduct,
      'isProductDisplayPosApp': instance.isProductDisplayPosApp,
      'isProductDisplayWebsiteApp': instance.isProductDisplayWebsiteApp,
      'isProductDisplayRackLabel': instance.isProductDisplayRackLabel,
      'isProductDisplayTag': instance.isProductDisplayTag,
      'isProductDisplayPriceTag': instance.isProductDisplayPriceTag,
      'isProductDisplayHangingTag': instance.isProductDisplayHangingTag,
      'isProductDisplayElectronicScale':
          instance.isProductDisplayElectronicScale,
      'isProductDisplayWeighingScale': instance.isProductDisplayWeighingScale,
      'isVerifiedByBuyer': instance.isVerifiedByBuyer,
      'isVerifiedBySupplier': instance.isVerifiedBySupplier,
      'isOffers': instance.isOffers,
      'returnDays': instance.returnDays,
      'exchangeDays': instance.exchangeDays,
      'promisedDeliveryDays': instance.promisedDeliveryDays,
      'isPaymentAvailableCod': instance.isPaymentAvailableCod,
      'isAcceleratedCheckoutAvailable': instance.isAcceleratedCheckoutAvailable,
      'isSubscriptionAvailable': instance.isSubscriptionAvailable,
      'isActive': instance.isActive,
      'units': instance.units,
      'branchInventory': instance.branchInventory,
      'images': instance.images,
    };

_$_ProductImageModel _$$_ProductImageModelFromJson(Map<String, dynamic> json) =>
    _$_ProductImageModel(
      id: json['id'] as String,
      productId: json['productId'] as String,
      colorId: json['colorId'] as String?,
      sizeId: json['sizeId'] as String?,
      imageUrl: json['imageUrl'] as String,
      isPrimary: json['isPrimary'] as bool? ?? false,
      displayOrder: json['displayOrder'] as int? ?? 0,
    );

Map<String, dynamic> _$$_ProductImageModelToJson(
        _$_ProductImageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'colorId': instance.colorId,
      'sizeId': instance.sizeId,
      'imageUrl': instance.imageUrl,
      'isPrimary': instance.isPrimary,
      'displayOrder': instance.displayOrder,
    };

_$_ProductUnitModel _$$_ProductUnitModelFromJson(Map<String, dynamic> json) =>
    _$_ProductUnitModel(
      id: json['id'] as String,
      productId: json['productId'] as String,
      unitCode: json['unitCode'] as String,
      conversionFactor: _toString(json['conversionFactor']),
      barcode: json['barcode'] as String?,
      price: _toStringNullable(json['price']),
    );

Map<String, dynamic> _$$_ProductUnitModelToJson(_$_ProductUnitModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'unitCode': instance.unitCode,
      'conversionFactor': instance.conversionFactor,
      'barcode': instance.barcode,
      'price': instance.price,
    };

_$_BranchInventoryModel _$$_BranchInventoryModelFromJson(
        Map<String, dynamic> json) =>
    _$_BranchInventoryModel(
      id: json['id'] as String,
      branchId: json['branchId'] as String,
      productId: json['productId'] as String,
      stockQuantity: json['stockQuantity'] as int,
      minStockLevel: json['minStockLevel'] as int,
      shelfLocation: json['shelfLocation'] as String?,
    );

Map<String, dynamic> _$$_BranchInventoryModelToJson(
        _$_BranchInventoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'branchId': instance.branchId,
      'productId': instance.productId,
      'stockQuantity': instance.stockQuantity,
      'minStockLevel': instance.minStockLevel,
      'shelfLocation': instance.shelfLocation,
    };
