import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_spacing.dart';
import '../core/utils/responsive.dart';
import '../data/repositories/hadith_repository.dart';
import '../services/app_controller.dart';
import '../widgets/empty_state.dart';
import 'hadith_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final repository = context.read<HadithRepository>();
    final saved = repository.availableHadiths
        .where((hadith) => controller.isBookmarked(hadith.id))
        .toList();

    if (saved.isEmpty) {
      return const EmptyState(
        icon: Icons.bookmark_border_rounded,
        title: 'Belum ada Hadis Pilihan',
        message:
            'Tekan ikon bookmark pada halaman hadis untuk menyimpannya di sini.',
      );
    }

    return SingleChildScrollView(
      padding: Responsive.pagePadding(context),
      child: Responsive.constrainedPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hadis Pilihan',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${saved.length} hadis telah disimpan untuk rujukan semula.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            for (final hadith in saved) ...[
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(AppSpacing.xl),
                  leading: CircleAvatar(child: Text(hadith.displayNumber)),
                  title: Text(hadith.title),
                  subtitle: Text(hadith.theme),
                  trailing: IconButton(
                    tooltip: 'Buang daripada Hadis Pilihan',
                    onPressed: () => controller.toggleBookmark(hadith.id),
                    icon: const Icon(Icons.bookmark_remove_rounded),
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => HadithScreen(hadith: hadith),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    );
  }
}
