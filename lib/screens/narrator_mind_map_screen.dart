import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../data/models/hadith.dart';
import '../data/repositories/hadith_repository.dart';
import '../data/repositories/narrator_repository.dart';
import '../widgets/mind_map/radial_mind_map.dart';

/// "Peta Minda Perawi Hadis 40" — pandangan radial 42 hadis dikelompokkan
/// mengikut PERAWI (`Hadith.allNarratorIds`), berbanding tema/nilai fokus
/// (lihat `MindMapScreen`) atau nombor/modul (grid biasa). Setiap cabang
/// ialah seorang sahabat; kembang satu cabang menunjukkan semua hadis yang
/// diriwayatkannya.
///
/// Setiap 22 perawi dalam koleksi ini mendapat cabangnya sendiri (tiada
/// cabang "lain-lain") — berbeza daripada `MindMapScreen` yang menghimpun
/// nilai fokus tunggal, sebab identiti perawi sentiasa bererti walaupun
/// hanya meriwayatkan satu hadis.
class NarratorMindMapScreen extends StatelessWidget {
  const NarratorMindMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hadiths = context.read<HadithRepository>().availableHadiths;
    final narrators = context.read<NarratorRepository>();

    return RadialMindMapPage(
      title: 'Peta Minda Perawi',
      hint: 'Disusun mengikut perawi setiap hadis. Ketik satu cabang untuk '
          'lihat senarai hadis · cubit/skrol untuk zum.',
      centerLabel: 'Hadis 40',
      centerSubLabel: 'Peta Perawi',
      clusters: _buildClusters(hadiths, narrators, scheme),
    );
  }

  List<MindMapCluster> _buildClusters(
    List<Hadith> hadiths,
    NarratorRepository narrators,
    ColorScheme scheme,
  ) {
    // Sesetengah hadis (cth. Hadis 27) diriwayatkan oleh lebih daripada
    // seorang perawi — kami tetapkan setiap hadis kepada perawi PERTAMA
    // sahaja (satu cabang induk sahaja per hadis), konsisten dengan
    // `MindMapScreen._buildClusters` supaya lukisan kekal pokok tulen
    // (tiada nod hadis berganda merentasi cabang).
    final buckets = <String, List<Hadith>>{};
    for (final hadith in hadiths) {
      final ids = hadith.allNarratorIds;
      final primaryId = ids.isNotEmpty ? ids.first : hadith.narrator.id;
      buckets.putIfAbsent(primaryId, () => []).add(hadith);
    }

    final entries = buckets.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    final total = entries.length;
    return [
      for (var i = 0; i < total; i++)
        MindMapCluster(
          label: _narratorLabel(entries[i].key, narrators),
          subtitle: narrators.byId(entries[i].key)?.title,
          accent: _clusterAccent(scheme, i, total),
          hadiths: entries[i].value
            ..sort((a, b) => a.number.compareTo(b.number)),
        ),
    ];
  }

  String _narratorLabel(String id, NarratorRepository narrators) {
    final profile = narrators.byId(id);
    if (profile != null && profile.name.isNotEmpty) return profile.name;
    return id;
  }

  /// Warna cabang: laluan TIGA warna (primary → pink → tertiary) — sama
  /// formula seperti `MindMapScreen`/`ModuleIdentity.accentFor` supaya
  /// identiti warna konsisten merentasi semua peta minda.
  Color _clusterAccent(ColorScheme scheme, int index, int total) {
    final dark = scheme.brightness == Brightness.dark;
    final thirdAccent = dark ? AppColors.darkGold : AppColors.pinkAccent;
    final t = total <= 1 ? 0.0 : index / (total - 1);
    if (t <= 0.5) return Color.lerp(scheme.primary, thirdAccent, t * 2)!;
    return Color.lerp(thirdAccent, scheme.tertiary, (t - 0.5) * 2)!;
  }
}
