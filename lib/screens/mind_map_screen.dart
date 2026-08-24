import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../data/models/hadith.dart';
import '../data/repositories/hadith_repository.dart';
import '../widgets/mind_map/radial_mind_map.dart';

/// "Peta Minda Hadis 40" — pandangan radial 42 hadis dikelompokkan
/// mengikut nilai fokus (`Hadith.focusValues`), bukan sekadar nombor/modul
/// seperti grid biasa. Nod tengah "Hadis 40" bercabang ke setiap tema; tema
/// yang diketik kembang menunjukkan senarai hadis di dalamnya.
///
/// Lukisan/geometri radial dikongsi dengan `NarratorMindMapScreen` melalui
/// `RadialMindMapPage` — fail ini hanya bertanggungjawab membina cabang
/// (kelompok ikut tema), bukan lukisan itu sendiri.
class MindMapScreen extends StatelessWidget {
  const MindMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hadiths = context.read<HadithRepository>().availableHadiths;

    return RadialMindMapPage(
      title: 'Peta Minda Hadis 40',
      hint: 'Disusun mengikut nilai fokus setiap hadis. Ketik satu cabang '
          'untuk lihat senarai hadis · cubit/skrol untuk zum.',
      centerLabel: 'Hadis 40',
      centerSubLabel: 'Peta Minda',
      clusters: _buildClusters(hadiths, scheme),
    );
  }

  List<MindMapCluster> _buildClusters(
    List<Hadith> hadiths,
    ColorScheme scheme,
  ) {
    final freq = <String, int>{};
    for (final hadith in hadiths) {
      for (final raw in hadith.focusValues) {
        final value = _normalizeFocusValue(raw);
        if (value.isEmpty) continue;
        freq[value] = (freq[value] ?? 0) + 1;
      }
    }
    // Nilai yang muncul pada ≥2 hadis menjadi cabang utama; nilai unik
    // (sekali sahaja) dihimpun dalam satu cabang "Nilai Murni Lain" supaya
    // peta minda kekal bersih (~13 cabang) berbanding 40+ cabang jika
    // setiap nilai fokus mendapat cabangnya sendiri.
    final major =
        freq.entries.where((e) => e.value >= 2).map((e) => e.key).toSet();

    final buckets = <String, List<Hadith>>{};
    const fallback = 'Nilai Murni Lain';
    for (final hadith in hadiths) {
      final values = hadith.focusValues.map(_normalizeFocusValue);
      final primary = values.firstWhere(major.contains, orElse: () => '');
      final key = primary.isNotEmpty ? primary : fallback;
      buckets.putIfAbsent(key, () => []).add(hadith);
    }

    final entries = buckets.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    final total = entries.length;
    return [
      for (var i = 0; i < total; i++)
        MindMapCluster(
          label: entries[i].key,
          accent: _clusterAccent(scheme, i, total),
          hadiths: entries[i].value
            ..sort((a, b) => a.number.compareTo(b.number)),
        ),
    ];
  }

  String _normalizeFocusValue(String value) {
    final trimmed = value.trim();
    if (trimmed.toLowerCase() == 'daya cipta') return 'Daya Cipta';
    return trimmed;
  }

  /// Warna cabang: laluan TIGA warna (primary → pink → tertiary) —
  /// konsisten dengan `ModuleIdentity.accentFor` supaya identiti warna
  /// peta minda sepadan dengan grid modul, bukan skema warna berasingan.
  Color _clusterAccent(ColorScheme scheme, int index, int total) {
    final dark = scheme.brightness == Brightness.dark;
    final thirdAccent = dark ? AppColors.darkGold : AppColors.pinkAccent;
    final t = total <= 1 ? 0.0 : index / (total - 1);
    if (t <= 0.5) return Color.lerp(scheme.primary, thirdAccent, t * 2)!;
    return Color.lerp(thirdAccent, scheme.tertiary, (t - 0.5) * 2)!;
  }
}
