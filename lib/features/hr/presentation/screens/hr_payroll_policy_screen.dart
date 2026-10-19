import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/employees_provider.dart';
import '../../domain/payroll_policy_model.dart';

class HrPayrollPolicyScreen extends ConsumerStatefulWidget {
  const HrPayrollPolicyScreen({super.key});

  @override
  ConsumerState<HrPayrollPolicyScreen> createState() => _HrPayrollPolicyScreenState();
}

class _HrPayrollPolicyScreenState extends ConsumerState<HrPayrollPolicyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedGradeFilter = 'ALL';
  String _searchQuery = '';
  String _scalesViewMode = 'MATRIX'; // 'MATRIX', 'CARDS', 'TABLE'
  String _gradesViewMode = 'VISUALIZER'; // 'VISUALIZER', 'CARDS', 'TABLE'

  // Interactive Salary Calculator State
  double _calcBasicSalary = 10000;
  double _calcHousingPercent = 25;
  double _calcTransportPercent = 10;
  double _calcOtherAllowances = 1000;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Predefined default grades if server is empty
  List<PayGrade> get _defaultGrades => [
        PayGrade(
          id: 'g-exec',
          gradeCode: 'EXEC-1',
          gradeName: 'Executive & C-Suite Level',
          minSalary: 25000,
          maxSalary: 60000,
          housingAllowancePercent: 30,
          transportAllowancePercent: 15,
          description: 'C-Level Executives, VPs and Directors',
        ),
        PayGrade(
          id: 'g-mgr',
          gradeCode: 'MGR-1',
          gradeName: 'Departmental Manager Level',
          minSalary: 15000,
          maxSalary: 28000,
          housingAllowancePercent: 25,
          transportAllowancePercent: 10,
          description: 'Department Managers & Senior Tech Leads',
        ),
        PayGrade(
          id: 'g-sr',
          gradeCode: 'G3',
          gradeName: 'Senior Specialist / Officer',
          minSalary: 9000,
          maxSalary: 16000,
          housingAllowancePercent: 25,
          transportAllowancePercent: 10,
          description: 'Senior Engineers, Senior Accountants & Specialists',
        ),
        PayGrade(
          id: 'g-mid',
          gradeCode: 'G2',
          gradeName: 'Mid-Level Generalist',
          minSalary: 5000,
          maxSalary: 9500,
          housingAllowancePercent: 25,
          transportAllowancePercent: 10,
          description: 'Mid-Level Staff, Developers & Officers',
        ),
        PayGrade(
          id: 'g-jr',
          gradeCode: 'G1',
          gradeName: 'Junior / Entry Level',
          minSalary: 3500,
          maxSalary: 5500,
          housingAllowancePercent: 25,
          transportAllowancePercent: 10,
          description: 'Junior Staff, Assistants & Trainees',
        ),
      ];

  // Predefined default scales matrix if server is empty
  List<PayScale> get _defaultScales {
    final list = <PayScale>[];
    for (final grade in _defaultGrades) {
      for (int step = 1; step <= 5; step++) {
        final factor = 1.0 + (step - 1) * 0.05;
        final basic = (grade.minSalary * factor).roundToDouble();
        final housing = (basic * (grade.housingAllowancePercent / 100)).roundToDouble();
        final transport = (basic * (grade.transportAllowancePercent / 100)).roundToDouble();
        final medical = 500.0;
        final other = step * 100.0;
        final total = basic + housing + transport + medical + other;
        list.add(
          PayScale(
            id: 's-${grade.gradeCode.toLowerCase()}-$step',
            gradeCode: grade.gradeCode,
            scaleName: 'Step $step',
            basicSalary: basic,
            housingAllowance: housing,
            transportAllowance: transport,
            medicalAllowance: medical,
            otherAllowances: other,
            totalPackage: total,
            incrementRate: 5.0,
          ),
        );
      }
    }
    return list;
  }

  void _showAddGradeDialog() {
    final codeController = TextEditingController();
    final nameController = TextEditingController();
    final minController = TextEditingController();
    final maxController = TextEditingController();
    final housingController = TextEditingController(text: '25');
    final transportController = TextEditingController(text: '10');
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.workspace_premium, color: Colors.blue),
            SizedBox(width: 8),
            Text('Create Pay Grade Policy'),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: codeController,
                        decoration: const InputDecoration(labelText: 'Grade Code *', hintText: 'e.g. G4, EXEC-2', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Grade Title *', hintText: 'e.g. Lead Specialist', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Min Salary (SAR)', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: maxController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Max Salary (SAR)', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: housingController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Housing Allowance %', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: transportController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Transport Allowance %', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Policy Description / Scope', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () async {
              if (codeController.text.trim().isEmpty || nameController.text.trim().isEmpty) return;
              try {
                final api = ref.read(hrApiProvider);
                await api.createPayGrade({
                  'grade_code': codeController.text.trim(),
                  'grade_name': nameController.text.trim(),
                  'min_salary': double.tryParse(minController.text) ?? 0,
                  'max_salary': double.tryParse(maxController.text) ?? 0,
                  'housing_allowance_percent': double.tryParse(housingController.text) ?? 25,
                  'transport_allowance_percent': double.tryParse(transportController.text) ?? 10,
                  'description': descController.text.trim(),
                });
                ref.invalidate(payGradesProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error creating grade: $e')));
                }
              }
            },
            icon: const Icon(Icons.check),
            label: const Text('Save Pay Grade'),
          ),
        ],
      ),
    );
  }

  void _showAddScaleDialog(List<PayGrade> grades) {
    final scaleNameController = TextEditingController();
    final basicController = TextEditingController(text: '8000');
    final housingController = TextEditingController(text: '2000');
    final transportController = TextEditingController(text: '800');
    final medicalController = TextEditingController(text: '500');
    final otherController = TextEditingController(text: '0');
    final incrementController = TextEditingController(text: '5.0');
    String selectedGradeCode = grades.isNotEmpty ? grades.first.gradeCode : 'G1';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.tune, color: Colors.purple),
            SizedBox(width: 8),
            Text('Create Pay Scale / Step'),
          ],
        ),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedGradeCode,
                        decoration: const InputDecoration(labelText: 'Pay Grade', border: OutlineInputBorder()),
                        items: grades
                            .map((g) => DropdownMenuItem(value: g.gradeCode, child: Text('${g.gradeCode} - ${g.gradeName}')))
                            .toList(),
                        onChanged: (val) => selectedGradeCode = val ?? 'G1',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: scaleNameController,
                        decoration: const InputDecoration(labelText: 'Scale / Step Name *', hintText: 'e.g. Grade 2 Step 1', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: basicController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Basic Salary (SAR)', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: housingController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Housing Allowance (SAR)', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: transportController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Transport Allowance (SAR)', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: medicalController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Medical Allowance (SAR)', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: otherController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Other Allowances (SAR)', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: incrementController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Annual Increment %', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () async {
              if (scaleNameController.text.trim().isEmpty) return;
              try {
                final api = ref.read(hrApiProvider);
                await api.createPayScale({
                  'grade_code': selectedGradeCode,
                  'scale_name': scaleNameController.text.trim(),
                  'basic_salary': double.tryParse(basicController.text) ?? 0,
                  'housing_allowance': double.tryParse(housingController.text) ?? 0,
                  'transport_allowance': double.tryParse(transportController.text) ?? 0,
                  'medical_allowance': double.tryParse(medicalController.text) ?? 0,
                  'other_allowances': double.tryParse(otherController.text) ?? 0,
                  'increment_rate': double.tryParse(incrementController.text) ?? 0,
                });
                ref.invalidate(payScalesProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error creating pay scale: $e')));
                }
              }
            },
            icon: const Icon(Icons.check),
            label: const Text('Save Pay Scale'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradesAsync = ref.watch(payGradesProvider);
    final scalesAsync = ref.watch(payScalesProvider);

    final grades = gradesAsync.valueOrNull?.isNotEmpty == true ? gradesAsync.value! : _defaultGrades;
    final scales = scalesAsync.valueOrNull?.isNotEmpty == true ? scalesAsync.value! : _defaultScales;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payroll Policy & Grade Pay Scales Engine'),
        elevation: 1,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.auto_graph), text: 'Policy Matrix & Calculator'),
            Tab(icon: Icon(Icons.workspace_premium), text: 'Manage Pay Grades'),
            Tab(icon: Icon(Icons.tune), text: 'Manage Pay Scales & Steps'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Payroll Policy',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(payGradesProvider);
              ref.invalidate(payScalesProvider);
            },
          ),
          ElevatedButton.icon(
            onPressed: _showAddGradeDialog,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Pay Grade'),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => _showAddScaleDialog(grades),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Pay Scale'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPolicyMatrixTab(grades, scales, theme),
          _buildManageGradesTab(grades, theme),
          _buildManageScalesTab(grades, scales, theme),
        ],
      ),
    );
  }

  // --- Tab 1: Policy Matrix & Interactive Salary Calculator ---
  Widget _buildPolicyMatrixTab(List<PayGrade> grades, List<PayScale> scales, ThemeData theme) {
    final housingCalc = _calcBasicSalary * (_calcHousingPercent / 100);
    final transportCalc = _calcBasicSalary * (_calcTransportPercent / 100);
    final totalPackageCalc = _calcBasicSalary + housingCalc + transportCalc + _calcOtherAllowances;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary KPI Banner
          Row(
            children: [
              _buildKpiCard('Pay Grades Defined', '${grades.length} Grades', Icons.workspace_premium, Colors.blue),
              const SizedBox(width: 16),
              _buildKpiCard('Pay Scale Steps', '${scales.length} Scales', Icons.tune, Colors.purple),
              const SizedBox(width: 16),
              _buildKpiCard('Housing Allowance Policy', '25% of Basic', Icons.home_work, Colors.orange),
              const SizedBox(width: 16),
              _buildKpiCard('Transport Allowance Policy', '10% of Basic', Icons.directions_car, Colors.teal),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Policy Grade Ranges Table
              Expanded(
                flex: 3,
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.table_chart, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Corporate Pay Grade Benchmark Matrix', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Table(
                          border: TableBorder.all(color: Colors.grey[300]!, width: 1),
                          columnWidths: const {
                            0: FlexColumnWidth(1.2),
                            1: FlexColumnWidth(2.5),
                            2: FlexColumnWidth(2.0),
                            3: FlexColumnWidth(1.5),
                            4: FlexColumnWidth(1.5),
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(color: Colors.grey[100]),
                              children: const [
                                Padding(padding: EdgeInsets.all(10), child: Text('Grade', style: TextStyle(fontWeight: FontWeight.bold))),
                                Padding(padding: EdgeInsets.all(10), child: Text('Grade Title & Level', style: TextStyle(fontWeight: FontWeight.bold))),
                                Padding(padding: EdgeInsets.all(10), child: Text('Basic Salary Range', style: TextStyle(fontWeight: FontWeight.bold))),
                                Padding(padding: EdgeInsets.all(10), child: Text('Housing %', style: TextStyle(fontWeight: FontWeight.bold))),
                                Padding(padding: EdgeInsets.all(10), child: Text('Transport %', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                            ),
                            ...grades.map(
                              (g) => TableRow(
                                children: [
                                  Padding(padding: const EdgeInsets.all(10), child: Text(g.gradeCode, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                                  Padding(padding: const EdgeInsets.all(10), child: Text(g.gradeName)),
                                  Padding(padding: const EdgeInsets.all(10), child: Text('${g.minSalary.toStringAsFixed(0)} - ${g.maxSalary.toStringAsFixed(0)} SAR')),
                                  Padding(padding: const EdgeInsets.all(10), child: Text('${g.housingAllowancePercent.toStringAsFixed(0)}%')),
                                  Padding(padding: const EdgeInsets.all(10), child: Text('${g.transportAllowancePercent.toStringAsFixed(0)}%')),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Interactive Package Calculator Widget
              Expanded(
                flex: 2,
                child: Card(
                  elevation: 2,
                  color: Colors.blue[50]?.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.blue[200]!)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.calculate, color: Colors.indigo),
                            SizedBox(width: 8),
                            Text('Interactive Package Calculator', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text('Basic Salary: ${_calcBasicSalary.toStringAsFixed(0)} SAR', style: const TextStyle(fontWeight: FontWeight.w600)),
                        Slider(
                          value: _calcBasicSalary,
                          min: 3000,
                          max: 50000,
                          divisions: 94,
                          label: '${_calcBasicSalary.toStringAsFixed(0)} SAR',
                          onChanged: (val) => setState(() => _calcBasicSalary = val),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Housing: ${_calcHousingPercent.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12)),
                                  Slider(
                                    value: _calcHousingPercent,
                                    min: 0,
                                    max: 40,
                                    divisions: 8,
                                    onChanged: (v) => setState(() => _calcHousingPercent = v),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Transport: ${_calcTransportPercent.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12)),
                                  Slider(
                                    value: _calcTransportPercent,
                                    min: 0,
                                    max: 25,
                                    divisions: 5,
                                    onChanged: (v) => setState(() => _calcTransportPercent = v),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        const SizedBox(height: 8),
                        _buildCalcRow('Basic Salary', '${_calcBasicSalary.toStringAsFixed(2)} SAR'),
                        _buildCalcRow('Housing Allowance (${_calcHousingPercent.toStringAsFixed(0)}%)', '${housingCalc.toStringAsFixed(2)} SAR'),
                        _buildCalcRow('Transport Allowance (${_calcTransportPercent.toStringAsFixed(0)}%)', '${transportCalc.toStringAsFixed(2)} SAR'),
                        _buildCalcRow('Other Allowances', '${_calcOtherAllowances.toStringAsFixed(2)} SAR'),
                        const Divider(thickness: 1.5),
                        _buildCalcRow('Total Gross Monthly Package', '${totalPackageCalc.toStringAsFixed(2)} SAR', isBold: true, color: Colors.indigo),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Tab 2: Manage Pay Grades ---
  Widget _buildManageGradesTab(List<PayGrade> grades, ThemeData theme) {
    final filtered = grades.where((g) {
      final q = _searchQuery.toLowerCase();
      return g.gradeCode.toLowerCase().contains(q) || g.gradeName.toLowerCase().contains(q);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search pay grades by code or title...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'VISUALIZER', label: Text('Salary Bands'), icon: Icon(Icons.bar_chart)),
                  ButtonSegment(value: 'CARDS', label: Text('Cards'), icon: Icon(Icons.view_module)),
                  ButtonSegment(value: 'TABLE', label: Text('Data Table'), icon: Icon(Icons.table_chart)),
                ],
                selected: {_gradesViewMode},
                onSelectionChanged: (val) => setState(() => _gradesViewMode = val.first),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _showAddGradeDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Pay Grade'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700], foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _gradesViewMode == 'VISUALIZER'
                ? _buildGradesVisualizer(filtered)
                : _gradesViewMode == 'TABLE'
                    ? _buildGradesDataTable(filtered)
                    : _buildGradesCardsGrid(filtered),
          ),
        ],
      ),
    );
  }

  Widget _buildGradesVisualizer(List<PayGrade> grades) {
    if (grades.isEmpty) return const Center(child: Text('No pay grades defined.'));

    double globalMin = grades.map((g) => g.minSalary).reduce((a, b) => a < b ? a : b);
    double globalMax = grades.map((g) => g.maxSalary).reduce((a, b) => a > b ? a : b);

    if (globalMin == globalMax) globalMax = globalMin + 10000;
    final totalRange = globalMax - globalMin;

    return SingleChildScrollView(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.stacked_line_chart, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Pay Grade Salary Ranges & Overlap Visualizer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Visualizes min/max salary ranges and compensation overlap across corporate grade levels (${globalMin.toStringAsFixed(0)} SAR to ${globalMax.toStringAsFixed(0)} SAR).',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 24),
              ...grades.map((grade) {
                final leftPct = ((grade.minSalary - globalMin) / totalRange).clamp(0.0, 1.0);
                final widthPct = ((grade.maxSalary - grade.minSalary) / totalRange).clamp(0.05, 1.0);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: InkWell(
                    onTap: () => _showGradeDetailModal(grade),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 140,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Chip(
                                label: Text(grade.gradeCode, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 11)),
                                backgroundColor: Colors.blue[50],
                                visualDensity: VisualDensity.compact,
                              ),
                              Text(grade.gradeName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LayoutBuilder(
                                builder: (ctx, constraints) {
                                  final totalW = constraints.maxWidth;
                                  final leftPos = totalW * leftPct;
                                  final barW = totalW * widthPct;

                                  return Stack(
                                    children: [
                                      Container(
                                        height: 28,
                                        width: totalW,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                      Positioned(
                                        left: leftPos,
                                        width: barW < 40 ? 40 : barW,
                                        child: Container(
                                          height: 28,
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(colors: [Colors.blue[400]!, Colors.indigo[600]!]),
                                            borderRadius: BorderRadius.circular(6),
                                            boxShadow: [
                                              BoxShadow(color: Colors.blue.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2)),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(grade.minSalary.toStringAsFixed(0), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                              Text('${grade.maxSalary.toStringAsFixed(0)} SAR', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Row(
                          children: [
                            Chip(label: Text('${grade.housingAllowancePercent.toStringAsFixed(0)}% Housing'), backgroundColor: Colors.orange[50], visualDensity: VisualDensity.compact),
                            const SizedBox(width: 4),
                            Chip(label: Text('${grade.transportAllowancePercent.toStringAsFixed(0)}% Transport'), backgroundColor: Colors.teal[50], visualDensity: VisualDensity.compact),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradesCardsGrid(List<PayGrade> grades) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: grades.length,
      itemBuilder: (ctx, idx) {
        final grade = grades[idx];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(grade.gradeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text(grade.gradeCode, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 11)),
                      backgroundColor: Colors.blue[50],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Salary Bounds: ${grade.minSalary.toStringAsFixed(0)} - ${grade.maxSalary.toStringAsFixed(0)} SAR', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(grade.description ?? 'No policy notes provided.', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Chip(label: Text('${grade.housingAllowancePercent.toStringAsFixed(0)}% Housing'), backgroundColor: Colors.orange[50], visualDensity: VisualDensity.compact),
                        const SizedBox(width: 6),
                        Chip(label: Text('${grade.transportAllowancePercent.toStringAsFixed(0)}% Transport'), backgroundColor: Colors.teal[50], visualDensity: VisualDensity.compact),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline, color: Colors.blue),
                      onPressed: () => _showGradeDetailModal(grade),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGradesDataTable(List<PayGrade> grades) {
    return SingleChildScrollView(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Code', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Grade Title & Level', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Min Salary', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Max Salary', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Housing %', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Transport %', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Description', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: grades.map((g) {
              return DataRow(
                cells: [
                  DataCell(Chip(label: Text(g.gradeCode, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 11)), backgroundColor: Colors.blue[50])),
                  DataCell(Text(g.gradeName, style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text('${g.minSalary.toStringAsFixed(0)} SAR')),
                  DataCell(Text('${g.maxSalary.toStringAsFixed(0)} SAR')),
                  DataCell(Text('${g.housingAllowancePercent.toStringAsFixed(0)}%')),
                  DataCell(Text('${g.transportAllowancePercent.toStringAsFixed(0)}%')),
                  DataCell(Text(g.description ?? '', maxLines: 1, overflow: TextOverflow.ellipsis)),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showGradeDetailModal(PayGrade grade) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${grade.gradeCode} - ${grade.gradeName}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Chip(label: Text(grade.gradeCode, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)), backgroundColor: Colors.blue[50]),
              ],
            ),
            const Divider(height: 24),
            _buildCalcRow('Minimum Basic Salary', '${grade.minSalary.toStringAsFixed(2)} SAR'),
            _buildCalcRow('Maximum Basic Salary Ceiling', '${grade.maxSalary.toStringAsFixed(2)} SAR'),
            _buildCalcRow('Default Housing Allowance', '${grade.housingAllowancePercent.toStringAsFixed(0)}% of Basic'),
            _buildCalcRow('Default Transport Allowance', '${grade.transportAllowancePercent.toStringAsFixed(0)}% of Basic'),
            const SizedBox(height: 12),
            Text('Policy Scope & Description:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800])),
            const SizedBox(height: 4),
            Text(grade.description ?? 'No detailed description specified.', style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(ctx),
                icon: const Icon(Icons.check),
                label: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Bulk Step Generator Dialog ---
  void _showBulkGenerateScalesDialog(List<PayGrade> grades) {
    String selectedGradeCode = grades.isNotEmpty ? grades.first.gradeCode : 'G1';
    final baseSalaryController = TextEditingController(text: '5000');
    final stepsCountController = TextEditingController(text: '5');
    final incrementController = TextEditingController(text: '5.0');
    final housingPercentController = TextEditingController(text: '25');
    final transportPercentController = TextEditingController(text: '10');
    final medicalController = TextEditingController(text: '500');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.purple),
            SizedBox(width: 8),
            Text('Bulk Auto-Generate Pay Scale Steps'),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedGradeCode,
                  decoration: const InputDecoration(labelText: 'Target Pay Grade', border: OutlineInputBorder()),
                  items: grades
                      .map((g) => DropdownMenuItem(value: g.gradeCode, child: Text('${g.gradeCode} - ${g.gradeName}')))
                      .toList(),
                  onChanged: (val) => selectedGradeCode = val ?? 'G1',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: baseSalaryController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Step 1 Basic Salary (SAR)', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: stepsCountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Number of Steps (e.g. 5-10)', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: incrementController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Annual Increment % per Step', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: housingPercentController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Housing Allowance %', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: transportPercentController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Transport Allowance %', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: medicalController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Medical Allowance (SAR)', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () async {
              final numSteps = int.tryParse(stepsCountController.text) ?? 5;
              final baseSal = double.tryParse(baseSalaryController.text) ?? 5000;
              final incRate = double.tryParse(incrementController.text) ?? 5.0;
              final housingPct = double.tryParse(housingPercentController.text) ?? 25;
              final transportPct = double.tryParse(transportPercentController.text) ?? 10;
              final medical = double.tryParse(medicalController.text) ?? 500;

              try {
                final api = ref.read(hrApiProvider);
                for (int i = 1; i <= numSteps; i++) {
                  final factor = 1.0 + (i - 1) * (incRate / 100.0);
                  final bSal = (baseSal * factor).roundToDouble();
                  final hSal = (bSal * (housingPct / 100.0)).roundToDouble();
                  final tSal = (bSal * (transportPct / 100.0)).roundToDouble();

                  await api.createPayScale({
                    'grade_code': selectedGradeCode,
                    'scale_name': 'Step $i',
                    'basic_salary': bSal,
                    'housing_allowance': hSal,
                    'transport_allowance': tSal,
                    'medical_allowance': medical,
                    'other_allowances': 0,
                    'increment_rate': incRate,
                  });
                }
                ref.invalidate(payScalesProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error auto-generating steps: $e')));
                }
              }
            },
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate Matrix Steps'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  // --- Tab 3: Manage Pay Scales & Steps ---
  Widget _buildManageScalesTab(List<PayGrade> grades, List<PayScale> scales, ThemeData theme) {
    var displayGrades = grades;
    if (_selectedGradeFilter != 'ALL') {
      displayGrades = displayGrades.where((g) => g.gradeCode == _selectedGradeFilter).toList();
    }

    var filteredScales = scales;
    if (_selectedGradeFilter != 'ALL') {
      filteredScales = filteredScales.where((s) => s.gradeCode == _selectedGradeFilter).toList();
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Toolbar header
          Row(
            children: [
              // Grade Filter
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: _selectedGradeFilter,
                  underline: const SizedBox(),
                  items: [
                    const DropdownMenuItem(value: 'ALL', child: Text('All Pay Grades')),
                    ...grades.map((g) => DropdownMenuItem(value: g.gradeCode, child: Text('${g.gradeCode} - ${g.gradeName}'))),
                  ],
                  onChanged: (val) => setState(() => _selectedGradeFilter = val ?? 'ALL'),
                ),
              ),
              const SizedBox(width: 16),
              // View Mode Selector
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'MATRIX', label: Text('Matrix Grid'), icon: Icon(Icons.grid_on)),
                  ButtonSegment(value: 'CARDS', label: Text('Cards'), icon: Icon(Icons.view_module)),
                  ButtonSegment(value: 'TABLE', label: Text('Data Table'), icon: Icon(Icons.table_chart)),
                ],
                selected: {_scalesViewMode},
                onSelectionChanged: (val) => setState(() => _scalesViewMode = val.first),
              ),
              const Spacer(),
              // Bulk Auto Generator Button
              OutlinedButton.icon(
                onPressed: () => _showBulkGenerateScalesDialog(grades),
                icon: const Icon(Icons.auto_awesome, color: Colors.purple),
                label: const Text('Bulk Auto-Generate Steps'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.purple, side: const BorderSide(color: Colors.purple)),
              ),
              const SizedBox(width: 12),
              // Add Single Step Button
              ElevatedButton.icon(
                onPressed: () => _showAddScaleDialog(grades),
                icon: const Icon(Icons.add),
                label: const Text('Add Scale Step'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Content based on View Mode
          Expanded(
            child: _scalesViewMode == 'MATRIX'
                ? _buildScalesMatrixGrid(displayGrades, scales)
                : _scalesViewMode == 'TABLE'
                    ? _buildScalesDataTable(filteredScales)
                    : _buildScalesCardsGrid(filteredScales),
          ),
        ],
      ),
    );
  }

  Widget _buildScalesMatrixGrid(List<PayGrade> grades, List<PayScale> scales) {
    const steps = ['Step 1', 'Step 2', 'Step 3', 'Step 4', 'Step 5'];

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.purple[50]),
              border: TableBorder.all(color: Colors.grey[200]!, width: 1),
              columns: [
                const DataColumn(label: Text('Pay Grade Level', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                ...steps.map((st) => DataColumn(label: Text(st, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)))),
              ],
              rows: grades.map((grade) {
                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          Chip(
                            label: Text(grade.gradeCode, style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
                            backgroundColor: Colors.purple[100],
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(grade.gradeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text('${grade.minSalary.toStringAsFixed(0)} - ${grade.maxSalary.toStringAsFixed(0)} SAR', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ...steps.map((stepName) {
                      final scaleMatch = scales.firstWhere(
                        (s) => s.gradeCode == grade.gradeCode && s.scaleName.toLowerCase().contains(stepName.toLowerCase()),
                        orElse: () => PayScale(
                          id: '',
                          gradeCode: '',
                          scaleName: '',
                          basicSalary: 0,
                          housingAllowance: 0,
                          transportAllowance: 0,
                          medicalAllowance: 0,
                          otherAllowances: 0,
                          totalPackage: 0,
                          incrementRate: 0,
                        ),
                      );

                      if (scaleMatch.id.isNotEmpty) {
                        return DataCell(
                          InkWell(
                            onTap: () => _showScaleDetailModal(scaleMatch),
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.indigo[50],
                                border: Border.all(color: Colors.indigo[100]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${scaleMatch.basicSalary.toStringAsFixed(0)} SAR', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.indigo)),
                                  Text('Total: ${scaleMatch.totalPackage.toStringAsFixed(0)} SAR', style: TextStyle(fontSize: 11, color: Colors.grey[700])),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        return DataCell(
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8), visualDensity: VisualDensity.compact),
                            onPressed: () => _showAddScaleDialog([grade]),
                            child: Text('+ Add $stepName', style: const TextStyle(fontSize: 11)),
                          ),
                        );
                      }
                    }),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScalesCardsGrid(List<PayScale> scales) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: scales.length,
      itemBuilder: (ctx, idx) {
        final scale = scales[idx];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.purple[100]!)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(scale.scaleName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text(scale.gradeCode, style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 11)),
                      backgroundColor: Colors.purple[50],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Basic Salary: ${scale.basicSalary.toStringAsFixed(2)} SAR', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Housing: ${scale.housingAllowance.toStringAsFixed(2)} SAR  •  Transport: ${scale.transportAllowance.toStringAsFixed(2)} SAR', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                Text('Medical: ${scale.medicalAllowance.toStringAsFixed(2)} SAR  •  Other: ${scale.otherAllowances.toStringAsFixed(2)} SAR', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total: ${scale.totalPackage.toStringAsFixed(2)} SAR', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 15)),
                    Text('+${scale.incrementRate}% Annual Inc', style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScalesDataTable(List<PayScale> scales) {
    return SingleChildScrollView(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Grade', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Scale / Step Name', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Basic Salary', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Housing', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Transport', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Medical / Other', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Total Package', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Increment %', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: scales.map((s) {
              return DataRow(
                cells: [
                  DataCell(Chip(label: Text(s.gradeCode, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple, fontSize: 11)), backgroundColor: Colors.purple[50])),
                  DataCell(Text(s.scaleName, style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text('${s.basicSalary.toStringAsFixed(2)} SAR')),
                  DataCell(Text('${s.housingAllowance.toStringAsFixed(2)} SAR')),
                  DataCell(Text('${s.transportAllowance.toStringAsFixed(2)} SAR')),
                  DataCell(Text('${(s.medicalAllowance + s.otherAllowances).toStringAsFixed(2)} SAR')),
                  DataCell(Text('${s.totalPackage.toStringAsFixed(2)} SAR', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
                  DataCell(Text('+${s.incrementRate}%', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showScaleDetailModal(PayScale scale) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${scale.gradeCode} - ${scale.scaleName}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Chip(label: Text('+${scale.incrementRate}% Inc Rate', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)), backgroundColor: Colors.green[50]),
              ],
            ),
            const Divider(height: 24),
            _buildCalcRow('Basic Salary', '${scale.basicSalary.toStringAsFixed(2)} SAR'),
            _buildCalcRow('Housing Allowance', '${scale.housingAllowance.toStringAsFixed(2)} SAR'),
            _buildCalcRow('Transport Allowance', '${scale.transportAllowance.toStringAsFixed(2)} SAR'),
            _buildCalcRow('Medical Allowance', '${scale.medicalAllowance.toStringAsFixed(2)} SAR'),
            _buildCalcRow('Other Allowances', '${scale.otherAllowances.toStringAsFixed(2)} SAR'),
            const Divider(height: 24, thickness: 1.5),
            _buildCalcRow('Total Gross Monthly Package', '${scale.totalPackage.toStringAsFixed(2)} SAR', isBold: true, color: Colors.indigo),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(ctx),
                icon: const Icon(Icons.check),
                label: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: color.withValues(alpha: 0.1), child: Icon(icon, color: color)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalcRow(String label, String val, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 14 : 13, color: color)),
          Text(val, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w600, fontSize: isBold ? 15 : 13, color: color)),
        ],
      ),
    );
  }
}
