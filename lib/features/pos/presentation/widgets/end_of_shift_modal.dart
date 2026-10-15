import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/shift_provider.dart';
import '../../providers/receipt_printer_service.dart';
import '../../../../features/settings/providers/hardware_provider.dart';

class EndOfShiftModal extends ConsumerStatefulWidget {
  const EndOfShiftModal({Key? key}) : super(key: key);

  @override
  ConsumerState<EndOfShiftModal> createState() => _EndOfShiftModalState();
}

class _EndOfShiftModalState extends ConsumerState<EndOfShiftModal> {
  final _actualCashController = TextEditingController();
  final _notesController = TextEditingController();
  
  bool _isLoading = true;
  ShiftReport? _report;
  double _variance = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchReport();
    _actualCashController.addListener(_calculateVariance);
  }
  
  @override
  void dispose() {
    _actualCashController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchReport() async {
    final report = await ref.read(shiftProvider.notifier).generateReport();
    if (mounted) {
      setState(() {
        _report = report;
        _isLoading = false;
        // Default actual cash to expected to start
        _actualCashController.text = report.expectedCash.toStringAsFixed(2);
      });
      _calculateVariance();
    }
  }

  void _calculateVariance() {
    if (_report == null) return;
    final actual = double.tryParse(_actualCashController.text) ?? 0.0;
    setState(() {
      _variance = actual - _report!.expectedCash;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Dialog(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Generating Z-Report...')
            ],
          ),
        ),
      );
    }

    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('End of Shift (Z-Report)', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Divider(),
            
            // System Calculated Totals
            Text('Card Sales: \$${_report!.totalCardSales.toStringAsFixed(2)}'),
            Text('Refunds: \$${_report!.totalRefunds.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.blue.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Expected Cash in Drawer:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('\$${_report!.expectedCash.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Cashier Input
            TextField(
              controller: _actualCashController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Actual Counted Cash',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Variance Display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Variance (Over/Short):'),
                Text(
                  '\$${_variance.toStringAsFixed(2)}', 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    color: _variance == 0 ? Colors.green : Colors.red,
                    fontSize: 16
                  )
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Closing Notes (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('CANCEL'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () async {
                    if (_report == null) return;
                    final actual = double.tryParse(_actualCashController.text) ?? 0.0;
                    bool success = await ref.read(shiftProvider.notifier).closeShift(actual, _notesController.text);
                    if (success && context.mounted) {
                      final printer = await ref.read(defaultPrinterProvider.future);
                      await ReceiptPrinterService.printZReport(
                        report: _report!,
                        actualCash: actual,
                        variance: _variance,
                        notes: _notesController.text,
                        printer: printer,
                      );
                      
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shift Closed Successfully! Z-Report printed.')));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('CLOSE SHIFT & PRINT'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
