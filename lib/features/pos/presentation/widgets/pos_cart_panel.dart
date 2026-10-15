import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/pos_provider.dart';
import '../../../clients/domain/client_model.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../domain/product_model.dart';
import 'delivery_details_modal.dart';
import 'plan_guard_modal.dart';
import '../../../../core/providers/tenant_settings_provider.dart';
import '../../../settings/domain/tenant_preset_models.dart';

class PosCartPanel extends ConsumerWidget {
  final List<CartItem> cart;
  final double cartTotal;
  final double subtotal;
  final double vat;
  final double discount;
  final ClientModel? selectedCustomer;
  final bool isCheckoutLoading;
  final VoidCallback onCustomerTap;
  final VoidCallback onClearCustomerTap;
  final VoidCallback onDiscountTap;
  final VoidCallback onHoldTap;
  final VoidCallback onClearCartTap;
  final VoidCallback onCheckoutTap;
  final void Function(String, int, {ProductUnitModel? unit}) onUpdateQuantity;
  final void Function(String, {ProductUnitModel? unit}) onRemoveProduct;

  const PosCartPanel({
    super.key,
    required this.cart,
    required this.cartTotal,
    required this.subtotal,
    required this.vat,
    required this.discount,
    required this.selectedCustomer,
    required this.isCheckoutLoading,
    required this.onCustomerTap,
    required this.onClearCustomerTap,
    required this.onDiscountTap,
    required this.onHoldTap,
    required this.onClearCartTap,
    required this.onCheckoutTap,
    required this.onUpdateQuantity,
    required this.onRemoveProduct,
  });

  void _handleRemoveItem(BuildContext context, WidgetRef ref, CartItem item) {
    onRemoveProduct(item.product.id, unit: item.selectedUnit);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.delete_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text('Removed "${item.product.name}"')),
          ],
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.grey.shade900,
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.amberAccent,
          onPressed: () {
            ref.read(cartProvider.notifier).addProduct(item.product, unit: item.selectedUnit);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final tenantSettings = ref.watch(tenantSettingsProvider);
    final totalUnits = cart.fold<int>(0, (sum, item) => sum + item.quantity);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          // 1. COMPACT CUSTOMER BAR
          InkWell(
            onTap: onCustomerTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: selectedCustomer != null ? Colors.blue.shade50.withValues(alpha: 0.5) : Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: selectedCustomer != null ? Colors.blue.shade600 : Colors.grey.shade200,
                    child: Icon(
                      Icons.person,
                      color: selectedCustomer != null ? Colors.white : Colors.grey.shade600,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          selectedCustomer?.name ?? 'Walk-in Customer',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: selectedCustomer != null ? Colors.blue.shade900 : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          selectedCustomer != null
                              ? (selectedCustomer!.phoneNumber ?? 'Tap to view details')
                              : 'Tap to assign customer',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (selectedCustomer != null)
                    InkWell(
                      onTap: onClearCustomerTap,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(Icons.close, size: 16, color: Colors.grey.shade600),
                      ),
                    )
                  else
                    Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade400),
                ],
              ),
            ),
          ),

          // 1.5 DELIVERY / ORDER TYPE SELECTOR (Take Away / Delivery / Dine In)
          _buildDeliveryTypeSelector(context, ref),

          // 1.6 DINE IN / DELIVERY DETAILS BANNER (Table / Address / Aggregator)
          _buildDeliveryDetailsBanner(context, ref),

          // 2. COMPACT TOOLBAR & ITEMS COUNT
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                // Item & Unit Count Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    '${cart.length} items • $totalUnits pcs',
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (cart.isNotEmpty) ...[
                  // Discount Pill
                  _buildCompactPill(
                    icon: Icons.percent,
                    label: discount > 0 ? '-${discount.toStringAsFixed(0)}' : 'Discount',
                    color: discount > 0 ? Colors.green : Colors.blue,
                    onTap: onDiscountTap,
                  ),
                  const SizedBox(width: 6),
                  // Hold Pill (Plan Guarded)
                  _buildCompactPill(
                    icon: tenantSettings.isFeatureEnabled('holdCart') ? Icons.pause_circle_outline : Icons.lock_outline,
                    label: tenantSettings.isFeatureEnabled('holdCart') ? 'Hold' : 'Hold 🔒',
                    color: Colors.orange,
                    onTap: () {
                      if (!tenantSettings.isFeatureEnabled('holdCart')) {
                        PlanGuardModal.show(
                          context,
                          featureKey: 'holdCart',
                          featureName: 'Order Holding & Multi-Cart Parking',
                          requiredPlan: 'Standard',
                        );
                        return;
                      }
                      onHoldTap();
                    },
                  ),
                  const SizedBox(width: 6),
                  // Clear Pill
                  _buildCompactPill(
                    icon: Icons.delete_sweep_outlined,
                    label: 'Clear',
                    color: Colors.red,
                    onTap: onClearCartTap,
                  ),
                ],
              ],
            ),
          ),

          // 3. COMPACT CART ITEMS LIST (SORTED DESCENDING)
          Expanded(
            child: cart.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            l10n.cartIsEmpty,
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Click products on the right to add',
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    itemCount: cart.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      final price = item.effectivePrice;
                      final lineTotal = price * item.quantity;
                      final itemKey = '${item.product.id}_${item.selectedUnit?.id ?? ''}';

                      return Dismissible(
                        key: ValueKey(itemKey),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.delete_outline, color: Colors.white, size: 20),
                              SizedBox(width: 4),
                              Text('Remove', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ),
                        onDismissed: (_) {
                          _handleRemoveItem(context, ref, item);
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Top Row: Product Name + Line Total
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.product.name,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, height: 1.2),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    tenantSettings.formatCurrency(lineTotal),
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                                  ),
                                  const SizedBox(width: 6),
                                  Tooltip(
                                    message: 'Remove item',
                                    child: InkWell(
                                      onTap: () => _handleRemoveItem(context, ref, item),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Icon(
                                          Icons.cancel_outlined,
                                          size: 16,
                                          color: Colors.red.shade400,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if ((item.batchNumber != null || item.product.requiresBatchTracking) ||
                                  item.expiryDate != null ||
                                  item.product.isPrescriptionRequired ||
                                  (item.measuredWeightKg != null || item.product.isWeightBased) ||
                                  (item.modifiers != null && item.modifiers!.isNotEmpty) ||
                                  (item.assignedStaff != null && item.assignedStaff!.isNotEmpty)) ...[
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 2,
                                  children: [
                                    if (item.batchNumber != null || item.product.requiresBatchTracking)
                                      _buildMetaBadge(
                                        icon: Icons.qr_code_2,
                                        text: 'Lot #${item.batchNumber ?? 'AUTO'}',
                                        bgColor: Colors.teal.shade50,
                                        textColor: Colors.teal.shade800,
                                        borderColor: Colors.teal.shade200,
                                      ),
                                    if (item.expiryDate != null)
                                      _buildMetaBadge(
                                        icon: Icons.event_outlined,
                                        text: 'Exp: ${item.expiryDate}',
                                        bgColor: Colors.amber.shade50,
                                        textColor: Colors.amber.shade900,
                                        borderColor: Colors.amber.shade300,
                                      ),
                                    if (item.product.isPrescriptionRequired)
                                      _buildMetaBadge(
                                        icon: Icons.medical_services_outlined,
                                        text: 'Rx Required',
                                        bgColor: Colors.red.shade50,
                                        textColor: Colors.red.shade800,
                                        borderColor: Colors.red.shade200,
                                      ),
                                    if (item.measuredWeightKg != null || item.product.isWeightBased)
                                      _buildMetaBadge(
                                        icon: Icons.scale_outlined,
                                        text: '${(item.measuredWeightKg ?? (item.product.weight > 0 ? item.product.weight : 1.0)).toStringAsFixed(3)} kg',
                                        bgColor: Colors.green.shade50,
                                        textColor: Colors.green.shade800,
                                        borderColor: Colors.green.shade200,
                                      ),
                                    if (item.modifiers != null && item.modifiers!.isNotEmpty)
                                      _buildMetaBadge(
                                        icon: Icons.room_service_outlined,
                                        text: item.modifiers!,
                                        bgColor: Colors.orange.shade50,
                                        textColor: Colors.orange.shade900,
                                        borderColor: Colors.orange.shade200,
                                      ),
                                    if (item.assignedStaff != null && item.assignedStaff!.isNotEmpty)
                                      _buildMetaBadge(
                                        icon: Icons.face_retouching_natural,
                                        text: 'Staff: ${item.assignedStaff!}',
                                        bgColor: Colors.purple.shade50,
                                        textColor: Colors.purple.shade800,
                                        borderColor: Colors.purple.shade200,
                                      ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 5),

                              // Bottom Row: Unit Price + Badges | Stepper + Delete Button
                              Row(
                                children: [
                                  Text(
                                    '@ ${tenantSettings.formatCurrency(price)}',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                                  ),
                                  if (item.selectedUnit != null) ...[
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        item.selectedUnit!.unitCode,
                                        style: TextStyle(color: Colors.blue.shade700, fontSize: 9, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                  if (item.product.stockQuantity <= 0) ...[
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Out',
                                        style: TextStyle(color: Colors.red.shade700, fontSize: 9, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ] else if (item.quantity > item.product.stockQuantity) ...[
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Exceeds',
                                        style: TextStyle(color: Colors.orange.shade800, fontSize: 9, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                  const Spacer(),

                                  // Compact Stepper [- QTY +]
                                  Container(
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Minus or Trash at Qty 1
                                        InkWell(
                                          onTap: () {
                                            if (item.quantity == 1) {
                                              _handleRemoveItem(context, ref, item);
                                            } else {
                                              onUpdateQuantity(item.product.id, item.quantity - 1, unit: item.selectedUnit);
                                            }
                                          },
                                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(5)),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                            child: Icon(
                                              item.quantity == 1 ? Icons.delete_outline_rounded : Icons.remove,
                                              size: 13,
                                              color: item.quantity == 1 ? Colors.red.shade700 : Colors.black87,
                                            ),
                                          ),
                                        ),
                                        // Quantity Display
                                        Container(
                                          constraints: const BoxConstraints(minWidth: 24),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${item.quantity}',
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        // Plus
                                        InkWell(
                                          onTap: () => onUpdateQuantity(item.product.id, item.quantity + 1, unit: item.selectedUnit),
                                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(5)),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                            child: Icon(Icons.add, size: 13, color: Colors.black87),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),

                                  // Dedicated 1-Click Remove Button
                                  Tooltip(
                                    message: 'Remove item',
                                    child: InkWell(
                                      onTap: () => _handleRemoveItem(context, ref, item),
                                      borderRadius: BorderRadius.circular(6),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: Colors.red.shade200),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.delete_outline_rounded,
                                              size: 14,
                                              color: Colors.red.shade700,
                                            ),
                                            const SizedBox(width: 3),
                                            Text(
                                              'Remove',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // 4. COMPACT TOTALS & PAY BUTTON
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Subtotal & VAT (Single line or clean 2-line)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Subtotal: ${tenantSettings.formatCurrency(subtotal)}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    Text('${tenantSettings.taxType} (${tenantSettings.taxRate.toStringAsFixed(0)}%): ${tenantSettings.formatCurrency(vat)}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
                if (discount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Discount:', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                        Text('- ${tenantSettings.formatCurrency(discount)}', style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                const SizedBox(height: 6),
                const Divider(height: 1),
                const SizedBox(height: 6),

                // Grand Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                    Text(
                      tenantSettings.formatCurrency(cartTotal),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Restaurant Kitchen Order Ticket (KOT) Button
                if (tenantSettings.businessType == BusinessType.restaurant) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: OutlinedButton.icon(
                      onPressed: cart.isEmpty
                          ? null
                          : () {
                              final tableNo = ref.read(posDeliveryDetailsProvider).tableNumber;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.soup_kitchen, color: Colors.white, size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'KOT sent to kitchen for ${tableNo != null && tableNo.isNotEmpty ? 'Table $tableNo' : 'Take Away'} (${cart.length} items)',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.deepOrange.shade700,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                      icon: const Icon(Icons.soup_kitchen_outlined, size: 16),
                      label: const Text('SEND KOT TO KITCHEN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.deepOrange.shade800,
                        side: BorderSide(color: Colors.deepOrange.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],

                // Compact Checkout / Pay Button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: cart.isEmpty || isCheckoutLoading ? null : onCheckoutTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BFA5),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: isCheckoutLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.payments_outlined, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'PAY (F12) • ${tenantSettings.formatCurrency(cartTotal)}',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactPill({
    required IconData icon,
    required String label,
    required MaterialColor color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color.shade700),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: color.shade800, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryTypeSelector(BuildContext context, WidgetRef ref) {
    final currentType = ref.watch(posDeliveryTypeProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: PosDeliveryType.values.map((type) {
          final isSelected = type == currentType;
          final isDineIn = type == PosDeliveryType.dineIn;
          final tenantSettings = ref.watch(tenantSettingsProvider);
          final isDineInLocked = isDineIn && !tenantSettings.isFeatureEnabled('tableManagement');

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: InkWell(
                onTap: () {
                  if (isDineInLocked) {
                    PlanGuardModal.show(
                      context,
                      featureKey: 'tableManagement',
                      featureName: 'Dine-In & Restaurant Table Layouts',
                      requiredPlan: tenantSettings.businessType != BusinessType.restaurant ? 'Restaurant Business Profile' : 'Standard',
                      customDescription: tenantSettings.businessType != BusinessType.restaurant
                          ? 'Dine-In & Table Management is configured for Restaurant business types. Switch your business type in Settings or upgrade your subscription.'
                          : null,
                    );
                    return;
                  }
                  ref.read(posDeliveryTypeProvider.notifier).state = type;
                },
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.25),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isSelected ? type.activeIcon : type.icon,
                        size: 15,
                        color: isSelected ? Colors.white : (isDineInLocked ? Colors.grey.shade400 : Colors.grey.shade700),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isDineInLocked ? '${type.label} 🔒' : type.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? Colors.white : (isDineInLocked ? Colors.grey.shade400 : Colors.grey.shade800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),

      ),
    );
  }

  Widget _buildDeliveryDetailsBanner(BuildContext context, WidgetRef ref) {
    final deliveryType = ref.watch(posDeliveryTypeProvider);
    if (deliveryType == PosDeliveryType.takeAway) {
      return const SizedBox.shrink();
    }

    final details = ref.watch(posDeliveryDetailsProvider);
    final tenantSettings = ref.watch(tenantSettingsProvider);
    final isDineIn = deliveryType == PosDeliveryType.dineIn;

    String displayText;
    IconData displayIcon;

    if (isDineIn) {
      displayIcon = Icons.table_restaurant_outlined;
      final waiterPart = (details.waiterName != null && details.waiterName!.isNotEmpty) ? ' • Waiter: ${details.waiterName!}' : '';
      if (details.tableNumber != null && details.tableNumber!.isNotEmpty) {
        displayText = 'Table: ${details.tableNumber!}$waiterPart';
      } else {
        displayText = details.waiterName != null && details.waiterName!.isNotEmpty
            ? 'No table • Waiter: ${details.waiterName!}'
            : 'No table selected • Tap to assign';
      }
    } else {
      displayIcon = Icons.delivery_dining;
      final aggregatorPart = details.aggregator != null ? '[${details.aggregator!}] ' : '';
      if (details.deliveryAddress != null && details.deliveryAddress!.isNotEmpty) {
        displayText = '$aggregatorPart${details.deliveryAddress!}';
      } else {
        displayText = '${aggregatorPart}Tap to set address & aggregator';
      }
      if (details.deliveryFee > 0) {
        displayText += ' (+${tenantSettings.formatCurrency(details.deliveryFee)})';
      }
    }

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => DeliveryDetailsModal(deliveryType: deliveryType),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isDineIn ? Colors.purple.shade50 : Colors.orange.shade50,
          border: Border(bottom: BorderSide(color: isDineIn ? Colors.purple.shade200 : Colors.orange.shade200)),
        ),
        child: Row(
          children: [
            Icon(displayIcon, size: 14, color: isDineIn ? Colors.purple.shade800 : Colors.orange.shade900),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                displayText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDineIn ? Colors.purple.shade900 : Colors.orange.shade900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.edit_outlined, size: 13, color: isDineIn ? Colors.purple.shade700 : Colors.orange.shade700),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaBadge({
    required IconData icon,
    required String text,
    required Color bgColor,
    required Color textColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: textColor),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
