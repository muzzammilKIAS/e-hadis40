import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/curriculum/app_curriculum_structure.dart';
import '../core/utils/dashboard_layout.dart';
import '../data/repositories/hadith_repository.dart';
import '../data/repositories/module_repository.dart';
import '../services/app_controller.dart';
import '../widgets/dashboard/glass_surface.dart';
import '../widgets/dashboard/module_learning_card.dart';
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
          padding: layout.pagePadding,
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
