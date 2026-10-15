import 'package:flutter/material.dart';
import '../../../core/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import 'package:dio/dio.dart';

class ManageBranchesContent extends ConsumerStatefulWidget {
  const ManageBranchesContent({super.key});

  @override
  ConsumerState<ManageBranchesContent> createState() => _ManageBranchesContentState();
}

class _ManageBranchesContentState extends ConsumerState<ManageBranchesContent> {
  // Mock branches removed, data now loaded from backend

  String _searchQuery = '';
  int _currentPage = 0;
  final int _pageSize = 10;

  void _addOrEditBranch([Map<String, dynamic>? branch]) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = branch != null;
    
    final nameController = TextEditingController(text: isEditing ? (branch["name"] as String?) ?? "" : "");
    final locController = TextEditingController(text: isEditing ? (branch["address"] as String?) ?? "" : "");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? l10n.edit : l10n.addBranch),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: l10n.branchName),
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
                    await api.updateBranch(branch["id"] as String, {
                      "name": nameController.text,
                      "address": locController.text,
                    });
                  } else {
                    await api.createBranch({
                      "name": nameController.text,
                      "address": locController.text,
                    });
                  }
                  ref.invalidate(branchesProvider);
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isEditing ? 'Updated branch successfully' : 'Added branch successfully')),
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

  void _deleteBranch(Map<String, dynamic> branch) async {
    final l10n = AppLocalizations.of(context)!;
    
    // Show confirmation dialog before deleting
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${branch["name"]}"?'),
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
      await api.deleteBranch(branch["id"] as String);
      ref.invalidate(branchesProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deleted branch successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (e is DioException && e.response?.data != null && e.response?.data is Map) {
          errorMessage = e.response!.data['error'] ?? errorMessage;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting branch: $errorMessage')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final branchesAsync = ref.watch(branchesProvider);
    final branchesData = branchesAsync.valueOrNull ?? [];
    
    // Convert dynamic list to list of maps
    final _branches = branchesData.map((e) => e as Map<String, dynamic>).toList();

    // Filter
    final filteredBranches = _branches.where((branch) {
      final q = _searchQuery.toLowerCase();
      final branchName = (branch["name"] as String?) ?? '';
      final branchLocation = (branch["address"] as String?) ?? '';
      final branchId = (branch["id"] as String?) ?? '';
      
      return branchName.toLowerCase().contains(q) ||
             branchLocation.toLowerCase().contains(q) ||
             branchId.toLowerCase().contains(q);
    }).toList();

    // Paginate
    final totalPages = (filteredBranches.length / _pageSize).ceil();
    if (_currentPage >= totalPages && totalPages > 0) {
      _currentPage = totalPages - 1;
    }
    final startIndex = _currentPage * _pageSize;
    final endIndex = (startIndex + _pageSize > filteredBranches.length) ? filteredBranches.length : startIndex + _pageSize;
    final paginatedBranches = filteredBranches.sublist(startIndex, endIndex);

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
                Text(
                  l10n.manageBranches,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                          hintText: 'Search branches...',
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
                      label: Text(l10n.addBranch),
                      onPressed: () => _addOrEditBranch(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: branchesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error loading branches: $e')),
              data: (_) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                child: DataTable(
                  columns: [
                    const DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text(l10n.branchName, style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text(l10n.branchLocation, style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text(l10n.actions, style: const TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: paginatedBranches.map((branch) {
                    return DataRow(
                      cells: [
                        DataCell(Text(branch["id"]?.toString() ?? '')),
                        DataCell(Text(branch["name"]?.toString() ?? '')),
                        DataCell(Text(branch["address"]?.toString() ?? '')),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _addOrEditBranch(branch),
                                tooltip: l10n.edit,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                onPressed: () => _deleteBranch(branch),
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
                Text('Showing ${filteredBranches.isEmpty ? 0 : startIndex + 1} to $endIndex of ${filteredBranches.length}'),
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
