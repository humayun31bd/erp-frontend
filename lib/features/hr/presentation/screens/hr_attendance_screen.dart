import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/employees_provider.dart';

class HrAttendanceScreen extends ConsumerStatefulWidget {
  const HrAttendanceScreen({super.key});

  @override
  ConsumerState<HrAttendanceScreen> createState() => _HrAttendanceScreenState();
}

class _HrAttendanceScreenState extends ConsumerState<HrAttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedEmployeeId;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final attendanceParams = {
      'startDate': dateStr,
      'endDate': dateStr,
      if (_selectedEmployeeId != null) 'employeeId': _selectedEmployeeId!,
    };
    
    final attendanceAsync = ref.watch(attendanceProvider(attendanceParams));
    final employeesAsync = ref.watch(employeesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  'Date: ${DateFormat.yMMMd().format(_selectedDate)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
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
            child: attendanceAsync.when(
              data: (records) {
                if (records.isEmpty) {
                  return const Center(child: Text('No attendance records for this date.'));
                }
                return ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return ListTile(
                      title: Text('Employee ID: ${record.employeeId}'),
                      subtitle: Text('Status: ${record.status}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (record.checkIn != null) Text('In: ${DateFormat.Hm().format(DateTime.parse(record.checkIn!))}'),
                              if (record.checkOut != null) Text('Out: ${DateFormat.Hm().format(DateTime.parse(record.checkOut!))}'),
                            ],
                          ),
                          if (record.checkIn != null && record.checkOut == null)
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: ElevatedButton(
                                onPressed: () async {
                                  final api = ref.read(hrApiProvider);
                                  await api.updateAttendance(record.id, {
                                    'check_out': DateTime.now().toIso8601String(),
                                  });
                                  
                                  final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
                                  ref.invalidate(attendanceProvider({
                                    'startDate': dateStr,
                                    'endDate': dateStr,
                                    if (_selectedEmployeeId != null) 'employeeId': _selectedEmployeeId!,
                                  }));
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  backgroundColor: Colors.orange.withValues(alpha: 0.1),
                                  foregroundColor: Colors.orange,
                                ),
                                child: const Text('Clock Out'),
                              ),
                            )
                        ],
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
        onPressed: () {
          _showMarkAttendanceDialog(context, ref);
        },
        icon: const Icon(Icons.add_task),
        label: const Text('Mark Attendance'),
      ),
    );
  }

  void _showMarkAttendanceDialog(BuildContext context, WidgetRef ref) {
    // Basic dialog implementation to record attendance
    final employees = ref.read(employeesProvider).valueOrNull ?? [];
    String? selectedEmpId = _selectedEmployeeId ?? (employees.isNotEmpty ? employees.first.id : null);
    String status = 'PRESENT';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Mark Attendance'),
              content: Column(
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
                    initialValue: status,
                    items: ['PRESENT', 'ABSENT', 'LATE', 'LEAVE']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) => setState(() => status = val!),
                    decoration: const InputDecoration(labelText: 'Status'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedEmpId != null) {
                      final api = ref.read(hrApiProvider);
                      await api.recordAttendance({
                        'employee_id': selectedEmpId,
                        'date': DateTime.now().toIso8601String(),
                        'status': status,
                        'check_in': status == 'PRESENT' || status == 'LATE' ? DateTime.now().toIso8601String() : null,
                      });
                      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
                      ref.invalidate(attendanceProvider({
                        'startDate': dateStr,
                        'endDate': dateStr,
                        if (_selectedEmployeeId != null) 'employeeId': _selectedEmployeeId!,
                      }));
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      }
    );
  }
}
