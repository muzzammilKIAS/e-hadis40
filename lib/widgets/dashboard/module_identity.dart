import 'package:flutter/material.dart';

/// Identiti visual bagi setiap modul.
///
/// Setiap modul mendapat ikon tema dan aksen warnanya sendiri dalam keluarga
/// emerald → mint, supaya lapan kad modul dapat dibezakan secara halus tanpa
/// keluar daripada palet aplikasi.
class ModuleIdentity {
  const ModuleIdentity._();

  static const _icons = <IconData>[
    Icons.menu_book_rounded, // 1 — kitab terbuka
    Icons.wb_incandescent_rounded, // 2 — cahaya ilmu
    Icons.record_voice_over_rounded, // 3 — ilmu & penyampaian
    Icons.mosque_rounded, // 4 — lengkung masjid
    Icons.description_rounded, // 5 — nota / dokumen
    Icons.auto_stories_rounded, // 6 — pembacaan
    Icons.school_rounded, // 7 — pembelajaran
    Icons.workspace_premium_rounded, // 8 — kesempurnaan modul
  ];

  static IconData iconFor(int moduleNumber) =>
      _icons[(moduleNumber - 1).clamp(0, _icons.length - 1)];

  /// Aksen modul: interpolasi primary → tertiary mengikut nombor modul.
  static Color accentFor(ColorScheme scheme, int moduleNumber) {
    final t = ((moduleNumber - 1) / 7).clamp(0.0, 1.0) * 0.75;
    return Color.lerp(scheme.primary, scheme.tertiary, t)!;
  }
}

/// Lambang modul: petak bulat bergradien dengan lengkung halus dan ikon tema.
class ModuleGlyph extends StatelessWidget {
  const ModuleGlyph({
    required this.moduleNumber,
    this.size = 48,
    this.scale = 1,
    super.key,
  });

  final int moduleNumber;
  final double size;

  /// Skala mikro-interaksi semasa hover (1.0 – 1.06).
  final double scale;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = ModuleIdentity.accentFor(scheme, moduleNumber);
    final dark = scheme.brightness == Brightness.dark;

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: Container(
        width: size,
        height: size,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.3),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accent.withValues(alpha: dark ? 0.32 : 0.2),
              accent.withValues(alpha: dark ? 0.14 : 0.08),
            ],
          ),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _GlyphArchPainter(
                  color: accent.withValues(alpha: dark ? 0.4 : 0.28),
                ),
                willChange: false,
              ),
            ),
            Icon(
              ModuleIdentity.iconFor(moduleNumber),
              size: size * 0.46,
              color: dark
                  ? Color.lerp(accent, Colors.white, 0.28)
                  : Color.lerp(accent, Colors.black, 0.12),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlyphArchPainter extends CustomPainter {
  const _GlyphArchPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color;

    final width = size.width * 0.62;
    final rect = Rect.fromLTWH(
      (size.width - width) / 2,
      size.height * 0.18,
      width,
      size.height * 0.9,
    );

    final path = Path();
    final spring = rect.top + rect.height * 0.45;
    final cx = rect.center.dx;
    path.moveTo(rect.left, rect.bottom);
    path.lineTo(rect.left, spring);
    path.cubicTo(rect.left, spring - rect.height * 0.32, cx - rect.width * 0.3,
        rect.top, cx, rect.top);
    path.cubicTo(cx + rect.width * 0.3, rect.top, rect.right,
        spring - rect.height * 0.32, rect.right, spring);
    path.lineTo(rect.right, rect.bottom);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_GlyphArchPainter old) => old.color != color;
}
