import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'islamic_atmosphere.dart';
import 'module_identity.dart';

/// Kad hadis untuk senarai "Anatomi Sunnah 3D" — gaya kotak sama seperti
/// [ModuleLearningCard] (gradien, corak Islamik, hover terapung) supaya
/// senarai 42 hadis kekal konsisten dengan bahasa visual kad modul,
/// diwarnakan penuh ikut `ColorScheme` semasa (light/dark).
class AnatomiSunnahHadithCard extends StatefulWidget {
  const AnatomiSunnahHadithCard({
    required this.hadithNumber,
    required this.moduleNumber,
    required this.title,
    required this.available,
    required this.onTap,
    this.compact = false,
    super.key,
  });

  final int hadithNumber;
  final int moduleNumber;
  final String title;
  final bool available;
  final VoidCallback? onTap;
  final bool compact;

  @override
  State<AnatomiSunnahHadithCard> createState() =>
      _AnatomiSunnahHadithCardState();
}

class _AnatomiSunnahHadithCardState extends State<AnatomiSunnahHadithCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = scheme.brightness == Brightness.dark;
    final accent = ModuleIdentity.accentFor(scheme, widget.moduleNumber);
    final padding = widget.compact ? 14.0 : 18.0;

    final statusLabel = widget.available ? 'Sedia Dimainkan' : 'Akan Datang';
    final statusIcon = widget.available
        ? Icons.play_circle_outline_rounded
        : Icons.schedule_rounded;
    final statusColor = widget.available ? accent : scheme.onSurfaceVariant;

    return MouseRegion(
      cursor: widget.available
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(
          0,
          _hovered && widget.available ? -4 : 0,
          0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.available
                ? (dark
                    ? [
                        Color.lerp(scheme.surface, accent, 0.06)!,
                        scheme.surfaceContainerLowest.withValues(alpha: 0.9),
                      ]
                    : [
                        Color.lerp(scheme.surface, AppColors.deepSage,
                            _hovered ? 0.1 : 0.045)!,
                        Color.lerp(scheme.surfaceContainerHighest,
                            AppColors.deepSage, _hovered ? 0.08 : 0.03)!,
                      ])
                : [
                    scheme.surfaceContainerLowest,
                    scheme.surfaceContainerLowest,
                  ],
          ),
          border: Border.all(
            color: _hovered && widget.available
                ? (dark
                    ? AppColors.darkGold.withValues(alpha: 0.85)
                    : accent.withValues(alpha: 0.75))
                : scheme.outlineVariant.withValues(alpha: dark ? 0.6 : 1),
            width: _hovered && widget.available ? 1.4 : 1,
          ),
          boxShadow: widget.available
              ? [
                  BoxShadow(
                    color: dark
                        ? (_hovered
                            ? AppColors.darkGold.withValues(alpha: 0.22)
                            : Colors.black.withValues(alpha: 0.24))
                        : scheme.shadow
                            .withValues(alpha: _hovered ? 0.16 : 0.06),
                    blurRadius: _hovered ? 24 : 14,
                    offset: Offset(0, _hovered ? 10 : 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(22),
            child: Opacity(
              opacity: widget.available ? 1 : 0.6,
              child: Stack(
                children: [
                  if (widget.available)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: IslamicCardPattern(
                          color: accent,
                          seed: widget.hadithNumber,
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
                            Container(
                              width: widget.compact ? 40 : 46,
                              height: widget.compact ? 40 : 46,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    accent.withValues(alpha: dark ? 0.32 : 0.2),
                                    accent.withValues(
                                        alpha: dark ? 0.14 : 0.08),
                                  ],
                                ),
                                border: Border.all(
                                  color: accent.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Text(
                                widget.hadithNumber.toString().padLeft(2, '0'),
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: widget.compact ? 14 : 16,
                                  color: dark
                                      ? Color.lerp(accent, Colors.white, 0.28)
                                      : Color.lerp(accent, Colors.black, 0.12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'HADIS ${widget.hadithNumber.toString().padLeft(2, '0')}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: accent,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: widget.compact ? 12 : 14),
                        Text(
                          widget.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: widget.compact ? 14 : 15.5,
                                  ),
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
                            if (widget.available)
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
      ),
    );
  }
}
