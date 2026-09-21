import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app.dart'; // To access localeProvider

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'الإعدادات' : 'Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(isArabic ? 'اللغة' : 'Language'),
                  trailing: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'en', label: Text('English')),
                      ButtonSegment(value: 'ar', label: Text('العربية')),
                    ],
                    selected: {isArabic ? 'ar' : 'en'},
                    onSelectionChanged: (Set<String> newSelection) {
                      final lang = newSelection.first;
                      ref.read(localeProvider.notifier).state = Locale(lang, lang == 'ar' ? 'SA' : 'US');
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: Text(isArabic ? 'الوضع الداكن' : 'Dark Mode'),
                  trailing: Switch(
                    value: Theme.of(context).brightness == Brightness.dark,
                    onChanged: (val) {
                      // Note: We need a ThemeProvider to properly toggle this globally.
                      // For now, this is a placeholder UI toggle.
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(isArabic ? 'سيتم تفعيله قريباً' : 'Coming soon in global state')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
            ),
            child: ListTile(
              leading: const Icon(Icons.business_center),
              title: Text(isArabic ? 'إعدادات الوكالة' : 'Agency Settings'),
              subtitle: Text(isArabic ? 'إدارة المستأجرين والعلامة البيضاء' : 'Manage Tenants & White-label'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
