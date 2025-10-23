import 'package:flutter/material.dart';
import '../theme/caothulive_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _videoNotificationsEnabled = true;
  String _selectedLanguage = 'Tiếng Việt';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CaoThuLiveTheme.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Cài Đặt',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: CaoThuLiveTheme.backgroundDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [

          // Thông báo
          _buildSectionCard(
            title: 'Thông Báo',
            icon: Icons.notifications,
            children: [
              _buildSwitchTile(
                title: 'Thông báo push',
                subtitle: 'Nhận thông báo từ ứng dụng',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                    // Nếu tắt thông báo chính thì tắt luôn thông báo video
                    if (!value) {
                      _videoNotificationsEnabled = false;
                    }
                  });
                },
              ),
              _buildSwitchTile(
                title: 'Thông báo video mới',
                subtitle: 'Thông báo khi có video mới',
                value: _videoNotificationsEnabled,
                enabled: _notificationsEnabled, // Chỉ enable khi thông báo chính bật
                onChanged: (value) {
                  setState(() {
                    _videoNotificationsEnabled = value;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Ngôn ngữ
          _buildSectionCard(
            title: 'Ngôn Ngữ',
            icon: Icons.language,
            children: [
              _buildListTile(
                title: 'Ngôn ngữ',
                subtitle: _selectedLanguage,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showLanguageDialog(),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Lưu trữ
          _buildSectionCard(
            title: 'Lưu Trữ',
            icon: Icons.storage,
            children: [
              _buildListTile(
                title: 'Xóa cache',
                subtitle: 'Xóa dữ liệu tạm thời',
                trailing: const Icon(Icons.delete_outline),
                onTap: () => _showClearCacheDialog(),
              ),
              _buildListTile(
                title: 'Dung lượng sử dụng',
                subtitle: '125 MB',
                trailing: const Icon(Icons.info_outline),
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Về ứng dụng
          _buildSectionCard(
            title: 'Về Ứng Dụng',
            icon: Icons.info,
            children: [
              _buildListTile(
                title: 'Thông tin ứng dụng',
                subtitle: 'CaoThuLive - AI Stream Discovery Hub',
                trailing: const Icon(Icons.info_outline),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      color: CaoThuLiveTheme.backgroundCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, color: CaoThuLiveTheme.primaryRed, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: enabled ? Colors.white : Colors.white54, 
          fontSize: 16
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: enabled ? Colors.white70 : Colors.white38, 
          fontSize: 14
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
        activeColor: CaoThuLiveTheme.primaryRed,
      ),
    );
  }


  Widget _buildListTile({
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CaoThuLiveTheme.backgroundCard,
        title: const Text(
          'Chọn ngôn ngữ',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('Tiếng Việt', 'Tiếng Việt'),
            _buildLanguageOption('English', 'English'),
            _buildLanguageOption('中文', '中文'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String title, String value) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      trailing: _selectedLanguage == value
          ? const Icon(Icons.check, color: CaoThuLiveTheme.primaryRed)
          : null,
      onTap: () {
        setState(() {
          _selectedLanguage = value;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CaoThuLiveTheme.backgroundCard,
        title: const Text(
          'Xóa cache',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Bạn có chắc chắn muốn xóa cache? Điều này sẽ xóa dữ liệu tạm thời và có thể làm chậm ứng dụng lần đầu.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Hủy',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã xóa cache thành công'),
                  backgroundColor: CaoThuLiveTheme.primaryRed,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CaoThuLiveTheme.primaryRed,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
