import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'register_session_report_modal.dart';
import '../../providers/counter_session_provider.dart';
import '../../providers/counter_provider.dart';
import '../../domain/counter_model.dart';

class CounterSessionManagementDialog extends ConsumerStatefulWidget {
  const CounterSessionManagementDialog({super.key});

  @override
  ConsumerState<CounterSessionManagementDialog> createState() => _CounterSessionManagementDialogState();
}

class _CounterSessionManagementDialogState extends ConsumerState<CounterSessionManagementDialog> {
  CounterModel? _selectedCounter;
  final _transferCtrl = TextEditingController(text: '0.00');
  final _pinCtrl = TextEditingController();
  bool _showReport = false;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 700,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF1A237E), // Deep Navy
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.point_of_sale_sharp, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      const Text('Terminal Session', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (_selectedCounter != null)
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      icon: const Icon(Icons.receipt_long, size: 18),
                      label: const Text('Z-Report Summary'),
                      onPressed: () {
                        showRegisterSessionReportModal(context);
                      },
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                ],
              ),
            ),
            
            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _isAuthenticated ? _buildCounterPicker() : _buildLogin(),
              ),
            ),
            
            if (_isAuthenticated && _selectedCounter != null)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildCounterPicker() {
    final countersAsync = ref.watch(countersProvider);
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select a Counter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          const Text('Tap a counter to manage its session.', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 16),
          countersAsync.when(
            data: (counters) {
              if (counters.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.point_of_sale_outlined, size: 48, color: Colors.orange),
                      SizedBox(height: 12),
                      Text('No counters found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 4),
                      Text('Please add a counter in the settings first.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }
              if (_selectedCounter != null) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Selected: ${_selectedCounter!.name} (${_selectedCounter!.branchName})',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue[800]),
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Change Counter'),
                      onPressed: () => setState(() => _selectedCounter = null),
                    ),
                  ],
                );
              }
              return GridView.count(
                crossAxisCount: counters.length == 1 ? 1 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
                children: counters.map((c) {
                  final isSelected = _selectedCounter?.id == c.id;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCounter = c;
                        _showReport = false;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue[50] : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.blue[700]! : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue[700] : Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.point_of_sale,
                              color: isSelected ? Colors.white : Colors.grey[600], size: 22),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(c.name, style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isSelected ? Colors.blue[800] : Colors.black87,
                                )),
                                Text(c.branchName, style: TextStyle(
                                  color: isSelected ? Colors.blue[400] : Colors.grey[500],
                                  fontSize: 12,
                                )),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_circle, color: Colors.blue[700]),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Loading counters...', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            error: (e, _) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Failed to load counters: $e', style: const TextStyle(color: Colors.red))),
                  TextButton(onPressed: () => ref.refresh(countersProvider), child: const Text('Retry')),
                ],
              ),
            ),
          ),
          if (_selectedCounter != null) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 4),
            _showReport ? _buildCounterReport() : _buildSessionInfo(),
          ],
        ],
      ),
    );
  }



  Widget _buildLogin() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        const Icon(Icons.admin_panel_settings, size: 64, color: Color(0xFF1A237E)),
        const SizedBox(height: 24),
        const Text('Terminal Authentication', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF1A237E))),
        const SizedBox(height: 8),
        const Text('Enter Manager/Cashier PIN to manage session.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 15)),
        const SizedBox(height: 32),
        TextField(
          controller: _pinCtrl,
          decoration: InputDecoration(
            labelText: 'Secure PIN Code',
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2)),
            prefixIcon: const Icon(Icons.password, color: Color(0xFF1A237E)),
          ),
          obscureText: true,
          obscuringCharacter: '●',
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          onPressed: () {
            if (_pinCtrl.text.isNotEmpty) {
              setState(() => _isAuthenticated = true);
            }
          },
          child: const Text('AUTHENTICATE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
        ),
      ],
    );
  }

  Widget _buildCounterReport() {
    final sessionAsync = ref.watch(currentSessionProvider(_selectedCounter!.id));

    return sessionAsync.when(
      data: (session) {
        if (session == null) {
          return const Center(child: Text('No active session report available. Please open a session first.'));
        }
        
        final opening = double.tryParse(session.openingBalance) ?? 0.0;
        final sales = double.tryParse(session.cashSales) ?? 0.0;
        final transfer = double.tryParse(session.transferAmount) ?? 0.0;
        final expectedClosing = opening - transfer + sales;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Z-Report Preview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Opening Time'),
              trailing: Text(session.openedAt.toLocal().toString().split('.')[0]),
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('Opening Balance'),
              trailing: Text('SAR ${opening.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.point_of_sale, color: Color(0xFF00BFA5)),
              title: const Text('Cash Sales'),
              trailing: Text('+ SAR ${sales.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF00BFA5), fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.local_shipping_outlined, color: Color(0xFFEF5350)),
              title: const Text('Transfer / Cash Drop'),
              trailing: Text('- SAR ${transfer.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFFEF5350))),
            ),
            const Divider(),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF1A237E).withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Expected Closing Balance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A237E))),
                  Text('SAR ${expectedClosing.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
    );
  }

  final Map<double, TextEditingController> _denomCtrls = {
    500.0: TextEditingController(),
    200.0: TextEditingController(),
    100.0: TextEditingController(),
    50.0: TextEditingController(),
    10.0: TextEditingController(),
    5.0: TextEditingController(),
    1.0: TextEditingController(),
    0.50: TextEditingController(),
    0.25: TextEditingController(),
  };

  double get _calculatedTotal {
    double total = 0;
    _denomCtrls.forEach((value, ctrl) {
      final count = int.tryParse(ctrl.text) ?? 0;
      total += value * count;
    });
    return total;
  }

  Widget _buildSessionInfo() {
    final sessionAsync = ref.watch(currentSessionProvider(_selectedCounter!.id));

    return sessionAsync.when(
      data: (session) {
        if (session == null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: const Color(0xFFEF5350).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Row(
                  children: [
                    Icon(Icons.lock_clock, color: Color(0xFFEF5350)),
                    SizedBox(width: 8),
                    Text('STATUS: CLOSED', style: TextStyle(color: Color(0xFFEF5350), fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Count Starting Cash (Opening Balance):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2.8,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: _denomCtrls.entries.map((e) {
                  return TextField(
                    controller: e.value,
                    decoration: InputDecoration(
                      labelText: '${e.key} SAR',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    onChanged: (_) => setState(() {}),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text('Total Counted: SAR ${_calculatedTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF00BFA5))),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.play_circle_fill),
                  label: _isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('OPEN TERMINAL SHIFT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : () async {
                    setState(() => _isLoading = true);
                    final success = await ref.read(sessionControllerProvider.notifier).openSession(
                      counterId: _selectedCounter!.id,
                      openingBalance: _calculatedTotal,
                    );
                    setState(() => _isLoading = false);
                    if (success) {
                      for (var ctrl in _denomCtrls.values) {
                        ctrl.clear();
                      }
                      ref.invalidate(currentSessionProvider(_selectedCounter!.id));
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session opened successfully.')));
                        Navigator.pop(context);
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to open session.'), backgroundColor: Color(0xFFEF5350)));
                      }
                    }
                  },
                ),
              ),
            ],
          );
        } else {
          final opening = double.tryParse(session.openingBalance) ?? 0.0;
          final sales = double.tryParse(session.cashSales) ?? 0.0;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: const Color(0xFF00BFA5).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Row(
                  children: [
                    Icon(Icons.lock_open, color: Color(0xFF00BFA5)),
                    SizedBox(width: 8),
                    Text('STATUS: OPEN', style: TextStyle(color: Color(0xFF00BFA5), fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Opened At:'), Text(session.openedAt.toLocal().toString().split('.')[0], style: const TextStyle(fontWeight: FontWeight.bold))]),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Opening Balance:'), Text('SAR ${opening.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold))]),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Cash Sales (System):'), Text('SAR ${sales.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00BFA5)))]),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Count Cash in Drawer (SAR Denominations):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2.8,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: _denomCtrls.entries.map((e) {
                  return TextField(
                    controller: e.value,
                    decoration: InputDecoration(
                      labelText: '${e.key} SAR',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    onChanged: (_) => setState(() {}),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text('Total Counted: SAR ${_calculatedTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1A237E))),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _transferCtrl,
                decoration: InputDecoration(
                  labelText: 'Cash Drop / Transfer Amount (SAR)', 
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2)),
                  prefixIcon: const Icon(Icons.price_change, color: Color(0xFF1A237E)),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BFA5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        ref.read(sessionControllerProvider.notifier).resumeSession(session);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.point_of_sale),
                      label: const Text('CONTINUE SELLING', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () async {
                      final transfer = double.tryParse(_transferCtrl.text) ?? 0.0;
                      setState(() => _isLoading = true);
                      final success = await ref.read(sessionControllerProvider.notifier).closeSession(
                        sessionId: session.id,
                        transferAmount: transfer,
                        cashSales: sales,
                      );
                      setState(() => _isLoading = false);
                      if (success) {
                        ref.invalidate(currentSessionProvider(_selectedCounter!.id));
                        
                        if (!mounted) return;
                        showDialog(
                          context: context, 
                          builder: (_) => Dialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.receipt_long, size: 64, color: Color(0xFF1A237E)),
                                  const SizedBox(height: 24),
                                  const Text('Session Closed', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
                                    child: const Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [Icon(Icons.check_circle, color: Color(0xFF00BFA5), size: 20), SizedBox(width: 8), Text('Opening Cash Drawer...')]),
                                        SizedBox(height: 12),
                                        Row(children: [Icon(Icons.check_circle, color: Color(0xFF00BFA5), size: 20), SizedBox(width: 8), Text('Printing Z-Report...')]),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context); // close info dialog
                                        Navigator.pop(context); // close main dialog
                                      },
                                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                      child: const Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ]
                              )
                            )
                          )
                        );
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to close session.'), backgroundColor: Color(0xFFEF5350)));
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF5350),
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('CLOSE SHIFT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ),
                ],
              ),
            ],
          );
        }
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF1A237E))),
      error: (e, st) => Center(child: Text('Error: $e', style: const TextStyle(color: Color(0xFFEF5350)))),
    );
  }
}

Future<void> showCounterSessionManager(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (ctx) => const CounterSessionManagementDialog(),
  );
}
