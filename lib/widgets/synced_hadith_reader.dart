import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../core/constants/app_constants.dart';
import '../data/models/hadith.dart';
import '../services/hadith_local_audio_controller.dart';

class SyncedHadithReader extends StatefulWidget {
  const SyncedHadithReader({
    required this.hadith,
    required this.textScale,
    super.key,
  });

  final Hadith hadith;
  final double textScale;

  @override
  State<SyncedHadithReader> createState() => _SyncedHadithReaderState();
}

class _SyncedHadithReaderState extends State<SyncedHadithReader> {
  late final ScrollController _scrollController;
  late List<GlobalKey> _segmentKeys;
  late final HadithLocalAudioController _audio;

  bool _followAudio = true;
  int _lastScrolledIndex = -1;

  /// Kelajuan sorotan TEKS sahaja — berasingan daripada kelajuan main balik
  /// audio sebenar (`_audio.speed`). Digunakan untuk menskalakan kedudukan
  /// audio semasa mengira segmen/perkataan aktif, supaya pelajar boleh
  /// melajukan atau memperlahankan pergerakan sorotan teks tanpa mengubah
  /// kelajuan bacaan audio itu sendiri.
  double _textSpeed = 1.0;

  /// Indeks petikan yang sedang diulang (loop) apabila ikon ulang petikan
  /// ditekan — `null` jika tiada petikan dalam mod ulangan. Menekan teks
  /// petikan (bukan ikon ulang) kekal seperti asal: main terus ke hadapan.
  int? _loopSegmentIndex;

  @override
  void initState() {
    super.initState();
    _audio = HadithLocalAudioController();
    _scrollController = ScrollController();
    _segmentKeys = _buildSegmentKeys();
    _audio.addListener(_refresh);
    _audio.load(widget.hadith.audioAsset);
  }

  @override
  void didUpdateWidget(covariant SyncedHadithReader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hadith.id != widget.hadith.id ||
        oldWidget.hadith.audioTimings.length !=
            widget.hadith.audioTimings.length) {
      _segmentKeys = _buildSegmentKeys();
      _lastScrolledIndex = -1;
      _loopSegmentIndex = null;
      _audio.load(widget.hadith.audioAsset);
    }
  }

  List<GlobalKey> _buildSegmentKeys() {
    return List<GlobalKey>.generate(
      widget.hadith.audioTimings.length,
      (_) => GlobalKey(),
    );
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _audio.removeListener(_refresh);
    _audio.stop();
    _audio.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (_audio.loading && !_audio.ready) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Expanded(child: Text('Memuatkan rakaman bacaan…')),
          ],
        ),
      );
    }

    if (!_audio.ready) {
      return _unavailableState(context);
    }

    if (widget.hadith.audioTimings.isEmpty) {
      return _plainTextFallback(context);
    }

    return StreamBuilder<PlayerState>(
      stream: _audio.player.playerStateStream,
      builder: (context, stateSnapshot) {
        final playerState = stateSnapshot.data;
        final playing = playerState?.playing ?? false;
        final completed =
            playerState?.processingState == ProcessingState.completed;

        return StreamBuilder<Duration?>(
          stream: _audio.player.durationStream,
          builder: (context, durationSnapshot) {
            final duration = durationSnapshot.data ??
                Duration(milliseconds: widget.hadith.audioDurationMs);

            return StreamBuilder<Duration>(
              stream: _audio.player.positionStream,
              builder: (context, positionSnapshot) {
                final position = positionSnapshot.data ?? Duration.zero;
                // `_textSpeed` menskalakan kedudukan audio SEBELUM ditolak
                // dengan offset segerak — audio terus bermain pada kelajuan
                // sebenar, tetapi sorotan teks "melihat" masa yang lebih
                // jauh (lebih laju) atau lebih dekat (lebih perlahan)
                // berbanding kedudukan audio sebenar.
                final effectiveMs = math.max(
                  0,
                  (position.inMilliseconds * _textSpeed).round() +
                      widget.hadith.audioSyncOffsetMs,
                );
                final activeIndex = _activeSegmentIndex(effectiveMs);
                _scheduleAutoScroll(activeIndex, completed: completed);
                _scheduleLoopCheck(position.inMilliseconds, playing: playing);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _statusRow(
                      context,
                      playing: playing,
                      completed: completed,
                      activeIndex: activeIndex,
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      height:
                          MediaQuery.sizeOf(context).width < 600 ? 410 : 500,
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: scheme.outlineVariant),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 18,
                          ),
                          itemCount: widget.hadith.audioTimings.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final segment = widget.hadith.audioTimings[index];
                            final isActive = !completed && index == activeIndex;
                            final isCompleted = completed ||
                                effectiveMs >= segment.endMs ||
                                index < activeIndex;
                            // Word-level highlight bergerak per perkataan untuk
                            // SEMUA hadis (H1–H7 mahupun H8–H20), konsisten
                            // dengan kelakuan bacaan karaoke. Exact `words`
                            // timing dipakai jika wujud; selain itu fallback
                            // proportional mengikut berat huruf.
                            final activeWordIndex = isActive
                                ? _activeWordIndex(segment, effectiveMs)
                                : -1;

                            return _SyncedSegmentTile(
                              key: _segmentKeys[index],
                              number: index + 1,
                              segment: segment,
                              isActive: isActive,
                              isCompleted: isCompleted,
                              isLooping: _loopSegmentIndex == index,
                              activeWordIndex: activeWordIndex,
                              textScale: widget.textScale,
                              onTap: () => _seekToSegment(segment),
                              onToggleLoop: () => _toggleSegmentLoop(index),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _audioControls(
                      context: context,
                      playing: playing,
                      completed: completed,
                      position: position,
                      duration: duration,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tekan mana-mana petikan untuk terus memainkan bacaan '
                      'daripada bahagian tersebut.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _statusRow(
    BuildContext context, {
    required bool playing,
    required bool completed,
    required int activeIndex,
  }) {
    final current = activeIndex >= 0
        ? '${activeIndex + 1}/${widget.hadith.audioTimings.length}'
        : '—';

    final statusLabel = completed
        ? 'Bacaan selesai'
        : playing
            ? 'Bacaan sedang dimainkan'
            : 'Bacaan dihentikan seketika';

    final statusIcon = completed
        ? Icons.check_circle_rounded
        : playing
            ? Icons.graphic_eq_rounded
            : Icons.pause_circle_outline_rounded;

    return Wrap(
      spacing: 10,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Chip(
          avatar: Icon(statusIcon, size: 18),
          label: Text(statusLabel),
        ),
        Chip(
          avatar: const Icon(Icons.format_quote_rounded, size: 18),
          label: Text('Petikan $current'),
        ),
        FilterChip(
          selected: _followAudio,
          avatar: const Icon(Icons.vertical_align_center_rounded, size: 18),
          label: const Text('Ikut audio'),
          tooltip: _followAudio
              ? 'Paparan bergerak secara automatik mengikut bacaan'
              : 'Paparan kekal pada kedudukan yang anda pilih',
          onSelected: (value) {
            setState(() {
              _followAudio = value;
              if (value) _lastScrolledIndex = -1;
            });
          },
        ),
      ],
    );
  }

  Widget _audioControls({
    required BuildContext context,
    required bool playing,
    required bool completed,
    required Duration position,
    required Duration duration,
  }) {
    final maxMilliseconds =
        duration.inMilliseconds <= 0 ? 1.0 : duration.inMilliseconds.toDouble();
    final safePosition = position.inMilliseconds
        .toDouble()
        .clamp(0.0, maxMilliseconds)
        .toDouble();

    final mainLabel = playing
        ? 'Berhenti'
        : completed
            ? 'Main semula'
            : 'Mainkan';
    final mainIcon = playing
        ? Icons.pause_rounded
        : completed
            ? Icons.replay_rounded
            : Icons.play_arrow_rounded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton.tonalIcon(
              onPressed: _audio.togglePlay,
              icon: Icon(mainIcon),
              label: Text(mainLabel),
            ),
            Tooltip(
              message: 'Mainkan semula dari awal',
              child: IconButton(
                onPressed: _audio.replay,
                icon: const Icon(Icons.restart_alt_rounded),
              ),
            ),
            Tooltip(
              message: _audio.repeat ? 'Matikan ulangan' : 'Ulang satu',
              child: IconButton(
                onPressed: _audio.toggleRepeat,
                isSelected: _audio.repeat,
                icon: const Icon(Icons.repeat_rounded),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Kelajuan Audio'),
                  const SizedBox(width: 8),
                  DropdownButton<double>(
                    value: _audio.speed,
                    underline: const SizedBox.shrink(),
                    borderRadius: BorderRadius.circular(14),
                    onChanged: (value) {
                      if (value != null) _audio.setSpeed(value);
                    },
                    items: const [
                      DropdownMenuItem(value: 0.75, child: Text('0.75×')),
                      DropdownMenuItem(value: 1.0, child: Text('1.0×')),
                      DropdownMenuItem(value: 1.25, child: Text('1.25×')),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              child: Tooltip(
                message: 'Melajukan atau memperlahankan sorotan teks tanpa '
                    'mengubah kelajuan bacaan audio.',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Kelajuan Teks'),
                    const SizedBox(width: 8),
                    DropdownButton<double>(
                      value: _textSpeed,
                      underline: const SizedBox.shrink(),
                      borderRadius: BorderRadius.circular(14),
                      onChanged: (value) {
                        if (value != null) setState(() => _textSpeed = value);
                      },
                      items: const [
                        DropdownMenuItem(value: 0.75, child: Text('0.75×')),
                        DropdownMenuItem(value: 1.0, child: Text('1.0×')),
                        DropdownMenuItem(value: 1.25, child: Text('1.25×')),
                        DropdownMenuItem(value: 1.5, child: Text('1.5×')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: safePosition,
          max: maxMilliseconds,
          semanticFormatterCallback: (value) =>
              _formatDuration(Duration(milliseconds: value.round())),
          onChanged: (value) {
            _audio.seek(Duration(milliseconds: value.round()));
          },
        ),
        Row(
          children: [
            Text(_formatDuration(position)),
            const Spacer(),
            Text(_formatDuration(duration)),
          ],
        ),
      ],
    );
  }

  Widget _unavailableState(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.volume_off_rounded, color: scheme.onSecondaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _audio.errorMessage ?? 'Audio bacaan sedang disediakan.',
              style: TextStyle(color: scheme.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }

  Widget _plainTextFallback(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SelectableText(
        widget.hadith.arabicText,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: AppConstants.arabicFontFamily,
          fontFamilyFallback: AppConstants.arabicFontFallback,
          fontSize: 30 * widget.textScale,
          height: 2,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  int _activeSegmentIndex(int positionMs) {
    final segments = widget.hadith.audioTimings;
    if (segments.isEmpty) return -1;
    if (positionMs < segments.first.startMs) return 0;
    for (var index = segments.length - 1; index >= 0; index--) {
      if (positionMs >= segments[index].startMs) return index;
    }
    return 0;
  }

  int _activeWordIndex(AudioTextSegment segment, int positionMs) {
    final words = segment.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList(growable: false);
    if (words.isEmpty) return -1;
    if (positionMs <= segment.startMs) return 0;
    if (positionMs >= segment.endMs) return words.length - 1;

    // Exact word timing jika tersedia (e.g. Hadis 5).
    if (segment.hasWordTimings) {
      for (var i = segment.words.length - 1; i >= 0; i--) {
        if (positionMs >= segment.words[i].startMs) return i;
      }
      return 0;
    }

    // Fallback proportional (untuk semua hadis, termasuk phraseOnly).
    final duration = math.max(1, segment.endMs - segment.startMs);
    final progress =
        ((positionMs - segment.startMs) / duration).clamp(0.0, 1.0);
    final weights = words
        .map((word) => math.max(1, _arabicLetterWeight(word)))
        .toList(growable: false);
    final totalWeight = weights.fold<int>(0, (sum, value) => sum + value);
    final target = progress * totalWeight;
    var cumulative = 0;
    for (var index = 0; index < weights.length; index++) {
      cumulative += weights[index];
      if (target <= cumulative) return index;
    }
    return words.length - 1;
  }

  int _arabicLetterWeight(String word) {
    final withoutMarks = word.replaceAll(
      RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED،؛؟.:]'),
      '',
    );
    return withoutMarks.runes.length;
  }

  void _scheduleAutoScroll(int activeIndex, {required bool completed}) {
    if (!_followAudio ||
        completed ||
        activeIndex < 0 ||
        activeIndex >= _segmentKeys.length ||
        activeIndex == _lastScrolledIndex) {
      return;
    }
    _lastScrolledIndex = activeIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final targetContext = _segmentKeys[activeIndex].currentContext;
      if (targetContext == null) return;
      Scrollable.ensureVisible(
        targetContext,
        alignment: 0.42,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _seekToSegment(AudioTextSegment segment) async {
    // Menekan teks petikan sentiasa bermakna "main terus ke hadapan" —
    // batalkan mod ulangan (jika aktif) supaya ia tidak melompat balik ke
    // petikan lama semasa pengguna cuba beralih ke hadapan.
    if (_loopSegmentIndex != null) {
      setState(() => _loopSegmentIndex = null);
    }
    await _audio.seekAndPlay(segment.start);
  }

  /// Togol mod ulangan bagi petikan pada [index]. Menekan ikon ulang pada
  /// petikan yang sama sekali lagi menghentikan ulangan (tetapi audio
  /// terus bermain seperti biasa, tidak berhenti).
  Future<void> _toggleSegmentLoop(int index) async {
    if (_loopSegmentIndex == index) {
      setState(() => _loopSegmentIndex = null);
      return;
    }
    setState(() => _loopSegmentIndex = index);
    await _audio.seekAndPlay(widget.hadith.audioTimings[index].start);
  }

  /// Semasa mod ulangan aktif DAN audio sedang bermain, apabila kedudukan
  /// audio SEBENAR (bukan dilaraskan `_textSpeed`) melepasi hujung petikan
  /// yang di-loop, lompat balik ke permulaan petikan tersebut dan terus
  /// main. Kawalan `playing` mengelakkan kod ini secara tidak sengaja
  /// menyambung semula audio yang pengguna sengaja hentikan (jeda) tepat
  /// selepas kedudukannya melepasi hujung petikan.
  void _scheduleLoopCheck(int rawPositionMs, {required bool playing}) {
    final loopIndex = _loopSegmentIndex;
    if (!playing ||
        loopIndex == null ||
        loopIndex >= widget.hadith.audioTimings.length) {
      return;
    }
    final segment = widget.hadith.audioTimings[loopIndex];
    if (rawPositionMs < segment.endMs) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _loopSegmentIndex != loopIndex) return;
      _audio.seekAndPlay(segment.start);
    });
  }

  String _formatDuration(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _SyncedSegmentTile extends StatelessWidget {
  const _SyncedSegmentTile({
    required this.number,
    required this.segment,
    required this.isActive,
    required this.isCompleted,
    required this.isLooping,
    required this.activeWordIndex,
    required this.textScale,
    required this.onTap,
    required this.onToggleLoop,
    super.key,
  });

  final int number;
  final AudioTextSegment segment;
  final bool isActive;
  final bool isCompleted;
  final bool isLooping;
  final int activeWordIndex;
  final double textScale;
  final VoidCallback onTap;
  final VoidCallback onToggleLoop;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final words = segment.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList(growable: false);

    return Semantics(
      button: true,
      label: 'Petikan $number. Tekan untuk memainkan bacaan dari bahagian ini.',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              // Mod ulangan diberi warna tersendiri (tertiary) supaya
              // kelihatan berbeza daripada petikan yang sekadar "aktif"
              // (primary) — pengguna perlu nampak jelas petikan mana yang
              // sedang di-loop.
              color: isLooping
                  ? scheme.tertiaryContainer.withValues(alpha: 0.65)
                  : isActive
                      ? scheme.primaryContainer.withValues(alpha: 0.72)
                      : isCompleted
                          ? scheme.secondaryContainer.withValues(alpha: 0.28)
                          : scheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isLooping
                    ? scheme.tertiary
                    : isActive
                        ? scheme.primary
                        : scheme.outlineVariant,
                width: isLooping || isActive ? 1.6 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? scheme.primary
                        : isCompleted
                            ? scheme.secondaryContainer
                            : scheme.surfaceContainerHighest,
                  ),
                  child: isCompleted && !isActive
                      ? Icon(Icons.check_rounded,
                          size: 18, color: scheme.onSecondaryContainer)
                      : Text('$number',
                          style: TextStyle(
                            color: isActive
                                ? scheme.onPrimary
                                : scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w800,
                          )),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          for (var index = 0; index < words.length; index++)
                            TextSpan(
                              text: '${words[index]} ',
                              style: TextStyle(
                                color: index == activeWordIndex && isActive
                                    ? scheme.onTertiaryContainer
                                    : isActive && index < activeWordIndex
                                        ? scheme.primary
                                        : scheme.onSurface,
                                backgroundColor:
                                    index == activeWordIndex && isActive
                                        ? scheme.tertiaryContainer
                                        : Colors.transparent,
                                fontWeight: index == activeWordIndex && isActive
                                    ? FontWeight.w900
                                    : isActive && index < activeWordIndex
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: AppConstants.arabicFontFamily,
                        fontFamilyFallback: AppConstants.arabicFontFallback,
                        fontSize: 27 * textScale,
                        height: 1.9,
                      ),
                    ),
                  ),
                ),
                if (isActive) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.graphic_eq_rounded, color: scheme.primary),
                ],
                const SizedBox(width: 4),
                Tooltip(
                  message: isLooping
                      ? 'Henti ulangan petikan ini'
                      : 'Ulang petikan ini sahaja',
                  child: IconButton(
                    onPressed: onToggleLoop,
                    isSelected: isLooping,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.repeat_one_rounded),
                    color: scheme.onSurfaceVariant,
                    selectedIcon: Icon(Icons.repeat_one_on_rounded,
                        color: scheme.tertiary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
