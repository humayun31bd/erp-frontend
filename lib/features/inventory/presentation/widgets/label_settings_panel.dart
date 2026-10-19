import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/label_print_model.dart';
import '../../providers/label_printer_provider.dart';

/// Interactive configuration panel for label presets and display toggles.
class LabelSettingsPanel extends ConsumerWidget {
  const LabelSettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(labelSettingsProvider);
    final selectedPreset = ref.watch(labelPresetProvider);
    final settingsNotifier = ref.read(labelSettingsProvider.notifier);
    final presetNotifier = ref.read(labelPresetProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. PAPER & SHEET PRESET SELECTOR
          _buildPresetCard(context, selectedPreset, presetNotifier),
          const SizedBox(height: 16),

          // 2. SHOP INFORMATION
          _buildShopInfoCard(context, settings, settingsNotifier),
          const SizedBox(height: 16),

          // 3. PRODUCT & SYMBOLOGY
          _buildProductAndSymbologyCard(context, settings, settingsNotifier),
          const SizedBox(height: 16),

          // 4. TRACKING, BATCH & EXPIRY
          _buildTrackingCard(context, settings, settingsNotifier),
          const SizedBox(height: 16),

          // 5. PRICE INFORMATION
          _buildPriceCard(context, settings, settingsNotifier),
          const SizedBox(height: 16),

          // 6. LABEL DIMENSIONS & METADATA
          _buildDimensionsCard(context, settings, settingsNotifier),
        ],
      ),
    );
  }

  Widget _buildPresetCard(
    BuildContext context,
    LabelSheetPreset selectedPreset,
    LabelPresetNotifier notifier,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.print_outlined, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Paper & Barcode Setting Presets',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<LabelSheetPreset>(
                  value: selectedPreset,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: LabelSheetPreset.values.map((preset) {
                    return DropdownMenuItem<LabelSheetPreset>(
                      value: preset,
                      child: Text(
                        preset.name,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      notifier.setPreset(val);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Specifications Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Type:',
                        style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                      ),
                      Text(
                        selectedPreset.isRoll ? 'Continuous Roll (Thermal)' : 'Standard Sheet (Laser/Inkjet)',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sheet Size:',
                        style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                      ),
                      Text(
                        '${selectedPreset.sheetWidthInches}" x ${selectedPreset.sheetHeightInches}"',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Label Size:',
                        style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                      ),
                      Text(
                        '${selectedPreset.labelWidthInches}" x ${selectedPreset.labelHeightInches}"',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Grid Layout:',
                        style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                      ),
                      Text(
                        selectedPreset.isRoll
                            ? 'Single Label Stream'
                            : '${selectedPreset.columns} Cols x ${selectedPreset.rows} Rows (${selectedPreset.labelsPerPage} per page)',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopInfoCard(
    BuildContext context,
    LabelDisplaySettings settings,
    LabelSettingsNotifier notifier,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: Icon(Icons.storefront_outlined, color: theme.colorScheme.primary, size: 20),
        title: Text(
          'Shop Information',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Store header, contact info, and branding', style: TextStyle(fontSize: 11)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          _buildSwitchRow(
            title: 'Shop Name',
            subtitle: settings.shopName,
            value: settings.showShopName,
            onChanged: notifier.toggleShopName,
          ),
          _buildSwitchRow(
            title: 'Shop Address',
            subtitle: settings.shopAddress,
            value: settings.showShopAddress,
            onChanged: notifier.toggleShopAddress,
          ),
          _buildSwitchRow(
            title: 'Shop Phone',
            subtitle: settings.shopPhone,
            value: settings.showShopPhone,
            onChanged: notifier.toggleShopPhone,
          ),
          _buildSwitchRow(
            title: 'Shop Email',
            subtitle: settings.shopEmail,
            value: settings.showShopEmail,
            onChanged: notifier.toggleShopEmail,
          ),
          _buildSwitchRow(
            title: 'Shop Logo Badge',
            subtitle: 'Include store logo symbol',
            value: settings.showShopLogo,
            onChanged: notifier.toggleShopLogo,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _showEditShopDialog(context, settings, notifier),
            icon: const Icon(Icons.edit_note, size: 16),
            label: const Text('Edit Shop Details Text', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductAndSymbologyCard(
    BuildContext context,
    LabelDisplaySettings settings,
    LabelSettingsNotifier notifier,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: Icon(Icons.qr_code_scanner, color: theme.colorScheme.primary, size: 20),
        title: Text(
          'Product & Symbology',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Barcode, QR code, title & HSN', style: TextStyle(fontSize: 11)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          _buildSwitchRow(
            title: 'Product Name & Variants',
            subtitle: 'Show item title and attribute variations',
            value: settings.showProductName,
            onChanged: notifier.toggleProductName,
          ),
          _buildSwitchRow(
            title: 'HSN Code',
            subtitle: 'Harmonized System Nomenclature code',
            value: settings.showHsnCode,
            onChanged: notifier.toggleHsnCode,
          ),
          const Divider(height: 20),
          _buildSwitchRow(
            title: '1D Barcode (Code-128)',
            subtitle: 'Standard linear barcode for scanners',
            value: settings.showBarcode,
            onChanged: notifier.toggleBarcode,
          ),
          _buildSwitchRow(
            title: 'Barcode Human-Readable Text',
            subtitle: 'Display numeric/SKU digits under barcode',
            value: settings.showBarcodeText,
            onChanged: notifier.toggleBarcodeText,
          ),
          _buildSwitchRow(
            title: '2D QR Code',
            subtitle: 'Compact 2D matrix symbology',
            value: settings.showQrCode,
            onChanged: notifier.toggleQrCode,
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingCard(
    BuildContext context,
    LabelDisplaySettings settings,
    LabelSettingsNotifier notifier,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: Icon(Icons.timelapse_outlined, color: Colors.orange.shade700, size: 20),
        title: Text(
          'Tracking & Batch Info',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Expiry, batch, serial number & packing date', style: TextStyle(fontSize: 11)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber.shade800, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Enabling these activates their columns in the products queue table and generates composite barcode data.',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          _buildSwitchRow(
            title: 'Expiry Date Required (Y/N)',
            subtitle: 'Show Expiry Date on label & table',
            value: settings.requireExpiryDate,
            onChanged: notifier.toggleRequireExpiry,
          ),
          _buildSwitchRow(
            title: 'Batch Number Required (Y/N)',
            subtitle: 'Show Batch Number on label & table',
            value: settings.requireBatchNumber,
            onChanged: notifier.toggleRequireBatch,
          ),
          _buildSwitchRow(
            title: 'Serial Number Required (Y/N)',
            subtitle: 'Show Serial Number on label & table',
            value: settings.requireSerialNumber,
            onChanged: notifier.toggleRequireSerial,
          ),
          _buildSwitchRow(
            title: 'Packing Date (Y/N)',
            subtitle: 'Show Packing Date (PKD) on label',
            value: settings.showPackingDate,
            onChanged: notifier.togglePackingDate,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(
    BuildContext context,
    LabelDisplaySettings settings,
    LabelSettingsNotifier notifier,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        leading: Icon(Icons.attach_money_outlined, color: Colors.green.shade700, size: 20),
        title: Text(
          'Price Information',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Retail, wholesale, and discounted prices', style: TextStyle(fontSize: 11)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          _buildSwitchRow(
            title: 'Retail Price (Y/N)',
            subtitle: 'Standard selling price (e.g. SAR 150.00)',
            value: settings.showRetailPrice,
            onChanged: notifier.toggleRetailPrice,
          ),
          _buildSwitchRow(
            title: 'Wholesale Price (Y/N)',
            subtitle: 'Distributor/B2B price tier',
            value: settings.showWholesalePrice,
            onChanged: notifier.toggleWholesalePrice,
          ),
          _buildSwitchRow(
            title: 'Discount Price (Y/N)',
            subtitle: 'Sale price with crossed retail rate',
            value: settings.showDiscountPrice,
            onChanged: notifier.toggleDiscountPrice,
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionsCard(
    BuildContext context,
    LabelDisplaySettings settings,
    LabelSettingsNotifier notifier,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.straighten_outlined, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Label Sizing Info',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildSwitchRow(
              title: 'Print Label Dimensions',
              subtitle: 'Display label physical size in label corner (e.g. 2"x1")',
              value: settings.showLabelDimensions,
              onChanged: notifier.toggleDimensions,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  void _showEditShopDialog(
    BuildContext context,
    LabelDisplaySettings settings,
    LabelSettingsNotifier notifier,
  ) {
    final nameCtrl = TextEditingController(text: settings.shopName);
    final addrCtrl = TextEditingController(text: settings.shopAddress);
    final phoneCtrl = TextEditingController(text: settings.shopPhone);
    final emailCtrl = TextEditingController(text: settings.shopEmail);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.store, size: 20),
            SizedBox(width: 8),
            Text('Edit Store Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Shop Name', isDense: true),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addrCtrl,
                decoration: const InputDecoration(labelText: 'Shop Address', isDense: true),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Shop Phone', isDense: true),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Shop Email', isDense: true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              notifier.setShopDetails(
                name: nameCtrl.text.trim(),
                address: addrCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                email: emailCtrl.text.trim(),
              );
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
