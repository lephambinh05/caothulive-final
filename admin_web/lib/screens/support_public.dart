import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPublicScreen extends StatelessWidget {
  const SupportPublicScreen({super.key});

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        // ignore failure silently
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Hỗ trợ')), 
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('settings').doc('support').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data() ?? {};
          final items = <_SupportItem>[
            _SupportItem('Facebook', Icons.facebook, data['facebook']?.toString()),
            _SupportItem('Telegram', Icons.send, data['telegram']?.toString()),
            _SupportItem('Zalo', Icons.chat, data['zalo']?.toString()),
            _SupportItem('SMS', Icons.sms, data['sms']?.toString()),
            _SupportItem('Gmail', Icons.email, data['gmail']?.toString()),
          ].where((e) => (e.url ?? '').toString().trim().isNotEmpty).toList();

          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.support_agent, size: 72, color: theme.disabledColor),
                    const SizedBox(height: 12),
                    Text('Chưa có kênh hỗ trợ nào', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('Vui lòng liên hệ quản trị viên.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
                  ],
                ),
              ),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final item in items)
                      SizedBox(
                        width: 200,
                        child: ElevatedButton.icon(
                          icon: Icon(item.icon),
                          label: Text(item.label),
                          onPressed: () => _openUrl(item.url!),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SupportItem {
  final String label;
  final IconData icon;
  final String? url;
  _SupportItem(this.label, this.icon, this.url);
}


