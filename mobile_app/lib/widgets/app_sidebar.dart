import 'package:flutter/material.dart';
import '../theme/caothulive_theme.dart';

class AppSidebar extends StatelessWidget {
  final VoidCallback? onClose;
  final Function(String)? onItemTap;

  const AppSidebar({
    super.key,
    this.onClose,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            CaoThuLiveTheme.backgroundDark,
            CaoThuLiveTheme.backgroundCard,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header với logo và close button
            _buildSidebarHeader(context),
            
            const SizedBox(height: 20),
            
            // Menu items
            Expanded(
              child: _buildMenuItems(context),
            ),
            
            // Footer
            _buildSidebarFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Logo
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: CaoThuLiveTheme.primaryRed.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.play_circle_fill,
              color: CaoThuLiveTheme.primaryRed,
              size: 28,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // App name
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CaoThuLive',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'AI Stream Discovery Hub',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Close button
          IconButton(
            onPressed: onClose,
            icon: const Icon(
              Icons.close,
              color: Colors.white70,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final menuItems = [
      {
        'icon': Icons.home,
        'title': 'Trang Chủ',
        'route': '/',
        'color': CaoThuLiveTheme.primaryBlue,
      },
      {
        'icon': Icons.analytics,
        'title': 'Live Analytics',
        'route': '/live-analytics',
        'color': CaoThuLiveTheme.primaryGreen,
      },
      {
        'icon': Icons.newspaper,
        'title': 'Tin Tức',
        'route': '/news',
        'color': CaoThuLiveTheme.primaryOrange,
      },
      {
        'icon': Icons.games,
        'title': 'Mini Games',
        'route': '/mini-games',
        'color': CaoThuLiveTheme.primaryPurple,
      },
      {
        'icon': Icons.emoji_events,
        'title': 'Bảng Xếp Hạng',
        'route': '/game-leaderboard',
        'color': Colors.amber,
      },
      {
        'icon': Icons.format_quote,
        'title': 'Quotes Hàng Ngày',
        'route': '/daily-quotes',
        'color': Colors.indigo,
      },
      {
        'icon': Icons.settings,
        'title': 'Cài Đặt',
        'route': '/settings',
        'color': Colors.grey,
      },
      {
        'icon': Icons.help_outline,
        'title': 'Hỗ Trợ',
        'route': '/support',
        'color': Colors.teal,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _buildMenuItem(
          context,
          icon: item['icon'] as IconData,
          title: item['title'] as String,
          route: item['route'] as String,
          color: item['color'] as Color,
        );
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            onClose?.call();
            onItemTap?.call(route);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Title
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                // Arrow
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Divider
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.2),
          ),
          
          const SizedBox(height: 16),
          
          // Version info
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.white.withOpacity(0.6),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Copyright
          Text(
            '© 2024 CaoThuLive',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
