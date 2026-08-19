import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/curriculum/app_curriculum_structure.dart';
import '../core/utils/dashboard_layout.dart';
import '../data/repositories/hadith_repository.dart';
import '../widgets/app_footer.dart';
import '../widgets/dashboard/anatomi_sunnah_hadith_card.dart';
import '../widgets/dashboard/islamic_atmosphere.dart';
import 'anatomi_sunnah_screen.dart';

/// Senarai penuh "Anatomi Sunnah 3D" — memaparkan Hadis 1 hingga 42 dalam
/// kotak kad (gaya sama seperti kad Modul Pembelajaran), supaya pengguna
/// memilih sendiri hadis yang ingin diterokai dalam simulasi 3D, bukan
/// terus dibawa ke Hadis 1. Hadis yang belum ada simulasi (>14) dipaparkan
/// dalam keadaan "Akan Datang", konsisten dengan cara kad Modul memaparkan
/// modul yang belum tersedia.
///
/// Grid dibina secara "lazy" (`SliverGrid.builder`) supaya hanya kad yang
/// kelihatan di skrin sahaja dibina pada mulanya — 42 kad dibina sekali gus
/// terasa berat pada pembukaan skrin.
class AnatomiSunnahListScreen extends StatelessWidget {
  const AnatomiSunnahListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = context.read<HadithRepository>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        // Jalur dikaburkan (blur) supaya kad yang skrol di belakangnya
        // (`extendBodyBehindAppBar: true`) tidak bercampur/bertindih
        // dengan tajuk — hanya jalur AppBar ini sahaja yang dikaburkan,
        // bukan seluruh skrin, jadi kesan prestasi minimum.
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: AppBar(
              backgroundColor: scheme.surface.withValues(alpha: 0.55),
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              foregroundColor: scheme.onSurface,
              iconTheme: IconThemeData(color: scheme.onSurface),
              titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
              title: const Text('Anatomi Sunnah 3D'),
            ),
          ),
        ),
      ),
      body: IslamicAtmosphere(
        intensity: 0.7,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final layout = DashboardLayout.of(constraints);
            final columns = layout.moduleColumns;
            final compact = layout.compactModuleCards;
            final itemHeight = compact ? 158.0 : 182.0;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: kToolbarHeight + MediaQuery.of(context).padding.top,
                  ),
                ),
                SliverPadding(
                  padding: layout.pagePadding.copyWith(bottom: 0),
                  sliver: SliverToBoxAdapter(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: layout.contentWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pilih Hadis',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Simulasi 3D interaktif bagi meneroka makna '
                              'sebalik setiap hadis. ${AnatomiSunnahScreen.availableHadithSet.length} '
                              'daripada ${AppCurriculumStructure.totalHadiths} hadis sedia '
                              'dimainkan; selebihnya akan ditambah secara berperingkat.',
                              style: TextStyle(
                                color: scheme.onSurfaceVariant,
                                fontSize: 13.5,
                              ),
                            ),
                            SizedBox(height: layout.sectionGap),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverCenteredCrossAxis(
                  contentWidth: layout.contentWidth,
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: layout.gap,
                      crossAxisSpacing: layout.gap,
                      mainAxisExtent: itemHeight,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _hadithCard(
                        context: context,
                        repository: repository,
                        number: index + 1,
                        compact: compact,
                      ),
                      childCount: AppCurriculumStructure.totalHadiths,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: layout.sectionGap),
                ),
                const SliverToBoxAdapter(child: AppFooter()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _hadithCard({
    required BuildContext context,
    required HadithRepository repository,
    required int number,
    required bool compact,
  }) {
    final moduleId = AppCurriculumStructure.moduleIdFor(number);
    final moduleNumber = int.parse(moduleId.substring(moduleId.length - 2));
    final available = AnatomiSunnahScreen.isAvailable(number);

    return AnatomiSunnahHadithCard(
      hadithNumber: number,
      moduleNumber: moduleNumber,
      title: repository.byNumber(number)?.title ?? 'Hadis $number',
      available: available,
      compact: compact,
      onTap: available
          ? () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AnatomiSunnahScreen(hadithNumber: number),
                ),
              )
          : null,
    );
  }
}

/// Mengehadkan lebar [sliver] kepada [contentWidth] dan memusatkannya
/// merentasi keseluruhan lebar yang ada — tanpa ini, sliver yang dikekang
/// (`SliverConstrainedCrossAxis`) hanya melekat di tepi kiri, menyebabkan
/// grid kad kelihatan tersasar ke kiri berbanding tajuk/perenggan di
/// atasnya yang dipusatkan melalui [Align].
class SliverCenteredCrossAxis extends StatelessWidget {
  const SliverCenteredCrossAxis({
    required this.contentWidth,
    required this.sliver,
    super.key,
  });

  final double contentWidth;
  final Widget sliver;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final inset = ((constraints.crossAxisExtent - contentWidth) / 2).clamp(
          0.0,
          double.infinity,
        );
        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: inset),
          sliver: sliver,
        );
      },
    );
  }
}
