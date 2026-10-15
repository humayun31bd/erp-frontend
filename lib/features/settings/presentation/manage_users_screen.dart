import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

class ManageUsersContent extends ConsumerStatefulWidget {
  const ManageUsersContent({super.key});

  @override
  ConsumerState<ManageUsersContent> createState() => _ManageUsersContentState();
}

class _ManageUsersContentState extends ConsumerState<ManageUsersContent> {
  String _searchQuery = '';
  String _roleFilter = 'All'; // All, SUPERADMIN, ADMIN, TENANT_USER

  // Local list to hold newly created/edited mock users until backend is integrated
  final List<Map<String, dynamic>> _localUsers = [];
  // Keep track of deleted users to remove them from fetched data locally
  final Set<String> _deletedUserIds = {};

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersProvider);
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
                  'Manage Users',
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
                          hintText: 'Search email...',
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
                      value: _roleFilter,
                      items: ['All', 'SUPERADMIN', 'TENANT_ADMIN', 'TENANT_USER']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e == 'TENANT_ADMIN' ? 'ADMIN' : e)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _roleFilter = val;
                          });
                        }
                      },
                    ),

                    ElevatedButton.icon(
                      onPressed: () => _showUserDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add User'),
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
                final fetchedUsers = usersAsync.valueOrNull ?? [];
                
                // Merge fetched users with local edits, and exclude deleted ones
                final Map<String, Map<String, dynamic>> allUsersMap = {};
                for (var user in fetchedUsers) {
                  final id = user['id'] as String;
                  if (!_deletedUserIds.contains(id)) {
                    allUsersMap[id] = Map<String, dynamic>.from(user);
                  }
                }
                for (var user in _localUsers) {
                  final id = user['id'] as String;
                  if (!_deletedUserIds.contains(id)) {
                    allUsersMap[id] = user; // Will override fetched user if edited locally
                  }
                }
                
                final allUsers = allUsersMap.values.toList();

                if (countersLoadingOrErrorState(usersAsync)) {
                  if (usersAsync.isLoading && allUsers.isEmpty) return const Center(child: CircularProgressIndicator());
                  if (usersAsync.hasError && allUsers.isEmpty) return Center(child: Text('Error: ${usersAsync.error}'));
                }

                // Filter users
                final filtered = allUsers.where((u) {
                  final email = (u['email'] as String? ?? '').toLowerCase();
                  final role = (u['role'] as String? ?? 'TENANT_USER').toUpperCase();
                  
                  final matchesSearch = email.contains(_searchQuery);
                  final matchesFilter = _roleFilter == 'All' || 
                      role == _roleFilter ||
                      (_roleFilter == 'TENANT_ADMIN' && (role == 'ADMIN' || role == 'TENANT_ADMIN'));
                  return matchesSearch && matchesFilter;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No users found.'));
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
                    final user = filtered[index];
                    final String id = user['id'] ?? '';
                    final String email = user['email'] ?? 'No Email';
                    final String role = user['role'] ?? 'TENANT_USER';
                    final bool isLocal = _localUsers.any((u) => u['id'] == id);

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor: theme.colorScheme.primaryContainer,
                                  child: Text(
                                    email.isNotEmpty ? email[0].toUpperCase() : '?',
                                    style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        email,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.secondaryContainer,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          role,
                                          style: TextStyle(
                                            color: theme.colorScheme.onSecondaryContainer,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (isLocal) ...[
                               const SizedBox(height: 8),
                               const Text('(Pending Sync)', style: TextStyle(color: Colors.orange, fontSize: 12, fontStyle: FontStyle.italic)),
                            ],
                            const Spacer(),
                            const Divider(height: 1),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () => _showUserDialog(context, existingUser: user),
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('Edit'),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _deletedUserIds.add(id);
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('User deleted')),
                                    );
                                  },
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                  label: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
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

  bool countersLoadingOrErrorState(AsyncValue async) {
    return async.isLoading || async.hasError;
  }

  void _showUserDialog(BuildContext context, {Map<String, dynamic>? existingUser}) {
    final bool isEdit = existingUser != null;
    final emailController = TextEditingController(text: isEdit ? existingUser['email'] : '');
    final passwordController = TextEditingController();
    String rawRole = isEdit ? (existingUser['role'] ?? 'TENANT_USER') : 'TENANT_USER';
    String selectedRole = ['SUPERADMIN', 'TENANT_ADMIN', 'TENANT_USER'].contains(rawRole) 
        ? rawRole 
        : (rawRole == 'ADMIN' ? 'TENANT_ADMIN' : 'TENANT_USER');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit User' : 'Add New User'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: isEdit ? 'New Password (leave blank to keep current)' : 'Password',
                        border: const OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(),
                      ),
                      items: ['SUPERADMIN', 'TENANT_ADMIN', 'TENANT_USER']
                          .map((r) => DropdownMenuItem(value: r, child: Text(r == 'TENANT_ADMIN' ? 'ADMIN' : r)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedRole = val);
                      },
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
                  onPressed: () {
                    final email = emailController.text.trim();
                    if (email.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email cannot be empty')));
                      return;
                    }

                    final id = isEdit ? existingUser['id'] : DateTime.now().millisecondsSinceEpoch.toString();
                    
                    final newUser = {
                      'id': id,
                      'email': email,
                      'role': selectedRole,
                    };
                    
                    setState(() {
                      // Remove old mock version if editing
                      _localUsers.removeWhere((u) => u['id'] == id);
                      _localUsers.add(newUser);
                      _deletedUserIds.remove(id); // Undo deletion if they re-added somehow
                    });
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isEdit ? 'User updated (Mock)' : 'User added (Mock)')),
                    );
                    Navigator.pop(context);
                  },
                  child: Text(isEdit ? 'Save Changes' : 'Add User'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
