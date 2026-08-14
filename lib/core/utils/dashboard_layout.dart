import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../constants/app_constants.dart';

/// Keputusan susun atur dashboard berdasarkan lebar kandungan **sebenar**
/// (bukan lebar tetingkap).
///
/// Ini penting kerana kandungan dashboard berada di sebelah sidebar pada
/// desktop — menggunakan `MediaQuery.sizeOf(context).width` akan memberi
/// lebar yang salah dan menyebabkan teks tersepit sehingga pecah huruf demi
/// huruf.
class DashboardLayout {
  const DashboardLayout._(this.contentWidth, this.pagePadding);

  /// Bina daripada kekangan `LayoutBuilder` bagi kawasan kandungan.
  factory DashboardLayout.of(BoxConstraints constraints) {
    final available = constraints.maxWidth.isFinite
        ? constraints.maxWidth
        : AppConstants.maxContentWidth;

    final horizontal = available >= 1200
        ? 32.0
        : available >= 700
            ? 24.0
            : 16.0;
    final padding = EdgeInsets.fromLTRB(
      horizontal,
      available >= 700 ? 24 : 18,
      horizontal,
      available >= 700 ? 32 : 28,
    );

    final content = math.min(
      math.max(available - horizontal * 2, 240.0),
      AppConstants.maxContentWidth,
    );
    return DashboardLayout._(content, padding);
  }

  /// Lebar kandungan selepas ditolak padding dan had lebar maksimum.
  final double contentWidth;
  final EdgeInsets pagePadding;

  bool get isCompact => contentWidth < 660;
  bool get isMedium => contentWidth >= 660 && contentWidth < 1040;
  bool get isExpanded => contentWidth >= 1040;

  /// Tajuk dan medan carian hanya berkongsi baris apabila ada ruang lapang.
  bool get inlineSearch => contentWidth >= 820;

  /// Dua kad kemajuan berdampingan; menegak pada skrin yang sangat sempit.
  bool get sideBySideProgress => contentWidth >= 380;

  /// Kad hero di sebelah kanan kad kemajuan pada desktop.
  bool get heroBesideProgress => contentWidth >= 1040;

  int get moduleColumns {
    if (contentWidth >= 1040) return 4;
    if (contentWidth >= 760) return 3;
    if (contentWidth >= 420) return 2;
    return 1;
  }

  int get panelColumns {
    if (contentWidth >= 1040) return 3;
    if (contentWidth >= 700) return 2;
    return 1;
  }

  double get gap => isCompact ? 12 : 16;
  double get sectionGap => isCompact ? 26 : 34;

  /// Kad modul lebih padat apabila grid menjadi sempit.
  bool get compactModuleCards => contentWidth / moduleColumns < 260;

  /// Lebar setiap item dalam grid [columns] lajur dengan jurang [gap].
  double itemWidth(int columns) =>
      (contentWidth - gap * (columns - 1)) / columns;
}
