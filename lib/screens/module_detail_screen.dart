import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_spacing.dart';
import '../core/utils/responsive.dart';
import '../data/models/hadith.dart';
import '../data/models/learning_module.dart';
import '../data/repositories/hadith_repository.dart';
import '../services/app_controller.dart';
import '../widgets/app_footer.dart';
import 'hadith_screen.dart';

class ModuleDetailScreen extends StatelessWidget {
  const ModuleDetailScreen({required this.module, super.key});

  final LearningModule module;

  @override
  Widget build(BuildContext context) {
    final repository = context.read<HadithRepository>();
    final controller = context.watch<AppController>();
    final progress = controller.moduleProgress(module);

    return Scaffold(
      appBar: AppBar(title: Text('${module.title} · ${module.rangeLabel}')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: Responsive.pagePadding(context),
              children: [
                Responsive.constrainedPage(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                module.title,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(module.rangeLabel),
                              const SizedBox(height: AppSpacing.xl),
                              Row(
                                children: [
                                  Text(
                                    '${(progress * 100).round()}% selesai',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const Spacer(),
                                  Text('${module.hadithNumbers.length} hadis'),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      Text(
                        'Perjalanan pembelajaran',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      for (final number in module.hadithNumbers) ...[
                        _HadithListTile(
                          number: number,
                          hadith: repository.byNumber(number),
                          completed: controller.isCompleted(
                            'hadith_${number.toString().padLeft(2, '0')}',
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const AppFooter(),
        ],
      ),
    );
  }
}

class _HadithListTile extends StatelessWidget {
  const _HadithListTile({
    required this.number,
    required this.hadith,
    required this.completed,
  });

  final int number;
  final Hadith? hadith;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final available = hadith != null;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        enabled: available,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.sm,
        ),
        leading: CircleAvatar(
          backgroundColor: available
              ? scheme.primaryContainer
              : scheme.surfaceContainerHighest,
          child: Text(
            number.toString().padLeft(2, '0'),
            style: TextStyle(
              color: available
                  ? scheme.onPrimaryContainer
                  : scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        title: Text(
          available ? hadith!.title : 'Hadis $number',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          available
              ? hadith!.theme
              : 'Kandungan sedang disediakan selepas proses semakan.',
        ),
        trailing: available
            ? Icon(
                completed
                    ? Icons.check_circle_rounded
                    : Icons.arrow_forward_rounded,
                color: completed ? scheme.primary : null,
              )
            : const Icon(Icons.lock_outline_rounded),
        onTap: available
            ? () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => HadithScreen(hadith: hadith!),
                  ),
                )
            : null,
      ),
    );
  }
}
