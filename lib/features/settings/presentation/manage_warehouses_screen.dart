import 'package:flutter/material.dart';
import '../../../core/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import 'package:dio/dio.dart';

class ManageWarehousesContent extends ConsumerStatefulWidget {
  const ManageWarehousesContent({super.key});

  @override
  ConsumerState<ManageWarehousesContent> createState() => _ManageWarehousesContentState();
}

class _ManageWarehousesContentState extends ConsumerState<ManageWarehousesContent> {
  // Mock data removed, fetching from branches API with isWarehouse = true

  String _searchQuery = '';
  int _currentPage = 0;
  final int _pageSize = 10;

  void _addOrEditWarehouse(Map<String, dynamic>? warehouse, List<Map<String, dynamic>> allBranches) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = warehouse != null;
    
    // Parent branches
    final parentBranches = allBranches;
    if (parentBranches.isEmpty) {
      parentBranches.add({"id": "", "name": "No branch available"});
    }
    
    String selectedBranchId = isEditing ? (warehouse["branchId"] as String?) ?? parentBranches.first["id"] as String : parentBranches.first["id"] as String;
    
    final nameController = TextEditingController(text: isEditing ? (warehouse["name"] as String?) ?? "" : "");
    final locController = TextEditingController(text: isEditing ? (warehouse["location"] as String?) ?? "" : "");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Warehouse' : 'Add Warehouse'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: parentBranches.any((b) => (b["id"] as String) == selectedBranchId) ? selectedBranchId : parentBranches.first["id"] as String,
                decoration: const InputDecoration(labelText: 'Branch'),
                items: parentBranches.map((b) => DropdownMenuItem(value: b["id"] as String, child: Text(b["name"] as String))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    selectedBranchId = val;
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Warehouse Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locController,
                decoration: InputDecoration(labelText: l10n.branchLocation),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final api = ref.read(settingsApiProvider);
                  if (isEditing) {
                    await api.updateWarehouse(warehouse["id"] as String, {
                      "name": nameController.text,
                      "location": locController.text,
                      "branchId": selectedBranchId,
                      "isActive": true,
                    });
                  } else {
                    await api.createWarehouse({
                      "name": nameController.text,
                      "location": locController.text,
                      "branchId": selectedBranchId,
                      "isActive": true,
                    });
                  }
                  ref.invalidate(warehousesProvider);
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isEditing ? 'Updated warehouse successfully' : 'Added warehouse successfully')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                }
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }

  void _deleteWarehouse(Map<String, dynamic> warehouse) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete warehouse "${warehouse["name"]}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Delete', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final api = ref.read(settingsApiProvider);
      await api.deleteWarehouse(warehouse["id"] as String);
      ref.invalidate(warehousesProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deleted warehouse successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (e is DioException && e.response?.data != null && e.response?.data is Map) {
          errorMessage = e.response!.data['error'] ?? errorMessage;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting warehouse: $errorMessage')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final branchesAsync = ref.watch(branchesProvider);
    final branchesData = branchesAsync.valueOrNull ?? [];
    
    // Convert to map
    final _allBranches = branchesData.map((e) => e as Map<String, dynamic>).toList();
    
    final warehousesAsync = ref.watch(warehousesProvider);
    final warehousesData = warehousesAsync.valueOrNull ?? [];
    final _warehouses = warehousesData.map((e) => e as Map<String, dynamic>).toList();

    // Filter by search
    final filteredWarehouses = _warehouses.where((warehouse) {
      final q = _searchQuery.toLowerCase();
      final wName = (warehouse["name"] as String?) ?? '';
      final wLoc = (warehouse["location"] as String?) ?? '';
      
      return wName.toLowerCase().contains(q) || wLoc.toLowerCase().contains(q);
    }).toList();

    // Paginate
    final totalPages = (filteredWarehouses.length / _pageSize).ceil();
    if (_currentPage >= totalPages && totalPages > 0) {
      _currentPage = totalPages - 1;
    }
    final startIndex = _currentPage * _pageSize;
    final endIndex = (startIndex + _pageSize > filteredWarehouses.length) ? filteredWarehouses.length : startIndex + _pageSize;
    final paginatedWarehouses = filteredWarehouses.sublist(startIndex, endIndex);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'Manage Warehouses',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 250,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search warehouses...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                            _currentPage = 0;
                          });
                        },
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add Warehouse'),
                      onPressed: () => _addOrEditWarehouse(null, _allBranches),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: warehousesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
              data: (_) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                child: DataTable(
                  columns: [
                    const DataColumn(label: Text('Warehouse', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text('Branch', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text(l10n.branchLocation, style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text(l10n.actions, style: const TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: paginatedWarehouses.map((warehouse) {
                    final parentId = warehouse["branchId"] as String?;
                    final parentBranch = _allBranches.firstWhere((b) => b["id"] == parentId, orElse: () => {"name": "None"});
                    
                    return DataRow(
                      cells: [
                        DataCell(Text(warehouse["name"]?.toString() ?? '')),
                        DataCell(Text(parentBranch["name"]?.toString() ?? '')),
                        DataCell(Text(warehouse["location"]?.toString() ?? '')),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _addOrEditWarehouse(warehouse, _allBranches),
                                tooltip: l10n.edit,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                onPressed: () => _deleteWarehouse(warehouse),
                                tooltip: l10n.delete,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Showing ${filteredWarehouses.isEmpty ? 0 : startIndex + 1} to $endIndex of ${filteredWarehouses.length}'),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _currentPage > 0 ? () {
                        setState(() {
                          _currentPage--;
                        });
                      } : null,
                    ),
                    Text('Page ${_currentPage + 1} of ${totalPages == 0 ? 1 : totalPages}'),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _currentPage < totalPages - 1 ? () {
                        setState(() {
                          _currentPage++;
                        });
                      } : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
