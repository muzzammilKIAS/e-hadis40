import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/responsive.dart';
import '../services/app_controller.dart';
import '../services/global_audio_controller.dart';
import '../widgets/dashboard/islamic_atmosphere.dart';
import 'bookmarks_screen.dart';
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

  static const _destinations = <_ShellDestination>[
    _ShellDestination(Icons.space_dashboard_rounded, 'Dashboard'),
    _ShellDestination(Icons.grid_view_rounded, 'Modul'),
    _ShellDestination(Icons.bookmark_rounded, 'Bookmark'),
    _ShellDestination(Icons.headphones_rounded, 'Audio'),
    _ShellDestination(Icons.settings_rounded, 'Tetapan'),
  ];

  @override
  Widget build(BuildContext context) {
    final desktop = Responsive.isDesktop(context);
    final scheme = Theme.of(context).colorScheme;

    final pages = <Widget>[
      HomeScreen(onSelectTab: _selectTab),
      const ModulesScreen(),
      const BookmarksScreen(),
      const HadithPlaylistScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: IslamicAtmosphere(
        child: desktop
            ? Row(
                children: [
                  _DashboardSidebar(
                    selectedIndex: _selectedIndex,
                    destinations: _destinations,
                    onSelect: _selectTab,
                  ),
                  Container(
                      width: 1,
                      color: scheme.outlineVariant.withValues(alpha: 0.6)),
                  Expanded(
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: pages,
                    ),
                  ),
                ],
              )
            : SafeArea(
                bottom: false,
                child: IndexedStack(index: _selectedIndex, children: pages),
              ),
      ),
      bottomNavigationBar: desktop
          ? null
          : _MobileNavBar(
              selectedIndex: _selectedIndex,
              destinations: _destinations,
              onSelect: _selectTab,
            ),
    );
  }

  void _selectTab(int index) {
    setState(() => _selectedIndex = index);
  }
}

class _MobileNavBar extends StatelessWidget {
  const _MobileNavBar({
    required this.selectedIndex,
    required this.destinations,
    required this.onSelect,
  });

  final int selectedIndex;
  final List<_ShellDestination> destinations;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = scheme.brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        decoration: BoxDecoration(
          color: dark ? scheme.surface.withValues(alpha: 0.96) : scheme.surface,
          border: Border(
            top: BorderSide(
              color: scheme.outlineVariant.withValues(alpha: dark ? 0.6 : 1),
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onSelect,
          height: 68,
          backgroundColor: Colors.transparent,
          indicatorColor: scheme.primaryContainer,
          labelTextStyle: WidgetStatePropertyAll(
            TextStyle(
              color: scheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
          destinations: [
            for (final item in destinations)
              NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.icon, color: scheme.primary),
                label: item.label,
              ),
          ],
        ),
      ),
    );
  }
}

class _DashboardSidebar extends StatefulWidget {
  const _DashboardSidebar({
    required this.selectedIndex,
    required this.destinations,
    required this.onSelect,
  });

  final int selectedIndex;
  final List<_ShellDestination> destinations;
  final ValueChanged<int> onSelect;

  @override
  State<_DashboardSidebar> createState() => _DashboardSidebarState();
}

class _DashboardSidebarState extends State<_DashboardSidebar> {
  // Sidebar bermula dalam keadaan dikecilkan (ikon sahaja) setiap kali
  // aplikasi diakses — pengguna boleh mengembangkannya semula dengan
  // menekan togol jika perlu, tetapi ia tidak lagi terus mengembang
  // secara automatik pada setiap muatan halaman.
  bool _collapsed = true;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = scheme.brightness == Brightness.dark;
    final collapsed = _collapsed;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: collapsed ? 92 : 264,
      color: dark
          ? scheme.surface.withValues(alpha: 0.92)
          : scheme.surface.withValues(alpha: 0.96),
      child: Column(
        children: [
          SizedBox(
            height: 88,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: collapsed ? 18 : 20,
                vertical: 16,
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/e_hadis40_logo_official.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  if (!collapsed) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            AppConstants.appName,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                          Text(
                            'Pembelajaran Hadis',
                            style: TextStyle(
                              fontSize: 11,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Divider(
              height: 1, color: scheme.outlineVariant.withValues(alpha: 0.6)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              children: [
                for (var i = 0; i < widget.destinations.length; i++)
                  _SidebarItem(
                    destination: widget.destinations[i],
                    selected: widget.selectedIndex == i,
                    collapsed: collapsed,
                    onTap: () => widget.onSelect(i),
                  ),
              ],
            ),
          ),
          Divider(
              height: 1, color: scheme.outlineVariant.withValues(alpha: 0.6)),
          SizedBox(
            height: 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              // `FittedBox` — apabila audio sedang dimainkan, kawalan
              // audio menambah 3 butang ikon (sebelum/jeda/seterusnya) di
              // samping togol kecilkan dan menu tema. Jumlah lebar butang
              // tidak muat dalam lajur sisi 264px, menyebabkan jalur
              // amaran kuning-hitam. `FittedBox` menjamin baris ini
              // sentiasa muat, mengecil sedikit jika perlu.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    _CollapseToggle(
                      collapsed: collapsed,
                      onToggle: () => setState(() => _collapsed = !_collapsed),
                    ),
                    if (!collapsed) ...[
                      const SizedBox(width: 4),
                      const _AudioAppBarControls(),
                      const _ThemeModeMenu(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  const _SidebarItem({
    required this.destination,
    required this.selected,
    required this.collapsed,
    required this.onTap,
  });

  final _ShellDestination destination;
  final bool selected;
  final bool collapsed;
  final VoidCallback onTap;

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selected = widget.selected;
    // Ikon/label sendiri kini turut bertukar warna semasa hover (bukan
    // hanya latar) — sebelum ini hanya latar berubah pada alpha yang
    // sangat pudar (0.35), jadi kesan hover mudah tersasar pandangan dan
    // rasa "tidak berfungsi" walaupun ia sebenarnya aktif.
    final fg =
        (selected || _hovered) ? scheme.primary : scheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            color: selected
                ? scheme.primaryContainer
                : _hovered
                    ? scheme.primaryContainer.withValues(alpha: 0.65)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(14),
              child: Tooltip(
                message: widget.collapsed ? widget.destination.label : '',
                waitDuration: const Duration(milliseconds: 300),
                child: SizedBox(
                  height: 48,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.collapsed ? 0 : 16,
                    ),
                    child: Row(
                      mainAxisAlignment: widget.collapsed
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                      children: [
                        Icon(widget.destination.icon, color: fg, size: 22),
                        if (!widget.collapsed) ...[
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              widget.destination.label,
                              style: TextStyle(
                                color: fg,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (selected)
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CollapseToggle extends StatelessWidget {
  const _CollapseToggle({required this.collapsed, required this.onToggle});

  final bool collapsed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: onToggle,
      tooltip: collapsed ? 'Kembangkan' : 'Kecilkan',
      icon: Icon(
        collapsed ? Icons.menu_rounded : Icons.menu_open_rounded,
        color: scheme.onSurfaceVariant,
        size: 22,
      ),
    );
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

class _AudioAppBarControls extends StatelessWidget {
  const _AudioAppBarControls();

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<GlobalHadithAudioController>();

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (audio.playing) ...[
            IconButton(
              tooltip: 'Hadis sebelumnya',
              onPressed: audio.hasPrev ? audio.previous : null,
              icon: const Icon(Icons.skip_previous_rounded, size: 20),
            ),
            IconButton(
              tooltip: 'Berhenti',
              onPressed: audio.togglePlay,
              icon: const Icon(Icons.pause_rounded, size: 20),
            ),
            IconButton(
              tooltip: 'Hadis seterusnya',
              onPressed: audio.hasNext ? audio.next : null,
              icon: const Icon(Icons.skip_next_rounded, size: 20),
            ),
          ],
          IconButton(
            tooltip: 'Pemain Audio',
            onPressed: () => _openPlaylist(context),
            icon: const Icon(Icons.headphones_rounded),
          ),
        ],
      ),
    );
  }

  static void _openPlaylist(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const HadithPlaylistScreen()),
    );
  }
}
