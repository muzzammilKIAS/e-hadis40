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
              color: tone,
              seed: label.length,
              opacity: 0.9,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(compact ? 15 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
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
                    const Spacer(),
                    Text(
                      '$percent%',
                      style: TextStyle(
                        fontSize: compact ? 11.5 : 12.5,
                        fontWeight: FontWeight.w700,
                        color: tone,
                      ),
                    ),
                  ],
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
                SizedBox(height: compact ? 12 : 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: SizedBox(
                    height: 7,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ColoredBox(
                            color: scheme.surfaceContainerHighest,
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: progress.clamp(0.0, 1.0),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  tone.withValues(alpha: 0.85),
                                  Color.lerp(tone, Colors.white, 0.3)!,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
