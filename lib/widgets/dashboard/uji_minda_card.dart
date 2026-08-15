import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../screens/uji_minda_screen.dart';
import 'islamic_atmosphere.dart';

/// Kad promosi "Uji Minda" — ilustrasi roket besar di kanan, sengaja
/// melepasi garisan kotak; tajuk + ikon ">" beranimasi di tengah kotak.
/// Membuka game interaktif "Eksplorasi Hadis 40" (dibenamkan sebagai
/// halaman web berasingan) bila ditekan. Gaya kad sepadan dengan tema
/// emerald/emas app untuk light dan dark mode.
class UjiMindaCard extends StatefulWidget {
  const UjiMindaCard({super.key});

  @override
  State<UjiMindaCard> createState() => _UjiMindaCardState();
}

class _UjiMindaCardState extends State<UjiMindaCard>
    with SingleTickerProviderStateMixin {
  static const _cardHeight = 176.0;

  late final AnimationController _chevronController;
  late final Animation<double> _chevronOffset;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _chevronController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..repeat(reverse: true);
    _chevronOffset = Tween<double>(begin: 0, end: 5).animate(
      CurvedAnimation(parent: _chevronController, curve: Curves.easeInOut),
    );
  }

  void _openGame(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const UjiMindaScreen()),
    );
  }

  @override
  void dispose() {
    _chevronController.dispose();
    super.dispose();
  }

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // Ruang lapang kanan untuk ilustrasi "melepasi" garisan kad, dan
        // saiz ilustrasi berkadar dengan lebar kad supaya tak menutup teks
        // tengah pada skrin sempit.
        final rightGap = (width * 0.18).clamp(32.0, 72.0);
        final artSize = (width * 0.48).clamp(170.0, 300.0);
        // ~38% lebar ilustrasi sengaja melepasi garisan kanan kad; baki di
        // dalam kad kekal jauh daripada teks tengah pada semua lebar skrin.
        final artRight = -(artSize * 0.38);

        return Padding(
          padding: EdgeInsets.only(right: rightGap, top: 20, bottom: 8),
          child: SizedBox(
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
                        colors: gradientColors,
                      ),
                      border: Border.all(
                        color: _hovered && dark
                            ? AppColors.darkGold.withValues(alpha: 0.85)
                            : AppColors.goldAccent.withValues(alpha: 0.3),
                        width: _hovered && dark ? 1.4 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _hovered && dark
                              ? AppColors.darkGold.withValues(alpha: 0.22)
                              : AppColors.deepEmerald
                                  .withValues(alpha: dark ? 0.5 : 0.28),
                          blurRadius: _hovered ? 26 : 20,
                          offset: Offset(0, _hovered ? 10 : 8),
                        ),
                      ],
                    ),
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: () => _openGame(context),
                        child: Stack(
                          children: [
                            const Positioned.fill(
                              child: IslamicCardPattern(
                                color: Colors.white,
                                seed: 40,
                                opacity: 1.2,
                              ),
                            ),
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Uji Minda',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  AnimatedBuilder(
                                    animation: _chevronOffset,
                                    builder: (context, child) =>
                                        Transform.translate(
                                      offset: Offset(_chevronOffset.value, 0),
                                      child: child,
                                    ),
                                    child: Container(
                                      width: 34,
                                      height: 34,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.16),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.goldAccent
                                              .withValues(alpha: 0.55),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.chevron_right_rounded,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Ilustrasi roket — dibesarkan dan diposisikan supaya
                // sengaja melepasi garisan atas/bawah/kanan kotak, dengan
                // bayang lembut di bawahnya supaya kelihatan "hidup" dan
                // melayang, bukan tertampal rata pada kad.
                Positioned(
                  right: artRight,
                  top: -((artSize - _cardHeight) / 2),
                  child: IgnorePointer(
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
                                  (dark ? AppColors.darkGold : Colors.white)
                                      .withValues(alpha: dark ? 0.24 : 0.18),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          // Bayang kontak di bawah roket — beri kesan
                          // ilustrasi "melayang" di atas kad.
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
                                      alpha: dark ? 0.07 : 0.035,
                                    ),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.deepEmerald.withValues(
                                    alpha: dark ? 0.08 : 0.045,
                                  ),
                                  blurRadius: 26,
                                  offset: const Offset(0, 16),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/uji_minda_rocket.png',
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
            ),
          ),
        );
      },
    );
  }
}
