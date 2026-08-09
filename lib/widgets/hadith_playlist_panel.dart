import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_shadows.dart';
import '../core/theme/app_spacing.dart';
import '../data/models/hadith.dart';
import '../data/repositories/hadith_repository.dart';
import '../services/hadith_playlist_service.dart';

class HadithPlaylistPanel extends StatefulWidget {
  const HadithPlaylistPanel({super.key});

  @override
  State<HadithPlaylistPanel> createState() => _HadithPlaylistPanelState();
}

class _HadithPlaylistPanelState extends State<HadithPlaylistPanel> {
  HadithPlaylistService? _service;
  bool _initializing = true;

  @override
  void initState() {
    super.initState();
    _initService();
  }

  void _initService() {
    final repository = context.read<HadithRepository>();
    final hadiths = repository.availableHadiths;
    final service = HadithPlaylistService(hadiths: hadiths)
      ..addListener(_refresh);
    _service = service;
    service.load().then((_) {
      if (mounted) setState(() => _initializing = false);
    });
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _service?.removeListener(_refresh);
    _service?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_initializing || _service == null || _service!.loading) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final service = _service!;

    if (!service.ready) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.volume_off_rounded,
                size: 48, color: scheme.onSurfaceVariant),
            const SizedBox(height: AppSpacing.lg),
            Text(service.errorMessage ?? 'Audio tidak tersedia.',
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    final tracks = service.validHadiths;

    return Stack(
      children: [
        _DecorativeBackground(scheme: scheme, isDark: isDark),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              _ElegantHeader(
                  scheme: scheme, service: service, tracks: tracks),
              const SizedBox(height: AppSpacing.xl),
              _NowPlayingCard(
                  scheme: scheme, service: service, tracks: tracks),
              const SizedBox(height: AppSpacing.xl),
              Flexible(
                child: _ElegantTrackList(
                  scheme: scheme,
                  tracks: tracks,
                  currentIndex: service.currentIndex,
                  onTap: (index) {
                    service.skipTo(index);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DecorativeBackground extends StatelessWidget {
  const _DecorativeBackground({required this.scheme, required this.isDark});
  final ColorScheme scheme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.expand(
        child: Column(
          children: [
            const SizedBox(height: 160),
            Opacity(
              opacity: isDark ? 0.04 : 0.06,
              child: Icon(Icons.mosque_rounded, size: 200, color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary),
            ),
            const Spacer(),
            Opacity(
              opacity: isDark ? 0.03 : 0.05,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationZ(pi),
                child: Icon(Icons.headphones_rounded, size: 240, color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

class _ElegantHeader extends StatelessWidget {
  const _ElegantHeader({
    required this.scheme, required this.service, required this.tracks,
  });
  final ColorScheme scheme;
  final HadithPlaylistService service;
  final List<Hadith> tracks;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primaryContainer.withValues(alpha: 0.8), scheme.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.subtle(context),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child:
                Icon(Icons.headphones_rounded, color: scheme.onPrimary, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pemain Audio Hadis',
                    style: Theme.of(context).textTheme.titleMedium),
                Text('${tracks.length} hadis tersedia',
                    style: TextStyle(
                        color: scheme.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
          _RepeatModePill(service: service, scheme: scheme),
        ],
      ),
    );
  }
}

class _RepeatModePill extends StatelessWidget {
  const _RepeatModePill({required this.service, required this.scheme});
  final HadithPlaylistService service;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final mode = service.repeatMode;
    final isActive = mode != LoopMode.off;
    final isOne = mode == LoopMode.one;
    final label = mode == LoopMode.off
        ? 'Tiada ulangan'
        : mode == LoopMode.one
            ? 'Ulang satu'
            : 'Ulang semua';

    return Material(
      color: isActive ? scheme.primary.withValues(alpha: 0.12) : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: service.cycleRepeatMode,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.repeat_rounded, size: 16,
                        color: isActive ? scheme.primary : scheme.onSurfaceVariant),
                    if (isOne)
                      Positioned(
                        top: 0,
                        child: Text('1',
                            style: TextStyle(
                                fontSize: 7,
                                fontWeight: FontWeight.w900,
                                color: scheme.primary)),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isActive ? scheme.primary : scheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NowPlayingCard extends StatelessWidget {
  const _NowPlayingCard({
    required this.scheme, required this.service, required this.tracks,
  });
  final ColorScheme scheme;
  final HadithPlaylistService service;
  final List<Hadith> tracks;

  @override
  Widget build(BuildContext context) {
    final hadith = service.currentHadith;
    if (hadith == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primaryContainer.withValues(alpha: 0.6),
            scheme.secondaryContainer.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [scheme.primary, scheme.tertiary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(hadith.displayNumber,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: scheme.onPrimary)),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hadith.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.category_rounded,
                            size: 14, color: scheme.secondary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(hadith.theme,
                              style: TextStyle(
                                  color: scheme.onSurfaceVariant, fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _NowPlayingControls(service: service, scheme: scheme),
          const SizedBox(height: AppSpacing.lg),
          _ProgressSlider(service: service, scheme: scheme),
        ],
      ),
    );
  }
}

class _NowPlayingControls extends StatelessWidget {
  const _NowPlayingControls({required this.service, required this.scheme});
  final HadithPlaylistService service;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: service.player.playerStateStream,
      builder: (context, snapshot) {
        final playing = snapshot.data?.playing ?? false;
        final isCompleted =
            snapshot.data?.processingState == ProcessingState.completed;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ControlButton(
              onTap: service.previous,
              icon: Icons.skip_previous_rounded,
              size: 28,
              scheme: scheme,
            ),
            const SizedBox(width: AppSpacing.xl),
            _MainPlayPause(
              isCompleted: isCompleted,
              playing: playing,
              service: service,
              scheme: scheme,
            ),
            const SizedBox(width: AppSpacing.xl),
            _ControlButton(
              onTap: service.next,
              icon: Icons.skip_next_rounded,
              size: 28,
              scheme: scheme,
            ),
          ],
        );
      },
    );
  }
}

class _MainPlayPause extends StatelessWidget {
  const _MainPlayPause({
    required this.isCompleted,
    required this.playing,
    required this.service,
    required this.scheme,
  });
  final bool isCompleted;
  final bool playing;
  final HadithPlaylistService service;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.2),
            blurRadius: 40,
            offset: const Offset(0, 12),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: isCompleted ? () => service.skipTo(0) : service.togglePlay,
          customBorder: const CircleBorder(),
          child: Center(
            child: Icon(
              isCompleted
                  ? Icons.replay_rounded
                  : playing
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
              color: scheme.onPrimary,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.onTap,
    required this.icon,
    required this.size,
    required this.scheme,
  });
  final VoidCallback onTap;
  final IconData icon;
  final double size;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.7),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Icon(icon, size: size, color: scheme.onSurface),
        ),
      ),
    );
  }
}

class _ProgressSlider extends StatelessWidget {
  const _ProgressSlider({required this.service, required this.scheme});
  final HadithPlaylistService service;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration?>(
      stream: service.player.durationStream,
      builder: (context, durationSnapshot) {
        final duration = durationSnapshot.data ?? Duration.zero;
        return StreamBuilder<Duration>(
          stream: service.player.positionStream,
          builder: (context, positionSnapshot) {
            final position = positionSnapshot.data ?? Duration.zero;
            final safePosition =
                position > duration && duration > Duration.zero ? duration : position;
            final maxMs = duration.inMilliseconds <= 0
                ? 1.0
                : duration.inMilliseconds.toDouble();

            return Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 7),
                    activeTrackColor: scheme.primary,
                    inactiveTrackColor:
                        scheme.surfaceContainerHighest,
                    thumbColor: scheme.primary,
                    overlayColor: scheme.primary.withValues(alpha: 0.12),
                  ),
                  child: Slider(
                    value: safePosition.inMilliseconds
                        .toDouble()
                        .clamp(0.0, maxMs),
                    max: maxMs,
                    onChanged: (value) {
                      service.seek(Duration(milliseconds: value.round()));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_fmt(safePosition),
                          style: TextStyle(
                              color: scheme.onSurfaceVariant, fontSize: 11)),
                      Row(
                        children: [
                          _SpeedDot(0.75, service, scheme),
                          const SizedBox(width: 8),
                          _SpeedDot(1.0, service, scheme),
                          const SizedBox(width: 8),
                          _SpeedDot(1.25, service, scheme),
                        ],
                      ),
                      Text(_fmt(duration),
                          style: TextStyle(
                              color: scheme.onSurfaceVariant, fontSize: 11)),
                    ],
                  ),
                ),
              ],
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

class _SpeedDot extends StatelessWidget {
  const _SpeedDot(this.speed, this.service, this.scheme);
  final double speed;
  final HadithPlaylistService service;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final selected = service.speed == speed;
    return GestureDetector(
      onTap: () => service.setSpeed(speed),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text('${speed}x',
            style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? scheme.onPrimary : scheme.onSurfaceVariant)),
      ),
    );
  }
}

class _ElegantTrackList extends StatelessWidget {
  const _ElegantTrackList({
    required this.scheme,
    required this.tracks,
    required this.currentIndex,
    required this.onTap,
  });
  final ColorScheme scheme;
  final List<Hadith> tracks;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      itemCount: tracks.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final hadith = tracks[index];
        final isActive = index == currentIndex;
        return _TrackCard(
          hadith: hadith,
          isActive: isActive,
          scheme: scheme,
          onTap: () => onTap(index),
        );
      },
    );
  }
}

class _TrackCard extends StatelessWidget {
  const _TrackCard({
    required this.hadith,
    required this.isActive,
    required this.scheme,
    required this.onTap,
  });
  final Hadith hadith;
  final bool isActive;
  final ColorScheme scheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? scheme.primaryContainer.withValues(alpha: 0.7) : scheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : AppShadows.subtle(context),
        border: isActive
            ? Border.all(color: scheme.primary.withValues(alpha: 0.3))
            : Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? LinearGradient(
                            colors: [scheme.primary, scheme.tertiary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isActive ? null : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: scheme.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isActive
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(Icons.volume_up_rounded,
                                  color: scheme.onPrimary, size: 20),
                              Positioned(
                                right: 6,
                                bottom: 8,
                                child: _EqBars(scheme: scheme),
                              ),
                            ],
                          )
                        : Text(hadith.displayNumber,
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: scheme.onSurface)),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hadith.title,
                          style: TextStyle(
                              fontWeight:
                                  isActive ? FontWeight.w600 : FontWeight.normal,
                              color: isActive
                                  ? scheme.onPrimaryContainer
                                  : scheme.onSurface)),
                      const SizedBox(height: 2),
                      Text(hadith.theme,
                          style: TextStyle(
                              fontSize: 11,
                              color: isActive
                                  ? scheme.onPrimaryContainer.withValues(alpha: 0.65)
                                  : scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                if (isActive)
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.sm),
                    child: Icon(Icons.graphic_eq_rounded,
                        size: 16, color: scheme.primary),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EqBars extends StatefulWidget {
  const _EqBars({required this.scheme});
  final ColorScheme scheme;

  @override
  State<_EqBars> createState() => _EqBarsState();
}

class _EqBarsState extends State<_EqBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [0.6, 1.0, 0.4].map((scale) {
            final h = 5.0 + 3.0 * (_ctrl.value * scale);
            return Container(
              width: 2,
              height: h,
              margin: const EdgeInsets.only(left: 1),
              decoration: BoxDecoration(
                color: widget.scheme.onPrimary.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(1),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
