import 'package:flutter/material.dart';

import 'islamic_atmosphere.dart';

/// Kad ringkasan kemajuan (contoh: "Hadis Dipelajari — 0 / 42").
///
/// Susunannya menegak (ikon → nilai → label → bar) supaya kekal selamat pada
/// lebar sempit, dan dua kad bersebelahan mendapat tinggi yang sama apabila
/// dibalut dengan `IntrinsicHeight`.
class LearningProgressCard extends StatelessWidget {
  const LearningProgressCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.total,
    required this.unit,
    required this.progress,
    this.accent,
    this.compact = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final int value;
  final int total;
  final String unit;
  final double progress;
  final Color? accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final dark = scheme.brightness == Brightness.dark;
    final tone = accent ?? scheme.primary;
    final percent = (progress.clamp(0.0, 1.0) * 100).round();

    // Warna khusus untuk corak latar — berasingan daripada `tone` (ikon/
    // cincin/teks). `tone` boleh jadi warna cerah (contoh `scheme.tertiary`
    // pada kad "Modul Selesai"), yang kontrasnya terlalu rendah berbanding
    // latar kad hampir putih dalam mod cerah sehingga corak nyaris tidak
    // kelihatan. Mencampur ke arah `onSurface` menjamin corak sentiasa
    // cukup kontra tanpa menukar warna ikon/teks kad.
    final patternTone = Color.lerp(tone, scheme.onSurface, 0.45)!;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? [
                  Color.lerp(scheme.surface, tone, 0.08)!,
                  scheme.surfaceContainerLowest.withValues(alpha: 0.92),
                ]
              : [
                  scheme.surface,
                  Color.lerp(scheme.surface, tone, 0.06)!,
                ],
        ),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: dark ? 0.6 : 1),
        ),
        boxShadow: [
          BoxShadow(
            color: dark
                ? Colors.black.withValues(alpha: 0.24)
                : scheme.shadow.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IslamicCardPattern(
              color: patternTone,
              seed: label.length,
              opacity: 0.9,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(compact ? 15 : 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: compact ? 36 : 42,
                        height: compact ? 36 : 42,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          color: tone.withValues(alpha: dark ? 0.2 : 0.12),
                          border: Border.all(
                            color: tone.withValues(alpha: 0.32),
                          ),
                        ),
                        child: Icon(
                          icon,
                          size: compact ? 18 : 21,
                          color:
                              dark ? Color.lerp(tone, Colors.white, 0.2) : tone,
                        ),
                      ),
                      SizedBox(height: compact ? 14 : 18),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$value',
                            style: text.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: compact ? 28 : 34,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '/ $total $unit',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: scheme.onSurfaceVariant,
                                fontSize: compact ? 12 : 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: compact ? 13 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: compact ? 10 : 16),
                // Cincin kemajuan (radial) menggantikan jalur nipis di
                // bawah — mengisi ruang mendatar yang kosong di kad lebar
                // (terutama tablet) sambil kekal pada palet warna `tone`
                // yang sama seperti ikon/peratus asal.
                _ProgressRing(
                  progress: progress,
                  percent: percent,
                  tone: tone,
                  dark: dark,
                  trackColor: scheme.surfaceContainerHighest,
                  size: compact ? 58.0 : 72.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Cincin kemajuan radial (trek kelabu + lengkok warna `tone` + peratusan
/// di tengah). Mengekalkan palet warna yang sama seperti ikon/kad induk
/// (`tone` diwarisi terus daripada `LearningProgressCard`).
class _ProgressRing extends StatelessWidget {
  const _ProgressRing({
    required this.progress,
    required this.percent,
    required this.tone,
    required this.dark,
    required this.trackColor,
    required this.size,
  });

  final double progress;
  final int percent;
  final Color tone;
  final bool dark;
  final Color trackColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    final ringColor = dark ? Color.lerp(tone, Colors.white, 0.15)! : tone;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: size * 0.1,
              color: trackColor,
            ),
          ),
          SizedBox.expand(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: clamped),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => CircularProgressIndicator(
                value: value,
                strokeWidth: size * 0.1,
                strokeCap: StrokeCap.round,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(ringColor),
              ),
            ),
          ),
          Text(
            '$percent%',
            style: TextStyle(
              fontSize: size * 0.19,
              fontWeight: FontWeight.w800,
              color: ringColor,
            ),
          ),
        ],
      ),
    );
  }
}
