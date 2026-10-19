import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'erp_sidebar.dart';
import 'responsive_builder.dart';

class AppScaffold extends ConsumerWidget {
  final Widget child;
  
  const AppScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ResponsiveBuilder.isMobile(context);

    if (isMobile) {
      // ── Mobile: hamburger drawer ──
      return Scaffold(
        appBar: AppBar(
          title: const Text('Intelligent ERP'),
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
        ),
        drawer: const ErpMobileDrawer(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ErpBreadcrumbs(),
            Expanded(child: child),
          ],
        ),
      );
    }

    // ── Desktop / Tablet: persistent sidebar ──
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ErpSidebar(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar with breadcrumbs
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: const ErpBreadcrumbs(),
                ),
                // Content area
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
