import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../clients/domain/client_model.dart';
import '../../../clients/providers/client_provider.dart';
import '../../providers/pos_provider.dart';
import 'customer_form_modal.dart';

class CustomerSelectionModal extends ConsumerStatefulWidget {
  const CustomerSelectionModal({super.key});

  @override
  ConsumerState<CustomerSelectionModal> createState() => _CustomerSelectionModalState();
}

class _CustomerSelectionModalState extends ConsumerState<CustomerSelectionModal> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final clientsState = ref.watch(clientsProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 900,
        height: 650,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
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
                  const Row(
                    children: [
                      Icon(Icons.people_alt_outlined, color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Text('Select Customer', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            
            // Search & Actions
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search by Name / Phone / Loyalty ID...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2)),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.person_add, color: Colors.white),
                    label: const Text('New Customer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BFA5), // Vibrant Teal
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      final newCustomer = await showDialog<ClientModel>(
                        context: context, 
                        builder: (_) => const CustomerFormModal()
                      );
                      if (newCustomer != null) {
                        ref.read(selectedCustomerProvider.notifier).state = newCustomer;
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),
            
            // Customer List
            Expanded(
              child: Container(
                color: Colors.grey.shade50,
                child: clientsState.when(
                  data: (clients) {
                    final filtered = clients.where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                                                          (c.phoneNumber != null && c.phoneNumber!.contains(_searchQuery))).toList();
                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_off_outlined, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text('No customers found.', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                          ],
                        )
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final c = filtered[index];
                        final balance = (c.funds ?? 0) - (c.dues ?? 0);
                        
                        return InkWell(
                          autofocus: index == 0,
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            ref.read(selectedCustomerProvider.notifier).state = c;
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: const Color(0xFF1A237E).withValues(alpha: 0.1),
                                  child: const Icon(Icons.person, color: Color(0xFF1A237E)),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.phone, size: 14, color: Colors.grey.shade500),
                                          const SizedBox(width: 4),
                                          Text(c.phoneNumber ?? 'N/A', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Credit Status', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            c.permitCredit && c.creditLimit > 0 ? Icons.check_circle_outline : Icons.block,
                                            size: 14,
                                            color: c.permitCredit && c.creditLimit > 0 ? Colors.green.shade700 : Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            c.permitCredit && c.creditLimit > 0
                                                ? 'Limit SAR ${c.creditLimit.toStringAsFixed(2)}'
                                                : 'Credit Disabled',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: c.permitCredit && c.creditLimit > 0 ? Colors.green.shade800 : Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if ((c.dues ?? 0) > 0)
                                        Text(
                                          'Dues: SAR ${c.dues!.toStringAsFixed(2)}',
                                          style: TextStyle(color: Colors.red.shade700, fontSize: 11, fontWeight: FontWeight.w600),
                                        ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('Wallet Balance', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text(
                                        'SAR ${balance.toStringAsFixed(2)}', 
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold, 
                                          fontSize: 16,
                                          color: balance < 0 ? const Color(0xFFEF5350) : const Color(0xFF00BFA5)
                                        )
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF1A237E))),
                  error: (e, _) => Center(child: Text('Failed to load customers: $e', style: const TextStyle(color: Colors.red))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
