import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_controller.dart';

/// Paparan penuh "Uji Minda" — game interaktif "Eksplorasi Hadis 40" yang
/// dijalankan sebagai halaman HTML/JS berasingan (`web/uji_minda/index.html`,
/// termasuk GSAP + Phosphor Icons), dibenamkan melalui iframe kerana app ini
/// sasaran web sahaja.
///
/// Integrasi tema: kunci `ehadis40-theme` ditulis ke `localStorage` app induk
/// dengan nilai yang sama seperti dijangka oleh skrip dalam index.html itu.
/// Kerana iframe ini sama-origin (dilayan daripada folder `web/` yang sama),
/// ia berkongsi `localStorage` fizikal yang sama dengan app induk — jadi
/// penulisan di sini terus dibaca oleh game semasa `initTheme()`, dan event
/// `storage` (didengar dalam index.html) menyegerakkan tema secara langsung
/// walaupun iframe sudah pun dimuatkan.
class UjiMindaScreen extends StatefulWidget {
  const UjiMindaScreen({super.key});

  static const _viewType = 'uji-minda-game-iframe';
  static const _themeStorageKey = 'ehadis40-theme';

  @override
  State<UjiMindaScreen> createState() => _UjiMindaScreenState();
}

class _UjiMindaScreenState extends State<UjiMindaScreen> {
  static bool _factoryRegistered = false;

  bool _loaded = false;
  ThemeMode? _syncedMode;

  @override
  void initState() {
    super.initState();
    if (!_factoryRegistered) {
      _factoryRegistered = true;
      ui_web.platformViewRegistry.registerViewFactory(
        UjiMindaScreen._viewType,
        (int viewId) {
          final iframe = html.IFrameElement()
            ..src = 'uji_minda/index.html'
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
        title: const Text('Uji Minda'),
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: HtmlElementView(viewType: UjiMindaScreen._viewType),
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
