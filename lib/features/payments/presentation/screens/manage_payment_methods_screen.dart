import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/payment_method_provider.dart';

/// Settings sub-page: Manage Payment Methods
/// Accessible via Settings → Payment Methods
class ManagePaymentMethodsScreen extends ConsumerStatefulWidget {
  const ManagePaymentMethodsScreen({super.key});

  @override
  ConsumerState<ManagePaymentMethodsScreen> createState() =>
      _ManagePaymentMethodsScreenState();
}

class _ManagePaymentMethodsScreenState
    extends ConsumerState<ManagePaymentMethodsScreen> {
  void _showAddMethodDialog() {
    final nameController = TextEditingController();
    final nameArController = TextEditingController();
    Color selectedColor = const Color(0xFF1565C0);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text(
            'Add Payment Method',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Method Name (English)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.payment),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameArController,
                  textDirection: TextDirection.rtl,
                  decoration: const InputDecoration(
                    labelText: 'اسم طريقة الدفع (عربي)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.payment),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Color: '),
                    const SizedBox(width: 8),
                    ...([
                      const Color(0xFF2E7D32),
                      const Color(0xFF1565C0),
                      const Color(0xFF6A1B9A),
                      const Color(0xFFE65100),
                      const Color(0xFF37474F),
                      const Color(0xFFC62828),
                    ].map((c) => GestureDetector(
                          onTap: () => setDialogState(() => selectedColor = c),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedColor == c
                                    ? Colors.black
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                          ),
                        ))),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;
                final id =
                    nameController.text.trim().toLowerCase().replaceAll(' ', '_');
                ref.read(paymentMethodProvider.notifier).add(
                      PaymentMethod(
                        id: id,
                        name: nameController.text.trim(),
                        nameAr: nameArController.text.trim().isEmpty
                            ? nameController.text.trim()
                            : nameArController.text.trim(),
                        icon: Icons.payment,
                        color: selectedColor,
                      ),
                    );
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final methods = ref.watch(paymentMethodProvider);
    final notifier = ref.read(paymentMethodProvider.notifier);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                const Icon(Icons.payment, size: 24, color: Colors.indigo),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Methods',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Manage which payment methods appear in the POS checkout.',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Method'),
                  onPressed: _showAddMethodDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Methods List
          Expanded(
            child: methods.isEmpty
                ? const Center(child: Text('No payment methods configured.'))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: methods.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 72),
                    itemBuilder: (context, index) {
                      final method = methods[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: method.color.withValues(alpha: 0.15),
                          child: Icon(method.icon, color: method.color),
                        ),
                        title: Row(
                          children: [
                            Text(
                              method.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                            const SizedBox(width: 8),
                            if (method.isDefault)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.green[200]!),
                                ),
                                child: Text(
                                  'DEFAULT',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Text(
                          method.nameAr,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Set as Default
                            if (!method.isDefault)
                              Tooltip(
                                message: 'Set as Default',
                                child: IconButton(
                                  icon: const Icon(Icons.star_border,
                                      color: Colors.amber),
                                  onPressed: () =>
                                      notifier.setDefault(method.id),
                                ),
                              )
                            else
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.star,
                                    color: Colors.amber, size: 20),
                              ),
                            // Toggle Active
                            Switch(
                              value: method.isActive,
                              activeThumbColor: method.color,
                              onChanged: method.isDefault
                                  ? null // default method cannot be disabled
                                  : (_) => notifier.toggleActive(method.id),
                            ),
                            // Delete (non-cash only)
                            if (method.id != 'cash')
                              Tooltip(
                                message: 'Remove',
                                child: IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Remove Method'),
                                        content: Text(
                                            'Remove "${method.name}" from payment methods?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red),
                                            onPressed: () {
                                              notifier.remove(method.id);
                                              Navigator.pop(ctx);
                                            },
                                            child: const Text('Remove',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
