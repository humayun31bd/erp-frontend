import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../../providers/pos_provider.dart';
import '../../providers/counter_session_provider.dart';
import '../widgets/counter_session_dialogs.dart';
import '../widgets/register_session_report_modal.dart';
import '../widgets/payment_modal.dart';
import '../widgets/product_selection_modal.dart';
import '../widgets/product_selection_helper.dart';
import '../widgets/customer_selection_modal.dart';
import '../widgets/receipt_view_modal.dart';
import '../widgets/refund_return_exchange_modal.dart';
import '../widgets/receipt_customization_modal.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../providers/offline_sync_service.dart';
import '../widgets/cash_drawer_modal.dart' as import_cash_drawer;
import '../widgets/pos_help_modal.dart';
import '../widgets/pos_cart_panel.dart';
import '../widgets/pos_product_grid_panel.dart';
import 'package:go_router/go_router.dart';
import '../../../../app.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/providers/tenant_settings_provider.dart';
import '../../../settings/domain/tenant_preset_models.dart';
import '../widgets/plan_guard_modal.dart';
class CheckoutIntent extends Intent {
  const CheckoutIntent();
}

class FocusSearchIntent extends Intent {
  const FocusSearchIntent();
}

class PosCashierScreen extends ConsumerStatefulWidget {
  const PosCashierScreen({super.key});

  @override
  ConsumerState<PosCashierScreen> createState() => _PosCashierScreenState();
}

class _PosCashierScreenState extends ConsumerState<PosCashierScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ValueNotifier<String> _searchQueryNotifier = ValueNotifier('');
  final ValueNotifier<String?> _selectedCategoryNotifier = ValueNotifier(null);
  String _barcodeBuffer = '';
  DateTime? _lastKeyPressTime;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchQueryNotifier.dispose();
    _selectedCategoryNotifier.dispose();
    super.dispose();
  }

  Future<void> _triggerCheckout(double cartTotal, List cart, var selectedCustomer) async {
    final result = await showPaymentModal(context, ref, cartTotal);
    if (result == null) return;
    final deliveryType = ref.read(posDeliveryTypeProvider);
    final deliveryDetails = ref.read(posDeliveryDetailsProvider);

    final checkoutResult = await ref.read(checkoutProvider.notifier).checkout(
      selectedCustomer?.name,
      result.lines.map((l) => l.method.name).join(', '),
      clientId: selectedCustomer?.id,
      buyerPhone: selectedCustomer?.phoneNumber,
      deliveryType: deliveryType,
      deliveryDetails: deliveryDetails,
    );
    
    if (!mounted) return;

    final checkoutState = ref.read(checkoutProvider);
    if (checkoutState.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checkout failed: ${checkoutState.error}'), backgroundColor: Colors.red),
      );
      return;
    }

    final orderNum = checkoutResult?['deliveryOrder']?['orderNumber'] as String? ??
                     checkoutResult?['invoiceNumber'] as String?;
    
    await showDialog(
      context: context,
      builder: (_) => ReceiptViewModal(
        cart: List.from(cart),
        cartTotal: cartTotal,
        customer: selectedCustomer,
        paymentResult: result,
        deliveryType: deliveryType,
        deliveryDetails: deliveryDetails,
        orderNumber: orderNum,
      ),
    );
    
    if (mounted) {
      ref.read(cartProvider.notifier).clearCart();
      ref.read(posDeliveryTypeProvider.notifier).state = PosDeliveryType.takeAway;
      ref.read(posDeliveryDetailsProvider.notifier).state = const PosDeliveryOrderDetails();
    }
  }

  void _handleFastSearch(String query) {
    if (query.trim().isEmpty) return;
    
    final productsState = ref.read(productsProvider);
    productsState.whenData((products) {
      final q = query.trim().toLowerCase();
      final raw = query.trim();
      final tenantSettings = ref.read(tenantSettingsProvider);

      // 1. Weighing Scale Barcode Auto-Parsing (EAN-13 Embedded Weight: prefix 20, 02, or 21)
      if (raw.length == 13 && (raw.startsWith('20') || raw.startsWith('02') || raw.startsWith('21'))) {
        final plu = raw.substring(2, 7);
        final weightGrams = double.tryParse(raw.substring(7, 12)) ?? 0.0;
        final weightKg = weightGrams / 1000.0;

        final scaleProduct = products.where((p) {
          final skuMatch = p.sku != null && (p.sku == plu || p.sku!.endsWith(plu) || p.sku!.contains(plu));
          final barcodeMatch = p.barcode != null && (p.barcode == plu || p.barcode!.startsWith(raw.substring(0, 7)));
          return (p.isWeightBased || tenantSettings.businessType == BusinessType.grocery) && (skuMatch || barcodeMatch);
        }).firstOrNull;

        if (scaleProduct != null) {
          ProductSelectionHelper.handleProductSelection(
            context,
            ref,
            scaleProduct,
            measuredWeightKg: weightKg > 0 ? weightKg : 1.0,
          );
          _searchController.clear();
          _searchQueryNotifier.value = '';
          _searchFocusNode.requestFocus();
          return;
        }
      }

      // 2. Standard Exact Barcode / SKU / Name match
      final exactMatches = products.where((p) => 
        p.name.toLowerCase() == q || 
        (p.barcode != null && p.barcode!.toLowerCase() == q) ||
        (p.sku != null && p.sku!.toLowerCase() == q)
      ).toList();

      if (exactMatches.length == 1) {
        ProductSelectionHelper.handleProductSelection(context, ref, exactMatches.first);
        _searchController.clear();
        _searchQueryNotifier.value = '';
        _searchFocusNode.requestFocus();
      } else {
        showDialog(
          context: context,
          builder: (ctx) => ProductSelectionModal(initialQuery: q),
        ).then((_) {
          _searchController.clear();
          _searchQueryNotifier.value = '';
          _searchFocusNode.requestFocus();
        });
      }
    });
  }

  // Removed individual _paymentButton — now handled by payment modal


  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final cartTotals = ref.watch(cartTotalsProvider);
    final discount = cartTotals.discountAmount;
    final cartTotal = cartTotals.grandTotal;
    
    final checkoutState = ref.watch(checkoutProvider);
    final sessionState = ref.watch(sessionControllerProvider);
    final selectedCustomer = ref.watch(selectedCustomerProvider);
    final l10n = AppLocalizations.of(context)!;

    final subtotal = cartTotals.subtotal;
    final vat = cartTotals.taxAmount;

    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        LogicalKeySet(LogicalKeyboardKey.f1): const FocusSearchIntent(),
        LogicalKeySet(LogicalKeyboardKey.f12): const CheckoutIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          FocusSearchIntent: CallbackAction<FocusSearchIntent>(
            onInvoke: (FocusSearchIntent intent) => _searchFocusNode.requestFocus(),
          ),
          CheckoutIntent: CallbackAction<CheckoutIntent>(
            onInvoke: (CheckoutIntent intent) {
              if (cart.isNotEmpty && !checkoutState.isLoading) {
                _triggerCheckout(cartTotal, cart, selectedCustomer);
              }
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          canRequestFocus: true,
          onKeyEvent: (FocusNode node, KeyEvent event) {
            if (event is KeyDownEvent) {
              if (_searchFocusNode.hasFocus) {
                return KeyEventResult.ignored;
              }

              final now = DateTime.now();
              if (_lastKeyPressTime != null && now.difference(_lastKeyPressTime!).inMilliseconds > 100) {
                _barcodeBuffer = '';
              }
              _lastKeyPressTime = now;

              if (event.logicalKey == LogicalKeyboardKey.enter) {
                if (_barcodeBuffer.length > 2) {
                  final scanned = _barcodeBuffer;
                  _barcodeBuffer = '';
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _handleFastSearch(scanned);
                  });
                  return KeyEventResult.handled;
                }
                _barcodeBuffer = '';
              } else if (event.character != null) {
                _barcodeBuffer += event.character!;
              }
            }
            return KeyEventResult.ignored;
          },
          child: Scaffold(
          appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Icon(Icons.point_of_sale, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(l10n.posTerminal, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            const Spacer(),
            
            // Unified Action Bar
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildActionChip(
                        label: ref.watch(localeProvider).languageCode == 'ar' ? 'English (EN)' : 'العربية (AR)',
                        icon: Icons.language_rounded,
                        color: Colors.indigo,
                        onTap: () {
                          final isAr = ref.read(localeProvider).languageCode == 'ar';
                          ref.read(localeProvider.notifier).state =
                              isAr ? const Locale('en') : const Locale('ar');
                        },
                      ),
                      _buildActionChip(
                        label: sessionState.value != null
                            ? (ref.watch(localeProvider).languageCode == 'ar' ? 'وردية مفتوحة (OPEN)' : 'Session: OPEN')
                            : (ref.watch(localeProvider).languageCode == 'ar' ? 'وردية مغلقة (CLOSED)' : 'Session: CLOSED'),
                        icon: sessionState.value != null ? Icons.lock_open_rounded : Icons.lock_clock_rounded,
                        color: sessionState.value != null ? Colors.green : Colors.red,
                        onTap: () {
                          if (sessionState.value != null) {
                            showRegisterSessionReportModal(context, session: sessionState.value);
                          } else {
                            showCounterSessionManager(context);
                          }
                        },
                      ),
                      _buildActionChip(
                        label: ref.watch(localeProvider).languageCode == 'ar' ? 'المرتجعات' : 'Returns',
                        icon: Icons.assignment_return,
                        color: Colors.orange,
                        onTap: () => showDialog(context: context, builder: (_) => const RefundReturnExchangeModal()),
                      ),
                      _buildActionChip(
                        label: ref.watch(localeProvider).languageCode == 'ar' ? 'الصندوق' : 'Drawer',
                        icon: Icons.account_balance_wallet,
                        color: Colors.blue,
                        onTap: () => showDialog(context: context, builder: (_) => const import_cash_drawer.CashDrawerModal()),
                      ),
                      _buildActionChip(
                        label: ref.watch(localeProvider).languageCode == 'ar' ? 'المطبخ (KDS)' : 'Kitchen (KDS)',
                        icon: Icons.soup_kitchen_rounded,
                        color: Colors.deepPurple,
                        onTap: () {
                          final tenantSettings = ref.read(tenantSettingsProvider);
                          if (!tenantSettings.isFeatureEnabled('kds')) {
                            PlanGuardModal.show(
                              context,
                              featureKey: 'kds',
                              featureName: 'Kitchen Display System (KDS)',
                              requiredPlan: 'Pro',
                              customDescription: tenantSettings.businessType != BusinessType.restaurant
                                  ? 'Kitchen Display System is designed for Restaurant & Food Service operations. Switch your business type in Settings or upgrade your subscription.'
                                  : 'Real-time kitchen order dispatch and multi-station KDS requires the Pro or Enterprise tier.',
                            );
                            return;
                          }
                          context.goNamed(RouteNames.ordersDelivery);
                        },
                      ),
                      _buildActionChip(
                        label: ref.watch(localeProvider).languageCode == 'ar' ? 'الإعدادات' : 'Settings',
                        icon: Icons.settings,
                        color: Colors.grey,
                        onTap: () {
                          final tenantSettings = ref.read(tenantSettingsProvider);
                          if (!tenantSettings.isFeatureEnabled('receiptCustomization')) {
                            PlanGuardModal.show(
                              context,
                              featureKey: 'receiptCustomization',
                              featureName: 'Receipt Template Designer & Custom Branding',
                              requiredPlan: 'Pro',
                              customDescription: 'Custom header banners, social links, promotional footers, and custom fonts on tax receipts require the Pro or Enterprise plan.',
                            );
                            return;
                          }
                          showDialog(context: context, builder: (_) => const ReceiptCustomizationModal());
                        },
                      ),
                      _buildActionChip(
                        label: ref.watch(localeProvider).languageCode == 'ar' ? 'مساعدة' : 'Help',
                        icon: Icons.help_outline,
                        color: Colors.green,
                        onTap: () => showDialog(context: context, builder: (_) => const PosHelpModal()),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            Consumer(
              builder: (context, ref, child) {
                final pendingCountAsync = ref.watch(offlineCheckoutsCountProvider);
                final pendingCount = pendingCountAsync.value ?? 0;
                final isOffline = pendingCount > 0;
                
                return InkWell(
                  onTap: isOffline ? () {
                    ref.read(checkoutProvider.notifier).syncOfflineCheckouts();
                  } : null,
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isOffline 
                            ? [Colors.orange[400]!, Colors.orange[600]!]
                            : [Colors.green[400]!, Colors.green[600]!],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (isOffline ? Colors.orange : Colors.green).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(isOffline ? Icons.cloud_off : Icons.cloud_done, color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          isOffline ? 'Sync ($pendingCount)' : 'Online',
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: sessionState.value == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('Session Closed', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('You must open a session before using the POS Terminal.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => showCounterSessionManager(context),
                    icon: const Icon(Icons.point_of_sale),
                    label: const Text('Open Session'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                  ),
                ],
              ),
            )
          : Row(
        children: [
          // LEFT PANEL: Customer, Cart, Totals, Payments
          SizedBox(
            width: 400,
            child: PosCartPanel(
              cart: cart,
              cartTotal: cartTotal,
              subtotal: subtotal,
              vat: vat,
              discount: discount,
              selectedCustomer: selectedCustomer,
              isCheckoutLoading: checkoutState.isLoading,
              onCustomerTap: () => showDialog(context: context, builder: (_) => const CustomerSelectionModal()),
              onClearCustomerTap: () => ref.read(selectedCustomerProvider.notifier).state = null,
              onDiscountTap: () => _showDiscountDialog(context, ref),
              onHoldTap: () async {
                if (cart.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cannot hold an empty cart. Please add products first.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                final discount = ref.read(cartDiscountProvider);
                final deliveryType = ref.read(posDeliveryTypeProvider);
                final success = await ref.read(heldCartsProvider.notifier).holdCart(
                  cart, 
                  selectedCustomer, 
                  discount, 
                  cartTotal,
                  deliveryType: deliveryType,
                );
                if (success) {
                  ref.read(cartProvider.notifier).clearCart();
                  ref.read(selectedCustomerProvider.notifier).state = null;
                  ref.read(cartDiscountProvider.notifier).clearDiscount();
                  ref.read(posDeliveryTypeProvider.notifier).state = PosDeliveryType.takeAway;
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cart held successfully.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to hold cart. Please try again.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              onClearCartTap: () {
                ref.read(cartProvider.notifier).clearCart();
                ref.read(cartDiscountProvider.notifier).clearDiscount();
                ref.read(posDeliveryTypeProvider.notifier).state = PosDeliveryType.takeAway;
                ref.read(posDeliveryDetailsProvider.notifier).state = const PosDeliveryOrderDetails();
              },
              onCheckoutTap: () => _triggerCheckout(cartTotal, cart, selectedCustomer),
              onUpdateQuantity: (id, quantity, {unit}) => ref.read(cartProvider.notifier).updateQuantity(id, quantity, unit: unit),
              onRemoveProduct: (id, {unit}) => ref.read(cartProvider.notifier).removeProduct(id, unit: unit),
            ),
          ),
          
          // RIGHT PANEL: Search, Product Grid, and Actions
          Expanded(
            child: PosProductGridPanel(
              searchController: _searchController,
              searchFocusNode: _searchFocusNode,
              searchQueryNotifier: _searchQueryNotifier,
              selectedCategoryNotifier: _selectedCategoryNotifier,
              onSearchSubmitted: _handleFastSearch,
              onSearchChanged: (val) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 300), () {
                  _searchQueryNotifier.value = val.toLowerCase();
                });
              },
              onHeldCartsTap: _showHeldCartsDialog,
            ),
          ),
        ],
      ),
    ),
    ),
    ),
    );
  }

  void _showHeldCartsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final heldCartsState = ref.watch(heldCartsProvider);
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Container(
                width: 600,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Held Carts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    heldCartsState.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, st) => Center(child: Text('Error: $err')),
                      data: (heldCarts) {
                        if (heldCarts.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text('No held carts.'),
                          );
                        }
                        return Flexible(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: heldCarts.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final hc = heldCarts[index];
                              final totalItems = hc.items.fold<int>(0, (sum, i) => sum + i.quantity);
                              final itemNames = hc.items.map((i) => '${i.quantity}x ${i.product.name}').join(', ');
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      hc.customer?.name ?? 'Walk-in Customer',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'SAR ${(hc.totalAmount > 0 ? hc.totalAmount : hc.items.fold<double>(0, (sum, i) => sum + (i.effectivePrice * i.quantity))).toStringAsFixed(2)}',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: Colors.blue.shade200),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(hc.deliveryType.icon, size: 11, color: Colors.blue.shade800),
                                              const SizedBox(width: 3),
                                              Text(
                                                hc.deliveryType.label,
                                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '$totalItems items • Held at ${hc.heldAt.hour.toString().padLeft(2, '0')}:${hc.heldAt.minute.toString().padLeft(2, '0')}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    if (itemNames.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        itemNames,
                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.play_arrow, size: 16),
                                      label: const Text('Recall'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade600,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                      onPressed: () async {
                                        final activeCart = ref.read(cartProvider);
                                        if (activeCart.isNotEmpty) {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (c) => AlertDialog(
                                              title: const Text('Replace Active Cart?'),
                                              content: const Text('The current active cart contains items. Recalling this held cart will overwrite the current cart. Do you want to continue?'),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                                  onPressed: () => Navigator.pop(c, true),
                                                  child: const Text('Replace Cart'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm != true) return;
                                        }

                                        // Restore Cart Items, Customer, Discount, and Delivery Type
                                        ref.read(cartProvider.notifier).setCart(hc.items);
                                        ref.read(selectedCustomerProvider.notifier).state = hc.customer;
                                        ref.read(cartDiscountProvider.notifier).setDiscount(hc.discount);
                                        ref.read(posDeliveryTypeProvider.notifier).state = hc.deliveryType;

                                        // Delete from backend held carts
                                        await ref.read(heldCartsProvider.notifier).deleteHeldCart(hc.id);

                                        if (context.mounted) {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Cart recalled: $totalItems item(s) restored.'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                      tooltip: 'Delete Held Cart',
                                      onPressed: () async {
                                        await ref.read(heldCartsProvider.notifier).deleteHeldCart(hc.id);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      }, // Close data function
                    ), // Close when
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDiscountDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: ref.read(cartDiscountProvider).toStringAsFixed(2));
    final isAr = ref.read(localeProvider).languageCode == 'ar';
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(isAr ? 'خصم الفاتورة' : 'Cart Discount'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: isAr ? 'مبلغ الخصم (ريال)' : 'Discount Amount (SAR)',
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isAr ? 'إلغاء' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final val = double.tryParse(controller.text) ?? 0.0;
                ref.read(cartDiscountProvider.notifier).setDiscount(val);
                Navigator.pop(ctx);
              },
              child: Text(isAr ? 'تطبيق' : 'Apply'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionChip({required String label, required IconData icon, required MaterialColor color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.shade50,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.shade200.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color.shade700, size: 16),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color.shade800, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
