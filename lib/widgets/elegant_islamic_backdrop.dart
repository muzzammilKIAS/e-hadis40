import 'package:flutter/material.dart';

class ElegantIslamicBackdrop extends StatelessWidget {
  const ElegantIslamicBackdrop({
    required this.child,
    required this.padding,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.inverseSurface,
              Color.lerp(scheme.inverseSurface, scheme.primary, 0.3)!,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -40,
              right: -30,
              child: Opacity(
                opacity: 0.06,
                child: Icon(
                  Icons.mosque_rounded,
                  size: 180,
                  color: scheme.onInverseSurface,
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: -20,
              child: Opacity(
                opacity: 0.05,
                child: Icon(
                  Icons.auto_stories_rounded,
                  size: 120,
                  color: scheme.onInverseSurface,
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}
