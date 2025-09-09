import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _webDomainController = TextEditingController();
  bool _saving = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _emailController.text = user?.email ?? '';
    _loadConfig();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _webDomainController.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('settings').doc('config').get();
      final data = doc.data();
      if (data != null) {
        _webDomainController.text = (data['web_domain'] ?? '').toString();
        if (mounted) setState(() {});
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _saving = true);

    try {
      // Update email if changed
      final newEmail = _emailController.text.trim();
      if (newEmail.isNotEmpty && newEmail != user.email) {
        await user.updateEmail(newEmail);
        // Optional: also reflect in Firestore admins collection if needed
        final admins = await FirebaseFirestore.instance.collection('admins').limit(1).get();
        if (admins.docs.isNotEmpty) {
          await admins.docs.first.reference.update({'email': newEmail});
        }
      }

      // Update password if provided
      final newPassword = _passwordController.text;
      if (newPassword.isNotEmpty) {
        await user.updatePassword(newPassword);
      }

      // Save web domain to settings/config
      final webDomain = _webDomainController.text.trim();
      await FirebaseFirestore.instance.collection('settings').doc('config').set({
        'web_domain': webDomain,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật thành công'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.code}'), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi xảy ra: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Cài đặt', style: theme.textTheme.titleLarge),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Thông tin admin', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Nhập email';
                          final ok = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim());
                          if (!ok) return 'Email không hợp lệ';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu mới (để trống nếu không đổi)',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        obscureText: _obscure,
                        validator: (v) {
                          if (v != null && v.isNotEmpty && v.length < 6) {
                            return 'Mật khẩu tối thiểu 6 ký tự';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: const InputDecoration(
                          labelText: 'Nhập lại mật khẩu mới',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        obscureText: _obscure,
                        validator: (v) {
                          if (_passwordController.text.isNotEmpty && v != _passwordController.text) {
                            return 'Mật khẩu không khớp';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Text('Cấu hình web', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _webDomainController,
                        decoration: const InputDecoration(
                          labelText: 'Domain web (ví dụ: https://domain.com)',
                          prefixIcon: Icon(Icons.language),
                        ),
                        validator: (v) {
                          // không bắt buộc; nếu điền thì nên hợp lệ cơ bản
                          if (v != null && v.trim().isNotEmpty) {
                            final ok = Uri.tryParse(v.trim()) != null;
                            if (!ok) return 'URL không hợp lệ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Lưu thay đổi'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


