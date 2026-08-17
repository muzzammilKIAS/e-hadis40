// ignore_for_file: deprecated_member_use
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../widgets/dashboard/misi_mencari_hikmah_title.dart';

/// Paparan penuh "Misi Mencari Hikmah" — RPG 2D interaktif Hadis 40 yang
/// dijalankan sebagai halaman HTML/JS berasingan
/// (`web/misi_pencari_hikmah/index.html`), dibenamkan melalui iframe kerana
/// app ini sasaran web sahaja. Corak sama seperti `UjiMindaScreen`.
class MisiPencariHikmahScreen extends StatefulWidget {
  const MisiPencariHikmahScreen({super.key});

  static const _viewType = 'misi-pencari-hikmah-game-iframe';

  @override
  State<MisiPencariHikmahScreen> createState() =>
      _MisiPencariHikmahScreenState();
}

class _MisiPencariHikmahScreenState extends State<MisiPencariHikmahScreen> {
  static bool _factoryRegistered = false;

  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (!_factoryRegistered) {
      _factoryRegistered = true;
      ui_web.platformViewRegistry.registerViewFactory(
        MisiPencariHikmahScreen._viewType,
        (int viewId) {
          final iframe = html.IFrameElement()
            ..src = 'misi_pencari_hikmah/index.html'
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFF17110B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF17110B),
        title: const MisiMencariHikmahTitle(
          textColor: Colors.white,
          mBoxColor: AppColors.gold,
          mIconColor: Colors.white,
          fontSize: 18,
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: HtmlElementView(
              viewType: MisiPencariHikmahScreen._viewType,
            ),
          ),
          if (!_loaded)
            Positioned.fill(
              child: ColoredBox(
                color: const Color(0xFF17110B),
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
