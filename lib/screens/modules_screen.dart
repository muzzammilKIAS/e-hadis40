import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/curriculum/app_curriculum_structure.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/dashboard_layout.dart';
import '../data/repositories/hadith_repository.dart';
import '../data/repositories/module_repository.dart';
import '../services/app_controller.dart';
import '../widgets/dashboard/glass_surface.dart';
import '../widgets/dashboard/islamic_atmosphere.dart';
import '../widgets/dashboard/misi_pencari_hikmah_card.dart';
import '../widgets/dashboard/module_learning_card.dart';
import '../widgets/dashboard/uji_minda_card.dart';
import 'anatomi_sunnah_list_screen.dart';
import 'module_detail_screen.dart';

class ModulesScreen extends StatelessWidget {
  const ModulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final modules = context.read<ModuleRepository>().modules;
    final controller = context.watch<AppController>();
    final repository = context.read<HadithRepository>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = DashboardLayout.of(constraints);
        return SingleChildScrollView(
          // `MainShell` guna `extendBody: true`, jadi badan skrin memanjang
          // ke BELAKANG bar navigasi bawah. Tanpa menambah tinggi bar itu
          // pada padding bawah, kad terakhir kekal tersembunyi separuh di
          // bawah bar walau sudah skrol habis.
          padding: layout.pagePadding.copyWith(
            bottom: layout.pagePadding.bottom +
                MediaQuery.paddingOf(context).bottom,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: layout.contentWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DashboardSectionHeader(
                    title: 'Modul Pembelajaran',
                    subtitle:
                        'Hadis 1 hingga ${AppCurriculumStructure.totalHadiths} '
                        'disusun dalam ${AppCurriculumStructure.totalModules} '
                        'modul. Kandungan akan ditambah secara berperingkat '
                        'selepas semakan.',
                  ),
                  SizedBox(height: layout.sectionGap),
                  Wrap(
                    spacing: layout.gap,
                    runSpacing: layout.gap,
                    children: [
                      for (final module in modules)
                        SizedBox(
                          width: layout.itemWidth(layout.moduleColumns),
                          child: ModuleLearningCard(
                            module: module,
                            compact: layout.compactModuleCards,
                            progress: controller.moduleProgress(module),
                            completedCount:
                                controller.moduleCompletedCount(module),
                            availableCount: repository.availableHadiths
                                .where(
                                  (h) =>
                                      module.hadithNumbers.contains(h.number),
                                )
                                .length,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    ModuleDetailScreen(module: module),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: layout.sectionGap),
                  _AnatomiSunnahCard(layout: layout),
                  SizedBox(height: layout.sectionGap),
                  const _InteractiveActivitySection(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ───────────────────────── Anatomi Sunnah ──────────────────────────

/// Kotak promosi "Anatomi Sunnah 3D" — guna ikon `view_in_ar_rounded` yang
/// sama seperti slaid penutup mod projektor, supaya kedua-dua kemasukan
/// mengekalkan identiti visual yang konsisten. Navigasi belum disambungkan;
/// kandungan simulasi akan dibekalkan berasingan sebelum butang ini
/// diaktifkan.
class _AnatomiSunnahCard extends StatelessWidget {
  const _AnatomiSunnahCard({required this.layout});

  final DashboardLayout layout;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final dark = scheme.brightness == Brightness.dark;

    final heading = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: scheme.primary.withValues(alpha: dark ? 0.22 : 0.12),
            border: Border.all(color: scheme.primary.withValues(alpha: 0.32)),
          ),
          child: Icon(
            Icons.view_in_ar_rounded,
            size: 21,
            color: dark ? scheme.tertiary : scheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Anatomi Sunnah 3D',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: text.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Simulasi interaktif 3D bagi meneroka makna sebalik hadis.',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: text.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    // Butang tindakan utama kad ini — sengaja `FilledButton` (bukan
    // `OutlinedButton` seperti sebelum ini) dengan hijau lebih pekat dalam
    // mod cerah supaya ia menonjol sebagai butang sebenar, bukan sekadar
    // garis sempadan nipis di atas kotak yang kini turut berwarna hijau.
    final button = FilledButton.icon(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const AnatomiSunnahListScreen(),
        ),
      ),
      icon: const Icon(Icons.view_in_ar_rounded, size: 18),
      label: const Text('Buka Anatomi Sunnah'),
      style: dark
          ? null
          : FilledButton.styleFrom(
              backgroundColor: AppColors.primaryHover,
              foregroundColor: Colors.white,
            ),
    );

    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: IslamicCardPattern(color: scheme.primary, seed: 6),
          ),
        ),
        GlassSurface(
          padding: EdgeInsets.all(layout.isCompact ? 16 : 20),
          accent: scheme.primary.withValues(alpha: 0.35),
          child: layout.contentWidth >= 700
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: heading),
                    const SizedBox(width: 16),
                    button,
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    heading,
                    const SizedBox(height: 14),
                    button,
                  ],
                ),
        ),
      ],
    );
  }
}

// ───────────────────── Aktiviti Interaktif ─────────────────────────

/// Kotak "Aktiviti Interaktif" — satu bekas (kotak) tunggal yang memuatkan
/// kumpulan permainan pembelajaran (Xplorasi Minda, Misi Mencari Hikmah) di
/// dalamnya, di bawah kad Anatomi Sunnah 3D. Diletakkan di skrin Modul
/// (bukan dashboard) supaya jelas ia sebahagian daripada kumpulan aktiviti
/// pembelajaran, bukan kandungan utama halaman utama.
class _InteractiveActivitySection extends StatelessWidget {
  const _InteractiveActivitySection();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = scheme.brightness == Brightness.dark;

    return Stack(
      // `Clip.none` — Stack lalai memotong (Clip.hardEdge); tanpa ini,
      // lepasan ilustrasi roket kad di dalamnya akan terpotong di sini
      // walaupun `GlassSurface` di bawah sudah `clip: false`.
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: IslamicCardPattern(color: scheme.tertiary, seed: 9),
          ),
        ),
        GlassSurface(
          padding: const EdgeInsets.all(18),
          // `clip: false` — kad Xplorasi Minda & Misi Mencari Hikmah di
          // dalam kotak ini sengaja membenarkan ilustrasi roket melepasi
          // sempadan kad sendiri (lihat `UjiMindaCard`/
          // `MisiPencariHikmahCard`); jika kotak luar ini turut memotong
          // (clip), lepasan itu akan terpotong sebelum sempat "keluar"
          // secara visual.
          clip: false,
          // Kotak PEMBUNGKUS luar ini sengaja lebih cerah (bukan warna
          // `surface` pekat yang sama seperti kotak lain) dalam mod cerah
          // sahaja — kad Xplorasi Minda & Misi Mencari Hikmah di dalamnya
          // sudah ada latar gelap tersendiri, jadi kotak luar yang turut
          // pekat menjadikan keseluruhan seksyen terlalu berat/gelap.
          background: dark ? null : scheme.surfaceContainerLowest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color:
                          scheme.tertiary.withValues(alpha: dark ? 0.22 : 0.12),
                      border: Border.all(
                        color: scheme.tertiary.withValues(alpha: 0.32),
                      ),
                    ),
                    child: Icon(
                      Icons.sports_esports_rounded,
                      size: 21,
                      color: scheme.tertiary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Aktiviti Interaktif',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 15.5,
                              ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Permainan pembelajaran interaktif Hadis 40.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontSize: 12.5,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const UjiMindaCard(),
              const MisiPencariHikmahCard(),
            ],
          ),
        ),
      ],
    );
  }
}
