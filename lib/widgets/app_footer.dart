import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.xl),
          Icon(Icons.auto_stories_rounded,
              size: 28, color: scheme.primary.withValues(alpha: 0.5)),
          const SizedBox(height: AppSpacing.md),
          Text(
            '\u00a9 2026 e-Hadis40. Hak cipta terpelihara.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Muzzammil Najib | Saied Ramadhan | Adam Abd. Azid',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontSize: 11,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(
              'Kandungan pembelajaran dibangunkan berasaskan Modul '
              'Penghayatan Hadis 40 Imam Nawawi Edisi Kedua, '
              'Kementerian Pendidikan Malaysia.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontSize: 11,
                    height: 1.4,
                  ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const _AboutPage(),
                ),
              );
            },
            icon: const Icon(Icons.info_outline_rounded, size: 16),
            label: const Text('Tentang Aplikasi'),
            style: TextButton.styleFrom(
              foregroundColor: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

class _AboutPage extends StatelessWidget {
  const _AboutPage();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Tentang e-Hadis40')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/e_hadis40_logo_official.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'e-Hadis40',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Platform Pengajaran dan Pembelajaran Interaktif\n'
                    'Modul Penghayatan Hadis 40 Imam al-Nawawi\n'
                    'Kementerian Pendidikan Malaysia.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Prototaip Pembelajaran Interaktif',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),
            Text(
              '\u00a9 2026 e-Hadis40. Hak cipta reka bentuk aplikasi, susun '
              'atur interaktif, sistem audio, sorotan teks, kuiz dan kod '
              'sumber adalah terpelihara.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                    color: scheme.onSurface,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Kandungan pembelajaran dalam prototaip ini dibangunkan '
              'berasaskan Modul Penghayatan Hadis 40 Imam Nawawi Edisi Kedua '
              'yang digunakan dalam pelaksanaan Aktiviti Penghayatan Hadis 40 '
              'Imam Nawawi di institusi pendidikan bawah Kementerian '
              'Pendidikan Malaysia.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                    color: scheme.onSurface,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'e-Hadis40 ialah sebuah prototaip aplikasi pembelajaran yang '
              'dibangunkan secara bebas dan bukan aplikasi rasmi, produk '
              'rasmi atau platform yang diperakui oleh Kementerian Pendidikan '
              'Malaysia.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                    color: scheme.onSurface,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Hak cipta kandungan asal, modul, logo, nama dan identiti '
              'rasmi Kementerian Pendidikan Malaysia kekal milik pemegang hak '
              'masing-masing.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                    color: scheme.onSurface,
                  ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),
            Text(
              'Pembangun Aplikasi',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Muzzammil Najib | Saied Ramadhan | Adam Abd. Azid',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.7,
                    color: scheme.onSurface,
                  ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),
            Text(
              'Modul Penghayatan Hadis 40 Imam Nawawi Edisi Kedua',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kementerian Pendidikan Malaysia',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
