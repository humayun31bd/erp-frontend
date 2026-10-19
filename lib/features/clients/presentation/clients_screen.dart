// Re-export the real grid screen as the canonical ClientsScreen
export 'screens/client_list_screen.dart' show CustomerGridScreen;

import 'package:flutter/material.dart';
import 'screens/client_list_screen.dart';

/// Top-level entry point used by the router for the /customers route.
class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context) => const CustomerGridScreen();
}
