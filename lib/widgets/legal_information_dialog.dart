import 'package:flutter/material.dart';

import '../core/utils/dashboard_layout.dart';
import 'dashboard/islamic_atmosphere.dart';

/// Halaman "Hak Cipta & Penafian" — kandungan legal sahaja (sumber &
/// rujukan kandungan, hak cipta, penafian).
///
/// Sengaja diasingkan daripada [AboutEHadis40Dialog] (`about_ehadis40_dialog.dart`)
/// supaya kandungan legal kekal ringkas/neutral dan tidak bercampur dengan
/// tujuan pembangunan/objektif/pasukan yang lebih visual. Gaya di sini
/// sengaja minimal — tajuk, subtajuk, teks boleh baca, dan pembahagi
/// (`Divider`) — bukan kad "glass" bertema seperti halaman Tentang.
///
/// Dinamakan "Dialog" mengikut konvensyen yang diminta, tetapi
/// dilaksanakan sebagai halaman penuh boleh skrol (`Navigator.push`),
/// sepadan dengan corak sedia ada dalam projek untuk kandungan panjang.
class LegalInformationDialog extends StatelessWidget {
  const LegalInformationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: scheme.onSurface,
        iconTheme: IconThemeData(color: scheme.onSurface),
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
        title: const Text('Hak Cipta & Penafian'),
      ),
      body: IslamicAtmosphere(
        intensity: 0.5,
        child: Column(
          children: [
            SizedBox(
              height: kToolbarHeight + MediaQuery.of(context).padding.top,
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final layout = DashboardLayout.of(constraints);
                  return ListView(
                    padding: layout.pagePadding,
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 640),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _LegalSection(
                                title: 'Sumber & Rujukan Kandungan',
                                paragraphs: [
                                  'Kandungan pembelajaran dalam e-Hadis40 '
                                      'dibangunkan dengan merujuk kepada Modul '
                                      'Penghayatan Hadis 40 Imam Nawawi Edisi '
                                      'Kedua serta sumber rujukan berkaitan '
                                      'yang dinyatakan dalam aplikasi.',
                                  'Segala hak cipta bagi kandungan asal, '
                                      'teks, modul, logo, nama, identiti '
                                      'rasmi dan bahan rujukan pihak ketiga '
                                      'adalah milik pemegang hak '
                                      'masing-masing.',
                                  'Penggunaan bahan tersebut dalam e-Hadis40 '
                                      'adalah bagi tujuan pendidikan, '
                                      'pembelajaran, penyelidikan dan '
                                      'pembangunan prototaip inovasi.',
                                ],
                              ),
                              _LegalDivider(),
                              _LegalSection(
                                title: 'Hak Cipta',
                                paragraphs: [
                                  '© 2026 e-Hadis40.',
                                  'Hak cipta bagi reka bentuk antaramuka, '
                                      'susun atur interaktif, struktur '
                                      'pengalaman pengguna, ciri '
                                      'pembelajaran, integrasi sistem, kuiz '
                                      'dan komponen pembangunan asli '
                                      'e-Hadis40 adalah terpelihara.',
                                  'Sebarang pustaka perisian, framework, '
                                      'aset, ikon, font atau komponen pihak '
                                      'ketiga yang digunakan adalah '
                                      'tertakluk kepada lesen, hak cipta dan '
                                      'syarat penggunaan pemegang hak '
                                      'masing-masing.',
                                ],
                              ),
                              _LegalDivider(),
                              _LegalSection(
                                title: 'Penafian',
                                paragraphs: [
                                  'e-Hadis40 merupakan prototaip aplikasi '
                                      'pembelajaran yang dibangunkan secara '
                                      'bebas bagi tujuan pendidikan, '
                                      'pengajaran, pembelajaran dan inovasi '
                                      'teknologi pendidikan.',
                                  'e-Hadis40 bukan aplikasi rasmi, produk '
                                      'rasmi atau platform yang '
                                      'dibangunkan, ditaja, diperakui, '
                                      'disahkan atau diterbitkan oleh '
                                      'Kementerian Pendidikan Malaysia '
                                      '(KPM).',
                                  'Sebarang penyebutan Kementerian '
                                      'Pendidikan Malaysia adalah bagi '
                                      'tujuan rujukan dan pengiktirafan '
                                      'sumber modul yang digunakan dalam '
                                      'pembangunan kandungan pembelajaran '
                                      'dan tidak menunjukkan sebarang '
                                      'bentuk hubungan rasmi, endorsement '
                                      'atau kerjasama melainkan dinyatakan '
                                      'secara rasmi oleh pihak berkaitan.',
                                  'e-Hadis40 berfungsi sebagai alat '
                                      'sokongan pengajaran dan pembelajaran '
                                      'dan tidak bertujuan menggantikan '
                                      'modul, dokumen, garis panduan atau '
                                      'sumber rasmi yang diterbitkan oleh '
                                      'Kementerian Pendidikan Malaysia atau '
                                      'mana-mana pihak berautoriti.',
                                  'Sekiranya terdapat sebarang perbezaan '
                                      'antara kandungan dalam e-Hadis40 '
                                      'dengan sumber rasmi, sumber rasmi '
                                      'hendaklah dijadikan rujukan utama.',
                                ],
                              ),
                              SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalSection extends StatelessWidget {
  const _LegalSection({required this.title, required this.paragraphs});

  final String title;
  final List<String> paragraphs;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < paragraphs.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          Text(
            paragraphs[i],
            style: TextStyle(
              height: 1.65,
              color: scheme.onSurface.withValues(alpha: 0.92),
            ),
          ),
        ],
      ],
    );
  }
}

class _LegalDivider extends StatelessWidget {
  const _LegalDivider();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Divider(color: scheme.outlineVariant.withValues(alpha: 0.6)),
    );
  }
}
