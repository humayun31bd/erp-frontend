import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../../../app.dart';
import '../../domain/label_print_model.dart';
import '../../providers/label_printer_provider.dart';
import '../../utils/label_pdf_generator.dart';
import '../widgets/label_product_queue_table.dart';
import '../widgets/label_settings_panel.dart';

/// Screen for generating and printing product barcodes, QR codes, and sheet labels.
class PrintLabelsScreen extends ConsumerStatefulWidget {
  const PrintLabelsScreen({super.key});

  @override
  ConsumerState<PrintLabelsScreen> createState() => _PrintLabelsScreenState();
}

class _PrintLabelsScreenState extends ConsumerState<PrintLabelsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleDirectPrint(
    List<LabelItem> queue,
    LabelDisplaySettings settings,
    LabelSheetPreset preset,
  ) async {
    final isArabic = ref.read(localeProvider).languageCode == 'ar';
    if (queue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic ? 'يرجى إضافة منتج واحد على الأقل إلى قائمة الانتظار قبل الطباعة.' : 'Please add at least one product to the queue before printing.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isPrinting = true);
    try {
      await Printing.layoutPdf(
        name: 'Product_Labels_${DateTime.now().millisecondsSinceEpoch}.pdf',
        onLayout: (PdfPageFormat format) async {
          return await LabelPdfGenerator.generateLabelsDoc(
            items: queue,
            settings: settings,
            preset: preset,
          );
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${isArabic ? "فشلت الطباعة: " : "Printing failed: "}$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPrinting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final queue = ref.watch(labelQueueProvider);
    final totalCount = ref.watch(totalLabelsCountProvider);
    final settings = ref.watch(labelSettingsProvider);
    final preset = ref.watch(labelPresetProvider);
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1050;

          return Column(
            children: [
              // 1. TOP HEADER & ACTION BAR
              _buildTopBar(context, queue, totalCount, settings, preset, isArabic),

              // 2. MAIN WORKSPACE
              Expanded(
                child: isDesktop
                    ? _buildDesktopLayout(queue, totalCount, settings, preset, isArabic)
                    : _buildMobileTabletLayout(queue, totalCount, settings, preset, isArabic),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    List<LabelItem> queue,
    int totalCount,
    LabelDisplaySettings settings,
    LabelSheetPreset preset,
    bool isArabic,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.qr_code_2, color: theme.colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      isArabic ? 'طباعة ملصقات الباركود والمنتجات' : 'Print Product Labels & Barcodes',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        preset.name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  isArabic ? 'اختر المنتجات، خصص تفاصيل الملصق واطبع على أوراق مقصوصة أو رولات حرارية.' : 'Select products, customize label details & print on pre-cut sheets or thermal continuous rolls.',
                  style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              final current = ref.read(localeProvider);
              ref.read(localeProvider.notifier).state =
                  current.languageCode == 'en' ? const Locale('ar') : const Locale('en');
            },
            tooltip: isArabic ? 'تغيير اللغة' : 'Switch Language',
          ),
          const SizedBox(width: 12),
          // Quick Stats Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.style_outlined, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  '$totalCount',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  isArabic ? 'ملصق في الانتظار' : 'Labels Queued',
                  style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Direct Print Button
          ElevatedButton.icon(
            onPressed: _isPrinting ? null : () => _handleDirectPrint(queue, settings, preset),
            icon: _isPrinting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.print, size: 18),
            label: Text(
              _isPrinting ? (isArabic ? 'جاري الطباعة...' : 'Printing...') : (isArabic ? 'طباعة الملصقات ($totalCount)' : 'Print Labels ($totalCount)'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  /// Two-column layout for desktop displays (Left: Queue & Settings, Right: WYSIWYG Live Preview)
  Widget _buildDesktopLayout(
    List<LabelItem> queue,
    int totalCount,
    LabelDisplaySettings settings,
    LabelSheetPreset preset,
    bool isArabic,
  ) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // LEFT COLUMN: TABS (Products Queue & Label Settings)
        Expanded(
          flex: 6,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                // Inner TabBar
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor: theme.textTheme.bodySmall?.color,
                    indicatorColor: theme.colorScheme.primary,
                    indicatorWeight: 3,
                    tabs: [
                      Tab(
                        icon: const Icon(Icons.format_list_bulleted, size: 18),
                        text: isArabic ? 'قائمة المنتجات (${queue.length})' : 'Products Queue (${queue.length})',
                      ),
                      Tab(
                        icon: const Icon(Icons.tune, size: 18),
                        text: isArabic ? 'إعدادات الملصق والورق' : 'Label & Paper Settings',
                      ),
                    ],
                  ),
                ),
                // Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      LabelProductQueueTable(),
                      LabelSettingsPanel(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // RIGHT COLUMN: LIVE PDF PREVIEW
        Expanded(
          flex: 5,
          child: Container(
            margin: const EdgeInsets.fromLTRB(0, 16, 16, 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
            ),
            child: _buildPreviewPane(queue, settings, preset, isArabic),
          ),
        ),
      ],
    );
  }

  /// Responsive layout for mobile and tablet screens
  Widget _buildMobileTabletLayout(
    List<LabelItem> queue,
    int totalCount,
    LabelDisplaySettings settings,
    LabelSheetPreset preset,
    bool isArabic,
  ) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            labelColor: Theme.of(context).colorScheme.primary,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: [
              Tab(text: isArabic ? 'القائمة (${queue.length})' : 'Queue (${queue.length})'),
              Tab(text: isArabic ? 'الإعدادات' : 'Settings'),
              Tab(text: isArabic ? 'المعاينة' : 'Preview'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                const LabelProductQueueTable(),
                const LabelSettingsPanel(),
                _buildPreviewPane(queue, settings, preset, isArabic),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Live WYSIWYG Preview widget powered by `PdfPreview`
  Widget _buildPreviewPane(
    List<LabelItem> queue,
    LabelDisplaySettings settings,
    LabelSheetPreset preset,
    bool isArabic,
  ) {
    final theme = Theme.of(context);

    if (queue.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  size: 54,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isArabic ? 'لا توجد منتجات في قائمة الانتظار' : 'No Products in Queue',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                isArabic ? 'أضف منتجات باستخدام جدول القائمة لإنشاء معاينة ملصقات باركود حية.' : 'Add products using the queue table to instantly generate a live WYSIWYG barcode preview.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Unique key so PdfPreview regenerates when items, copies, preset, or settings change
    final previewKey = ValueKey(
      'preview_${queue.length}_${queue.fold<int>(0, (acc, item) => acc + item.copiesCount)}_${preset.name}_${settings.hashCode}',
    );

    return Column(
      children: [
        // Header for Preview Panel
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border(bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.visibility_outlined, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    isArabic ? 'معاينة الطباعة الحية' : 'Live Print Preview',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
              Text(
                preset.description,
                style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color),
              ),
            ],
          ),
        ),

        // Live PDF Preview Widget
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            child: PdfPreview(
              key: previewKey,
              build: (PdfPageFormat format) async {
                return await LabelPdfGenerator.generateLabelsDoc(
                  items: queue,
                  settings: settings,
                  preset: preset,
                );
              },
              canChangePageFormat: false,
              canChangeOrientation: false,
              canDebug: false,
              dynamicLayout: false,
              previewPageMargin: const EdgeInsets.all(12),
              pdfFileName: 'product_labels.pdf',
              loadingWidget: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(isArabic ? 'جاري عرض صفحات الملصقات...' : 'Rendering label pages...', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
