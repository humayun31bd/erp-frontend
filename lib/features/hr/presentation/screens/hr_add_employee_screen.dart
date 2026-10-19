import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import '../../providers/employees_provider.dart';
import '../../domain/employee_model.dart';
import '../../domain/payroll_policy_model.dart';
import '../../utils/hr_constants.dart';

class HrAddEmployeeScreen extends ConsumerStatefulWidget {
  const HrAddEmployeeScreen({super.key});

  @override
  ConsumerState<HrAddEmployeeScreen> createState() => _HrAddEmployeeScreenState();
}

class _HrAddEmployeeScreenState extends ConsumerState<HrAddEmployeeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // --- Step 1: Personal Information ---
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _profilePictureController = TextEditingController();

  // --- Step 2: Department & Designation ---
  String? _selectedManagerId;
  String? _selectedManagerName;
  String? _selectedPayGradeCode;
  String? _selectedPayScaleName;
  final _departmentNameController = TextEditingController(text: HrConstants.departments[0]);
  final _designationNameController = TextEditingController(text: HrConstants.designations[0]);
  final _jobResponsibilityController = TextEditingController();
  final _joiningDateController = TextEditingController();
  final _basicSalaryController = TextEditingController();
  final _housingAllowanceController = TextEditingController();
  final _transportAllowanceController = TextEditingController();
  final _otherAllowanceController = TextEditingController();
  String _paymentMethod = 'BANK';
  String _status = 'ACTIVE';

  // --- Step 3: Schedule & Benefits ---
  String? _selectedShift = HrConstants.shifts[0];
  String? _selectedOffDay = HrConstants.offDays[0];
  final _workingHoursController = TextEditingController(text: HrConstants.shifts[0]);
  final _offDayController = TextEditingController(text: HrConstants.offDays[0]);
  final _shiftInfoController = TextEditingController(text: 'Day Shift');
  final _yearlyBenefitsController = TextEditingController();
  String? _selectedMonth;

  // --- Step 4: Documents & IDs ---
  final _nationalIdController = TextEditingController();
  final _iqamaExpiryController = TextEditingController();
  final _passportNumberController = TextEditingController();
  final _passportExpiryController = TextEditingController();
  final _gosiNumberController = TextEditingController();

  final List<EmployeeDocument> _documents = [];
  String _selectedDocType = 'National ID / Iqama Copy';
  final _docTitleController = TextEditingController();
  final _docUrlController = TextEditingController();
  final _docExpiryController = TextEditingController();
  final _docNotesController = TextEditingController();

  // --- Step 5: Educations & Experience ---
  final List<EmployeeEducation> _educations = [];
  final _eduDegreeController = TextEditingController();
  final _eduInstController = TextEditingController();
  final _eduYearController = TextEditingController();
  final _eduResultController = TextEditingController();

  final List<EmployeeExperience> _experiences = [];
  final _expCompanyController = TextEditingController();
  final _expPeriodController = TextEditingController();
  final _expRespController = TextEditingController();

  // --- Step 6: Skills ---
  final List<String> _skills = [];
  final _skillInputController = TextEditingController();

  bool _isLoading = false;

  final List<String> _presetAvatars = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
  ];

  final List<String> _docTypes = [
    'National ID / Iqama Copy',
    'Passport Copy',
    'Employment Contract',
    'Driving License',
    'Educational Certificate',
    'Medical Fitness Certificate',
    'GOSI / Social Insurance Copy',
    'Other Document',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _profilePictureController.dispose();

    _departmentNameController.dispose();
    _designationNameController.dispose();
    _jobResponsibilityController.dispose();
    _joiningDateController.dispose();
    _basicSalaryController.dispose();
    _housingAllowanceController.dispose();
    _transportAllowanceController.dispose();
    _otherAllowanceController.dispose();

    _workingHoursController.dispose();
    _offDayController.dispose();
    _shiftInfoController.dispose();
    _yearlyBenefitsController.dispose();

    _nationalIdController.dispose();
    _iqamaExpiryController.dispose();
    _passportNumberController.dispose();
    _passportExpiryController.dispose();
    _gosiNumberController.dispose();

    _docTitleController.dispose();
    _docUrlController.dispose();
    _docExpiryController.dispose();
    _docNotesController.dispose();

    _eduDegreeController.dispose();
    _eduInstController.dispose();
    _eduYearController.dispose();
    _eduResultController.dispose();

    _expCompanyController.dispose();
    _expPeriodController.dispose();
    _expRespController.dispose();

    _skillInputController.dispose();
    super.dispose();
  }

  Uint8List? _profilePictureBytes;

  Future<void> _pickProfilePictureFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'gif'],
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          if (file.bytes != null) {
            _profilePictureBytes = file.bytes;
            final base64String = base64Encode(file.bytes!);
            final ext = file.extension ?? 'png';
            _profilePictureController.text = 'data:image/$ext;base64,$base64String';
          } else if (file.path != null && file.path!.isNotEmpty) {
            _profilePictureController.text = file.path!;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image file: $e')),
        );
      }
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final formatted = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {
        controller.text = formatted;
        _selectedMonth = HrConstants.months[picked.month - 1];
      });
    }
  }

  Future<void> _pickDocumentFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'doc', 'docx'],
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _docUrlController.text = file.name;
          if (_docTitleController.text.isEmpty) {
            _docTitleController.text = '${_selectedDocType.split(' ')[0]} - ${file.name}';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting file: $e')),
        );
      }
    }
  }

  void _addDocument() {
    if (_docTitleController.text.trim().isEmpty || _docUrlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a Document Title and select or paste a File URL/path')),
      );
      return;
    }
    setState(() {
      _documents.add(EmployeeDocument(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        documentType: _selectedDocType,
        title: _docTitleController.text.trim(),
        fileUrl: _docUrlController.text.trim(),
        expiryDate: _docExpiryController.text.trim().isEmpty ? null : _docExpiryController.text.trim(),
        notes: _docNotesController.text.trim().isEmpty ? null : _docNotesController.text.trim(),
      ));
      _docTitleController.clear();
      _docUrlController.clear();
      _docExpiryController.clear();
      _docNotesController.clear();
    });
  }

  void _addEducation() {
    if (_eduDegreeController.text.trim().isEmpty || _eduInstController.text.trim().isEmpty) return;
    setState(() {
      _educations.add(EmployeeEducation(
        degree: _eduDegreeController.text.trim(),
        institution: _eduInstController.text.trim(),
        passingYear: _eduYearController.text.trim(),
        result: _eduResultController.text.trim(),
      ));
      _eduDegreeController.clear();
      _eduInstController.clear();
      _eduYearController.clear();
      _eduResultController.clear();
    });
  }

  void _addExperience() {
    if (_expCompanyController.text.trim().isEmpty) return;
    setState(() {
      _experiences.add(EmployeeExperience(
        company: _expCompanyController.text.trim(),
        period: _expPeriodController.text.trim(),
        responsibilities: _expRespController.text.trim(),
      ));
      _expCompanyController.clear();
      _expPeriodController.clear();
      _expRespController.clear();
    });
  }

  void _addSkill([String? skillName]) {
    final skill = (skillName ?? _skillInputController.text).trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillInputController.clear();
      });
    }
  }

  void _addBenefit(String benefit) {
    setState(() {
      if (_yearlyBenefitsController.text.isEmpty) {
        _yearlyBenefitsController.text = benefit;
      } else if (!_yearlyBenefitsController.text.contains(benefit)) {
        _yearlyBenefitsController.text = '${_yearlyBenefitsController.text}\n• $benefit';
      }
    });
  }

  CountryCode _selectedCountryCode = HrConstants.countryCodes[0];

  void _showCountryPickerModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = HrConstants.countryCodes.where((c) {
              final q = query.toLowerCase();
              return c.name.toLowerCase().contains(q) ||
                  c.dialCode.toLowerCase().contains(q) ||
                  c.code.toLowerCase().contains(q);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),
                  const Text('Select Country & Dial Code', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: (val) => setModalState(() => query = val),
                    decoration: InputDecoration(
                      hintText: 'Search country or code (e.g. +966, Saudi Arabia...)',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (ctx, idx) {
                        final country = filtered[idx];
                        final isSelected = country.dialCode == _selectedCountryCode.dialCode;

                        return ListTile(
                          leading: Text(country.flag, style: const TextStyle(fontSize: 24)),
                          title: Text(country.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          trailing: Text(country.dialCode, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Theme.of(context).primaryColor : Colors.grey[700])),
                          selected: isSelected,
                          onTap: () {
                            setState(() => _selectedCountryCode = country);
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSearchableSelectionModal({
    required String title,
    required List<String> items,
    required String? selectedValue,
    required ValueChanged<String> onSelected,
    required Function(String) onAddNew,
    VoidCallback? onManage,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String query = '';
        bool isGridView = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = items.where((i) => i.toLowerCase().contains(query.toLowerCase())).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Select $title', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(isGridView ? Icons.view_list : Icons.grid_view),
                            tooltip: isGridView ? 'Switch to List' : 'Switch to Grid',
                            onPressed: () => setModalState(() => isGridView = !isGridView),
                          ),
                          if (onManage != null)
                            TextButton.icon(
                              onPressed: () {
                                Navigator.pop(ctx);
                                onManage();
                              },
                              icon: const Icon(Icons.settings, size: 16),
                              label: const Text('Manage'),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (val) => setModalState(() => query = val),
                          decoration: InputDecoration(
                            hintText: 'Search $title...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          _showQuickAddDialog(
                            title: 'Add New $title',
                            onAdd: (newItem) {
                              onAddNew(newItem);
                              onSelected(newItem);
                              setModalState(() {});
                            },
                          );
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Custom'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_off, size: 48, color: Colors.grey),
                                const SizedBox(height: 8),
                                Text('No matching $title found'),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    if (query.trim().isNotEmpty) {
                                      onAddNew(query.trim());
                                      onSelected(query.trim());
                                      Navigator.pop(ctx);
                                    }
                                  },
                                  icon: const Icon(Icons.add),
                                  label: Text('Use "$query"'),
                                ),
                              ],
                            ),
                          )
                        : isGridView
                            ? GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 2.8,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final item = filtered[index];
                                  final isSelected = item == selectedValue;
                                  return InkWell(
                                    onTap: () {
                                      onSelected(item);
                                      Navigator.pop(ctx);
                                    },
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.grey[100],
                                        border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!, width: isSelected ? 2 : 1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Text(
                                          item,
                                          style: TextStyle(
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                                            fontSize: 13,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : ListView.separated(
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final item = filtered[index];
                                  final isSelected = item == selectedValue;

                                  return ListTile(
                                    title: Text(item, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                                    trailing: isSelected ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor) : null,
                                    selected: isSelected,
                                    onTap: () {
                                      onSelected(item);
                                      Navigator.pop(ctx);
                                    },
                                  );
                                },
                              ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showQuickAddDialog({required String title, required ValueChanged<String> onAdd}) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter name/title...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                onAdd(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save & Select'),
          ),
        ],
      ),
    );
  }

  void _showManageItemsDialog({
    required String title,
    required List<String> items,
    required Function(String) onAdd,
    required Function(String) onDelete,
  }) {
    showDialog(
      context: context,
      builder: (ctx) {
        String query = '';
        final addController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filtered = items.where((i) => i.toLowerCase().contains(query.toLowerCase())).toList();

            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Manage $title (${items.length})'),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              content: SizedBox(
                width: 500,
                height: 450,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: addController,
                            decoration: InputDecoration(
                              hintText: 'New $title name...',
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (addController.text.trim().isNotEmpty) {
                              onAdd(addController.text.trim());
                              addController.clear();
                              setState(() {});
                              setDialogState(() {});
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      onChanged: (val) => setDialogState(() => query = val),
                      decoration: const InputDecoration(
                        hintText: 'Filter existing items...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (ctx, idx) {
                          final item = filtered[idx];
                          return ListTile(
                            dense: true,
                            title: Text(item, style: const TextStyle(fontWeight: FontWeight.w500)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              onPressed: () {
                                onDelete(item);
                                setState(() {});
                                setDialogState(() {});
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submit() async {
    final isFirstValid = _firstNameController.text.trim().isNotEmpty;
    final isLastValid = _lastNameController.text.trim().isNotEmpty;

    if (!isFirstValid || !isLastValid) {
      _tabController.animateTo(0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('First Name and Last Name are required in Personal Info'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please check all required form fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final api = ref.read(hrApiProvider);

      final payload = {
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'father_name': _fatherNameController.text.trim().isEmpty ? null : _fatherNameController.text.trim(),
        'mother_name': _motherNameController.text.trim().isEmpty ? null : _motherNameController.text.trim(),
        'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        'phone': _phoneController.text.trim().isEmpty ? null : '${_selectedCountryCode.dialCode} ${_phoneController.text.trim()}',
        'address': _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        'profile_picture': _profilePictureController.text.trim().isEmpty ? null : _profilePictureController.text.trim(),

        'department_name': _departmentNameController.text.trim().isEmpty ? null : _departmentNameController.text.trim(),
        'designation_name': _designationNameController.text.trim().isEmpty ? null : _designationNameController.text.trim(),
        'manager_id': _selectedManagerId,
        'manager_name': _selectedManagerName,
        'job_responsibility': _jobResponsibilityController.text.trim().isEmpty ? null : _jobResponsibilityController.text.trim(),
        'joining_date': _joiningDateController.text.trim().isEmpty ? null : _joiningDateController.text.trim(),
        'basic_salary': _basicSalaryController.text.trim().isEmpty ? null : _basicSalaryController.text.trim(),
        'pay_grade': _selectedPayGradeCode,
        'pay_scale': _selectedPayScaleName,
        'housing_allowance': _housingAllowanceController.text.trim().isEmpty ? null : _housingAllowanceController.text.trim(),
        'transport_allowance': _transportAllowanceController.text.trim().isEmpty ? null : _transportAllowanceController.text.trim(),
        'other_allowance': _otherAllowanceController.text.trim().isEmpty ? null : _otherAllowanceController.text.trim(),
        'payment_method': _paymentMethod,
        'status': _status,

        'working_hours': _workingHoursController.text.trim().isEmpty ? null : _workingHoursController.text.trim(),
        'off_day': _offDayController.text.trim().isEmpty ? null : _offDayController.text.trim(),
        'shift_info': _shiftInfoController.text.trim().isEmpty ? null : _shiftInfoController.text.trim(),
        'yearly_benefits': _yearlyBenefitsController.text.trim().isEmpty ? null : _yearlyBenefitsController.text.trim(),

        'national_id': _nationalIdController.text.trim().isEmpty ? null : _nationalIdController.text.trim(),
        'iqama_expiry_date': _iqamaExpiryController.text.trim().isEmpty ? null : _iqamaExpiryController.text.trim(),
        'passport_number': _passportNumberController.text.trim().isEmpty ? null : _passportNumberController.text.trim(),
        'passport_expiry_date': _passportExpiryController.text.trim().isEmpty ? null : _passportExpiryController.text.trim(),
        'gosi_number': _gosiNumberController.text.trim().isEmpty ? null : _gosiNumberController.text.trim(),

        'documents': _documents.map((e) => e.toJson()).toList(),
        'educations': _educations.map((e) => e.toJson()).toList(),
        'experiences': _experiences.map((e) => e.toJson()).toList(),
        'skills': _skills,
      };

      await api.createEmployee(payload);
      ref.invalidate(employeesProvider);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Employee added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = 'Failed to save employee.';
        if (e is DioException) {
          final resData = e.response?.data;
          if (resData is Map && resData.containsKey('error')) {
            errorMsg = resData['error'].toString();
          } else if (e.message != null && e.message!.isNotEmpty) {
            errorMsg = e.message!;
          }
        } else {
          errorMsg = e.toString();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Employee (HR Master Portal)'),
        elevation: 1,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Personal Info'),
            Tab(icon: Icon(Icons.work), text: 'Job & Designation'),
            Tab(icon: Icon(Icons.access_time), text: 'Schedule & Benefits'),
            Tab(icon: Icon(Icons.badge), text: 'Documents & IDs'),
            Tab(icon: Icon(Icons.school), text: 'Education & Exp'),
            Tab(icon: Icon(Icons.star), text: 'Skills'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPersonalInfoTab(theme),
                  _buildJobDesignationTab(theme),
                  _buildScheduleBenefitsTab(theme),
                  _buildDocumentsTab(theme),
                  _buildEducationExperienceTab(theme),
                  _buildSkillsTab(theme),
                ],
              ),
            ),
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  // --- Tab 1: Personal Info ---
  Widget _buildPersonalInfoTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                      backgroundImage: _profilePictureBytes != null
                          ? MemoryImage(_profilePictureBytes!)
                          : (_profilePictureController.text.isNotEmpty
                              ? NetworkImage(_profilePictureController.text) as ImageProvider
                              : null),
                      child: (_profilePictureBytes == null && _profilePictureController.text.isEmpty)
                          ? Icon(Icons.person, size: 50, color: theme.primaryColor)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickProfilePictureFile,
                        borderRadius: BorderRadius.circular(16),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: theme.primaryColor,
                          child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickProfilePictureFile,
                      icon: const Icon(Icons.upload_file, size: 18),
                      label: const Text('Upload Photo'),
                    ),
                    if (_profilePictureBytes != null || _profilePictureController.text.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _profilePictureBytes = null;
                            _profilePictureController.clear();
                          });
                        },
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        label: const Text('Remove', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 450,
                  child: TextFormField(
                    controller: _profilePictureController,
                    onChanged: (val) => setState(() {
                      _profilePictureBytes = null;
                    }),
                    decoration: const InputDecoration(
                      labelText: 'Profile Picture Image URL / Data Path',
                      hintText: 'Upload image above or paste image URL...',
                      prefixIcon: Icon(Icons.link),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Preset Avatars: ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ..._presetAvatars.map((url) => GestureDetector(
                          onTap: () => setState(() {
                            _profilePictureBytes = null;
                            _profilePictureController.text = url;
                          }),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: CircleAvatar(radius: 14, backgroundImage: NetworkImage(url)),
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Basic Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name *',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name *',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _fatherNameController,
                  decoration: const InputDecoration(
                    labelText: "Father's Name",
                    prefixIcon: Icon(Icons.family_restroom),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _motherNameController,
                  decoration: const InputDecoration(
                    labelText: "Mother's Name",
                    prefixIcon: Icon(Icons.family_restroom),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: _showCountryPickerModal,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_selectedCountryCode.flag, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 4),
                            Text(_selectedCountryCode.dialCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const Icon(Icons.arrow_drop_down, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Full Address (Present & Permanent)',
              prefixIcon: Icon(Icons.home),
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  // --- Tab 2: Job & Designation ---
  Widget _buildJobDesignationTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Department & Designation Setup', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => _showManageItemsDialog(
                      title: 'Department',
                      items: HrConstants.departments,
                      onAdd: (n) => HrConstants.addDepartment(n),
                      onDelete: (item) => setState(() => HrConstants.departments.remove(item)),
                    ),
                    icon: const Icon(Icons.settings, size: 16),
                    label: const Text('Manage Depts'),
                  ),
                  TextButton.icon(
                    onPressed: () => _showManageItemsDialog(
                      title: 'Designation',
                      items: HrConstants.designations,
                      onAdd: (n) => HrConstants.addDesignation(n),
                      onDelete: (item) => setState(() => HrConstants.designations.remove(item)),
                    ),
                    icon: const Icon(Icons.settings, size: 16),
                    label: const Text('Manage Designations'),
                  ),
                ],
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    _showSearchableSelectionModal(
                      title: 'Department',
                      items: HrConstants.departments,
                      selectedValue: _departmentNameController.text,
                      onSelected: (val) {
                        setState(() {
                          _departmentNameController.text = val;
                        });
                      },
                      onAddNew: (newItem) => HrConstants.addDepartment(newItem),
                      onManage: () => _showManageItemsDialog(
                        title: 'Department',
                        items: HrConstants.departments,
                        onAdd: (n) => HrConstants.addDepartment(n),
                        onDelete: (item) => setState(() => HrConstants.departments.remove(item)),
                      ),
                    );
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Department (Searchable)',
                      prefixIcon: Icon(Icons.business),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _departmentNameController.text.isEmpty ? 'Select Department' : _departmentNameController.text,
                      style: TextStyle(fontWeight: _departmentNameController.text.isNotEmpty ? FontWeight.bold : FontWeight.normal),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () {
                    _showSearchableSelectionModal(
                      title: 'Designation',
                      items: HrConstants.designations,
                      selectedValue: _designationNameController.text,
                      onSelected: (val) {
                        setState(() {
                          _designationNameController.text = val;
                        });
                      },
                      onAddNew: (newItem) => HrConstants.addDesignation(newItem),
                      onManage: () => _showManageItemsDialog(
                        title: 'Designation',
                        items: HrConstants.designations,
                        onAdd: (n) => HrConstants.addDesignation(n),
                        onDelete: (item) => setState(() => HrConstants.designations.remove(item)),
                      ),
                    );
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Designation / Title (Searchable)',
                      prefixIcon: Icon(Icons.work_outline),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _designationNameController.text.isEmpty ? 'Select Designation' : _designationNameController.text,
                      style: TextStyle(fontWeight: _designationNameController.text.isNotEmpty ? FontWeight.bold : FontWeight.normal),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Reporting Manager Searchable Selector
          Consumer(
            builder: (context, ref, child) {
              final employeesAsync = ref.watch(employeesProvider);
              final employeeList = employeesAsync.value ?? [];

              return InkWell(
                onTap: () {
                  final managerOptions = [
                    'No Manager (Top-Level Executive / Board)',
                    ...employeeList.map((e) => '${e.firstName} ${e.lastName} (${e.designationName ?? "No Title"})')
                  ];

                  _showSearchableSelectionModal(
                    title: 'Reporting Manager',
                    items: managerOptions,
                    selectedValue: _selectedManagerName != null
                        ? managerOptions.firstWhere((m) => m.contains(_selectedManagerName!), orElse: () => _selectedManagerName!)
                        : 'No Manager (Top-Level Executive / Board)',
                    onSelected: (val) {
                      setState(() {
                        if (val.startsWith('No Manager')) {
                          _selectedManagerId = null;
                          _selectedManagerName = null;
                        } else {
                          final matches = employeeList.where((e) => val.contains(e.firstName) && val.contains(e.lastName)).toList();
                          if (matches.isNotEmpty) {
                            final selectedEmp = matches.first;
                            _selectedManagerId = selectedEmp.id;
                            _selectedManagerName = '${selectedEmp.firstName} ${selectedEmp.lastName}';
                          }
                        }
                      });
                    },
                    onAddNew: (_) {},
                  );
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Reporting Manager / Supervisor (Organogram Manager)',
                    prefixIcon: Icon(Icons.account_tree),
                    suffixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    helperText: 'Select manager for organogram chart tree hierarchy',
                  ),
                  child: Text(
                    _selectedManagerName ?? 'No Manager (Top-Level Executive / Board)',
                    style: TextStyle(fontWeight: _selectedManagerName != null ? FontWeight.bold : FontWeight.normal),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _jobResponsibilityController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Job Responsibility & Key Performance Scope',
              hintText: 'Describe key responsibilities, deliverables, and role scope...',
              prefixIcon: Icon(Icons.assignment),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 20),
          const Text('Pay Scale & Compensation Setup', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(),
          const SizedBox(height: 12),
          Consumer(
            builder: (context, ref, _) {
              final gradesAsync = ref.watch(payGradesProvider);
              final scalesAsync = ref.watch(payScalesProvider);

              final grades = gradesAsync.valueOrNull ?? [];
              final scales = scalesAsync.valueOrNull ?? [];

              final List<PayGrade> gradeOptions = grades.isNotEmpty
                  ? grades
                  : [
                      PayGrade(id: '1', gradeCode: 'EXEC-1', gradeName: 'Executive Level', minSalary: 25000, maxSalary: 60000, housingAllowancePercent: 30, transportAllowancePercent: 15),
                      PayGrade(id: '2', gradeCode: 'MGR-1', gradeName: 'Managerial Level', minSalary: 15000, maxSalary: 28000, housingAllowancePercent: 25, transportAllowancePercent: 10),
                      PayGrade(id: '3', gradeCode: 'G3', gradeName: 'Senior Level', minSalary: 9000, maxSalary: 16000, housingAllowancePercent: 25, transportAllowancePercent: 10),
                      PayGrade(id: '4', gradeCode: 'G2', gradeName: 'Mid Level', minSalary: 5000, maxSalary: 9500, housingAllowancePercent: 25, transportAllowancePercent: 10),
                      PayGrade(id: '5', gradeCode: 'G1', gradeName: 'Junior Level', minSalary: 3500, maxSalary: 5500, housingAllowancePercent: 25, transportAllowancePercent: 10),
                    ];

              var filteredScales = scales.where((s) => s.gradeCode == _selectedPayGradeCode).toList();
              if (filteredScales.isEmpty && _selectedPayGradeCode != null) {
                final selGrade = gradeOptions.firstWhere((g) => g.gradeCode == _selectedPayGradeCode, orElse: () => gradeOptions.first);
                filteredScales = List.generate(5, (idx) {
                  final step = idx + 1;
                  final factor = 1.0 + (step - 1) * 0.05;
                  final basic = (selGrade.minSalary * factor).roundToDouble();
                  final housing = (basic * (selGrade.housingAllowancePercent / 100)).roundToDouble();
                  final transport = (basic * (selGrade.transportAllowancePercent / 100)).roundToDouble();
                  return PayScale(
                    id: 'step-$step',
                    gradeCode: selGrade.gradeCode,
                    scaleName: 'Step $step',
                    basicSalary: basic,
                    housingAllowance: housing,
                    transportAllowance: transport,
                    medicalAllowance: 500,
                    otherAllowances: 0,
                    totalPackage: basic + housing + transport + 500,
                    incrementRate: 5,
                  );
                });
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Pay Grade Picker
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            final gradeItems = gradeOptions.map((g) => '${g.gradeCode} - ${g.gradeName}').toList();
                            _showSearchableSelectionModal(
                              title: 'Pay Grade',
                              items: gradeItems,
                              selectedValue: _selectedPayGradeCode != null
                                  ? gradeItems.firstWhere((i) => i.startsWith(_selectedPayGradeCode!), orElse: () => _selectedPayGradeCode!)
                                  : null,
                              onSelected: (val) {
                                setState(() {
                                  _selectedPayGradeCode = val.split(' - ')[0];
                                  _selectedPayScaleName = null;
                                });
                              },
                              onAddNew: (_) {},
                            );
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Pay Grade (Searchable)',
                              prefixIcon: Icon(Icons.workspace_premium),
                              suffixIcon: Icon(Icons.arrow_drop_down),
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              _selectedPayGradeCode ?? 'Select Pay Grade (Optional)',
                              style: TextStyle(fontWeight: _selectedPayGradeCode != null ? FontWeight.bold : FontWeight.normal),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Pay Scale Step Picker
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            if (_selectedPayGradeCode == null) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a Pay Grade first')));
                              return;
                            }
                            final scaleItems = filteredScales.map((s) => '${s.scaleName} (${s.basicSalary.toStringAsFixed(0)} SAR Basic)').toList();
                            _showSearchableSelectionModal(
                              title: 'Pay Scale Step',
                              items: scaleItems,
                              selectedValue: _selectedPayScaleName != null
                                  ? scaleItems.firstWhere((i) => i.startsWith(_selectedPayScaleName!), orElse: () => _selectedPayScaleName!)
                                  : null,
                              onSelected: (val) {
                                final selectedStepName = val.split(' (')[0];
                                final scaleObj = filteredScales.firstWhere((s) => s.scaleName == selectedStepName, orElse: () => filteredScales.first);
                                setState(() {
                                  _selectedPayScaleName = scaleObj.scaleName;
                                  _basicSalaryController.text = scaleObj.basicSalary.toStringAsFixed(0);
                                  _housingAllowanceController.text = scaleObj.housingAllowance.toStringAsFixed(0);
                                  _transportAllowanceController.text = scaleObj.transportAllowance.toStringAsFixed(0);
                                  _otherAllowanceController.text = scaleObj.otherAllowances.toStringAsFixed(0);
                                });
                              },
                              onAddNew: (_) {},
                            );
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Pay Scale / Step',
                              prefixIcon: Icon(Icons.tune),
                              suffixIcon: Icon(Icons.arrow_drop_down),
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              _selectedPayScaleName ?? 'Select Scale Step',
                              style: TextStyle(fontWeight: _selectedPayScaleName != null ? FontWeight.bold : FontWeight.normal),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _joiningDateController,
                          readOnly: true,
                          onTap: () => _selectDate(_joiningDateController),
                          decoration: InputDecoration(
                            labelText: 'Joining Date',
                            hintText: 'YYYY-MM-DD',
                            prefixIcon: const Icon(Icons.calendar_today),
                            suffixIcon: const Icon(Icons.event),
                            helperText: _selectedMonth != null ? 'Joining Month: $_selectedMonth' : null,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _basicSalaryController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            labelText: 'Basic Salary (SAR) *',
                            prefixIcon: Icon(Icons.payments),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _housingAllowanceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            labelText: 'Housing Allowance (SAR)',
                            prefixIcon: Icon(Icons.home_work),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _transportAllowanceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            labelText: 'Transport Allowance (SAR)',
                            prefixIcon: Icon(Icons.directions_car),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _otherAllowanceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            labelText: 'Other Allowances (SAR)',
                            prefixIcon: Icon(Icons.more_horiz),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Package Calculation Summary Banner
                  Builder(builder: (_) {
                    final basic = double.tryParse(_basicSalaryController.text) ?? 0;
                    final housing = double.tryParse(_housingAllowanceController.text) ?? 0;
                    final transport = double.tryParse(_transportAllowanceController.text) ?? 0;
                    final other = double.tryParse(_otherAllowanceController.text) ?? 0;
                    final totalGross = basic + housing + transport + other;

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.indigo[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.indigo[200]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calculate, color: Colors.indigo),
                              const SizedBox(width: 8),
                              Text('Total Gross Package: ${totalGross.toStringAsFixed(2)} SAR / month', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 14)),
                            ],
                          ),
                          Text('Annual: ${(totalGross * 12).toStringAsFixed(2)} SAR', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.indigo, fontSize: 12)),
                        ],
                      ),
                    );
                  }),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _paymentMethod,
                  decoration: const InputDecoration(
                    labelText: 'Payment Method',
                    prefixIcon: Icon(Icons.account_balance),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'BANK', child: Text('Bank Transfer (WPS)')),
                    DropdownMenuItem(value: 'CASH', child: Text('Cash')),
                    DropdownMenuItem(value: 'CHEQUE', child: Text('Cheque')),
                  ],
                  onChanged: (v) => setState(() => _paymentMethod = v!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: const InputDecoration(
                    labelText: 'Employment Status',
                    prefixIcon: Icon(Icons.check_circle_outline),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'ACTIVE', child: Text('Active')),
                    DropdownMenuItem(value: 'PROBATION', child: Text('Probation (3-6 Months)')),
                    DropdownMenuItem(value: 'INACTIVE', child: Text('Inactive')),
                  ],
                  onChanged: (v) => setState(() => _status = v!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Tab 3: Schedule & Benefits ---
  Widget _buildScheduleBenefitsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Predefined Working Hours, Shifts & Days', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedShift,
            decoration: const InputDecoration(
              labelText: 'Work Shift (Predefined)',
              prefixIcon: Icon(Icons.access_time),
              border: OutlineInputBorder(),
            ),
            items: [
              ...HrConstants.shifts.map((s) => DropdownMenuItem(value: s, child: Text(s))),
              const DropdownMenuItem(value: 'CUSTOM', child: Text('➕ Custom Shift Schedule...')),
            ],
            onChanged: (val) {
              setState(() {
                _selectedShift = val;
                if (val != 'CUSTOM' && val != null) {
                  _workingHoursController.text = val;
                  _shiftInfoController.text = val.split(' (')[0];
                } else {
                  _workingHoursController.clear();
                }
              });
            },
          ),
          if (_selectedShift == 'CUSTOM') ...[
            const SizedBox(height: 10),
            TextFormField(
              controller: _workingHoursController,
              decoration: const InputDecoration(
                labelText: 'Enter Custom Working Hours',
                prefixIcon: Icon(Icons.edit),
                border: OutlineInputBorder(),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _selectedOffDay,
                      decoration: const InputDecoration(
                        labelText: 'Off Days / Weekend (Predefined)',
                        prefixIcon: Icon(Icons.event_available),
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        ...HrConstants.offDays.map((d) => DropdownMenuItem(value: d, child: Text(d))),
                        const DropdownMenuItem(value: 'CUSTOM', child: Text('➕ Custom Off Days...')),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedOffDay = val;
                          if (val != 'CUSTOM' && val != null) {
                            _offDayController.text = val;
                          } else {
                            _offDayController.clear();
                          }
                        });
                      },
                    ),
                    if (_selectedOffDay == 'CUSTOM') ...[
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _offDayController,
                        decoration: const InputDecoration(
                          labelText: 'Enter Custom Off Days',
                          prefixIcon: Icon(Icons.edit),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _shiftInfoController,
                  decoration: const InputDecoration(
                    labelText: 'Shift Tag / Roster Name',
                    hintText: 'e.g. Day Shift, Night Shift',
                    prefixIcon: Icon(Icons.sync),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Yearly Benefits & Perks (Quick Select)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () => _showManageItemsDialog(
                  title: 'Yearly Benefit',
                  items: HrConstants.yearlyBenefits,
                  onAdd: (n) => HrConstants.addYearlyBenefit(n),
                  onDelete: (item) => setState(() => HrConstants.yearlyBenefits.remove(item)),
                ),
                icon: const Icon(Icons.settings, size: 16),
                label: const Text('Manage Benefits'),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 8),
          const Text('Tap to add predefined benefits:', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: HrConstants.yearlyBenefits
                .map((benefit) => ActionChip(
                      avatar: const Icon(Icons.add_circle, size: 16, color: Colors.green),
                      label: Text(benefit, style: const TextStyle(fontSize: 12)),
                      onPressed: () => _addBenefit(benefit),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _yearlyBenefitsController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Yearly Benefits Details',
              hintText: 'Details of annual bonuses, air tickets, health insurance, leave allowances...',
              prefixIcon: Icon(Icons.card_giftcard),
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  // --- Tab 4: Documents & IDs (Required Uploads) ---
  Widget _buildDocumentsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Identification & Legal Numbers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _nationalIdController,
                  decoration: const InputDecoration(
                    labelText: 'National ID / Iqama Number',
                    prefixIcon: Icon(Icons.badge),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _iqamaExpiryController,
                  readOnly: true,
                  onTap: () => _selectDate(_iqamaExpiryController),
                  decoration: const InputDecoration(
                    labelText: 'Iqama Expiry Date',
                    prefixIcon: Icon(Icons.event_busy),
                    suffixIcon: Icon(Icons.calendar_month),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _passportNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Passport Number',
                    prefixIcon: Icon(Icons.import_contacts),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _passportExpiryController,
                  readOnly: true,
                  onTap: () => _selectDate(_passportExpiryController),
                  decoration: const InputDecoration(
                    labelText: 'Passport Expiry Date',
                    prefixIcon: Icon(Icons.event_busy),
                    suffixIcon: Icon(Icons.calendar_month),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _gosiNumberController,
            decoration: const InputDecoration(
              labelText: 'GOSI Registration Number',
              prefixIcon: Icon(Icons.security),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 28),

          // Upload Required Documents Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Required Document Attachments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Chip(
                visualDensity: VisualDensity.compact,
                backgroundColor: Colors.blue[50],
                label: Text('${_documents.length} Attached', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _selectedDocType,
                    decoration: const InputDecoration(
                      labelText: 'Document Type *',
                      prefixIcon: Icon(Icons.file_present),
                      border: OutlineInputBorder(),
                    ),
                    items: _docTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                    onChanged: (val) => setState(() => _selectedDocType = val!),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _docTitleController,
                          decoration: const InputDecoration(
                            labelText: 'Document Title / Description *',
                            hintText: 'e.g. Iqama Scan 2026.pdf',
                            prefixIcon: Icon(Icons.description),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _docUrlController,
                          decoration: const InputDecoration(
                            labelText: 'File Name / URL / Path *',
                            hintText: 'Click Browse or paste file URL',
                            prefixIcon: Icon(Icons.attach_file),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _pickDocumentFile,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Browse File'),
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _docExpiryController,
                          readOnly: true,
                          onTap: () => _selectDate(_docExpiryController),
                          decoration: const InputDecoration(
                            labelText: 'Document Expiry Date (Optional)',
                            prefixIcon: Icon(Icons.event),
                            suffixIcon: Icon(Icons.calendar_month),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _docNotesController,
                          decoration: const InputDecoration(
                            labelText: 'Notes / Remarks',
                            prefixIcon: Icon(Icons.note),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: _addDocument,
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text('Attach Document to Employee File'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_documents.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.amber, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(8),
                color: Colors.amber[50],
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.amber),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No documents attached yet. Please upload required documents (National ID/Iqama, Passport, Employment Contract).',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _documents.length,
              itemBuilder: (context, index) {
                final doc = _documents[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.insert_drive_file, color: Colors.white, size: 20),
                    ),
                    title: Text('${doc.title} (${doc.documentType})', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('File: ${doc.fileUrl}${doc.expiryDate != null ? ' | Expires: ${doc.expiryDate}' : ''}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => setState(() => _documents.removeAt(index)),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // --- Tab 5: Education & Experience ---
  Widget _buildEducationExperienceTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Education & Academic Background', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('${_educations.length} Added', style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const Divider(),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _eduDegreeController,
                          decoration: const InputDecoration(labelText: 'Degree / Certificate', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _eduInstController,
                          decoration: const InputDecoration(labelText: 'Institution / Board', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _eduYearController,
                          decoration: const InputDecoration(labelText: 'Passing Year', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _eduResultController,
                          decoration: const InputDecoration(labelText: 'Result / GPA', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _addEducation,
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_educations.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _educations.length,
              itemBuilder: (context, index) {
                final item = _educations[index];
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.school, color: Colors.blue),
                  title: Text('${item.degree} - ${item.institution}'),
                  subtitle: Text('Year: ${item.passingYear} | Result: ${item.result}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => setState(() => _educations.removeAt(index)),
                  ),
                );
              },
            ),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Work Experiences', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('${_experiences.length} Added', style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const Divider(),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _expCompanyController,
                          decoration: const InputDecoration(labelText: 'Company Name', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _expPeriodController,
                          decoration: const InputDecoration(labelText: 'Period (e.g. 2021-2024)', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _expRespController,
                          decoration: const InputDecoration(labelText: 'Key Responsibilities', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _addExperience,
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_experiences.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _experiences.length,
              itemBuilder: (context, index) {
                final item = _experiences[index];
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.work, color: Colors.orange),
                  title: Text('${item.company} (${item.period})'),
                  subtitle: Text(item.responsibilities),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => setState(() => _experiences.removeAt(index)),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // --- Tab 6: Skills ---
  Widget _buildSkillsTab(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Technical & Professional Skills', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(),
          const SizedBox(height: 8),
          const Text('Popular Skills Quick Add:', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: HrConstants.popularSkills
                .map((skill) => ActionChip(
                      avatar: const Icon(Icons.star, size: 14, color: Colors.amber),
                      label: Text(skill, style: const TextStyle(fontSize: 12)),
                      onPressed: () => _addSkill(skill),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _skillInputController,
                  decoration: const InputDecoration(
                    labelText: 'Add Custom Skill',
                    hintText: 'e.g. Accounting, Project Management',
                    prefixIcon: Icon(Icons.star_outline),
                    border: OutlineInputBorder(),
                  ),
                  onFieldSubmitted: (_) => _addSkill(),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _addSkill(),
                icon: const Icon(Icons.add),
                label: const Text('Add Skill'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Selected Skill Tags:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _skills.isEmpty
              ? const Text('No skills added yet. Select popular skills above or type a custom skill.', style: TextStyle(color: Colors.grey))
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _skills
                      .map((skill) => Chip(
                            avatar: const CircleAvatar(child: Icon(Icons.check, size: 14)),
                            label: Text(skill),
                            deleteIcon: const Icon(Icons.cancel, size: 18),
                            onDeleted: () => setState(() => _skills.remove(skill)),
                            backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                          ))
                      .toList(),
                ),
        ],
      ),
    );
  }

  // --- Bottom Action Bar ---
  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_tabController.index > 0)
            OutlinedButton.icon(
              onPressed: () {
                _tabController.animateTo(_tabController.index - 1);
                setState(() {});
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Previous'),
            )
          else
            const SizedBox.shrink(),
          Row(
            children: [
              if (_tabController.index < 5)
                ElevatedButton.icon(
                  onPressed: () {
                    _tabController.animateTo(_tabController.index + 1);
                    setState(() {});
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next Step'),
                ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submit,
                icon: _isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save),
                label: Text(_isLoading ? 'Saving...' : 'Save Employee'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
