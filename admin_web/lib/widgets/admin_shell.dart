import 'package:flutter/material.dart';
import '../main.dart';

class AdminShell extends StatelessWidget {
  final String title;
  final List<String>? breadcrumbs;
  final String? subtitle;
  final Widget body;
  final List<Widget>? actions;
  final Widget? search;
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;

  const AdminShell({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.search,
    this.selectedIndex = 0,
    this.onDestinationSelected,
    this.breadcrumbs,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 1000;
    final showRail = size.width >= 800;

    final rail = NavigationRail(
      extended: size.width >= 1200,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: size.width >= 1200
          ? NavigationRailLabelType.none
          : (isWide ? NavigationRailLabelType.none : NavigationRailLabelType.selected),
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Admin Panel',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ),
      destinations: const [
        NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Dashboard')),
        NavigationRailDestination(icon: Icon(Icons.download_outlined), selectedIcon: Icon(Icons.download), label: Text('Downloads')),
        NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: Text('Cài đặt')),
        NavigationRailDestination(icon: Icon(Icons.support_agent_outlined), selectedIcon: Icon(Icons.support_agent), label: Text('Hỗ trợ')),
      ],
      trailing: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: IconButton(
          tooltip: 'Bật/tắt Dark mode',
          icon: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.dark_mode : Icons.light_mode),
          onPressed: () => AppTheme.of(context)?.toggleThemeMode(),
        ),
      ),
    );

    final header = Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!showRail)
                Builder(
                  builder: (ctx) => IconButton(
                    tooltip: 'Menu',
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (breadcrumbs != null && breadcrumbs!.isNotEmpty) ...[
                      Wrap(
                        spacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          for (int i = 0; i < breadcrumbs!.length; i++) ...[
                            Text(
                              breadcrumbs![i],
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (i < breadcrumbs!.length - 1)
                              Icon(Icons.chevron_right, size: 16, color: Theme.of(context).hintColor),
                          ]
                        ],
                      ),
                      const SizedBox(height: 6),
                    ],
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
                    ],
                    const SizedBox(height: 10),
                    if (search != null)
                      SizedBox(
                        height: 44,
                        child: Align(alignment: Alignment.centerLeft, child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 680), child: search!)),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (actions != null)
                Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.end, children: actions!),
            ],
          ),
        ),
      ),
    );

    final content = Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Card(
            child: body,
          ),
        ),
      ),
    );

    return Scaffold(
      drawer: showRail
          ? null
          : Drawer(
              child: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text('Admin Panel', style: Theme.of(context).textTheme.titleLarge),
                    ),
                    ListTile(
                      leading: const Icon(Icons.dashboard_outlined),
                      title: const Text('Dashboard'),
                      selected: selectedIndex == 0,
                      onTap: () {
                        Navigator.of(context).pop();
                        onDestinationSelected?.call(0);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.download_outlined),
                      title: const Text('Downloads'),
                      selected: selectedIndex == 1,
                      onTap: () {
                        Navigator.of(context).pop();
                        onDestinationSelected?.call(1);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings_outlined),
                      title: const Text('Cài đặt'),
                      selected: selectedIndex == 2,
                      onTap: () {
                        Navigator.of(context).pop();
                        onDestinationSelected?.call(2);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.support_agent_outlined),
                      title: const Text('Hỗ trợ'),
                      selected: selectedIndex == 3,
                      onTap: () {
                        Navigator.of(context).pop();
                        onDestinationSelected?.call(3);
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.dark_mode : Icons.light_mode),
                      title: const Text('Dark mode'),
                      onTap: () {
                        AppTheme.of(context)?.toggleThemeMode();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ),
      body: SafeArea(
        child: Row(
          children: [
            if (showRail) ...[
              rail,
              const VerticalDivider(width: 1),
            ],
            Expanded(
              child: Column(
                children: [
                  header,
                  Expanded(child: content),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


