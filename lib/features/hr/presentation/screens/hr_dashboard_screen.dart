import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/employees_provider.dart';

class HrDashboardScreen extends ConsumerWidget {
  const HrDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesAsyncValue = ref.watch(employeesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('HR Dashboard'),
      ),
      body: employeesAsyncValue.when(
        data: (employees) {
          final totalEmployees = employees.length;
          final activeEmployees = employees.where((e) => e.status == 'ACTIVE').length;
          
          final now = DateTime.now();
          final upcomingIqamaExpiries = employees.where((e) {
            if (e.iqamaExpiryDate == null) return false;
            final expiry = DateTime.tryParse(e.iqamaExpiryDate!);
            if (expiry == null) return false;
            final diff = expiry.difference(now).inDays;
            return diff >= 0 && diff <= 30; // Expiring in next 30 days
          }).length;

          final upcomingPassportExpiries = employees.where((e) {
            if (e.passportExpiryDate == null) return false;
            final expiry = DateTime.tryParse(e.passportExpiryDate!);
            if (expiry == null) return false;
            final diff = expiry.difference(now).inDays;
            return diff >= 0 && diff <= 30;
          }).length;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(employeesProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard(
                      'Total Employees',
                      totalEmployees.toString(),
                      Icons.people,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'Active Employees',
                      activeEmployees.toString(),
                      Icons.how_to_reg,
                      Colors.green,
                    ),
                    _buildStatCard(
                      'Iqama Expiring (30 days)',
                      upcomingIqamaExpiries.toString(),
                      Icons.warning_amber,
                      upcomingIqamaExpiries > 0 ? Colors.orange : Colors.grey,
                    ),
                    _buildStatCard(
                      'Passport Expiring (30 days)',
                      upcomingPassportExpiries.toString(),
                      Icons.warning_amber,
                      upcomingPassportExpiries > 0 ? Colors.orange : Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        context.pushNamed('hrAddEmployee');
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Employee'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.pushNamed('hrOrganogram');
                      },
                      icon: const Icon(Icons.account_tree_rounded),
                      label: const Text('Organogram Chart'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.pushNamed('hrPayroll');
                      },
                      icon: const Icon(Icons.receipt),
                      label: const Text('Run Payroll'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
