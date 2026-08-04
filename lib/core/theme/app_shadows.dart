import 'package:flutter/material.dart';

class AppShadows {
  const AppShadows._();

  static List<BoxShadow> subtle(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return [
      BoxShadow(
        color: scheme.shadow.withValues(alpha: 0.06),
        blurRadius: 12,
        offset: const Offset(0, 2),
      ),
    ];
  }

  static List<BoxShadow> elevated(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return [
      BoxShadow(
        color: scheme.shadow.withValues(alpha: 0.08),
        blurRadius: 20,
        offset: const Offset(0, 6),
      ),
    ];
  }
}
