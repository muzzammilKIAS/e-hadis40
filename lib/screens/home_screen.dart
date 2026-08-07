import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
import '../widgets/learning_hero_banner.dart';
import '../widgets/progress_overview.dart';
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
        ? firstHadith
        : hadithRepository.byId(controller.lastHadithId!) ?? firstHadith;

    return SingleChildScrollView(
      padding: Responsive.pagePadding(context),
      child: Responsive.constrainedPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LearningHeroBanner(
              progress: controller.overallProgress,
              onContinue: () => _openHadith(context, lastHadith),
              onViewModules: () => onSelectTab(1),
            ),
            const SizedBox(height: AppSpacing.xxl),
            ProgressOverview(
              completedHadiths: controller.completed.length,
              bookmarks: controller.bookmarks.length,
              bestScore: controller.bestScore(firstHadith.id),
              teacherMode: controller.teacherMode,
            ),
            const SizedBox(height: AppSpacing.xxxl),
            _SectionHeading(
              title: 'Sambung pembelajaran',
              subtitle: 'Kandungan terakhir yang tersedia untuk dipelajari.',
              actionLabel: 'Buka modul',
              onAction: () => _openModule(context, modules.first),
            ),
            const SizedBox(height: AppSpacing.lg),
            _ContinueLearningCard(
              hadith: lastHadith,
              controller: controller,
              onOpen: () => _openHadith(context, lastHadith),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            _SectionHeading(
              title: 'Modul pembelajaran',
              subtitle: '40 hadis disusun dalam lapan modul pembelajaran.',
              actionLabel: 'Lihat semua',
              onAction: () => onSelectTab(1),
            ),
            const SizedBox(height: AppSpacing.lg),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = Responsive.gridColumns(context);
                const gap = 16.0;
                final cardWidth =
                    (constraints.maxWidth - gap * (columns - 1)) / columns;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final module in modules.take(4))
                      SizedBox(
                        width: cardWidth,
                        child: ElegantModuleCard(
                          module: module,
                          progress: controller.moduleProgress(module),
                          availableCount: hadithRepository.availableHadiths
                              .where(
                                (hadith) => module.hadithNumbers
                                    .contains(hadith.number),
                              )
                              .length,
                          onTap: () => _openModule(context, module),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.xxxl),
            _TeacherFeatureCard(
              enabled: controller.teacherMode,
              onToggle: controller.setTeacherMode,
              onProjector: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ProjectorScreen(
                    hadith: firstHadith,
                    repository: hadithRepository,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const AppFooter(),
          ],
        ),
      ),
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
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        TextButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }
}

class _ContinueLearningCard extends StatelessWidget {
  const _ContinueLearningCard({
    required this.hadith,
    required this.controller,
    required this.onOpen,
  });

  final Hadith hadith;
  final AppController controller;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final completed = controller.isCompleted(hadith.id);
    final score = controller.bestScore(hadith.id);

    return Card(
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < AppBreakpoints.cardCompact;
              final information = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text('Hadis ${hadith.displayNumber}')),
                      Chip(
                        avatar: Icon(
                          completed
                              ? Icons.check_circle_rounded
                              : Icons.timelapse_rounded,
                          size: 16,
                        ),
                        label:
                            Text(completed ? 'Selesai' : 'Sedang dipelajari'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    hadith.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    hadith.subtitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Wrap(
                    spacing: 20,
                    runSpacing: 10,
                    children: [
                      _InlineStat(
                        icon: Icons.auto_awesome_rounded,
                        text: hadith.theme,
                      ),
                      _InlineStat(
                        icon: Icons.workspace_premium_outlined,
                        text: score == 0
                            ? 'Kuiz belum dijawab'
                            : 'Markah terbaik $score%',
                      ),
                    ],
                  ),
                ],
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    information,
                    const SizedBox(height: AppSpacing.xl),
                    FilledButton.icon(
                      onPressed: onOpen,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Buka Hadis'),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: information),
                  const SizedBox(width: AppSpacing.xxl),
                  FilledButton.icon(
                    onPressed: onOpen,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Buka Hadis'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _InlineStat extends StatelessWidget {
  const _InlineStat({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 6),
        Flexible(child: Text(text)),
      ],
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
    return Card(
      color: scheme.secondaryContainer.withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact =
                constraints.maxWidth < AppBreakpoints.cardHorizontal;
            final info = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: scheme.secondary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child:
                      Icon(Icons.co_present_rounded, color: scheme.onSecondary),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mod Guru & Projektor',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Aktifkan paparan yang lebih sesuai untuk pengajaran '
                        'di kelas dan tayangan pada skrin besar.',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            );

            final actions = Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Switch(value: enabled, onChanged: onToggle),
                Text(enabled ? 'Mod Guru aktif' : 'Mod Pelajar'),
                OutlinedButton.icon(
                  onPressed: onProjector,
                  icon: const Icon(Icons.present_to_all_rounded),
                  label: const Text('Buka Projektor'),
                ),
              ],
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  info,
                  const SizedBox(height: AppSpacing.xl),
                  actions,
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: info),
                const SizedBox(width: AppSpacing.xl),
                actions,
              ],
            );
          },
        ),
      ),
    );
  }
}
