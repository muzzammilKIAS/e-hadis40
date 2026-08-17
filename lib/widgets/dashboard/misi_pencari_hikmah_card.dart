import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../screens/misi_pencari_hikmah_screen.dart';
import 'islamic_atmosphere.dart';
import 'misi_mencari_hikmah_title.dart';

/// Kad promosi "Misi Mencari Hikmah" — ilustrasi budak menunggang roket
/// menghala ke kitab bercahaya di kanan, sengaja melepasi garisan kotak
/// (seperti reka bentuk asal) supaya kelihatan "hidup"; tajuk besar di
/// tengah kotak, dengan ikon lampu bertindak sebagai butang utama. Bila
/// ditekan (mana-mana bahagian kad, atau khusus ikon lampu), roket
/// "melepaskan diri" (terbang ke atas dengan api + asap ringan) sebelum
/// membuka RPG interaktif "Misi Mencari Hikmah" (dibenamkan sebagai
/// halaman web berasingan).
///
/// Lepasan ilustrasi di sebelah kanan diukur secara langsung (RenderBox)
/// terhadap tepi sebenar skrin — bukan anggaran mengikut lebar kotak —
/// supaya ia sentiasa "keluar" daripada kotak seperti reka bentuk asal
/// TANPA sekali-kali terpotong oleh tepi skrin, sama ada pada desktop
/// (dengan bar sisi), tablet mahupun telefon. Struktur animasi & gaya kad
/// sengaja dikekalkan sama seperti `UjiMindaCard` supaya kedua-dua kad
/// aktiviti interaktif berasa sepadan; hanya identiti (warna aksen,
/// ilustrasi, tajuk) yang berbeza.
class MisiPencariHikmahCard extends StatefulWidget {
  const MisiPencariHikmahCard({super.key});

  @override
  State<MisiPencariHikmahCard> createState() => _MisiPencariHikmahCardState();
}

class _MisiPencariHikmahCardState extends State<MisiPencariHikmahCard>
    with TickerProviderStateMixin {
  static const _cardHeight = 176.0;

  final GlobalKey _boxKey = GlobalKey();

  late final AnimationController _launchController;
  bool _hovered = false;
  bool _launching = false;

  /// Ruang selamat (px) antara tepi kanan kotak dan tepi sebenar skrin.
  /// Bermula kecil & selamat sebelum ukuran pertama selesai, kemudian
  /// dikemas kini melalui [_measureSafeOverflow].
  double _safeOverflow = 8;

  @override
  void initState() {
    super.initState();
    _launchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureSafeOverflow());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Bina semula ukuran apabila tetingkap/viewport berubah saiz (cth.
    // putaran skrin, bar sisi dikembang/kuncup) — MediaQuery berubah
    // memicu didChangeDependencies.
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureSafeOverflow());
  }

  void _measureSafeOverflow() {
    if (!mounted) return;
    final renderObject = _boxKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return;
    final topLeft = renderObject.localToGlobal(Offset.zero);
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final rightEdge = topLeft.dx + renderObject.size.width;
    // 6px baki keselamatan supaya bayang/highlight ilustrasi juga tidak
    // tersentuh tepi skrin.
    final available = (viewportWidth - rightEdge - 6).clamp(4.0, 220.0);
    if ((available - _safeOverflow).abs() > 0.5) {
      setState(() => _safeOverflow = available);
    }
  }

  Future<void> _handleTap(BuildContext context) async {
    if (_launching) return;
    setState(() => _launching = true);
    await _launchController.forward(from: 0);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const MisiPencariHikmahScreen(),
      ),
    );
    if (!mounted) return;
    _launchController.reset();
    setState(() => _launching = false);
  }

  @override
  void dispose() {
    _launchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = scheme.brightness == Brightness.dark;
    // Aksen dwi-tone kad ini — terakota hikmah berpadu dengan latar kaca,
    // gaya sama seperti kad Xplorasi Minda (surface + aksen), bukan
    // gradien pepejal tersendiri.
    const cardAccent = AppColors.rainbowOrange;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // Saiz ilustrasi berkadar dengan lebar kad supaya tak menutup teks
        // tengah pada skrin sempit.
        final artSize = (width * 0.48).clamp(170.0, 300.0);
        // Lepasan yang DIINGINI (gaya dramatik asal, ~38% lebar ilustrasi)
        // dihadkan oleh ruang selamat SEBENAR yang diukur di [_measureSafeOverflow]
        // — jadi ia sentiasa "keluar kotak" semaksimum mungkin tanpa
        // sekali-kali melepasi tepi skrin.
        final artRight = -math.min(artSize * 0.38, _safeOverflow);
        const titleLeftInset = 24.0;
        final safeTitleWidth =
            (width - artSize * 0.62 - titleLeftInset - 8).clamp(110.0, 560.0);

        return Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: SizedBox(
            key: _boxKey,
            height: _cardHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) => setState(() => _hovered = true),
                  onExit: (_) => setState(() => _hovered = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    width: double.infinity,
                    height: _cardHeight,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: dark
                            ? [
                                Color.lerp(scheme.surface, cardAccent, 0.08)!,
                                scheme.surfaceContainerLowest
                                    .withValues(alpha: 0.9),
                              ]
                            : [
                                Color.lerp(scheme.surface, AppColors.deepSage,
                                    _hovered ? 0.1 : 0.045)!,
                                Color.lerp(
                                    scheme.surfaceContainerHighest,
                                    AppColors.deepSage,
                                    _hovered ? 0.08 : 0.03)!,
                              ],
                      ),
                      border: Border.all(
                        color: _hovered
                            ? (dark
                                ? AppColors.darkGold.withValues(alpha: 0.85)
                                : cardAccent.withValues(alpha: 0.75))
                            : scheme.outlineVariant
                                .withValues(alpha: dark ? 0.6 : 1),
                        width: _hovered ? 1.4 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: dark
                              ? (_hovered
                                  ? AppColors.darkGold.withValues(alpha: 0.22)
                                  : Colors.black.withValues(alpha: 0.24))
                              : scheme.shadow
                                  .withValues(alpha: _hovered ? 0.16 : 0.06),
                          blurRadius: _hovered ? 24 : 14,
                          offset: Offset(0, _hovered ? 10 : 4),
                        ),
                      ],
                    ),
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: () => _handleTap(context),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: IslamicCardPattern(
                                color: cardAccent,
                                seed: 41,
                                opacity: _hovered ? 1.15 : 1,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: titleLeftInset,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: safeTitleWidth,
                                      ),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: MisiMencariHikmahTitle(
                                          textColor: scheme.onSurface,
                                          mBoxColor: cardAccent,
                                          mIconColor: dark
                                              ? scheme.surface
                                              : Colors.white,
                                          fontSize: 42,
                                          onIconTap: () => _handleTap(context),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Ilustrasi roket — dibesarkan dan diposisikan supaya
                // melepasi garisan atas/bawah/kanan kotak, dengan bayang
                // lembut di bawahnya supaya kelihatan "hidup" dan
                // melayang, bukan tertampal rata pada kad. Bila ditekan,
                // ia "melancar" ke atas dengan api + asap ringan sebelum
                // game dibuka. `artRight` dihadkan oleh ruang skrin
                // sebenar (lihat atas), jadi ia tidak pernah terpotong.
                Positioned(
                  right: artRight,
                  top: -((artSize - _cardHeight) / 2),
                  child: IgnorePointer(
                    child: SizedBox(
                      width: artSize,
                      height: artSize,
                      child: AnimatedBuilder(
                        animation: _launchController,
                        builder: (context, child) {
                          final t = _launchController.value;
                          return Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              // Bayang kontak di bawah roket.
                              Positioned(
                                bottom: artSize * 0.1,
                                child: Container(
                                  width: artSize * 0.5,
                                  height: artSize * 0.14,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.elliptical(
                                        artSize * 0.25,
                                        artSize * 0.07,
                                      ),
                                    ),
                                    gradient: RadialGradient(
                                      colors: [
                                        AppColors.deepEmerald.withValues(
                                          alpha:
                                              (dark ? 0.07 : 0.035) * (1 - t),
                                        ),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Asap ringan — beberapa puf, susul-menyusul.
                              for (final puff in _smokePuffs)
                                _SmokePuff(
                                  progress: t,
                                  delay: puff.delay,
                                  life: puff.life,
                                  dx: puff.dx * artSize,
                                  bottom: artSize * 0.08,
                                  maxSize: artSize * 0.3,
                                  dark: dark,
                                ),
                              // Nyalaan api di ekor roket.
                              _FlameEffect(progress: t, artSize: artSize),
                              // Roket itu sendiri — terbang ke atas & pudar.
                              Positioned(
                                bottom:
                                    Curves.easeIn.transform(t) * artSize * 1.9,
                                child: Opacity(
                                  opacity: 1 -
                                      Curves.easeIn.transform(
                                        ((t - 0.55) / 0.45).clamp(0.0, 1.0),
                                      ),
                                  child: SizedBox(
                                    width: artSize,
                                    height: artSize,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Glow lembut di belakang ilustrasi.
                                        Container(
                                          width: artSize,
                                          height: artSize,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: RadialGradient(
                                              colors: [
                                                (dark
                                                        ? AppColors.darkGold
                                                        : Colors.white)
                                                    .withValues(
                                                  alpha: dark ? 0.24 : 0.18,
                                                ),
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.deepEmerald
                                                    .withValues(
                                                  alpha: dark ? 0.08 : 0.045,
                                                ),
                                                blurRadius: 26,
                                                offset: const Offset(0, 16),
                                              ),
                                            ],
                                          ),
                                          child: Image.asset(
                                            'assets/images/misi_pencari_hikmah_rocket.png',
                                            width: artSize * 0.9,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SmokePuffSpec {
  const _SmokePuffSpec(this.delay, this.life, this.dx);
  final double delay;
  final double life;
  final double dx;
}

const _smokePuffs = [
  _SmokePuffSpec(0.0, 0.5, -0.06),
  _SmokePuffSpec(0.08, 0.5, 0.08),
  _SmokePuffSpec(0.18, 0.5, -0.14),
  _SmokePuffSpec(0.28, 0.5, 0.15),
];

/// Puf asap ringan — muncul, mengembang sedikit, lalu pudar. Tidak ikut
/// roket naik (kekal dekat pangkal), meniru asap ekor yang ditinggalkan.
class _SmokePuff extends StatelessWidget {
  const _SmokePuff({
    required this.progress,
    required this.delay,
    required this.life,
    required this.dx,
    required this.bottom,
    required this.maxSize,
    required this.dark,
  });

  final double progress;
  final double delay;
  final double life;
  final double dx;
  final double bottom;
  final double maxSize;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final t = ((progress - delay) / life).clamp(0.0, 1.0);
    final opacity = math.sin(t * math.pi) * (dark ? 0.24 : 0.16);
    final scale = 0.4 + t * 0.9;
    final drift = t * maxSize * 0.4;

    return Positioned(
      bottom: bottom + drift,
      child: Transform.translate(
        offset: Offset(dx * (0.6 + t * 0.6), 0),
        child: Container(
          width: maxSize * scale,
          height: maxSize * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.white.withValues(alpha: opacity),
                Colors.white.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Nyalaan api ringan di ekor roket semasa "pelancaran" — dua lapisan
/// gradient (teras terang + lidah api luar), berkelip halus.
class _FlameEffect extends StatelessWidget {
  const _FlameEffect({required this.progress, required this.artSize});

  final double progress;
  final double artSize;

  @override
  Widget build(BuildContext context) {
    final ignite = Curves.easeOut.transform((progress / 0.12).clamp(0.0, 1.0));
    final fade = Curves.easeIn.transform(
      ((progress - 0.5) / 0.5).clamp(0.0, 1.0),
    );
    final opacity = ignite * (1 - fade);
    if (opacity <= 0.01) return const SizedBox.shrink();

    final flicker = 1 + 0.12 * math.sin(progress * 46);
    final height = artSize * 0.34 * flicker;
    final width = artSize * 0.2 * flicker;

    return Positioned(
      bottom: artSize * 0.08,
      child: Opacity(
        opacity: opacity,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(width),
                gradient: RadialGradient(
                  colors: [
                    AppColors.rainbowOrange,
                    AppColors.rainbowOrange.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
            Container(
              width: width * 0.5,
              height: height * 0.6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(width),
                gradient: RadialGradient(
                  colors: [
                    AppColors.goldAccent,
                    AppColors.goldAccent.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
