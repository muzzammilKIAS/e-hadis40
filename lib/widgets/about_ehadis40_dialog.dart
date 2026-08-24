import 'package:flutter/material.dart';

import '../core/utils/dashboard_layout.dart';
import 'dashboard/glass_surface.dart';
import 'dashboard/islamic_atmosphere.dart';

/// Halaman "Tentang e-Hadis40" — maklumat produk, tujuan pembangunan,
/// objektif, ciri utama dan pasukan pembangun.
///
/// Ini BUKAN halaman penafian/hak cipta (lihat [LegalInformationDialog] di
/// `legal_information_dialog.dart` untuk itu) — dipisahkan secara sengaja
/// supaya maklumat produk yang lebih visual tidak bercampur dengan
/// kandungan legal yang perlu kekal ringkas dan neutral.
///
/// Dinamakan "Dialog" mengikut konvensyen yang diminta, tetapi
/// dilaksanakan sebagai halaman penuh (`Navigator.push`) — corak yang
/// sedia digunakan dalam projek ini untuk kandungan super panjang/boleh
/// skrol (lihat `ModuleDetailScreen`, `HadithScreen`), bukan `Dialog`
/// bersaiz kekangan seperti kotak penafian splash.
class AboutEHadis40Dialog extends StatelessWidget {
  const AboutEHadis40Dialog({super.key});

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
        title: const Text('Tentang e-Hadis40'),
      ),
      body: IslamicAtmosphere(
        intensity: 0.7,
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
                          constraints: const BoxConstraints(maxWidth: 720),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _Hero(),
                              SizedBox(height: 28),
                              _IntroSection(),
                              SizedBox(height: 28),
                              _Section(
                                icon: Icons.flag_rounded,
                                title: 'Tujuan Pembangunan',
                                child: Text(
                                  'e-Hadis40 dibangunkan sebagai prototaip '
                                  'inovasi pendidikan bagi memperkasa '
                                  'pengajaran dan pembelajaran Hadis 40 '
                                  'melalui penggunaan teknologi digital yang '
                                  'lebih interaktif, mudah diakses dan sesuai '
                                  'dengan keperluan pembelajaran semasa.',
                                  style: TextStyle(height: 1.6),
                                ),
                              ),
                              SizedBox(height: 28),
                              _Section(
                                icon: Icons.track_changes_rounded,
                                title: 'Objektif',
                                child: _ObjectiveList(),
                              ),
                              SizedBox(height: 28),
                              _Section(
                                icon: Icons.auto_awesome_rounded,
                                title: 'Ciri Utama',
                                child: _FeatureGrid(),
                              ),
                              SizedBox(height: 28),
                              _Section(
                                icon: Icons.groups_rounded,
                                title: 'Pasukan Pembangun',
                                child: _TeamSection(),
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

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            'assets/images/e_hadis40_logo_official.png',
            width: 72,
            height: 72,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
        const SizedBox(height: 16),
        Text('e-Hadis40', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(
          'Platform Pengajaran dan Pembelajaran Interaktif',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'Prototaip Inovasi Pendidikan',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
              color: scheme.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}

class _IntroSection extends StatelessWidget {
  const _IntroSection();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GlassSurface(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'e-Hadis40 ialah platform pengajaran dan pembelajaran '
            'interaktif yang dibangunkan bagi menyokong pembelajaran serta '
            'penghayatan Hadis 40 Imam al-Nawawi melalui pendekatan digital '
            'yang lebih mudah, tersusun dan interaktif.',
            style: TextStyle(height: 1.6),
          ),
          const SizedBox(height: 12),
          const Text(
            'Platform ini dibangunkan berasaskan Modul Penghayatan Hadis '
            '40 Imam Nawawi Edisi Kedua sebagai salah satu sumber rujukan '
            'utama kandungan pembelajaran.',
            style: TextStyle(height: 1.6),
          ),
          const SizedBox(height: 12),
          const Text(
            'e-Hadis40 mengintegrasikan kandungan hadis dengan pelbagai '
            'ciri pembelajaran digital seperti teks hadis, terjemahan, '
            'audio, sorotan teks, penerangan, kuiz dan aktiviti interaktif.',
            style: TextStyle(height: 1.6),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.6)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.menu_book_rounded, size: 16, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                      children: const [
                        TextSpan(
                          text: 'Rujukan Modul: ',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(
                          text: 'Kementerian Pendidikan Malaysia (KPM)',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(
      {required this.icon, required this.title, required this.child});

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: scheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        child,
      ],
    );
  }
}

const _objectives = <String>[
  'Memudahkan akses kepada bahan pembelajaran Hadis 40.',
  'Menyokong proses pengajaran dan pembelajaran secara digital.',
  'Membantu pelajar memahami dan menghayati kandungan hadis melalui '
      'teks, audio dan aktiviti interaktif.',
  'Menyediakan pengalaman pembelajaran yang boleh digunakan melalui '
      'komputer, tablet dan telefon pintar.',
  'Memperkasa pembelajaran hadis dalam era digital.',
];

class _ObjectiveList extends StatelessWidget {
  const _ObjectiveList();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GlassSurface(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < _objectives.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_rounded,
                    size: 18, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child:
                      Text(_objectives[i], style: const TextStyle(height: 1.5)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _FeatureSpec {
  const _FeatureSpec(this.icon, this.label);
  final IconData icon;
  final String label;
}

/// Hanya ciri yang BENAR-BENAR wujud dalam aplikasi (disemak terus
/// terhadap model `Hadith`, `AppController`, `HadithPlaylistScreen`,
/// `DashboardLayout`/`Responsive`, dan `web/manifest.json` untuk PWA).
const _features = <_FeatureSpec>[
  _FeatureSpec(Icons.menu_book_rounded, 'Teks hadis'),
  _FeatureSpec(Icons.translate_rounded, 'Terjemahan'),
  _FeatureSpec(Icons.headphones_rounded, 'Audio'),
  _FeatureSpec(Icons.highlight_alt_rounded, 'Sorotan teks'),
  _FeatureSpec(Icons.lightbulb_rounded, 'Penerangan hadis'),
  _FeatureSpec(Icons.quiz_rounded, 'Kuiz interaktif'),
  _FeatureSpec(Icons.extension_rounded, 'Aktiviti pembelajaran'),
  _FeatureSpec(Icons.devices_rounded, 'Responsive design'),
  _FeatureSpec(Icons.install_mobile_rounded, 'Progressive Web App'),
  _FeatureSpec(
    Icons.laptop_chromebook_rounded,
    'Sokongan komputer, tablet & telefon pintar',
  ),
];

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 560 ? 2 : 1;
        final width = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final feature in _features)
              SizedBox(
                width: width,
                child: GlassSurface(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  radius: 14,
                  child: Row(
                    children: [
                      Icon(feature.icon, size: 18, color: scheme.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          feature.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TeamMemberSpec {
  const _TeamMemberSpec(this.name, this.role);
  final String name;
  final String role;
}

const _team = <_TeamMemberSpec>[
  _TeamMemberSpec('Adam Abd. Azid', 'Ketua Projek'),
  _TeamMemberSpec('Muzzammil Najib', 'Reka Bentuk & UI/UX'),
  _TeamMemberSpec('Saeid Ramadhan', 'Pembangunan Teknikal & Pengujian Sistem'),
];

class _TeamSection extends StatelessWidget {
  const _TeamSection();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GlassSurface(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < _team.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: scheme.primaryContainer,
                  child: Text(
                    _team[i].name.trim()[0],
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _team[i].name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        _team[i].role,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 18),
          Divider(color: scheme.outlineVariant.withValues(alpha: 0.6)),
          const SizedBox(height: 14),
          Text(
            'Fakulti Pengajian Islam & Bahasa Arab',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 3),
          Text(
            'Kolej Universiti Islam Antarabangsa Sultan Ismail Petra (KIAS)',
            style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
