import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/primary_button.dart';

class AccountSubmittedScreen extends StatelessWidget {
  const AccountSubmittedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Celebration Badge
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.paleGreen,
                    shape: BoxShape.circle,
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.celebration_rounded,
                      size: 52,
                      color: AppColors.primaryDarkGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Account Activated!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                const Text(
                  'Welcome to the ADSSU Peer-to-Peer Hub',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDarkGreen,
                  ),
                ),
                const SizedBox(height: 24),

                // Card with guidelines
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    children: [
                      _buildCheckRow(
                        'Verified ADSSU Student Account',
                        'You can now browse listings, make exchange offers, and request donations.',
                      ),
                      const Divider(color: AppColors.borderLight, height: 24),
                      _buildCheckRow(
                        'Selling Secondhand Items',
                        'To post paid sales, activate your one-time ₱50 student seller membership.',
                      ),
                      const Divider(color: AppColors.borderLight, height: 24),
                      _buildCheckRow(
                        'Campus Safety Guarantee',
                        'Always meet at designated campus buildings during official university hours.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // 11 Account Submitted → 12
                PrimaryButton(
                  label: 'Start Exploring (Go to Home)',
                  icon: Icons.storefront_rounded,
                  onPressed: () {
                    SharedPreferences.getInstance().then((p) => p.setBool('has_seen_onboarding', true)).catchError((_) => false);
                    context.go('/home');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckRow(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.paleGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 16,
            color: AppColors.primaryDarkGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.mutedGray,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

