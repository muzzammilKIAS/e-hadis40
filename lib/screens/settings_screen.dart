import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_spacing.dart';
import '../core/utils/responsive.dart';
import '../services/app_controller.dart';
import '../widgets/app_footer.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();

    final pagePadding = Responsive.pagePadding(context);

    return SingleChildScrollView(
      // `MainShell` menetapkan `extendBody: true` — tambah tinggi bar
      // navigasi supaya hujung kandungan (footer) tidak tersembunyi.
      padding: pagePadding.copyWith(
        bottom: pagePadding.bottom + MediaQuery.paddingOf(context).bottom,
      ),
      child: Responsive.constrainedPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tetapan', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Sesuaikan pengalaman pembelajaran mengikut keperluan anda.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            _SettingsCard(
              title: 'Paparan',
              icon: Icons.palette_outlined,
              child: Column(
                children: [
                  _ThemeModeChoice(
                    value: ThemeMode.light,
                    title: 'Mod Cerah',
                    subtitle: 'Sentiasa gunakan paparan cerah.',
                    icon: Icons.light_mode_rounded,
                    groupValue: controller.themeMode,
                    onChanged: controller.setThemeMode,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _ThemeModeChoice(
                    value: ThemeMode.dark,
                    title: 'Mod Gelap',
                    subtitle: 'Sentiasa gunakan paparan gelap.',
                    icon: Icons.dark_mode_rounded,
                    groupValue: controller.themeMode,
                    onChanged: controller.setThemeMode,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _ThemeModeChoice(
                    value: ThemeMode.system,
                    title: 'Ikut Sistem',
                    subtitle:
                        'Tema berubah mengikut tetapan peranti atau sistem operasi.',
                    icon: Icons.settings_suggest_rounded,
                    groupValue: controller.themeMode,
                    onChanged: controller.setThemeMode,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _SettingsCard(
              title: 'Saiz teks Arab',
              icon: Icons.format_size_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Skala semasa: ${(controller.arabicScale * 100).round()}%',
                  ),
                  Slider(
                    value: controller.arabicScale,
                    min: 0.8,
                    max: 1.6,
                    divisions: 8,
                    label: '${(controller.arabicScale * 100).round()}%',
                    onChanged: controller.setArabicScale,
                  ),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      'إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ',
                      style: TextStyle(
                        fontFamily: AppConstants.arabicFontFamily,
                        fontFamilyFallback: AppConstants.arabicFontFallback,
                        fontSize: 28 * controller.arabicScale,
                        height: 1.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _SettingsCard(
              title: 'Mod penggunaan',
              icon: Icons.school_outlined,
              child: SwitchListTile(
                value: controller.teacherMode,
                onChanged: controller.setTeacherMode,
                title: const Text('Aktifkan Mod Guru'),
                subtitle: const Text(
                  'Membuka akses lebih jelas kepada paparan projektor dan aktiviti kelas.',
                ),
                secondary: const Icon(Icons.co_present_rounded),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _SettingsCard(
              title: 'Data pembelajaran',
              icon: Icons.storage_rounded,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Reset progres, bookmark, markah dan nota'),
                subtitle:
                    const Text('Tema dan saiz tulisan tidak akan dipadam.'),
                trailing: OutlinedButton(
                  onPressed: () => _confirmReset(context, controller),
                  child: const Text('Reset'),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const AppFooter(),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReset(
    BuildContext context,
    AppController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset data pembelajaran?'),
        content: const Text(
          'Tindakan ini akan memadam progres, bookmark, markah kuiz dan nota peribadi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.resetLearningData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data pembelajaran telah direset.')),
        );
      }
    }
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            child,
          ],
        ),
      ),
    );
  }
}

class _ThemeModeChoice extends StatelessWidget {
  const _ThemeModeChoice({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.groupValue,
    required this.onChanged,
  });

  final ThemeMode value;
  final String title;
  final String subtitle;
  final IconData icon;
  final ThemeMode groupValue;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: selected ? scheme.secondaryContainer : scheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              ConstrainedBox(
                constraints:
                    const BoxConstraints.tightFor(width: 44, height: 44),
                child: Icon(
                  icon,
                  color: selected
                      ? scheme.onSecondaryContainer
                      : scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: selected
                            ? scheme.onSecondaryContainer
                            : scheme.onSurface,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: selected
                            ? scheme.onSecondaryContainer.withValues(alpha: 0.8)
                            : scheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(
                  Icons.check_circle_rounded,
                  color: scheme.onSecondaryContainer,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
