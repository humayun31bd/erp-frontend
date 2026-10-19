import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents a single payment method configured by the tenant.
class PaymentMethod {
  final String id;
  final String name;
  final String nameAr;
  final IconData icon;
  final Color color;
  final bool isActive;
  final bool isDefault; // only one should be true (Cash by default)

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.icon,
    required this.color,
    this.isActive = true,
    this.isDefault = false,
  });

  PaymentMethod copyWith({
    String? id,
    String? name,
    String? nameAr,
    IconData? icon,
    Color? color,
    bool? isActive,
    bool? isDefault,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

/// Default system payment methods seeded on first launch.
final List<PaymentMethod> _defaultPaymentMethods = [
  const PaymentMethod(
    id: 'cash',
    name: 'Cash',
    nameAr: 'نقداً',
    icon: Icons.payments_outlined,
    color: Color(0xFF2E7D32), // green
    isDefault: true,
  ),
  const PaymentMethod(
    id: 'card',
    name: 'Card / Mada',
    nameAr: 'بطاقة / مدى',
    icon: Icons.credit_card,
    color: Color(0xFF1565C0), // blue
  ),
  const PaymentMethod(
    id: 'stc_pay',
    name: 'STC Pay',
    nameAr: 'STC Pay',
    icon: Icons.phone_android,
    color: Color(0xFF6A1B9A), // purple
  ),
  const PaymentMethod(
    id: 'bank_transfer',
    name: 'Bank Transfer',
    nameAr: 'تحويل بنكي',
    icon: Icons.account_balance,
    color: Color(0xFFE65100), // orange
  ),
  const PaymentMethod(
    id: 'credit',
    name: 'Credit / On Account',
    nameAr: 'آجل / على الحساب',
    icon: Icons.receipt_long_outlined,
    color: Color(0xFF37474F), // blue-grey
  ),
];

/// Notifier that manages the list of payment methods.
class PaymentMethodNotifier extends Notifier<List<PaymentMethod>> {
  @override
  List<PaymentMethod> build() => List.from(_defaultPaymentMethods);

  /// Add a new custom payment method.
  void add(PaymentMethod method) {
    state = [...state, method];
  }

  /// Toggle active/inactive for a method.
  void toggleActive(String id) {
    state = state.map((m) {
      if (m.id == id) return m.copyWith(isActive: !m.isActive);
      return m;
    }).toList();
  }

  /// Set a method as default (and unset all others).
  void setDefault(String id) {
    state = state.map((m) => m.copyWith(isDefault: m.id == id)).toList();
  }

  /// Update name/icon of a method.
  void update(String id, {String? name, String? nameAr, Color? color}) {
    state = state.map((m) {
      if (m.id == id) {
        return m.copyWith(name: name, nameAr: nameAr, color: color);
      }
      return m;
    }).toList();
  }

  /// Remove a custom method (built-in cash cannot be removed).
  void remove(String id) {
    if (id == 'cash') return; // Cash is always required
    state = state.where((m) => m.id != id).toList();
  }

  /// Active methods sorted: default first.
  List<PaymentMethod> get activeMethods {
    final active = state.where((m) => m.isActive).toList();
    active.sort((a, b) {
      if (a.isDefault) return -1;
      if (b.isDefault) return 1;
      return 0;
    });
    return active;
  }

  /// The current default payment method.
  PaymentMethod get defaultMethod =>
      state.firstWhere((m) => m.isDefault, orElse: () => state.first);
}

final paymentMethodProvider =
    NotifierProvider<PaymentMethodNotifier, List<PaymentMethod>>(
  PaymentMethodNotifier.new,
);
