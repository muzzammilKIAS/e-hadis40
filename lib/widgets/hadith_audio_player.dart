import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../services/hadith_audio_service.dart';

class HadithAudioPlayer extends StatefulWidget {
  const HadithAudioPlayer({required this.assetPath, super.key});

  final String assetPath;

  @override
  State<HadithAudioPlayer> createState() => _HadithAudioPlayerState();
}

class _HadithAudioPlayerState extends State<HadithAudioPlayer> {
  late final HadithAudioService _service;

  @override
  void initState() {
    super.initState();
    _service = HadithAudioService()..addListener(_refresh);
    _service.load(widget.assetPath);
  }

  @override
  void didUpdateWidget(covariant HadithAudioPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath) {
      _service.load(widget.assetPath);
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _service.removeListener(_refresh);
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (_service.loading) {
      return const Row(
        children: [
          SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 12),
          Text('Memuatkan audio bacaan…'),
        ],
      );
    }

    if (!_service.ready) {
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
                _service.errorMessage ?? 'Audio bacaan sedang disediakan.',
                style: TextStyle(color: scheme.onSecondaryContainer),
              ),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<PlayerState>(
      stream: _service.player.playerStateStream,
      builder: (context, stateSnapshot) {
        final playing = stateSnapshot.data?.playing ?? false;
        return StreamBuilder<Duration?>(
          stream: _service.player.durationStream,
          builder: (context, durationSnapshot) {
            final duration = durationSnapshot.data ?? Duration.zero;
            return StreamBuilder<Duration>(
              stream: _service.player.positionStream,
              builder: (context, positionSnapshot) {
                final position = positionSnapshot.data ?? Duration.zero;
                final safePosition =
                    position > duration && duration > Duration.zero
                        ? duration
                        : position;
                final maxMilliseconds = duration.inMilliseconds <= 0
                    ? 1.0
                    : duration.inMilliseconds.toDouble();

                return Column(
                  children: [
                    Row(
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: _service.togglePlay,
                          icon: Icon(
                            playing
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                          ),
                          label: Text(playing ? 'Pause' : 'Mainkan'),
                        ),
                        const SizedBox(width: 8),
                        Tooltip(
                          message: 'Ulang dari awal',
                          child: IconButton(
                            onPressed: _service.replay,
                            icon: const Icon(Icons.replay_rounded),
                          ),
                        ),
                        Tooltip(
                          message: _service.repeat
                              ? 'Matikan ulangan'
                              : 'Ulang audio',
                          child: IconButton(
                            onPressed: _service.toggleRepeat,
                            isSelected: _service.repeat,
                            icon: const Icon(Icons.repeat_rounded),
                          ),
                        ),
                        const Spacer(),
                        DropdownButton<double>(
                          value: _service.speed,
                          underline: const SizedBox.shrink(),
                          borderRadius: BorderRadius.circular(14),
                          onChanged: (value) {
                            if (value != null) _service.setSpeed(value);
                          },
                          items: const [
                            DropdownMenuItem(value: 0.75, child: Text('0.75×')),
                            DropdownMenuItem(value: 1.0, child: Text('1.0×')),
                            DropdownMenuItem(value: 1.25, child: Text('1.25×')),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Slider(
                      value: safePosition.inMilliseconds
                          .toDouble()
                          .clamp(0.0, maxMilliseconds)
                          .toDouble(),
                      max: maxMilliseconds,
                      onChanged: (value) {
                        _service.seek(Duration(milliseconds: value.round()));
                      },
                    ),
                    Row(
                      children: [
                        Text(_formatDuration(safePosition)),
                        const Spacer(),
                        Text(_formatDuration(duration)),
                      ],
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

  String _formatDuration(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
