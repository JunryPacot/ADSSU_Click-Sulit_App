import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/primary_button.dart';

void _completeOnboarding(BuildContext context) {
  SharedPreferences.getInstance().then((prefs) {
    prefs.setBool('has_seen_onboarding', true);
  }).catchError((_) {});
  context.go('/login');
}

class OnboardingScreen extends StatelessWidget {
  final int step; // 1, 2, or 3
  final String title;
  final String description;
  final IconData icon;
  final String primaryButtonText;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final List<String> highlights;

  const OnboardingScreen({
    super.key,
    required this.step,
    required this.title,
    required this.description,
    required this.icon,
    required this.primaryButtonText,
    required this.onNext,
    required this.onSkip,
    required this.highlights,
  });

  // Screen 2: Onboarding Sell
  factory OnboardingScreen.sell(BuildContext context) {
    return OnboardingScreen(
      step: 1,
      title: 'Sell What You No Longer Need',
      description:
          'Turn your pre-loved textbooks, uniforms, calculators, and campus gear into cash. Exclusively for the ADSSU student and staff community.',
      icon: Icons.storefront_rounded,
      primaryButtonText: 'Next: Exchange',
      highlights: const [
        'Verified peer-to-peer campus marketplace',
        'Safe on-campus meet-up spots at ADSSU buildings',
        'Direct cash or GCash transactions between peers',
      ],
      // 2 Onboarding Sell → 3 | Skip → 5
      onNext: () => context.go('/onboarding-exchange'),
      onSkip: () => _completeOnboarding(context),
    );
  }

  // Screen 3: Onboarding Exchange
  factory OnboardingScreen.exchange(BuildContext context) {
    return OnboardingScreen(
      step: 2,
      title: 'Exchange Items Hassle-Free',
      description:
          'Trade books, uniforms, and study tools directly with students from CA, CAS, CCIS, CEIT, and CTE without spending cash.',
      icon: Icons.swap_horiz_rounded,
      primaryButtonText: 'Next: Donate',
      highlights: const [
        'Zero commission or fees for exchanges',
        'Specify preferred items or college swaps',
        'Easy offer and counter-offer negotiation',
      ],
      // 3 Onboarding Exchange → 4 | Skip → 5
      onNext: () => context.go('/onboarding-donate'),
      onSkip: () => _completeOnboarding(context),
    );
  }

  // Screen 4: Onboarding Donate
  factory OnboardingScreen.donate(BuildContext context) {
    return OnboardingScreen(
      step: 3,
      title: 'Give Back and Donate',
      description:
          'Pass on reusable supplies, lab coats, and reference materials to students who need them most. Support a sustainable campus!',
      icon: Icons.volunteer_activism_rounded,
      primaryButtonText: 'Get Started',
      highlights: const [
        '100% free donations for ADSSU peers',
        'Earn campus circular economy impact points',
        'Promote zero-waste university lifestyle',
      ],
      // 4 Onboarding Donate → 5
      onNext: () => _completeOnboarding(context),
      onSkip: () => _completeOnboarding(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(3, (i) {
                      final isActive = (i + 1) == step;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 6),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primaryDarkGreen : AppColors.borderLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  if (step < 3)
                    TextButton(
                      onPressed: onSkip,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.mutedGray,
                        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Skip'),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios_rounded, size: 12),
                        ],
                      ),
                    )
                  else
                    const SizedBox(height: 36),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Column(
                  children: [
                    // Step Dots Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        final isActive = index == (step - 1);
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.primaryDarkGreen : AppColors.paleGreen,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 28),

                    // Central Illustrated Circle
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColors.paleGreen.withAlpha(160),
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Center(
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.cardWhite,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: step == 3
                                  ? AppColors.accentGold
                                  : AppColors.primaryDarkGreen.withAlpha(40),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            icon,
                            size: 58,
                            color: step == 3
                                ? AppColors.accentGold
                                : (step == 2 ? AppColors.midGreen : AppColors.primaryDarkGreen),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Title
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                    ),
                    const SizedBox(height: 12),

                    // Description
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.mutedGray,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Highlights Checklist Cards
                    Column(
                      children: highlights.map((text) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.cardWhite,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderLight),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  color: AppColors.paleGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  size: 14,
                                  color: AppColors.primaryDarkGreen,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  text,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Action Area
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: PrimaryButton(
                label: primaryButtonText,
                isAccent: step == 3,
                icon: step == 3 ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
                onPressed: onNext,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

