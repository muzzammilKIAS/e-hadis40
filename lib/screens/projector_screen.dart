import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../core/constants/app_constants.dart';
import '../core/curriculum/app_curriculum_structure.dart';
import '../data/models/hadith.dart';
import '../data/repositories/hadith_repository.dart';
import '../services/hadith_local_audio_controller.dart';

class ProjectorScreen extends StatefulWidget {
  const ProjectorScreen({
    required this.hadith,
    required this.repository,
    super.key,
  });

  final Hadith hadith;
  final HadithRepository repository;

  @override
  State<ProjectorScreen> createState() => _ProjectorScreenState();
}

class _ProjectorScreenState extends State<ProjectorScreen> {
  late PageController _pageController;
  late HadithLocalAudioController _audio;
  late Hadith _currentHadith;
  int _index = 0;

  List<Hadith> get _allHadiths => widget.repository.availableHadiths
      .where((h) => h.number <= AppCurriculumStructure.totalHadiths)
      .toList();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _currentHadith = widget.hadith;
    _audio = HadithLocalAudioController()..addListener(_refresh);
    _audio.load(_currentHadith.audioAsset);
  }

  @override
  void dispose() {
    _audio.removeListener(_refresh);
    _audio.stop();
    _audio.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  List<_ProjectorPageData> _buildPages(Hadith h) {
    final pages = <_ProjectorPageData>[
      _ProjectorPageData(
        title: 'Hadis ${h.displayNumber} · ${h.title}',
        subtitle: h.theme,
        arabic: h.arabicText,
        isFirstPage: true,
      ),
      _ProjectorPageData(
          title: 'Maksud Hadis', paragraphs: [h.translationMalay]),
      _ProjectorPageData(title: 'Huraian Hadis', paragraphs: h.explanations),
    ];

    if (h.contextNotice.trim().isNotEmpty) {
      pages.add(_ProjectorPageData(
        title: 'Peringatan Penting',
        paragraphs: [h.contextNotice],
      ));
    }

    for (final evidence in h.allQuranEvidences) {
      pages.add(_ProjectorPageData(
        title: 'Dalil al-Quran',
        subtitle: 'Surah ${evidence.surah}, ${evidence.verseLabel}',
        arabic: evidence.arabicText,
        paragraphs: evidence.translationMalay.isNotEmpty
            ? ['"${evidence.translationMalay}"']
            : [],
      ));
    }

    pages.addAll([
      _ProjectorPageData(title: 'Pengajaran', paragraphs: h.lessons),
      _ProjectorPageData(title: 'Penghayatan', paragraphs: h.appreciation),
      _ProjectorPageData(title: 'Fokus Nilai', paragraphs: h.focusValues),
      _ProjectorPageData(
          title: 'Soalan Refleksi', paragraphs: h.reflectionQuestions),
    ]);

    return pages;
  }

  Future<void> _switchHadith(Hadith hadith) async {
    _currentHadith = hadith;
    _index = 0;
    await _audio.player.stop();
    await _audio.load(hadith.audioAsset);
    setState(() {});
    _pageController.jumpToPage(0);
  }

  bool get _hasPrev {
    final list = _allHadiths;
    final idx = list.indexWhere((h) => h.id == _currentHadith.id);
    return idx > 0;
  }

  bool get _hasNext {
    final list = _allHadiths;
    final idx = list.indexWhere((h) => h.id == _currentHadith.id);
    return idx < list.length - 1;
  }

  void _goToPrev() {
    final list = _allHadiths;
    final idx = list.indexWhere((h) => h.id == _currentHadith.id);
    if (idx > 0) _switchHadith(list[idx - 1]);
  }

  void _goToNext() {
    final list = _allHadiths;
    final idx = list.indexWhere((h) => h.id == _currentHadith.id);
    if (idx < list.length - 1) _switchHadith(list[idx + 1]);
  }

  @override
  Widget build(BuildContext context) {
    final hadith = _currentHadith;
    final pages = _buildPages(hadith);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                _hasPrev
                    ? Icons.skip_previous_rounded
                    : Icons.skip_previous_rounded,
                color: _hasPrev ? null : Theme.of(context).disabledColor,
              ),
              tooltip: _hasPrev ? 'Hadis ${hadith.number - 1}' : '',
              onPressed: _hasPrev ? _goToPrev : null,
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Hadis ${hadith.displayNumber}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(
                _hasNext ? Icons.skip_next_rounded : Icons.skip_next_rounded,
                color: _hasNext ? null : Theme.of(context).disabledColor,
              ),
              tooltip: _hasNext ? 'Hadis ${hadith.number + 1}' : '',
              onPressed: _hasNext ? _goToNext : null,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(child: Text('${_index + 1}/${pages.length}')),
          ),
        ],
      ),
      body: PageView.builder(
        key: ValueKey('projector_${hadith.id}'),
        controller: _pageController,
        itemCount: pages.length,
        onPageChanged: (value) => setState(() => _index = value),
        itemBuilder: (context, index) {
          final data = pages[index];
          if (index == 0 && hadith.audioTimings.isNotEmpty) {
            return _SyncedProjectorPage(
              data: data,
              hadith: hadith,
              audio: _audio,
            );
          }
          return _ProjectorPage(data: data);
        },
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_index == 0) _ProjectorAudioBar(audio: _audio),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _index == 0 ? null : () => _goTo(_index - 1),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Sebelumnya'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_index + 1) / pages.length,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    onPressed: _index == pages.length - 1
                        ? null
                        : () => _goTo(_index + 1),
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('Seterusnya'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goTo(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }
}

class _ProjectorPageData {
  const _ProjectorPageData({
    required this.title,
    this.subtitle,
    this.arabic,
    this.paragraphs = const [],
    this.isFirstPage = false,
  });

  final String title;
  final String? subtitle;
  final String? arabic;
  final List<String> paragraphs;
  final bool isFirstPage;
}

class _ProjectorPage extends StatelessWidget {
  const _ProjectorPage({required this.data});

  final _ProjectorPageData data;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(42),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              if (data.subtitle != null) ...[
                const SizedBox(height: 12),
                Text(
                  data.subtitle!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: scheme.primary,
                      ),
                ),
              ],
              const SizedBox(height: 36),
              if (data.arabic != null)
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: SelectableText(
                    data.arabic!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppConstants.arabicFontFamily,
                      fontFamilyFallback: AppConstants.arabicFontFallback,
                      fontSize: 46,
                      height: 2,
                    ),
                  ),
                ),
              if (data.paragraphs.isNotEmpty)
                Column(
                  children: [
                    for (var index = 0; index < data.paragraphs.length; index++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 22),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 18,
                              child: Text('${index + 1}'),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                data.paragraphs[index],
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      height: 1.55,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SyncedProjectorPage extends StatefulWidget {
  const _SyncedProjectorPage({
    required this.data,
    required this.hadith,
    required this.audio,
  });
  final _ProjectorPageData data;
  final Hadith hadith;
  final HadithLocalAudioController audio;

  @override
  State<_SyncedProjectorPage> createState() => _SyncedProjectorPageState();
}

class _SyncedProjectorPageState extends State<_SyncedProjectorPage> {
  late final List<_TimedWord> _timedWords;

  @override
  void initState() {
    super.initState();
    _timedWords = _buildTimedWords();
  }

  List<_TimedWord> _buildTimedWords() {
    final result = <_TimedWord>[];
    for (final seg in widget.hadith.audioTimings) {
      final words = seg.text
          .trim()
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .toList(growable: false);
      if (words.isEmpty) continue;
      final duration = math.max(1, seg.endMs - seg.startMs);
      final weights = words
          .map((w) => math.max(1, _arabicLetterWeight(w)))
          .toList(growable: false);
      final totalWeight = weights.fold<int>(0, (s, v) => s + v);
      var cumulative = 0;
      for (var i = 0; i < words.length; i++) {
        final startFrac = cumulative / totalWeight;
        cumulative += weights[i];
        final endFrac = cumulative / totalWeight;
        result.add(_TimedWord(
          text: words[i],
          startMs: seg.startMs + (startFrac * duration).round(),
          endMs: seg.startMs + (endFrac * duration).round(),
          segmentIndex: 0,
        ));
      }
    }
    var segIdx = 0;
    for (var i = 0; i < result.length; i++) {
      final seg = widget.hadith.audioTimings[segIdx];
      if (result[i].startMs >= seg.endMs &&
          segIdx + 1 < widget.hadith.audioTimings.length) {
        segIdx++;
      }
      result[i] = result[i].copyWith(segmentIndex: segIdx);
    }
    return result;
  }

  int _arabicLetterWeight(String word) {
    final withoutMarks = word.replaceAll(
      RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED،؛؟.:]'),
      '',
    );
    return withoutMarks.runes.length;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final data = widget.data;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(42),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Text(data.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall),
              if (data.subtitle != null) ...[
                const SizedBox(height: 12),
                Text(data.subtitle!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: scheme.primary)),
              ],
              const SizedBox(height: 36),
              StreamBuilder<Duration>(
                stream: widget.audio.player.positionStream,
                builder: (context, snapshot) {
                  final posMs = (snapshot.data ?? Duration.zero).inMilliseconds;
                  var activeSegIdx = -1;
                  final segments = widget.hadith.audioTimings;
                  for (var i = segments.length - 1; i >= 0; i--) {
                    if (posMs >= segments[i].startMs) {
                      activeSegIdx = i;
                      break;
                    }
                  }
                  var activeWordIdx = -1;
                  for (var i = _timedWords.length - 1; i >= 0; i--) {
                    if (posMs >= _timedWords[i].startMs) {
                      activeWordIdx = i;
                      break;
                    }
                  }

                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          for (var i = 0; i < _timedWords.length; i++)
                            TextSpan(
                              text: '${_timedWords[i].text} ',
                              style: TextStyle(
                                fontFamily: AppConstants.arabicFontFamily,
                                fontFamilyFallback:
                                    AppConstants.arabicFontFallback,
                                fontSize: 46,
                                height: 2,
                                color: i == activeWordIdx
                                    ? scheme.onTertiaryContainer
                                    : _timedWords[i].segmentIndex < activeSegIdx
                                        ? scheme.primary
                                        : scheme.onSurface,
                                backgroundColor: i == activeWordIdx
                                    ? scheme.tertiaryContainer
                                    : Colors.transparent,
                                fontWeight: i == activeWordIdx
                                    ? FontWeight.w900
                                    : _timedWords[i].segmentIndex < activeSegIdx
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                              ),
                            ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimedWord {
  const _TimedWord({
    required this.text,
    required this.startMs,
    required this.endMs,
    required this.segmentIndex,
  });

  final String text;
  final int startMs;
  final int endMs;
  final int segmentIndex;

  _TimedWord copyWith({int? segmentIndex}) => _TimedWord(
      text: text,
      startMs: startMs,
      endMs: endMs,
      segmentIndex: segmentIndex ?? this.segmentIndex);
}

class _ProjectorAudioBar extends StatelessWidget {
  const _ProjectorAudioBar({required this.audio});
  final HadithLocalAudioController audio;

  @override
  Widget build(BuildContext context) {
    if (!audio.ready) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;

    return StreamBuilder<PlayerState>(
      stream: audio.player.playerStateStream,
      builder: (context, stateSnapshot) {
        final playing = stateSnapshot.data?.playing ?? false;
        final isCompleted =
            stateSnapshot.data?.processingState == ProcessingState.completed;

        return StreamBuilder<Duration?>(
          stream: audio.player.durationStream,
          builder: (context, durationSnapshot) {
            final duration = durationSnapshot.data ?? Duration.zero;
            return StreamBuilder<Duration>(
              stream: audio.player.positionStream,
              builder: (context, positionSnapshot) {
                final position = positionSnapshot.data ?? Duration.zero;
                final safePosition =
                    position > duration && duration > Duration.zero
                        ? duration
                        : position;
                final maxMs = duration.inMilliseconds <= 0
                    ? 1.0
                    : duration.inMilliseconds.toDouble();

                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    border:
                        Border(top: BorderSide(color: scheme.outlineVariant)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6),
                          activeTrackColor: scheme.primary,
                          inactiveTrackColor: scheme.surfaceContainerHighest,
                          thumbColor: scheme.primary,
                        ),
                        child: Slider(
                          value: safePosition.inMilliseconds
                              .toDouble()
                              .clamp(0.0, maxMs),
                          max: maxMs,
                          onChanged: (value) {
                            audio.seek(Duration(milliseconds: value.round()));
                          },
                        ),
                      ),
                      Row(
                        children: [
                          Text(_fmt(safePosition),
                              style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontSize: 11)),
                          const Spacer(),
                          Tooltip(
                            message: 'Ulang audio',
                            child: IconButton(
                              onPressed: audio.toggleRepeat,
                              isSelected: audio.repeat,
                              icon: const Icon(Icons.repeat_rounded, size: 20),
                              color: audio.repeat ? scheme.primary : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed:
                                  isCompleted ? audio.replay : audio.togglePlay,
                              icon: Icon(
                                isCompleted
                                    ? Icons.replay_rounded
                                    : playing
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                color: scheme.onPrimary,
                              ),
                              iconSize: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _SpeedToggleGlobal(audio: audio, scheme: scheme),
                          const Spacer(),
                          Text(_fmt(duration),
                              style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _SpeedToggleGlobal extends StatelessWidget {
  const _SpeedToggleGlobal({required this.audio, required this.scheme});
  final HadithLocalAudioController audio;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final speed = audio.speed;
    return GestureDetector(
      onTap: () {
        if (speed == 0.75) {
          audio.setSpeed(1.0);
        } else if (speed == 1.0) {
          audio.setSpeed(1.25);
        } else {
          audio.setSpeed(0.75);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: speed != 1.0
              ? scheme.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text('${speed}x',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color:
                    speed != 1.0 ? scheme.primary : scheme.onSurfaceVariant)),
      ),
    );
  }
}
