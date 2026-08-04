import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'screens/main_shell.dart';
import 'screens/splash_screen.dart';
import 'services/app_controller.dart';

class EHadis40App extends StatefulWidget {
  const EHadis40App({super.key});

  @override
  State<EHadis40App> createState() => _EHadis40AppState();
}

class _EHadis40AppState extends State<EHadis40App> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _startSplashTimer();
  }

  void _startSplashTimer() {
    Future<void>.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: controller.themeMode,
      home: _showSplash ? const AppSplashScreen() : const MainShell(),
    );
  }
}
