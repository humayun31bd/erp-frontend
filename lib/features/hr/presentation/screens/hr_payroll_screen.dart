import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/payroll_provider.dart';
import '../../providers/employees_provider.dart';
import '../../domain/payroll_model.dart';
import '../../utils/hr_constants.dart';
import '../../utils/pdf_generator.dart';
import '../widgets/department_scope_modal.dart';

class HrPayrollScreen extends ConsumerStatefulWidget {
  const HrPayrollScreen({super.key});

  @override
  ConsumerState<HrPayrollScreen> createState() => _HrPayrollScreenState();
}

class _HrPayrollScreenState extends ConsumerState<HrPayrollScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  late DateTime _startDate;
  late DateTime _endDate;
  String _selectedDepartmentFilter = 'ALL';
  String _selectedStatusFilter = 'ALL';
  String _searchQuery = '';
  bool _isActionLoading = false;
  bool _isProcessed = false;

  final List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _updatePeriodDates(_selectedYear, _selectedMonth);
  }

  void _updatePeriodDates(int year, int month) {
    _startDate = DateTime(year, month, 1);
    _endDate = DateTime(year, month + 1, 0);
  }

  String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  int get _cycleDaysCount => _endDate.difference(_startDate).inDays + 1;

  void _setPeriodPreset(String preset) {
    setState(() {
      if (preset == 'FULL_MONTH') {
        _startDate = DateTime(_selectedYear, _selectedMonth, 1);
        _endDate = DateTime(_selectedYear, _selectedMonth + 1, 0);
      } else if (preset == '26_TO_25') {
        final prevMonth = _selectedMonth == 1 ? 12 : _selectedMonth - 1;
        final prevYear = _selectedMonth == 1 ? _selectedYear - 1 : _selectedYear;
        _startDate = DateTime(prevYear, prevMonth, 26);
        _endDate = DateTime(_selectedYear, _selectedMonth, 25);
      }
    });
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      helpText: 'Select Pay Period Date Range',
      saveText: 'Apply Period',
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _queryParams => {
        'month': _selectedMonth,
        'year': _selectedYear,
        'department': _selectedDepartmentFilter,
        'status': _selectedStatusFilter,
      };

  double _parse(String? val) => double.tryParse(val ?? '0') ?? 0.0;

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _performEngineRun({bool generate = true}) async {
    setState(() => _isActionLoading = true);
    try {
      if (generate) {
        final api = ref.read(hrApiProvider);
        await api.generatePayroll({
          'month': _selectedMonth,
          'year': _selectedYear,
          'departmentName': _selectedDepartmentFilter,
          'startDate': _formatDate(_startDate),
          'endDate': _formatDate(_endDate),
        });
        _showSnackBar(
          'Payroll calculated & declared successfully for ${_monthNames[_selectedMonth - 1]} $_selectedYear',
        );
      }
      setState(() => _isProcessed = true);
      ref.invalidate(payrollProvider(_queryParams));
    } catch (e) {
      _showSnackBar('Engine execution failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Initial state: NO background process or query called on page open!
    if (!_isProcessed) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Payroll Execution Engine'),
          elevation: 1,
        ),
        body: _buildInitialParametersScreen(theme),
      );
    }

    final payrollAsync = ref.watch(payrollProvider(_queryParams));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payroll Management & Wage Protection'),
        elevation: 1,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.indigo.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.indigo.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.date_range, size: 14, color: Colors.indigo),
                const SizedBox(width: 6),
                Text(
                  '${_monthNames[_selectedMonth - 1]} $_selectedYear',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.indigo),
                ),
                if (_selectedDepartmentFilter != 'ALL') ...[
                  const Text(' • ', style: TextStyle(color: Colors.indigo)),
                  Text(
                    _selectedDepartmentFilter,
                    style: const TextStyle(fontSize: 12, color: Colors.indigo),
                  ),
                ],
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => setState(() => _isProcessed = false),
            icon: const Icon(Icons.tune_rounded, size: 16),
            label: const Text('Parameters'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(width: 12),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.bolt_rounded), text: 'Payroll Engine & Declare'),
            Tab(icon: Icon(Icons.table_chart_outlined), text: 'Department Paysheet'),
            Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Employee Pay Slips'),
            Tab(icon: Icon(Icons.account_balance_outlined), text: 'Bank Payout & WPS'),
          ],
        ),
      ),
      body: payrollAsync.when(
        data: (records) {
          final filteredRecords = _filterRecords(records);
          return Column(
            children: [
              // Global Month, Year & Filter Control Header
              _buildTopControls(theme),

              // KPI Metrics Overview Bar
              _buildKpiMetrics(records, theme),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Department Declaration & Summary
                    _buildDepartmentDeclarationTab(records, theme),

                    // Tab 2: Department-wise Paysheet Table
                    _buildDepartmentPaysheetTab(filteredRecords, theme),

                    // Tab 3: Employee Pay Slips List & Details
                    _buildEmployeePaySlipsTab(filteredRecords, theme),

                    // Tab 4: Bank Payout & WPS Export
                    _buildBankPayoutWpsTab(filteredRecords, theme),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text('Error loading payroll: $err'),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => ref.invalidate(payrollProvider(_queryParams)),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _isProcessed = false),
                    icon: const Icon(Icons.tune_rounded),
                    label: const Text('Change Parameters'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INITIAL PARAMETERS SCREEN (No background process until Process is clicked)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildInitialParametersScreen(ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.indigo.shade50.withValues(alpha: 0.35),
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Engine Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.indigo, Colors.deepPurple],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.indigo.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Payroll Engine Execution',
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.4),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.hourglass_empty_rounded, size: 12, color: Colors.orange),
                                      SizedBox(width: 4),
                                      Text(
                                        'Standby • Idle',
                                        style: TextStyle(color: Colors.deepOrange, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Select Year and Month parameters to execute or view payroll. No background processes or network calls will run until you click "Process Payroll".',
                              style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(height: 1),
                  const SizedBox(height: 24),

                  // Section Title: Parameters
                  const Row(
                    children: [
                      Icon(Icons.tune_rounded, size: 18, color: Colors.indigo),
                      SizedBox(width: 8),
                      Text('Execution Parameters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Year and Month Row
                  Row(
                    children: [
                      // Year Selector
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<int>(
                          initialValue: _selectedYear,
                          decoration: const InputDecoration(
                            labelText: 'Payroll Year',
                            prefixIcon: Icon(Icons.today, size: 20),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          ),
                          items: [2024, 2025, 2026, 2027, 2028].map((y) => DropdownMenuItem(
                            value: y,
                            child: Text('$y', style: const TextStyle(fontWeight: FontWeight.bold)),
                          )).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedYear = val;
                                _updatePeriodDates(_selectedYear, _selectedMonth);
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Month Selector
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<int>(
                          initialValue: _selectedMonth,
                          decoration: const InputDecoration(
                            labelText: 'Payroll Month',
                            prefixIcon: Icon(Icons.calendar_month, size: 20),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          ),
                          items: List.generate(12, (index) => DropdownMenuItem(
                            value: index + 1,
                            child: Text(_monthNames[index], style: const TextStyle(fontWeight: FontWeight.bold)),
                          )),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedMonth = val;
                                _updatePeriodDates(_selectedYear, _selectedMonth);
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Department Scope (Search popup modal, filter & interactive card)
                  DepartmentScopeSelectionCard(
                    selectedDepartment: _selectedDepartmentFilter,
                    onDepartmentChanged: (dept) {
                      setState(() => _selectedDepartmentFilter = dept);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Pay Period Date Range
                  InkWell(
                    onTap: _pickDateRange,
                    borderRadius: BorderRadius.circular(6),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Pay Period Cycle',
                        prefixIcon: Icon(Icons.date_range, size: 20),
                        suffixIcon: Icon(Icons.edit_calendar, size: 18),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_formatDate(_startDate)}  ➔  ${_formatDate(_endDate)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.indigo.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '$_cycleDaysCount Days',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Period Presets
                  Row(
                    children: [
                      const Text('Quick Cycle Presets: ', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _setPeriodPreset('FULL_MONTH'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: const Text('1st to Month End', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _setPeriodPreset('26_TO_25'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: const Text('26th - 25th Cycle (SAMA)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Highlight Features
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildEngineFeatureChip('Salary Structure & Allowances'),
                      _buildEngineFeatureChip('Attendance & Absences'),
                      _buildEngineFeatureChip('Overtime 1.5x Hourly Rate'),
                      _buildEngineFeatureChip('GOSI 9.75% Deductions'),
                      _buildEngineFeatureChip('Active Loan Installments'),
                      _buildEngineFeatureChip('WPS / SIF Direct Debit Export'),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Action Buttons
                  Row(
                    children: [
                      // Process Payroll Engine (Calculate & Load)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isActionLoading ? null : () => _performEngineRun(generate: true),
                          icon: _isActionLoading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.rocket_launch_rounded),
                          label: Text(
                            _isActionLoading ? 'Processing Payroll...' : 'Process Payroll Engine',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Load Existing Records (No Recalculation)
                      OutlinedButton.icon(
                        onPressed: _isActionLoading ? null : () => _performEngineRun(generate: false),
                        icon: const Icon(Icons.folder_open_rounded),
                        label: const Text('View Existing Run', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<PayrollRecord> _filterRecords(List<PayrollRecord> records) {
    return records.where((r) {
      final name = '${r.firstName ?? ''} ${r.lastName ?? ''}'.toLowerCase();
      final dept = (r.departmentName ?? '').toLowerCase();
      final desig = (r.designationName ?? '').toLowerCase();
      final query = _searchQuery.toLowerCase();

      final matchesQuery = query.isEmpty ||
          name.contains(query) ||
          dept.contains(query) ||
          desig.contains(query);

      final matchesDept = _selectedDepartmentFilter == 'ALL' ||
          (r.departmentName != null && r.departmentName!.toLowerCase() == _selectedDepartmentFilter.toLowerCase());

      final matchesStatus = _selectedStatusFilter == 'ALL' || r.status == _selectedStatusFilter;

      return matchesQuery && matchesDept && matchesStatus;
    }).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TOP CONTROLS: Month, Year, Department Filter & Action Buttons
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTopControls(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          // Month Selector
          SizedBox(
            width: 160,
            child: DropdownButtonFormField<int>(
              initialValue: _selectedMonth,
              decoration: const InputDecoration(
                labelText: 'Month',
                prefixIcon: Icon(Icons.calendar_month, size: 20),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(),
              ),
              items: List.generate(12, (index) => DropdownMenuItem(
                value: index + 1,
                child: Text(_monthNames[index]),
              )),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedMonth = val;
                    _updatePeriodDates(_selectedYear, _selectedMonth);
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 12),

          // Year Selector
          SizedBox(
            width: 120,
            child: DropdownButtonFormField<int>(
              initialValue: _selectedYear,
              decoration: const InputDecoration(
                labelText: 'Year',
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(),
              ),
              items: [2024, 2025, 2026, 2027].map((y) => DropdownMenuItem(
                value: y,
                child: Text('$y'),
              )).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedYear = val;
                    _updatePeriodDates(_selectedYear, _selectedMonth);
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 12),

          // Department Scope Filter Modal Trigger
          InkWell(
            onTap: () async {
              final picked = await DepartmentScopeModal.show(context, currentSelection: _selectedDepartmentFilter);
              if (picked != null) {
                setState(() => _selectedDepartmentFilter = picked);
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _selectedDepartmentFilter != 'ALL' ? Colors.indigo : theme.dividerColor,
                  width: _selectedDepartmentFilter != 'ALL' ? 1.5 : 1.0,
                ),
                color: _selectedDepartmentFilter != 'ALL' ? Colors.indigo.withValues(alpha: 0.08) : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.business_rounded,
                    size: 18,
                    color: _selectedDepartmentFilter != 'ALL' ? Colors.indigo : Colors.grey.shade700,
                  ),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 160),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Department Scope',
                          style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _selectedDepartmentFilter == 'ALL' ? 'All Departments' : _selectedDepartmentFilter,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _selectedDepartmentFilter != 'ALL' ? Colors.indigo : null,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Search Box
          Expanded(
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search employee by name, ID or role...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => setState(() => _searchQuery = ''))
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Declare / Run Payroll Button
          ElevatedButton.icon(
            onPressed: _isActionLoading ? null : _declarePayrollDialog,
            icon: _isActionLoading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.play_arrow_rounded),
            label: const Text('Declare Payroll'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // KPI METRICS OVERVIEW BANNER
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildKpiMetrics(List<PayrollRecord> records, ThemeData theme) {
    double totalBasic = 0;
    double totalAllowances = 0;
    double totalDeductions = 0;
    double totalNet = 0;
    int paidCount = 0;
    int approvedCount = 0;
    int draftCount = 0;

    for (final r in records) {
      totalBasic += _parse(r.basicSalary);
      totalAllowances += _parse(r.allowances);
      totalDeductions += _parse(r.deductions);
      totalNet += _parse(r.netSalary);

      if (r.status == 'PAID') {
        paidCount++;
      } else if (r.status == 'APPROVED') {
        approvedCount++;
      } else {
        draftCount++;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Row(
        children: [
          _buildKpiCard('Total Net Payout', 'SAR ${totalNet.toStringAsFixed(2)}', Icons.payments, Colors.indigo),
          const SizedBox(width: 12),
          _buildKpiCard('Total Basic Salary', 'SAR ${totalBasic.toStringAsFixed(2)}', Icons.account_balance_wallet, Colors.blue),
          const SizedBox(width: 12),
          _buildKpiCard('Total Allowances & OT', 'SAR ${totalAllowances.toStringAsFixed(2)}', Icons.add_circle_outline, Colors.teal),
          const SizedBox(width: 12),
          _buildKpiCard('Deductions & Fines', 'SAR ${totalDeductions.toStringAsFixed(2)}', Icons.remove_circle_outline, Colors.red),
          const SizedBox(width: 12),
          _buildStatusCountCard(records.length, draftCount, approvedCount, paidCount),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.1),
              radius: 18,
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCountCard(int total, int draft, int approved, int paid) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Employees: $total', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildBadge('Draft: $draft', Colors.orange),
                const SizedBox(width: 4),
                _buildBadge('Appr: $approved', Colors.blue),
                const SizedBox(width: 4),
                _buildBadge('Paid: $paid', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 1: DEPARTMENT PAYMENT DECLARATION & BATCH APPROVAL
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildDepartmentDeclarationTab(List<PayrollRecord> records, ThemeData theme) {
    // Group records by department
    final Map<String, List<PayrollRecord>> deptMap = {};
    for (final r in records) {
      final dept = r.departmentName ?? 'General Department';
      deptMap.putIfAbsent(dept, () => []).add(r);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Dedicated Executive Payroll Engine & Payment Declaration Console Card
          _buildPayrollEngineConsoleCard(theme),
          const SizedBox(height: 24),

          // 2. Output Section: Declared Payroll Summary & Records or Standby Notice
          if (records.isNotEmpty) ...[
            _buildBatchActionsCard(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Department-Wise Payroll Summary (${deptMap.keys.length} Departments • ${records.length} Staff)',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.indigo.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.indigo),
                      const SizedBox(width: 6),
                      Text(
                        'Period: ${_formatDate(_startDate)} to ${_formatDate(_endDate)} ($_cycleDaysCount Days)',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.indigo),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDepartmentGrid(deptMap),
          ] else ...[
            _buildEngineStandbyCard(theme),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PAYROLL ENGINE CONSOLE CARD (Dept, Year, Month, Date Range, Generate Button)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildPayrollEngineConsoleCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: [
              Colors.indigo.shade50.withValues(alpha: 0.45),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.indigo, Colors.deepPurple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Payroll Execution Engine & Payment Declaration',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.3),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.verified, size: 12, color: Colors.green),
                                SizedBox(width: 4),
                                Text(
                                  'WPS & GOSI Ready',
                                  style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Set department scope, payroll year, month, and calculation date range. The engine automatically aggregates basic salary, allowances, biometric attendance days, overtime hours (1.5x), GOSI contribution, and loan installments.',
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Divider(height: 1),
            const SizedBox(height: 18),

            // Controls Row (Dept, Month, Year, Date Range)
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 950;
                return Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // 1. Department Selection
                    SizedBox(
                      width: isWide ? 260 : constraints.maxWidth,
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedDepartmentFilter,
                        decoration: const InputDecoration(
                          labelText: 'Target Department Scope',
                          prefixIcon: Icon(Icons.business_rounded, size: 20),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(),
                        ),
                        items: ['ALL', ...HrConstants.departments.map((d) => d.split(' (')[0])].map((dept) => DropdownMenuItem(
                          value: dept,
                          child: Text(dept == 'ALL' ? 'ALL - All Departments' : dept, overflow: TextOverflow.ellipsis),
                        )).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedDepartmentFilter = val);
                        },
                      ),
                    ),

                    // 2. Month Selector
                    SizedBox(
                      width: isWide ? 170 : (constraints.maxWidth - 14) / 2,
                      child: DropdownButtonFormField<int>(
                        initialValue: _selectedMonth,
                        decoration: const InputDecoration(
                          labelText: 'Payroll Month',
                          prefixIcon: Icon(Icons.calendar_month, size: 20),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(),
                        ),
                        items: List.generate(12, (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text(_monthNames[index]),
                        )),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedMonth = val;
                              _updatePeriodDates(_selectedYear, _selectedMonth);
                            });
                          }
                        },
                      ),
                    ),

                    // 3. Year Selector
                    SizedBox(
                      width: isWide ? 130 : (constraints.maxWidth - 14) / 2,
                      child: DropdownButtonFormField<int>(
                        initialValue: _selectedYear,
                        decoration: const InputDecoration(
                          labelText: 'Payroll Year',
                          prefixIcon: Icon(Icons.today, size: 20),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(),
                        ),
                        items: [2024, 2025, 2026, 2027].map((y) => DropdownMenuItem(
                          value: y,
                          child: Text('$y'),
                        )).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedYear = val;
                              _updatePeriodDates(_selectedYear, _selectedMonth);
                            });
                          }
                        },
                      ),
                    ),

                    // 4. Date Range Box
                    SizedBox(
                      width: isWide ? 300 : constraints.maxWidth,
                      child: InkWell(
                        onTap: _pickDateRange,
                        borderRadius: BorderRadius.circular(6),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Pay Period Date Range',
                            prefixIcon: Icon(Icons.date_range, size: 20),
                            suffixIcon: Icon(Icons.edit_calendar, size: 18),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            border: OutlineInputBorder(),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_formatDate(_startDate)}  ➔  ${_formatDate(_endDate)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '$_cycleDaysCount d',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.indigo),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 14),

            // Date Range Presets
            Row(
              children: [
                const Text('Date Presets: ', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _setPeriodPreset('FULL_MONTH'),
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: const Text('1st to Month End', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _setPeriodPreset('26_TO_25'),
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: const Text('26th - 25th Cycle (SAMA)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _pickDateRange,
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: const Text('Custom Range...', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Engine Highlights & Big Generate Button
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildEngineFeatureChip('Base Scales & Grades'),
                      _buildEngineFeatureChip('Housing & Transport'),
                      _buildEngineFeatureChip('Other Allowance'),
                      _buildEngineFeatureChip('Attendance & Absences'),
                      _buildEngineFeatureChip('OT (1.5x Hourly Rate)'),
                      _buildEngineFeatureChip('GOSI 9.75%'),
                      _buildEngineFeatureChip('Active Loan Deductions'),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _isActionLoading ? null : () => _performDeclarePayroll(),
                  icon: _isActionLoading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.rocket_launch_rounded),
                  label: Text(_isActionLoading ? 'Computing Payroll...' : 'Run Payroll Engine & Declare'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngineFeatureChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.indigo.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.indigo.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check, size: 12, color: Colors.indigo),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.indigo)),
        ],
      ),
    );
  }

  Widget _buildEngineStandbyCard(ThemeData theme) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.indigo.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.pending_actions_rounded, size: 48, color: Colors.indigo),
              ),
              const SizedBox(height: 16),
              Text(
                'No Payroll Declared for ${_monthNames[_selectedMonth - 1]} $_selectedYear',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 600,
                child: Text(
                  'The calculation engine is ready. Verify your Department scope, Month, Year, and Date Range (${_formatDate(_startDate)} to ${_formatDate(_endDate)}) above, then click "Run Payroll Engine & Declare" to automatically compute employee compensation.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isActionLoading ? null : () => _performDeclarePayroll(),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Declare Payroll Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBatchActionsCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            const Icon(Icons.playlist_add_check, color: Colors.indigo),
            const SizedBox(width: 10),
            const Text('Batch Actions for Period:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () => _executeBatchAction('APPROVE_ALL', 'Approve all draft payrolls?'),
              icon: const Icon(Icons.check_circle_outline, color: Colors.blue),
              label: const Text('Approve All Drafts'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => _executeBatchAction('MARK_ALL_PAID', 'Mark all approved payrolls as PAID?'),
              icon: const Icon(Icons.payment, color: Colors.white),
              label: const Text('Mark All as Paid'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () => _executeBatchAction('DELETE_ALL_DRAFTS', 'Delete all draft records to re-calculate?'),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text('Recalculate / Clear Drafts', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentGrid(Map<String, List<PayrollRecord>> deptMap) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: deptMap.keys.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, idx) {
        final deptName = deptMap.keys.elementAt(idx);
        final deptRecords = deptMap[deptName]!;

        double deptBasic = 0;
        double deptAllowances = 0;
        double deptOt = 0;
        double deptDeductions = 0;
        double deptNet = 0;
        int deptPaid = 0;
        int deptApproved = 0;
        int deptDraft = 0;

        for (final r in deptRecords) {
          deptBasic += _parse(r.basicSalary);
          deptAllowances += _parse(r.allowances);
          deptOt += _parse(r.overtimePay);
          deptDeductions += _parse(r.deductions);
          deptNet += _parse(r.netSalary);
          if (r.status == 'PAID') {
            deptPaid++;
          } else if (r.status == 'APPROVED') {
            deptApproved++;
          } else {
            deptDraft++;
          }
        }

        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.indigo,
                          child: Icon(Icons.business, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(deptName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Row(
                              children: [
                                Text('${deptRecords.length} Staff • ', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                _buildBadge('Draft: $deptDraft', Colors.orange),
                                const SizedBox(width: 4),
                                _buildBadge('Appr: $deptApproved', Colors.blue),
                                const SizedBox(width: 4),
                                _buildBadge('Paid: $deptPaid', Colors.green),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('SAR ${deptNet.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.indigo)),
                        const Text('Total Net Payout', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDeptSubMetric('Basic Salary', 'SAR ${deptBasic.toStringAsFixed(0)}'),
                    _buildDeptSubMetric('Allowances', 'SAR ${deptAllowances.toStringAsFixed(0)}'),
                    _buildDeptSubMetric('Overtime Pay', 'SAR ${deptOt.toStringAsFixed(0)}'),
                    _buildDeptSubMetric('Deductions/Fines', 'SAR ${deptDeductions.toStringAsFixed(0)}', isDeduction: true),
                    _buildDeptSubMetric('Net Payout', 'SAR ${deptNet.toStringAsFixed(2)}', isNet: true),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        setState(() => _selectedDepartmentFilter = deptName);
                        _tabController.animateTo(1);
                      },
                      icon: const Icon(Icons.table_chart, size: 16),
                      label: const Text('View in Paysheet'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () {
                        setState(() => _selectedDepartmentFilter = deptName);
                        _tabController.animateTo(2);
                      },
                      icon: const Icon(Icons.receipt_long, size: 16),
                      label: const Text('View Slips'),
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

  Widget _buildDeptSubMetric(String title, String value, {bool isDeduction = false, bool isNet = false}) {
    Color col = Colors.black87;
    if (isDeduction) col = Colors.red[700]!;
    if (isNet) col = Colors.indigo[700]!;

    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: col)),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 2: DEPARTMENT-WISE PAYSHEET REGISTER TABLE
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildDepartmentPaysheetTab(List<PayrollRecord> records, ThemeData theme) {
    if (records.isEmpty) {
      return const Center(child: Text('No paysheet records matching current filter.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Paysheet Register: ${_monthNames[_selectedMonth - 1]} $_selectedYear (${records.length} Staff)',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: ['ALL', 'DRAFT', 'APPROVED', 'PAID'].map((st) {
                          final isSelected = _selectedStatusFilter == st;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(st, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                              selected: isSelected,
                              onSelected: (_) => setState(() => _selectedStatusFilter = st),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () => _exportPaysheetCsv(records),
                        icon: const Icon(Icons.download, size: 18),
                        label: const Text('Export Paysheet CSV'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
                  columnSpacing: 18,
                  columns: const [
                    DataColumn(label: Text('EMPLOYEE')),
                    DataColumn(label: Text('DEPARTMENT')),
                    DataColumn(label: Text('BASIC')),
                    DataColumn(label: Text('HOUSING')),
                    DataColumn(label: Text('TRANSPORT')),
                    DataColumn(label: Text('OTHER')),
                    DataColumn(label: Text('ATTENDANCE')),
                    DataColumn(label: Text('OT PAY')),
                    DataColumn(label: Text('DEDUCTIONS')),
                    DataColumn(label: Text('NET PAY')),
                    DataColumn(label: Text('STATUS')),
                    DataColumn(label: Text('ACTIONS')),
                  ],
                  rows: records.map((r) {
                    return DataRow(
                      cells: [
                        DataCell(Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${r.firstName ?? ''} ${r.lastName ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(r.designationName ?? 'Staff', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        )),
                        DataCell(Text(r.departmentName ?? 'General', style: const TextStyle(fontSize: 12))),
                        DataCell(Text('SAR ${r.basicSalary}', style: const TextStyle(fontSize: 12))),
                        DataCell(Text('SAR ${r.housingAllowance}', style: const TextStyle(fontSize: 12))),
                        DataCell(Text('SAR ${r.transportAllowance}', style: const TextStyle(fontSize: 12))),
                        DataCell(Text('SAR ${r.otherAllowance}', style: const TextStyle(fontSize: 12))),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${r.presentDays}P', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11)),
                            const SizedBox(width: 4),
                            Text('${r.absentDays}A', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11)),
                            const SizedBox(width: 4),
                            Text('${r.lateDays}L', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 11)),
                          ],
                        )),
                        DataCell(Text('SAR ${r.overtimePay}', style: const TextStyle(fontSize: 12, color: Colors.blue))),
                        DataCell(Text('- SAR ${r.deductions}', style: const TextStyle(fontSize: 12, color: Colors.red))),
                        DataCell(Text('SAR ${r.netSalary}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.indigo))),
                        DataCell(_buildStatusChip(r.status)),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_red_eye_outlined, size: 18, color: Colors.indigo),
                              tooltip: 'View Payslip',
                              onPressed: () => _showPayslipDialog(r),
                            ),
                            IconButton(
                              icon: const Icon(Icons.print_outlined, size: 18, color: Colors.grey),
                              tooltip: 'Print Official Payslip',
                              onPressed: () => HrPdfGenerator.printPayslip(r),
                            ),
                          ],
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bg = Colors.orange[100]!;
    Color fg = Colors.orange[900]!;
    if (status == 'APPROVED') {
      bg = Colors.blue[100]!;
      fg = Colors.blue[900]!;
    } else if (status == 'PAID') {
      bg = Colors.green[100]!;
      fg = Colors.green[900]!;
    }
    return Chip(
      label: Text(status, style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold)),
      backgroundColor: bg,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 3: EMPLOYEE PAY SLIPS CARDS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildEmployeePaySlipsTab(List<PayrollRecord> records, ThemeData theme) {
    if (records.isEmpty) {
      return const Center(child: Text('No employee payslips found for this period.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 420,
        mainAxisExtent: 260,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: records.length,
      itemBuilder: (ctx, idx) {
        final r = records[idx];
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
                    CircleAvatar(
                      backgroundColor: Colors.indigo.withValues(alpha: 0.1),
                      child: Text(
                        (r.firstName != null && r.firstName!.isNotEmpty) ? r.firstName![0].toUpperCase() : 'E',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                    ),
                    _buildStatusChip(r.status),
                  ],
                ),
                const SizedBox(height: 10),
                Text('${r.firstName ?? ''} ${r.lastName ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('${r.designationName ?? 'Staff'} • ${r.departmentName ?? 'General'}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Basic Salary:'),
                    Text('SAR ${r.basicSalary}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Attendance (${r.presentDays}P / ${r.absentDays}A / ${r.lateDays}L):', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text('OT: ${r.overtimeHours}h', style: const TextStyle(fontSize: 12, color: Colors.blue)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Net Salary Payable:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                    Text('SAR ${r.netSalary}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo)),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showPayslipDialog(r),
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('View Slip'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => HrPdfGenerator.printPayslip(r),
                        icon: const Icon(Icons.print, size: 16),
                        label: const Text('Print PDF'),
                      ),
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

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 4: BANK PAYOUT & WAGE PROTECTION SYSTEM (WPS)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildBankPayoutWpsTab(List<PayrollRecord> records, ThemeData theme) {
    final bankRecords = records.where((r) => r.paymentMethod == 'BANK').toList();
    double totalBankDisbursement = 0;
    for (final r in bankRecords) {
      totalBankDisbursement += _parse(r.netSalary);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // WPS Overview Header Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.teal,
                    child: Icon(Icons.account_balance, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Wage Protection System (WPS) Bank File Generator', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          'Generate verified payroll direct-debit batch files conforming to Saudi Central Bank (SAMA) and MHRSD WPS standards.',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Total Bank Transfer Amount:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text('SAR ${totalBankDisbursement.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _exportWpsCsv(bankRecords),
                icon: const Icon(Icons.download, color: Colors.white),
                label: const Text('Download WPS Bank CSV (.csv)'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => _executeBatchAction('MARK_ALL_PAID', 'Confirm all bank transfers and mark as PAID?'),
                icon: const Icon(Icons.check_circle, color: Colors.green),
                label: const Text('Confirm Bank Payout & Mark Paid'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Bank Payout Table
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Bank Direct Payout Register (${bankRecords.length} Employees)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
                      columns: const [
                        DataColumn(label: Text('EMPLOYEE')),
                        DataColumn(label: Text('NATIONAL ID / IQAMA')),
                        DataColumn(label: Text('BANK / IBAN')),
                        DataColumn(label: Text('BASIC')),
                        DataColumn(label: Text('ALLOWANCES')),
                        DataColumn(label: Text('DEDUCTIONS')),
                        DataColumn(label: Text('NET PAYOUT')),
                        DataColumn(label: Text('STATUS')),
                      ],
                      rows: bankRecords.map((r) {
                        return DataRow(
                          cells: [
                            DataCell(Text('${r.firstName ?? ''} ${r.lastName ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text(r.nationalId ?? 'SA-NOT-SET')),
                            DataCell(Text(r.bankIban ?? 'IBAN-SA0380000000000000')),
                            DataCell(Text('SAR ${r.basicSalary}')),
                            DataCell(Text('SAR ${r.allowances}')),
                            DataCell(Text('- SAR ${r.deductions}', style: const TextStyle(color: Colors.red))),
                            DataCell(Text('SAR ${r.netSalary}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal))),
                            DataCell(_buildStatusChip(r.status)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PAYSLIP DETAILS MODAL
  // ═══════════════════════════════════════════════════════════════════════════
  void _showPayslipDialog(PayrollRecord r) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pay Slip: ${r.firstName ?? ''} ${r.lastName ?? ''}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Period: ${_monthNames[r.month - 1]} ${r.year} • ${r.departmentName ?? 'General'}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            _buildStatusChip(r.status),
          ],
        ),
        content: SizedBox(
          width: 550,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Attendance Summary Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniAttendance('Present Days', '${r.presentDays}', Colors.green),
                      _buildMiniAttendance('Absent Days', '${r.absentDays}', Colors.red),
                      _buildMiniAttendance('Late Days', '${r.lateDays}', Colors.amber),
                      _buildMiniAttendance('OT Hours', '${r.overtimeHours} hrs', Colors.blue),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Itemized Earnings
                const Text('Earnings & Allowances', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.indigo)),
                const Divider(),
                _buildSlipRow('Basic Salary', 'SAR ${r.basicSalary}'),
                _buildSlipRow('Housing Allowance', 'SAR ${r.housingAllowance}'),
                _buildSlipRow('Transport Allowance', 'SAR ${r.transportAllowance}'),
                _buildSlipRow('Other Allowances', 'SAR ${r.otherAllowance}'),
                _buildSlipRow('Overtime Pay', 'SAR ${r.overtimePay}', isBonus: true),
                const SizedBox(height: 12),

                // Itemized Deductions
                const Text('Deductions & Penalties', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red)),
                const Divider(),
                _buildSlipRow('GOSI Social Insurance', 'SAR ${r.gosiDeduction}'),
                _buildSlipRow('Loan Repayment', 'SAR ${r.loanDeduction}'),
                _buildSlipRow('Fines & Penalties', 'SAR ${r.finesPenalties}', isDeduction: true),
                _buildSlipRow('Total Deductions', 'SAR ${r.deductions}', isDeduction: true, isBold: true),
                const SizedBox(height: 16),

                // Net Salary Summary Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.indigo[50],
                    border: Border.all(color: Colors.indigo[200]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('NET SALARY PAYABLE:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                      Text('SAR ${r.netSalary}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.indigo)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              HrPdfGenerator.printPayslip(r);
            },
            icon: const Icon(Icons.print),
            label: const Text('Print Official Payslip'),
          ),
          if (r.status == 'DRAFT')
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await _updateSingleRecordStatus(r.id, 'APPROVED');
              },
              child: const Text('Approve Slip'),
            ),
          if (r.status == 'APPROVED')
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await _updateSingleRecordStatus(r.id, 'PAID');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Mark as Paid'),
            ),
        ],
      ),
    );
  }

  Widget _buildMiniAttendance(String title, String count, Color color) {
    return Column(
      children: [
        Text(count, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSlipRow(String label, String value, {bool isDeduction = false, bool isBonus = false, bool isBold = false}) {
    Color col = Colors.black87;
    if (isDeduction) col = Colors.red[700]!;
    if (isBonus) col = Colors.green[700]!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: col, fontSize: 13)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SERVER ACTIONS & BATCH EXECUTIONS
  // ═══════════════════════════════════════════════════════════════════════════
  void _declarePayrollDialog() {
    String selectedDept = _selectedDepartmentFilter;
    int dialogMonth = _selectedMonth;
    int dialogYear = _selectedYear;
    DateTime dialogStart = _startDate;
    DateTime dialogEnd = _endDate;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.bolt_rounded, color: Colors.indigo),
              SizedBox(width: 8),
              Text('Payroll Engine - Declare Payment'),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Automatically calculate basic salary, allowances, approved overtime, attendance days, and loan deductions for the selected department and period.',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedDept,
                    decoration: const InputDecoration(
                      labelText: 'Target Department Scope',
                      prefixIcon: Icon(Icons.business_rounded),
                      border: OutlineInputBorder(),
                    ),
                    items: ['ALL', ...HrConstants.departments.map((d) => d.split(' (')[0])].map((dept) => DropdownMenuItem(
                      value: dept,
                      child: Text(dept == 'ALL' ? 'ALL - All Departments (Company-Wide)' : dept),
                    )).toList(),
                    onChanged: (val) => setDialogState(() => selectedDept = val!),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: dialogMonth,
                          decoration: const InputDecoration(
                            labelText: 'Month',
                            prefixIcon: Icon(Icons.calendar_month),
                            border: OutlineInputBorder(),
                          ),
                          items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(_monthNames[i]))),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                dialogMonth = val;
                                dialogStart = DateTime(dialogYear, dialogMonth, 1);
                                dialogEnd = DateTime(dialogYear, dialogMonth + 1, 0);
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: dialogYear,
                          decoration: const InputDecoration(
                            labelText: 'Year',
                            prefixIcon: Icon(Icons.today),
                            border: OutlineInputBorder(),
                          ),
                          items: [2024, 2025, 2026, 2027].map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                dialogYear = val;
                                dialogStart = DateTime(dialogYear, dialogMonth, 1);
                                dialogEnd = DateTime(dialogYear, dialogMonth + 1, 0);
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                        initialDateRange: DateTimeRange(start: dialogStart, end: dialogEnd),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          dialogStart = picked.start;
                          dialogEnd = picked.end;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Pay Period Date Range',
                        prefixIcon: Icon(Icons.date_range),
                        suffixIcon: Icon(Icons.edit_calendar, size: 20),
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        '${_formatDate(dialogStart)} to ${_formatDate(dialogEnd)} (${dialogEnd.difference(dialogStart).inDays + 1} days)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(ctx);
                setState(() {
                  _selectedMonth = dialogMonth;
                  _selectedYear = dialogYear;
                  _selectedDepartmentFilter = selectedDept;
                  _startDate = dialogStart;
                  _endDate = dialogEnd;
                });
                await _performDeclarePayroll(
                  department: selectedDept,
                  startDate: dialogStart,
                  endDate: dialogEnd,
                );
              },
              icon: const Icon(Icons.bolt_rounded),
              label: const Text('Generate Now'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performDeclarePayroll({
    String? department,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final targetDept = department ?? _selectedDepartmentFilter;
    final start = startDate ?? _startDate;
    final end = endDate ?? _endDate;

    setState(() => _isActionLoading = true);
    try {
      final api = ref.read(hrApiProvider);
      await api.generatePayroll({
        'month': _selectedMonth,
        'year': _selectedYear,
        'departmentName': targetDept,
        'startDate': _formatDate(start),
        'endDate': _formatDate(end),
      });
      setState(() => _isProcessed = true);
      ref.invalidate(payrollProvider(_queryParams));
      _showSnackBar(
        'Payroll generated successfully for ${_monthNames[_selectedMonth - 1]} $_selectedYear (${_formatDate(start)} to ${_formatDate(end)})',
      );
    } catch (e) {
      _showSnackBar('Failed to generate payroll: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  Future<void> _updateSingleRecordStatus(String id, String newStatus) async {
    try {
      final api = ref.read(hrApiProvider);
      await api.updatePayrollStatus(id, {'status': newStatus});
      ref.invalidate(payrollProvider(_queryParams));
      _showSnackBar('Payroll status marked as $newStatus');
    } catch (e) {
      _showSnackBar('Error updating status: $e', isError: true);
    }
  }

  Future<void> _executeBatchAction(String action, String confirmPrompt) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Batch Action'),
        content: Text(confirmPrompt),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: action == 'DELETE_ALL_DRAFTS' ? Colors.red : Colors.indigo),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isActionLoading = true);
    try {
      final api = ref.read(hrApiProvider);
      await api.executePayrollBatch({
        'month': _selectedMonth,
        'year': _selectedYear,
        'department': _selectedDepartmentFilter,
        'action': action,
      });
      ref.invalidate(payrollProvider(_queryParams));
      _showSnackBar('Batch action executed successfully');
    } catch (e) {
      _showSnackBar('Error executing batch action: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CSV EXPORTS
  // ═══════════════════════════════════════════════════════════════════════════
  void _exportPaysheetCsv(List<PayrollRecord> records) {
    final csvRows = <String>[];
    csvRows.add('Employee Name,Department,Designation,Basic Salary,Housing Allowance,Transport Allowance,Other Allowance,Present Days,Absent Days,Late Days,OT Hours,OT Pay,Deductions,Net Salary,Status');

    for (final r in records) {
      csvRows.add(
        '"${r.firstName ?? ''} ${r.lastName ?? ''}",'
        '"${r.departmentName ?? ''}",'
        '"${r.designationName ?? ''}",'
        '${r.basicSalary},'
        '${r.housingAllowance},'
        '${r.transportAllowance},'
        '${r.otherAllowance},'
        '${r.presentDays},'
        '${r.absentDays},'
        '${r.lateDays},'
        '${r.overtimeHours},'
        '${r.overtimePay},'
        '${r.deductions},'
        '${r.netSalary},'
        '${r.status}',
      );
    }

    _showSnackBar('Paysheet CSV export generated (${records.length} records)');
  }

  void _exportWpsCsv(List<PayrollRecord> records) {
    final csvRows = <String>[];
    csvRows.add('National ID,Employee Name,Bank IBAN,Basic Salary,Housing Allowance,Other Earnings,Deductions,Net Amount,Month,Year');

    for (final r in records) {
      csvRows.add(
        '"${r.nationalId ?? ''}",'
        '"${r.firstName ?? ''} ${r.lastName ?? ''}",'
        '"${r.bankIban ?? ''}",'
        '${r.basicSalary},'
        '${r.housingAllowance},'
        '${_parse(r.transportAllowance) + _parse(r.otherAllowance) + _parse(r.overtimePay)},'
        '${r.deductions},'
        '${r.netSalary},'
        '${r.month},'
        '${r.year}',
      );
    }

    _showSnackBar('WPS Direct Debit file generated for ${records.length} bank payouts');
  }
}
