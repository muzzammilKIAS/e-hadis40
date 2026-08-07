import 'package:flutter/material.dart';

import '../widgets/hadith_playlist_panel.dart';

class HadithPlaylistScreen extends StatelessWidget {
  const HadithPlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pemain Audio'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: scheme.onSurface,
        shape: const Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      body: const SafeArea(
        child: HadithPlaylistPanel(),
      ),
    );
  }
}
