import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/caothulive_theme.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CaoThuLiveTheme.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Hỗ Trợ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: CaoThuLiveTheme.backgroundDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeaderCard(),
            
            const SizedBox(height: 20),
            
            // Liên hệ nhanh
            _buildQuickContactCard(),
            
            const SizedBox(height: 20),
            
            // Form liên hệ
            _buildContactFormCard(),
            
            const SizedBox(height: 20),
            
            // FAQ
            _buildFAQCard(),
            
            const SizedBox(height: 20),
            
            // Thông tin liên hệ
            _buildContactInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      color: CaoThuLiveTheme.backgroundCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: CaoThuLiveTheme.primaryRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.support_agent,
                color: CaoThuLiveTheme.primaryRed,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chúng tôi ở đây để giúp bạn!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Có câu hỏi hoặc cần hỗ trợ? Hãy liên hệ với chúng tôi.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickContactCard() {
    return Card(
      color: CaoThuLiveTheme.backgroundCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Liên Hệ Nhanh',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildQuickContactItem(
              icon: Icons.email,
              title: 'Email',
              subtitle: 'support@caothulive.com',
              onTap: () => _launchEmail(),
            ),
            _buildQuickContactItem(
              icon: Icons.phone,
              title: 'Điện thoại',
              subtitle: '+84 123 456 789',
              onTap: () => _launchPhone(),
            ),
            _buildQuickContactItem(
              icon: Icons.chat,
              title: 'Chat trực tuyến',
              subtitle: 'Hỗ trợ 24/7',
              onTap: () => _showChatDialog(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: CaoThuLiveTheme.primaryRed),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white70),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
      onTap: onTap,
    );
  }

  Widget _buildContactFormCard() {
    return Card(
      color: CaoThuLiveTheme.backgroundCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gửi Tin Nhắn',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nameController,
              label: 'Họ và tên',
              hint: 'Nhập họ và tên của bạn',
            ),
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'Nhập email của bạn',
              keyboardType: TextInputType.emailAddress,
            ),
            _buildTextField(
              controller: _subjectController,
              label: 'Chủ đề',
              hint: 'Nhập chủ đề tin nhắn',
            ),
            _buildTextField(
              controller: _messageController,
              label: 'Nội dung',
              hint: 'Nhập nội dung tin nhắn',
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CaoThuLiveTheme.primaryRed,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Gửi Tin Nhắn',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: Colors.white70),
          hintStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: CaoThuLiveTheme.backgroundDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: CaoThuLiveTheme.primaryRed),
          ),
        ),
      ),
    );
  }

  Widget _buildFAQCard() {
    return Card(
      color: CaoThuLiveTheme.backgroundCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Câu Hỏi Thường Gặp',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFAQItem(
              question: 'Làm thế nào để tải video?',
              answer: 'Bạn có thể tải video bằng cách nhấn vào nút "Tải xuống" trên video.',
            ),
            _buildFAQItem(
              question: 'Ứng dụng có miễn phí không?',
              answer: 'Có, ứng dụng hoàn toàn miễn phí với tất cả tính năng.',
            ),
            _buildFAQItem(
              question: 'Làm thế nào để báo lỗi?',
              answer: 'Bạn có thể báo lỗi qua form liên hệ hoặc email support@caothulive.com.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            answer,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfoCard() {
    return Card(
      color: CaoThuLiveTheme.backgroundCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông Tin Liên Hệ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildContactInfoItem(
              icon: Icons.business,
              title: 'Công ty',
              content: 'CaoThuLive Technology',
            ),
            _buildContactInfoItem(
              icon: Icons.location_on,
              title: 'Địa chỉ',
              content: 'Hà Nội, Việt Nam',
            ),
            _buildContactInfoItem(
              icon: Icons.schedule,
              title: 'Giờ làm việc',
              content: '24/7 - Hỗ trợ liên tục',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoItem({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: CaoThuLiveTheme.primaryRed, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_nameController.text.isEmpty || 
        _emailController.text.isEmpty || 
        _subjectController.text.isEmpty || 
        _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Simulate sending message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tin nhắn đã được gửi thành công!'),
        backgroundColor: CaoThuLiveTheme.primaryRed,
      ),
    );

    // Clear form
    _nameController.clear();
    _emailController.clear();
    _subjectController.clear();
    _messageController.clear();
  }

  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@caothulive.com',
      query: 'subject=Hỗ trợ từ ứng dụng CaoThuLive',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể mở ứng dụng email'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+84123456789');
    
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể mở ứng dụng điện thoại'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CaoThuLiveTheme.backgroundCard,
        title: const Text(
          'Chat Trực Tuyến',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Tính năng chat trực tuyến sẽ được phát triển trong phiên bản tiếp theo.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: CaoThuLiveTheme.primaryRed,
            ),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}