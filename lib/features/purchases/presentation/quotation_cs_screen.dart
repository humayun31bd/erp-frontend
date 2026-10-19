import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../domain/procurement_models.dart';
import '../utils/procurement_document_formatter.dart';
import '../providers/procurement_provider.dart';
import '../../../../core/widgets/feature_guard.dart';

class QuotationCsScreen extends ConsumerStatefulWidget {
  const QuotationCsScreen({super.key});

  @override
  ConsumerState<QuotationCsScreen> createState() => _QuotationCsScreenState();
}

class _QuotationCsScreenState extends ConsumerState<QuotationCsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final csAsync = ref.watch(comparativeStatementsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparative Statements (CS Matrix)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(comparativeStatementsProvider),
            tooltip: 'Refresh',
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            icon: const Icon(Icons.compare_arrows),
            label: const Text('New CS Evaluation'),
            onPressed: () => _showCreateCsDialog(context),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: FeatureGuard(
        featureKey: 'quotations',
        featureTitle: 'Comparative Statements & Quotations',
        child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search CS #, title, or winner supplier...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
            ),
          ),
          Expanded(
            child: csAsync.when(
              data: (csList) {
                final filtered = csList.where((cs) {
                  return cs.csNumber.toLowerCase().contains(_searchQuery) ||
                      cs.title.toLowerCase().contains(_searchQuery) ||
                      (cs.winnerSupplierName ?? '').toLowerCase().contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('No Comparative Statements found.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final cs = filtered[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: theme.colorScheme.secondaryContainer,
                                  child: Icon(Icons.analytics, color: theme.colorScheme.secondary),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(cs.csNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                          const SizedBox(width: 10),
                                          _buildStatusBadge(cs.status),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(cs.title, style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                                    ],
                                  ),
                                ),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.visibility),
                                  label: const Text('View Matrix'),
                                  onPressed: () => _showCsDetailModal(context, cs),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Evaluated Bids: ${cs.items.length} Suppliers', style: const TextStyle(fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text(
                                      cs.winnerSupplierName != null
                                          ? 'Selected Winner: ${cs.winnerSupplierName}'
                                          : 'Winning Supplier: Pending Approval',
                                      style: TextStyle(
                                        color: cs.winnerSupplierName != null ? Colors.green.shade700 : Colors.orange.shade800,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Created: ${DateFormat('yyyy-MM-dd').format(cs.createdAt)}',
                                  style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
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
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error loading comparative statements: $err')),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    switch (status.toUpperCase()) {
      case 'APPROVED':
        bg = Colors.green.withValues(alpha: 0.15);
        fg = Colors.green.shade800;
        break;
      case 'REJECTED':
        bg = Colors.red.withValues(alpha: 0.15);
        fg = Colors.red.shade800;
        break;
      default:
        bg = Colors.amber.withValues(alpha: 0.2);
        fg = Colors.amber.shade900;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(
        status,
        style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  Future<void> _showCreateCsDialog(BuildContext context) async {
    final titleController = TextEditingController();

    List<SupplierQuotationModel> quotations = [];
    try {
      quotations = await ref.read(supplierQuotationsProvider.future);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load supplier quotations: $e'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
      return;
    }

    if (quotations.length < 2) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(quotations.isEmpty
                ? 'Please create supplier quotations first before generating a Comparative Statement.'
                : 'Comparative Statement requires at least 2 supplier quotations to compare (currently found ${quotations.length}).'),
            backgroundColor: Colors.orange.shade900,
          ),
        );
      }
      return;
    }

    final selectedMap = <String, bool>{};
    final leadDaysMap = <String, TextEditingController>{};
    final scoreMap = <String, TextEditingController>{};

    for (var q in quotations) {
      selectedMap[q.id] = false;
      leadDaysMap[q.id] = TextEditingController(text: '7');
      scoreMap[q.id] = TextEditingController(text: '80');
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Create Comparative Statement (CS Matrix)'),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'CS Evaluation Title *',
                      hintText: 'e.g. Q4 Raw Material Procurement CS',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Select Quotations for Comparison (Min 2):', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...quotations.map((q) {
                    final isChecked = selectedMap[q.id] ?? false;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            CheckboxListTile(
                              value: isChecked,
                              title: Text('${q.quotationNumber} - ${q.supplierName ?? ProcurementDocumentFormatter.formatSupplierCode(q.supplierId)}'),
                              subtitle: Text('Amount: SAR ${q.totalAmount} | Title: ${q.title ?? "N/A"}'),
                              onChanged: (val) {
                                setModalState(() {
                                  selectedMap[q.id] = val ?? false;
                                });
                              },
                            ),
                            if (isChecked) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: leadDaysMap[q.id],
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: 'Delivery Lead Days',
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextField(
                                        controller: scoreMap[q.id],
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: 'Technical Score (0-100)',
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                            ]
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                if (title.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Please enter a CS evaluation title.')),
                  );
                  return;
                }

                final items = <Map<String, dynamic>>[];
                for (var q in quotations) {
                  if (selectedMap[q.id] == true) {
                    items.add({
                      'quotationId': q.id,
                      'supplierId': q.supplierId,
                      'supplierName': q.supplierName ?? q.supplierId,
                      'quotationNumber': q.quotationNumber,
                      'quotedAmount': q.totalAmount,
                      'deliveryLeadDays': int.tryParse(leadDaysMap[q.id]?.text ?? '7') ?? 7,
                      'score': int.tryParse(scoreMap[q.id]?.text ?? '80') ?? 80,
                      'isSelected': false,
                    });
                  }
                }

                if (items.length < 2) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Please select at least 2 quotations for comparison.')),
                  );
                  return;
                }

                final payload = {
                  'title': title,
                  'status': 'DRAFT',
                  'quotationIds': items.map((i) => i['quotationId']).toList(),
                  'items': items,
                  'remarks': 'Created from CS Matrix evaluation',
                };

                try {
                  await ref.read(procurementServiceProvider).createComparativeStatement(payload);
                  ref.invalidate(comparativeStatementsProvider);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('CS Matrix created successfully!')),
                    );
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Text('Failed to create CS: ${e.toString().replaceAll('Exception: ', '')}'),
                        backgroundColor: Colors.red.shade800,
                      ),
                    );
                  }
                }
              },
              child: const Text('Save CS Matrix'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCsDetailModal(BuildContext context, ComparativeStatementModel cs) {
    String? selectedWinnerQuotationId = cs.winnerQuotationId ?? (cs.items.isNotEmpty ? cs.items.first.quotationId : null);
    final notesController = TextEditingController(text: cs.notes ?? '');
    int activeTab = 0; // 0: Supplier Bid Ranking, 1: Line-Item Comparison Matrix

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Row(
            children: [
              Expanded(
                child: Text('${cs.csNumber} - Evaluation Matrix'),
              ),
              _buildStatusBadge(cs.status),
            ],
          ),
          content: SizedBox(
            width: 900,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Title: ${cs.title}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  // Tab Switcher
                  SegmentedButton<int>(
                    segments: [
                      const ButtonSegment(
                        value: 0,
                        icon: Icon(Icons.leaderboard),
                        label: Text('Supplier Bid Ranking (50/35/15)'),
                      ),
                      ButtonSegment(
                        value: 1,
                        icon: const Icon(Icons.table_chart),
                        label: Text(
                          cs.lineItemMatrix?.rows.isNotEmpty == true
                              ? 'Line-Item Matrix (${cs.lineItemMatrix!.rows.length} Items)'
                              : 'Line-Item Matrix',
                        ),
                      ),
                    ],
                    selected: {activeTab},
                    onSelectionChanged: (val) {
                      setModalState(() {
                        activeTab = val.first;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (activeTab == 0) ...[
                  Table(
                    border: TableBorder.all(color: Colors.grey.shade300, width: 1),
                    columnWidths: const {
                      0: FlexColumnWidth(0.7),
                      1: FlexColumnWidth(1.3),
                      2: FlexColumnWidth(2.0),
                      3: FlexColumnWidth(1.7),
                      4: FlexColumnWidth(1.3),
                      5: FlexColumnWidth(1.6),
                      6: FlexColumnWidth(0.8),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: Colors.grey.shade100),
                        children: const [
                          Padding(padding: EdgeInsets.all(8), child: Text('Rank', style: TextStyle(fontWeight: FontWeight.bold))),
                          Padding(padding: EdgeInsets.all(8), child: Text('Quotation #', style: TextStyle(fontWeight: FontWeight.bold))),
                          Padding(padding: EdgeInsets.all(8), child: Text('Supplier', style: TextStyle(fontWeight: FontWeight.bold))),
                          Padding(padding: EdgeInsets.all(8), child: Text('Price (SAR)', style: TextStyle(fontWeight: FontWeight.bold))),
                          Padding(padding: EdgeInsets.all(8), child: Text('Lead Time', style: TextStyle(fontWeight: FontWeight.bold))),
                          Padding(padding: EdgeInsets.all(8), child: Text('Score (50/35/15)', style: TextStyle(fontWeight: FontWeight.bold))),
                          Padding(padding: EdgeInsets.all(8), child: Text('Award', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                      ...cs.items.map((item) {
                        final isSelected = selectedWinnerQuotationId == item.quotationId;
                        return TableRow(
                          decoration: BoxDecoration(color: isSelected ? Colors.green.withValues(alpha: 0.1) : null),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                '#${item.rank}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: item.rank == 1 ? Colors.amber.shade900 : Colors.grey.shade700,
                                ),
                              ),
                            ),
                            Padding(padding: const EdgeInsets.all(8), child: Text(item.quotationNumber)),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.supplierName, style: const TextStyle(fontWeight: FontWeight.w600)), Text(ProcurementDocumentFormatter.formatSupplierCode(item.supplierId), style: TextStyle(fontSize: 10, color: Colors.grey.shade600))]),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 4,
                                    children: [
                                      if (item.isLowestPrice)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade100,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text('L1 - Best Price', style: TextStyle(fontSize: 10, color: Colors.green.shade800, fontWeight: FontWeight.bold)),
                                        ),
                                      if (item.isHighestScore)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade100,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text('Best Value', style: TextStyle(fontSize: 10, color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('SAR ${item.quotedAmount}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  if (item.financialScore > 0)
                                    Text('Price: ${item.financialScore.toStringAsFixed(1)}%', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${item.deliveryLeadDays} days'),
                                  if (item.deliveryScore > 0)
                                    Text('Speed: ${item.deliveryScore.toStringAsFixed(1)}%', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item.compositeScore.toStringAsFixed(1)} / 100',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: item.compositeScore >= 85 ? Colors.green.shade800 : Colors.blue.shade900,
                                    ),
                                  ),
                                  Text('Tech: ${item.technicalScore.toStringAsFixed(0)} pts', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4),
                              child: Radio<String>(
                                value: item.quotationId,
                                groupValue: selectedWinnerQuotationId,
                                onChanged: cs.status == 'APPROVED'
                                    ? null
                                    : (val) {
                                        setModalState(() {
                                          selectedWinnerQuotationId = val;
                                        });
                                      },
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (cs.status != 'APPROVED') ...[
                    Builder(
                      builder: (context) {
                        final chosenItem = cs.items.where((i) => i.quotationId == selectedWinnerQuotationId).firstOrNull;
                        final isDeviation = chosenItem != null && !chosenItem.isLowestPrice;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isDeviation)
                              Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.amber.shade300),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Note: You have selected an offer higher than L1 (Lowest Bidder). Please record your deviation justification below for audit compliance.',
                                        style: TextStyle(fontSize: 12, color: Colors.amber.shade900, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            TextField(
                              controller: notesController,
                              decoration: InputDecoration(
                                labelText: isDeviation
                                    ? 'Deviation Justification & Approval Notes *'
                                    : 'Manager Approval / Rejection Notes',
                                border: const OutlineInputBorder(),
                                hintText: isDeviation
                                    ? 'Explain why L1 was bypassed (e.g. superior warranty, faster delivery)...'
                                    : 'e.g. Approved based on technical evaluation...',
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  cs.winnerSupplierName != null
                                      ? 'Approved Winner: ${cs.winnerSupplierName}'
                                      : 'Approved under Split-Award Strategy (Multiple Winning Vendors)',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          if (cs.purchaseOrders.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Text('Generated Purchase Orders:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: cs.purchaseOrders.map((po) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.green.shade400),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2)),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.green.shade800),
                                      const SizedBox(width: 6),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(po.poNumber, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green.shade900)),
                                          Text('${po.supplierName} • SAR ${po.totalAmount}', style: TextStyle(fontSize: 10, color: Colors.grey.shade700)),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  ] else ...[
                    _buildLineItemMatrixSection(cs),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
            if (cs.status != 'APPROVED') ...[
              if (cs.lineItemMatrix != null && cs.lineItemMatrix!.rows.isNotEmpty)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.call_split),
                  label: const Text('Approve Split-Award (Multi-PO)'),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: ctx,
                      builder: (c) => AlertDialog(
                        title: const Text('Confirm Split-Award Allocation'),
                        content: Text(
                          'This will automatically generate separate Purchase Orders to each winning supplier for their respective lowest-rate items (Cherry-Pick Strategy Total: SAR ${cs.lineItemMatrix!.summary?.cherryPickTotal.toStringAsFixed(2) ?? "0.00"}).\n\nProceed with Split-Award?',
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade700, foregroundColor: Colors.white),
                            onPressed: () => Navigator.pop(c, true),
                            child: const Text('Generate Split POs'),
                          ),
                        ],
                      ),
                    );

                    if (confirm != true) return;

                    try {
                      await ref.read(procurementServiceProvider).approveComparativeStatement(
                            csId: cs.id,
                            awardMode: 'SPLIT',
                            notes: notesController.text.trim().isEmpty
                                ? 'Approved via optimal lowest-rate split award'
                                : notesController.text.trim(),
                          );
                      ref.invalidate(comparativeStatementsProvider);
                      if (ctx.mounted) Navigator.of(ctx).pop();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Split-Award approved! Separate Purchase Orders generated per supplier.'),
                            backgroundColor: Colors.teal,
                          ),
                        );
                      }
                    } catch (e) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text('Failed to split award CS: $e'), backgroundColor: Colors.red.shade800),
                        );
                      }
                    }
                  },
                ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                icon: const Icon(Icons.approval),
                label: const Text('Single-Vendor Award'),
                onPressed: () async {
                  if (selectedWinnerQuotationId == null) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Please select a winning supplier quotation.')),
                    );
                    return;
                  }

                  final winnerItem = cs.items.firstWhere((i) => i.quotationId == selectedWinnerQuotationId);

                  try {
                    await ref.read(procurementServiceProvider).approveComparativeStatement(
                          csId: cs.id,
                          awardMode: 'SINGLE',
                          winnerQuotationId: winnerItem.quotationId,
                          winnerSupplierId: winnerItem.supplierId ?? winnerItem.supplierName,
                          notes: notesController.text.trim(),
                        );
                    ref.invalidate(comparativeStatementsProvider);
                    if (ctx.mounted) Navigator.of(ctx).pop();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('CS Approved successfully! Winning supplier selected.')),
                      );
                    }
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text('Failed to approve CS: $e')),
                      );
                    }
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLineItemMatrixSection(ComparativeStatementModel cs) {
    final matrix = cs.lineItemMatrix;
    if (matrix == null || matrix.rows.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(28),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 44, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            const Text('No line-item details found for the participating quotations.',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 6),
            Text(
              'Quotations may have been submitted without item-level line records.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      );
    }

    final summary = matrix.summary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Executive Optimization Summary Banner
        if (summary != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blueGrey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    icon: Icons.savings_outlined,
                    color: Colors.green.shade800,
                    title: 'Cherry-Pick Optimal (Split-Award)',
                    value: 'SAR ${summary.cherryPickTotal.toStringAsFixed(2)}',
                    subtitle: 'Lowest rate across all items',
                  ),
                ),
                Container(width: 1, height: 45, color: Colors.grey.shade300),
                Expanded(
                  child: _buildMetricTile(
                    icon: Icons.trending_down,
                    color: Colors.teal.shade800,
                    title: 'Potential Multi-Award Savings',
                    value: 'SAR ${summary.potentialSavingsVsHighest.toStringAsFixed(2)}',
                    subtitle: '${summary.potentialSavingsPercent.toStringAsFixed(1)}% vs highest quotation',
                  ),
                ),
                Container(width: 1, height: 45, color: Colors.grey.shade300),
                Expanded(
                  child: _buildMetricTile(
                    icon: Icons.checklist_rtl_rounded,
                    color: Colors.indigo.shade800,
                    title: 'Compared Product Lines',
                    value: '${summary.totalItems} Items',
                    subtitle: 'Cross-supplier item breakdown',
                  ),
                ),
              ],
            ),
          ),

        // Line-Item Matrix Comparison Table
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 860),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
              dataRowMinHeight: 48,
              dataRowMaxHeight: 56,
              border: TableBorder.all(color: Colors.grey.shade300, width: 1),
              columns: [
                const DataColumn(label: Text('Product / Item', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold))),
                ...cs.items.map(
                  (item) => DataColumn(
                    label: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.supplierName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('#${item.quotationNumber}', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                ),
                const DataColumn(label: Text('Spread (%)', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('Potential Savings', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: matrix.rows.map((row) {
                return DataRow(
                  cells: [
                    DataCell(
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(row.productName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          if (row.description != row.productName && row.description.isNotEmpty)
                            Text(row.description, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    DataCell(Text(row.quantity.toStringAsFixed(0))),
                    ...cs.items.map((item) {
                      final bid = row.supplierBids[item.quotationId];
                      if (bid == null) {
                        return const DataCell(Text('-', style: TextStyle(color: Colors.grey)));
                      }
                      return DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: bid.isLowestPrice ? Colors.green.withValues(alpha: 0.12) : null,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'SAR ${bid.unitPrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: bid.isLowestPrice ? FontWeight.bold : FontWeight.normal,
                                      color: bid.isLowestPrice ? Colors.green.shade900 : Colors.black87,
                                    ),
                                  ),
                                  if (bid.isLowestPrice) ...[
                                    const SizedBox(width: 4),
                                    Icon(Icons.check_circle, size: 13, color: Colors.green.shade800),
                                  ],
                                ],
                              ),
                              Text('Total: SAR ${bid.totalAmount.toStringAsFixed(2)}',
                                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                      );
                    }),
                    DataCell(
                      Text(
                        row.variancePercent > 0 ? '+${row.variancePercent.toStringAsFixed(1)}%' : '0%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: row.variancePercent > 15 ? Colors.deepOrange.shade800 : Colors.grey.shade800,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        'SAR ${row.potentialSavings.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: row.potentialSavings > 0 ? Colors.green.shade800 : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: Colors.blue.shade800),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Green cells with checkmarks highlight the lowest unit price (L1) per item. Step 3 (Split-Award PO) will allow awarding lines individually to optimize overall expenditure.',
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.15),
            radius: 18,
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
                Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

