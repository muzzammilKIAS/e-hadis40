import 'dart:async';
// ignore_for_file: deprecated_member_use
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_controller.dart';

/// Paparan penuh "Anatomi Sunnah 3D" — simulasi interaktif Three.js yang
/// memaparkan metafora visual bagi hadis semasa
/// (`web/anatomi_sunnah/hadith_NN.html`), dibenamkan melalui iframe
/// sama-origin, sama pola dengan `UjiMindaScreen`.
///
/// Setiap hadis mempunyai fail HTML tersendiri (bukan satu templat dikongsi)
/// kerana setiap simulasi mempunyai bentuk 3D, mekanik interaksi dan teks
/// matan yang direka khusus untuknya.
class AnatomiSunnahScreen extends StatefulWidget {
  const AnatomiSunnahScreen({required this.hadithNumber, super.key});

  final int hadithNumber;

  static const _themeStorageKey = 'ehadis40-theme';
  static const availableHadithNumbers = 17;

  @override
  State<AnatomiSunnahScreen> createState() => _AnatomiSunnahScreenState();
}

class _AnatomiSunnahScreenState extends State<AnatomiSunnahScreen> {
  late final String _viewType =
      'anatomi-sunnah-game-iframe-${widget.hadithNumber}';

  /// Jenis paparan yang kilangnya (view factory) SUDAH didaftarkan.
  ///
  /// Mesti `static`: `registerViewFactory` hanya berjaya sekali bagi setiap
  /// `viewType` sepanjang hayat aplikasi — panggilan kedua dikembalikan
  /// `false` secara senyap dan kilang LAMA dikekalkan. Jika bendera ini
  /// disimpan per-instance, kunjungan kedua ke hadis yang sama akan
  /// menggunakan semula penutupan (closure) daripada State LAMA yang sudah
  /// dilupuskan — `mounted` bernilai false, `setState` tidak pernah dipanggil,
  /// dan `_loaded` skrin baharu tersekat `false` selama-lamanya.
  static final Set<String> _registeredViewTypes = <String>{};

  /// Panggil balik "iframe sudah dimuatkan" bagi State yang sedang aktif.
  /// Kilang yang didaftarkan sekali sahaja itu merujuk peta ini (bukan
  /// menangkap `this`), supaya ia sentiasa memberitahu State semasa.
  static final Map<String, VoidCallback> _onLoadCallbacks =
      <String, VoidCallback>{};

  bool _loaded = false;
  ThemeMode? _syncedMode;
  StreamSubscription<html.MessageEvent>? _messageSub;

  late final VoidCallback _onLoadCallback = () {
    if (mounted) setState(() => _loaded = true);
  };

  @override
  void initState() {
    super.initState();
    _onLoadCallbacks[_viewType] = _onLoadCallback;

    if (_registeredViewTypes.add(_viewType)) {
      final padded = widget.hadithNumber.toString().padLeft(2, '0');
      final viewType = _viewType;
      ui_web.platformViewRegistry.registerViewFactory(
        viewType,
        (int viewId) {
          final iframe = html.IFrameElement()
            ..src = 'anatomi_sunnah/hadith_$padded.html'
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%'
            ..allow = 'autoplay'
            ..onLoad.listen((_) => _onLoadCallbacks[viewType]?.call());
          return iframe;
        },
      );
    }
    // Butang kembali diletakkan di dalam HTML simulasi itu sendiri (bukan
    // widget Flutter di atas iframe) supaya klik sentiasa berfungsi — iframe
    // menelan semua event penunjuk pada ruang skrin yang ditempatinya,
    // walaupun ada widget Flutter dilukis "di atas" secara visual. Fail HTML
    // menghantar postMessage apabila diklik; kita dengar di sini dan pop.
    _messageSub = html.window.onMessage.listen((event) {
      if (event.origin != html.window.location.origin) return;
      if (event.data == 'anatomi-sunnah-back' && mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    // Buang panggil balik hanya jika ia masih milik State ini — jika State
    // baharu sudah menggantikannya, biarkan milik State baharu itu.
    if (identical(_onLoadCallbacks[_viewType], _onLoadCallback)) {
      _onLoadCallbacks.remove(_viewType);
    }
    super.dispose();
  }

  void _syncTheme(ThemeMode mode, Brightness platformBrightness) {
    if (_syncedMode == mode) return;
    _syncedMode = mode;
    final isDark = switch (mode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system => platformBrightness == Brightness.dark,
    };
    html.window.localStorage[AnatomiSunnahScreen._themeStorageKey] =
        isDark ? 'dark' : 'light';
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<AppController>().themeMode;
    _syncTheme(themeMode, MediaQuery.platformBrightnessOf(context));
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      // Tiada `appBar` dan tiada latar khas — iframe simulasi mengisi
      // keseluruhan skrin sepenuhnya, tanpa jalur/kotak berwarna di atasnya.
      // Butang kembali wujud di dalam HTML simulasi itu sendiri (lihat
      // `_messageSub` dalam initState).
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
