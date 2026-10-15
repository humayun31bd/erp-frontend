import 'package:flutter/material.dart';
import '../../../core/l10n/app_localizations.dart';

class ManageTaxesContent extends StatefulWidget {
  const ManageTaxesContent({super.key});

  @override
  State<ManageTaxesContent> createState() => _ManageTaxesContentState();
}

class _ManageTaxesContentState extends State<ManageTaxesContent> {
  // Mock data: tax groups
  final List<Map<String, String>> _taxes = [
    {"id": "t1", "name": "Standard Rate", "rate": "15%", "type": "VAT"},
    {"id": "t2", "name": "Zero Rate", "rate": "0%", "type": "VAT"},
    {"id": "t3", "name": "Exempt", "rate": "0%", "type": "Exempt"},
  ];

  String _searchQuery = '';
  int _currentPage = 0;
  final int _pageSize = 10;

  void _addOrEditTax([Map<String, String>? tax]) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = tax != null;
    
    final nameController = TextEditingController(text: isEditing ? tax["name"] : "");
    final rateController = TextEditingController(text: isEditing ? tax["rate"] : "");
    final typeController = TextEditingController(text: isEditing ? tax["type"] : "");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Tax' : 'Add Tax'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tax Name (e.g. Standard Rate)'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: rateController,
                decoration: const InputDecoration(labelText: 'Rate (e.g. 15%)'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: typeController,
                decoration: const InputDecoration(labelText: 'Tax Type (e.g. VAT)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (isEditing) {
                    tax["name"] = nameController.text;
                    tax["rate"] = rateController.text;
                    tax["type"] = typeController.text;
                  } else {
                    _taxes.add({
                      "id": DateTime.now().millisecondsSinceEpoch.toString(),
                      "name": nameController.text,
                      "rate": rateController.text,
                      "type": typeController.text,
                    });
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isEditing ? 'Updated tax' : 'Added tax')),
                );
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }

  void _deleteTax(Map<String, String> tax) {
    setState(() {
      _taxes.removeWhere((t) => t["id"] == tax["id"]);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Deleted tax')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Filter
    final filteredTaxes = _taxes.where((tax) {
      final q = _searchQuery.toLowerCase();
      return (tax["name"]?.toLowerCase().contains(q) ?? false) ||
             (tax["rate"]?.toLowerCase().contains(q) ?? false) ||
             (tax["type"]?.toLowerCase().contains(q) ?? false);
    }).toList();

    // Paginate
    final totalPages = (filteredTaxes.length / _pageSize).ceil();
    if (_currentPage >= totalPages && totalPages > 0) {
      _currentPage = totalPages - 1;
    }
    final startIndex = _currentPage * _pageSize;
    final endIndex = (startIndex + _pageSize > filteredTaxes.length) ? filteredTaxes.length : startIndex + _pageSize;
    final paginatedTaxes = filteredTaxes.sublist(startIndex, endIndex);

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
                  'Manage Taxes',
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
                          hintText: 'Search taxes...',
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
                      label: const Text('Add Tax'),
                      onPressed: () => _addOrEditTax(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columns: [
                    const DataColumn(label: Text('Tax Name', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text('Rate', style: TextStyle(fontWeight: FontWeight.bold))),
                    const DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text(l10n.actions, style: const TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: paginatedTaxes.map((tax) {
                    return DataRow(
                      cells: [
                        DataCell(Text(tax["name"]!)),
                        DataCell(Text(tax["rate"]!)),
                        DataCell(Text(tax["type"]!)),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _addOrEditTax(tax),
                                tooltip: l10n.edit,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                onPressed: () => _deleteTax(tax),
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
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Showing ${filteredTaxes.isEmpty ? 0 : startIndex + 1} to $endIndex of ${filteredTaxes.length}'),
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
