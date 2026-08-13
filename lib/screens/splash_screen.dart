import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';

/// e-Hadis40 Emerald Motion Splash (SILENT).
///
/// Sequence:
///   1. background + iridescent aurora fade in
///   2. 3D logo MARK reveal (official app icon, layered depth + perspective)
///   3. brand wordmark "e-Hadis" + "40" horizontal lockup reveal
///   4. subtitle fade + slide up
///   5. light sweep
///   6. hold
///   7. -> Disclaimer dialog (bukan terus Dashboard)
///
/// Tiada audio, tiada AudioPlayer, tiada side-effect kepada audio global.
class AppSplashScreen extends StatefulWidget {
  const AppSplashScreen({required this.onComplete, super.key});

  final VoidCallback onComplete;

  @override
  State<AppSplashScreen> createState() => _AppSplashScreenState();
}

class _AppSplashScreenState extends State<AppSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _aurora;
  late final Animation<double> _markOpacity;
  late final Animation<double> _markScale;
  late final Animation<double> _markRotateY;
  late final Animation<double> _wordOpacity;
  late final Animation<double> _badgeOpacity;
  late final Animation<double> _badgeScale;
  late final Animation<double> _subtitleOpacity;
  late final Animation<double> _subtitleSlide;
  late final Animation<double> _sweep;

  bool _reducedMotion = false;
  bool _reducedMotionResolved = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2700),
    );

    _aurora = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.00, 0.35, curve: Curves.easeOut),
    );

    _markOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.05, 0.30, curve: Curves.easeOutCubic),
    );
    _markScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.72, end: 1.07)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.07, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.05, 0.40, curve: Curves.easeOut),
      ),
    );
    _markRotateY = Tween<double>(begin: -0.10, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.05, 0.40, curve: Curves.easeOutCubic),
      ),
    );

    _wordOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.24, 0.44, curve: Curves.easeOutCubic),
    );

    _badgeOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.34, 0.52, curve: Curves.easeOutCubic),
    );
    _badgeScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.82, end: 1.03)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.03, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.34, 0.56, curve: Curves.easeOut),
      ),
    );

    _subtitleOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.48, 0.66, curve: Curves.easeOutCubic),
    );
    _subtitleSlide = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.48, 0.66, curve: Curves.easeOutCubic),
    );

    _sweep = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.66, 0.84, curve: Curves.easeInOut),
    );

    _controller.forward().whenComplete(() {
      if (mounted) _showDisclaimer();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_reducedMotionResolved) {
      _reducedMotionResolved = true;
      _reducedMotion =
          MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showDisclaimer() async {
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _DisclaimerDialog(),
    );
    if (!mounted) return;
    // accepted boleh null (back) — kekal splash, tidak masuk app.
    if (accepted == true) {
      widget.onComplete();
    } else {
      _controller.reset();
      _controller.forward().whenComplete(() {
        if (mounted) _showDisclaimer();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.splashDarkBg : AppColors.splashLightBg;
    final onBg =
        isDark ? AppColors.splashLightText : const Color(0xFF0A2A20);

    return Scaffold(
      backgroundColor: bg,
      body: SizedBox.expand(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                _IridescentAurora(progress: _aurora.value, isDark: isDark),
                Center(
                  child: _SplashLockup(
                    isDark: isDark,
                    onBg: onBg,
                    markOpacity: _markOpacity.value,
                    markScale: _markScale.value,
                    markRotateY: _markRotateY.value,
                    wordOpacity: _wordOpacity.value,
                    badgeOpacity: _badgeOpacity.value,
                    badgeScale: _badgeScale.value,
                    subtitleOpacity: _subtitleOpacity.value,
                    subtitleSlide: _subtitleSlide.value,
                    sweepProgress: _sweep.value,
                    reducedMotion: _reducedMotion,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _IridescentAurora extends StatelessWidget {
  const _IridescentAurora({required this.progress, required this.isDark});
  final double progress;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final base = isDark
        ? AppColors.splashDarkBg
        : const Color(0xFF0F513F);
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0.0, -0.2),
          radius: 1.4,
          colors: [
            AppColors.splashPrimaryEmerald.withValues(alpha: 0.30),
            base.withValues(alpha: 0.9),
            base,
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            child: _glowCircle(340, AppColors.splashMint, 0.30),
          ),
          Positioned(
            top: -40,
            right: -100,
            child: _glowCircle(300, AppColors.splashAqua, 0.24),
          ),
          Positioned(
            bottom: -140,
            left: 40,
            child: _glowCircle(360, AppColors.splashSoftBlue, 0.20),
          ),
          Positioned(
            bottom: -80,
            right: -40,
            child: _glowCircle(280, AppColors.splashSoftJade, 0.22),
          ),
        ],
      ),
    );
  }

  Widget _glowCircle(double size, Color color, double alpha) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: alpha * progress),
        ),
      ),
    );
  }
}

class _SplashLockup extends StatelessWidget {
  const _SplashLockup({
    required this.isDark,
    required this.onBg,
    required this.markOpacity,
    required this.markScale,
    required this.markRotateY,
    required this.wordOpacity,
    required this.badgeOpacity,
    required this.badgeScale,
    required this.subtitleOpacity,
    required this.subtitleSlide,
    required this.sweepProgress,
    required this.reducedMotion,
  });

  final bool isDark;
  final Color onBg;
  final double markOpacity;
  final double markScale;
  final double markRotateY;
  final double wordOpacity;
  final double badgeOpacity;
  final double badgeScale;
  final double subtitleOpacity;
  final double subtitleSlide;
  final double sweepProgress;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    const subtitle = AppConstants.appDescription;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final logoSize = width < 420
            ? 170.0
            : width < 800
                ? 200.0
                : 240.0;
        final wordmarkSize =
            width < 420 ? 50.0 : width < 800 ? 64.0 : 80.0;
        final badgeSize = width < 420 ? 30.0 : 38.0;
        final subtitleSize = width < 420 ? 15.0 : 18.0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ThreeDLogoMark(
                size: logoSize,
                opacity: markOpacity,
                scale: markScale,
                rotateY: markRotateY,
                isDark: isDark,
              ),
              const SizedBox(height: 30),
              _BrandLockup(
                onBg: onBg,
                wordmarkSize: wordmarkSize,
                badgeSize: badgeSize,
                wordOpacity: wordOpacity,
                badgeOpacity: badgeOpacity,
                badgeScale: badgeScale,
                sweepProgress: sweepProgress,
              ),
              const SizedBox(height: 26),
              Opacity(
                opacity: subtitleOpacity,
                child: Transform.translate(
                  offset: Offset(0, 10 * (1 - subtitleSlide)),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: subtitleSize,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                        color: onBg.withValues(alpha: 0.78),
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ThreeDLogoMark extends StatelessWidget {
  const _ThreeDLogoMark({
    required this.size,
    required this.opacity,
    required this.scale,
    required this.rotateY,
    required this.isDark,
  });

  final double size;
  final double opacity;
  final double scale;
  final double rotateY;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0012)
          ..rotateY(rotateY)
          ..scaleByDouble(scale, scale, scale, 1),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ground shadow
            Transform.translate(
              offset: const Offset(0, 18),
              child: Container(
                width: size * 0.72,
                height: size * 0.18,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(999),
                  color: Colors.black.withValues(alpha: 0.28),
                ),
              ),
            ),
            // extrusion layers
            _extrusion(size, 14, 8, 0.10, isDark),
            _extrusion(size, 10, 6, 0.14, isDark),
            _extrusion(size, 6, 4, 0.20, isDark),
            _extrusion(size, 3, 2, 0.28, isDark),
            // glow
            Container(
              width: size + 30,
              height: size + 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.splashPrimaryEmerald.withValues(alpha: 0.30),
                    blurRadius: 60,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
            // front logo
            Image.asset(
              'assets/images/e_hadis40_logo_official.png',
              width: size,
              height: size,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (context, error, stack) {
                debugPrint('[SPLASH] official logo failed to load: $error');
                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: AppColors.splashPrimaryEmerald,
                    borderRadius: BorderRadius.circular(size * 0.22),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _extrusion(double size, double dy, double dx, double alpha, bool isDark) {
    return Transform.translate(
      offset: Offset(dx, dy),
      child: Opacity(
        opacity: alpha,
        child: Image.asset(
          'assets/images/e_hadis40_logo_official.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          color: isDark ? Colors.black : AppColors.splashDeepEmerald,
          colorBlendMode: BlendMode.srcATop,
        ),
      ),
    );
  }
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup({
    required this.onBg,
    required this.wordmarkSize,
    required this.badgeSize,
    required this.wordOpacity,
    required this.badgeOpacity,
    required this.badgeScale,
    required this.sweepProgress,
  });

  final Color onBg;
  final double wordmarkSize;
  final double badgeSize;
  final double wordOpacity;
  final double badgeOpacity;
  final double badgeScale;
  final double sweepProgress;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Opacity(
          opacity: wordOpacity,
          child: ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.splashPrimaryEmerald,
                  onBg,
                  AppColors.splashAqua,
                ],
                stops: [
                  sweepProgress - 0.15,
                  sweepProgress,
                  sweepProgress + 0.15,
                ].map((v) => v.clamp(0.0, 1.0)).toList(),
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcATop,
            child: Text(
              'e-Hadis',
              style: TextStyle(
                fontSize: wordmarkSize,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.5,
                height: 1.0,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Opacity(
          opacity: badgeOpacity,
          child: Transform.scale(
            scale: badgeScale,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: badgeSize * 0.5,
                vertical: badgeSize * 0.22,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.splashRichEmerald,
                    AppColors.splashPrimaryEmerald,
                  ],
                ),
                borderRadius: BorderRadius.circular(badgeSize * 0.5),
                boxShadow: [
                  BoxShadow(
                    color:
                        AppColors.splashPrimaryEmerald.withValues(alpha: 0.40),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 1.2,
                ),
              ),
              child: Text(
                '40',
                style: TextStyle(
                  fontSize: badgeSize,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DisclaimerDialog extends StatelessWidget {
  const _DisclaimerDialog();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/e_hadis40_logo_official.png',
                        width: 56,
                        height: 56,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'PENAFIAN',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'e-Hadis40 ialah sebuah prototaip aplikasi pembelajaran '
                  'yang dibangunkan secara bebas berasaskan Modul Penghayatan '
                  'Hadis 40 Imam Nawawi Edisi Kedua, Kementerian Pendidikan '
                  'Malaysia.\n\n'
                  'Aplikasi ini bukan aplikasi rasmi, produk rasmi atau '
                  'platform yang diperakui oleh Kementerian Pendidikan '
                  'Malaysia.\n\n'
                  'Hak cipta kandungan asal Modul Penghayatan Hadis 40 Imam '
                  'Nawawi Edisi Kedua, nama, logo dan identiti rasmi '
                  'Kementerian Pendidikan Malaysia kekal milik pemegang hak '
                  'masing-masing.\n\n'
                  'Kandungan dalam aplikasi ini hendaklah dirujuk bersama '
                  'sumber dan modul rasmi bagi tujuan pengajaran dan '
                  'pembelajaran.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.65,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.splashPrimaryEmerald,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('SAYA FAHAM & TERUSKAN'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
