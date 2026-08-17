// ignore_for_file: deprecated_member_use
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../services/app_controller.dart';
import '../widgets/dashboard/xplorasi_minda_title.dart';

/// Paparan penuh "X-plorasi Minda" — game interaktif "Eksplorasi Hadis 40" yang
/// dijalankan sebagai halaman HTML/JS berasingan (`web/uji_minda/index.html`,
/// termasuk GSAP + Phosphor Icons), dibenamkan melalui iframe kerana app ini
/// sasaran web sahaja.
///
/// [level] (1-4) menghantar `?level=N` ke iframe supaya `index.html` hanya
/// memainkan ~10 hadis bagi level berkenaan (lihat logik `activeIndices`
/// dalam fail itu) — bentuk & kesan permainan (roket, buih, kuiz) itu
/// sendiri tidak disentuh langsung.
///
/// Integrasi tema: kunci `ehadis40-theme` ditulis ke `localStorage` app induk
/// dengan nilai yang sama seperti dijangka oleh skrip dalam index.html itu.
/// Kerana iframe ini sama-origin (dilayan daripada folder `web/` yang sama),
/// ia berkongsi `localStorage` fizikal yang sama dengan app induk — jadi
/// penulisan di sini terus dibaca oleh game semasa `initTheme()`, dan event
/// `storage` (didengar dalam index.html) menyegerakkan tema secara langsung
/// walaupun iframe sudah pun dimuatkan.
class UjiMindaScreen extends StatefulWidget {
  const UjiMindaScreen({required this.level, super.key});

  /// Level 1-4. `null` memainkan mod asal (semua 41 hadis).
  final int? level;

  static const _themeStorageKey = 'ehadis40-theme';

  @override
  State<UjiMindaScreen> createState() => _UjiMindaScreenState();
}

class _UjiMindaScreenState extends State<UjiMindaScreen> {
  static final Set<String> _registeredViewTypes = {};

  late final String _viewType =
      'uji-minda-game-iframe-${widget.level ?? 'all'}';

  bool _loaded = false;
  ThemeMode? _syncedMode;

  @override
  void initState() {
    super.initState();
    if (_registeredViewTypes.add(_viewType)) {
      final src = widget.level == null
          ? 'uji_minda/index.html'
          : 'uji_minda/index.html?level=${widget.level}';
      ui_web.platformViewRegistry.registerViewFactory(
        _viewType,
        (int viewId) {
          final iframe = html.IFrameElement()
            ..src = src
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%'
            ..allow = 'autoplay'
            ..onLoad.listen((_) {
              if (mounted) setState(() => _loaded = true);
            });
          return iframe;
        },
      );
    }
  }

  void _syncTheme(ThemeMode mode, Brightness platformBrightness) {
    if (_syncedMode == mode) return;
    _syncedMode = mode;
    final isDark = switch (mode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system => platformBrightness == Brightness.dark,
    };
    html.window.localStorage[UjiMindaScreen._themeStorageKey] =
        isDark ? 'dark' : 'light';
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<AppController>().themeMode;
    _syncTheme(themeMode, MediaQuery.platformBrightnessOf(context));
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: XplorasiMindaTitle(
          textColor: scheme.onSurface,
          xBoxColor: AppColors.gold,
          xIconColor: scheme.brightness == Brightness.dark
              ? scheme.surface
              : Colors.white,
          fontSize: 18,
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: HtmlElementView(viewType: _viewType),
          ),
          if (!_loaded)
            Positioned.fill(
              child: ColoredBox(
                color: scheme.surface,
                child: Center(
                  child: CircularProgressIndicator(color: scheme.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
