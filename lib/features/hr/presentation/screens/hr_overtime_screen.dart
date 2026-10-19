import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/overtime_provider.dart';
import '../../providers/employees_provider.dart';

class HrOvertimeScreen extends ConsumerStatefulWidget {
  const HrOvertimeScreen({super.key});

  @override
  ConsumerState<HrOvertimeScreen> createState() => _HrOvertimeScreenState();
}

class _HrOvertimeScreenState extends ConsumerState<HrOvertimeScreen> {
  String? _selectedEmployeeId;

  @override
  Widget build(BuildContext context) {
    final overtimeAsync = ref.watch(overtimeProvider(_selectedEmployeeId));
    final employeesAsync = ref.watch(employeesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Overtime Tracking'),
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
            child: overtimeAsync.when(
              data: (records) {
                if (records.isEmpty) {
                  return const Center(child: Text('No overtime records found.'));
                }
                return ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text('${record.firstName} ${record.lastName}'),
                        subtitle: Text(
                          'Date: ${DateFormat.yMMMd().format(DateTime.parse(record.date))}\n'
                          'Hours: ${record.hours}\n'
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
        onPressed: () => _showLogOvertimeDialog(context, ref),
        icon: const Icon(Icons.timer),
        label: const Text('Log Overtime'),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'APPROVED':
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
              title: const Text('Update Overtime Status'),
              content: DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                items: ['PENDING', 'APPROVED', 'REJECTED']
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
                      await api.updateOvertimeStatus(recordId, {'status': selectedStatus});
                      ref.invalidate(overtimeProvider);
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

  void _showLogOvertimeDialog(BuildContext context, WidgetRef ref) {
    final employees = ref.read(employeesProvider).valueOrNull ?? [];
    String? selectedEmpId = _selectedEmployeeId ?? (employees.isNotEmpty ? employees.first.id : null);
    DateTime date = DateTime.now();
    final hoursController = TextEditingController();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Log Overtime'),
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
                    TextButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text('Date: ${DateFormat.yMMMd().format(date)}'),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: date,
                          firstDate: DateTime.now().subtract(const Duration(days: 30)),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) setState(() => date = picked);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: hoursController,
                      decoration: const InputDecoration(labelText: 'Hours (Max 2.0)'),
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
                    if (selectedEmpId != null && hoursController.text.isNotEmpty) {
                      try {
                        final api = ref.read(hrApiProvider);
                        await api.logOvertime({
                          'employee_id': selectedEmpId,
                          'date': date.toIso8601String(),
                          'hours': hoursController.text,
                          'reason': reasonController.text,
                        });
                        ref.invalidate(overtimeProvider);
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
