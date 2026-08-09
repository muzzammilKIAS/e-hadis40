import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/app_breakpoints.dart';
import '../core/utils/responsive.dart';
import '../data/models/hadith.dart';
import '../data/repositories/hadith_repository.dart';
import '../services/app_controller.dart';
import '../widgets/mini_player.dart';
import 'bookmarks_screen.dart';
import 'hadith_screen.dart';
import 'home_screen.dart';
import 'modules_screen.dart';
import 'hadith_playlist_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  bool _disclaimerShown = false;

  static const _destinations = <_ShellDestination>[
    _ShellDestination(Icons.home_rounded, 'Utama'),
    _ShellDestination(Icons.grid_view_rounded, 'Modul'),
    _ShellDestination(Icons.bookmark_rounded, 'Pilihan'),
    _ShellDestination(Icons.settings_rounded, 'Tetapan'),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_disclaimerShown) {
      _disclaimerShown = true;
      final controller = context.read<AppController>();
      if (!controller.disclaimerAccepted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showDisclaimer(context, controller);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final desktop = Responsive.isDesktop(context);
    final scheme = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;

    final pages = <Widget>[
      HomeScreen(onSelectTab: _selectTab),
      const ModulesScreen(),
      const BookmarksScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: desktop ? 28 : 12,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/logo_e_hadis40.png',
                width: 42,
                height: 42,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (width >= AppBreakpoints.appBarSubtitle)
                    Text(
                      AppConstants.appShortDescription,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Tooltip(
            message: 'Buka pemain audio',
            child: IconButton(
              onPressed: _openPlaylist,
              icon: const Icon(Icons.headphones_rounded),
            ),
          ),
          Tooltip(
            message: 'Cari hadis',
            child: IconButton(
              onPressed: _openSearch,
              icon: const Icon(Icons.search_rounded),
            ),
          ),
          const _ThemeModeMenu(),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: desktop
                ? Row(
                    children: [
                      NavigationRail(
                        selectedIndex: _selectedIndex,
                        onDestinationSelected: _selectTab,
                        labelType: NavigationRailLabelType.all,
                        groupAlignment: -0.88,
                        indicatorColor: scheme.primaryContainer,
                        destinations: [
                          for (final item in _destinations)
                            NavigationRailDestination(
                              icon: Icon(item.icon),
                              selectedIcon:
                                  Icon(item.icon, color: scheme.primary),
                              label: Text(item.label),
                            ),
                        ],
                      ),
                      VerticalDivider(
                          width: 1, color: scheme.outlineVariant),
                      Expanded(
                        child: IndexedStack(
                          index: _selectedIndex,
                          children: pages,
                        ),
                      ),
                    ],
                  )
                : IndexedStack(index: _selectedIndex, children: pages),
          ),
          const MiniPlayer(),
        ],
      ),
      bottomNavigationBar: desktop
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MiniPlayer(),
                NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _selectTab,
                  height: 72,
                  indicatorColor: scheme.primaryContainer,
                  labelTextStyle: WidgetStatePropertyAll(
                    TextStyle(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  destinations: [
                    for (final item in _destinations)
                      NavigationDestination(
                        icon: Icon(item.icon),
                        selectedIcon:
                            Icon(item.icon, color: scheme.primary),
                        label: item.label,
                      ),
                  ],
                ),
              ],
            ),
    );
  }

  void _selectTab(int index) {
    setState(() => _selectedIndex = index);
  }

  void _openPlaylist() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const HadithPlaylistScreen()),
    );
  }

  Future<void> _openSearch() async {
    final repository = context.read<HadithRepository>();
    final selected = await showSearch<Hadith?>(
      context: context,
      delegate: _HadithSearchDelegate(repository),
    );
    if (!mounted || selected == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => HadithScreen(hadith: selected)),
    );
  }

  Future<void> _showDisclaimer(
      BuildContext context, AppController controller) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return AlertDialog(
          title: const Text('Makluman Prototaip'),
          content: Text(
            'e-Hadis40 ialah prototaip pembelajaran interaktif yang '
            'dibangunkan berasaskan Modul Penghayatan Hadis 40 Imam Nawawi '
            'Edisi Kedua. Aplikasi ini bukan aplikasi rasmi Kementerian '
            'Pendidikan Malaysia.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  color: scheme.onSurface,
                ),
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Saya Faham'),
            ),
          ],
        );
      },
    );
    if (mounted) {
      await controller.acceptDisclaimer();
    }
  }
}

class _ShellDestination {
  const _ShellDestination(this.icon, this.label);

  final IconData icon;
  final String label;
}

class _ThemeModeMenu extends StatelessWidget {
  const _ThemeModeMenu();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final icon = switch (controller.themeMode) {
      ThemeMode.light => Icons.light_mode_rounded,
      ThemeMode.dark => Icons.dark_mode_rounded,
      ThemeMode.system => Icons.settings_suggest_rounded,
    };

    return PopupMenuButton<ThemeMode>(
      tooltip: 'Pilih tema',
      initialValue: controller.themeMode,
      onSelected: controller.setThemeMode,
      icon: Icon(icon),
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: ThemeMode.system,
          child: ListTile(
            leading: Icon(Icons.settings_suggest_rounded),
            title: Text('Ikut Sistem'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.light,
          child: ListTile(
            leading: Icon(Icons.light_mode_rounded),
            title: Text('Mod Cerah'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.dark,
          child: ListTile(
            leading: Icon(Icons.dark_mode_rounded),
            title: Text('Mod Gelap'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

class _HadithSearchDelegate extends SearchDelegate<Hadith?> {
  _HadithSearchDelegate(this.repository)
      : super(searchFieldLabel: 'Cari nombor, tajuk, tema atau nilai');

  final HadithRepository repository;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          tooltip: 'Kosongkan carian',
          onPressed: () => query = '',
          icon: const Icon(Icons.clear_rounded),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Kembali',
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back_rounded),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _results(context);

  @override
  Widget buildSuggestions(BuildContext context) => _results(context);

  Widget _results(BuildContext context) {
    final results = repository.search(query);
    if (results.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Tiada hadis tersedia yang sepadan dengan carian.'),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final hadith = results[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(child: Text(hadith.displayNumber)),
            title: Text(hadith.title),
            subtitle: Text(hadith.theme),
            trailing: const Icon(Icons.arrow_forward_rounded),
            onTap: () => close(context, hadith),
          ),
        );
      },
    );
  }
}
