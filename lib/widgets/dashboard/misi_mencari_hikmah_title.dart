import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Lencana tajuk "Misi Mencari Hikmah" — huruf "M" digantikan kotak ikon
/// bertema (selari dengan kotak "X" pada [XplorasiMindaTitle]), diikuti
/// "isi Mencari Hikmah" dan ikon lampu hikmah di hujung. Digunakan
/// konsisten di kad promosi dashboard dan tajuk skrin permainan supaya
/// identiti visual kedua-dua aktiviti interaktif sepadan.
///
/// Jika [onIconTap] diberikan, ikon lampu bertindak sebagai butang (bulatan
/// sorotan + reaksi ketuk) yang membuka permainan.
class MisiMencariHikmahTitle extends StatelessWidget {
  const MisiMencariHikmahTitle({
    required this.textColor,
    required this.mBoxColor,
    required this.mIconColor,
    this.fontSize = 20,
    this.onIconTap,
    super.key,
  });

  final Color textColor;
  final Color mBoxColor;
  final Color mIconColor;
  final double fontSize;
  final VoidCallback? onIconTap;

  @override
  Widget build(BuildContext context) {
    final mBoxSize = fontSize * 2;
    final iconSize = fontSize * 2;
    final gap = fontSize * 0.18;

    Widget hikmahIcon = Icon(
      Icons.lightbulb_rounded,
      size: iconSize * 0.72,
      color: mBoxColor,
    );

    if (onIconTap != null) {
      final buttonSize = iconSize * 1.35;
      hikmahIcon = Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onIconTap,
          customBorder: const CircleBorder(),
          child: Tooltip(
            message: 'Mulakan Misi Mencari Hikmah',
            child: Container(
              width: buttonSize,
              height: buttonSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: mBoxColor.withValues(alpha: 0.14),
                border: Border.all(
                  color: mBoxColor.withValues(alpha: 0.5),
                ),
              ),
              child: hikmahIcon,
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
          width: mBoxSize,
          height: mBoxSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: mBoxColor,
            borderRadius: BorderRadius.circular(mBoxSize * 0.28),
          ),
          child: Text(
            'M',
            style: GoogleFonts.baloo2(
              color: mIconColor,
              fontWeight: FontWeight.w800,
              fontSize: mBoxSize * 0.56,
              height: 1,
            ),
          ),
        ),
        SizedBox(width: gap),
        Text(
          'isi',
          style: GoogleFonts.baloo2(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: fontSize,
          ),
        ),
        SizedBox(width: gap * 1.6),
        Text(
          'Mencari',
          style: GoogleFonts.baloo2(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: fontSize,
          ),
        ),
        SizedBox(width: gap * 1.6),
        Text(
          'Hikmah',
          style: GoogleFonts.baloo2(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: fontSize,
          ),
        ),
        SizedBox(width: gap * 1.6),
        hikmahIcon,
      ],
    );
  }
}
