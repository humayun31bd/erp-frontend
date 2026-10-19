import 'package:flutter/material.dart';

class WhatsAppLogsScreen extends StatelessWidget {
  const WhatsAppLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'سجلات الواتساب' : 'WhatsApp Delivery Logs'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mark_chat_read, size: 64, color: Colors.green[400]),
            const SizedBox(height: 16),
            Text(
              isArabic 
                ? 'جميع الرسائل قيد التسليم أو تم استلامها.' 
                : 'All messages are delivered or pending.',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Mock MVP Data: Live delivery webhooks will populate this screen.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
