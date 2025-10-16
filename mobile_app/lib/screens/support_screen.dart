import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  Map<String, dynamic>? supportSettings;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSupportSettings();
  }

  Future<void> _loadSupportSettings() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('settings')
          .doc('support')
          .get();

      if (doc.exists) {
        setState(() {
          supportSettings = doc.data();
          isLoading = false;
        });
      } else {
        setState(() {
          supportSettings = defaultSettings;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading support settings: $e');
      setState(() {
        supportSettings = defaultSettings;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hỗ trợ'),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSupportSettings,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red.shade400, Colors.red.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.support_agent,
                            size: 48,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Liên hệ hỗ trợ',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Chúng tôi luôn sẵn sàng hỗ trợ bạn',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Support Options
                    if (supportSettings != null) ...[
                      _buildSupportOption(
                        icon: Icons.facebook,
                        title: 'Facebook',
                        subtitle: 'Kết nối với chúng tôi trên Facebook',
                        value: supportSettings!['facebook'] ?? defaultSettings['facebook'],
                        onTap: () => _openUrl(supportSettings!['facebook'] ?? defaultSettings['facebook']!),
                      ),
                      const SizedBox(height: 16),
                      _buildSupportOption(
                        icon: Icons.email,
                        title: 'Email',
                        subtitle: 'Gửi email cho chúng tôi',
                        value: supportSettings!['gmail'] ?? 'caothulive@gmail.com',
                        onTap: () => _openEmail(supportSettings!['gmail'] ?? 'caothulive@gmail.com'),
                      ),
                      const SizedBox(height: 16),
                      _buildSupportOption(
                        icon: Icons.phone,
                        title: 'SMS',
                        subtitle: 'Gửi tin nhắn cho chúng tôi',
                        value: supportSettings!['sms'] ?? '0123456789',
                        onTap: () => _openSMS(supportSettings!['sms'] ?? '0123456789'),
                      ),
                      const SizedBox(height: 16),
                      _buildSupportOption(
                        icon: Icons.telegram,
                        title: 'Telegram',
                        subtitle: 'Liên hệ qua Telegram',
                        value: supportSettings!['telegram'] ?? '@caothulive',
                        onTap: () => _openUrl(ensureHttps(supportSettings!['telegram'] ?? '@caothulive')),
                      ),
                      const SizedBox(height: 16),
                      _buildSupportOption(
                        icon: Icons.chat,
                        title: 'Zalo',
                        subtitle: 'Chat với chúng tôi trên Zalo',
                        value: supportSettings!['zalo'] ?? '0123456789',
                        onTap: () => _openUrl(ensureHttps(supportSettings!['zalo'] ?? '0123456789')),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Website Info
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Thông tin website',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.language, size: 20, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  supportSettings?['web_domain'] ?? websiteDomain,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.open_in_new),
                                onPressed: () => _openUrl(supportSettings?['web_domain'] ?? websiteDomain),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSupportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.red.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    try {
      final uri = Uri.parse(ensureHttps(url));
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error opening URL: $e');
    }
  }

  Future<void> _openEmail(String email) async {
    try {
      final uri = Uri.parse('mailto:$email');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Error opening email: $e');
    }
  }

  Future<void> _openSMS(String phone) async {
    try {
      final uri = Uri.parse('sms:$phone');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Error opening SMS: $e');
    }
  }
}
