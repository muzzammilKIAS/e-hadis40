import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';
import 'about_ehadis40_dialog.dart';
import 'legal_information_dialog.dart';

/// Footer kongsi merentasi Dashboard, Modul, Hadis, Tetapan dan Anatomi
/// Sunnah — hierarki: nama/kredit pembangun → Fakulti → penafian ringkas →
/// pautan (Tentang e-Hadis40 / Hak Cipta & Penafian) → hak cipta.
///
/// Kandungan legal PENUH (penafian lengkap, hak cipta terperinci, sumber
/// rujukan) sengaja TIDAK diletakkan di sini — footer kekal ringkas/tidak
/// sarat, dan pengguna yang mahukan butiran penuh boleh klik pautan
/// "Hak Cipta & Penafian" ke [LegalInformationDialog]. Maklumat produk
/// (tujuan, objektif, ciri, pasukan) pula di [AboutEHadis40Dialog].
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mutedStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
          fontSize: 11.5,
          height: 1.5,
        );

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.xl),
          Icon(Icons.auto_stories_rounded,
              size: 26, color: scheme.primary.withValues(alpha: 0.5)),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Dibangunkan oleh',
            textAlign: TextAlign.center,
            style: mutedStyle?.copyWith(fontSize: 10.5, letterSpacing: 0.3),
          ),
          const SizedBox(height: 3),
          Text(
            'Adam Abd. Azid · Muzzammil Najib · Saeid Ramadhan',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
          ),
          const SizedBox(height: 3),
          Text(
            'Fakulti Pengajian Islam & Bahasa Arab, KIAS',
            textAlign: TextAlign.center,
            style: mutedStyle,
          ),
          const SizedBox(height: AppSpacing.lg),
          // Penafian RINGKAS sahaja pada footer/homepage — kandungan legal
          // penuh dipindahkan ke `LegalInformationDialog` supaya footer
          // tidak sarat/panjang.
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Text(
              'e-Hadis40 ialah prototaip inovasi pendidikan yang '
              'dibangunkan secara bebas berasaskan Modul Penghayatan Hadis '
              '40 Imam Nawawi Edisi Kedua. Bukan aplikasi rasmi Kementerian '
              'Pendidikan Malaysia (KPM).',
              textAlign: TextAlign.center,
              style: mutedStyle,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [
              _FooterLink(
                label: 'Tentang e-Hadis40',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const AboutEHadis40Dialog(),
                  ),
                ),
              ),
              Text(
                '·',
                style: TextStyle(
                    color: scheme.onSurfaceVariant.withValues(
                  alpha: 0.6,
                )),
              ),
              _FooterLink(
                label: 'Hak Cipta & Penafian',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const LegalInformationDialog(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '© 2026 e-Hadis40',
            textAlign: TextAlign.center,
            style: mutedStyle,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: scheme.onSurfaceVariant,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: const Size(0, 32),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      child: Text(label),
    );
  }
}
