import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_spacing.dart';
import '../core/utils/app_breakpoints.dart';
import '../core/utils/responsive.dart';
import '../data/models/hadith.dart';
import '../data/repositories/hadith_repository.dart';
import '../data/repositories/narrator_repository.dart';
import '../services/app_controller.dart';
import '../widgets/synced_hadith_reader.dart';
import '../widgets/app_footer.dart';
import '../widgets/hadith_section.dart';
import '../widgets/narrator_info_trigger.dart';
import 'projector_screen.dart';
import 'quiz_screen.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({required this.hadith, super.key});

  final Hadith hadith;

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    final controller = context.read<AppController>();
    _noteController = TextEditingController(
      text: controller.noteFor(widget.hadith.id),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.markOpened(widget.hadith.id);
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final hadith = widget.hadith;
    final completed = controller.isCompleted(hadith.id);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hadis ${hadith.displayNumber} · ${hadith.title}'),
        actions: [
          if (controller.teacherMode)
            Tooltip(
              message: 'Mod Projektor',
              child: IconButton(
                onPressed: () {
                  final repo = context.read<HadithRepository>();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ProjectorScreen(
                        hadith: hadith,
                        repository: repo,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.present_to_all_rounded),
              ),
            ),
          Tooltip(
            message: controller.isBookmarked(hadith.id)
                ? 'Buang daripada Hadis Pilihan'
                : 'Simpan sebagai Hadis Pilihan',
            child: IconButton(
              onPressed: () => controller.toggleBookmark(hadith.id),
              isSelected: controller.isBookmarked(hadith.id),
              icon: Icon(
                controller.isBookmarked(hadith.id)
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: Responsive.pagePadding(context),
        child: Responsive.constrainedPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HadithHero(hadith: hadith, completed: completed),
              if (hadith.learningObjectives.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                HadithSection(
                  title: 'Objektif Pembelajaran',
                  icon: Icons.track_changes_rounded,
                  child: ElegantBulletList(items: hadith.learningObjectives),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              HadithSection(
                title: 'Baca Bersama Audio',
                subtitle:
                    'Teks Arab akan diserlahkan dan paparan bergerak mengikut rakaman bacaan.',
                icon: Icons.record_voice_over_rounded,
                accent: true,
                trailing: Wrap(
                  spacing: 4,
                  children: [
                    Tooltip(
                      message: 'Kecilkan tulisan Arab',
                      child: IconButton(
                        onPressed: controller.arabicScale <= 0.8
                            ? null
                            : () => controller.setArabicScale(
                                  controller.arabicScale - 0.1,
                                ),
                        icon: const Icon(Icons.text_decrease_rounded),
                      ),
                    ),
                    Tooltip(
                      message: 'Besarkan tulisan Arab',
                      child: IconButton(
                        onPressed: controller.arabicScale >= 1.6
                            ? null
                            : () => controller.setArabicScale(
                                  controller.arabicScale + 0.1,
                                ),
                        icon: const Icon(Icons.text_increase_rounded),
                      ),
                    ),
                  ],
                ),
                child: SyncedHadithReader(
                  hadith: hadith,
                  textScale: controller.arabicScale,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              HadithSection(
                title: 'Maksud Hadis',
                icon: Icons.translate_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      hadith.translationMalay,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (hadith.audioTranscriptNote.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: scheme.secondaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 18,
                              color: scheme.onSecondaryContainer,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                hadith.audioTranscriptNote,
                                style: TextStyle(
                                  color: scheme.onSecondaryContainer,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (hadith.narratorId != null &&
                  context.read<NarratorRepository>().byId(hadith.narratorId!) !=
                      null)
                HadithSection(
                  title: 'Kenali Perawi',
                  icon: Icons.person_search_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Arahkan penuding tetikus atau tekan nama perawi:',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      NarratorInfoTrigger(narrator: hadith.narrator),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        hadith.reference,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.xl),
              HadithSection(
                title: 'Huraian Hadis',
                icon: Icons.auto_stories_rounded,
                child: ElegantBulletList(items: hadith.explanations),
              ),
              if (hadith.supportingExample != null) ...[
                const SizedBox(height: AppSpacing.xl),
                HadithSection(
                  title: hadith.supportingExample!.title,
                  subtitle: hadith.supportingExample!.reference,
                  icon: Icons.history_edu_rounded,
                  accent: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hadith.supportingExample!.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (hadith.supportingExample!.sourceNote.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          hadith.supportingExample!.sourceNote,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              if (hadith.contextNotice.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                HadithSection(
                  title: 'Peringatan Penting',
                  icon: Icons.info_outline_rounded,
                  child: Text(
                    hadith.contextNotice,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.7,
                          color: scheme.onSurface,
                        ),
                  ),
                ),
              ],
              if (hadith.allQuranEvidences.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                for (var i = 0; i < hadith.allQuranEvidences.length; i++) ...[
                  HadithSection(
                    title: i == 0 ? 'Dalil al-Quran' : 'Dalil al-Quran',
                    subtitle: 'Surah ${hadith.allQuranEvidences[i].surah}, '
                        '${hadith.allQuranEvidences[i].verseLabel}',
                    icon: Icons.menu_book_rounded,
                    accent: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (hadith.allQuranEvidences[i].arabicText.isNotEmpty) ...[
                          SizedBox(
                            width: double.infinity,
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: Text(
                                hadith.allQuranEvidences[i].arabicText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22 * controller.arabicScale,
                                  height: 2.0,
                                  fontFamily: AppConstants.arabicFontFamily,
                                  fontFamilyFallback: AppConstants.arabicFontFallback,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                        if (hadith.allQuranEvidences[i].translationMalay.isNotEmpty)
                          Text(
                            '"${hadith.allQuranEvidences[i].translationMalay}"',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  height: 1.8,
                                ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ],
              if (hadith.learningIntentionExample.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                HadithSection(
                  title: 'Contoh Niat Menuntut Ilmu',
                  icon: Icons.school_rounded,
                  child: Text(
                    hadith.learningIntentionExample,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
              if (hadith.supplications.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                HadithSection(
                  title: 'Doa Pilihan',
                  icon: Icons.hail_rounded,
                  child: Column(
                    children: [
                      for (final dua in hadith.supplications)
                        _SupplicationCard(dua: dua),
                    ],
                  ),
                ),
              ],
              if (hadith.supplementaryHadiths.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                HadithSection(
                  title: 'Hadis Berkaitan Rahmat Allah',
                  icon: Icons.collections_bookmark_rounded,
                  child: Column(
                    children: [
                      for (final h in hadith.supplementaryHadiths)
                        _SupplementaryHadithCard(hadith: h),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              HadithSection(
                title: 'Pengajaran',
                icon: Icons.lightbulb_rounded,
                child: ElegantBulletList(items: hadith.lessons),
              ),
              const SizedBox(height: AppSpacing.xl),
              HadithSection(
                title: 'Penghayatan',
                icon: Icons.volunteer_activism_rounded,
                child: ElegantBulletList(items: hadith.appreciation),
              ),
              const SizedBox(height: AppSpacing.xl),
              HadithSection(
                title: 'Fokus Nilai',
                icon: Icons.diamond_outlined,
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final value in hadith.focusValues)
                      Chip(
                        avatar:
                            const Icon(Icons.auto_awesome_rounded, size: 16),
                        label: Text(value),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              HadithSection(
                title: 'Cadangan Aktiviti',
                icon: Icons.groups_rounded,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const gap = 12.0;
                    final columns =
                        constraints.maxWidth >= AppBreakpoints.grid3Col ? 3 : 1;
                    final width =
                        (constraints.maxWidth - gap * (columns - 1)) / columns;
                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        for (final activity in hadith.activities)
                          SizedBox(
                            width: width,
                            child: _ActivityTile(activity: activity),
                          ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              HadithSection(
                title: 'Soalan Refleksi',
                subtitle: 'Fikirkan jawapan sebelum menulis nota peribadi.',
                icon: Icons.psychology_alt_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElegantBulletList(items: hadith.reflectionQuestions),
                    const SizedBox(height: AppSpacing.xl),
                    TextField(
                      controller: _noteController,
                      minLines: 4,
                      maxLines: 8,
                      decoration: const InputDecoration(
                        labelText: 'Nota refleksi peribadi',
                        hintText: 'Tulis refleksi anda di sini…',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: () => _saveNote(context, controller),
                        icon: const Icon(Icons.save_rounded),
                        label: const Text('Simpan Nota'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _QuizCallToAction(hadith: hadith, controller: controller),
              const SizedBox(height: AppSpacing.xl),
              _CompletionCard(
                completed: completed,
                onComplete: () => _complete(context, controller),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (hadith.sourceNote.isNotEmpty)
                Text(
                  'Nota penerbitan: ${hadith.sourceNote}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              const SizedBox(height: AppSpacing.xxl),
              _HadithPrevNext(
                hadith: hadith,
                repository: context.read<HadithRepository>(),
              ),
              const AppFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveNote(BuildContext context, AppController controller) async {
    await controller.saveNote(widget.hadith.id, _noteController.text);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nota refleksi telah disimpan.')),
      );
    }
  }

  Future<void> _complete(BuildContext context, AppController controller) async {
    await controller.markCompleted(widget.hadith.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hadis telah ditandakan selesai.')),
      );
    }
  }
}

class _HadithHero extends StatelessWidget {
  const _HadithHero({required this.hadith, required this.completed});

  final Hadith hadith;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.primaryContainer.withValues(alpha: 0.4),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(AppSpacing.lg),
              ),
              child: Text(
                hadith.displayNumber,
                style: TextStyle(
                  color: scheme.onPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xl),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      Chip(label: Text(hadith.theme)),
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
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    hadith.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    hadith.subtitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity});

  final HadithActivity activity;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.group_work_rounded, color: scheme.primary),
          const SizedBox(height: AppSpacing.md),
          Text(activity.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(activity.description),
        ],
      ),
    );
  }
}

class _QuizCallToAction extends StatelessWidget {
  const _QuizCallToAction({required this.hadith, required this.controller});

  final Hadith hadith;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final score = controller.bestScore(hadith.id);
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < AppBreakpoints.grid2Col;
            final text = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Uji Kefahaman',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  score == 0
                      ? '${hadith.quiz.length} soalan · Lulus ${hadith.passingScorePercent}%'
                      : 'Markah terbaik: $score% · Lulus ${hadith.passingScorePercent}%',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ],
            );
            final button = FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => QuizScreen(hadith: hadith),
                ),
              ),
              icon: const Icon(Icons.quiz_rounded),
              label: Text(score == 0 ? 'Mulakan Kuiz' : 'Ulang Kuiz'),
            );
            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  text,
                  const SizedBox(height: AppSpacing.lg),
                  button,
                ],
              );
            }
            return Row(children: [Expanded(child: text), button]);
          },
        ),
      ),
    );
  }
}

class _CompletionCard extends StatelessWidget {
  const _CompletionCard({required this.completed, required this.onComplete});

  final bool completed;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: completed
          ? scheme.primaryContainer.withValues(alpha: 0.45)
          : scheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < AppBreakpoints.cardCompact;
            final information = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  completed ? Icons.verified_rounded : Icons.flag_outlined,
                  size: 32,
                  color: scheme.primary,
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        completed
                            ? 'Pembelajaran selesai'
                            : 'Selesai membaca hadis ini?',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        completed
                            ? 'Hadis ini telah direkodkan dalam progres pembelajaran anda.'
                            : 'Tandakan selesai selepas membaca, memahami dan membuat refleksi.',
                      ),
                    ],
                  ),
                ),
              ],
            );
            final button = FilledButton.icon(
              onPressed: completed ? null : onComplete,
              icon: const Icon(Icons.check_rounded),
              label: Text(completed ? 'Selesai' : 'Tandakan Selesai'),
            );
            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  information,
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(width: double.infinity, child: button),
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: information),
                const SizedBox(width: AppSpacing.lg),
                button,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HadithPrevNext extends StatelessWidget {
  const _HadithPrevNext({required this.hadith, required this.repository});

  final Hadith hadith;
  final HadithRepository repository;

  @override
  Widget build(BuildContext context) {
    final prev = repository.byNumber(hadith.number - 1);
    final next = repository.byNumber(hadith.number + 1);

    return Row(
      children: [
        if (prev != null)
          TextButton.icon(
            onPressed: () => _navigateReplace(context, prev),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: Text('${prev.displayNumber}. ${prev.title}'),
          )
        else
          const Spacer(),
        if (next != null)
          TextButton.icon(
            onPressed: () => _navigateReplace(context, next),
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: Text('${next.displayNumber}. ${next.title}'),
          )
        else
          const Spacer(),
      ],
    );
  }

  void _navigateReplace(BuildContext context, Hadith target) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => HadithScreen(hadith: target)),
    );
  }
}

class _SupplicationCard extends StatelessWidget {
  const _SupplicationCard({required this.dua});

  final Supplication dua;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                dua.title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.lg),
              Directionality(
                textDirection: TextDirection.rtl,
                child: SelectableText(
                  dua.arabic,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    height: 2.0,
                    fontFamily: AppConstants.arabicFontFamily,
                    fontFamilyFallback: AppConstants.arabicFontFallback,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                dua.translationMalay,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.7,
                    ),
              ),
              if (dua.reference.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Rujukan: ${dua.reference}',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SupplementaryHadithCard extends StatelessWidget {
  const _SupplementaryHadithCard({required this.hadith});

  final SupplementaryHadith hadith;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Card(
        color: scheme.secondaryContainer.withValues(alpha: 0.2),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.mosque_rounded, size: 18, color: scheme.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      hadith.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              if (hadith.narrator.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Daripada: ${hadith.narrator}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Directionality(
                textDirection: TextDirection.rtl,
                child: SelectableText(
                  hadith.arabic,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    height: 1.9,
                    fontFamily: AppConstants.arabicFontFamily,
                    fontFamilyFallback: AppConstants.arabicFontFallback,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Maksud: ${hadith.translationMalay}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                    ),
              ),
              if (hadith.reference.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  hadith.reference,
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
