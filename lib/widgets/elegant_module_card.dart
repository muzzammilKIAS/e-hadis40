import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';
import '../data/models/learning_module.dart';

class ElegantModuleCard extends StatefulWidget {
  const ElegantModuleCard({
    required this.module,
    required this.progress,
    required this.availableCount,
    required this.onTap,
    super.key,
  });

  final LearningModule module;
  final double progress;
  final int availableCount;
  final VoidCallback onTap;

  @override
  State<ElegantModuleCard> createState() => _ElegantModuleCardState();
}

class _ElegantModuleCardState extends State<ElegantModuleCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final percent = (widget.progress * 100).round();
    final completed = widget.progress >= 1;
    final inProgress = widget.progress > 0 && !completed;
    final status = completed
        ? 'Selesai'
        : inProgress
            ? 'Sedang Dipelajari'
            : 'Belum Bermula';

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: _hovered ? scheme.primary : scheme.outlineVariant,
              width: _hovered ? 1.5 : 1,
            ),
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '${widget.module.number}'.padLeft(2, '0'),
                          style: TextStyle(
                            color: scheme.onPrimaryContainer,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.arrow_outward_rounded,
                          color: scheme.primary, size: 20),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    widget.module.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    widget.module.rangeLabel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Text(
                        '$percent%',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      Text(
                        '${widget.availableCount}/5 kandungan',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: widget.progress,
                      minHeight: 7,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Icon(
                        completed
                            ? Icons.check_circle_rounded
                            : inProgress
                                ? Icons.timelapse_rounded
                                : Icons.circle_outlined,
                        size: 16,
                        color: completed
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(status,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
