import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/admin_shell.dart';

class AdminSupportScreen extends StatefulWidget {
  const AdminSupportScreen({super.key});

  @override
  State<AdminSupportScreen> createState() => _AdminSupportScreenState();
}

class _AdminSupportScreenState extends State<AdminSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fbCtrl = TextEditingController();
  final _teleCtrl = TextEditingController();
  final _zaloCtrl = TextEditingController();
  final _smsCtrl = TextEditingController();
  final _gmailCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _fbCtrl.dispose();
    _teleCtrl.dispose();
    _zaloCtrl.dispose();
    _smsCtrl.dispose();
    _gmailCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('settings').doc('support').get();
      final data = doc.data();
      if (data != null) {
        _fbCtrl.text = (data['facebook'] ?? '').toString();
        _teleCtrl.text = (data['telegram'] ?? '').toString();
        _zaloCtrl.text = (data['zalo'] ?? '').toString();
        _smsCtrl.text = (data['sms'] ?? '').toString();
        _gmailCtrl.text = (data['gmail'] ?? '').toString();
        setState(() {});
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('settings').doc('support').set({
        'facebook': _fbCtrl.text.trim(),
        'telegram': _teleCtrl.text.trim(),
        'zalo': _zaloCtrl.text.trim(),
        'sms': _smsCtrl.text.trim(),
        'gmail': _gmailCtrl.text.trim(),
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu liên hệ hỗ trợ'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AdminShell(
      breadcrumbs: const ['Trang chủ', 'Hỗ trợ'],
      title: 'Liên hệ hỗ trợ',
      subtitle: 'Điền link cho Facebook, Telegram, Zalo, SMS, Gmail',
      selectedIndex: 2,
      onDestinationSelected: (i) {
        if (i == 0) Navigator.of(context).pop();
        if (i == 1) Navigator.of(context).maybePop();
      },
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Các kênh liên hệ', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 16),
                    _buildField(label: 'Facebook URL', icon: Icons.facebook, controller: _fbCtrl),
                    const SizedBox(height: 12),
                    _buildField(label: 'Telegram URL', icon: Icons.send, controller: _teleCtrl),
                    const SizedBox(height: 12),
                    _buildField(label: 'Zalo URL', icon: Icons.chat, controller: _zaloCtrl),
                    const SizedBox(height: 12),
                    _buildField(label: 'SMS (sms: hoặc link)', icon: Icons.sms, controller: _smsCtrl),
                    const SizedBox(height: 12),
                    _buildField(label: 'Gmail (mailto: hoặc link)', icon: Icons.email, controller: _gmailCtrl),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.save),
                      label: const Text('Lưu'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({required String label, required IconData icon, required TextEditingController controller}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        hintText: 'Để trống nếu không dùng',
      ),
      validator: (v) {
        // no strict validation; allow empty or any string
        return null;
      },
    );
  }
}


