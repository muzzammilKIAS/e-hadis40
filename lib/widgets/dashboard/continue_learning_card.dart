import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Kad utama "Sambung Pembelajaran" — fokus visual dashboard.
///
/// Menggabungkan gradien emerald→mint, lengkung mihrab, ilustrasi kitab
/// terbuka dan aksen emas halus.
class ContinueLearningCard extends StatefulWidget {
  const ContinueLearningCard({
    required this.badgeLabel,
    required this.headline,
    required this.title,
    required this.actionLabel,
    required this.onAction,
    this.footnote,
    this.wide = false,
    super.key,
  });

  final String badgeLabel;
  final String headline;
  final String title;
  final String actionLabel;
  final VoidCallback onAction;
  final String? footnote;

  /// Susun atur ilustrasi kitab sebelah teks (bukan `LayoutBuilder` dalaman)
  /// — dikira oleh pemanggil kerana kad ini sering dibalut `IntrinsicHeight`,
  /// dan `LayoutBuilder` tidak menyokong pengiraan intrinsic-height dengan
  /// betul (boleh menyebabkan kandungan terpotong).
  final bool wide;

  @override
  State<ContinueLearningCard> createState() => _ContinueLearningCardState();
}

class _ContinueLearningCardState extends State<ContinueLearningCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = scheme.brightness == Brightness.dark;

    final gradientColors = dark
        ? const [
            AppColors.deepEmerald,
            Color(0xFF15654C),
            Color(0xFF2E9C74),
          ]
        : [
            AppColors.primary,
            AppColors.secondary,
            Color.lerp(AppColors.secondary, AppColors.accent, 0.55)!,
          ];

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          border: Border.all(
            color:
                AppColors.goldAccent.withValues(alpha: _hovered ? 0.42 : 0.24),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepEmerald.withValues(alpha: dark ? 0.5 : 0.28),
              blurRadius: _hovered ? 30 : 20,
              offset: Offset(0, _hovered ? 12 : 8),
            ),
          ],
        ),
        child: Builder(
          builder: (context) {
            final wide = widget.wide;
            final padding = wide ? 26.0 : 20.0;

            final content = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColors.goldAccent.withValues(alpha: 0.55),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        size: 13,
                        color: AppColors.softGold,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          widget.badgeLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.5,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: wide ? 18 : 14),
                Text(
                  widget.headline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: wide ? 30 : 24,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.93),
                    fontWeight: FontWeight.w600,
                    fontSize: wide ? 16 : 14.5,
                    height: 1.35,
                  ),
                ),
                if (widget.footnote != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    widget.footnote!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 12.5,
                    ),
                  ),
                ],
                SizedBox(height: wide ? 22 : 18),
                FilledButton.icon(
                  onPressed: widget.onAction,
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: Text(widget.actionLabel),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryHover,
                    minimumSize: const Size(44, 46),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                ),
              ],
            );

            return Stack(
              children: [
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _HeroDecorPainter(
                        glow: _hovered ? 1.12 : 1,
                      ),
                      willChange: false,
                    ),
                  ),
                ),
                if (!wide)
                  const Positioned(
                    right: -14,
                    top: 6,
                    width: 132,
                    height: 132,
                    child: Opacity(
                      opacity: 0.32,
                      child: CustomPaint(
                        painter: _OpenBookPainter(),
                        willChange: false,
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.all(padding),
                  child: wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(child: content),
                            const SizedBox(width: 18),
                            AnimatedScale(
                              scale: _hovered ? 1.04 : 1,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                              child: const SizedBox(
                                width: 150,
                                height: 150,
                                child: CustomPaint(
                                  painter: _OpenBookPainter(),
                                  willChange: false,
                                ),
                              ),
                            ),
                          ],
                        )
                      : content,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Lengkung mihrab + bintang khatam + kilauan emas pada latar kad hero.
class _HeroDecorPainter extends CustomPainter {
  const _HeroDecorPainter({required this.glow});

  final double glow;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    canvas.clipRect(Offset.zero & size);

    // Kilauan lembut di sudut kanan atas.
    final glowRect = Rect.fromCircle(
      center: Offset(size.width * 0.86, -size.height * 0.1),
      radius: size.height * 1.1,
    );
    canvas.drawRect(
      glowRect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.16 * glow),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(glowRect),
    );

    final white = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.16);
    final gold = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = AppColors.softGold.withValues(alpha: 0.34 * glow);

    // Lengkung mihrab berlapis di kanan.
    final archWidth = size.height * 0.9;
    final archRect = Rect.fromLTWH(
      size.width - archWidth * 0.55,
      size.height * 0.1,
      archWidth,
      size.height * 1.02,
    );
    canvas.drawPath(_arch(archRect), gold);
    canvas.drawPath(_arch(archRect.deflate(archWidth * 0.09)), white);

    // Lengkung kecil di kiri bawah untuk kedalaman.
    final smallWidth = size.height * 0.5;
    canvas.drawPath(
      _arch(
        Rect.fromLTWH(
          -smallWidth * 0.35,
          size.height * 0.42,
          smallWidth,
          size.height * 0.85,
        ),
      ),
      white,
    );

    // Titik cahaya emas.
    final random = math.Random(9);
    for (var i = 0; i < 12; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        0.8 + random.nextDouble() * 1.4,
        Paint()
          ..color = AppColors.softGold.withValues(
            alpha: (0.2 + random.nextDouble() * 0.35) * glow,
          ),
      );
    }
  }

  static Path _arch(Rect rect) {
    final path = Path();
    final spring = rect.top + rect.height * 0.44;
    final cx = rect.center.dx;
    path.moveTo(rect.left, rect.bottom);
    path.lineTo(rect.left, spring);
    path.cubicTo(rect.left, spring - rect.height * 0.3, cx - rect.width * 0.3,
        rect.top, cx, rect.top);
    path.cubicTo(cx + rect.width * 0.3, rect.top, rect.right,
        spring - rect.height * 0.3, rect.right, spring);
    path.lineTo(rect.right, rect.bottom);
    return path;
  }

  @override
  bool shouldRepaint(_HeroDecorPainter old) => old.glow != glow;
}

/// Ilustrasi vektor kitab terbuka (tiada aset imej luar).
class _OpenBookPainter extends CustomPainter {
  const _OpenBookPainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    final pageFill = Paint()..color = Colors.white.withValues(alpha: 0.2);
    final pageStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.white.withValues(alpha: 0.68);
    final goldStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = AppColors.softGold.withValues(alpha: 0.72);
    final lineStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.42);

    Path page(bool left) {
      final sign = left ? -1.0 : 1.0;
      final outerX = cx + sign * w * 0.42;
      final path = Path()
        ..moveTo(cx, h * 0.28)
        ..quadraticBezierTo(
          cx + sign * w * 0.2,
          h * 0.2,
          outerX,
          h * 0.3,
        )
        ..lineTo(outerX, h * 0.74)
        ..quadraticBezierTo(
          cx + sign * w * 0.2,
          h * 0.66,
          cx,
          h * 0.76,
        )
        ..close();
      return path;
    }

    for (final left in const [true, false]) {
      final path = page(left);
      canvas.drawPath(path, pageFill);
      canvas.drawPath(path, pageStroke);
    }

    // Tulang belakang kitab.
    canvas.drawLine(Offset(cx, h * 0.28), Offset(cx, h * 0.76), goldStroke);

    // Garis teks halus pada setiap halaman.
    for (var i = 0; i < 3; i++) {
      final y = h * (0.4 + i * 0.1);
      canvas.drawLine(
          Offset(cx - w * 0.32, y), Offset(cx - w * 0.08, y), lineStroke);
      canvas.drawLine(
          Offset(cx + w * 0.08, y), Offset(cx + w * 0.32, y), lineStroke);
    }

    // Bintang khatam kecil di atas kitab — simbol ilmu.
    final starCenter = Offset(cx, h * 0.14);
    final starRadius = w * 0.08;
    for (final rotation in const [0.0, math.pi / 4]) {
      final path = Path();
      for (var i = 0; i < 4; i++) {
        final angle = rotation + math.pi / 4 + i * math.pi / 2;
        final point = Offset(
          starCenter.dx + starRadius * math.cos(angle),
          starCenter.dy + starRadius * math.sin(angle),
        );
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, goldStroke);
    }
  }

  @override
  bool shouldRepaint(_OpenBookPainter oldDelegate) => false;
}
