import 'package:flutter/material.dart';

/// Permukaan kad standard untuk dashboard dan halaman modul.
///
/// Memberi rasa "soft glass" tanpa `BackdropFilter`: permukaan separa lut
/// sinar, sempadan emerald halus, bayang lembut dan highlight dalaman.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 22,
    this.accent,
    this.highlighted = false,
    this.clip = true,
    this.background,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  /// Warna sempadan/highlight. Lalai: `outlineVariant`.
  final Color? accent;

  /// Sempadan lebih terang — untuk keadaan hover atau kad utama.
  final bool highlighted;

  final bool clip;

  /// Override warna latar (gantikan gradien lalai berasaskan `scheme.surface`).
  /// Untuk kotak besar yang membungkus kad lain (contoh: `_InteractiveActivitySection`)
  /// yang perlu kekal lebih cerah daripada kotak biasa.
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = scheme.brightness == Brightness.dark;
    final border = accent ?? scheme.outlineVariant;
    final base = background ?? scheme.surface;

    return Container(
      padding: padding,
      clipBehavior: clip ? Clip.antiAlias : Clip.none,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? [
                  base.withValues(alpha: 0.94),
                  scheme.surfaceContainerLowest.withValues(alpha: 0.82),
                ]
              : [
                  base,
                  base.withValues(alpha: 0.9),
                ],
        ),
        border: Border.all(
          color: highlighted
              ? border.withValues(alpha: dark ? 0.7 : 0.85)
              : border.withValues(alpha: dark ? 0.55 : 1),
          width: highlighted ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: dark
                ? Colors.black.withValues(alpha: 0.28)
                : scheme.shadow.withValues(alpha: 0.05),
            blurRadius: highlighted ? 22 : 14,
            offset: Offset(0, highlighted ? 8 : 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Tajuk seksyen dashboard dengan sub-tajuk dan aksi pilihan.
class DashboardSectionHeader extends StatelessWidget {
  const DashboardSectionHeader({
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.compact = false,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final label = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: compact ? 18 : 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [scheme.primary, scheme.tertiary],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                title,
                style: (compact ? text.titleMedium : text.titleLarge)?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Text(
              subtitle!,
              style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ],
    );

    if (actionLabel == null || onAction == null) return label;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: label),
        const SizedBox(width: 12),
        TextButton.icon(
          onPressed: onAction,
          iconAlignment: IconAlignment.end,
          icon: const Icon(Icons.chevron_right_rounded, size: 20),
          label: Text(actionLabel!),
          style: TextButton.styleFrom(
            foregroundColor: scheme.primary,
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
