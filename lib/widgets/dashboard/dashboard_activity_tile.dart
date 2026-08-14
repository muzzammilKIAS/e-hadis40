import 'package:flutter/material.dart';

/// Baris kandungan padat: ikon kiri → teks → anak panah kanan.
///
/// Digunakan untuk senarai sekunder dashboard (terakhir dibaca, bookmark,
/// pintasan) dan senarai hadis dalam halaman modul.
class DashboardActivityTile extends StatefulWidget {
  const DashboardActivityTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.leadingLabel,
    this.trailing,
    this.accent,
    this.onTap,
    this.dense = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  /// Teks pendek dalam petak ikon (contoh nombor hadis "07").
  final String? leadingLabel;

  final Widget? trailing;
  final Color? accent;
  final VoidCallback? onTap;
  final bool dense;

  @override
  State<DashboardActivityTile> createState() => _DashboardActivityTileState();
}

class _DashboardActivityTileState extends State<DashboardActivityTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final dark = scheme.brightness == Brightness.dark;
    final tone = widget.accent ?? scheme.primary;
    final interactive = widget.onTap != null;
    final active = _hovered && interactive;
    final box = widget.dense ? 38.0 : 44.0;

    return MouseRegion(
      cursor: interactive ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 170),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, active ? -2 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: dark
              ? scheme.surface.withValues(alpha: active ? 0.95 : 0.78)
              : scheme.surface,
          border: Border.all(
            color: active
                ? tone.withValues(alpha: 0.6)
                : scheme.outlineVariant.withValues(alpha: dark ? 0.5 : 1),
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: widget.dense ? 12 : 14,
                vertical: widget.dense ? 10 : 12,
              ),
              child: Row(
                children: [
                  Container(
                    width: box,
                    height: box,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      color: tone.withValues(alpha: dark ? 0.18 : 0.11),
                      border: Border.all(
                        color: tone.withValues(alpha: 0.3),
                      ),
                    ),
                    child: widget.leadingLabel != null
                        ? Text(
                            widget.leadingLabel!,
                            style: TextStyle(
                              color: dark
                                  ? Color.lerp(tone, Colors.white, 0.25)
                                  : tone,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          )
                        : Icon(
                            widget.icon,
                            size: widget.dense ? 18 : 20,
                            color: dark
                                ? Color.lerp(tone, Colors.white, 0.25)
                                : tone,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: widget.dense ? 13 : 14,
                            height: 1.3,
                          ),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (widget.trailing != null) ...[
                    const SizedBox(width: 8),
                    widget.trailing!,
                  ],
                  if (interactive) ...[
                    const SizedBox(width: 4),
                    AnimatedOpacity(
                      opacity: active ? 1 : 0.5,
                      duration: const Duration(milliseconds: 170),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: active ? tone : scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
