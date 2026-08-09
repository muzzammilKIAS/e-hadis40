import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../data/models/hadith.dart';
import '../screens/hadith_screen.dart';
import '../services/global_audio_controller.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<GlobalHadithAudioController>();
    final hadith = audio.currentHadith;
    if (hadith == null) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => _openHadith(context, hadith),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: scheme.surface,
          border: Border(top: BorderSide(color: scheme.outlineVariant)),
        ),
        child: SafeArea(
          top: false,
          child: StreamBuilder<PlayerState>(
            stream: audio.player.playerStateStream,
            builder: (context, stateSnapshot) {
              final playing = stateSnapshot.data?.playing ?? false;
              final isCompleted = stateSnapshot.data?.processingState ==
                  ProcessingState.completed;

              return StreamBuilder<Duration?>(
                stream: audio.player.durationStream,
                builder: (context, durationSnapshot) {
                  final duration = durationSnapshot.data ?? Duration.zero;
                  return StreamBuilder<Duration>(
                    stream: audio.player.positionStream,
                    builder: (context, positionSnapshot) {
                      final position = positionSnapshot.data ?? Duration.zero;
                      final safePosition = position > duration &&
                              duration > Duration.zero
                          ? duration
                          : position;
                      final maxMs = duration.inMilliseconds <= 0
                          ? 1.0
                          : duration.inMilliseconds.toDouble();
                      final progress = maxMs > 1
                          ? safePosition.inMilliseconds / maxMs
                          : 0.0;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 2,
                            backgroundColor:
                                scheme.surfaceContainerHighest,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Hadis ${hadith.displayNumber}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                            color: scheme.primary,
                                          ),
                                        ),
                                        Text(
                                          hadith.title,
                                          maxLines: 1,
                                          overflow:
                                              TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: scheme.onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                        Icons.skip_previous_rounded),
                                    iconSize: 22,
                                    tooltip: 'Hadis sebelumnya',
                                    onPressed: audio.hasPrev
                                        ? audio.previous
                                        : null,
                                    color: audio.hasPrev
                                        ? scheme.onSurface
                                        : scheme.onSurfaceVariant
                                            .withValues(alpha: 0.3),
                                  ),
                                  Material(
                                    color: scheme.primary,
                                    shape: const CircleBorder(),
                                    child: InkWell(
                                      onTap: isCompleted
                                          ? () async {
                                              await audio.player
                                                  .seek(Duration.zero);
                                              await audio.player.play();
                                            }
                                          : audio.togglePlay,
                                      customBorder:
                                          const CircleBorder(),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Icon(
                                          isCompleted
                                              ? Icons.replay_rounded
                                              : playing
                                                  ? Icons.pause_rounded
                                                  : Icons
                                                      .play_arrow_rounded,
                                          color: scheme.onPrimary,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                        Icons.skip_next_rounded),
                                    iconSize: 22,
                                    tooltip: 'Hadis seterusnya',
                                    onPressed: audio.hasNext
                                        ? audio.next
                                        : null,
                                    color: audio.hasNext
                                        ? scheme.onSurface
                                        : scheme.onSurfaceVariant
                                            .withValues(alpha: 0.3),
                                  ),
                                  const SizedBox(width: 4),
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _fmt(safePosition),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color:
                                              scheme.onSurfaceVariant,
                                        ),
                                      ),
                                      Text(
                                        _fmt(duration),
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: scheme.onSurfaceVariant
                                              .withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _openHadith(BuildContext context, Hadith hadith) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => HadithScreen(hadith: hadith)),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
