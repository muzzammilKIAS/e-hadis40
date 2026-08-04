import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_spacing.dart';
import '../core/utils/responsive.dart';
import 'elegant_islamic_backdrop.dart';

class LearningHeroBanner extends StatelessWidget {
  const LearningHeroBanner({
    required this.progress,
    required this.onContinue,
    required this.onViewModules,
    super.key,
  });

  final double progress;
  final VoidCallback onContinue;
  final VoidCallback onViewModules;

  @override
  Widget build(BuildContext context) {
    final desktop = Responsive.isDesktop(context);
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: onPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: onPrimary.withValues(alpha: 0.15)),
          ),
          child: Text(
            AppConstants.appShortDescription,
            style: TextStyle(
              color: onPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Hayati Hadis, Bina Peribadi',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: onPrimary,
                fontSize: desktop ? 42 : 32,
                height: 1.15,
              ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Pelajari dan fahami Modul Penghayatan Hadis 40 Imam '
          'al-Nawawi melalui pengalaman pembelajaran yang tersusun, '
          'menarik dan mudah difahami.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: onPrimary.withValues(alpha: 0.82),
                height: 1.6,
              ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: onContinue,
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Sambung Pembelajaran'),
            ),
            OutlinedButton.icon(
              onPressed: onViewModules,
              style: OutlinedButton.styleFrom(
                foregroundColor: onPrimary,
                side: BorderSide(color: onPrimary.withValues(alpha: 0.5)),
              ),
              icon: const Icon(Icons.grid_view_rounded),
              label: const Text('Lihat Semua Modul'),
            ),
          ],
        ),
      ],
    );

    return ElegantIslamicBackdrop(
      padding: EdgeInsets.all(desktop ? 38 : 24),
      child: desktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 7, child: content),
                const SizedBox(width: 36),
                Expanded(
                  flex: 3,
                  child: _HeroProgress(progress: progress),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                content,
                const SizedBox(height: 28),
                _HeroProgress(progress: progress),
              ],
            ),
    );
  }
}

class _HeroProgress extends StatelessWidget {
  const _HeroProgress({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final percent = (progress * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: onPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: onPrimary.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.menu_book_rounded, color: onPrimary, size: 36),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            '$percent%',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: onPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Progres keseluruhan',
            style: TextStyle(color: onPrimary.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: AppSpacing.xl),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              color: Theme.of(context).colorScheme.secondary,
              backgroundColor: onPrimary.withValues(alpha: 0.15),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Teruskan secara konsisten, satu hadis pada satu masa.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: onPrimary.withValues(alpha: 0.68),
                  height: 1.45,
                ),
          ),
        ],
      ),
    );
  }
}
