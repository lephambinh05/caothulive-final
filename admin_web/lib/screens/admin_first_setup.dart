import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminFirstSetupScreen extends StatefulWidget {
  const AdminFirstSetupScreen({super.key});

  @override
  State<AdminFirstSetupScreen> createState() => _AdminFirstSetupScreenState();
}

class _AdminFirstSetupScreenState extends State<AdminFirstSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _createFirstAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Double-check that there is still no admin to avoid race condition
      final adminsSnap = await FirebaseFirestore.instance.collection('admins').limit(1).get();
      if (adminsSnap.docs.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã có admin, vui lòng đăng nhập.')),
          );
        }
        if (mounted) Navigator.of(context).pop();
        return;
      }

      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create admin profile doc
      await FirebaseFirestore.instance.collection('admins').doc(cred.user!.uid).set({
        'email': email,
        'created_at': FieldValue.serverTimestamp(),
        'role': 'owner',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tạo admin thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Done: back to app (AuthWrapper will route to dashboard since signed in)
      if (mounted) Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      String message = 'Tạo tài khoản thất bại';
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Email đã được sử dụng';
          break;
        case 'invalid-email':
          message = 'Email không hợp lệ';
          break;
        case 'weak-password':
          message = 'Mật khẩu quá yếu (ít nhất 6 ký tự)';
          break;
        case 'operation-not-allowed':
          message = 'Sign-up bằng Email/Password chưa bật';
          break;
      }
      final detailed = '${message}\n(code: ${e.code}${e.message != null ? ', ${e.message}' : ''})';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(detailed), backgroundColor: Colors.red, duration: const Duration(seconds: 6)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Có lỗi xảy ra\n${e.toString()}'), backgroundColor: Colors.red, duration: const Duration(seconds: 6)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thiết lập admin lần đầu'),
        centerTitle: true,
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Tạo tài khoản admin đầu tiên',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chỉ hiển thị một lần khi dự án chưa có admin.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Nhập email';
                      if (!RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(value)) return 'Email không hợp lệ';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Mật khẩu',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Nhập mật khẩu';
                      if (value.length < 6) return 'Ít nhất 6 ký tự';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      label: Text(_obscurePassword ? 'Hiện mật khẩu' : 'Ẩn mật khẩu'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _createFirstAdmin,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Tạo admin'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


