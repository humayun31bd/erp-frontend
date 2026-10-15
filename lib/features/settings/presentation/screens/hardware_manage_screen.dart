import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/hardware_provider.dart';
import '../../../pos/providers/receipt_printer_service.dart';

class HardwareManageScreen extends ConsumerStatefulWidget {
  const HardwareManageScreen({super.key});

  @override
  ConsumerState<HardwareManageScreen> createState() => _HardwareManageScreenState();
}

class _HardwareManageScreenState extends ConsumerState<HardwareManageScreen> {
  @override
  Widget build(BuildContext context) {
    final availablePrintersAsync = ref.watch(availablePrintersProvider);
    final defaultPrinterAsync = ref.watch(defaultPrinterProvider);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hardware & Printers',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage connected thermal receipt printers, cash drawers, and barcode scanners.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            
            // Current Default Printer
            const Text(
              'Default POS Printer',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            defaultPrinterAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, st) => Text('Error loading default printer: $e'),
              data: (defaultPrinter) {
                if (defaultPrinter == null) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      border: Border.all(color: Colors.amber),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.amber),
                        SizedBox(width: 8),
                        Text('No default POS printer selected. Printing will use system dialog.', style: TextStyle(color: Colors.amber)),
                      ],
                    ),
                  );
                }
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.print, color: Colors.green),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(defaultPrinter.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(defaultPrinter.url, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.receipt_long),
                        label: const Text('Test Print'),
                        onPressed: () {
                          ReceiptPrinterService.printTestReceipt(printer: defaultPrinter);
                        },
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.red),
                        onPressed: () async {
                          await ref.read(hardwareServiceProvider).clearDefaultPrinter();
                          ref.invalidate(defaultPrinterProvider);
                        },
                        tooltip: 'Clear Default Printer',
                      )
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 32),

            // Available Printers List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Available Printers',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    ref.invalidate(availablePrintersProvider);
                  },
                  tooltip: 'Refresh Printers',
                )
              ],
            ),
            const SizedBox(height: 16),
            
            if (kIsWeb)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('Web Browser detected. Direct printing is restricted by browsers. '
                          'To print silently to a receipt printer, please use the Desktop (Windows/Mac) app, '
                          'or use the standard browser print dialog.'),
                    ),
                  ],
                ),
              ),
              
            const SizedBox(height: 16),
            Expanded(
              child: availablePrintersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Failed to load printers: $e')),
                data: (printers) {
                  if (printers.isEmpty) {
                    if (kIsWeb) {
                      return const Center(child: Text('Browsers do not expose local printers directly.'));
                    }
                    return const Center(child: Text('No printers found on this system.'));
                  }
                  return ListView.builder(
                    itemCount: printers.length,
                    itemBuilder: (context, index) {
                      final printer = printers[index];
                      return ListTile(
                        leading: const Icon(Icons.print),
                        title: Text(printer.name),
                        subtitle: Text(printer.model ?? printer.url),
                        trailing: ElevatedButton(
                          onPressed: () async {
                            await ref.read(hardwareServiceProvider).setDefaultPrinter(printer);
                            ref.invalidate(defaultPrinterProvider);
                            if (context.mounted) {
                               ScaffoldMessenger.of(context).showSnackBar(
                                 SnackBar(content: Text('${printer.name} set as default.')),
                               );
                            }
                          },
                          child: const Text('Set as Default'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
