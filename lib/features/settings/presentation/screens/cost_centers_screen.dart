import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erp_frontend/features/accounting/providers/accounting_providers.dart';

class CostCentersScreen extends ConsumerStatefulWidget {
  const CostCentersScreen({super.key});

  @override
  ConsumerState<CostCentersScreen> createState() => _CostCentersScreenState();
}

class _CostCentersScreenState extends ConsumerState<CostCentersScreen> {
  String _selectedSourceType = 'ALL';
  String _searchQuery = '';
  bool _isSyncing = false;

  final List<Map<String, String>> _sourceFilterOptions = [
    {'type': 'ALL', 'label': 'All Cost Centers', 'icon': 'dashboard'},
    {'type': 'EMPLOYEE', 'label': 'Employees', 'icon': 'person'},
    {'type': 'CAR_VEHICLE', 'label': 'Vehicles & Fleet', 'icon': 'directions_car'},
    {'type': 'BRANCH', 'label': 'Branches', 'icon': 'store'},
    {'type': 'SUPPLIER', 'label': 'Suppliers', 'icon': 'local_shipping'},
    {'type': 'CUSTOMER', 'label': 'Customers', 'icon': 'people'},
    {'type': 'PROJECT', 'label': 'Projects', 'icon': 'assignment'},
    {'type': 'GENERAL', 'label': 'General Overhead', 'icon': 'category'},
  ];

  Future<void> _syncOperationalSources() async {
    setState(() => _isSyncing = true);
    try {
      final api = ref.read(accountingApiProvider);
      final res = await api.syncCostCenters();
      ref.invalidate(costCentersProvider);
      if (mounted) {
        final msg = res.data is Map ? (res.data['message'] ?? 'Operational entities synced successfully!') : 'Operational entities synced!';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(msg.toString())),
              ],
            ),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sync operational entities: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Color _getSourceTypeColor(String sourceType) {
    switch (sourceType.toUpperCase()) {
      case 'EMPLOYEE':
        return Colors.blue;
      case 'CAR_VEHICLE':
        return Colors.orange;
      case 'BRANCH':
        return Colors.teal;
      case 'SUPPLIER':
        return Colors.purple;
      case 'CUSTOMER':
        return Colors.indigo;
      case 'PROJECT':
        return Colors.amber.shade900;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _getSourceTypeIcon(String sourceType) {
    switch (sourceType.toUpperCase()) {
      case 'EMPLOYEE':
        return Icons.person_rounded;
      case 'CAR_VEHICLE':
        return Icons.directions_car_rounded;
      case 'BRANCH':
        return Icons.storefront_rounded;
      case 'SUPPLIER':
        return Icons.local_shipping_rounded;
      case 'CUSTOMER':
        return Icons.people_alt_rounded;
      case 'PROJECT':
        return Icons.assignment_rounded;
      default:
        return Icons.business_center_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final costCentersAsync = ref.watch(costCentersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cost Centers & Entity Linking', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Analytical sub-ledgers linked with Employee, Vehicle, Branch, Supplier & Customer refs', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: OutlinedButton.icon(
              onPressed: _isSyncing ? null : _syncOperationalSources,
              icon: _isSyncing
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.sync_rounded, size: 18),
              label: Text(_isSyncing ? 'Syncing...' : 'Sync Operational Entities'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.indigo.shade800,
                side: BorderSide(color: Colors.indigo.shade300),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const CostCenterDialog(),
                );
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New Cost Center'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter & Search Header Card
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search by Code (CC-...), Name, Reference ID, or Category...',
                          prefixIcon: const Icon(Icons.search),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () => setState(() => _searchQuery = ''),
                                )
                              : null,
                        ),
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Source Type Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _sourceFilterOptions.map((opt) {
                      final isSelected = _selectedSourceType == opt['type'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(opt['label']!),
                          selectedColor: Colors.blue.shade100,
                          checkmarkColor: Colors.blue.shade900,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.blue.shade900 : Colors.grey.shade800,
                          ),
                          onSelected: (selected) {
                            setState(() {
                              _selectedSourceType = opt['type']!;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Main Cost Centers List
          Expanded(
            child: costCentersAsync.when(
              data: (costCenters) {
                var filtered = costCenters;

                if (_selectedSourceType != 'ALL') {
                  filtered = filtered.where((c) => c.sourceType.toUpperCase() == _selectedSourceType).toList();
                }

                if (_searchQuery.trim().isNotEmpty) {
                  final q = _searchQuery.toLowerCase().trim();
                  filtered = filtered.where((c) {
                    final matchName = c.name.toLowerCase().contains(q);
                    final matchCode = c.code.toLowerCase().contains(q);
                    final matchRef = (c.sourceId ?? '').toLowerCase().contains(q);
                    final matchCategory = (c.category ?? '').toLowerCase().contains(q);
                    return matchName || matchCode || matchRef || matchCategory;
                  }).toList();
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.account_tree_outlined, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            costCenters.isEmpty ? 'No Cost Centers configured yet.' : 'No matching cost centers found.',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            costCenters.isEmpty
                                ? 'Click "Sync Operational Entities" to automatically create cost centers from all Employees, Vehicles, Branches, Suppliers and Customers, or create custom ones manually.'
                                : 'Try searching with a different keyword or selecting "All Cost Centers".',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                          ),
                          if (costCenters.isEmpty) ...[
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _syncOperationalSources,
                              icon: const Icon(Icons.sync),
                              label: const Text('Auto-Sync Operational Entities Now'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 900;
                    return isWide
                        ? GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 2.7,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) => _buildCostCenterCard(filtered[index]),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: _buildCostCenterCard(filtered[index]),
                            ),
                          );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error loading cost centers: $err', style: const TextStyle(color: Colors.red))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostCenterCard(CostCenter cc) {
    final typeColor = _getSourceTypeColor(cc.sourceType);
    final typeIcon = _getSourceTypeIcon(cc.sourceType);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Row: Code Badge, Source Type Pill, Switch
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  cc.code.isNotEmpty ? cc.code : 'CC-GENERAL',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'monospace'),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: typeColor.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(typeIcon, size: 12, color: typeColor),
                    const SizedBox(width: 4),
                    Text(
                      cc.refTypeLabel,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: typeColor),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Switch(
                value: cc.isActive,
                activeThumbColor: Colors.green,
                onChanged: (val) async {
                  try {
                    final api = ref.read(accountingApiProvider);
                    await api.updateCostCenter({'id': cc.id, 'isActive': val});
                    ref.invalidate(costCentersProvider);
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update status: $e')));
                    }
                  }
                },
              ),
            ],
          ),

          // Middle: Cost Center Name & Ref
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cc.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Icon(Icons.link_rounded, size: 14, color: Colors.blue.shade700),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Linked Ref: ${cc.refWhosLabel}',
                      style: TextStyle(fontSize: 12, color: Colors.blue.shade900, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Bottom Row: Category, Budget, Edit & Delete Actions
          Row(
            children: [
              if (cc.category != null && cc.category!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    cc.category!,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (cc.monthlyBudget > 0) ...[
                Text(
                  'Budget: ৳${cc.monthlyBudget.toStringAsFixed(0)}/mo',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
              ],
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                tooltip: 'Edit Cost Center & Ref',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => CostCenterDialog(existingCostCenter: cc),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                tooltip: 'Delete Cost Center',
                onPressed: () => _confirmDeleteCostCenter(cc),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteCostCenter(CostCenter cc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Cost Center?'),
        content: Text('Are you sure you want to delete "${cc.name}" [${cc.code}]? This operation cannot be undone if the cost center has not been used in transactions.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final api = ref.read(accountingApiProvider);
      await api.deleteCostCenter(cc.id);
      ref.invalidate(costCentersProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cost center deleted successfully'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

// ─── Dialog: Create / Edit Cost Center with Reference ──────────────────────────
class CostCenterDialog extends ConsumerStatefulWidget {
  final CostCenter? existingCostCenter;

  const CostCenterDialog({super.key, this.existingCostCenter});

  @override
  ConsumerState<CostCenterDialog> createState() => _CostCenterDialogState();
}

class _CostCenterDialogState extends ConsumerState<CostCenterDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _sourceIdController;
  late TextEditingController _categoryController;
  late TextEditingController _budgetController;

  String _sourceType = 'EMPLOYEE';
  bool _isLoading = false;
  bool _isLoadingSources = false;

  Map<String, List<Map<String, dynamic>>> _sources = {
    'employees': [],
    'vehicles': [],
    'branches': [],
    'suppliers': [],
    'customers': [],
  };

  @override
  void initState() {
    super.initState();
    final cc = widget.existingCostCenter;
    _sourceType = cc != null ? cc.sourceType : 'EMPLOYEE';
    _codeController = TextEditingController(text: cc?.code ?? '');
    _nameController = TextEditingController(text: cc?.name ?? '');
    _sourceIdController = TextEditingController(text: cc?.sourceId ?? '');
    _categoryController = TextEditingController(text: cc?.category ?? '');
    _budgetController = TextEditingController(text: cc != null && cc.monthlyBudget > 0 ? cc.monthlyBudget.toString() : '');

    _loadOperationalSources();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _sourceIdController.dispose();
    _categoryController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _loadOperationalSources() async {
    setState(() => _isLoadingSources = true);
    try {
      final api = ref.read(accountingApiProvider);
      final res = await api.getCostCenterSources();
      if (res.data is Map && res.data['sources'] != null) {
        final s = res.data['sources'];
        setState(() {
          _sources = {
            'employees': List<Map<String, dynamic>>.from(s['employees'] ?? []),
            'vehicles': List<Map<String, dynamic>>.from(s['vehicles'] ?? []),
            'branches': List<Map<String, dynamic>>.from(s['branches'] ?? []),
            'suppliers': List<Map<String, dynamic>>.from(s['suppliers'] ?? []),
            'customers': List<Map<String, dynamic>>.from(s['customers'] ?? []),
          };
        });
      }
    } catch (_) {
      // Non-critical, fallback to manual reference text entry
    } finally {
      if (mounted) setState(() => _isLoadingSources = false);
    }
  }

  void _onEntitySelected(Map<String, dynamic> item) {
    setState(() {
      switch (_sourceType) {
        case 'EMPLOYEE':
          _sourceIdController.text = item['code'] ?? item['id'] ?? '';
          _nameController.text = 'Employee: ${item['name']}';
          if (_codeController.text.isEmpty || _codeController.text.startsWith('CC-EMP')) {
            _codeController.text = 'CC-EMP-${(item['code'] ?? item['id']).toString().sliceSafe(-4)}';
          }
          if (_categoryController.text.isEmpty && item['department'] != null) {
            _categoryController.text = item['department'].toString();
          }
          break;
        case 'CAR_VEHICLE':
          _sourceIdController.text = item['plate'] ?? item['driverName'] ?? item['id'] ?? '';
          _nameController.text = 'Vehicle: ${item['name']}';
          if (_codeController.text.isEmpty || _codeController.text.startsWith('CC-VEH')) {
            _codeController.text = 'CC-VEH-${(item['plate'] ?? item['id']).toString().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').sliceSafe(-4)}';
          }
          _categoryController.text = 'FLEET_LOGISTICS';
          break;
        case 'BRANCH':
          _sourceIdController.text = item['code'] ?? item['id'] ?? '';
          _nameController.text = 'Branch: ${item['name']}';
          if (_codeController.text.isEmpty || _codeController.text.startsWith('CC-BR')) {
            _codeController.text = 'CC-BR-${(item['code'] ?? item['id']).toString().sliceSafe(-4)}';
          }
          _categoryController.text = 'RETAIL_OUTLET';
          break;
        case 'SUPPLIER':
          _sourceIdController.text = item['code'] ?? item['id'] ?? '';
          _nameController.text = 'Supplier: ${item['name']}';
          if (_codeController.text.isEmpty || _codeController.text.startsWith('CC-SUP')) {
            _codeController.text = 'CC-SUP-${(item['code'] ?? item['id']).toString().sliceSafe(-4)}';
          }
          _categoryController.text = 'PROCUREMENT';
          break;
        case 'CUSTOMER':
          _sourceIdController.text = item['code'] ?? item['id'] ?? '';
          _nameController.text = 'Customer: ${item['name']}';
          if (_codeController.text.isEmpty || _codeController.text.startsWith('CC-CUST')) {
            _codeController.text = 'CC-CUST-${(item['code'] ?? item['id']).toString().sliceSafe(-4)}';
          }
          _categoryController.text = 'SALES_CLIENT';
          break;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final api = ref.read(accountingApiProvider);
      final payload = {
        'code': _codeController.text.trim(),
        'name': _nameController.text.trim(),
        'sourceType': _sourceType,
        'sourceId': _sourceIdController.text.trim().isNotEmpty ? _sourceIdController.text.trim() : null,
        'category': _categoryController.text.trim().isNotEmpty ? _categoryController.text.trim() : null,
        'monthlyBudget': double.tryParse(_budgetController.text) ?? 0.0,
      };

      if (widget.existingCostCenter != null) {
        payload['id'] = widget.existingCostCenter!.id;
        await api.updateCostCenter(payload);
      } else {
        await api.createCostCenter(payload);
      }

      ref.invalidate(costCentersProvider);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingCostCenter != null ? 'Cost Center updated' : 'Cost Center created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> currentSourceList = [];
    if (_sourceType == 'EMPLOYEE') currentSourceList = _sources['employees'] ?? [];
    if (_sourceType == 'CAR_VEHICLE') currentSourceList = _sources['vehicles'] ?? [];
    if (_sourceType == 'BRANCH') currentSourceList = _sources['branches'] ?? [];
    if (_sourceType == 'SUPPLIER') currentSourceList = _sources['suppliers'] ?? [];
    if (_sourceType == 'CUSTOMER') currentSourceList = _sources['customers'] ?? [];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 580),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.existingCostCenter != null ? 'Edit Cost Center & Reference' : 'New Cost Center & Reference Link',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 1. Source Type Picker
                const Text('Reference Type (Ref Whos):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _sourceType,
                  decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                  items: const [
                    DropdownMenuItem(value: 'EMPLOYEE', child: Text('Employee (Staff, Salaries, Travel, Field Reps)')),
                    DropdownMenuItem(value: 'CAR_VEHICLE', child: Text('Vehicle & Fleet (Cars, Trucks, Delivery Drivers, Fuel)')),
                    DropdownMenuItem(value: 'BRANCH', child: Text('Branch (Retail Outlet, Warehouse, Office)')),
                    DropdownMenuItem(value: 'SUPPLIER', child: Text('Supplier (Procurement, Outsourced Vendor)')),
                    DropdownMenuItem(value: 'CUSTOMER', child: Text('Customer (Client Account, Project Account)')),
                    DropdownMenuItem(value: 'PROJECT', child: Text('Project (Specific Contract or Job)')),
                    DropdownMenuItem(value: 'GENERAL', child: Text('General Overhead (Admin, IT, Headquarters)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _sourceType = val;
                        if (_codeController.text.isEmpty || _codeController.text.startsWith('CC-')) {
                          _codeController.text = 'CC-${val.sliceSafe(0, 3)}-${DateTime.now().millisecondsSinceEpoch.toString().sliceSafe(-3)}';
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                if (_isLoadingSources)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: LinearProgressIndicator(minHeight: 2),
                  ),

                // 2. Select from Existing Entities if available
                if (currentSourceList.isNotEmpty) ...[
                  Text('Select Existing $_sourceType (Auto-Populates Ref):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.indigo.shade800)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<Map<String, dynamic>>(
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      hintText: 'Choose from ${_sourceType.toLowerCase()} list...',
                      filled: true,
                      fillColor: Colors.indigo.shade50.withValues(alpha: 0.3),
                    ),
                    items: currentSourceList.map((item) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: item,
                        child: Text(item['name'] ?? item['id'], overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (selected) {
                      if (selected != null) _onEntitySelected(selected);
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // 3. Name & Code Row
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _codeController,
                        decoration: const InputDecoration(
                          labelText: 'Cost Center Code *',
                          hintText: 'e.g. CC-EMP-001',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _sourceIdController,
                        decoration: const InputDecoration(
                          labelText: 'Related Reference (Ref ID/Whos)',
                          hintText: 'e.g. EMP-042 or Plate 1234',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 4. Cost Center Display Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Cost Center Name *',
                    hintText: 'e.g. Employee: Ahmed Al-Harbi or Vehicle: Toyota Hilux',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // 5. Category & Budget Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _categoryController,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          hintText: 'e.g. LOGISTICS, STAFF, PROCUREMENT',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _budgetController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Monthly Budget (৳)',
                          hintText: 'e.g. 5000',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(widget.existingCostCenter != null ? 'Update Cost Center' : 'Save & Link Ref'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension on String {
  String sliceSafe(int start, [int? end]) {
    if (isEmpty) return '';
    if (start < 0) {
      final s = length + start;
      return s < 0 ? this : substring(s);
    }
    final actualEnd = (end == null || end > length) ? length : end;
    if (start >= length) return '';
    return substring(start, actualEnd);
  }
}
