import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/routing/route_names.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/settings/providers/settings_provider.dart';
import '../../app.dart';

// ──────────────────────────────────────────────
// Sidebar state providers
// ──────────────────────────────────────────────
final sidebarCollapsedProvider = StateProvider<bool>((ref) => false);
final sidebarSearchProvider = StateProvider<String>((ref) => '');

// ──────────────────────────────────────────────
// Role & Email based Permission provider
// Controls module access on sidebar based on active session role/email
// ──────────────────────────────────────────────
final userPermissionsProvider = Provider<Map<String, Map<String, bool>>>((ref) {
  final role = ref.watch(userRoleProvider).toUpperCase();
  final email = ref.watch(userEmailProvider).toLowerCase();

  // 1. Superadmin and Tenant Admin: Full access to all modules
  if (role == 'SUPERADMIN' || role == 'TENANT_ADMIN' || role == 'ADMIN' || email.contains('admin') || email.contains('owner') || email == 'accounts@shaplamart.com') {
    return {
      'main': {'view': true},
      'sales': {'view': true, 'create': true, 'edit': true},
      'inventory': {'view': true, 'create': true, 'edit': true},
      'purchasing': {'view': true, 'create': true, 'edit': true},
      'accounting': {'view': true, 'create': true, 'edit': true},
      'reports': {'view': true},
      'hr': {'view': true, 'create': true, 'edit': true},
      'communication': {'view': true},
      'settings': {'view': true, 'edit': true},
    };
  }

  // 2. Cashier role (e.g. cashier@shaplamart.com): Access ONLY to Sales & POS and Main
  if (email.contains('cashier') || role == 'CASHIER') {
    return {
      'main': {'view': true},
      'sales': {'view': true, 'create': true, 'edit': false},
      'inventory': {'view': false},
      'purchasing': {'view': false},
      'accounting': {'view': false},
      'reports': {'view': false},
      'hr': {'view': false},
      'communication': {'view': false},
      'settings': {'view': false},
    };
  }

  // 3. Accountant role (e.g. accountant@shaplamart.com): Accounts, Reports, Procurement, Sales, Main
  if (email.contains('accountant') || role == 'ACCOUNTANT') {
    return {
      'main': {'view': true},
      'sales': {'view': true},
      'inventory': {'view': false},
      'purchasing': {'view': true},
      'accounting': {'view': true, 'create': true, 'edit': true},
      'reports': {'view': true},
      'hr': {'view': false},
      'communication': {'view': false},
      'settings': {'view': false},
    };
  }

  // 4. Store Manager role (e.g. manager@shaplamart.com): Main, Sales, Inventory, Purchasing, Reports
  if (email.contains('manager') || role == 'MANAGER') {
    return {
      'main': {'view': true},
      'sales': {'view': true, 'create': true, 'edit': true},
      'inventory': {'view': true, 'create': true, 'edit': true},
      'purchasing': {'view': true, 'create': true, 'edit': true},
      'accounting': {'view': false},
      'reports': {'view': true},
      'hr': {'view': false},
      'communication': {'view': true},
      'settings': {'view': false},
    };
  }

  // 5. Default TENANT_USER: Restrict to Sales & POS and Main
  return {
    'main': {'view': true},
    'sales': {'view': true},
    'inventory': {'view': false},
    'purchasing': {'view': false},
    'accounting': {'view': false},
    'reports': {'view': false},
    'hr': {'view': false},
    'communication': {'view': false},
    'settings': {'view': false},
  };
});


// ──────────────────────────────────────────────
// Spec constants from sidebaranalysis.md
// ──────────────────────────────────────────────
class _SidebarSpec {
  static const double expandedWidth = 256;
  static const double collapsedWidth = 64;
  static const double mobileDrawerWidth = 304;
  static const double iconSize = 20;
  static const double itemHeight = 48;
  static const double itemRadius = 8;
  static const Duration tooltipDelay = Duration(milliseconds: 500);
  static const Duration collapseAnimation = Duration(milliseconds: 220);
  static const Duration fadeAnimation = Duration(milliseconds: 120);
}

// ──────────────────────────────────────────────
// Data models
// ──────────────────────────────────────────────
// Data models
// ──────────────────────────────────────────────
class SidebarItem {
  final String label;
  final String? labelAr;
  final IconData icon;
  final IconData? activeIcon;
  final String? routeName;
  final String? routePath;
  final int badgeCount;

  const SidebarItem({
    required this.label,
    this.labelAr,
    required this.icon,
    this.activeIcon,
    this.routeName,
    this.routePath,
    this.badgeCount = 0,
  });

  String getLabel(bool isAr) => isAr && labelAr != null ? labelAr! : label;
}

class SidebarGroup {
  final String label;
  final String? labelAr;
  final IconData icon;
  final String permissionKey;
  final List<SidebarItem> children;

  const SidebarGroup({
    required this.label,
    this.labelAr,
    required this.icon,
    required this.permissionKey,
    required this.children,
  });

  String getLabel(bool isAr) => isAr && labelAr != null ? labelAr! : label;
}

// ──────────────────────────────────────────────
// Menu definitions – all ERP modules
// ──────────────────────────────────────────────
final List<SidebarGroup> sidebarMenuGroups = [
  const SidebarGroup(
    label: 'Main',
    labelAr: 'الرئيسية',
    icon: Icons.space_dashboard_outlined,
    permissionKey: 'main',
    children: [
      SidebarItem(
        label: 'Executive Dashboard',
        labelAr: 'لوحة التحكم التنفيذية',
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard_rounded,
        routeName: RouteNames.dashboard,
        routePath: RoutePaths.dashboard,
      ),
      SidebarItem(
        label: 'Analytics & Insights',
        labelAr: 'التحليلات والرؤى',
        icon: Icons.analytics_outlined,
        activeIcon: Icons.analytics_rounded,
        routeName: RouteNames.analytics,
        routePath: RoutePaths.analytics,
      ),
      SidebarItem(
        label: 'AI Copilot Assistant',
        labelAr: 'المساعد الذكي (AI Copilot)',
        icon: Icons.auto_awesome_outlined,
        activeIcon: Icons.auto_awesome,
        routeName: RouteNames.copilot,
        routePath: RoutePaths.copilot,
      ),
    ],
  ),
  const SidebarGroup(
    label: 'Sales & POS',
    labelAr: 'المبيعات ونقاط البيع',
    icon: Icons.point_of_sale_outlined,
    permissionKey: 'sales',
    children: [
      SidebarItem(
        label: 'POS Register Terminal',
        labelAr: 'شاشة نقطة البيع (POS)',
        icon: Icons.point_of_sale_outlined,
        activeIcon: Icons.point_of_sale_rounded,
        routeName: RouteNames.posCashier,
        routePath: RoutePaths.posCashier,
      ),
      SidebarItem(
        label: 'POS Analytics Dashboard',
        labelAr: 'تحليلات نقطة البيع',
        icon: Icons.assessment_outlined,
        activeIcon: Icons.assessment_rounded,
        routeName: RouteNames.posDashboard,
        routePath: RoutePaths.posDashboard,
      ),
      SidebarItem(
        label: 'Kitchen & Delivery (KDS)',
        labelAr: 'المطبخ والتوصيل (KDS)',
        icon: Icons.soup_kitchen_outlined,
        activeIcon: Icons.soup_kitchen_rounded,
        routeName: RouteNames.ordersDelivery,
        routePath: RoutePaths.ordersDelivery,
      ),
      SidebarItem(
        label: 'Sales Tax Invoices',
        labelAr: 'فواتير المبيعات الضريبية',
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long_rounded,
        routeName: RouteNames.invoices,
        routePath: RoutePaths.invoices,
      ),
      SidebarItem(
        label: 'Customer Directory',
        labelAr: 'دليل العملاء',
        icon: Icons.people_outline,
        activeIcon: Icons.people_rounded,
        routeName: RouteNames.customers,
        routePath: RoutePaths.customers,
      ),
    ],
  ),
  const SidebarGroup(
    label: 'Inventory & Stock',
    labelAr: 'المخزون والمنتجات',
    icon: Icons.inventory_2_outlined,
    permissionKey: 'inventory',
    children: [
      SidebarItem(
        label: 'Products & Master Catalog',
        labelAr: 'المنتجات والكتالوج الرئيسي',
        icon: Icons.inventory_outlined,
        activeIcon: Icons.inventory_rounded,
        routeName: RouteNames.inventory,
        routePath: RoutePaths.inventory,
      ),
      SidebarItem(
        label: 'Stock Management & Transfer',
        labelAr: 'إدارة المخزون والتحويلات',
        icon: Icons.warehouse_outlined,
        activeIcon: Icons.warehouse_rounded,
        routeName: RouteNames.stockManagement,
        routePath: RoutePaths.stockManagement,
      ),
      SidebarItem(
        label: 'Product Categories',
        labelAr: 'تصنيفات المنتجات',
        icon: Icons.category_outlined,
        activeIcon: Icons.category_rounded,
        routeName: RouteNames.categories,
        routePath: RoutePaths.categories,
      ),
      SidebarItem(
        label: 'Print Barcode Labels',
        labelAr: 'طباعة ملصقات البار كود',
        icon: Icons.qr_code_2_outlined,
        activeIcon: Icons.qr_code_2_rounded,
        routeName: RouteNames.printLabels,
        routePath: RoutePaths.printLabels,
      ),
      SidebarItem(
        label: 'Product & Pricing Policy',
        labelAr: 'سياسات المنتجات والأسعار',
        icon: Icons.policy_outlined,
        activeIcon: Icons.policy_rounded,
        routeName: RouteNames.settingsProductPolicy,
        routePath: RoutePaths.settingsProductPolicy,
      ),
    ],
  ),
  const SidebarGroup(
    label: 'Procurement & Purchases',
    labelAr: 'المشتريات والتوريد',
    icon: Icons.shopping_cart_outlined,
    permissionKey: 'purchasing',
    children: [
      SidebarItem(
        label: 'Purchase Bills & Invoices',
        labelAr: 'فواتير المشتريات',
        icon: Icons.receipt_outlined,
        activeIcon: Icons.receipt_rounded,
        routeName: RouteNames.purchases,
        routePath: RoutePaths.purchases,
      ),
      SidebarItem(
        label: 'Supplier Directory',
        labelAr: 'دليل الموردين',
        icon: Icons.local_shipping_outlined,
        activeIcon: Icons.local_shipping_rounded,
        routeName: RouteNames.suppliers,
        routePath: RoutePaths.suppliers,
      ),
    ],
  ),
  const SidebarGroup(
    label: 'Accounts & Finance',
    labelAr: 'الحسابات والمالية',
    icon: Icons.account_balance_outlined,
    permissionKey: 'accounting',
    children: [
      SidebarItem(
        label: 'Accounts Overview',
        labelAr: 'نظرة عامة على الحسابات',
        icon: Icons.space_dashboard_outlined,
        activeIcon: Icons.space_dashboard_rounded,
        routeName: RouteNames.accountingDashboard,
        routePath: RoutePaths.accountingDashboard,
      ),
      SidebarItem(
        label: 'Chart of Accounts (COA)',
        labelAr: 'شجرة الحسابات (COA)',
        icon: Icons.account_tree_outlined,
        activeIcon: Icons.account_tree_rounded,
        routeName: RouteNames.accountingCoA,
        routePath: RoutePaths.accountingCoA,
      ),
      SidebarItem(
        label: 'Vouchers',
        labelAr: 'السندات المالية',
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long_rounded,
        routeName: RouteNames.accountingVouchers,
        routePath: RoutePaths.accountingVouchers,
      ),
      SidebarItem(
        label: 'Voucher Approval Center',
        labelAr: 'اعتماد السندات المالية',
        icon: Icons.fact_check_outlined,
        activeIcon: Icons.fact_check_rounded,
        routeName: RouteNames.voucherApproval,
        routePath: RoutePaths.voucherApproval,
      ),
      SidebarItem(
        label: 'General Ledger Book',
        labelAr: 'دفتر الأستاذ العام',
        icon: Icons.book_outlined,
        activeIcon: Icons.book_rounded,
        routeName: RouteNames.accountingLedger,
        routePath: RoutePaths.accountingLedger,
      ),
      SidebarItem(
        label: 'Cheque Book & Leaves',
        labelAr: 'دفتر وقوائم الشيكات',
        icon: Icons.book_online_outlined,
        activeIcon: Icons.book_online_rounded,
        routeName: RouteNames.chequeManagement,
        routePath: RoutePaths.chequeManagement,
      ),
      SidebarItem(
        label: 'Financial Statements & Reports',
        labelAr: 'القوائم والتقارير المالية',
        icon: Icons.assessment_outlined,
        activeIcon: Icons.assessment_rounded,
        routeName: RouteNames.reports,
        routePath: RoutePaths.reports,
      ),
      SidebarItem(
        label: 'Payment Gateways',
        labelAr: 'بوابات الدفع الإلكتروني',
        icon: Icons.payment_outlined,
        activeIcon: Icons.payment_rounded,
        routeName: RouteNames.payments,
        routePath: RoutePaths.payments,
      ),
    ],
  ),
  const SidebarGroup(
    label: 'Human Resource (HRM)',
    labelAr: 'الموارد البشرية (HRM)',
    icon: Icons.badge_outlined,
    permissionKey: 'hr',
    children: [
      SidebarItem(
        label: 'HR Overview Dashboard',
        labelAr: 'لوحة تحكم الموارد البشرية',
        icon: Icons.space_dashboard_outlined,
        activeIcon: Icons.space_dashboard_rounded,
        routeName: RouteNames.hrDashboard,
        routePath: RoutePaths.hrDashboard,
      ),
      SidebarItem(
        label: 'Employee Directory',
        labelAr: 'دليل الموظفين',
        icon: Icons.badge_outlined,
        activeIcon: Icons.badge_rounded,
        routeName: RouteNames.hrEmployees,
        routePath: RoutePaths.hrEmployees,
      ),
      SidebarItem(
        label: 'Daily Attendance & Time logs',
        labelAr: 'سجل الحضور والانصراف',
        icon: Icons.fingerprint_outlined,
        activeIcon: Icons.fingerprint_rounded,
        routeName: RouteNames.hrAttendance,
        routePath: RoutePaths.hrAttendance,
      ),
      SidebarItem(
        label: 'Leave Requests & Approvals',
        labelAr: 'طلبات الإجازات والموافقات',
        icon: Icons.event_busy_outlined,
        activeIcon: Icons.event_busy_rounded,
        routeName: RouteNames.hrLeaves,
        routePath: RoutePaths.hrLeaves,
      ),
      SidebarItem(
        label: 'Overtime Register',
        labelAr: 'سجل العمل الإضافي',
        icon: Icons.more_time_outlined,
        activeIcon: Icons.more_time_rounded,
        routeName: RouteNames.hrOvertime,
        routePath: RoutePaths.hrOvertime,
      ),
      SidebarItem(
        label: 'Payroll Engine & Slips',
        labelAr: 'مسير الرواتب والمسيرات',
        icon: Icons.payments_outlined,
        activeIcon: Icons.payments_rounded,
        routeName: RouteNames.hrPayroll,
        routePath: RoutePaths.hrPayroll,
      ),
      SidebarItem(
        label: 'Payroll Policy & Pay Scales',
        labelAr: 'سلم الرواتب والدرجات',
        icon: Icons.auto_graph_outlined,
        activeIcon: Icons.auto_graph_rounded,
        routeName: RouteNames.hrPayrollPolicy,
        routePath: RoutePaths.hrPayrollPolicy,
      ),
      SidebarItem(
        label: 'Loans & Salary Advances',
        labelAr: 'القروض والسلف المالية',
        icon: Icons.request_quote_outlined,
        activeIcon: Icons.request_quote_rounded,
        routeName: RouteNames.hrLoans,
        routePath: RoutePaths.hrLoans,
      ),
      SidebarItem(
        label: 'End of Service (EOSB)',
        labelAr: 'مكافأة نهاية الخدمة (EOSB)',
        icon: Icons.exit_to_app_outlined,
        activeIcon: Icons.exit_to_app_rounded,
        routeName: RouteNames.hrEosb,
        routePath: RoutePaths.hrEosb,
      ),
    ],
  ),
  const SidebarGroup(
    label: 'Communication & Integrations',
    labelAr: 'التواصل والربط',
    icon: Icons.chat_outlined,
    permissionKey: 'communication',
    children: [
      SidebarItem(
        label: 'WhatsApp Messaging',
        labelAr: 'رسائل الواتساب',
        icon: Icons.chat_bubble_outline,
        activeIcon: Icons.chat_bubble_rounded,
        routeName: RouteNames.whatsapp,
        routePath: RoutePaths.whatsapp,
      ),
    ],
  ),
  const SidebarGroup(
    label: 'System Administration',
    labelAr: 'إدارة النظام والإعدادات',
    icon: Icons.settings_outlined,
    permissionKey: 'settings',
    children: [
      SidebarItem(
        label: 'Tenant General Settings',
        labelAr: 'الإعدادات العامة للنظام',
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings_rounded,
        routeName: RouteNames.settings,
        routePath: RoutePaths.settings,
      ),
      SidebarItem(
        label: 'Accounting Settings',
        labelAr: 'إعدادات المحاسبة والترقيم',
        icon: Icons.settings_suggest_outlined,
        activeIcon: Icons.settings_suggest_rounded,
        routeName: RouteNames.accountingSettings,
        routePath: RoutePaths.accountingSettings,
      ),
      SidebarItem(
        label: 'Branch & Outlets Management',
        labelAr: 'إدارة الفروع والمنافذ',
        icon: Icons.store_outlined,
        activeIcon: Icons.store_rounded,
        routeName: RouteNames.settingsBranches,
        routePath: RoutePaths.settingsBranches,
      ),
      SidebarItem(
        label: 'Cost Centers & Department Rules',
        labelAr: 'مراكز التكلفة والأقسام',
        icon: Icons.workspaces_outline,
        activeIcon: Icons.workspaces_rounded,
        routeName: RouteNames.settingsCostCenters,
        routePath: RoutePaths.settingsCostCenters,
      ),
      SidebarItem(
        label: 'Product & Pricing Policy',
        labelAr: 'سياسات المنتجات والأسعار',
        icon: Icons.policy_outlined,
        activeIcon: Icons.policy_rounded,
        routeName: RouteNames.settingsProductPolicy,
        routePath: RoutePaths.settingsProductPolicy,
      ),
    ],
  ),
];

List<SidebarGroup> getDynamicSidebarMenuGroups(String flowMode) {
  final List<SidebarItem> procurementItems = [];
  final List<SidebarItem> inventoryItems = [
    const SidebarItem(
      label: 'Products & Master Catalog',
      labelAr: 'المنتجات والكتالوج الرئيسي',
      icon: Icons.inventory_outlined,
      activeIcon: Icons.inventory_rounded,
      routeName: RouteNames.inventory,
      routePath: RoutePaths.inventory,
    ),
  ];

  if (flowMode == 'COMPLEX') {
    procurementItems.addAll([
      const SidebarItem(
        label: 'Supplier Quotations',
        labelAr: 'عروض أسعار الموردين',
        icon: Icons.request_quote_outlined,
        activeIcon: Icons.request_quote_rounded,
        routeName: RouteNames.quotations,
        routePath: RoutePaths.quotations,
      ),
      const SidebarItem(
        label: 'Quotation CS (Comparative)',
        labelAr: 'مقارنة عروض الأسعار (CS)',
        icon: Icons.compare_arrows_outlined,
        activeIcon: Icons.compare_arrows_rounded,
        routeName: RouteNames.quotationCs,
        routePath: RoutePaths.quotationCs,
      ),
      const SidebarItem(
        label: 'Purchase Orders (PO)',
        labelAr: 'أوامر الشراء (PO)',
        icon: Icons.assignment_outlined,
        activeIcon: Icons.assignment_rounded,
        routeName: RouteNames.purchaseOrders,
        routePath: RoutePaths.purchaseOrders,
      ),
      const SidebarItem(
        label: 'Received Goods (GRN)',
        labelAr: 'استلام البضائع (GRN)',
        icon: Icons.move_to_inbox_outlined,
        activeIcon: Icons.move_to_inbox_rounded,
        routeName: RouteNames.goodsReceived,
        routePath: RoutePaths.goodsReceived,
      ),
      const SidebarItem(
        label: 'Quality Check (QC)',
        labelAr: 'فحص الجودة (QC)',
        icon: Icons.fact_check_outlined,
        activeIcon: Icons.fact_check_rounded,
        routeName: RouteNames.qualityCheck,
        routePath: RoutePaths.qualityCheck,
      ),
      const SidebarItem(
        label: 'Received Bills',
        labelAr: 'الفواتير المستلمة',
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long_rounded,
        routeName: RouteNames.receivedBills,
        routePath: RoutePaths.receivedBills,
      ),
      const SidebarItem(
        label: 'Purchase Bills & Invoices',
        labelAr: 'فواتير المشتريات',
        icon: Icons.receipt_outlined,
        activeIcon: Icons.receipt_rounded,
        routeName: RouteNames.purchases,
        routePath: RoutePaths.purchases,
      ),
      const SidebarItem(
        label: 'Supplier Directory',
        labelAr: 'دليل الموردين',
        icon: Icons.local_shipping_outlined,
        activeIcon: Icons.local_shipping_rounded,
        routeName: RouteNames.suppliers,
        routePath: RoutePaths.suppliers,
      ),
    ]);

    inventoryItems.addAll([
      const SidebarItem(
        label: 'Stock Management',
        labelAr: 'إدارة المخزون',
        icon: Icons.warehouse_outlined,
        activeIcon: Icons.warehouse_rounded,
        routeName: RouteNames.stockManagement,
        routePath: RoutePaths.stockManagement,
      ),
      const SidebarItem(
        label: 'Inventory Transfer',
        labelAr: 'تحويل المخزون',
        icon: Icons.multiple_stop_outlined,
        activeIcon: Icons.multiple_stop_rounded,
        routeName: RouteNames.inventoryTransfer,
        routePath: RoutePaths.inventoryTransfer,
      ),
      const SidebarItem(
        label: 'Inventory Stock & Report',
        labelAr: 'تقارير ورصيد المخزون',
        icon: Icons.summarize_outlined,
        activeIcon: Icons.summarize_rounded,
        routeName: RouteNames.inventoryReport,
        routePath: RoutePaths.inventoryReport,
      ),
    ]);
  } else if (flowMode == 'NORMAL') {
    procurementItems.addAll([
      const SidebarItem(
        label: 'Purchase Bills & Invoices',
        labelAr: 'فواتير المشتريات',
        icon: Icons.receipt_outlined,
        activeIcon: Icons.receipt_rounded,
        routeName: RouteNames.purchases,
        routePath: RoutePaths.purchases,
      ),
      const SidebarItem(
        label: 'Supplier Returns (Debit Notes)',
        labelAr: 'مرتجعات الموردين (الإشعارات المدينة)',
        icon: Icons.assignment_return_outlined,
        activeIcon: Icons.assignment_return_rounded,
        routeName: RouteNames.purchases,
        routePath: RoutePaths.purchases,
      ),
      const SidebarItem(
        label: 'Supplier Directory',
        labelAr: 'دليل الموردين',
        icon: Icons.local_shipping_outlined,
        activeIcon: Icons.local_shipping_rounded,
        routeName: RouteNames.suppliers,
        routePath: RoutePaths.suppliers,
      ),
    ]);

    inventoryItems.addAll([
      const SidebarItem(
        label: 'Stock Management & Adjustments',
        labelAr: 'إدارة وتعديل المخزون',
        icon: Icons.warehouse_outlined,
        activeIcon: Icons.warehouse_rounded,
        routeName: RouteNames.stockManagement,
        routePath: RoutePaths.stockManagement,
      ),
      const SidebarItem(
        label: 'Inventory Stock & Report',
        labelAr: 'تقارير ورصيد المخزون',
        icon: Icons.summarize_outlined,
        activeIcon: Icons.summarize_rounded,
        routeName: RouteNames.inventoryReport,
        routePath: RoutePaths.inventoryReport,
      ),
    ]);
  } else {
    // SIMPLE flow
    procurementItems.addAll([
      const SidebarItem(
        label: 'Purchase Invoices',
        labelAr: 'فواتير المشتريات',
        icon: Icons.receipt_outlined,
        activeIcon: Icons.receipt_rounded,
        routeName: RouteNames.purchases,
        routePath: RoutePaths.purchases,
      ),
      const SidebarItem(
        label: 'Supplier Directory',
        labelAr: 'دليل الموردين',
        icon: Icons.local_shipping_outlined,
        activeIcon: Icons.local_shipping_rounded,
        routeName: RouteNames.suppliers,
        routePath: RoutePaths.suppliers,
      ),
    ]);

    inventoryItems.add(
      const SidebarItem(
        label: 'Inventory Stock & Report',
        labelAr: 'تقارير ورصيد المخزون',
        icon: Icons.summarize_outlined,
        activeIcon: Icons.summarize_rounded,
        routeName: RouteNames.inventoryReport,
        routePath: RoutePaths.inventoryReport,
      ),
    );
  }

  inventoryItems.addAll([
    const SidebarItem(
      label: 'Product Categories',
      labelAr: 'تصنيفات المنتجات',
      icon: Icons.category_outlined,
      activeIcon: Icons.category_rounded,
      routeName: RouteNames.categories,
      routePath: RoutePaths.categories,
    ),
    const SidebarItem(
      label: 'Print Barcode Labels',
      labelAr: 'طباعة ملصقات البار كود',
      icon: Icons.qr_code_2_outlined,
      activeIcon: Icons.qr_code_2_rounded,
      routeName: RouteNames.printLabels,
      routePath: RoutePaths.printLabels,
    ),
  ]);

  return [
    sidebarMenuGroups[0], // Main
    sidebarMenuGroups[1], // Sales & POS
    SidebarGroup(
      label: 'Inventory & Stock',
      labelAr: 'المخزون والمنتجات',
      icon: Icons.inventory_2_outlined,
      permissionKey: 'inventory',
      children: inventoryItems,
    ),
    SidebarGroup(
      label: 'Procurement & Purchases',
      labelAr: 'المشتريات والتوريد',
      icon: Icons.shopping_cart_outlined,
      permissionKey: 'purchasing',
      children: procurementItems,
    ),
    sidebarMenuGroups[4], // Accounts & Finance
    sidebarMenuGroups[5], // HR
    sidebarMenuGroups[6], // Communication
    sidebarMenuGroups[7], // Settings
  ];
}

// ──────────────────────────────────────────────
// Sidebar theme colors (from spec)
// ──────────────────────────────────────────────
class _C {
  static const bg = Color(0xFF0F172A);
  static const bgHover = Color(0xFF1F2937);
  static const bgActive = Color(0xFF2563EB);
  static const textPrimary = Color(0xFFF1F5F9);
  static const textSecondary = Color(0xFF9CA3AF);
  static const textMuted = Color(0xFF64748B);
  static const divider = Color(0xFF1E293B);
  static const searchBg = Color(0xFF1E293B);
  static const focusOutline = Color(0xFF93C5FD);
  static const badgeRed = Color(0xFFEF4444);
  static const tooltipBg = Color(0xFF111827);
}

// ══════════════════════════════════════════════
// MAIN SIDEBAR WIDGET
// ══════════════════════════════════════════════
class ErpSidebar extends ConsumerStatefulWidget {
  const ErpSidebar({super.key});

  @override
  ConsumerState<ErpSidebar> createState() => _ErpSidebarState();
}

class _ErpSidebarState extends ConsumerState<ErpSidebar>
    with TickerProviderStateMixin {
  final Set<String> _expandedGroups = {'Main', 'Sales & POS'};
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _collapseController;
  late Animation<double> _labelOpacity;

  @override
  void initState() {
    super.initState();
    _collapseController = AnimationController(
      vsync: this,
      duration: _SidebarSpec.collapseAnimation,
    );
    _labelOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _collapseController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _collapseController.dispose();
    super.dispose();
  }

  String _currentPath(BuildContext context) {
    return GoRouterState.of(context).uri.path;
  }

  bool _isItemActive(SidebarItem item, String currentPath) {
    if (item.routePath == null) return false;
    if (currentPath == item.routePath) return true;
    if (currentPath.startsWith('${item.routePath!}/')) return true;
    return false;
  }

  void _toggleCollapse() {
    final isCollapsed = ref.read(sidebarCollapsedProvider);
    if (isCollapsed) {
      // Expanding: width first, then fade in labels
      ref.read(sidebarCollapsedProvider.notifier).state = false;
      _collapseController.reverse();
    } else {
      // Collapsing: fade out labels first, then shrink
      _collapseController.forward().then((_) {
        ref.read(sidebarCollapsedProvider.notifier).state = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCollapsed = ref.watch(sidebarCollapsedProvider);
    final searchQuery = ref.watch(sidebarSearchProvider);
    final permissions = ref.watch(userPermissionsProvider);
    final currentPath = _currentPath(context);
    final sidebarWidth = isCollapsed
        ? _SidebarSpec.collapsedWidth
        : _SidebarSpec.expandedWidth;

    return AnimatedContainer(
      duration: _SidebarSpec.collapseAnimation,
      curve: Curves.easeInOut,
      width: sidebarWidth,
      decoration: const BoxDecoration(
        color: _C.bg,
        border: Border(right: BorderSide(color: _C.divider, width: 1)),
      ),
      child: Column(
        children: [
          _buildHeader(isCollapsed),
          const Divider(color: _C.divider, height: 1),
          if (!isCollapsed) _buildSearchBar(),
          Expanded(
            child: _buildNavigation(
              isCollapsed: isCollapsed,
              searchQuery: searchQuery,
              currentPath: currentPath,
              permissions: permissions,
            ),
          ),
          const Divider(color: _C.divider, height: 1),
          _buildFooter(isCollapsed),
        ],
      ),
    );
  }

  // ── Header ──
  Widget _buildHeader(bool isCollapsed) {
    return SizedBox(
      height: 64,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isCollapsed ? 10 : 16,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.hexagon_rounded, color: Colors.white, size: 20),
            ),
            if (!isCollapsed) ...[
              const SizedBox(width: 12),
              AnimatedBuilder(
                animation: _labelOpacity,
                builder: (context, child) => Opacity(
                  opacity: _labelOpacity.value,
                  child: child,
                ),
                child: const Text(
                  'Intelligent ERP',
                  style: TextStyle(
                    color: _C.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const Spacer(),
            ],
            const SizedBox(width: 4),
            _buildCollapseButton(isCollapsed),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapseButton(bool isCollapsed) {
    return Semantics(
      label: isCollapsed ? 'Expand sidebar' : 'Collapse sidebar',
      button: true,
      child: Focus(
        child: Builder(builder: (context) {
          return InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: _toggleCollapse,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _C.searchBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                isCollapsed
                    ? Icons.chevron_right_rounded
                    : Icons.chevron_left_rounded,
                size: 18,
                color: _C.textSecondary,
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Search ──
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: SizedBox(
        height: 36,
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: _C.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Search menu…',
            hintStyle: const TextStyle(color: _C.textMuted, fontSize: 13),
            prefixIcon: const Icon(Icons.search_rounded, size: 18, color: _C.textMuted),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.close, size: 16, color: _C.textMuted),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(sidebarSearchProvider.notifier).state = '';
                    },
                  )
                : null,
            filled: true,
            fillColor: _C.searchBg,
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_SidebarSpec.itemRadius),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) {
            ref.read(sidebarSearchProvider.notifier).state = value;
          },
        ),
      ),
    );
  }

  // ── Navigation list ──
  Widget _buildNavigation({
    required bool isCollapsed,
    required String searchQuery,
    required String currentPath,
    required Map<String, Map<String, bool>> permissions,
  }) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final query = searchQuery.toLowerCase();
    final activeFlow = ref.watch(activePurchaseFlowProvider);
    final dynamicGroups = getDynamicSidebarMenuGroups(activeFlow);

    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: isCollapsed ? 8 : 12,
        vertical: 8,
      ),
      children: [
        for (final group in dynamicGroups) ...[
          // Permission-based hiding: hide entire module if no view permission
          if (permissions[group.permissionKey]?['view'] != false)
            () {
              final filteredChildren = query.isEmpty
                  ? group.children
                  : group.children
                      .where((item) =>
                          item.getLabel(isArabic).toLowerCase().contains(query) ||
                          item.label.toLowerCase().contains(query) ||
                          group.getLabel(isArabic).toLowerCase().contains(query) ||
                          group.label.toLowerCase().contains(query))
                      .toList();

              if (filteredChildren.isEmpty) {
                return const SizedBox.shrink();
              }

              if (isCollapsed) {
                return Column(
                  children: [
                    for (final item in filteredChildren)
                      _CollapsedNavItem(
                        item: item,
                        isActive: _isItemActive(item, currentPath),
                        onTap: () {
                          if (item.routeName != null) {
                            context.goNamed(item.routeName!);
                          }
                        },
                      ),
                    const SizedBox(height: 4),
                  ],
                );
              }

              final isExpanded =
                  _expandedGroups.contains(group.label) || query.isNotEmpty;

              return _ExpandableGroup(
                label: group.getLabel(isArabic),
                icon: group.icon,
                isExpanded: isExpanded,
                onToggle: () {
                  setState(() {
                    if (_expandedGroups.contains(group.label)) {
                      _expandedGroups.remove(group.label);
                    } else {
                      _expandedGroups.add(group.label);
                    }
                  });
                },
                children: [
                  for (final item in filteredChildren)
                    _ExpandedNavItem(
                      item: item,
                      isActive: _isItemActive(item, currentPath),
                      onTap: () {
                        if (item.routeName != null) {
                          context.goNamed(item.routeName!);
                        }
                      },
                    ),
                ],
              );
            }(),
        ],
      ],
    );
  }

  // ── Footer ──
  Widget _buildFooter(bool isCollapsed) {
    final email = ref.watch(userEmailProvider);
    final role = ref.watch(userRoleProvider);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCollapsed ? 10 : 16,
        vertical: 12,
      ),
      child: isCollapsed
          ? Center(
              child: Tooltip(
                message: 'Logout',
                waitDuration: _SidebarSpec.tooltipDelay,
                child: IconButton(
                  onPressed: () => ref.read(authProvider.notifier).logout(),
                  icon: const Icon(Icons.logout_rounded, color: _C.textSecondary, size: _SidebarSpec.iconSize),
                ),
              ),
            )
          : Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF334155),
                  child: Text(
                    email.isNotEmpty ? email[0].toUpperCase() : 'U',
                    style: const TextStyle(fontSize: 14, color: _C.textSecondary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        email.isNotEmpty ? email : 'User Account',
                        style: const TextStyle(
                          color: _C.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        role.isNotEmpty ? role : 'TENANT_USER',
                        style: const TextStyle(color: _C.textMuted, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => ref.read(authProvider.notifier).logout(),
                  icon: const Icon(Icons.logout_rounded, color: _C.textSecondary, size: 18),
                  tooltip: 'Logout',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
    );
  }
}

// ══════════════════════════════════════════════
// EXPANDABLE GROUP HEADER
// ══════════════════════════════════════════════
class _ExpandableGroup extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isExpanded;
  final VoidCallback onToggle;
  final List<Widget> children;

  const _ExpandableGroup({
    required this.label,
    required this.icon,
    required this.isExpanded,
    required this.onToggle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: Row(
              children: [
                Icon(icon, size: 14, color: _C.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      color: _C.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0,
                  duration: _SidebarSpec.fadeAnimation,
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: _C.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: Column(children: children),
          secondChild: const SizedBox.shrink(),
          crossFadeState:
              isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 180),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}

// ══════════════════════════════════════════════
// EXPANDED NAV ITEM  (label + icon, 48px height)
// ══════════════════════════════════════════════
class _ExpandedNavItem extends ConsumerStatefulWidget {
  final SidebarItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _ExpandedNavItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  ConsumerState<_ExpandedNavItem> createState() => _ExpandedNavItemState();
}

class _ExpandedNavItemState extends ConsumerState<_ExpandedNavItem> {
  bool _isHovering = false;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final labelText = widget.item.getLabel(isArabic);
    final isActive = widget.isActive;

    // Colors per spec: Active → #2563EB bg + white icon
    // Hover → #1F2937 bg, Inactive → #9CA3AF icon
    final Color bgColor;
    final Color iconColor;
    final Color textColor;

    if (isActive) {
      bgColor = _C.bgActive;
      iconColor = Colors.white;
      textColor = Colors.white;
    } else if (_isHovering) {
      bgColor = _C.bgHover;
      iconColor = _C.textPrimary;
      textColor = _C.textPrimary;
    } else {
      bgColor = Colors.transparent;
      iconColor = _C.textSecondary;
      textColor = _C.textSecondary;
    }

    return Semantics(
      label: labelText,
      button: true,
      selected: isActive,
      child: Focus(
        onFocusChange: (focused) => setState(() => _isFocused = focused),
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter ||
               event.logicalKey == LogicalKeyboardKey.space)) {
            widget.onTap();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: _SidebarSpec.itemHeight,
              margin: const EdgeInsets.symmetric(vertical: 1),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(_SidebarSpec.itemRadius),
                border: _isFocused
                    ? Border.all(color: _C.focusOutline, width: 2)
                    : isActive
                        ? const Border(
                            left: BorderSide(color: Colors.white, width: 3),
                          )
                        : null,
              ),
              child: Row(
                children: [
                  Icon(
                    isActive
                        ? (widget.item.activeIcon ?? widget.item.icon)
                        : widget.item.icon,
                    size: _SidebarSpec.iconSize,
                    color: iconColor,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      labelText,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 13,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.item.badgeCount > 0)
                    _Badge(count: widget.item.badgeCount),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// COLLAPSED NAV ITEM  (icon only, 48px, tooltip)
// ══════════════════════════════════════════════
class _CollapsedNavItem extends ConsumerStatefulWidget {
  final SidebarItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _CollapsedNavItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  ConsumerState<_CollapsedNavItem> createState() => _CollapsedNavItemState();
}

class _CollapsedNavItemState extends ConsumerState<_CollapsedNavItem> {
  bool _isHovering = false;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final labelText = widget.item.getLabel(isArabic);
    final isActive = widget.isActive;

    final Color bgColor;
    final Color iconColor;

    if (isActive) {
      bgColor = _C.bgActive;
      iconColor = Colors.white;
    } else if (_isHovering) {
      bgColor = _C.bgHover;
      iconColor = _C.textPrimary;
    } else {
      bgColor = Colors.transparent;
      iconColor = _C.textSecondary;
    }

    return Semantics(
      label: labelText,
      button: true,
      selected: isActive,
      child: Tooltip(
        message: labelText,
        preferBelow: false,
        verticalOffset: 0,
        waitDuration: _SidebarSpec.tooltipDelay,
        decoration: BoxDecoration(
          color: _C.tooltipBg,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        child: Focus(
          onFocusChange: (focused) => setState(() => _isFocused = focused),
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent &&
                (event.logicalKey == LogicalKeyboardKey.enter ||
                 event.logicalKey == LogicalKeyboardKey.space)) {
              widget.onTap();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovering = true),
            onExit: (_) => setState(() => _isHovering = false),
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(vertical: 2),
                width: _SidebarSpec.collapsedWidth - 16,
                height: _SidebarSpec.itemHeight,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(_SidebarSpec.itemRadius),
                  border: _isFocused
                      ? Border.all(color: _C.focusOutline, width: 2)
                      : null,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      isActive
                          ? (widget.item.activeIcon ?? widget.item.icon)
                          : widget.item.icon,
                      size: _SidebarSpec.iconSize,
                      color: iconColor,
                    ),
                    if (widget.item.badgeCount > 0)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: _BadgeDot(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// BADGE WIDGETS
// ══════════════════════════════════════════════
class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _C.badgeRed,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _BadgeDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: _C.badgeRed,
        shape: BoxShape.circle,
      ),
    );
  }
}

// ══════════════════════════════════════════════
// BREADCRUMBS
// ══════════════════════════════════════════════
class ErpBreadcrumbs extends StatelessWidget {
  const ErpBreadcrumbs({super.key});

  static const _segmentLabels = {
    'dashboard': 'Dashboard',
    'pos': 'POS',
    'invoices': 'Invoices',
    'customers': 'Clients',
    'settings': 'Settings',
    'inventory': 'Inventory',
    'hr': 'Human Resources',
    'employees': 'Employees',
    'attendance': 'Attendance',
    'payroll': 'Payroll',
    'leaves': 'Leave Requests',
    'overtime': 'Overtime',
    'loans': 'Loans & Advances',
    'eosb': 'End of Service',
    'accounting': 'Accounting',
    'coa': 'Chart of Accounts',
    'journal': 'Journal Entries',
    'ledger': 'Ledger',
    'vouchers': 'Vouchers',
    'suppliers': 'Suppliers',
    'purchases': 'Purchases',
    'cash-book': 'Cash Book',
    'reports': 'Reports',
    'whatsapp': 'WhatsApp',
    'copilot': 'AI Copilot',
    'payments': 'Payments',
    'categories': 'Categories',
    'sub-categories': 'Sub Categories',
    'units': 'Units',
    'variable-products': 'Variable Products',
    'stock-management': 'Stock Management',
    'cost-centers': 'Cost Centers',
    'branches': 'Branches',
    'add': 'Add New',
    'create': 'Create',
    'new': 'New',
    'detail': 'Details',
    'edit': 'Edit',
  };

  String _labelForSegment(String segment) {
    return _segmentLabels[segment] ??
        segment
            .replaceAll('-', ' ')
            .split(' ')
            .map((w) =>
                w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
            .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();

    if (segments.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 48,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            InkWell(
              onTap: () => context.goNamed(RouteNames.dashboard),
              borderRadius: BorderRadius.circular(4),
              child: Icon(Icons.home_rounded,
                  size: 18, color: Theme.of(context).colorScheme.primary),
            ),
            for (int i = 0; i < segments.length; i++) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.chevron_right_rounded,
                    size: 16, color: Colors.grey.shade400),
              ),
              if (i < segments.length - 1)
                InkWell(
                  onTap: () {
                    final targetPath =
                        '/${segments.sublist(0, i + 1).join('/')}';
                    context.go(targetPath);
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Text(
                    _labelForSegment(segments[i]),
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                )
              else
                Text(
                  _labelForSegment(segments[i]),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// MOBILE DRAWER  (304px, 5 priority quick actions)
// ══════════════════════════════════════════════
class ErpMobileDrawer extends ConsumerWidget {
  const ErpMobileDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = GoRouterState.of(context).uri.path;
    final permissions = ref.watch(userPermissionsProvider);

    return Drawer(
      width: _SidebarSpec.mobileDrawerWidth,
      backgroundColor: _C.bg,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.hexagon_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Intelligent ERP',
                    style: TextStyle(
                      color: _C.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: _C.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(color: _C.divider, height: 1),

            // Quick Actions – 5 priority items
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 8, bottom: 8),
                    child: Text(
                      'QUICK ACTIONS',
                      style: TextStyle(
                        color: _C.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  _MobileNavItem(
                    icon: Icons.dashboard_rounded,
                    label: 'Dashboard',
                    isActive: currentPath.startsWith(RoutePaths.dashboard),
                    onTap: () {
                      Navigator.pop(context);
                      context.goNamed(RouteNames.dashboard);
                    },
                  ),
                  _MobileNavItem(
                    icon: Icons.point_of_sale_rounded,
                    label: 'POS Cashier',
                    isActive: currentPath.startsWith(RoutePaths.posCashier),
                    onTap: () {
                      Navigator.pop(context);
                      context.goNamed(RouteNames.posCashier);
                    },
                  ),
                  _MobileNavItem(
                    icon: Icons.description_rounded,
                    label: 'Invoices',
                    isActive: currentPath.startsWith(RoutePaths.invoices),
                    onTap: () {
                      Navigator.pop(context);
                      context.goNamed(RouteNames.invoices);
                    },
                  ),
                  _MobileNavItem(
                    icon: Icons.badge_rounded,
                    label: 'Employees',
                    isActive: currentPath.startsWith(RoutePaths.hrEmployees),
                    onTap: () {
                      Navigator.pop(context);
                      context.goNamed(RouteNames.hrEmployees);
                    },
                  ),
                  _MobileNavItem(
                    icon: Icons.analytics_rounded,
                    label: 'Reports',
                    isActive: currentPath.startsWith(RoutePaths.reports),
                    onTap: () {
                      Navigator.pop(context);
                      context.goNamed(RouteNames.reports);
                    },
                  ),
                ],
              ),
            ),
            const Divider(color: _C.divider, height: 1),

            // Full menu – permission-filtered
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  for (final group in sidebarMenuGroups)
                    if (permissions[group.permissionKey]?['view'] != false) ...[
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 8, top: 12, bottom: 6),
                        child: Text(
                          group.label.toUpperCase(),
                          style: const TextStyle(
                            color: _C.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      for (final item in group.children)
                        _MobileNavItem(
                          icon: item.icon,
                          label: item.label,
                          isActive: item.routePath != null &&
                              currentPath.startsWith(item.routePath!),
                          onTap: () {
                            Navigator.pop(context);
                            if (item.routeName != null) {
                              context.goNamed(item.routeName!);
                            }
                          },
                        ),
                    ],
                ],
              ),
            ),

            // Footer
            const Divider(color: _C.divider, height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: _MobileNavItem(
                icon: Icons.logout_rounded,
                label: 'Logout',
                isActive: false,
                onTap: () {
                  Navigator.pop(context);
                  ref.read(authProvider.notifier).logout();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _MobileNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -1),
      leading: Icon(
        icon,
        size: _SidebarSpec.iconSize,
        color: isActive ? Colors.white : _C.textSecondary,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : _C.textPrimary,
          fontSize: 14,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      selected: isActive,
      selectedTileColor: _C.bgActive,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_SidebarSpec.itemRadius)),
      onTap: onTap,
    );
  }
}
