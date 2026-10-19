import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/leave_provider.dart';
import '../../providers/employees_provider.dart';

class HrLeaveScreen extends ConsumerStatefulWidget {
  const HrLeaveScreen({super.key});

  @override
  ConsumerState<HrLeaveScreen> createState() => _HrLeaveScreenState();
}

class _HrLeaveScreenState extends ConsumerState<HrLeaveScreen> {
  String? _selectedEmployeeId;

  @override
  Widget build(BuildContext context) {
    final leavesAsync = ref.watch(leavesProvider(_selectedEmployeeId));
    final employeesAsync = ref.watch(employeesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Management'),
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
            child: leavesAsync.when(
              data: (records) {
                if (records.isEmpty) {
                  return const Center(child: Text('No leave requests found.'));
                }
                return ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text('${record.firstName} ${record.lastName} - ${record.leaveType}'),
                        subtitle: Text(
                          'From: ${DateFormat.yMMMd().format(DateTime.parse(record.startDate))}\n'
                          'To: ${DateFormat.yMMMd().format(DateTime.parse(record.endDate))} (${record.durationDays} days)\n'
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
        onPressed: () => _showRequestLeaveDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Request Leave'),
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
      case 'MANAGER_APPROVED':
        color = Colors.blue;
        break;
      default:
        color = Colors.orange;
    }
    return Chip(
      label: Text(status, style: const TextStyle(fontSize: 10, color: Colors.white)),
      backgroundColor: color,
    );
  }

  void _showUpdateStatusDialog(BuildContext context, WidgetRef ref, String leaveId, String currentStatus) {
    String selectedStatus = currentStatus;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update Leave Status'),
              content: DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                items: ['PENDING', 'MANAGER_APPROVED', 'APPROVED', 'REJECTED']
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
                      await api.updateLeaveRequest(leaveId, {'status': selectedStatus});
                      ref.invalidate(leavesProvider);
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

  void _showRequestLeaveDialog(BuildContext context, WidgetRef ref) {
    final employees = ref.read(employeesProvider).valueOrNull ?? [];
    String? selectedEmpId = _selectedEmployeeId ?? (employees.isNotEmpty ? employees.first.id : null);
    String leaveType = 'Annual';
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 1));
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Request Leave'),
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
                    DropdownButtonFormField<String>(
                      initialValue: leaveType,
                      items: ['Annual', 'Sick', 'Unpaid', 'Maternity', 'Paternity']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (val) => setState(() => leaveType = val!),
                      decoration: const InputDecoration(labelText: 'Leave Type'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            icon: const Icon(Icons.calendar_today),
                            label: Text('Start: ${DateFormat.MMMd().format(startDate)}'),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: startDate,
                                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) setState(() => startDate = picked);
                            },
                          ),
                        ),
                        Expanded(
                          child: TextButton.icon(
                            icon: const Icon(Icons.calendar_today),
                            label: Text('End: ${DateFormat.MMMd().format(endDate)}'),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: endDate,
                                firstDate: startDate,
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) setState(() => endDate = picked);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: reasonController,
                      decoration: const InputDecoration(labelText: 'Reason (optional)'),
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
                    if (selectedEmpId != null) {
                      try {
                        final api = ref.read(hrApiProvider);
                        await api.createLeaveRequest({
                          'employee_id': selectedEmpId,
                          'leave_type': leaveType,
                          'start_date': startDate.toIso8601String(),
                          'end_date': endDate.toIso8601String(),
                          'reason': reasonController.text,
                        });
                        ref.invalidate(leavesProvider);
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
