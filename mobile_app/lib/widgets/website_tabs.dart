import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WebsiteTabs extends StatelessWidget {
  final String activeTab;
  final Function(String) onTabChanged;

  const WebsiteTabs({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.bgWhite,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              context,
              'live',
              'Trực tiếp',
              Icons.mic,
              activeTab == 'live',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTab(
              context,
              'channel',
              'Đăng ký kênh',
              Icons.person_add,
              activeTab == 'channel',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    String tabId,
    String label,
    IconData icon,
    bool isActive,
  ) {
    return GestureDetector(
      onTap: () => onTabChanged(tabId),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryRed : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppTheme.primaryRed : Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : AppTheme.textMuted,
              size: 18,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : AppTheme.textMuted,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
