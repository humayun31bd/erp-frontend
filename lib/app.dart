import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/l10n/app_localizations.dart';
import 'core/services/security_service.dart';

// Provide the current locale
final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));
// Provide the current theme mode
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

class IntelligentErpApp extends ConsumerStatefulWidget {
  const IntelligentErpApp({super.key});

  @override
  ConsumerState<IntelligentErpApp> createState() => _IntelligentErpAppState();
}

class _IntelligentErpAppState extends ConsumerState<IntelligentErpApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Enforce anti-phishing/secure mode immediately on startup
    SecurityService.enableSecureMode();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-assert secure mode when coming from background to prevent overlay injections
      SecurityService.enableSecureMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    final goRouter = ref.watch(goRouterProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Intelligent ERP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: goRouter,
    );
  }
}
