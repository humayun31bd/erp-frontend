import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/loans_provider.dart';
import '../../providers/employees_provider.dart';

class HrLoanScreen extends ConsumerStatefulWidget {
  const HrLoanScreen({super.key});

  @override
  ConsumerState<HrLoanScreen> createState() => _HrLoanScreenState();
}

class _HrLoanScreenState extends ConsumerState<HrLoanScreen> {
  String? _selectedEmployeeId;

  @override
  Widget build(BuildContext context) {
    final loansAsync = ref.watch(loansProvider(_selectedEmployeeId));
    final employeesAsync = ref.watch(employeesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Salary Advances & Loans'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text('Filter by Employee: ', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                Expanded(
                  child: employeesAsync.when(
                    data: (employees) {
                      return DropdownButton<String?>(
                        value: _selectedEmployeeId,
                        isExpanded: true,
                        hint: const Text('All Employees'),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Employees')),
                          ...employees.map((e) => DropdownMenuItem(
                                value: e.id,
                                child: Text('${e.firstName} ${e.lastName}'),
                              )),
                        ],
                        onChanged: (val) => setState(() => _selectedEmployeeId = val),
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('Error loading employees'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: loansAsync.when(
              data: (records) {
                if (records.isEmpty) {
                  return const Center(child: Text('No loans found.'));
                }
                return ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text('${record.firstName} ${record.lastName} - ${record.amount} SAR'),
                        subtitle: Text(
                          'Instalment: ${record.monthlyInstallment} SAR/mo\n'
                          'Remaining: ${record.remainingAmount} SAR\n'
                          'Reason: ${record.reason ?? "N/A"}',
                        ),
                        trailing: _buildStatusChip(record.status),
                        isThreeLine: true,
                        onTap: () => _showUpdateStatusDialog(context, ref, record.id, record.status),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRequestLoanDialog(context, ref),
        icon: const Icon(Icons.money),
        label: const Text('Request Loan'),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'APPROVED':
      case 'ACTIVE':
      case 'COMPLETED':
        color = Colors.green;
        break;
      case 'REJECTED':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }
    return Chip(
      label: Text(status, style: const TextStyle(fontSize: 10, color: Colors.white)),
      backgroundColor: color,
    );
  }

  void _showUpdateStatusDialog(BuildContext context, WidgetRef ref, String recordId, String currentStatus) {
    String selectedStatus = currentStatus;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update Loan Status'),
              content: DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                items: ['PENDING', 'APPROVED', 'ACTIVE', 'COMPLETED', 'REJECTED']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => setState(() => selectedStatus = val!),
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final api = ref.read(hrApiProvider);
                      await api.updateLoanStatus(recordId, {'status': selectedStatus});
                      ref.invalidate(loansProvider);
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      }
    );
  }

  void _showRequestLoanDialog(BuildContext context, WidgetRef ref) {
    final employees = ref.read(employeesProvider).valueOrNull ?? [];
    String? selectedEmpId = _selectedEmployeeId ?? (employees.isNotEmpty ? employees.first.id : null);
    final amountController = TextEditingController();
    final installmentController = TextEditingController();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Request Loan/Advance'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedEmpId,
                      items: employees.map((e) => DropdownMenuItem(
                        value: e.id,
                        child: Text('${e.firstName} ${e.lastName}'),
                      )).toList(),
                      onChanged: (val) => setState(() => selectedEmpId = val),
                      decoration: const InputDecoration(labelText: 'Employee'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      decoration: const InputDecoration(labelText: 'Total Amount (SAR)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: installmentController,
                      decoration: const InputDecoration(labelText: 'Monthly Installment (SAR)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: reasonController,
                      decoration: const InputDecoration(labelText: 'Reason'),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedEmpId != null && amountController.text.isNotEmpty && installmentController.text.isNotEmpty) {
                      try {
                        final api = ref.read(hrApiProvider);
                        await api.requestLoan({
                          'employee_id': selectedEmpId,
                          'amount': amountController.text,
                          'monthly_installment': installmentController.text,
                          'reason': reasonController.text,
                        });
                        ref.invalidate(loansProvider);
                        if (context.mounted) Navigator.pop(context);
                      } catch (e) {
                         if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      }
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      }
    );
  }
}
