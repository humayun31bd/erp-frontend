import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/app_localizations.dart';
import 'manage_branches_screen.dart';
import 'manage_warehouses_screen.dart';
import 'manage_taxes_screen.dart';
import 'product_settings_screen.dart';
import 'marketing_plans_screen.dart';
import 'manage_products_screen.dart';
import '../../../core/providers/custom_translation_provider.dart';
import '../../payments/presentation/screens/manage_payment_methods_screen.dart';
import '../providers/csid_provider.dart';
import 'screens/cost_centers_screen.dart';
import 'screens/hardware_manage_screen.dart';
import 'manage_counters_screen.dart';
import 'manage_users_screen.dart';
import 'tenant_info_settings_screen.dart';
import 'screens/financial_years_screen.dart';
import 'screens/rbac_permissions_screen.dart';
import 'screens/manage_purchase_flow_screen.dart';
import 'smtp_settings_screen.dart';
import 'manage_websites_screen.dart';

import 'screens/voucher_entry_policy_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDesktop = MediaQuery.of(context).size.width > 800;

    Widget content = const LanguageSettingsContent();
    if (_selectedIndex == 1) {
      content = const ManageBranchesContent();
    } else if (_selectedIndex == 2) {
      content = const MarketingPlansScreen();
    } else if (_selectedIndex == 3) {
      content = const ManageWarehousesContent();
    } else if (_selectedIndex == 4) {
      content = const ManageTaxesContent();
    } else if (_selectedIndex == 5) {
      content = const ProductSettingsContent();
    } else if (_selectedIndex == 6) {
      content = const ManageProductsContent();
    } else if (_selectedIndex == 7) {
      content = const ManagePaymentMethodsScreen();
    } else if (_selectedIndex == 8) {
      content = const ZatcaSettingsContent();
    } else if (_selectedIndex == 9) {
      content = const CostCentersScreen();
    } else if (_selectedIndex == 10) {
      content = const HardwareManageScreen();
    } else if (_selectedIndex == 11) {
      content = const ManageCountersContent();
    } else if (_selectedIndex == 12) {
      content = const ManageUsersContent();
    } else if (_selectedIndex == 13) {
      content = const TenantInfoSettingsContent();
    } else if (_selectedIndex == 14) {
      content = const FinancialYearsScreen();
    } else if (_selectedIndex == 15) {
      content = const RbacPermissionsScreen();
    } else if (_selectedIndex == 16) {
      content = const ManagePurchaseFlowScreen();
    } else if (_selectedIndex == 17) {
      content = const SmtpSettingsContent();
    } else if (_selectedIndex == 18) {
      content = const VoucherEntryPolicyContent();
    } else if (_selectedIndex == 19) {
      content = const ManageWebsitesScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Sidebar
          Container(
            width: isDesktop ? 250 : 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                right: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: ListView(
                children: [
                  ExpansionTile(
                    leading: const Icon(Icons.business),
                    title: isDesktop ? const Text('MANAGE OFFICE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)) : const SizedBox.shrink(),
                    initiallyExpanded: [1, 3, 9, 11].contains(_selectedIndex),
                    childrenPadding: const EdgeInsets.only(left: 16),
                    children: [
                      ListTile(
                        leading: const Icon(Icons.store),
                        title: isDesktop ? Text(l10n.manageBranches) : null,
                        selected: _selectedIndex == 1,
                        onTap: () => setState(() => _selectedIndex = 1),
                      ),
                      ListTile(
                        leading: const Icon(Icons.warehouse_outlined),
                        title: isDesktop ? const Text('Manage Warehouses') : null,
                        selected: _selectedIndex == 3,
                        onTap: () => setState(() => _selectedIndex = 3),
                      ),
                      ListTile(
                        leading: const Icon(Icons.business_center_outlined),
                        title: isDesktop ? const Text('Cost Centers') : null,
                        selected: _selectedIndex == 9,
                        onTap: () => setState(() => _selectedIndex = 9),
                      ),
                      ListTile(
                        leading: const Icon(Icons.point_of_sale),
                        title: isDesktop ? const Text('Manage Counters') : null,
                        selected: _selectedIndex == 11,
                        onTap: () => setState(() => _selectedIndex = 11),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    leading: const Icon(Icons.inventory),
                    title: isDesktop ? const Text('MANAGE INVENTORY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)) : const SizedBox.shrink(),
                    initiallyExpanded: [5, 6, 16].contains(_selectedIndex),
                    childrenPadding: const EdgeInsets.only(left: 16),
                    children: [
                      ListTile(
                        leading: const Icon(Icons.alt_route_outlined),
                        title: isDesktop ? const Text('Manage Purchase Flow') : null,
                        selected: _selectedIndex == 16,
                        onTap: () => setState(() => _selectedIndex = 16),
                      ),
                      ListTile(
                        leading: const Icon(Icons.category_outlined),
                        title: isDesktop ? const Text('Manage Products') : null,
                        selected: _selectedIndex == 6,
                        onTap: () => setState(() => _selectedIndex = 6),
                      ),
                      ListTile(
                        leading: const Icon(Icons.inventory_2_outlined),
                        title: isDesktop ? const Text('Product Settings') : null,
                        selected: _selectedIndex == 5,
                        onTap: () => setState(() => _selectedIndex = 5),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    leading: const Icon(Icons.devices),
                    title: isDesktop ? const Text('DEVICES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)) : const SizedBox.shrink(),
                    initiallyExpanded: _selectedIndex == 10,
                    childrenPadding: const EdgeInsets.only(left: 16),
                    children: [
                      ListTile(
                        leading: const Icon(Icons.print_outlined),
                        title: isDesktop ? const Text('Hardware & Printers') : null,
                        selected: _selectedIndex == 10,
                        onTap: () => setState(() => _selectedIndex = 10),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    leading: const Icon(Icons.group),
                    title: isDesktop ? const Text('MANAGE USERS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)) : const SizedBox.shrink(),
                    initiallyExpanded: [12, 15].contains(_selectedIndex),
                    childrenPadding: const EdgeInsets.only(left: 16),
                    children: [
                      ListTile(
                        leading: const Icon(Icons.people_outline),
                        title: isDesktop ? const Text('Manage Users') : null,
                        selected: _selectedIndex == 12,
                        onTap: () => setState(() => _selectedIndex = 12),
                      ),
                      ListTile(
                        leading: const Icon(Icons.admin_panel_settings_outlined),
                        title: isDesktop ? const Text('RBAC & Menu Permissions') : null,
                        selected: _selectedIndex == 15,
                        onTap: () => setState(() => _selectedIndex = 15),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    leading: const Icon(Icons.account_balance_rounded),
                    title: isDesktop ? const Text('ACCOUNTING SETTINGS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)) : const SizedBox.shrink(),
                    initiallyExpanded: [14, 18].contains(_selectedIndex),
                    childrenPadding: const EdgeInsets.only(left: 16),
                    children: [
                      ListTile(
                        leading: const Icon(Icons.policy_rounded),
                        title: isDesktop ? const Text('Voucher Entry Policy') : null,
                        selected: _selectedIndex == 18,
                        onTap: () => setState(() => _selectedIndex = 18),
                      ),
                      ListTile(
                        leading: const Icon(Icons.calendar_month_rounded),
                        title: isDesktop ? const Text('Financial Year & Period Lock') : null,
                        selected: _selectedIndex == 14,
                        onTap: () => setState(() => _selectedIndex = 14),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    leading: const Icon(Icons.settings),
                    title: isDesktop ? const Text('GENERAL SETTINGS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)) : const SizedBox.shrink(),
                    initiallyExpanded: [0, 2, 4, 7, 8, 13, 17, 19].contains(_selectedIndex),
                    childrenPadding: const EdgeInsets.only(left: 16),
                    children: [
                      ListTile(
                        leading: const Icon(Icons.language_rounded),
                        title: isDesktop ? const Text('Client Websites') : null,
                        selected: _selectedIndex == 19,
                        onTap: () => setState(() => _selectedIndex = 19),
                      ),
                      ListTile(
                        leading: const Icon(Icons.business_rounded),
                        title: isDesktop ? const Text('Tenant & Business Profile') : null,
                        selected: _selectedIndex == 13,
                        onTap: () => setState(() => _selectedIndex = 13),
                      ),
                      ListTile(
                        leading: const Icon(Icons.email_outlined),
                        title: isDesktop ? const Text('SMTP Email Setup') : null,
                        selected: _selectedIndex == 17,
                        onTap: () => setState(() => _selectedIndex = 17),
                      ),
                      ListTile(
                        leading: const Icon(Icons.language),
                        title: isDesktop ? Text(l10n.languageSettings) : null,
                        selected: _selectedIndex == 0,
                        onTap: () => setState(() => _selectedIndex = 0),
                      ),
                      ListTile(
                        leading: const Icon(Icons.receipt_outlined),
                        title: isDesktop ? const Text('Manage Taxes') : null,
                        selected: _selectedIndex == 4,
                        onTap: () => setState(() => _selectedIndex = 4),
                      ),
                      ListTile(
                        leading: const Icon(Icons.payment_outlined),
                        title: isDesktop ? const Text('Payment Methods') : null,
                        selected: _selectedIndex == 7,
                        onTap: () => setState(() => _selectedIndex = 7),
                      ),
                      ListTile(
                        leading: const Icon(Icons.star_outline),
                        title: isDesktop ? const Text('Marketing Plans') : null,
                        selected: _selectedIndex == 2,
                        onTap: () => setState(() => _selectedIndex = 2),
                      ),
                      ListTile(
                        leading: const Icon(Icons.security),
                        title: isDesktop ? const Text('ZATCA Integration') : null,
                        selected: _selectedIndex == 8,
                        onTap: () => setState(() => _selectedIndex = 8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // Main Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: content,
            ),
          ),
        ],
      ),
    );
  }
}

class LanguageSettingsContent extends ConsumerStatefulWidget {
  const LanguageSettingsContent({super.key});

  @override
  ConsumerState<LanguageSettingsContent> createState() => _LanguageSettingsContentState();
}

class _LanguageSettingsContentState extends ConsumerState<LanguageSettingsContent> {
  String _searchQuery = '';
  int _currentPage = 0;
  final int _pageSize = 10;

  void _editLabel(String key, Map<String, String> currentTranslations) {
    final l10n = AppLocalizations.of(context)!;
    final enController = TextEditingController(text: currentTranslations["en"]);
    final arController = TextEditingController(text: currentTranslations["ar"]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${l10n.update}: $key'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: enController,
                decoration: InputDecoration(labelText: l10n.englishValue),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: arController,
                decoration: InputDecoration(labelText: l10n.arabicValue),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final notifier = ref.read(customTranslationProvider.notifier);
                
                try {
                  await notifier.updateTranslation(key, enController.text, arController.text);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Updated $key')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update $key')),
                    );
                  }
                }
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final translationState = ref.watch(customTranslationProvider);

    // Initial default fallback keys if API is empty
    final List<Map<String, String>> defaultLabels = [
      {"key": "dashboard", "en": "Dashboard", "ar": "لوحة القيادة"},
      {"key": "invoices", "en": "Invoices", "ar": "الفواتير"},
      {"key": "customers", "en": "Customers", "ar": "العملاء"},
      {"key": "settings", "en": "Settings", "ar": "الإعدادات"},
      {"key": "logout", "en": "Logout", "ar": "تسجيل الخروج"},
    ];

    // Combine defaults with backend overrides
    List<Map<String, String>> combinedLabels = [];
    for (var defaultLabel in defaultLabels) {
      final key = defaultLabel["key"]!;
      final backendOverride = translationState.translations[key];
      combinedLabels.add({
        "key": key,
        "en": backendOverride?["en"] ?? defaultLabel["en"]!,
        "ar": backendOverride?["ar"] ?? defaultLabel["ar"]!,
      });
    }

    // Add any backend keys that aren't in defaults
    translationState.translations.forEach((key, value) {
      if (!combinedLabels.any((l) => l["key"] == key)) {
        combinedLabels.add({
          "key": key,
          "en": value["en"]!,
          "ar": value["ar"]!,
        });
      }
    });

    if (translationState.isLoading && translationState.translations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Filter
    final filteredLabels = combinedLabels.where((label) {
      final q = _searchQuery.toLowerCase();
      return (label["key"]?.toLowerCase().contains(q) ?? false) ||
             (label["en"]?.toLowerCase().contains(q) ?? false) ||
             (label["ar"]?.toLowerCase().contains(q) ?? false);
    }).toList();

    // Paginate
    final totalPages = (filteredLabels.length / _pageSize).ceil();
    if (_currentPage >= totalPages && totalPages > 0) {
      _currentPage = totalPages - 1;
    }
    final startIndex = _currentPage * _pageSize;
    final endIndex = (startIndex + _pageSize > filteredLabels.length) ? filteredLabels.length : startIndex + _pageSize;
    final paginatedLabels = filteredLabels.sublist(startIndex, endIndex);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  l10n.languageSettings,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 300,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search label key...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                        _currentPage = 0;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columns: [
                    DataColumn(label: Text(l10n.labelKey, style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text(l10n.englishValue, style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text(l10n.arabicValue, style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text(l10n.actions, style: const TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: paginatedLabels.map((label) {
                    return DataRow(
                      cells: [
                        DataCell(Text(label["key"]!)),
                        DataCell(Text(label["en"]!)),
                        DataCell(Text(label["ar"]!)),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => _editLabel(label["key"]!, {"en": label["en"]!, "ar": label["ar"]!}),
                            tooltip: l10n.update,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Showing ${filteredLabels.isEmpty ? 0 : startIndex + 1} to $endIndex of ${filteredLabels.length}'),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _currentPage > 0 ? () {
                        setState(() {
                          _currentPage--;
                        });
                      } : null,
                    ),
                    Text('Page ${_currentPage + 1} of ${totalPages == 0 ? 1 : totalPages}'),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _currentPage < totalPages - 1 ? () {
                        setState(() {
                          _currentPage++;
                        });
                      } : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ZatcaSettingsContent extends ConsumerStatefulWidget {
  const ZatcaSettingsContent({super.key});

  @override
  ConsumerState<ZatcaSettingsContent> createState() => _ZatcaSettingsContentState();
}

class _ZatcaSettingsContentState extends ConsumerState<ZatcaSettingsContent> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(csidStatusProvider);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: statusAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error loading CSID status: $e')),
          data: (status) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ZATCA Phase 2 Integration',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Manage your Cryptographic Stamp Identifiers (CSID) and connect to the FATOORA portal.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                
                // Status Badges
                Row(
                  children: [
                    _buildStatusBadge('Compliance CSID', status.hasCompliance),
                    const SizedBox(width: 16),
                    _buildStatusBadge('Production CSID', status.hasProduction),
                  ],
                ),
                const SizedBox(height: 32),

                // Compliance CSID Section
                const Text(
                  'Compliance CSID (CCSID)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _otpController,
                        decoration: const InputDecoration(
                          labelText: 'FATOORA Portal OTP',
                          border: OutlineInputBorder(),
                          helperText: 'Enter the 6-digit OTP generated from the ZATCA portal.',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : () async {
                        setState(() => _isLoading = true);
                        try {
                          final api = ref.read(csidApiProvider);
                          await api.generateComplianceCsid({'otp': _otpController.text});
                          ref.invalidate(csidStatusProvider);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('CCSID generated successfully!')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error generating CCSID: $e')),
                            );
                          }
                        } finally {
                          setState(() => _isLoading = false);
                        }
                      },
                      icon: _isLoading 
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                        : const Icon(Icons.security),
                      label: const Text('Generate CCSID'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 32),
                
                // Production CSID Section
                const Text(
                  'Production CSID (PCSID)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  status.hasCompliance 
                    ? 'Compliance CSID is active. You can now generate the Production CSID.'
                    : 'A Compliance CSID is required before generating a Production CSID.',
                  style: TextStyle(color: status.hasCompliance ? Colors.green : Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: (!status.hasCompliance || _isLoading) ? null : () async {
                    setState(() => _isLoading = true);
                    try {
                      final api = ref.read(csidApiProvider);
                      await api.generateProductionCsid({'complianceRequestId': status.complianceRequestId});
                      ref.invalidate(csidStatusProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('PCSID generated successfully!')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error generating PCSID: $e')),
                        );
                      }
                    } finally {
                      setState(() => _isLoading = false);
                    }
                  },
                  icon: const Icon(Icons.verified),
                  label: const Text('Generate Production CSID'),
                ),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String title, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isActive ? Colors.green : Colors.red),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isActive ? Icons.check_circle : Icons.cancel, 
               color: isActive ? Colors.green : Colors.red, size: 16),
          const SizedBox(width: 8),
          Text(
            '$title: ${isActive ? 'Active' : 'Missing'}',
            style: TextStyle(
              color: isActive ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

