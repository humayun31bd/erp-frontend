import 'package:flutter/material.dart';
import '../../../../core/l10n/app_localizations.dart';

class MarketingPlansScreen extends StatefulWidget {
  const MarketingPlansScreen({super.key});

  @override
  State<MarketingPlansScreen> createState() => _MarketingPlansScreenState();
}

class _MarketingPlansScreenState extends State<MarketingPlansScreen> {
  final List<Map<String, dynamic>> _plans = [
    {
      "name": "Starter",
      "branches": 1,
      "counters": 1,
      "invoices": 500,
      "users": 1,
    },
    {
      "name": "Standard",
      "branches": 1,
      "counters": 3,
      "invoices": 2000,
      "users": 3,
    },
    {
      "name": "Pro",
      "branches": -1, // -1 means unlimited
      "counters": -1,
      "invoices": -1,
      "users": -1,
    }
  ];

  void _editPlan(Map<String, dynamic> plan) {
    final l10n = AppLocalizations.of(context)!;
    
    final branchesController = TextEditingController(text: plan["branches"].toString());
    final countersController = TextEditingController(text: plan["counters"].toString());
    final invoicesController = TextEditingController(text: plan["invoices"].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${l10n.editPlan}: ${plan["name"]}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: branchesController,
                decoration: InputDecoration(
                  labelText: l10n.noOfBranches,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: countersController,
                decoration: InputDecoration(
                  labelText: l10n.noOfCounters,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: invoicesController,
                decoration: InputDecoration(
                  labelText: l10n.invoicesPerMonth,
                ),
                keyboardType: TextInputType.number,
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
                  plan["branches"] = int.tryParse(branchesController.text) ?? plan["branches"];
                  plan["counters"] = int.tryParse(countersController.text) ?? plan["counters"];
                  plan["invoices"] = int.tryParse(invoicesController.text) ?? plan["invoices"];
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.planUpdated)),
                );
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListView.builder(
      padding: const EdgeInsets.all(24.0),
      itemCount: _plans.length,
      itemBuilder: (context, index) {
        final plan = _plans[index];
        final unlimitedText = l10n.unlimited;
        
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      plan["name"],
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editPlan(plan),
                      tooltip: l10n.editPlan,
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _FeatureItem(
                      icon: Icons.person,
                      title: 'Users',
                      value: plan["users"] == -1 ? unlimitedText : plan["users"].toString(),
                    ),
                    _FeatureItem(
                      icon: Icons.store,
                      title: l10n.branches,
                      value: plan["branches"] == -1 ? unlimitedText : plan["branches"].toString(),
                    ),
                    _FeatureItem(
                      icon: Icons.point_of_sale,
                      title: l10n.counters,
                      value: plan["counters"] == -1 ? unlimitedText : plan["counters"].toString(),
                    ),
                    _FeatureItem(
                      icon: Icons.receipt_long,
                      title: l10n.invoicesMo,
                      value: plan["invoices"] == -1 ? unlimitedText : plan["invoices"].toString(),
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
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.grey[600]),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
