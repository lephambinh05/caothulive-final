import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';

class WebsiteHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSupportTap;
  final bool showSupportButton;

  const WebsiteHeader({
    super.key,
    required this.title,
    this.onSupportTap,
    this.showSupportButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.headerGradient,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SafeArea(
        child: Row(
          children: [
            // Logo/Brand
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.play_circle_filled,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'YouTube',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Quản lý video YouTube',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Theme Toggle Button
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    onPressed: () => themeProvider.toggleTheme(),
                    icon: Icon(
                      themeProvider.themeIcon,
                      color: Colors.white,
                      size: 20,
                    ),
                    tooltip: 'Chuyển đổi giao diện (${themeProvider.themeModeName})',
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            // Settings Button
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                onPressed: () => Navigator.pushNamed(context, '/theme-settings'),
                icon: const Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 20,
                ),
                tooltip: 'Cài đặt giao diện',
              ),
            ),
            const SizedBox(width: 8),
            // Support Button
            if (showSupportButton)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  onPressed: onSupportTap,
                  icon: const Icon(
                    Icons.support_agent,
                    color: Colors.white,
                    size: 20,
                  ),
                  tooltip: 'Hỗ trợ',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
