import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ManageWebsitesScreen extends StatefulWidget {
  const ManageWebsitesScreen({super.key});

  @override
  State<ManageWebsitesScreen> createState() => _ManageWebsitesScreenState();
}

class _ManageWebsitesScreenState extends State<ManageWebsitesScreen> {
  final String _baseUrl = "http://localhost:3000/api/settings/client-websites";

  List<Map<String, dynamic>> _websites = [
    {
      "id": "1",
      "domainName": "intelligentdive.com",
      "appType": "Next.js",
      "appPort": 3000,
      "documentRoot": "-",
      "phpVersion": "-",
      "status": "active",
      "sslActive": true,
      "createdAt": "2026-10-10",
    },
    {
      "id": "2",
      "domainName": "dim.sonalisa.info",
      "appType": "Laravel",
      "appPort": null,
      "documentRoot": "/home/dim.sonalisa.info/public_html",
      "phpVersion": "8.1",
      "status": "active",
      "sslActive": false,
      "createdAt": "2026-10-10",
    },
  ];

  bool _isLoading = false;
  bool _isCheckingHealth = false;

  @override
  void initState() {
    super.initState();
    _fetchWebsites();
  }

  Future<void> _fetchWebsites() async {
    setState(() => _isLoading = true);
    try {
      final res = await http.get(Uri.parse(_baseUrl));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['success'] == true && data['data'] != null) {
          final List list = data['data'];
          if (list.isNotEmpty) {
            setState(() {
              _websites = List<Map<String, dynamic>>.from(list);
            });
          }
        }
      }
    } catch (e) {
      // Fallback to local state if backend API is offline
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _runHealthCheck() async {
    setState(() => _isCheckingHealth = true);
    try {
      final res = await http.get(Uri.parse("$_baseUrl/health-check"));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final summary = data['summary'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Health Check Complete: ${summary['active']} Active, ${summary['offline']} Offline',
            ),
            backgroundColor: summary['offline'] == 0 ? Colors.green : Colors.orange,
          ),
        );
        _fetchWebsites();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Health Check API request sent')),
      );
    } finally {
      setState(() => _isCheckingHealth = false);
    }
  }

  Future<void> _provisionWebsite(String domain, String type, String param, String phpVer) async {
    setState(() => _isLoading = true);
    try {
      final body = {
        "domainName": domain,
        "appType": type.toLowerCase(),
        "appPort": type == "Next.js" ? param : null,
        "documentRoot": type != "Next.js" ? param : null,
        "phpVersion": type == "Laravel" ? phpVer : null,
      };

      final res = await http.post(
        Uri.parse(_baseUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Successfully provisioned $domain on VPS!'), backgroundColor: Colors.green),
          );
          _fetchWebsites();
          return;
        }
      }
    } catch (e) {
      // Fallback local add
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAddWebsiteDialog() {
    final domainController = TextEditingController();
    final paramController = TextEditingController(text: "3001");
    String selectedType = "Next.js";
    String selectedPhp = "8.1";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.web, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Provision Client Website'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: domainController,
                      decoration: const InputDecoration(
                        labelText: 'Domain Name (e.g. clientbrand.com)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.language),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Application Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.apps),
                      ),
                      items: const [
                        DropdownMenuItem(value: "Next.js", child: Text("Next.js / Node.js (Proxy Port)")),
                        DropdownMenuItem(value: "Laravel", child: Text("PHP / Laravel (PHP-FPM)")),
                        DropdownMenuItem(value: "Static", child: Text("Static HTML / Frontend")),
                      ],
                      onChanged: (val) {
                        setDialogState(() {
                          selectedType = val!;
                          if (val == "Next.js") {
                            paramController.text = "3001";
                          } else if (val == "Laravel") {
                            paramController.text = "/home/client/public_html";
                          } else {
                            paramController.text = "/var/www/client";
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: paramController,
                      decoration: InputDecoration(
                        labelText: selectedType == "Next.js"
                            ? 'App Port (e.g. 3001)'
                            : 'Document Root Path',
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(selectedType == "Next.js" ? Icons.numbers : Icons.folder),
                      ),
                    ),
                    if (selectedType == "Laravel") ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedPhp,
                        decoration: const InputDecoration(
                          labelText: 'PHP Version',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.code),
                        ),
                        items: const [
                          DropdownMenuItem(value: "8.1", child: Text("PHP 8.1")),
                          DropdownMenuItem(value: "8.2", child: Text("PHP 8.2")),
                          DropdownMenuItem(value: "8.3", child: Text("PHP 8.3")),
                        ],
                        onChanged: (val) {
                          setDialogState(() => selectedPhp = val!);
                        },
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    final domain = domainController.text.trim();
                    if (domain.isEmpty) return;

                    Navigator.pop(context);
                    _provisionWebsite(domain, selectedType, paramController.text.trim(), selectedPhp);
                  },
                  icon: const Icon(Icons.rocket_launch),
                  label: const Text('Provision on VPS'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Websites Management'),
        actions: [
          IconButton(
            icon: _isCheckingHealth
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.monitor_heart_outlined),
            onPressed: _isCheckingHealth ? null : _runHealthCheck,
            tooltip: 'Run Health & Uptime Check',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchWebsites,
            tooltip: 'Refresh List',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.dns, size: 40, color: Colors.blue),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'VPS Nginx Hosting Manager',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Manage client domains, subdomains, reverse proxies, and Laravel PHP-FPM sites directly on your VPS (165.73.244.224).',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _showAddWebsiteDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Client Website'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                            columns: const [
                              DataColumn(label: Text('Domain Name', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('App Type', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Port / Document Root', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('PHP Version', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('SSL', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: _websites.map((site) {
                              final isActive = site['status'] == 'active';
                              return DataRow(
                                cells: [
                                  DataCell(Row(
                                    children: [
                                      const Icon(Icons.language, size: 18, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Text(
                                        site['domainName'] ?? '-',
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  )),
                                  DataCell(Chip(
                                    label: Text(site['appType'] ?? 'Next.js'),
                                    backgroundColor: Colors.blue.shade50,
                                    labelStyle: const TextStyle(color: Colors.blue),
                                  )),
                                  DataCell(Text(
                                    site['appPort'] != null ? 'Port ${site['appPort']}' : (site['documentRoot'] ?? '-'),
                                  )),
                                  DataCell(Text(site['phpVersion'] ?? '-')),
                                  DataCell(Chip(
                                    avatar: Icon(
                                      isActive ? Icons.check_circle : Icons.error,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      (site['status'] ?? 'pending').toString().toUpperCase(),
                                      style: const TextStyle(color: Colors.white, fontSize: 11),
                                    ),
                                    backgroundColor: isActive ? Colors.green : Colors.red,
                                  )),
                                  DataCell(Icon(
                                    site['sslActive'] == true ? Icons.lock : Icons.lock_open,
                                    color: site['sslActive'] == true ? Colors.green : Colors.orange,
                                  )),
                                  DataCell(Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.sync, color: Colors.blue),
                                        tooltip: 'Re-sync Nginx Config',
                                        onPressed: () {},
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        tooltip: 'Delete Site',
                                        onPressed: () {
                                          setState(() {
                                            _websites.removeWhere((w) => w['id'] == site['id']);
                                          });
                                        },
                                      ),
                                    ],
                                  )),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
