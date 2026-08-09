import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';

class AppTheme {
  const AppTheme._();

  static TextTheme _buildTextTheme(ColorScheme scheme) {
    final base = GoogleFonts.poppinsTextTheme();
    return base.copyWith(
      displaySmall: base.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.15,
        color: scheme.onSurface,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.2,
        color: scheme.onSurface,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: scheme.onSurface,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: scheme.onSurface,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: scheme.onSurface,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        height: 1.6,
        color: scheme.onSurface,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        height: 1.55,
        color: scheme.onSurface,
      ),
      bodySmall: base.bodySmall?.copyWith(
        height: 1.45,
        color: scheme.onSurfaceVariant,
      ),
    );
  }

  static ThemeData get light {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.deepEmerald,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFDCECE5),
      onPrimaryContainer: AppColors.deepEmerald,
      secondary: AppColors.antiqueGold,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFF2E8CF),
      onSecondaryContainer: Color(0xFF5B4518),
      tertiary: AppColors.emerald,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFC8EAD8),
      onTertiaryContainer: Color(0xFF0A3122),
      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surface: AppColors.warmIvory,
      onSurface: AppColors.lightText,
      surfaceContainerHighest: Color(0xFFEFEAE0),
      surfaceContainerLowest: Color(0xFFF8F7F3),
      onSurfaceVariant: AppColors.lightMuted,
      outline: Color(0xFF8A938E),
      outlineVariant: AppColors.warmStone,
      shadow: Color(0x22000000),
      scrim: Color(0x99000000),
      inverseSurface: AppColors.midnightNavy,
      onInverseSurface: Colors.white,
      inversePrimary: Color(0xFF8BD5B3),
      surfaceTint: AppColors.deepEmerald,
    );

    return _base(scheme, _buildTextTheme(scheme)).copyWith(
      scaffoldBackgroundColor: AppColors.lightBackground,
    );
  }

  static ThemeData get dark {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.darkEmeraldAccent,
      onPrimary: Color(0xFF003828),
      primaryContainer: Color(0xFF174B3A),
      onPrimaryContainer: Color(0xFFB6F0D3),
      secondary: AppColors.darkGold,
      onSecondary: Color(0xFF3D2E00),
      secondaryContainer: Color(0xFF554510),
      onSecondaryContainer: Color(0xFFF3DEA0),
      tertiary: AppColors.darkEmeraldAccent,
      onTertiary: Color(0xFF003828),
      tertiaryContainer: AppColors.darkActiveWordBg,
      onTertiaryContainer: Color(0xFFE0F5EA),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkText,
      surfaceContainerHighest: AppColors.darkSurfaceTwo,
      surfaceContainerLowest: AppColors.darkBackground,
      onSurfaceVariant: AppColors.darkMuted,
      outline: Color(0xFF5A6B63),
      outlineVariant: AppColors.darkBorder,
      shadow: Colors.black,
      scrim: Color(0xCC000000),
      inverseSurface: AppColors.darkText,
      onInverseSurface: AppColors.darkBackground,
      inversePrimary: AppColors.deepEmerald,
      surfaceTint: AppColors.darkEmeraldAccent,
    );

    return _base(scheme, _buildTextTheme(scheme)).copyWith(
      scaffoldBackgroundColor: AppColors.darkBackground,
    );
  }

  static ThemeData _base(ColorScheme scheme, TextTheme textTheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: textTheme,
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 68,
        titleSpacing: 16,
        shape: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: BorderSide(color: scheme.error),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(44, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(44, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(44, 44),
        ),
      ),
      chipTheme: ChipThemeData(
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        labelStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 13,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      tooltipTheme: TooltipThemeData(
        constraints: const BoxConstraints(maxWidth: 340),
        padding: const EdgeInsets.all(AppSpacing.lg),
        margin: const EdgeInsets.all(AppSpacing.md),
        waitDuration: const Duration(milliseconds: 450),
        showDuration: const Duration(seconds: 8),
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        textStyle: TextStyle(
          color: scheme.onInverseSurface,
          height: 1.45,
          fontSize: 13,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            color: scheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.dialog),
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
}
