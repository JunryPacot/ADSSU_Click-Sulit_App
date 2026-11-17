import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/primary_button.dart';

class LoginErrorScreen extends StatelessWidget {
  const LoginErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/login'),
        ),
        title: const Text('Authentication Error'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              // Warning Error Badge
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: AppColors.statusError.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: AppColors.statusError,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_person_rounded,
                      size: 32,
                      color: AppColors.cardWhite,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Access Restricted',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'AUTHENTICATION REFUSED',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: AppColors.statusError,
                ),
              ),
              const SizedBox(height: 24),

              // Prominent Requirement Warning Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.statusError.withAlpha(15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.statusError.withAlpha(60)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.domain_disabled_rounded, color: AppColors.statusError, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ADSSU Email Required',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.statusError,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Only official institutional accounts ending in @adssu.edu.ph are permitted to access this circular exchange platform.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textDark,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Explanation Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Why are personal emails blocked?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'To ensure safety, prevent off-campus scams, and foster community trust, ADSSU Click & Sulit is strictly restricted to currently enrolled students, faculty, and university personnel.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mutedGray,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 7 Login Error → Try Again 5 | Contact ADSSU DTC 6
              PrimaryButton(
                label: 'Try Again',
                icon: Icons.refresh_rounded,
                onPressed: () => context.go('/login'),
              ),
              const SizedBox(height: 12),

              PrimaryButton(
                label: 'Contact ADSSU DTC',
                isSecondary: true,
                icon: Icons.support_agent_rounded,
                onPressed: () => context.push('/forgot-password'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

