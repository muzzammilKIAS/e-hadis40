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
  static const availableHadithNumbers = 25;

  @override
  State<AnatomiSunnahScreen> createState() => _AnatomiSunnahScreenState();
}

class _AnatomiSunnahScreenState extends State<AnatomiSunnahScreen> {
  bool _loaded = false;
  ThemeMode? _syncedMode;
  StreamSubscription<html.MessageEvent>? _messageSub;

  late final VoidCallback _onLoadCallback = () {
    if (mounted) setState(() => _loaded = true);
  };

  @override
  void initState() {
    super.initState();
    AnatomiSunnahEmbed.register(
      hadithNumber: widget.hadithNumber,
      onLoad: _onLoadCallback,
    );
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
    AnatomiSunnahEmbed.unregister(
      hadithNumber: widget.hadithNumber,
      onLoad: _onLoadCallback,
    );
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
            child: AnatomiSunnahEmbed(hadithNumber: widget.hadithNumber),
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

/// Pembenaman iframe "Anatomi Sunnah 3D" bagi satu hadis — boleh digunakan
/// sebagai paparan penuh (dalam [AnatomiSunnahScreen]) atau terbenam dalam
/// halaman lain (cth. mod projektor).
///
/// Pendaftaran kilang platform view hanya boleh dilakukan sekali bagi setiap
/// `viewType` sepanjang hayat aplikasi, maka pendaftaran dilakukan secara
/// statik kongsi melalui [register]. Widget ini sendiri TIDAK mendaftar —
/// pemilik mesti memanggil [register] sebelum membinanya.
class AnatomiSunnahEmbed extends StatelessWidget {
  const AnatomiSunnahEmbed({required this.hadithNumber, super.key});

  final int hadithNumber;

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

  /// Panggil balik "iframe sudah dimuatkan" bagi pemilik yang sedang aktif.
  /// Kilang yang didaftarkan sekali sahaja itu merujuk peta ini (bukan
  /// menangkap `this`), supaya ia sentiasa memberitahu pemilik semasa.
  static final Map<String, VoidCallback> _onLoadCallbacks =
      <String, VoidCallback>{};

  static String _viewTypeFor(int hadithNumber) =>
      'anatomi-sunnah-game-iframe-$hadithNumber';

  /// Daftarkan kilang platform view bagi hadis tertentu (sekali sahaja).
  static void register({
    required int hadithNumber,
    required VoidCallback onLoad,
  }) {
    final viewType = _viewTypeFor(hadithNumber);
    _onLoadCallbacks[viewType] = onLoad;

    if (_registeredViewTypes.add(viewType)) {
      final padded = hadithNumber.toString().padLeft(2, '0');
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
  }

  /// Buang panggil balik hanya jika ia masih milik pemilik yang memanggil —
  /// jika pemilik baharu sudah menggantikannya, biarkan milik pemilik baharu.
  static void unregister({
    required int hadithNumber,
    required VoidCallback onLoad,
  }) {
    final viewType = _viewTypeFor(hadithNumber);
    if (identical(_onLoadCallbacks[viewType], onLoad)) {
      _onLoadCallbacks.remove(viewType);
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewTypeFor(hadithNumber));
  }
}
