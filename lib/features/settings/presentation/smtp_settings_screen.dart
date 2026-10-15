import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

class SmtpSettingsContent extends ConsumerStatefulWidget {
  const SmtpSettingsContent({super.key});

  @override
  ConsumerState<SmtpSettingsContent> createState() => _SmtpSettingsContentState();
}

class _SmtpSettingsContentState extends ConsumerState<SmtpSettingsContent> {
  final _formKey = GlobalKey<FormState>();

  bool _enabled = false;
  final _hostController = TextEditingController();
  final _portController = TextEditingController(text: '587');
  bool _secure = false; // true for SSL (465), false for TLS (587)
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fromNameController = TextEditingController();
  final _fromEmailController = TextEditingController();

  bool _obscurePassword = true;
  bool _isPasswordSet = false;
  bool _isSaving = false;
  bool _isTesting = false;
  bool _loaded = false;

  final _testEmailController = TextEditingController();

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _fromNameController.dispose();
    _fromEmailController.dispose();
    _testEmailController.dispose();
    super.dispose();
  }

  void _populateForm(Map<String, dynamic> settings) {
    if (_loaded) return;
    _loaded = true;

    _enabled = settings['enabled'] ?? false;
    _hostController.text = settings['host'] ?? '';
    _portController.text = (settings['port'] ?? 587).toString();
    _secure = settings['secure'] ?? (_portController.text == '465');
    _usernameController.text = settings['username'] ?? '';
    _fromNameController.text = settings['fromName'] ?? '';
    _fromEmailController.text = settings['fromEmail'] ?? '';
    _isPasswordSet = settings['isPasswordSet'] ?? false;

    if (_isPasswordSet) {
      _passwordController.text = '••••••••';
    } else {
      _passwordController.text = settings['password'] ?? '';
    }
  }

  void _applyPreset(String presetKey) {
    setState(() {
      switch (presetKey) {
        case 'gmail':
          _hostController.text = 'smtp.gmail.com';
          _portController.text = '587';
          _secure = false;
          break;
        case 'outlook':
          _hostController.text = 'smtp.office365.com';
          _portController.text = '587';
          _secure = false;
          break;
        case 'sendgrid':
          _hostController.text = 'smtp.sendgrid.net';
          _portController.text = '587';
          _secure = false;
          break;
        case 'mailgun':
          _hostController.text = 'smtp.mailgun.org';
          _portController.text = '587';
          _secure = false;
          break;
        case 'amazon_ses':
          _hostController.text = 'email-smtp.us-east-1.amazonaws.com';
          _portController.text = '587';
          _secure = false;
          break;
      }
    });
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final api = ref.read(settingsApiProvider);
      final payload = {
        'smtpSettings': {
          'enabled': _enabled,
          'host': _hostController.text.trim(),
          'port': int.tryParse(_portController.text.trim()) ?? 587,
          'secure': _secure,
          'username': _usernameController.text.trim(),
          'password': _passwordController.text.trim(),
          'fromName': _fromNameController.text.trim(),
          'fromEmail': _fromEmailController.text.trim(),
        }
      };

      await api.updateSmtpSettings(payload);
      ref.invalidate(smtpSettingsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ SMTP Settings saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error saving SMTP settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _showTestEmailDialog() async {
    if (_usernameController.text.isNotEmpty && _testEmailController.text.isEmpty) {
      _testEmailController.text = _fromEmailController.text.isNotEmpty
          ? _fromEmailController.text
          : _usernameController.text;
    }

    final testRecipient = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.mark_email_read_outlined, color: Color(0xFF2563EB)),
            SizedBox(width: 8),
            Text('Send Test Email'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the recipient email address to send a test message using the current SMTP settings:',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _testEmailController,
              decoration: const InputDecoration(
                labelText: 'Recipient Email Address',
                hintText: 'e.g. name@example.com',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              if (_testEmailController.text.trim().isNotEmpty) {
                Navigator.pop(ctx, _testEmailController.text.trim());
              }
            },
            icon: const Icon(Icons.send_rounded, size: 18),
            label: const Text('Send Test Email'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (testRecipient != null && testRecipient.isNotEmpty) {
      _runSmtpTest(testRecipient);
    }
  }

  Future<void> _runSmtpTest(String recipientEmail) async {
    setState(() => _isTesting = true);
    try {
      final api = ref.read(settingsApiProvider);
      final payload = {
        'testEmail': recipientEmail,
        'smtpSettings': {
          'host': _hostController.text.trim(),
          'port': int.tryParse(_portController.text.trim()) ?? 587,
          'secure': _secure,
          'username': _usernameController.text.trim(),
          'password': _passwordController.text.trim(),
          'fromName': _fromNameController.text.trim(),
          'fromEmail': _fromEmailController.text.trim(),
        }
      };

      final response = await api.testSmtpSettings(payload);
      final message = response['message'] ?? 'SMTP connection successful & test email sent!';

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
                SizedBox(width: 8),
                Text('Test Connection Successful'),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error_outline_rounded, color: Colors.red, size: 28),
                SizedBox(width: 8),
                Text('SMTP Test Failed'),
              ],
            ),
            content: Text(
              'Could not connect or send email via SMTP server.\n\nDetails: $e',
              style: const TextStyle(fontSize: 13),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isTesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final smtpAsync = ref.watch(smtpSettingsProvider);

    return smtpAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text('Failed to load SMTP settings: $err'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.refresh(smtpSettingsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (settings) {
        _populateForm(settings);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Banner Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SMTP Email Setup',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Configure outbound email delivery for invoices, receipts, and system alerts.',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                    // Enable/Disable Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _enabled ? Colors.green.shade50 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _enabled ? Colors.green.shade300 : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _enabled ? Icons.check_circle : Icons.power_settings_new,
                            color: _enabled ? Colors.green.shade700 : Colors.grey.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _enabled ? 'SMTP Enabled' : 'SMTP Disabled',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _enabled ? Colors.green.shade800 : Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Switch(
                            value: _enabled,
                            activeColor: Colors.green.shade600,
                            onChanged: (val) => setState(() => _enabled = val),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Quick Presets Selector
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.bolt, color: Color(0xFFF59E0B), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Quick Provider Presets',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ActionChip(
                              avatar: const Icon(Icons.mail, size: 16, color: Colors.red),
                              label: const Text('Gmail / Workspace'),
                              onPressed: () => _applyPreset('gmail'),
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.business, size: 16, color: Colors.blue),
                              label: const Text('Outlook 365'),
                              onPressed: () => _applyPreset('outlook'),
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.send, size: 16, color: Colors.purple),
                              label: const Text('SendGrid'),
                              onPressed: () => _applyPreset('sendgrid'),
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.mark_email_unread, size: 16, color: Colors.orange),
                              label: const Text('Mailgun'),
                              onPressed: () => _applyPreset('mailgun'),
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.cloud, size: 16, color: Colors.amber),
                              label: const Text('Amazon SES'),
                              onPressed: () => _applyPreset('amazon_ses'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Server Configuration Section
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Server Settings',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // SMTP Host
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _hostController,
                                decoration: const InputDecoration(
                                  labelText: 'SMTP Host / Server *',
                                  hintText: 'smtp.gmail.com',
                                  prefixIcon: Icon(Icons.dns_outlined),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (val) {
                                  if (_enabled && (val == null || val.trim().isEmpty)) {
                                    return 'SMTP Host is required when SMTP is enabled';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Port
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                controller: _portController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Port *',
                                  hintText: '587',
                                  prefixIcon: Icon(Icons.numbers_outlined),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (val) {
                                  if (_enabled && (val == null || val.trim().isEmpty)) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Security Protocol (TLS vs SSL)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Security Protocol:',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Radio<bool>(
                                  value: false,
                                  groupValue: _secure,
                                  onChanged: (val) {
                                    setState(() {
                                      _secure = val!;
                                      if (_portController.text == '465') _portController.text = '587';
                                    });
                                  },
                                ),
                                const Text('TLS / STARTTLS (Recommended - Port 587)'),
                                const SizedBox(width: 24),
                                Radio<bool>(
                                  value: true,
                                  groupValue: _secure,
                                  onChanged: (val) {
                                    setState(() {
                                      _secure = val!;
                                      if (_portController.text == '587') _portController.text = '465';
                                    });
                                  },
                                ),
                                const Text('SSL (Port 465)'),
                              ],
                            ),
                          ],
                        ),

                        if (_hostController.text.contains('gmail.com')) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber.shade300),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.amber, size: 20),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Gmail Note: Use a 16-character Google App Password (not your regular Gmail password). Ensure 2-Step Verification is turned on in your Google Account.',
                                    style: TextStyle(fontSize: 12, color: Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Credentials & Sender Info Section
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Authentication & Sender Details',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            // Username
                            Expanded(
                              child: TextFormField(
                                controller: _usernameController,
                                decoration: const InputDecoration(
                                  labelText: 'SMTP Username / Email',
                                  hintText: 'user@domain.com',
                                  prefixIcon: Icon(Icons.person_outline),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Password
                            Expanded(
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'SMTP Password / App Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  border: const OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    ),
                                    onPressed: () {
                                      setState(() => _obscurePassword = !_obscurePassword);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            // From Name
                            Expanded(
                              child: TextFormField(
                                controller: _fromNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Sender Name (From Name)',
                                  hintText: 'e.g. Acme Billing Dept',
                                  prefixIcon: Icon(Icons.badge_outlined),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // From Email
                            Expanded(
                              child: TextFormField(
                                controller: _fromEmailController,
                                decoration: const InputDecoration(
                                  labelText: 'Sender Email (From Email)',
                                  hintText: 'no-reply@domain.com',
                                  prefixIcon: Icon(Icons.alternate_email_outlined),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Bottom Action Buttons (Test Connection & Save)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _isTesting ? null : _showTestEmailDialog,
                      icon: _isTesting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.network_check_rounded),
                      label: Text(_isTesting ? 'Testing...' : 'Test Connection & Send Email'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        foregroundColor: const Color(0xFF2563EB),
                        side: const BorderSide(color: Color(0xFF2563EB)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveSettings,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.save_rounded),
                      label: Text(_isSaving ? 'Saving...' : 'Save SMTP Settings'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}
