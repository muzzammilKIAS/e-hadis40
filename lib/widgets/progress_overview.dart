import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';
import '../core/utils/app_breakpoints.dart';

class ProgressOverview extends StatelessWidget {
  const ProgressOverview({
    required this.completedHadiths,
    required this.bookmarks,
    required this.bestScore,
    required this.teacherMode,
    super.key,
  });

  final int completedHadiths;
  final int bookmarks;
  final int bestScore;
  final bool teacherMode;

  @override
  Widget build(BuildContext context) {
    final items = <_MetricData>[
      _MetricData(
        icon: Icons.task_alt_rounded,
        label: 'Hadis selesai',
        value: '$completedHadiths/40',
      ),
      _MetricData(
        icon: Icons.bookmark_rounded,
        label: 'Hadis pilihan',
        value: '$bookmarks',
      ),
      _MetricData(
        icon: Icons.workspace_premium_rounded,
        label: 'Markah terbaik',
        value: bestScore == 0 ? '—' : '$bestScore%',
      ),
      _MetricData(
        icon: teacherMode ? Icons.co_present_rounded : Icons.school_rounded,
        label: 'Mod penggunaan',
        value: teacherMode ? 'Guru' : 'Pelajar',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= AppBreakpoints.metric4Col
            ? 4
            : constraints.maxWidth >= AppBreakpoints.metric2Col
                ? 2
                : 1;
        const gap = 14.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final item in items)
              SizedBox(width: width, child: _MetricCard(data: item)),
          ],
        );
      },
    );
  }
}

class _MetricData {
  const _MetricData({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.data});

  final _MetricData data;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child:
                  Icon(data.icon, color: scheme.onPrimaryContainer, size: 22),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.value,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
