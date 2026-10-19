import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductFeaturesState {
  final bool enableVariableProduct;
  final bool enableStockManagement;
  final bool enableBranches;
  final bool enableCategories;
  final bool enableSubCategories; // Added for sub-categories
  final bool enableUnits;
  final bool enableTaxRates;
  final bool enableGroupTax;
  final bool enableLowStockAlert;
  final bool enableProductExpiry;
  final bool enableLowStockExpiryAlert;
  final bool enableImeiSerial;
  final bool enableLotNumber;
  final bool enableBarcodePrinting;
  final bool enableSellingPriceGroup;

  ProductFeaturesState({
    this.enableVariableProduct = true,
    this.enableStockManagement = true,
    this.enableBranches = true,
    this.enableCategories = true,
    this.enableSubCategories = true,
    this.enableUnits = true,
    this.enableTaxRates = true,
    this.enableGroupTax = false,
    this.enableLowStockAlert = true,
    this.enableProductExpiry = false,
    this.enableLowStockExpiryAlert = false,
    this.enableImeiSerial = false,
    this.enableLotNumber = false,
    this.enableBarcodePrinting = true,
    this.enableSellingPriceGroup = false,
  });

  ProductFeaturesState copyWith({
    bool? enableVariableProduct,
    bool? enableStockManagement,
    bool? enableBranches,
    bool? enableCategories,
    bool? enableSubCategories,
    bool? enableUnits,
    bool? enableTaxRates,
    bool? enableGroupTax,
    bool? enableLowStockAlert,
    bool? enableProductExpiry,
    bool? enableLowStockExpiryAlert,
    bool? enableImeiSerial,
    bool? enableLotNumber,
    bool? enableBarcodePrinting,
    bool? enableSellingPriceGroup,
  }) {
    return ProductFeaturesState(
      enableVariableProduct: enableVariableProduct ?? this.enableVariableProduct,
      enableStockManagement: enableStockManagement ?? this.enableStockManagement,
      enableBranches: enableBranches ?? this.enableBranches,
      enableCategories: enableCategories ?? this.enableCategories,
      enableSubCategories: enableSubCategories ?? this.enableSubCategories,
      enableUnits: enableUnits ?? this.enableUnits,
      enableTaxRates: enableTaxRates ?? this.enableTaxRates,
      enableGroupTax: enableGroupTax ?? this.enableGroupTax,
      enableLowStockAlert: enableLowStockAlert ?? this.enableLowStockAlert,
      enableProductExpiry: enableProductExpiry ?? this.enableProductExpiry,
      enableLowStockExpiryAlert: enableLowStockExpiryAlert ?? this.enableLowStockExpiryAlert,
      enableImeiSerial: enableImeiSerial ?? this.enableImeiSerial,
      enableLotNumber: enableLotNumber ?? this.enableLotNumber,
      enableBarcodePrinting: enableBarcodePrinting ?? this.enableBarcodePrinting,
      enableSellingPriceGroup: enableSellingPriceGroup ?? this.enableSellingPriceGroup,
    );
  }
}

class ProductFeaturesNotifier extends StateNotifier<ProductFeaturesState> {
  ProductFeaturesNotifier() : super(ProductFeaturesState());

  void updateState(ProductFeaturesState newState) {
    state = newState;
  }
}

final productFeaturesProvider = StateNotifierProvider<ProductFeaturesNotifier, ProductFeaturesState>((ref) {
  return ProductFeaturesNotifier();
});
