import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../pos/providers/counter_provider.dart';
import '../../pos/domain/counter_model.dart';
import '../providers/settings_provider.dart';
import 'package:dio/dio.dart';

class ManageCountersContent extends ConsumerStatefulWidget {
  const ManageCountersContent({super.key});

  @override
  ConsumerState<ManageCountersContent> createState() => _ManageCountersContentState();
}

class _ManageCountersContentState extends ConsumerState<ManageCountersContent> {
  String _searchQuery = '';
  String _statusFilter = 'All'; // All, Active, Inactive
  
  // Removed dummy users, we will fetch from DB
  
  // Mock assigned users mapping (counterId -> user)
  final Map<String, String> _assignedUsers = {};

  @override
  Widget build(BuildContext context) {
    final countersAsync = ref.watch(countersProvider);
    final branchesAsync = ref.watch(branchesProvider);
    final usersAsync = ref.watch(usersProvider);
    
    final fetchedUsers = usersAsync.valueOrNull ?? [];
    final userList = fetchedUsers.map((u) => u['email'] as String).toList();
    if (userList.isEmpty) userList.add('Unassigned');

    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header & Toolbar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'Manage Counters',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Search
                    SizedBox(
                      width: 250,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search counters...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val.toLowerCase();
                          });
                        },
                      ),
                    ),

                    // Filter
                    DropdownButton<String>(
                      value: _statusFilter,
                      items: ['All', 'Active', 'Inactive']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _statusFilter = val;
                          });
                        }
                      },
                    ),

                    ElevatedButton.icon(
                      onPressed: () {
                        if (branchesAsync.hasError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to load branches: ${branchesAsync.error}')),
                          );
                          // Fallback for demo purposes if backend fails
                          _showAddCounterDialog(context, [{"id": "", "name": 'Main Branch (Fallback)'}]);
                          return;
                        }
                        if (branchesAsync.isLoading) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Loading branches...')),
                          );
                          return;
                        }
                        
                        final branchesList = branchesAsync.maybeWhen(
                          data: (branches) {
                            return branches.map((b) => b as Map<String, dynamic>).toList();
                          },
                          orElse: () => <Map<String, dynamic>>[],
                        );
                        _showAddCounterDialog(context, branchesList);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Counter'),
                    )
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Grid View
          Expanded(
            child: Builder(
              builder: (context) {
                final fetchedCounters = countersAsync.valueOrNull ?? [];
                final allCounters = fetchedCounters;

                if (countersAsync.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (countersAsync.hasError) {
                  return Center(child: Text('Error: ${countersAsync.error}'));
                }

                // Filter counters
                final filtered = allCounters.where((c) {
                  final matchesSearch = c.name.toLowerCase().contains(_searchQuery) ||
                                        c.branchName.toLowerCase().contains(_searchQuery);
                  final matchesFilter = _statusFilter == 'All' ||
                                        (_statusFilter == 'Active' && c.isActive) ||
                                        (_statusFilter == 'Inactive' && !c.isActive);
                  return matchesSearch && matchesFilter;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No counters found.'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 350,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 260,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final counter = filtered[index];
                    final assignedUser = _assignedUsers[counter.id] ?? 'Unassigned';

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    counter.name,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: counter.isActive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    counter.isActive ? 'Active' : 'Inactive',
                                    style: TextStyle(
                                      color: counter.isActive ? Colors.green : Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.store_outlined, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    counter.branchName,
                                    style: const TextStyle(color: Colors.grey),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            const Text('Assigned To:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: userList.contains(assignedUser) ? assignedUser : userList.first,
                              isExpanded: true,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              items: userList.map((u) {
                                return DropdownMenuItem(value: u, child: Text(u));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _assignedUsers[counter.id] = val;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Assigned $val to ${counter.name}')),
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () async {
                                  // Show confirmation dialog before deleting
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirm Delete'),
                                      content: Text('Are you sure you want to delete "${counter.name}"?'),
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
                                    final api = ref.read(counterApiProvider);
                                    await api.deleteCounter(counter.id);
                                    ref.invalidate(countersProvider);
                                    
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Counter deleted successfully')),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      String errorMessage = e.toString();
                                      if (e is DioException && e.response?.data != null && e.response?.data is Map) {
                                        errorMessage = e.response!.data['error'] ?? errorMessage;
                                      }
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error deleting counter: $errorMessage')),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                label: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCounterDialog(BuildContext context, List<Map<String, dynamic>> branches) {
    final nameController = TextEditingController();
    bool isActive = true;
    
    // Ensure we don't crash if branches list is somehow empty
    if (branches.isEmpty) {
      branches.add({"id": "", "name": "No branches available"});
    }
    String selectedBranchId = branches.first["id"] as String;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add New Counter'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Counter Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: branches.any((b) => (b["id"] as String) == selectedBranchId) ? selectedBranchId : branches.first["id"] as String,
                      decoration: const InputDecoration(
                        labelText: 'Select Branch',
                        border: OutlineInputBorder(),
                      ),
                      items: branches.map((b) => DropdownMenuItem(value: b["id"] as String, child: Text(b["name"] as String))).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedBranchId = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Is Active'),
                      value: isActive,
                      onChanged: (val) => setDialogState(() => isActive = val),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedBranchId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a valid branch')),
                      );
                      return;
                    }
                    try {
                      final api = ref.read(counterApiProvider);
                      await api.createCounter({
                        "name": nameController.text,
                        "branchId": selectedBranchId,
                        "isActive": isActive,
                      });
                      
                      ref.invalidate(countersProvider);
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Counter "${nameController.text}" added successfully')),
                        );
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error adding counter: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Add Counter'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
