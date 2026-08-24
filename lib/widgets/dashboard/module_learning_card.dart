import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/learning_module.dart';
import 'islamic_atmosphere.dart';
import 'module_identity.dart';

/// Kad modul pembelajaran dengan ilustrasi, kemajuan dan status.
class ModuleLearningCard extends StatefulWidget {
  const ModuleLearningCard({
    required this.module,
    required this.progress,
    required this.completedCount,
    required this.availableCount,
    required this.onTap,
    this.compact = false,
    super.key,
  });

  final LearningModule module;
  final double progress;
  final int completedCount;
  final int availableCount;
  final VoidCallback onTap;

  /// Susun atur lebih padat untuk grid dua lajur pada telefon.
  final bool compact;

  @override
  State<ModuleLearningCard> createState() => _ModuleLearningCardState();
}

class _ModuleLearningCardState extends State<ModuleLearningCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final dark = scheme.brightness == Brightness.dark;
    final accent = ModuleIdentity.accentFor(scheme, widget.module.number);

    final total = widget.module.hadithNumbers.length;
    final percent = (widget.progress * 100).round();
    final completed = widget.progress >= 1;
    final pending = widget.availableCount == 0;
    final inProgress = widget.progress > 0 && !completed;

    final statusLabel = pending
        ? 'Akan Datang'
        : completed
            ? 'Selesai'
            : inProgress
                ? 'Sedang Dipelajari'
                : 'Belum Bermula';
    final statusIcon = pending
        ? Icons.schedule_rounded
        : completed
            ? Icons.check_circle_rounded
            : inProgress
                ? Icons.timelapse_rounded
                : Icons.play_circle_outline_rounded;
    // Warna aksen modul (termasuk pink) sengaja diketepikan daripada TEKS
    // kecil (label, peratus, status) — dipakai sebaliknya pada latar
    // kotak/glif/bar kemajuan sahaja, supaya kad kekal mudah dibaca dan
    // tidak "sakit mata" dengan pelbagai teks berwarna.
    final statusColor = pending
        ? scheme.onSurfaceVariant
        : completed
            ? scheme.primary
            : scheme.onSurfaceVariant;

    final padding = widget.compact ? 14.0 : 18.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          // Latar KOTAK (bukan teks — lihat `statusColor`/label di bawah)
          // sengaja dwi-warna hijau→dusty pink pada SETIAP kad modul dalam
          // mod cerah (permintaan pengguna: unsur dusty pink DAN hijau pada
          // semua kotak modul, bukan hanya sebahagian kad seperti sebelum
          // ini). Mod gelap kekal guna aksen per-modul (emas) seperti asal.
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dark
                ? [
                    Color.lerp(scheme.surface, accent, _hovered ? 0.22 : 0.14)!,
                    scheme.surfaceContainerLowest.withValues(alpha: 0.9),
                  ]
                : [
                    Color.lerp(
                        scheme.surface, scheme.primary, _hovered ? 0.2 : 0.13)!,
                    Color.lerp(scheme.surfaceContainerHighest,
                        AppColors.pinkAccent, _hovered ? 0.24 : 0.16)!,
                  ],
          ),
          border: Border.all(
            color: _hovered
                ? (dark
                    ? AppColors.darkGold.withValues(alpha: 0.85)
                    : accent.withValues(alpha: 0.75))
                : scheme.outlineVariant.withValues(alpha: dark ? 0.6 : 1),
            width: _hovered ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: dark
                  ? (_hovered
                      ? AppColors.darkGold.withValues(alpha: 0.22)
                      : Colors.black.withValues(alpha: 0.24))
                  : scheme.shadow.withValues(alpha: _hovered ? 0.16 : 0.06),
              blurRadius: _hovered ? 24 : 14,
              offset: Offset(0, _hovered ? 10 : 4),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: IslamicCardPattern(
                      color: accent,
                      seed: widget.module.number,
                      opacity: _hovered ? 1.15 : 1,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ModuleGlyph(
                            moduleNumber: widget.module.number,
                            size: widget.compact ? 40 : 46,
                            scale: _hovered ? 1.06 : 1,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'MODUL ${widget.module.number.toString().padLeft(2, '0')}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: scheme.onSurfaceVariant,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.module.rangeLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: text.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: widget.compact ? 14 : 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: widget.compact ? 14 : 18),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${widget.completedCount} / $total selesai',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$percent%',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: completed
                                  ? scheme.primary
                                  : scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _ModuleProgressBar(
                        value: widget.progress,
                        accent: accent,
                        track: scheme.surfaceContainerHighest,
                      ),
                      SizedBox(height: widget.compact ? 12 : 14),
                      Row(
                        children: [
                          Icon(statusIcon, size: 15, color: statusColor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              statusLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ),
                          AnimatedOpacity(
                            opacity: _hovered ? 1 : 0.45,
                            duration: const Duration(milliseconds: 180),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _ModuleProgressBar extends StatelessWidget {
  const _ModuleProgressBar({
    required this.value,
    required this.accent,
    required this.track,
  });

  final double value;
  final Color accent;
  final Color track;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: 7,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: track)),
            FractionallySizedBox(
              widthFactor: value.clamp(0.0, 1.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accent.withValues(alpha: 0.85),
                      Color.lerp(accent, Colors.white, 0.25)!,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
