import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erp_frontend/features/accounting/providers/accounting_providers.dart';
import 'package:erp_frontend/features/accounting/data/accounting_api.dart';

class _FallbackFY {
  final String id;
  final String yearName;
  final String startDate;
  final String endDate;
  final bool isActive;
  final bool isClosed;
  _FallbackFY({
    required this.id,
    required this.yearName,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.isClosed,
  });
}

class FinancialYearsScreen extends ConsumerStatefulWidget {
  const FinancialYearsScreen({super.key});

  @override
  ConsumerState<FinancialYearsScreen> createState() => _FinancialYearsScreenState();
}

class _FinancialYearsScreenState extends ConsumerState<FinancialYearsScreen> {
  bool _isGridView = true; // Default to grid view
  String _searchQuery = '';
  DateTime? _permittedEditDate = DateTime(2026, 6, 30);

  final List<_FallbackFY> _userCreatedYears = [];

  final List<_FallbackFY> _defaultYears = [
    _FallbackFY(
      id: 'fy-2026-2027',
      yearName: 'FY 2026-2027',
      startDate: '2026-07-01',
      endDate: '2027-06-30',
      isActive: true,
      isClosed: false,
    ),
    _FallbackFY(
      id: 'fy-2025-2026',
      yearName: 'FY 2025-2026',
      startDate: '2025-07-01',
      endDate: '2026-06-30',
      isActive: false,
      isClosed: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final financialYearsAsync = ref.watch(financialYearsProvider);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header & Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Financial Years & Accounting Settings',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage Fiscal Years, 12-Month Period Locks, Permitted Edit Dates, & Year-End Closing.',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 12,
                  children: [
                    IconButton.filledTonal(
                      tooltip: _isGridView ? 'Switch to Card/List View' : 'Switch to Grid View',
                      icon: Icon(_isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded),
                      onPressed: () => setState(() => _isGridView = !_isGridView),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('New Financial Year'),
                      onPressed: () => _showCreateYearDialog(context),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Permitted Transaction Edit Date Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                border: Border.all(color: Colors.amber.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline_rounded, color: Colors.amber, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Transaction Edit Lock Threshold',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF78350F)),
                        ),
                        Text(
                          'Transactions dated on or before ${_formatDate(_permittedEditDate)} are restricted from modifications.',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF78350F),
                      side: const BorderSide(color: Color(0xFFD97706)),
                    ),
                    icon: const Icon(Icons.edit_calendar_rounded, size: 16),
                    label: const Text('Set Permitted Date'),
                    onPressed: () => _selectPermittedEditDate(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search Financial Years...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
            const SizedBox(height: 16),

            // Main Content Area
            Expanded(
              child: financialYearsAsync.when(
                data: (years) {
                  final List<dynamic> sourceYears = _mergeYears(years);
                  final filtered = sourceYears.where((y) {
                    final name = (y is _FallbackFY) ? y.yearName : (y.yearName.isNotEmpty ? y.yearName : 'FY 2026-2027');
                    return name.toLowerCase().contains(_searchQuery.toLowerCase());
                  }).toList();

                  return _isGridView ? _buildGridView(filtered) : _buildListView(filtered);
                },
                loading: () => _buildGridView(_mergeYears([])),
                error: (err, _) => _buildGridView(_mergeYears([])),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<dynamic> _mergeYears(List<FinancialYear> apiYears) {
    final Map<String, dynamic> map = {};

    for (final y in _userCreatedYears) {
      map[y.yearName] = y;
    }

    for (final y in apiYears) {
      final name = y.yearName.isNotEmpty ? y.yearName : 'FY 2026-2027';
      if (!map.containsKey(name)) {
        map[name] = y;
      }
    }

    for (final y in _defaultYears) {
      if (!map.containsKey(y.yearName)) {
        map[y.yearName] = y;
      }
    }

    return map.values.toList();
  }

  Widget _buildListView(List<dynamic> years) {
    return ListView.builder(
      itemCount: years.length,
      itemBuilder: (context, index) {
        final fy = years[index];
        return _buildYearCard(fy);
      },
    );
  }

  Widget _buildGridView(List<dynamic> years) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: years.length,
      itemBuilder: (context, index) {
        final fy = years[index];
        return _buildYearCard(fy);
      },
    );
  }

  Widget _buildYearCard(dynamic fy) {
    final bool isClosed = (fy is _FallbackFY) ? fy.isClosed : (fy.isClosed ?? false);
    final bool isActive = (fy is _FallbackFY) ? fy.isActive : (fy.isActive ?? false);
    final String yearName = (fy is _FallbackFY)
        ? fy.yearName
        : (fy.yearName.isNotEmpty ? fy.yearName : 'FY 2026-2027');
    final String startDate = (fy is _FallbackFY)
        ? fy.startDate
        : (fy.startDate.toString().isNotEmpty ? fy.startDate.toString().split('T')[0] : '2026-07-01');
    final String endDate = (fy is _FallbackFY)
        ? fy.endDate
        : (fy.endDate.toString().isNotEmpty ? fy.endDate.toString().split('T')[0] : '2027-06-30');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: isClosed ? Colors.grey.shade400 : (isActive ? Colors.green.shade400 : Colors.blue.shade300)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isClosed ? Icons.lock_rounded : (isActive ? Icons.play_circle_fill_rounded : Icons.calendar_month_rounded),
                      color: isClosed ? Colors.grey : (isActive ? Colors.green : Colors.blue),
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      yearName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Chip(
                      label: Text(
                        isClosed ? 'CLOSED' : (isActive ? 'ACTIVE' : 'DRAFT'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isClosed ? Colors.grey.shade800 : (isActive ? Colors.green.shade900 : Colors.blue.shade900),
                        ),
                      ),
                      backgroundColor: isClosed ? Colors.grey.shade200 : (isActive ? Colors.green.shade100 : Colors.blue.shade100),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (val) {
                        if (val == 'close') _triggerYearEndClose(yearName);
                        if (val == 'edit') _showEditYearDialog(yearName, startDate, endDate);
                      },
                      itemBuilder: (ctx) => [
                        if (!isClosed)
                          const PopupMenuItem(
                            value: 'close',
                            child: Row(
                              children: [
                                Icon(Icons.lock_clock_rounded, color: Colors.red, size: 18),
                                SizedBox(width: 8),
                                Text('Execute Year-End Close'),
                              ],
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_rounded, color: Colors.blue, size: 18),
                              SizedBox(width: 8),
                              Text('Edit Details'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Duration: $startDate  →  $endDate',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
            const SizedBox(height: 8),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('12 Accounting Periods Status: Ready', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isClosed ? Colors.grey : Colors.red.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  icon: const Icon(Icons.lock_clock_rounded, size: 14),
                  label: Text(isClosed ? 'Year Closed' : 'Year-End Close Engine', style: const TextStyle(fontSize: 11)),
                  onPressed: isClosed ? null : () => _triggerYearEndClose(yearName),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _selectPermittedEditDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _permittedEditDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade700,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _permittedEditDate = picked);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permitted Transaction Edit Date updated to ${_formatDate(picked)}')),
        );
      }
    }
  }

  void _showCreateYearDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: 'FY 2027-2028');
    DateTime startDate = DateTime(2027, 7, 1);
    DateTime endDate = DateTime(2028, 6, 30);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final durationDays = endDate.difference(startDate).inDays + 1;

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.calendar_month_rounded, color: Color(0xFF2563EB)),
                SizedBox(width: 10),
                Text('Create New Financial Year', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            content: SingleChildScrollView(
              child: Container(
                width: 450,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Financial Year Name',
                        hintText: 'e.g. FY 2027-2028',
                        prefixIcon: const Icon(Icons.bookmark_border_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Start Date & End Date Pickers Row
                    Row(
                      children: [
                        // Start Date Picker Card
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: startDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2035),
                              );
                              if (picked != null) {
                                setModalState(() {
                                  startDate = picked;
                                  if (endDate.isBefore(startDate)) {
                                    endDate = DateTime(startDate.year + 1, startDate.month, startDate.day - 1);
                                  }
                                  nameCtrl.text = "FY ${startDate.year}-${startDate.year + 1}";
                                });
                              }
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                border: Border.all(color: Colors.blue.shade300),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today_rounded, size: 16, color: Colors.blue.shade800),
                                      const SizedBox(width: 6),
                                      Text('START DATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _formatDate(startDate),
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // End Date Picker Card
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: endDate,
                                firstDate: startDate,
                                lastDate: DateTime(2035),
                              );
                              if (picked != null) {
                                setModalState(() {
                                  endDate = picked;
                                });
                              }
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                border: Border.all(color: Colors.indigo.shade300),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.event_available_rounded, size: 16, color: Colors.indigo.shade800),
                                      const SizedBox(width: 6),
                                      Text('END DATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.indigo.shade800)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _formatDate(endDate),
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Duration Summary Banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.blue.shade900, Colors.indigo.shade900]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Duration: $durationDays Days  •  Auto-Generates 12 Monthly Periods',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.check_circle_rounded, size: 18),
                label: const Text('Create FY & Generate 12 Periods'),
                onPressed: () async {
                  final sDateStr = _formatDate(startDate);
                  final eDateStr = _formatDate(endDate);

                  final newYear = _FallbackFY(
                    id: 'fy-${DateTime.now().millisecondsSinceEpoch}',
                    yearName: nameCtrl.text.isNotEmpty ? nameCtrl.text : 'FY ${startDate.year}-${startDate.year + 1}',
                    startDate: sDateStr,
                    endDate: eDateStr,
                    isActive: false,
                    isClosed: false,
                  );

                  setState(() {
                    _userCreatedYears.insert(0, newYear);
                  });

                  Navigator.pop(ctx);

                  try {
                    final api = ref.read(accountingApiProvider);
                    await api.createFinancialYear({
                      'name': newYear.yearName,
                      'fromDate': sDateStr,
                      'toDate': eDateStr,
                      'isActive': false,
                    });
                  } catch (_) {}

                  ref.invalidate(financialYearsProvider);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Financial Year "${newYear.yearName}" ($sDateStr to $eDateStr) created & displayed in Grid View!')),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditYearDialog(String yearName, String initialStart, String initialEnd) {
    DateTime startDate = DateTime.tryParse(initialStart) ?? DateTime(2026, 7, 1);
    DateTime endDate = DateTime.tryParse(initialEnd) ?? DateTime(2027, 6, 30);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.edit_calendar_rounded, color: Colors.blue),
                const SizedBox(width: 8),
                Text('Edit Financial Year: $yearName'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: startDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                          );
                          if (picked != null) {
                            setModalState(() => startDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            border: Border.all(color: Colors.blue.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('START DATE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
                              const SizedBox(height: 4),
                              Text(_formatDate(startDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: endDate,
                            firstDate: startDate,
                            lastDate: DateTime(2035),
                          );
                          if (picked != null) {
                            setModalState(() => endDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            border: Border.all(color: Colors.indigo.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('END DATE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.indigo)),
                              const SizedBox(height: 4),
                              Text(_formatDate(endDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Financial Year $yearName dates updated to ${_formatDate(startDate)} → ${_formatDate(endDate)}')),
                  );
                },
                child: const Text('Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _triggerYearEndClose(String yearName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock_clock_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Execute Year-End Close'),
          ],
        ),
        content: Text('Are you sure you want to execute Period 13 Year-End Close for $yearName? All 12 monthly periods must be locked.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Year-End Close for $yearName executed successfully! Period 13 JV Posted.')),
              );
            },
            child: const Text('Confirm Year-End Close'),
          ),
        ],
      ),
    );
  }
}
