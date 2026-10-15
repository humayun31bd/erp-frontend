import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

String _toString(dynamic val) => val?.toString() ?? '0.0';
String? _toStringNullable(dynamic val) => val?.toString();

List<String> _toStringList(dynamic val) {
  if (val == null) return const [];
  if (val is List) return val.map((e) => e.toString()).toList();
  if (val is String) {
    if (val.trim().isEmpty || val == '[]') return const [];
    try {
      final decoded = json.decode(val);
      if (decoded is List) return decoded.map((e) => e.toString()).toList();
    } catch (_) {}
  }
  return const [];
}

List<ProductUnitModel> _toUnitsList(dynamic val) {
  if (val == null) return const [];
  if (val is List) {
    return val.map((e) {
      if (e is ProductUnitModel) return e;
      if (e is Map<String, dynamic>) return ProductUnitModel.fromJson(e);
      if (e is Map) return ProductUnitModel.fromJson(Map<String, dynamic>.from(e));
      return null;
    }).whereType<ProductUnitModel>().toList();
  }
  if (val is String) {
    if (val.trim().isEmpty || val == '[]') return const [];
    try {
      final decoded = json.decode(val);
      if (decoded is List) {
        return decoded.map((e) {
          if (e is Map<String, dynamic>) return ProductUnitModel.fromJson(e);
          if (e is Map) return ProductUnitModel.fromJson(Map<String, dynamic>.from(e));
          return null;
        }).whereType<ProductUnitModel>().toList();
      }
    } catch (_) {}
  }
  return const [];
}

List<BranchInventoryModel> _toBranchInventoryList(dynamic val) {
  if (val == null) return const [];
  if (val is List) {
    return val.map((e) {
      if (e is BranchInventoryModel) return e;
      if (e is Map<String, dynamic>) return BranchInventoryModel.fromJson(e);
      if (e is Map) return BranchInventoryModel.fromJson(Map<String, dynamic>.from(e));
      return null;
    }).whereType<BranchInventoryModel>().toList();
  }
  if (val is String) {
    if (val.trim().isEmpty || val == '[]') return const [];
    try {
      final decoded = json.decode(val);
      if (decoded is List) {
        return decoded.map((e) {
          if (e is Map<String, dynamic>) return BranchInventoryModel.fromJson(e);
          if (e is Map) return BranchInventoryModel.fromJson(Map<String, dynamic>.from(e));
          return null;
        }).whereType<BranchInventoryModel>().toList();
      }
    } catch (_) {}
  }
  return const [];
}

List<ProductImageModel> _toImagesList(dynamic val) {
  if (val == null) return const [];
  if (val is List) {
    return val.map((e) {
      if (e is ProductImageModel) return e;
      if (e is Map<String, dynamic>) return ProductImageModel.fromJson(e);
      if (e is Map) return ProductImageModel.fromJson(Map<String, dynamic>.from(e));
      return null;
    }).whereType<ProductImageModel>().toList();
  }
  if (val is String) {
    if (val.trim().isEmpty || val == '[]') return const [];
    try {
      final decoded = json.decode(val);
      if (decoded is List) {
        return decoded.map((e) {
          if (e is Map<String, dynamic>) return ProductImageModel.fromJson(e);
          if (e is Map) return ProductImageModel.fromJson(Map<String, dynamic>.from(e));
          return null;
        }).whereType<ProductImageModel>().toList();
      }
    } catch (_) {}
  }
  return const [];
}

int _toInt(dynamic val) {
  if (val == null) return 0;
  if (val is int) return val;
  if (val is double) return val.toInt();
  if (val is num) return val.toInt();
  return int.tryParse(val.toString()) ?? (double.tryParse(val.toString())?.toInt() ?? 0);
}

int _toIntDefaultFive(dynamic val) {
  if (val == null) return 5;
  if (val is int) return val;
  if (val is double) return val.toInt();
  if (val is num) return val.toInt();
  return int.tryParse(val.toString()) ?? (double.tryParse(val.toString())?.toInt() ?? 5);
}

@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    String? categoryId,
    @JsonKey(name: 'sku') String? sku,
    @JsonKey(name: 'productName') required String name,
    String? barcode,
    String? description,
    @JsonKey(name: 'baseSellingPrice', fromJson: _toString) required String price,
    @JsonKey(fromJson: _toStringNullable) String? costPrice,
    @Default('0') @JsonKey(fromJson: _toString) String discountAmount,
    @Default(0) @JsonKey(fromJson: _toInt) int stockQuantity,
    @Default(5) @JsonKey(fromJson: _toIntDefaultFive) int minStockLevel,
    String? parentProductId,
    String? brandId,
    String? productTypeId,
    String? unitId,
    String? sizeId,
    String? colorId,
    String? taxCategoryId,
    String? modelNumber,
    String? storageCapacity,
    String? ram,
    String? genericName,
    String? activeIngredient,
    String? strengthId,
    String? dosageFormId,
    String? manufacturerId,
    String? marketingAuthHolderId,
    String? storageConditionId,
    String? apparelProductTypeId,
    String? fiberComposition,
    String? genderId,
    String? ageGroupId,
    @Default(false) bool isCategoryWiseStock,
    @Default(false) bool isProductWiseStock,
    @Default(false) bool isParentProduct,
    @Default(false) bool isPacketOfPieces,
    @Default(1) int packetSize,
    @Default(false) bool isWeightBased,
    @Default(1.0) double weight,
    @Default(20.0) double marginPercentage,
    @JsonKey(fromJson: _toStringNullable) String? retailPrice,
    @JsonKey(fromJson: _toStringNullable) String? distributorPrice,
    @JsonKey(fromJson: _toStringNullable) String? specialPrice,
    @JsonKey(fromJson: _toStringNullable) String? discountedPrice,
    @Default(0) int stockInHand,
    @Default(0) int minOrderQty,
    @Default(false) bool isWholesaler,
    @Default(false) bool isDistributor,
    @Default(false) bool isPharmacy,
    @Default(false) bool isElectronics,
    @Default(false) bool isModelNumber,
    @Default(false) bool isColorApplicable,
    @Default(false) bool isStorageCapacityApplicable,
    String? storageCapacityId,
    @Default(false) bool isRamApplicable,
    String? ramId,
    @Default(false) bool isWarrantyApplicable,
    @Default(0) int warrantyMonths,
    @Default(0) int warrantyPeriodsDays,
    String? warrantyProviderId,
    @Default(false) bool isImeiRequired,
    @Default(false) bool requiresSerialTracking,
    @Default(false) bool isColorVariant,
    String? colorVariantId,
    @Default(false) bool isSizeVariant,
    String? sizeVariantId,
    @Default([]) @JsonKey(fromJson: _toStringList) List<String> sizeVariantIds,
    @Default(false) bool isMedicine,
    @Default(false) bool isGenericNameApplicable,
    @Default(false) bool isActiveIngredientApplicable,
    @Default(false) bool isStrengthApplicable,
    @Default(false) bool isDosageFormApplicable,
    @Default(false) bool isManufacturerApplicable,
    @Default(false) bool isMarketingAuthHolderApplicable,
    @Default(false) bool isPrescriptionRequired,
    String? controlledSubstanceSchedule,
    @Default(false) bool requiresBatchTracking,
    @Default(false) bool isApparel,
    @Default(false) bool isUnderwear,
    @Default(false) bool isTaxExempt,
    @Default(false) bool isPointsApplicable,
    @Default(0) int pointsPerProduct,
    @Default(true) bool isProductDisplayPosApp,
    @Default(false) bool isProductDisplayWebsiteApp,
    @Default(false) bool isProductDisplayRackLabel,
    @Default(false) bool isProductDisplayTag,
    @Default(false) bool isProductDisplayPriceTag,
    @Default(false) bool isProductDisplayHangingTag,
    @Default(false) bool isProductDisplayElectronicScale,
    @Default(false) bool isProductDisplayWeighingScale,
    @Default(false) bool isVerifiedByBuyer,
    @Default(false) bool isVerifiedBySupplier,
    @Default(false) bool isOffers,
    @Default(7) int returnDays,
    @Default(30) int exchangeDays,
    @Default(2) int promisedDeliveryDays,
    @Default(true) bool isPaymentAvailableCod,
    @Default(false) bool isAcceleratedCheckoutAvailable,
    @Default(false) bool isSubscriptionAvailable,
    @Default(true) bool isActive,
    @Default([]) @JsonKey(fromJson: _toUnitsList) List<ProductUnitModel> units,
    @Default([]) @JsonKey(fromJson: _toBranchInventoryList) List<BranchInventoryModel> branchInventory,
    @Default([]) @JsonKey(fromJson: _toImagesList) List<ProductImageModel> images,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);
}

@freezed
class ProductImageModel with _$ProductImageModel {
  const factory ProductImageModel({
    required String id,
    required String productId,
    String? colorId,
    String? sizeId,
    required String imageUrl,
    @Default(false) bool isPrimary,
    @Default(0) int displayOrder,
  }) = _ProductImageModel;

  factory ProductImageModel.fromJson(Map<String, dynamic> json) => _$ProductImageModelFromJson(json);
}

@freezed
class ProductUnitModel with _$ProductUnitModel {
  const factory ProductUnitModel({
    required String id,
    required String productId,
    required String unitCode,
    @JsonKey(fromJson: _toString) required String conversionFactor,
    String? barcode,
    @JsonKey(fromJson: _toStringNullable) String? price,
  }) = _ProductUnitModel;

  factory ProductUnitModel.fromJson(Map<String, dynamic> json) => _$ProductUnitModelFromJson(json);
}

@freezed
class BranchInventoryModel with _$BranchInventoryModel {
  const factory BranchInventoryModel({
    required String id,
    required String branchId,
    required String productId,
    required int stockQuantity,
    required int minStockLevel,
    String? shelfLocation,
  }) = _BranchInventoryModel;

  factory BranchInventoryModel.fromJson(Map<String, dynamic> json) => _$BranchInventoryModelFromJson(json);
}

