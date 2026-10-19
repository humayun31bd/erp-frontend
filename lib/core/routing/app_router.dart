import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'route_names.dart';
import '../../shared/widgets/app_scaffold.dart';
import 'not_found_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/invoicing/presentation/screens/invoice_list_screen.dart';
import '../../features/invoicing/presentation/screens/create_invoice_screen.dart';
import '../../features/invoicing/presentation/screens/invoice_detail_screen.dart';
import '../../features/clients/presentation/screens/client_list_screen.dart';
import '../../features/clients/presentation/screens/client_form_screen.dart';
import '../../features/clients/presentation/screens/customer_detail_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/agency/presentation/screens/agency_dashboard_screen.dart';
import '../../features/agency/presentation/screens/tenant_form_screen.dart';
import '../../features/pos/presentation/screens/inventory_screen.dart';
import '../../features/inventory/presentation/screens/categories_screen.dart';
import '../../features/inventory/presentation/screens/sub_categories_screen.dart';
import '../../features/inventory/presentation/screens/variable_products_screen.dart';
import '../../features/inventory/presentation/screens/stock_management_screen.dart';
import '../../features/inventory/presentation/screens/opening_stock_screen.dart';
import '../../features/inventory/presentation/screens/units_screen.dart';
import '../../features/inventory/presentation/screens/print_labels_screen.dart';
import '../../features/inventory/presentation/screens/inventory_transfer_screen.dart';
import '../../features/inventory/presentation/screens/create_inventory_transfer_screen.dart';
import '../../features/inventory/presentation/screens/inventory_report_screen.dart';
import '../../features/pos/presentation/screens/pos_cashier_screen.dart';
import '../../features/pos/presentation/screens/pos_dashboard_screen.dart';
import '../../features/orders/presentation/screens/orders_delivery_screen.dart';
import '../../features/copilot/presentation/screens/copilot_screen.dart';
import '../../features/whatsapp/presentation/screens/whatsapp_logs_screen.dart';
import '../../features/payments/presentation/screens/payment_history_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/suppliers/presentation/suppliers_screen.dart';
import '../../features/settings/presentation/screens/product_policy_screen.dart';
import '../../features/settings/presentation/screens/manage_purchase_flow_screen.dart';
import '../../features/suppliers/presentation/supplier_form_screen.dart';
import '../../features/suppliers/presentation/supplier_detail_screen.dart';
import '../../features/suppliers/presentation/supplier_returns_screen.dart';
import '../../features/suppliers/domain/supplier_model.dart';
import '../../features/purchases/presentation/purchases_screen.dart';
import '../../features/purchases/presentation/purchase_form_screen.dart';
import '../../features/purchases/presentation/quotations_screen.dart';
import '../../features/purchases/presentation/quotation_cs_screen.dart';
import '../../features/purchases/presentation/purchase_orders_screen.dart';
import '../../features/purchases/presentation/goods_received_screen.dart';
import '../../features/purchases/presentation/quality_check_screen.dart';
import '../../features/purchases/presentation/received_bills_screen.dart';
import '../../features/cash_book/presentation/cash_book_screen.dart';
import '../../features/cash_book/presentation/cash_book_form_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/hr/presentation/screens/hr_dashboard_screen.dart';
import '../../features/hr/presentation/screens/hr_employees_screen.dart';
import '../../features/hr/presentation/screens/hr_add_employee_screen.dart';
import '../../features/hr/presentation/screens/hr_employee_detail_screen.dart';
import '../../features/hr/presentation/screens/hr_attendance_screen.dart';
import '../../features/hr/presentation/screens/hr_payroll_screen.dart';
import '../../features/hr/presentation/screens/hr_leave_screen.dart';
import '../../features/hr/presentation/screens/hr_overtime_screen.dart';
import '../../features/hr/presentation/screens/hr_loan_screen.dart';
import '../../features/hr/presentation/screens/hr_eosb_screen.dart';
import '../../features/hr/presentation/screens/hr_organogram_screen.dart';
import '../../features/hr/presentation/screens/hr_payroll_policy_screen.dart';
import '../../features/accounting/presentation/screens/accounting_dashboard_screen.dart';
import '../../features/accounting/presentation/screens/journal_entries_screen.dart';
import '../../features/accounting/presentation/screens/create_journal_entry_screen.dart';
import '../../features/accounting/presentation/screens/chart_of_accounts_screen.dart';
import '../../features/accounting/presentation/screens/voucher_approval_screen.dart';
import '../../features/accounting/presentation/screens/accounting_settings_screen.dart';
import '../../features/settings/presentation/screens/cost_centers_screen.dart';
import '../../features/settings/presentation/screens/branches_screen.dart';
import '../../features/settings/presentation/screens/financial_years_screen.dart';
import '../../features/settings/presentation/screens/rbac_permissions_screen.dart';
import '../../features/accounting/presentation/vouchers_screen.dart';
import '../../features/accounting/presentation/screens/cheque_management_screen.dart';


final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.dashboard,
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Splash Screen / Loading...')),
        ),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AppScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: RoutePaths.dashboard,
            name: RouteNames.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: RoutePaths.customers,
            name: RouteNames.customers,
            builder: (context, state) => const CustomerGridScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: RouteNames.createCustomer,
                builder: (context, state) => const ClientFormScreen(),
              ),
              GoRoute(
                path: ':id',
                name: RouteNames.customerDetail,
                builder: (context, state) => CustomerDetailScreen(customerId: state.pathParameters['id']!),
              ),
              GoRoute(
                path: ':id/edit',
                name: RouteNames.editCustomer,
                builder: (context, state) => const ClientFormScreen(),
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.invoices,
            name: RouteNames.invoices,
            builder: (context, state) => const InvoiceListScreen(),
            routes: [
              GoRoute(
                path: 'create',
                name: RouteNames.createInvoice,
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return CreateInvoiceScreen(
                    originalInvoiceId: extra?['originalInvoiceId'],
                    noteType: extra?['noteType'],
                  );
                },
              ),
              GoRoute(
                path: ':id',
                name: RouteNames.invoiceDetail,
                builder: (context, state) => InvoiceDetailScreen(
                  invoiceId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.agencyDashboard,
            name: RouteNames.agencyDashboard,
            builder: (context, state) => const AgencyDashboardScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: RouteNames.agencyNewTenant,
                builder: (context, state) => const TenantFormScreen(),
              ),
              GoRoute(
                path: 'copilot',
                name: RouteNames.copilot,
                builder: (context, state) => const CopilotScreen(),
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.posCashier,
            name: RouteNames.posCashier,
            builder: (context, state) => const PosCashierScreen(),
          ),
          GoRoute(
            path: RoutePaths.posDashboard,
            name: RouteNames.posDashboard,
            builder: (context, state) => const PosDashboardScreen(),
          ),
          GoRoute(
            path: RoutePaths.ordersDelivery,
            name: RouteNames.ordersDelivery,
            builder: (context, state) => const OrdersDeliveryScreen(),
          ),
          GoRoute(
            path: RoutePaths.whatsapp,
            name: RouteNames.whatsapp,
            builder: (context, state) => const WhatsAppLogsScreen(),
          ),
          GoRoute(
            path: RoutePaths.payments,
            name: RouteNames.payments,
            builder: (context, state) => const PaymentHistoryScreen(),
          ),
          GoRoute(
            path: RoutePaths.reports,
            name: RouteNames.reports,
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: RoutePaths.inventory,
            name: RouteNames.inventory,
            builder: (context, state) => const InventoryScreen(),
          ),
          GoRoute(
            path: RoutePaths.categories,
            name: RouteNames.categories,
            builder: (context, state) => const CategoriesScreen(),
          ),
          GoRoute(
            path: RoutePaths.subCategories,
            name: RouteNames.subCategories,
            builder: (context, state) => const SubCategoriesScreen(),
          ),
          GoRoute(
            path: RoutePaths.variableProducts,
            name: RouteNames.variableProducts,
            builder: (context, state) => const VariableProductsScreen(),
          ),
          GoRoute(
            path: RoutePaths.stockManagement,
            name: RouteNames.stockManagement,
            builder: (context, state) => const StockManagementScreen(),
          ),
          GoRoute(
            path: RoutePaths.openingStock,
            name: RouteNames.openingStock,
            builder: (context, state) => const OpeningStockScreen(),
          ),
          GoRoute(
            path: RoutePaths.units,
            name: RouteNames.units,
            builder: (context, state) => const UnitsScreen(),
          ),
          GoRoute(
            path: RoutePaths.printLabels,
            name: RouteNames.printLabels,
            builder: (context, state) => const PrintLabelsScreen(),
          ),
          GoRoute(
            path: RoutePaths.inventoryTransfer,
            name: RouteNames.inventoryTransfer,
            builder: (context, state) => const InventoryTransferScreen(),
            routes: [
              GoRoute(
                path: 'create',
                name: RouteNames.createInventoryTransfer,
                builder: (context, state) => const CreateInventoryTransferScreen(),
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.inventoryReport,
            name: RouteNames.inventoryReport,
            builder: (context, state) => const InventoryReportScreen(),
          ),
          GoRoute(
            path: RoutePaths.suppliers,
            name: RouteNames.suppliers,
            builder: (context, state) => const SuppliersScreen(),
            routes: [
              GoRoute(
                path: 'create',
                name: RouteNames.createSupplier,
                builder: (context, state) => const SupplierFormScreen(),
              ),
              GoRoute(
                path: 'edit',
                name: RouteNames.editSupplier,
                builder: (context, state) {
                  final supplier = state.extra as SupplierModel?;
                  return SupplierFormScreen(supplier: supplier);
                },
              ),
              GoRoute(
                path: 'detail/:id',
                name: RouteNames.supplierDetail,
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  final supplier = state.extra as SupplierModel?;
                  return SupplierDetailScreen(supplierId: id, supplier: supplier);
                },
              ),
              GoRoute(
                path: 'returns',
                name: RouteNames.supplierReturns,
                builder: (context, state) => const SupplierReturnsScreen(),
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.purchases,
            name: RouteNames.purchases,
            builder: (context, state) => const PurchasesScreen(),
            routes: [
              GoRoute(
                path: 'create',
                name: RouteNames.createPurchase,
                builder: (context, state) => const PurchaseFormScreen(),
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.quotations,
            name: RouteNames.quotations,
            builder: (context, state) => const QuotationsScreen(),
          ),
          GoRoute(
            path: RoutePaths.quotationCs,
            name: RouteNames.quotationCs,
            builder: (context, state) => const QuotationCsScreen(),
          ),
          GoRoute(
            path: RoutePaths.purchaseOrders,
            name: RouteNames.purchaseOrders,
            builder: (context, state) => const PurchaseOrdersScreen(),
          ),
          GoRoute(
            path: RoutePaths.goodsReceived,
            name: RouteNames.goodsReceived,
            builder: (context, state) => const GoodsReceivedScreen(),
          ),
          GoRoute(
            path: RoutePaths.qualityCheck,
            name: RouteNames.qualityCheck,
            builder: (context, state) => const QualityCheckScreen(),
          ),
          GoRoute(
            path: RoutePaths.receivedBills,
            name: RouteNames.receivedBills,
            builder: (context, state) => const ReceivedBillsScreen(),
          ),
          GoRoute(
            path: RoutePaths.cashBook,
            name: RouteNames.cashBook,
            builder: (context, state) => const CashBookScreen(),
            routes: [
              GoRoute(
                path: 'create',
                name: RouteNames.createCashBook,
                builder: (context, state) => const CashBookFormScreen(),
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.settings,
            name: RouteNames.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: RoutePaths.settingsPurchaseFlow,
            name: RouteNames.settingsPurchaseFlow,
            builder: (context, state) => const ManagePurchaseFlowScreen(),
          ),
          GoRoute(
            path: RoutePaths.hrDashboard,
            name: RouteNames.hrDashboard,
            builder: (context, state) => const HrDashboardScreen(),
          ),
          GoRoute(
            path: RoutePaths.hrEmployees,
            name: RouteNames.hrEmployees,
            builder: (context, state) => const HrEmployeesScreen(),
          ),
          GoRoute(
            path: RoutePaths.hrAddEmployee,
            name: RouteNames.hrAddEmployee,
            builder: (context, state) => const HrAddEmployeeScreen(),
          ),
          GoRoute(
            path: RoutePaths.hrEmployeeDetail,
            name: RouteNames.hrEmployeeDetail,
            builder: (context, state) {
              final employeeId = state.uri.queryParameters['id'] ?? '';
              return HrEmployeeDetailScreen(employeeId: employeeId);
            },
          ),
          GoRoute(
            path: RoutePaths.hrAttendance,
            name: RouteNames.hrAttendance,
            builder: (context, state) => const HrAttendanceScreen(),
          ),
          GoRoute(
            path: RoutePaths.hrPayroll,
            name: RouteNames.hrPayroll,
            builder: (context, state) => const HrPayrollScreen(),
          ),
          GoRoute(
            path: RoutePaths.hrLeaves,
            name: RouteNames.hrLeaves,
            builder: (context, state) => const HrLeaveScreen(),
          ),
          GoRoute(
            path: RoutePaths.hrOvertime,
            name: RouteNames.hrOvertime,
            builder: (context, state) => const HrOvertimeScreen(),
          ),
          GoRoute(
            path: RoutePaths.hrLoans,
            name: RouteNames.hrLoans,
            builder: (context, state) => const HrLoanScreen(),
          ),
          GoRoute(
            path: RoutePaths.hrEosb,
            name: RouteNames.hrEosb,
            builder: (context, state) => const HrEosbScreen(),
          ),
          GoRoute(
            path: RoutePaths.hrOrganogram,
            name: RouteNames.hrOrganogram,
            builder: (context, state) => const HrOrganogramScreen(),
          ),
          GoRoute(
            path: RoutePaths.hrPayrollPolicy,
            name: RouteNames.hrPayrollPolicy,
            builder: (context, state) => const HrPayrollPolicyScreen(),
          ),
          GoRoute(
            path: RoutePaths.accountingDashboard,
            name: RouteNames.accountingDashboard,
            builder: (context, state) => const AccountingDashboardScreen(initialTab: 0),
          ),
          GoRoute(
            path: RoutePaths.accountingLedger,
            name: RouteNames.accountingLedger,
            builder: (context, state) => const AccountingDashboardScreen(initialTab: 1),
          ),
          GoRoute(
            path: RoutePaths.accountingJournal,
            name: RouteNames.accountingJournal,
            builder: (context, state) => const JournalEntriesScreen(),
            routes: [
              GoRoute(
                path: 'create',
                name: RouteNames.accountingCreateJournal,
                builder: (context, state) => const CreateJournalEntryScreen(),
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.accountingCoA,
            name: RouteNames.accountingCoA,
            builder: (context, state) => const ChartOfAccountsScreen(),
          ),
          GoRoute(
            path: RoutePaths.accountingSettings,
            name: RouteNames.accountingSettings,
            builder: (context, state) => const AccountingSettingsScreen(initialTab: 0),
          ),
          GoRoute(
            path: RoutePaths.accountingIntegrationMapping,
            name: RouteNames.accountingIntegrationMapping,
            builder: (context, state) => const AccountingSettingsScreen(initialTab: 1),
          ),
          GoRoute(
            path: RoutePaths.accountingVouchers,
            name: RouteNames.accountingVouchers,
            builder: (context, state) => const VouchersScreen(),
          ),
          GoRoute(
            path: RoutePaths.voucherApproval,
            name: RouteNames.voucherApproval,
            builder: (context, state) => const VoucherApprovalScreen(),
          ),
          GoRoute(
            path: RoutePaths.voucherPolicy,
            name: RouteNames.voucherPolicy,
            builder: (context, state) => const AccountingSettingsScreen(initialTab: 0),
          ),
          GoRoute(
            path: RoutePaths.chequeManagement,
            name: RouteNames.chequeManagement,
            builder: (context, state) => const ChequeManagementScreen(),
          ),
          GoRoute(
            path: RoutePaths.settingsCostCenters,
            name: RouteNames.settingsCostCenters,
            builder: (context, state) => const CostCentersScreen(),
          ),
          GoRoute(
            path: RoutePaths.settingsBranches,
            name: RouteNames.settingsBranches,
            builder: (context, state) => const BranchesScreen(),
          ),
          GoRoute(
            path: RoutePaths.settingsProductPolicy,
            name: RouteNames.settingsProductPolicy,
            builder: (context, state) => const ProductPolicyScreen(),
          ),
          GoRoute(
            path: RoutePaths.settingsFinancialYears,
            name: RouteNames.settingsFinancialYears,
            builder: (context, state) => const FinancialYearsScreen(),
          ),
          GoRoute(
            path: RoutePaths.settingsRbacPermissions,
            name: RouteNames.settingsRbacPermissions,
            builder: (context, state) => const RbacPermissionsScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == RoutePaths.login;
      final isSplash = state.matchedLocation == RoutePaths.splash;

      if (!authState.isAuthenticated && !isLoggingIn && !isSplash) {
        return RoutePaths.login;
      }

      if (authState.isAuthenticated && isLoggingIn) {
        return RoutePaths.dashboard;
      }

      return null;
    },
  );
});
