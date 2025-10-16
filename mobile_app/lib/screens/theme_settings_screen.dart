import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt giao diện'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Theme Mode Section
              _buildSection(
                context,
                title: 'Chế độ hiển thị',
                icon: Icons.palette,
                children: [
                  _buildThemeModeTile(
                    context,
                    themeProvider,
                    ThemeMode.light,
                    'Sáng',
                    Icons.light_mode,
                    'Giao diện sáng, phù hợp ban ngày',
                  ),
                  _buildThemeModeTile(
                    context,
                    themeProvider,
                    ThemeMode.dark,
                    'Tối',
                    Icons.dark_mode,
                    'Giao diện tối, tiết kiệm pin',
                  ),
                  _buildThemeModeTile(
                    context,
                    themeProvider,
                    ThemeMode.system,
                    'Hệ thống',
                    Icons.brightness_auto,
                    'Tự động theo cài đặt hệ thống',
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Accent Color Section
              _buildSection(
                context,
                title: 'Màu chủ đạo',
                icon: Icons.color_lens,
                children: [
                  _buildAccentColorGrid(context, themeProvider),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Font Size Section
              _buildSection(
                context,
                title: 'Kích thước chữ',
                icon: Icons.text_fields,
                children: [
                  _buildFontSizeSlider(context, themeProvider),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Preview Section
              _buildSection(
                context,
                title: 'Xem trước',
                icon: Icons.preview,
                children: [
                  _buildPreviewCard(context, themeProvider),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildThemeModeTile(
    BuildContext context,
    ThemeProvider themeProvider,
    ThemeMode mode,
    String title,
    IconData icon,
    String subtitle,
  ) {
    final isSelected = themeProvider.themeMode == mode;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade300,
            ),
          ),
          child: Icon(
            icon,
            color: isSelected 
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: isSelected 
            ? Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              )
            : null,
        onTap: () => themeProvider.setThemeMode(mode),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: isSelected 
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
            : null,
      ),
    );
  }

  Widget _buildAccentColorGrid(BuildContext context, ThemeProvider themeProvider) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: ThemeProvider.accentColors.length,
      itemBuilder: (context, index) {
        final color = ThemeProvider.accentColors[index];
        final isSelected = themeProvider.accentColor == color;
        
        return GestureDetector(
          onTap: () => themeProvider.setAccentColor(color),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: isSelected
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 24,
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildFontSizeSlider(BuildContext context, ThemeProvider themeProvider) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Nhỏ',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              themeProvider.fontSizeName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              'Lớn',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        Slider(
          value: themeProvider.fontSize,
          min: 0.8,
          max: 1.4,
          divisions: 6,
          activeColor: Theme.of(context).colorScheme.primary,
          onChanged: (value) => themeProvider.setFontSize(value),
        ),
      ],
    );
  }

  Widget _buildPreviewCard(BuildContext context, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: themeProvider.accentColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Video mẫu',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: (Theme.of(context).textTheme.titleMedium?.fontSize ?? 16) * themeProvider.fontSize,
                      ),
                    ),
                    Text(
                      'Kênh YouTube • 2 giờ trước',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: (Theme.of(context).textTheme.bodySmall?.fontSize ?? 12) * themeProvider.fontSize,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Đây là mô tả video mẫu để bạn có thể xem trước giao diện với các cài đặt hiện tại.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14) * themeProvider.fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
