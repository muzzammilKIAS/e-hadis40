import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import 'app_breakpoints.dart';

class Responsive {
  const Responsive._();

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppBreakpoints.desktop;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= AppBreakpoints.tablet && width < AppBreakpoints.desktop;
  }

  static int gridColumns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppBreakpoints.grid4Col) return 4;
    if (width >= AppBreakpoints.grid2Col) return 2;
    return 1;
  }

  static EdgeInsets pagePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppBreakpoints.wide) {
      return const EdgeInsets.all(32);
    }
    if (width >= AppBreakpoints.tablet) {
      return const EdgeInsets.all(24);
    }
    return const EdgeInsets.fromLTRB(16, 18, 16, 28);
  }

  static Widget constrainedPage({required Widget child}) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppConstants.maxContentWidth,
        ),
        child: child,
      ),
    );
  }
}
