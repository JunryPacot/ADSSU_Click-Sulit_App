import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/campus_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/firebase_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _animController.forward();

    // Automatic splash transition: direct returning users to login/home
    _navTimer = Timer(const Duration(milliseconds: 2400), () async {
      if (!mounted) return;
      try {
        final prefs = await SharedPreferences.getInstance();
        final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
        final savedEmail = prefs.getString('current_user_email');

        // Check if an existing authenticated Firebase user session is active
        if (FirebaseService().isInitialized) {
          final u = FirebaseService().auth.currentUser;
          if (u != null) {
            if (!mounted) return;
            if (u.email?.toLowerCase() == CampusConstants.demoAdminEmail.toLowerCase()) {
              context.go('/admin/dashboard');
            } else {
              context.go('/home');
            }
            return;
          }
        }

        // Also check persisted local session for returning logged-in users (Shopee-like persistence)
        if (savedEmail != null && savedEmail.isNotEmpty) {
          if (!mounted) return;
          if (savedEmail.toLowerCase() == CampusConstants.demoAdminEmail.toLowerCase()) {
            context.go('/admin/dashboard');
          } else {
            context.go('/home');
          }
          return;
        }

        if (!mounted) return;
        if (hasSeenOnboarding) {
          // Returning user: direct to login screen, skip onboarding steps 1, 2, 3
          context.go('/login');
        } else {
          // First-time user: display introductory onboarding
          context.go('/onboarding-sell');
        }
      } catch (_) {
        if (!mounted) return;
        context.go('/login');
      }
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.primaryDarkGreen,
      body: Stack(
        children: [
          // Background organic curves
          Positioned(
            top: -60,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.midGreen.withAlpha(50),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentGold.withAlpha(30),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Campus Pill Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.cardWhite.withAlpha(25),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.accentGold.withAlpha(120),
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified,
                                  size: 14,
                                  color: AppColors.accentGold,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'OFFICIAL CAMPUS PLATFORM',
                                  style: TextStyle(
                                    color: AppColors.cardWhite,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Logo in elevated white rounded card
                          Container(
                            width: size.width * 0.72 > 260 ? 260 : size.width * 0.72,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.cardWhite,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 20,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              AppAssets.logo,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // App Title & Tagline
                          Text(
                            CampusConstants.appTitle,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: AppColors.cardWhite,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                          ),
                          const SizedBox(height: 8),

                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accentGold,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              CampusConstants.appTagline,
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          Text(
                            'A Campus-Based Circular Economy\nand Peer-to-Peer Exchange Platform',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.paleGreen.withAlpha(220),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 48),

                          // Subtle loading spinner with gold tint
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentGold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

