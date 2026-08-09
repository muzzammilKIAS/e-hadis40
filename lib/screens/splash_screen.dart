import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';

class AppSplashScreen extends StatefulWidget {
  const AppSplashScreen({super.key});

  @override
  State<AppSplashScreen> createState() => _AppSplashScreenState();
}

class _AppSplashScreenState extends State<AppSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.darkBackground,
              AppColors.darkSurface,
              AppColors.darkSecondarySurface,
              AppColors.darkElevatedSurface,
            ],
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: -120,
              right: -80,
              child: Opacity(
                opacity: 0.06,
                child: Icon(
                  Icons.mosque_rounded,
                  size: 380,
                  color: AppColors.darkPrimary,
                ),
              ),
            ),
            const Positioned(
              bottom: -60,
              left: -40,
              child: Opacity(
                opacity: 0.04,
                child: Icon(
                  Icons.auto_stories_rounded,
                  size: 280,
                  color: AppColors.darkSecondary,
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FadeTransition(
                              opacity: _logoScale,
                              child: Transform.scale(
                                scale: _logoScale.value,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(28),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.darkPrimary
                                            .withValues(alpha: 0.25),
                                        AppColors.darkPrimaryHover
                                            .withValues(alpha: 0.15),
                                      ],
                                    ),
                                      border: Border.all(
                                        color: AppColors.darkPrimary
                                            .withValues(alpha: 0.3),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.darkPrimary
                                              .withValues(alpha: 0.12),
                                        blurRadius: 40,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(28),
                                    child: Image.asset(
                                      'assets/images/logo_e_hadis40.png',
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            FadeTransition(
                              opacity: _fadeIn,
                              child: Column(
                                children: [
                                  const Text(
                                    AppConstants.appName,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.5,
                                       color: AppColors.darkTextPrimary,
                                      height: 1.15,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'PROTOTAIP PEMBELAJARAN INTERAKTIF',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.8,
                                       color: AppColors.darkSecondary
                                           .withValues(alpha: 0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.darkPrimary
                                          .withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: AppColors.darkPrimary
                                            .withValues(alpha: 0.18),
                                      ),
                                    ),
                                    child: Text(
                                      AppConstants.appShortDescription,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.darkPrimary
                                            .withValues(alpha: 0.9),
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 48),
                            SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation(
                                  AppColors.darkPrimary
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              'Berasaskan Modul Penghayatan\nHadis 40 Imam Nawawi Edisi Kedua\nKementerian Pendidikan Malaysia',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                height: 1.5,
                                color:
                                    AppColors.darkTextPrimary.withValues(alpha: 0.3),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '\u00a9 2026 e-Hadis40',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color:
                                    AppColors.darkTextPrimary.withValues(alpha: 0.35),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
