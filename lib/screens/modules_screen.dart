import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_spacing.dart';
import '../core/utils/app_breakpoints.dart';
import '../core/utils/responsive.dart';
import '../data/repositories/hadith_repository.dart';
import '../data/repositories/module_repository.dart';
import '../services/app_controller.dart';
import '../widgets/elegant_module_card.dart';
import 'module_detail_screen.dart';

class ModulesScreen extends StatelessWidget {
  const ModulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final modules = context.read<ModuleRepository>().modules;
    final controller = context.watch<AppController>();
    final repository = context.read<HadithRepository>();

    return SingleChildScrollView(
      padding: Responsive.pagePadding(context),
      child: Responsive.constrainedPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Modul Pembelajaran',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Hadis 1 hingga 42 disusun dalam lapan modul. Kandungan akan '
              'ditambah secara berperingkat selepas semakan.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= AppBreakpoints.grid4Col
                    ? 4
                    : constraints.maxWidth >= AppBreakpoints.grid2Col
                        ? 2
                        : 1;
                const gap = 16.0;
                final width =
                    (constraints.maxWidth - gap * (columns - 1)) / columns;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final module in modules)
                      SizedBox(
                        width: width,
                        child: ElegantModuleCard(
                          module: module,
                          progress: controller.moduleProgress(module),
                          completedCount:
                              controller.moduleCompletedCount(module),
                          availableCount: repository.availableHadiths
                              .where(
                                (h) => module.hadithNumbers.contains(h.number),
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
