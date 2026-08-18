import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_shadows.dart';
import '../core/theme/app_spacing.dart';
import '../data/models/hadith.dart';
import '../services/global_audio_controller.dart';

class HadithPlaylistPanel extends StatelessWidget {
  const HadithPlaylistPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final audio = context.watch<GlobalHadithAudioController>();

    if (audio.loading && !audio.ready) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!audio.ready) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.volume_off_rounded,
                size: 48, color: scheme.onSurfaceVariant),
            const SizedBox(height: AppSpacing.lg),
            Text(audio.errorMessage ?? 'Audio tidak tersedia.',
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    final tracks = audio.playlist;

    return Stack(
      children: [
        _DecorativeBackground(scheme: scheme, isDark: isDark),
        // Seluruh panel diskrol sebagai satu unit. Sebelum ini kepala +
        // kad "sedang dimainkan" bersaiz tetap, jadi pada skrin pendek
        // (telefon) tingginya sahaja sudah melebihi ruang badan — Column
        // melimpah (jalur belang RenderFlex) walaupun senarai trek
        // dibungkus `Flexible`, kerana bahagian tetap itu tidak boleh
        // mengecil. Dengan satu skrol luar, susun atur ini muat pada
        // mana-mana saiz skrin.
        SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              _ElegantHeader(scheme: scheme, audio: audio, tracks: tracks),
              const SizedBox(height: AppSpacing.xl),
              _NowPlayingCard(scheme: scheme, audio: audio, tracks: tracks),
              const SizedBox(height: AppSpacing.xl),
              _ElegantTrackList(
                scheme: scheme,
                tracks: tracks,
                currentIndex: audio.currentIndex,
                onTap: (index) => audio.skipTo(index),
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
    // Dua tanda air hiasan sahaja. Guna Stack + Positioned (bukan Column):
    // ketinggian tetapnya berjumlah 660px, jadi pada skrin pendek Column
    // akan melimpah dan memaparkan jalur belang RenderFlex. Dengan Stack,
    // hiasan ini hanya bertindih/dipotong oleh ClipRect — tidak sekali-kali
    // melimpah.
    return IgnorePointer(
      child: ClipRect(
        child: SizedBox.expand(
          child: Stack(
            children: [
              Positioned(
                top: 160,
                left: 0,
                right: 0,
                child: Center(
                  child: Opacity(
                    opacity: isDark ? 0.04 : 0.06,
                    child: const Icon(Icons.mosque_rounded,
                        size: 200, color: AppColors.primary),
                  ),
                ),
              ),
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: Center(
                  child: Opacity(
                    opacity: isDark ? 0.03 : 0.05,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationZ(pi),
                      child: const Icon(Icons.headphones_rounded,
                          size: 240, color: AppColors.primary),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ElegantHeader extends StatelessWidget {
  const _ElegantHeader({
    required this.scheme,
    required this.audio,
    required this.tracks,
  });
  final ColorScheme scheme;
  final GlobalHadithAudioController audio;
  final List<Hadith> tracks;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primaryContainer.withValues(alpha: 0.8),
            scheme.surface
          ],
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
            child: Icon(Icons.headphones_rounded,
                color: scheme.onPrimary, size: 24),
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
          _RepeatModePill(audio: audio, scheme: scheme),
        ],
      ),
    );
  }
}

class _RepeatModePill extends StatelessWidget {
  const _RepeatModePill({required this.audio, required this.scheme});
  final GlobalHadithAudioController audio;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final mode = audio.repeatMode;
    final isActive = mode != GlobalRepeatMode.off;
    final isOne = mode == GlobalRepeatMode.one;
    final label = mode == GlobalRepeatMode.off
        ? 'Tiada ulangan'
        : mode == GlobalRepeatMode.one
            ? 'Ulang satu'
            : 'Ulang semua';

    return Material(
      color: isActive
          ? scheme.primary.withValues(alpha: 0.12)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: audio.cycleRepeatMode,
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
                    Icon(Icons.repeat_rounded,
                        size: 16,
                        color: isActive
                            ? scheme.primary
                            : scheme.onSurfaceVariant),
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
                      color:
                          isActive ? scheme.primary : scheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NowPlayingCard extends StatelessWidget {
  const _NowPlayingCard({
    required this.scheme,
    required this.audio,
    required this.tracks,
  });
  final ColorScheme scheme;
  final GlobalHadithAudioController audio;
  final List<Hadith> tracks;

  @override
  Widget build(BuildContext context) {
    final hadith = audio.currentHadith;
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _NowPlayingControls(audio: audio, scheme: scheme),
          const SizedBox(height: AppSpacing.lg),
          _ProgressSlider(audio: audio, scheme: scheme),
        ],
      ),
    );
  }
}

class _NowPlayingControls extends StatelessWidget {
  const _NowPlayingControls({required this.audio, required this.scheme});
  final GlobalHadithAudioController audio;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: audio.player.playerStateStream,
      builder: (context, snapshot) {
        final playing = snapshot.data?.playing ?? false;
        final isCompleted =
            snapshot.data?.processingState == ProcessingState.completed;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ControlButton(
              onTap: audio.hasPrev ? audio.previous : null,
              icon: Icons.skip_previous_rounded,
              size: 28,
              scheme: scheme,
            ),
            const SizedBox(width: AppSpacing.xl),
            _MainPlayPause(
              isCompleted: isCompleted,
              playing: playing,
              audio: audio,
              scheme: scheme,
            ),
            const SizedBox(width: AppSpacing.xl),
            _ControlButton(
              onTap: audio.hasNext ? audio.next : null,
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
    required this.audio,
    required this.scheme,
  });
  final bool isCompleted;
  final bool playing;
  final GlobalHadithAudioController audio;
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
          onTap: audio.togglePlay,
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
  final VoidCallback? onTap;
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
  const _ProgressSlider({required this.audio, required this.scheme});
  final GlobalHadithAudioController audio;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration?>(
      stream: audio.player.durationStream,
      builder: (context, durationSnapshot) {
        final duration = durationSnapshot.data ?? Duration.zero;
        return StreamBuilder<Duration>(
          stream: audio.player.positionStream,
          builder: (context, positionSnapshot) {
            final position = positionSnapshot.data ?? Duration.zero;
            final safePosition = position > duration && duration > Duration.zero
                ? duration
                : position;
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
                    inactiveTrackColor: scheme.surfaceContainerHighest,
                    thumbColor: scheme.primary,
                    overlayColor: scheme.primary.withValues(alpha: 0.12),
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
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  // Kedudukan/tempoh dan togol kelajuan dipisahkan kepada
                  // dua baris tetap (bukan satu `Row` + `spaceBetween`).
                  // Gabungan tiga togol kelajuan sahaja sudah cukup lebar
                  // untuk melimpah pada panel sempit (sidebar + kandungan
                  // audio bersebelahan) walaupun dibalut `Wrap` — sebab
                  // togol kelajuan sebagai satu unit tetap tidak boleh
                  // mengecil lagi. Dua baris tetap ini kekal muat pada
                  // sebarang lebar panel yang munasabah.
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_fmt(safePosition),
                              style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontSize: 11)),
                          Text(_fmt(duration),
                              style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // `FittedBox` (skala-turun, bukan sekadar `Row`
                      // dipusatkan) — walaupun dipisahkan ke baris sendiri,
                      // tiga togol kelajuan masih boleh melebihi lebar
                      // panel yang sangat sempit (cth. sidebar + tetingkap
                      // pelayar sempit). `FittedBox` menjamin ia sentiasa
                      // muat dengan mengecilkan togol jika perlu, tanpa
                      // sekali-kali melimpah.
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _SpeedDot(0.75, audio, scheme),
                            const SizedBox(width: 8),
                            _SpeedDot(1.0, audio, scheme),
                            const SizedBox(width: 8),
                            _SpeedDot(1.25, audio, scheme),
                          ],
                        ),
                      ),
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
  const _SpeedDot(this.speed, this.audio, this.scheme);
  final double speed;
  final GlobalHadithAudioController audio;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final selected = audio.speed == speed;
    return GestureDetector(
      onTap: () => audio.setSpeed(speed),
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
      // Senarai ini berada di dalam `SingleChildScrollView` panel, jadi ia
      // sendiri tidak boleh menskrol (satu skrol luar sahaja).
      physics: const NeverScrollableScrollPhysics(),
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
        color: isActive
            ? scheme.primaryContainer.withValues(alpha: 0.7)
            : scheme.surface,
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
                        ? Icon(Icons.volume_up_rounded,
                            color: scheme.onPrimary, size: 20)
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isActive
                                  ? scheme.onPrimaryContainer
                                  : scheme.onSurface)),
                      const SizedBox(height: 2),
                      Text(hadith.theme,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 11,
                              color: isActive
                                  ? scheme.onPrimaryContainer
                                      .withValues(alpha: 0.65)
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
