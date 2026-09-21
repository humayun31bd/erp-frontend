import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'route_names.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/invoicing/presentation/screens/invoice_list_screen.dart';
import '../../features/invoicing/presentation/screens/create_invoice_screen.dart';
import '../../features/invoicing/presentation/screens/invoice_detail_screen.dart';
import '../../features/clients/presentation/clients_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../shared/widgets/app_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: RoutePaths.dashboard,
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isGoingToLogin = state.matchedLocation == RoutePaths.login;

      // If not authenticated and not going to login, redirect to login
      if (!isAuth && !isGoingToLogin) {
        return RoutePaths.login;
      }
      
      // If authenticated and going to login, redirect to dashboard
      if (isAuth && isGoingToLogin) {
        return RoutePaths.dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
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
            path: RoutePaths.invoices,
            name: RouteNames.invoices,
            builder: (context, state) => const InvoiceListScreen(),
            routes: [
              GoRoute(
                path: RoutePaths.createInvoice,
                name: RouteNames.createInvoice,
                builder: (context, state) => const CreateInvoiceScreen(),
              ),
              GoRoute(
                path: RoutePaths.invoiceDetail,
                name: RouteNames.invoiceDetail,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return InvoiceDetailScreen(invoiceId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.clients,
            name: RouteNames.clients,
            builder: (context, state) => const ClientsScreen(),
          ),
          GoRoute(
            path: RoutePaths.settings,
            name: RouteNames.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
