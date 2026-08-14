import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/curriculum/app_curriculum_structure.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/utils/app_breakpoints.dart';
import '../core/utils/responsive.dart';
import '../data/models/hadith.dart';
import '../data/models/learning_module.dart';
import '../data/repositories/hadith_repository.dart';
import '../data/repositories/module_repository.dart';
import '../services/app_controller.dart';
import '../widgets/app_footer.dart';
import '../widgets/elegant_module_card.dart';
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

    return SingleChildScrollView(
      padding: Responsive.pagePadding(context),
      child: Responsive.constrainedPage(
        child: _DashboardBody(
          controller: controller,
          hadithRepository: hadithRepository,
          modules: modules,
          firstHadith: firstHadith,
          lastHadith: lastHadith,
          onSelectTab: onSelectTab,
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.controller,
    required this.hadithRepository,
    required this.modules,
    required this.firstHadith,
    required this.lastHadith,
    required this.onSelectTab,
  });

  final AppController controller;
  final HadithRepository hadithRepository;
  final List<LearningModule> modules;
  final Hadith firstHadith;
  final Hadith? lastHadith;
  final ValueChanged<int> onSelectTab;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final showInsightPanel = width >= AppBreakpoints.wide;

    final mainContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DashboardHeader(
          onOpenSearch: () => _openSearch(context),
          controller: controller,
        ),
        const SizedBox(height: AppSpacing.xxl),
        _StatsRow(controller: controller, modules: modules),
        const SizedBox(height: AppSpacing.xxl),
        _ContinueLearningCard(
          controller: controller,
          hadith: lastHadith ?? firstHadith,
          hasHistory: lastHadith != null,
          onOpen: (h) => _openHadith(context, h),
        ),
        const SizedBox(height: AppSpacing.xxxl),
        _ModuleSection(
          modules: modules,
          hadithRepository: hadithRepository,
          controller: controller,
          onOpenModule: (m) => _openModule(context, m),
        ),
        // Insight panel dipindahkan ke bawah pada mobile/tablet.
        if (!showInsightPanel) ...[
          const SizedBox(height: AppSpacing.xxxl),
          _InsightPanel(
            controller: controller,
            hadithRepository: hadithRepository,
            modules: modules,
            firstHadith: firstHadith,
            lastHadith: lastHadith,
            onOpenHadith: (h) => _openHadith(context, h),
          ),
        ],
        const SizedBox(height: AppSpacing.xxl),
        _TeacherFeatureCard(
          enabled: controller.teacherMode,
          onToggle: controller.setTeacherMode,
          onProjector: () => _openProjector(context),
        ),
        const SizedBox(height: AppSpacing.lg),
        const AppFooter(),
      ],
    );

    if (!showInsightPanel) {
      return mainContent;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: mainContent),
        const SizedBox(width: AppSpacing.xxl),
        SizedBox(
          width: 320,
          child: _InsightPanel(
            controller: controller,
            hadithRepository: hadithRepository,
            modules: modules,
            firstHadith: firstHadith,
            lastHadith: lastHadith,
            onOpenHadith: (h) => _openHadith(context, h),
          ),
        ),
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

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.onOpenSearch,
    required this.controller,
  });

  final VoidCallback onOpenSearch;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        final greeting = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assalamualaikum 👋',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Selamat Datang ke e-Hadis40',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: isMobile ? 26 : null,
                  ),
            ),
          ],
        );

        final searchBar = _SearchBar(
          onTap: onOpenSearch,
          fullWidth: isMobile,
        );

        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              greeting,
              const SizedBox(height: AppSpacing.xl),
              searchBar,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: greeting),
            const SizedBox(width: AppSpacing.lg),
            searchBar,
          ],
        );
      },
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap, this.fullWidth = false});

  final VoidCallback onTap;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: fullWidth ? 54 : 48,
        width: fullWidth ? double.infinity : 300,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: scheme.onSurfaceVariant),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Cari hadis, tajuk atau perawi...',
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 14,
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

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.controller, required this.modules});

  final AppController controller;
  final List<LearningModule> modules;

  @override
  Widget build(BuildContext context) {
    final completedModules = modules
        .where((m) => controller.moduleProgress(m) >= 1)
        .length;

    final stats = <_Stat>[
      _Stat(
        icon: Icons.task_alt_rounded,
        label: 'Hadis Dipelajari',
        value: '${controller.completed.length}',
        support: '/ ${AppCurriculumStructure.totalHadiths} hadis',
      ),
      _Stat(
        icon: Icons.workspace_premium_rounded,
        label: 'Modul Selesai',
        value: '$completedModules',
        support: '/ ${modules.length} modul',
      ),
      _Stat(
        icon: Icons.bookmark_rounded,
        label: 'Bookmark',
        value: '${controller.bookmarks.length}',
        support: 'hadis disimpan',
      ),
      _Stat(
        icon: Icons.trending_up_rounded,
        label: 'Kemajuan',
        value: '${(controller.overallProgress * 100).round()}%',
        support: 'keseluruhan',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 560
                ? 2
                : constraints.maxWidth >= 320
                    ? 2
                    : 1;
        const gap = 12.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final stat in stats)
              SizedBox(width: width, child: _StatCard(stat: stat)),
          ],
        );
      },
    );
  }
}

class _Stat {
  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
    required this.support,
  });

  final IconData icon;
  final String label;
  final String value;
  final String support;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final _Stat stat;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final compact = MediaQuery.sizeOf(context).width < 600;
    return Container(
      padding: EdgeInsets.all(compact ? AppSpacing.lg : AppSpacing.xl),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(compact ? 18 : 20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: compact ? 32 : 40,
            height: compact ? 32 : 40,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(compact ? 10 : 12),
            ),
            child: Icon(stat.icon,
                color: scheme.primary, size: compact ? 18 : 22),
          ),
          SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
          Text(
            stat.value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: compact ? 30 : null,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            stat.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: compact ? 12 : null,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            stat.support,
            style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: compact ? 11 : 12),
          ),
        ],
      ),
    );
  }
}

class _ContinueLearningCard extends StatelessWidget {
  const _ContinueLearningCard({
    required this.controller,
    required this.hadith,
    required this.hasHistory,
    required this.onOpen,
  });

  final AppController controller;
  final Hadith hadith;
  final bool hasHistory;
  final ValueChanged<Hadith> onOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final compact = MediaQuery.sizeOf(context).width < 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? AppSpacing.xl : AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary,
            Color.lerp(scheme.primary, scheme.secondary, 0.5)!,
          ],
        ),
        borderRadius: BorderRadius.circular(compact ? 24 : 28),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    hasHistory ? 'Sambung Pembelajaran' : 'Mulakan Pembelajaran',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  hasHistory ? 'Hadis ${hadith.displayNumber}' : 'Hadis 01',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: compact ? 24 : null,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  hadith.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton.icon(
                  onPressed: () => onOpen(hadith),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: scheme.primary,
                  ),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(hasHistory ? 'Teruskan' : 'Mula Hadis 1'),
                ),
              ],
            ),
          ),
          if (!compact) ...[
            const SizedBox(width: AppSpacing.xl),
            Icon(
              Icons.auto_stories_rounded,
              size: 96,
              color: Colors.white.withValues(alpha: 0.22),
            ),
          ],
        ],
      ),
    );
  }
}

class _ModuleSection extends StatelessWidget {
  const _ModuleSection({
    required this.modules,
    required this.hadithRepository,
    required this.controller,
    required this.onOpenModule,
  });

  final List<LearningModule> modules;
  final HadithRepository hadithRepository;
  final AppController controller;
  final ValueChanged<LearningModule> onOpenModule;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Modul Pembelajaran',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '42 hadis disusun dalam lapan modul pembelajaran.',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1000
                ? 4
                : constraints.maxWidth >= 380
                    ? 2
                    : 1;
            const gap = 12.0;
            final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final module in modules)
                  SizedBox(
                    width: width,
                    child: ElegantModuleCard(
                      module: module,
                      progress: controller.moduleProgress(module),
                      completedCount: controller.moduleCompletedCount(module),
                      availableCount: hadithRepository.availableHadiths
                          .where(
                            (h) => module.hadithNumbers.contains(h.number),
                          )
                          .length,
                      onTap: () => onOpenModule(module),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _InsightPanel extends StatelessWidget {
  const _InsightPanel({
    required this.controller,
    required this.hadithRepository,
    required this.modules,
    required this.firstHadith,
    required this.lastHadith,
    required this.onOpenHadith,
  });

  final AppController controller;
  final HadithRepository hadithRepository;
  final List<LearningModule> modules;
  final Hadith firstHadith;
  final Hadith? lastHadith;
  final ValueChanged<Hadith> onOpenHadith;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final percent = (controller.overallProgress * 100).round();

    final bookmarkedHadiths = controller.bookmarks
        .map((id) => hadithRepository.byId(id))
        .whereType<Hadith>()
        .take(3)
        .toList();

    return Column(
      children: [
        _PanelCard(
          child: Column(
            children: [
              SizedBox(
                width: 96,
                height: 96,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 96,
                      height: 96,
                      child: CircularProgressIndicator(
                        value: controller.overallProgress,
                        strokeWidth: 9,
                        backgroundColor: scheme.surfaceContainerHighest,
                      ),
                    ),
                    Text(
                      '$percent%',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Kemajuan Keseluruhan',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '${controller.completed.length} / ${AppCurriculumStructure.totalHadiths} hadis selesai',
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _PanelCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.history_rounded, color: scheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Terakhir Dibaca',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (lastHadith != null)
                InkWell(
                  onTap: () => onOpenHadith(lastHadith!),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: scheme.primaryContainer,
                          child: Text(
                            lastHadith!.displayNumber,
                            style: TextStyle(
                              color: scheme.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            lastHadith!.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Text(
                  'Mulakan Hadis 1 untuk merekod kemajuan.',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _PanelCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.bookmark_rounded, color: scheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Bookmark Terkini',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (bookmarkedHadiths.isEmpty)
                Text(
                  'Belum ada hadis disimpan.',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                )
              else
                for (final hadith in bookmarkedHadiths)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: InkWell(
                      onTap: () => onOpenHadith(hadith),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.bookmark_rounded,
                            color: AppColors.gold,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${hadith.displayNumber} · ${hadith.title}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PanelCard extends StatelessWidget {
  const _PanelCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: child,
    );
  }
}

class _TeacherFeatureCard extends StatelessWidget {
  const _TeacherFeatureCard({
    required this.enabled,
    required this.onToggle,
    required this.onProjector,
  });

  final bool enabled;
  final ValueChanged<bool> onToggle;
  final VoidCallback onProjector;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: scheme.secondary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.co_present_rounded,
                  color: scheme.onSecondary, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mod Guru & Projektor',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Paparan sesuai untuk pengajaran di kelas dan tayangan skrin besar.',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: isMobile ? 12 : 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: isMobile ? AppSpacing.md : AppSpacing.lg),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Mod Guru', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 4),
                Switch(value: enabled, onChanged: onToggle),
              ],
            ),
            OutlinedButton.icon(
              onPressed: onProjector,
              icon: const Icon(Icons.present_to_all_rounded, size: 18),
              label: const Text('Buka Projektor'),
            ),
          ],
        ),
      ],
    );

    return Container(
      padding: EdgeInsets.all(isMobile ? AppSpacing.lg : AppSpacing.xl),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(isMobile ? 18 : 20),
      ),
      child: content,
    );
  }
}

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
