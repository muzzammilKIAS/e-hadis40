import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Lencana tajuk "Xplorasi Minda" — huruf "X" digantikan kotak ikon X
/// bertema, diikuti "plorasi Minda" dan ikon otak-litar
/// (`assets/images/brain_chip.png`) di sebelah perkataan "Minda". Kotak
/// "X" dan ikon otak kedua-duanya dua kali ganda saiz teks. Digunakan
/// konsisten di mana jua tajuk ini dipaparkan (kad promosi dashboard,
/// tajuk skrin permainan) supaya identiti visual sentiasa sepadan.
///
/// Jika [onBrainTap] diberikan, ikon otak bertindak sebagai butang
/// (bulatan sorotan + reaksi ketuk) yang membuka permainan — digunakan
/// pada kad promosi dashboard, bukan pada tajuk skrin permainan itu
/// sendiri (sudah berada di dalam permainan).
class XplorasiMindaTitle extends StatelessWidget {
  const XplorasiMindaTitle({
    required this.textColor,
    required this.xBoxColor,
    required this.xIconColor,
    this.fontSize = 20,
    this.onBrainTap,
    super.key,
  });

  final Color textColor;
  final Color xBoxColor;
  final Color xIconColor;
  final double fontSize;
  final VoidCallback? onBrainTap;

  @override
  Widget build(BuildContext context) {
    final xBoxSize = fontSize * 2;
    final brainSize = fontSize * 2;
    final gap = fontSize * 0.18;

    Widget brainIcon = Image.asset(
      'assets/images/brain_chip.png',
      width: brainSize,
      height: brainSize,
    );

    if (onBrainTap != null) {
      final buttonSize = brainSize * 1.35;
      brainIcon = Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onBrainTap,
          customBorder: const CircleBorder(),
          child: Tooltip(
            message: 'Mulakan Xplorasi Minda',
            child: Container(
              width: buttonSize,
              height: buttonSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: xBoxColor.withValues(alpha: 0.14),
                border: Border.all(
                  color: xBoxColor.withValues(alpha: 0.5),
                ),
              ),
              child: brainIcon,
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: xBoxSize,
          height: xBoxSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: xBoxColor,
            borderRadius: BorderRadius.circular(xBoxSize * 0.28),
          ),
          child: Icon(
            Icons.close_rounded,
            size: xBoxSize * 0.68,
            color: xIconColor,
          ),
        ),
        SizedBox(width: gap),
        Text(
          'plorasi',
          style: GoogleFonts.baloo2(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: fontSize,
          ),
        ),
        SizedBox(width: gap * 1.6),
        Text(
          'Minda',
          style: GoogleFonts.baloo2(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: fontSize,
          ),
        ),
        SizedBox(width: gap * 1.6),
        brainIcon,
      ],
    );
  }
}
