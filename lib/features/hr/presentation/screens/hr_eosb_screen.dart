import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/employees_provider.dart';
import '../../providers/eosb_provider.dart';

class HrEosbScreen extends ConsumerStatefulWidget {
  const HrEosbScreen({super.key});

  @override
  ConsumerState<HrEosbScreen> createState() => _HrEosbScreenState();
}

class _HrEosbScreenState extends ConsumerState<HrEosbScreen> {
  String? _selectedEmployeeId;
  String _selectedReason = 'RESIGNATION';
  final _endDateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));

  @override
  void dispose() {
    _endDateController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (_selectedEmployeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an employee')));
      return;
    }
    if (_endDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter an end date')));
      return;
    }
    
    ref.read(eosbCalculationProvider.notifier).calculateEosb(
      employeeId: _selectedEmployeeId!,
      endDate: _endDateController.text,
      reason: _selectedReason,
    );
  }

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(employeesProvider);
    final eosbState = ref.watch(eosbCalculationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('End of Service Benefits (EOSB)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Calculate EOSB (KSA Labor Law)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            employeesAsync.when(
              data: (employees) => DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Employee', border: OutlineInputBorder()),
                initialValue: _selectedEmployeeId,
                items: employees.map((e) => DropdownMenuItem(
                  value: e.id,
                  child: Text('${e.firstName} ${e.lastName}'),
                )).toList(),
                onChanged: (val) => setState(() => _selectedEmployeeId = val),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (err, _) => Text('Error loading employees: $err'),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _endDateController,
              decoration: const InputDecoration(labelText: 'End Date (YYYY-MM-DD)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Reason for Leaving', border: OutlineInputBorder()),
              initialValue: _selectedReason,
              items: const [
                DropdownMenuItem(value: 'RESIGNATION', child: Text('Resignation')),
                DropdownMenuItem(value: 'TERMINATION', child: Text('Termination by Employer')),
              ],
              onChanged: (val) => setState(() => _selectedReason = val!),
            ),
            const SizedBox(height: 24),
            
            ElevatedButton(
              onPressed: eosbState.isLoading ? null : _calculate,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: eosbState.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Calculate Benefits'),
            ),
            
            const SizedBox(height: 32),
            
            if (eosbState.hasError)
              Text('Error: ${eosbState.error}', style: const TextStyle(color: Colors.red)),
              
            if (eosbState.hasValue && eosbState.value != null) ...[
              const Divider(),
              const SizedBox(height: 16),
              const Text('Calculation Results', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ResultRow('Years of Service', eosbState.value!['yearsOfService'].toString()),
                      _ResultRow('Basic Salary', 'SAR ${eosbState.value!['basicSalary']}'),
                      _ResultRow('Full Award', 'SAR ${eosbState.value!['fullAward']}'),
                      _ResultRow('Reason', eosbState.value!['reason']),
                      const Divider(),
                      _ResultRow('Payable Award', 'SAR ${eosbState.value!['payableAward']}', isBold: true),
                    ],
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _ResultRow(this.label, this.value, {this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 16)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 16)),
        ],
      ),
    );
  }
}
