import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/employees_provider.dart';

class HrEmployeeDetailScreen extends ConsumerWidget {
  final String employeeId;

  const HrEmployeeDetailScreen({super.key, required this.employeeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesAsyncValue = ref.watch(employeesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Master Profile'),
        elevation: 1,
      ),
      body: employeesAsyncValue.when(
        data: (employees) {
          final employee = employees.firstWhere(
            (e) => e.id == employeeId,
            orElse: () => throw Exception('Employee not found'),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Profile Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                          backgroundImage: (employee.profilePicture != null && employee.profilePicture!.isNotEmpty)
                              ? NetworkImage(employee.profilePicture!)
                              : null,
                          child: (employee.profilePicture == null || employee.profilePicture!.isEmpty)
                              ? Text(
                                  employee.firstName.isNotEmpty ? employee.firstName[0].toUpperCase() : 'E',
                                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: theme.primaryColor),
                                )
                              : null,
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${employee.firstName} ${employee.lastName}',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${employee.designationName ?? 'No Designation'} • ${employee.departmentName ?? 'General Department'}',
                                style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Chip(
                                    visualDensity: VisualDensity.compact,
                                    backgroundColor: employee.status == 'ACTIVE' ? Colors.green[100] : Colors.amber[100],
                                    label: Text(
                                      employee.status,
                                      style: TextStyle(
                                        color: employee.status == 'ACTIVE' ? Colors.green[900] : Colors.amber[900],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (employee.paymentMethod.isNotEmpty)
                                    Chip(
                                      visualDensity: VisualDensity.compact,
                                      backgroundColor: Colors.blue[50],
                                      label: Text(
                                        'Payment: ${employee.paymentMethod}',
                                        style: const TextStyle(color: Colors.blue, fontSize: 12),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 1. Personal & Family Info
                _buildSectionHeader(Icons.person, 'Personal & Family Information', theme),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        _buildTile(Icons.family_restroom, "Father's Name", employee.fatherName),
                        _buildTile(Icons.family_restroom, "Mother's Name", employee.motherName),
                        _buildTile(Icons.email, 'Email Address', employee.email),
                        _buildTile(Icons.phone, 'Phone Number', employee.phone),
                        _buildTile(Icons.home, 'Address', employee.address),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Job & Position Details
                _buildSectionHeader(Icons.work, 'Job & Position Details', theme),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        _buildTile(Icons.business, 'Department', employee.departmentName),
                        _buildTile(Icons.work_outline, 'Designation / Title', employee.designationName),
                        _buildTile(Icons.assignment, 'Job Responsibilities', employee.jobResponsibility),
                        _buildTile(Icons.calendar_today, 'Joining Date', employee.joiningDate),
                        _buildTile(Icons.attach_money, 'Basic Salary', employee.basicSalary != null ? 'SAR ${employee.basicSalary}' : null),
                        _buildTile(Icons.grade_outlined, 'Pay Grade', employee.payGrade),
                        _buildTile(Icons.linear_scale_outlined, 'Pay Scale', employee.payScale),
                        _buildTile(Icons.home_work_outlined, 'Housing Allowance', (employee.housingAllowance != null && employee.housingAllowance!.isNotEmpty && employee.housingAllowance != '0') ? 'SAR ${employee.housingAllowance}' : null),
                        _buildTile(Icons.directions_car_outlined, 'Transport Allowance', (employee.transportAllowance != null && employee.transportAllowance!.isNotEmpty && employee.transportAllowance != '0') ? 'SAR ${employee.transportAllowance}' : null),
                        _buildTile(Icons.more_horiz_outlined, 'Other Allowances', (employee.otherAllowance != null && employee.otherAllowance!.isNotEmpty && employee.otherAllowance != '0') ? 'SAR ${employee.otherAllowance}' : null),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Work Schedule & Yearly Benefits
                _buildSectionHeader(Icons.access_time, 'Work Schedule & Yearly Benefits', theme),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        _buildTile(Icons.access_time, 'Working Hours', employee.workingHours),
                        _buildTile(Icons.event_available, 'Off Day / Weekend', employee.offDay),
                        _buildTile(Icons.sync, 'Shifting Roster', employee.shiftInfo),
                        _buildTile(Icons.card_giftcard, 'Yearly Benefits & Perks', employee.yearlyBenefits),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 4. Identification & Documents
                _buildSectionHeader(Icons.badge, 'Identification & Legal Documents', theme),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        _buildTile(Icons.badge, 'National ID / Iqama', employee.nationalId),
                        _buildTile(Icons.event_busy, 'Iqama Expiry Date', employee.iqamaExpiryDate),
                        _buildTile(Icons.import_contacts, 'Passport Number', employee.passportNumber),
                        _buildTile(Icons.event_busy, 'Passport Expiry Date', employee.passportExpiryDate),
                        _buildTile(Icons.security, 'GOSI Number', employee.gosiNumber),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 4b. Uploaded Document Attachments
                _buildSectionHeader(Icons.folder_shared, 'Uploaded Document Attachments & Files', theme),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: employee.documents.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text('No uploaded document attachments found', style: TextStyle(color: Colors.grey)),
                          )
                        : Column(
                            children: employee.documents
                                .map((doc) => ListTile(
                                      leading: const CircleAvatar(
                                        backgroundColor: Colors.blue,
                                        child: Icon(Icons.insert_drive_file, color: Colors.white, size: 20),
                                      ),
                                      title: Text('${doc.title} (${doc.documentType})', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Text('File: ${doc.fileUrl}${doc.expiryDate != null ? ' | Expiry: ${doc.expiryDate}' : ''}'),
                                      trailing: const Icon(Icons.download_rounded, color: Colors.blue),
                                    ))
                                .toList(),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // 5. Education & Qualifications
                _buildSectionHeader(Icons.school, 'Education & Qualifications', theme),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: employee.educations.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text('No education records added', style: TextStyle(color: Colors.grey)),
                          )
                        : Column(
                            children: employee.educations
                                .map((edu) => ListTile(
                                      leading: const Icon(Icons.school, color: Colors.blue),
                                      title: Text('${edu.degree} - ${edu.institution}'),
                                      subtitle: Text('Year: ${edu.passingYear} | Result: ${edu.result}'),
                                    ))
                                .toList(),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // 6. Experience History
                _buildSectionHeader(Icons.history_edu, 'Work Experience History', theme),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: employee.experiences.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text('No experience records added', style: TextStyle(color: Colors.grey)),
                          )
                        : Column(
                            children: employee.experiences
                                .map((exp) => ListTile(
                                      leading: const Icon(Icons.work_history, color: Colors.orange),
                                      title: Text('${exp.company} (${exp.period})'),
                                      subtitle: Text(exp.responsibilities),
                                    ))
                                .toList(),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // 7. Skills & Expertise
                _buildSectionHeader(Icons.star, 'Skills & Technical Expertise', theme),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: employee.skills.isEmpty
                        ? const Text('No skills recorded', style: TextStyle(color: Colors.grey))
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: employee.skills
                                .map((skill) => Chip(
                                      avatar: const CircleAvatar(child: Icon(Icons.check, size: 14)),
                                      label: Text(skill),
                                      backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                                    ))
                                .toList(),
                          ),
                  ),
                ),
                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Employee?'),
                              content: Text('Are you sure you want to delete ${employee.firstName} ${employee.lastName}?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            final api = ref.read(hrApiProvider);
                            await api.deleteEmployee(employee.id);
                            ref.invalidate(employeesProvider);
                            if (context.mounted) {
                              context.pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Employee deleted successfully')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text('Delete Employee', style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error loading employee: $error')),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: theme.primaryColor, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, String? value) {
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 20, color: Colors.grey[600]),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      subtitle: Text(
        (value != null && value.trim().isNotEmpty) ? value : 'Not specified',
        style: TextStyle(
          color: (value != null && value.trim().isNotEmpty) ? Colors.black87 : Colors.grey[400],
          fontSize: 14,
        ),
      ),
    );
  }
}
