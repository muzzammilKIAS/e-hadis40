import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/curriculum/app_curriculum_structure.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/dashboard_layout.dart';
import '../data/models/hadith.dart';
import '../data/models/learning_module.dart';
import '../data/repositories/hadith_repository.dart';
import '../data/repositories/module_repository.dart';
import '../services/app_controller.dart';
import '../widgets/app_footer.dart';
import '../widgets/dashboard/continue_learning_card.dart';
import '../widgets/dashboard/dashboard_activity_tile.dart';
import '../widgets/dashboard/glass_surface.dart';
import '../widgets/dashboard/learning_progress_card.dart';
import '../widgets/dashboard/module_identity.dart';
import '../widgets/dashboard/module_learning_card.dart';
import 'anatomi_sunnah_list_screen.dart';
import 'hadith_screen.dart';
import 'module_detail_screen.dart';
import 'projector_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.onSelectTab, super.key});

  final ValueChanged<int> onSelectTab;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final hadithRepository = context.read<HadithRepository>();
    final modules = context.read<ModuleRepository>().modules;
    final firstHadith = hadithRepository.byNumber(1)!;
    final lastHadith = controller.lastHadithId == null
        ? null
        : hadithRepository.byId(controller.lastHadithId!);

    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = DashboardLayout.of(constraints);
        return SingleChildScrollView(
          // `MainShell` menetapkan `extendBody: true`, jadi badan skrin
          // memanjang ke BELAKANG bar navigasi bawah. Tanpa tambahan ini,
          // hujung footer (butang "Tentang Aplikasi") kekal tersembunyi di
          // belakang bar itu walaupun sudah skrol habis.
          padding: layout.pagePadding.copyWith(
            bottom: layout.pagePadding.bottom +
                MediaQuery.paddingOf(context).bottom,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: layout.contentWidth,
              child: _DashboardBody(
                layout: layout,
                controller: controller,
                hadithRepository: hadithRepository,
                modules: modules,
                firstHadith: firstHadith,
                lastHadith: lastHadith,
                onSelectTab: onSelectTab,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.layout,
    required this.controller,
    required this.hadithRepository,
    required this.modules,
    required this.firstHadith,
    required this.lastHadith,
    required this.onSelectTab,
  });

  final DashboardLayout layout;
  final AppController controller;
  final HadithRepository hadithRepository;
  final List<LearningModule> modules;
  final Hadith firstHadith;
  final Hadith? lastHadith;
  final ValueChanged<int> onSelectTab;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DashboardHeader(
          layout: layout,
          controller: controller,
          onOpenSearch: () => _openSearch(context),
          onOpenAnatomiSunnah: () => _openAnatomiSunnah(context),
        ),
        SizedBox(height: layout.sectionGap),
        _OverviewRow(
          layout: layout,
          controller: controller,
          modules: modules,
          hadith: lastHadith ?? firstHadith,
          hasHistory: lastHadith != null,
          onOpenHadith: (hadith) => _openHadith(context, hadith),
        ),
        SizedBox(height: layout.sectionGap),
        _ModuleSection(
          layout: layout,
          modules: modules,
          hadithRepository: hadithRepository,
          controller: controller,
          onOpenModule: (module) => _openModule(context, module),
          onSeeAll: () => onSelectTab(1),
        ),
        SizedBox(height: layout.sectionGap),
        _ActivitySection(
          layout: layout,
          controller: controller,
          hadithRepository: hadithRepository,
          lastHadith: lastHadith,
          onOpenHadith: (hadith) => _openHadith(context, hadith),
          onOpenProjector: () => _openProjector(context),
        ),
        const SizedBox(height: 18),
        const AppFooter(),
      ],
    );
  }

  void _openHadith(BuildContext context, Hadith hadith) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => HadithScreen(hadith: hadith)),
    );
  }

  void _openModule(BuildContext context, LearningModule module) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ModuleDetailScreen(module: module),
      ),
    );
  }

  void _openProjector(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProjectorScreen(
          hadith: firstHadith,
          repository: hadithRepository,
        ),
      ),
    );
  }

  void _openAnatomiSunnah(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AnatomiSunnahListScreen(),
      ),
    );
  }

  Future<void> _openSearch(BuildContext context) async {
    final repo = context.read<HadithRepository>();
    final selected = await showSearch<Hadith?>(
      context: context,
      delegate: _DashboardSearchDelegate(repo),
    );
    if (!context.mounted || selected == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => HadithScreen(hadith: selected)),
    );
  }
}

// ───────────────────────────── Header ─────────────────────────────

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.layout,
    required this.controller,
    required this.onOpenSearch,
    required this.onOpenAnatomiSunnah,
  });

  final DashboardLayout layout;
  final AppController controller;
  final VoidCallback onOpenSearch;
  final VoidCallback onOpenAnatomiSunnah;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final greeting = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Assalamualaikum',
              style: text.bodyMedium?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            const Text('👋', style: TextStyle(fontSize: 14)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Selamat Datang ke ${AppConstants.appName}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: text.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: layout.isCompact ? 25 : 31,
            height: 1.15,
          ),
        ),
      ],
    );

    final search = _DashboardSearchField(onTap: onOpenSearch);

    // Mod gelap/cerah yang SEDANG dipaparkan — apabila `themeMode` diikat
    // kepada sistem, kita rujuk kecerahan yang telah diselesaikan
    // (`Theme.of(context).brightness`) supaya ikon sentiasa menggambarkan
    // rupa sebenar skrin, bukan tetapan mentah `ThemeMode.system` itu
    // sendiri.
    final isDark = controller.themeMode == ThemeMode.dark ||
        (controller.themeMode == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);

    final quickIcons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _HeaderIconButton(
          icon: Icons.view_in_ar_rounded,
          tooltip: 'Anatomi Hadis',
          onTap: onOpenAnatomiSunnah,
        ),
        const SizedBox(width: 10),
        _HeaderIconButton(
          // Togol ini sengaja HANYA bertukar antara `ThemeMode.light` dan
          // `ThemeMode.dark` (dua mod sahaja apabila ditekan) — pilihan
          // "Ikut Sistem" kekal tersedia di skrin Tetapan/sidebar sebagai
          // mod lalai di sebalik tabir, bukan sebahagian daripada kitaran
          // togol pantas ini.
          icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          tooltip: isDark ? 'Tukar ke Mod Cerah' : 'Tukar ke Mod Gelap',
          onTap: () => controller
              .setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark),
        ),
      ],
    );

    // Baris dikongsi hanya apabila ruang mencukupi — pada lebar sempit tajuk
    // sentiasa mendapat lebar penuh supaya tidak tersepit.
    if (!layout.inlineSearch) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: greeting),
              const SizedBox(width: 12),
              quickIcons,
            ],
          ),
          const SizedBox(height: 18),
          search,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: greeting),
        const SizedBox(width: 16),
        quickIcons,
        const SizedBox(width: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340, minWidth: 240),
          child: search,
        ),
      ],
    );
  }
}

/// Ikon kecil laluan pantas di header dashboard (Anatomi Hadis, Mod
/// Projektor) — pengganti kad besar `_TeacherFeatureCard`/`_AnatomiSunnahCard`
/// yang sebelum ini menuntut ruang penuh satu seksyen setiap satu. Togol
/// "Mod Guru" sendiri kekal di skrin Tetapan; ikon ini hanya laluan pantas
/// untuk membuka paparan berkaitan terus dari dashboard.
class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = scheme.brightness == Brightness.dark;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: scheme.primary.withValues(alpha: dark ? 0.22 : 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: scheme.primary.withValues(alpha: 0.32)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              icon,
              size: 21,
              color: dark ? scheme.tertiary : scheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardSearchField extends StatefulWidget {
  const _DashboardSearchField({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_DashboardSearchField> createState() => _DashboardSearchFieldState();
}

class _DashboardSearchFieldState extends State<_DashboardSearchField> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = scheme.brightness == Brightness.dark;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: dark
                ? scheme.surface.withValues(alpha: _hovered ? 0.95 : 0.72)
                : scheme.surface,
            border: Border.all(
              color: _hovered
                  ? (dark
                      ? AppColors.darkGold.withValues(alpha: 0.85)
                      : scheme.primary.withValues(alpha: 0.6))
                  : scheme.outlineVariant.withValues(alpha: dark ? 0.6 : 1),
            ),
            boxShadow: _hovered && dark
                ? [
                    BoxShadow(
                      color: AppColors.darkGold.withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                size: 20,
                color: _hovered
                    ? (dark ? AppColors.darkGold : scheme.primary)
                    : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Cari hadis, tajuk atau perawi...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────── Kemajuan + hero ─────────────────────────

class _OverviewRow extends StatelessWidget {
  const _OverviewRow({
    required this.layout,
    required this.controller,
    required this.modules,
    required this.hadith,
    required this.hasHistory,
    required this.onOpenHadith,
  });

  final DashboardLayout layout;
  final AppController controller;
  final List<LearningModule> modules;
  final Hadith hadith;
  final bool hasHistory;
  final ValueChanged<Hadith> onOpenHadith;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final completedModules =
        modules.where((m) => controller.moduleProgress(m) >= 1).length;
    final moduleProgress =
        modules.isEmpty ? 0.0 : completedModules / modules.length;

    final hadithCard = LearningProgressCard(
      icon: Icons.menu_book_rounded,
      label: 'Hadis Dipelajari',
      value: controller.completed.length,
      total: AppCurriculumStructure.totalHadiths,
      unit: 'hadis',
      progress: controller.overallProgress,
      compact: layout.isCompact,
    );

    final moduleCard = LearningProgressCard(
      icon: Icons.workspace_premium_rounded,
      label: 'Modul Selesai',
      value: completedModules,
      total: AppCurriculumStructure.totalModules,
      unit: 'modul',
      progress: moduleProgress,
      accent: scheme.tertiary,
      compact: layout.isCompact,
    );

    final progressGroup = layout.sideBySideProgress
        ? IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: hadithCard),
                SizedBox(width: layout.gap),
                Expanded(child: moduleCard),
              ],
            ),
          )
        : Column(
            children: [
              hadithCard,
              SizedBox(height: layout.gap),
              moduleCard,
            ],
          );

    final hero = ContinueLearningCard(
      badgeLabel: hasHistory ? 'Sambung Pembelajaran' : 'Mulakan Pembelajaran',
      headline: 'Hadis ${hasHistory ? hadith.displayNumber : '01'}',
      title: hadith.title,
      footnote: hadith.theme.isEmpty ? null : hadith.theme,
      actionLabel: hasHistory ? 'Teruskan' : 'Mula Hadis 1',
      onAction: () => onOpenHadith(hadith),
      // `wide` diikat kepada `heroBesideProgress` (bukan ambang lebar
      // 480px bebas) supaya kad ini kekal SAMA gaya (susun atur, saiz
      // fon, padding) pada telefon dan tablet — kedua-duanya berada
      // dalam mod "stacked" yang sama. Sebelum ini, tablet (contentWidth
      // sering > 480) tiba-tiba beralih ke gaya "wide" bersama ilustrasi
      // kitab, manakala telefon kekal gaya padat — dua saiz/gaya yang
      // tidak sekata bagi konteks susun atur yang sepatutnya serupa.
      wide: layout.heroBesideProgress,
    );

    if (!layout.heroBesideProgress) {
      // Kad "Sambung Pembelajaran" (hero) diletakkan DAHULU, betul-betul
      // di bawah tajuk/carian — bukan selepas kad statistik — supaya
      // pengguna terus nampak tindakan seterusnya sebaik membuka
      // dashboard, sebelum melihat statistik kemajuan.
      //
      // `crossAxisAlignment.stretch` WAJIB di sini — `hero` ialah
      // `AnimatedContainer` yang tiada lebar dipaksa, jadi di bawah
      // `Column` lalai (center), ia mengecut mengikut kandungannya
      // sendiri dan kelihatan lebih kecil (bercelah kosong kiri/kanan)
      // berbanding kad statistik di bawahnya, yang kebetulan sentiasa
      // memenuhi lebar penuh kerana `Row` sememangnya menuntut lebar
      // maksimum secara lalai. `stretch` menjadikan kedua-duanya sama
      // lebar dengan carian/tajuk di atas, konsisten pada mod tablet
      // mahupun telefon.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          hero,
          SizedBox(height: layout.gap),
          progressGroup,
        ],
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 5, child: progressGroup),
          SizedBox(width: layout.gap),
          Expanded(flex: 4, child: hero),
        ],
      ),
    );
  }
}

// ────────────────────────── Modul section ─────────────────────────

class _ModuleSection extends StatelessWidget {
  const _ModuleSection({
    required this.layout,
    required this.modules,
    required this.hadithRepository,
    required this.controller,
    required this.onOpenModule,
    required this.onSeeAll,
  });

  final DashboardLayout layout;
  final List<LearningModule> modules;
  final HadithRepository hadithRepository;
  final AppController controller;
  final ValueChanged<LearningModule> onOpenModule;
  final VoidCallback onSeeAll;

  /// Bilangan modul yang dipaparkan sebagai pratonton di dashboard.
  ///
  /// Memaparkan kesemua 8 modul menjadikan dashboard terlalu panjang pada
  /// telefon (satu lajur = 8 kad tinggi berturut-turut). Kita hadkan kepada
  /// baris yang lengkap sahaja; senarai penuh sentiasa boleh dicapai melalui
  /// "Lihat semua".
  int _previewCount(int columns) {
    final count = switch (columns) {
      1 => 3, // telefon — pratonton ringkas
      2 => 4, // 2 baris
      3 => 6, // 2 baris
      _ => modules.length, // 4 lajur: 2 baris sudah muat kesemuanya
    };
    return count.clamp(0, modules.length);
  }

  @override
  Widget build(BuildContext context) {
    final columns = layout.moduleColumns;
    final width = layout.itemWidth(columns);

    final shown = _previewCount(columns);
    final preview = modules.take(shown).toList();
    final remaining = modules.length - shown;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSectionHeader(
          title: 'Modul Pembelajaran',
          subtitle: remaining > 0
              ? 'Memaparkan $shown daripada '
                  '${AppCurriculumStructure.totalModules} modul '
                  '(${AppCurriculumStructure.totalHadiths} hadis).'
              : '${AppCurriculumStructure.totalHadiths} hadis disusun '
                  'dalam ${AppCurriculumStructure.totalModules} modul.',
          actionLabel: 'Lihat semua',
          onAction: onSeeAll,
        ),
        SizedBox(height: layout.gap + 4),
        Wrap(
          spacing: layout.gap,
          runSpacing: layout.gap,
          children: [
            for (final module in preview)
              SizedBox(
                width: width,
                child: ModuleLearningCard(
                  module: module,
                  compact: layout.compactModuleCards,
                  progress: controller.moduleProgress(module),
                  completedCount: controller.moduleCompletedCount(module),
                  availableCount: hadithRepository.availableHadiths
                      .where((h) => module.hadithNumbers.contains(h.number))
                      .length,
                  onTap: () => onOpenModule(module),
                ),
              ),
          ],
        ),
        if (remaining > 0) ...[
          SizedBox(height: layout.gap),
          _SeeMoreModulesButton(remaining: remaining, onTap: onSeeAll),
        ],
      ],
    );
  }
}

/// Butang lebar penuh di bawah pratonton modul — memberi laluan kedua yang
/// jelas ke senarai penuh (selain pautan "Lihat semua" di kepala seksyen),
/// tepat di tempat pengguna berhenti menatal.
class _SeeMoreModulesButton extends StatelessWidget {
  const _SeeMoreModulesButton({required this.remaining, required this.onTap});

  final int remaining;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.outlineVariant),
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lihat $remaining modul lagi',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded,
                      size: 18, color: scheme.primary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Aktiviti section ───────────────────────

class _ActivitySection extends StatelessWidget {
  const _ActivitySection({
    required this.layout,
    required this.controller,
    required this.hadithRepository,
    required this.lastHadith,
    required this.onOpenHadith,
    required this.onOpenProjector,
  });

  final DashboardLayout layout;
  final AppController controller;
  final HadithRepository hadithRepository;
  final Hadith? lastHadith;
  final ValueChanged<Hadith> onOpenHadith;
  final VoidCallback onOpenProjector;

  @override
  Widget build(BuildContext context) {
    final bookmarked = controller.bookmarks
        .map(hadithRepository.byId)
        .whereType<Hadith>()
        .take(3)
        .toList();

    final panels = <Widget>[
      _ActivityPanel(
        icon: Icons.history_rounded,
        title: 'Terakhir Dibaca',
        child: lastHadith == null
            ? const _PanelEmpty(
                message: 'Mulakan Hadis 1 untuk merekod kemajuan anda.',
              )
            : DashboardActivityTile(
                icon: Icons.auto_stories_rounded,
                leadingLabel: lastHadith!.displayNumber,
                title: lastHadith!.title,
                subtitle: lastHadith!.theme.isEmpty ? null : lastHadith!.theme,
                onTap: () => onOpenHadith(lastHadith!),
              ),
      ),
      _ActivityPanel(
        icon: Icons.bookmark_rounded,
        iconColor: AppColors.gold,
        title: 'Hadis Pilihan',
        badge: controller.bookmarks.isEmpty
            ? null
            : '${controller.bookmarks.length}',
        child: bookmarked.isEmpty
            ? const _PanelEmpty(message: 'Belum ada hadis disimpan.')
            : Column(
                children: [
                  for (var i = 0; i < bookmarked.length; i++) ...[
                    if (i > 0) const SizedBox(height: 8),
                    DashboardActivityTile(
                      dense: true,
                      icon: Icons.bookmark_rounded,
                      leadingLabel: bookmarked[i].displayNumber,
                      title: bookmarked[i].title,
                      accent: AppColors.gold,
                      onTap: () => onOpenHadith(bookmarked[i]),
                    ),
                  ],
                ],
              ),
      ),
      _ActivityPanel(
        icon: Icons.co_present_rounded,
        title: 'Mod Projektor',
        child: DashboardActivityTile(
          icon: Icons.co_present_rounded,
          title: 'Buka Mod Projektor',
          subtitle: 'Paparan untuk pengajaran & skrin besar',
          onTap: onOpenProjector,
        ),
      ),
    ];

    // Tiga kotak (Terakhir Dibaca, Hadis Pilihan, Mod Projektor) mesti
    // kekal SAMA besar (lebar & tinggi) apabila disusun sebaris — `Wrap`
    // sahaja tidak menyamakan tinggi antara item dalam baris yang sama,
    // jadi kita guna `Row` + `IntrinsicHeight` + `Expanded` (stretch)
    // apabila ruang cukup untuk ketiga-tiganya sebaris; pada skrin sempit
    // (satu lajur) ia disusun menegak dan lebar penuh secara semula jadi.
    if (layout.panelColumns >= 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardSectionHeader(
            title: 'Aktiviti Pembelajaran',
            subtitle: 'Teruskan dari tempat anda berhenti.',
          ),
          SizedBox(height: layout.gap + 4),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < panels.length; i++) ...[
                  if (i > 0) SizedBox(width: layout.gap),
                  Expanded(child: panels[i]),
                ],
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DashboardSectionHeader(
          title: 'Aktiviti Pembelajaran',
          subtitle: 'Teruskan dari tempat anda berhenti.',
        ),
        SizedBox(height: layout.gap + 4),
        for (var i = 0; i < panels.length; i++) ...[
          if (i > 0) SizedBox(height: layout.gap),
          panels[i],
        ],
      ],
    );
  }
}

class _ActivityPanel extends StatelessWidget {
  const _ActivityPanel({
    required this.icon,
    required this.title,
    required this.child,
    this.iconColor,
    this.badge,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final Color? iconColor;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tone = iconColor ?? scheme.primary;

    return GlassSurface(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: tone),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              if (badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: tone.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      color: tone,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _PanelEmpty extends StatelessWidget {
  const _PanelEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Text(
        message,
        style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12.5),
      ),
    );
  }
}

// ─────────────────────────── Carian ───────────────────────────────

class _DashboardSearchDelegate extends SearchDelegate<Hadith?> {
  _DashboardSearchDelegate(this.repository)
      : super(searchFieldLabel: 'Cari nombor, tajuk, tema atau perawi');

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
        final moduleId = AppCurriculumStructure.moduleIdFor(hadith.number);
        final moduleNumber = int.parse(moduleId.substring(moduleId.length - 2));
        return DashboardActivityTile(
          icon: Icons.auto_stories_rounded,
          leadingLabel: hadith.displayNumber,
          title: hadith.title,
          subtitle: hadith.theme.isEmpty ? null : hadith.theme,
          accent: ModuleIdentity.accentFor(
            Theme.of(context).colorScheme,
            moduleNumber,
          ),
          onTap: () => close(context, hadith),
        );
      },
    );
  }
}
