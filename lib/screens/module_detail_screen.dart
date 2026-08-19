import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/dashboard_layout.dart';
import '../data/models/hadith.dart';
import '../data/models/learning_module.dart';
import '../data/repositories/hadith_repository.dart';
import '../services/app_controller.dart';
import '../widgets/app_footer.dart';
import '../widgets/dashboard/dashboard_activity_tile.dart';
import '../widgets/dashboard/islamic_atmosphere.dart';
import '../widgets/dashboard/module_identity.dart';
import 'hadith_screen.dart';

class ModuleDetailScreen extends StatelessWidget {
  const ModuleDetailScreen({required this.module, super.key});

  final LearningModule module;

  @override
  Widget build(BuildContext context) {
    final repository = context.read<HadithRepository>();
    final controller = context.watch<AppController>();
    final progress = controller.moduleProgress(module);
    final scheme = Theme.of(context).colorScheme;

    final hadiths =
        module.hadithNumbers.map((n) => repository.byNumber(n)).toList();

    final completedCount =
        hadiths.where((h) => h != null && controller.isCompleted(h.id)).length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: scheme.onSurface,
        iconTheme: IconThemeData(color: scheme.onSurface),
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
        title: Text('${module.title} · ${module.rangeLabel}'),
      ),
      body: IslamicAtmosphere(
        intensity: 0.7,
        child: Column(
          children: [
            SizedBox(
                height: kToolbarHeight + MediaQuery.of(context).padding.top),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final layout = DashboardLayout.of(constraints);
                  return ListView(
                    padding: layout.pagePadding,
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          width: layout.contentWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _ModuleHero(
                                module: module,
                                progress: progress,
                                completedCount: completedCount,
                                totalCount: module.hadithNumbers.length,
                              ),
                              SizedBox(height: layout.sectionGap),
                              Row(
                                children: [
                                  Icon(Icons.format_list_bulleted_rounded,
                                      size: 18, color: scheme.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Senarai Hadis',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                              SizedBox(height: layout.gap + 4),
                              for (var i = 0; i < hadiths.length; i++)
                                Padding(
                                  padding: EdgeInsets.only(bottom: layout.gap),
                                  child: _HadithCard(
                                    module: module,
                                    number: hadiths[i]?.number ??
                                        (module.startHadith + i),
                                    hadith: hadiths[i],
                                    completed: hadiths[i] != null &&
                                        controller.isCompleted(hadiths[i]!.id),
                                    bookmarked: hadiths[i] != null &&
                                        controller.isBookmarked(hadiths[i]!.id),
                                  ),
                                ),
                              // AppFooter (notis hak cipta) diletakkan di
                              // dalam ListView (bukan sebagai sibling tetap
                              // di bawah Expanded) supaya ia hanya
                              // kelihatan selepas pengguna skrol ke
                              // penghujung senarai hadis, bukan statik
                              // mengganggu paparan sepanjang masa.
                              SizedBox(height: layout.sectionGap),
                              const AppFooter(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
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
    final dark = scheme.brightness == Brightness.dark;
    final accent = ModuleIdentity.accentFor(scheme, module.number);

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? [AppColors.deepEmerald, accent.withValues(alpha: 0.9)]
              : [scheme.primary, Color.lerp(scheme.primary, accent, 0.6)!],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.goldAccent.withValues(alpha: 0.28),
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IslamicCardPattern(
              color: Colors.white,
              seed: module.number,
              opacity: 1.4,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ModuleGlyph(moduleNumber: module.number, size: 56),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          module.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
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
                  ),
                ],
              ),
              const SizedBox(height: 22),
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
              const SizedBox(height: 8),
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
        ],
      ),
    );
  }
}

class _HadithCard extends StatelessWidget {
  const _HadithCard({
    required this.module,
    required this.number,
    required this.hadith,
    required this.completed,
    required this.bookmarked,
  });

  final LearningModule module;
  final int number;
  final Hadith? hadith;
  final bool completed;
  final bool bookmarked;

  @override
  Widget build(BuildContext context) {
    final available = hadith != null;
    final scheme = Theme.of(context).colorScheme;
    final accent = ModuleIdentity.accentFor(scheme, module.number);

    final statusLabel = completed
        ? 'Selesai'
        : available
            ? 'Sedang Dipelajari'
            : 'Akan Datang';
    final statusColor = completed
        ? scheme.primary
        : available
            ? accent
            : scheme.onSurfaceVariant;
    final hasAudio = available && hadith!.audioAsset.isNotEmpty;

    return DashboardActivityTile(
      icon: Icons.auto_stories_rounded,
      leadingLabel: number.toString().padLeft(2, '0'),
      title: available ? hadith!.title : 'Hadis $number',
      subtitle: available ? hadith!.theme : 'Kandungan sedang disediakan.',
      accent: accent,
      onTap: available
          ? () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => HadithScreen(hadith: hadith!),
                ),
              )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
          if (hasAudio) ...[
            const SizedBox(width: 6),
            Icon(Icons.graphic_eq_rounded, size: 14, color: scheme.tertiary),
          ],
          if (completed) ...[
            const SizedBox(width: 6),
            Icon(Icons.check_circle_rounded, size: 14, color: scheme.primary),
          ],
          if (bookmarked) ...[
            const SizedBox(width: 6),
            const Icon(Icons.bookmark_rounded, size: 14, color: AppColors.gold),
          ],
          if (!available) ...[
            const SizedBox(width: 6),
            Icon(Icons.lock_outline_rounded,
                size: 15, color: scheme.onSurfaceVariant),
          ],
        ],
      ),
    );
  }
}
