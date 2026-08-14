import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Latar belakang berlapis untuk dashboard dan halaman modul.
///
/// Empat lapisan mengikut spesifikasi reka bentuk:
///  1. base emerald gradient;
///  2. seni bina Islamik halus (lengkung mihrab + jalinan girih bintang
///     lapan mata bertindih, memudar dari sudut — meniru jubin Islamik
///     klasik);
///  3. glow emerald/mint lembut;
///  4. titik cahaya emas yang sangat halus.
///
/// Semua lapisan dilukis dengan `CustomPainter` menggunakan gradient shader —
/// tiada `BackdropFilter` atau `MaskFilter` supaya Flutter Web kekal lancar.
class IslamicAtmosphere extends StatelessWidget {
  const IslamicAtmosphere({
    required this.child,
    this.intensity = 1,
    super.key,
  });

  final Widget child;

  /// 0 = tiada corak, 1 = kekuatan penuh. Sidebar guna nilai lebih rendah.
  final double intensity;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = scheme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [
                  AppColors.darkAtmosphereBase,
                  AppColors.darkBackground,
                  Color(0xFF0B1A16),
                ]
              : const [
                  AppColors.lightBackground,
                  AppColors.lightAtmosphereBase,
                  Color(0xFFEDF6F1),
                ],
          stops: const [0, 0.55, 1],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: CustomPaint(
              painter: _AtmospherePainter(
                dark: dark,
                intensity: intensity,
                glow: dark
                    ? AppColors.darkAtmosphereGlow
                    : AppColors.lightAtmosphereGlow,
                line: dark ? AppColors.darkAccent : AppColors.primary,
                gold: dark ? AppColors.darkGold : AppColors.gold,
                sage: AppColors.deepSage,
              ),
              isComplex: true,
              willChange: false,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _AtmospherePainter extends CustomPainter {
  const _AtmospherePainter({
    required this.dark,
    required this.intensity,
    required this.glow,
    required this.line,
    required this.gold,
    required this.sage,
  });

  final bool dark;
  final double intensity;
  final Color glow;
  final Color line;
  final Color gold;
  final Color sage;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || intensity <= 0) return;
    final bounds = Offset.zero & size;
    canvas.clipRect(bounds);

    _paintGlow(canvas, size);
    _paintRainbowWhisper(canvas, size);
    _paintGoldGlow(canvas, size);
    _paintSageAccent(canvas, size);
    _paintArches(canvas, size);
    _paintTessellation(canvas, size);
    _paintGoldMotes(canvas, size);
  }

  /// Aksen sage gelap — hanya ketara dalam light mode supaya latar siang
  /// ada "berat" dan kedalaman tanpa jadi gelap keseluruhan.
  void _paintSageAccent(Canvas canvas, Size size) {
    if (dark) return;
    final strength = 0.22 * intensity;
    if (strength <= 0) return;

    void blob(Offset center, double radius, double alpha) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawRect(
        rect,
        Paint()
          ..shader = RadialGradient(
            colors: [
              sage.withValues(alpha: alpha * strength),
              sage.withValues(alpha: 0),
            ],
          ).createShader(rect),
      );
    }

    // Dijauhkan daripada bucu atas supaya kawasan app bar / tajuk kekal
    // cerah — hanya bahagian bawah skrin dapat sedikit "berat" sage.
    blob(Offset(size.width * -0.05, size.height * 0.62), size.shortestSide * 0.4,
        0.16);
    blob(Offset(size.width * 1.02, size.height * 1.02), size.shortestSide * 0.5,
        0.14);
  }

  /// Kilauan emas lembut — hanya ketara dalam dark mode supaya dashboard
  /// malam "naik seri" tanpa menenggelamkan emerald sebagai warna utama.
  void _paintGoldGlow(Canvas canvas, Size size) {
    if (!dark) return;
    final strength = 0.32 * intensity;
    if (strength <= 0) return;

    void blob(Offset center, double radius, double alpha) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawRect(
        rect,
        Paint()
          ..blendMode = BlendMode.plus
          ..shader = RadialGradient(
            colors: [
              gold.withValues(alpha: alpha * strength),
              gold.withValues(alpha: 0),
            ],
          ).createShader(rect),
      );
    }

    blob(Offset(size.width * 0.5, size.height * 1.02), size.shortestSide * 0.7,
        1);
    blob(Offset(size.width * 0.96, size.height * 0.85), size.shortestSide * 0.5,
        0.65);
  }

  /// Lapisan tambahan — kilauan pelangi yang sangat halus, berlapis di atas
  /// glow emerald supaya hijau kekal dominan. Setiap blob warna dilukis pada
  /// alpha rendah (≤ ~0.05) menggunakan radial gradient sahaja — tiada blur —
  /// jadi kesannya adalah "bayang warna", bukan warna solid yang menonjol.
  void _paintRainbowWhisper(Canvas canvas, Size size) {
    final strength = (dark ? 0.55 : 0.4) * intensity;
    if (strength <= 0) return;

    const colors = AppColors.rainbowWhisper;
    final anchors = <Offset>[
      Offset(size.width * 0.14, size.height * 0.16),
      Offset(size.width * 0.5, size.height * 0.02),
      Offset(size.width * 0.86, size.height * 0.22),
      Offset(size.width * 0.94, size.height * 0.58),
      Offset(size.width * 0.78, size.height * 0.92),
      Offset(size.width * 0.28, size.height * 0.86),
      Offset(size.width * 0.02, size.height * 0.46),
    ];

    for (var i = 0; i < colors.length; i++) {
      final center = anchors[i % anchors.length];
      final radius = size.shortestSide * 0.34;
      final rect = Rect.fromCircle(center: center, radius: radius);
      final alpha = 0.05 * strength;
      canvas.drawRect(
        rect,
        Paint()
          ..blendMode = BlendMode.plus
          ..shader = RadialGradient(
            colors: [
              colors[i].withValues(alpha: alpha),
              colors[i].withValues(alpha: 0),
            ],
          ).createShader(rect),
      );
    }
  }

  /// Lapisan 3 — glow emerald/mint menggunakan radial gradient (bukan blur).
  void _paintGlow(Canvas canvas, Size size) {
    final strength = (dark ? 0.5 : 0.38) * intensity;

    void blob(Offset center, double radius, double alpha) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawRect(
        rect,
        Paint()
          ..shader = RadialGradient(
            colors: [
              glow.withValues(alpha: alpha * strength),
              glow.withValues(alpha: 0),
            ],
          ).createShader(rect),
      );
    }

    blob(Offset(size.width * 0.78, size.height * 0.06), size.shortestSide * 0.9,
        1);
    blob(Offset(size.width * 0.05, size.height * 0.72), size.shortestSide * 0.8,
        0.7);
  }

  /// Lapisan 2a — siluet lengkung mihrab / kubah.
  void _paintArches(Canvas canvas, Size size) {
    final alpha = (dark ? 0.042 : 0.03) * intensity;
    if (alpha <= 0.002) return;

    final fill = Paint()..color = line.withValues(alpha: alpha);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = line.withValues(alpha: alpha * 1.5);

    // Barisan lengkung di bahagian bawah — rasa skyline masjid.
    final archWidth = math.max(size.width / 5, 190.0);
    final archHeight = math.min(size.height * 0.46, archWidth * 1.55);
    final count = (size.width / archWidth).ceil() + 1;
    for (var i = 0; i < count; i++) {
      final left = i * archWidth - archWidth * 0.18;
      final rect = Rect.fromLTWH(
        left,
        size.height - archHeight,
        archWidth * 0.72,
        archHeight,
      );
      canvas.drawPath(_archPath(rect), fill);
    }

    // Satu mihrab besar sebagai fokus di kanan atas.
    final mihrabWidth = math.min(size.width * 0.34, 460.0);
    final mihrabRect = Rect.fromLTWH(
      size.width - mihrabWidth * 0.82,
      -size.height * 0.06,
      mihrabWidth,
      math.min(size.height * 0.92, mihrabWidth * 1.6),
    );
    canvas.drawPath(_archPath(mihrabRect), stroke);
    canvas.drawPath(
      _archPath(mihrabRect.deflate(mihrabWidth * 0.09)),
      stroke,
    );
  }

  /// Lapisan 2b — jalinan girih bintang lapan mata (khatam) bertindih,
  /// disusun dalam kekisi segitiga dan memudar dari sudut — corak jubin
  /// Islamik klasik, bukan "bunga" tunggal yang menonjol.
  void _paintTessellation(Canvas canvas, Size size) {
    final baseAlpha = (dark ? 0.05 : 0.034) * intensity;
    if (baseAlpha <= 0.002) return;

    final unit = math.max(size.shortestSide * 0.048, 22.0);
    _paintTessellationField(
      canvas,
      size,
      anchor: Offset(0, size.height),
      dirX: 1,
      dirY: -1,
      maxDist: size.shortestSide * 0.6,
      unit: unit,
      alpha: baseAlpha,
    );
    _paintTessellationField(
      canvas,
      size,
      anchor: Offset(size.width, 0),
      dirX: -1,
      dirY: 1,
      maxDist: size.shortestSide * 0.3,
      unit: unit * 0.82,
      alpha: baseAlpha * 0.7,
    );
  }

  void _paintTessellationField(
    Canvas canvas,
    Size size, {
    required Offset anchor,
    required double dirX,
    required double dirY,
    required double maxDist,
    required double unit,
    required double alpha,
  }) {
    final dx = unit * 1.5;
    final dy = unit * 1.3;
    final cols = (maxDist / dx).ceil() + 2;
    final rows = (maxDist / dy).ceil() + 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var r = -1; r < rows; r++) {
      for (var c = -1; c < cols; c++) {
        final localX = c * dx + (r.isOdd ? dx / 2 : 0);
        final localY = r * dy;
        final center = anchor + Offset(dirX * localX, dirY * localY);
        final dist = (center - anchor).distance;
        if (dist > maxDist) continue;
        final falloff = (1 - dist / maxDist).clamp(0.0, 1.0);
        final a = alpha * math.pow(falloff, 1.3);
        if (a < 0.0025) continue;
        paint.color = line.withValues(alpha: a);
        _drawIslamicStar(canvas, center, unit * 0.56, paint);
      }
    }
  }

  /// Lapisan 4 — titik cahaya emas yang sangat halus.
  void _paintGoldMotes(Canvas canvas, Size size) {
    final alpha = (dark ? 0.38 : 0.14) * intensity;
    if (alpha <= 0.01) return;

    final random = math.Random(40);
    final paint = Paint();
    final count = dark ? 34 : 22;
    for (var i = 0; i < count; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      final radius = dark
          ? 0.9 + random.nextDouble() * 1.9
          : 0.8 + random.nextDouble() * 1.4;
      paint.color = gold.withValues(
        alpha: alpha * (0.35 + random.nextDouble() * 0.65),
      );
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_AtmospherePainter old) =>
      old.dark != dark ||
      old.intensity != intensity ||
      old.glow != glow ||
      old.line != line ||
      old.gold != gold ||
      old.sage != sage;
}

/// Lengkung ogival (mihrab) yang muat dalam [rect].
Path _archPath(Rect rect) {
  final path = Path();
  final spring = rect.top + rect.height * 0.42;
  final cx = rect.center.dx;
  final lift = rect.height * 0.3;
  final waist = rect.width * 0.3;

  path.moveTo(rect.left, rect.bottom);
  path.lineTo(rect.left, spring);
  path.cubicTo(rect.left, spring - lift, cx - waist, rect.top, cx, rect.top);
  path.cubicTo(
      cx + waist, rect.top, rect.right, spring - lift, rect.right, spring);
  path.lineTo(rect.right, rect.bottom);
  path.close();
  return path;
}

/// Bintang lapan mata (khatam / rub el hizb) — dua segi empat sama bertindih
/// pada 45°. Motif geometri Islamik klasik yang meluas dalam seni bina
/// masjid dan penanda Quran; unit asas bagi jalinan girih dalam
/// [_AtmospherePainter] dan [IslamicCardPattern] — garisan nipis yang saling
/// bertindih, bukan bentuk berisi.
void _drawIslamicStar(
    Canvas canvas, Offset center, double radius, Paint paint) {
  for (final rotation in const [0.0, math.pi / 4]) {
    final path = Path();
    for (var i = 0; i < 4; i++) {
      final angle = rotation - math.pi / 2 + i * (math.pi / 2);
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }
}

/// Corak hiasan dalam kad — versi ringan bagi [IslamicAtmosphere].
///
/// Serpihan kecil jalinan bintang lapan mata yang timbul dari satu sudut kad dan
/// memudar ke tengah — garisan nipis sahaja (tiada isian, tiada lengkung
/// mihrab berganda) supaya kekal halus dan tidak bersaing dengan kandungan
/// kad.
class IslamicCardPattern extends StatelessWidget {
  const IslamicCardPattern({
    required this.color,
    this.seed = 0,
    this.opacity = 1,
    super.key,
  });

  final Color color;

  /// Menggeser serpihan corak supaya kad bersebelahan tidak kelihatan sama.
  final int seed;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _CardPatternPainter(
            color: color,
            seed: seed,
            opacity: opacity,
          ),
          willChange: false,
        ),
      ),
    );
  }
}

class _CardPatternPainter extends CustomPainter {
  const _CardPatternPainter({
    required this.color,
    required this.seed,
    required this.opacity,
  });

  final Color color;
  final int seed;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || opacity <= 0) return;
    canvas.clipRect(Offset.zero & size);

    final baseAlpha = 0.1 * opacity;
    if (baseAlpha <= 0.002) return;

    final unit = math.max(size.height * 0.15, 13.0);
    final dx = unit * 1.5;
    final dy = unit * 1.3;
    final jitter = (seed % 4) * dx * 0.18;
    final corner = Offset(size.width + unit * 0.4, -unit * 0.5);
    final maxDist = size.shortestSide * 1.05;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var r = 0; r < 4; r++) {
      for (var c = 0; c < 4; c++) {
        final localX = c * dx + (r.isOdd ? dx / 2 : 0) + jitter;
        final localY = r * dy;
        final center = corner - Offset(localX, -localY);
        final dist = (center - corner).distance;
        if (dist > maxDist) continue;
        final falloff = (1 - dist / maxDist).clamp(0.0, 1.0);
        final a = baseAlpha * math.pow(falloff, 1.1);
        if (a < 0.006) continue;
        paint.color = color.withValues(alpha: a);
        _drawIslamicStar(canvas, center, unit * 0.56, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_CardPatternPainter old) =>
      old.color != color || old.seed != seed || old.opacity != opacity;
}
