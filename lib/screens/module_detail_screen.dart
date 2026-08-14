import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/utils/responsive.dart';
import '../data/models/hadith.dart';
import '../data/models/learning_module.dart';
import '../data/repositories/hadith_repository.dart';
import '../services/app_controller.dart';
import '../widgets/app_footer.dart';
import 'hadith_screen.dart';

class ModuleDetailScreen extends StatelessWidget {
  const ModuleDetailScreen({required this.module, super.key});

  final LearningModule module;

  @override
  Widget build(BuildContext context) {
    final repository = context.read<HadithRepository>();
    final controller = context.watch<AppController>();
    final progress = controller.moduleProgress(module);

    final hadiths = module.hadithNumbers
        .map((n) => repository.byNumber(n))
        .toList();

    final completedCount = hadiths
        .where((h) =>
            h != null && controller.isCompleted(h.id))
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${module.title} · ${module.rangeLabel}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: Responsive.pagePadding(context),
              children: [
                Responsive.constrainedPage(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ModuleHero(
                        module: module,
                        progress: progress,
                        completedCount: completedCount,
                        totalCount: module.hadithNumbers.length,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      Text(
                        'Senarai Hadis',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      for (final hadith in hadiths)
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppSpacing.md),
                          child: _HadithCard(
                            number: hadith?.number ??
                                (hadiths.indexOf(hadith) +
                                    module.startHadith),
                            hadith: hadith,
                            completed: hadith != null &&
                                controller.isCompleted(hadith.id),
                            bookmarked: hadith != null &&
                                controller.isBookmarked(hadith.id),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const AppFooter(),
        ],
      ),
    );
  }
}

class _ModuleHero extends StatelessWidget {
  const _ModuleHero({
    required this.module,
    required this.progress,
    required this.completedCount,
    required this.totalCount,
  });

  final LearningModule module;
  final double progress;
  final int completedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary,
            Color.lerp(scheme.primary, scheme.secondary, 0.55)!,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  module.number.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    module.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    module.rangeLabel,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Text(
                '$completedCount / $totalCount selesai',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _HadithCard extends StatelessWidget {
  const _HadithCard({
    required this.number,
    required this.hadith,
    required this.completed,
    required this.bookmarked,
  });

  final int number;
  final Hadith? hadith;
  final bool completed;
  final bool bookmarked;

  @override
  Widget build(BuildContext context) {
    final available = hadith != null;
    final scheme = Theme.of(context).colorScheme;

    final statusLabel = completed
        ? 'Selesai'
        : available
            ? 'Sedang Dipelajari'
            : 'Akan Datang';
    final statusColor = completed
        ? scheme.primary
        : available
            ? scheme.secondary
            : scheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: available
                  ? scheme.primaryContainer
                  : scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              number.toString().padLeft(2, '0'),
              style: TextStyle(
                color: available
                    ? scheme.primary
                    : scheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  available ? hadith!.title : 'Hadis $number',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  available
                      ? hadith!.theme
                      : 'Kandungan sedang disediakan.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (completed) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.check_circle_rounded,
                          size: 14, color: scheme.primary),
                    ],
                    if (bookmarked) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.bookmark_rounded,
                          size: 14, color: AppColors.gold),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          if (available)
            FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => HadithScreen(hadith: hadith!),
                ),
              ),
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: 10),
              ),
              child: const Text('Buka'),
            )
          else
            const Icon(Icons.lock_outline_rounded,
                color: Color(0xFF9AA39F)),
        ],
      ),
    );
  }
}
