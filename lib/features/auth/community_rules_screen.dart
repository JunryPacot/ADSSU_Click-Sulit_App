import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class CommunityRulesScreen extends StatelessWidget {
  const CommunityRulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          // 83 Community Rules → back
          onPressed: () => context.pop(),
        ),
        title: const Text('Community Rules'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mission Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryDarkGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.eco_rounded, color: AppColors.accentGold, size: 28),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Click, Shop, Sulit!',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.cardWhite,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Our circular economy platform thrives on peer honesty, transparency, and university solidarity.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.paleGreen,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Core Guidelines',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDarkGreen,
                ),
              ),
              const SizedBox(height: 12),

              _buildRuleCard(
                number: '01',
                title: 'Exclusively for Adssunians',
                description:
                    'Only currently enrolled students, faculty, and official personnel with valid @adssu.edu.ph institutional emails may participate.',
                icon: Icons.school_rounded,
              ),
              _buildRuleCard(
                number: '02',
                title: 'Honest Condition Disclosure',
                description:
                    'Accurately declare item conditions (New, Like New, Used - Good, Fair). Specify any missing book pages, wear on uniforms, or device flaws.',
                icon: Icons.fact_check_outlined,
              ),
              _buildRuleCard(
                number: '03',
                title: 'Safe On-Campus Meet-ups Only',
                description:
                    'All physical exchanges must take place in designated campus buildings (e.g. Library, CA, CAS, CTE, CEIT, ICT, MPB) during daytime university hours.',
                icon: Icons.domain_rounded,
              ),
              _buildRuleCard(
                number: '04',
                title: 'Fair Student Pricing & Fair Swaps',
                description:
                    'Keep secondhand textbook and uniform prices accessible to peers. Exchange requests and donation transfers are strictly free of service charges.',
                icon: Icons.price_check_rounded,
              ),
              _buildRuleCard(
                number: '05',
                title: 'Zero Tolerance for Prohibited Items',
                description:
                    'Illegal substances, alcohol, weapons, hazardous materials, and leaked exam keys are strictly forbidden and will result in permanent ban and DTC disciplinary action.',
                icon: Icons.gavel_rounded,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRuleCard({
    required String number,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.paleGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDarkGreen,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 18, color: AppColors.primaryDarkGreen),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedGray,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

