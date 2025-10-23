import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/caothulive_theme.dart';
import '../providers/theme_provider.dart';
import 'sidebar_drawer.dart';

class WebsiteHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSupportTap;
  final bool showSupportButton;
  final Function(String)? onRouteChanged;

  const WebsiteHeader({
    super.key,
    required this.title,
    this.onSupportTap,
    this.showSupportButton = true,
    this.onRouteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SidebarDrawer(
      onRouteChanged: onRouteChanged,
      child: Container(
        decoration: BoxDecoration(
          gradient: CaoThuLiveTheme.headerGradient,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Centered title and logo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.play_circle_fill,
                      color: CaoThuLiveTheme.primaryRed,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title
                  const Text(
                    'CaoThuLive',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Subtitle
              const Text(
                'AI Stream Discovery Hub',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}