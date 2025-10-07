import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../config.dart';

class WebsiteSupportPage extends StatefulWidget {
  const WebsiteSupportPage({super.key});

  @override
  State<WebsiteSupportPage> createState() => _WebsiteSupportPageState();
}

class _WebsiteSupportPageState extends State<WebsiteSupportPage> {
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
          supportSettings = DEFAULT_SETTINGS;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading support settings: $e');
      setState(() {
        supportSettings = DEFAULT_SETTINGS;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgWhite,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSupportSettings,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: AppTheme.headerGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.support_agent,
                            size: 48,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Liên hệ hỗ trợ',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Chúng tôi luôn sẵn sàng hỗ trợ bạn',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.9),
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
                        context,
                        icon: Icons.facebook,
                        title: 'Facebook',
                        subtitle: 'Kết nối với chúng tôi trên Facebook',
                        value: supportSettings!['facebook'] ?? DEFAULT_SETTINGS['facebook'],
                        onTap: () => _openUrl(supportSettings!['facebook'] ?? DEFAULT_SETTINGS['facebook']!),
                      ),
                      const SizedBox(height: 16),
                      _buildSupportOption(
                        context,
                        icon: Icons.email,
                        title: 'Email',
                        subtitle: 'Gửi email cho chúng tôi',
                        value: supportSettings!['gmail'] ?? 'caothulive@gmail.com',
                        onTap: () => _openEmail(supportSettings!['gmail'] ?? 'caothulive@gmail.com'),
                      ),
                      const SizedBox(height: 16),
                      _buildSupportOption(
                        context,
                        icon: Icons.phone,
                        title: 'SMS',
                        subtitle: 'Gửi tin nhắn cho chúng tôi',
                        value: supportSettings!['sms'] ?? '0123456789',
                        onTap: () => _openSMS(supportSettings!['sms'] ?? '0123456789'),
                      ),
                      const SizedBox(height: 16),
                      _buildSupportOption(
                        context,
                        icon: Icons.telegram,
                        title: 'Telegram',
                        subtitle: 'Liên hệ qua Telegram',
                        value: supportSettings!['telegram'] ?? '@caothulive',
                        onTap: () => _openUrl(ensureHttps(supportSettings!['telegram'] ?? '@caothulive')),
                      ),
                      const SizedBox(height: 16),
                      _buildSupportOption(
                        context,
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
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.bgLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.glassBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thông tin website',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.language, size: 20, color: AppTheme.textMuted),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  supportSettings?['web_domain'] ?? WEBSITE_DOMAIN,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.open_in_new),
                                onPressed: () => _openUrl(supportSettings?['web_domain'] ?? WEBSITE_DOMAIN),
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

  Widget _buildSupportOption(
    BuildContext context, {
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
                  color: AppTheme.primaryRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryRed,
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.textMuted,
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
