import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erp_frontend/app.dart';
import 'package:erp_frontend/features/settings/presentation/screens/voucher_entry_policy_screen.dart';
import 'package:erp_frontend/features/accounting/presentation/screens/account_mapping_screen.dart';

class AccountingSettingsScreen extends ConsumerStatefulWidget {
  final int initialTab;
  const AccountingSettingsScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<AccountingSettingsScreen> createState() => _AccountingSettingsScreenState();
}

class _AccountingSettingsScreenState extends ConsumerState<AccountingSettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, initialIndex: widget.initialTab.clamp(0, 1), vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.settings_suggest_rounded, color: Colors.indigo),
            const SizedBox(width: 10),
            Text(isArabic ? 'إعدادات المحاسبة (Accounting Settings)' : 'Accounting Settings'),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.indigo.shade700,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: Colors.indigo.shade700,
          indicatorWeight: 3,
          tabs: [
            Tab(
              icon: const Icon(Icons.pin_outlined),
              text: isArabic ? 'صيغة ترقيم وسياسات السندات' : 'Voucher Numbering & Policy',
            ),
            Tab(
              icon: const Icon(Icons.hub_outlined),
              text: isArabic ? 'ربط وتعيين الحسابات التلقائي' : 'Account Mappings (Linkage)',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: VoucherEntryPolicyContent(),
          ),
          AccountMappingScreen(),
        ],
      ),
    );
  }
}
