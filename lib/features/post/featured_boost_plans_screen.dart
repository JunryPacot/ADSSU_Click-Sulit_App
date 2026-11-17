import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/campus_constants.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/primary_button.dart';

class FeaturedBoostPlansScreen extends StatefulWidget {
  final Map<String, dynamic>? extraData;

  const FeaturedBoostPlansScreen({super.key, this.extraData});

  @override
  State<FeaturedBoostPlansScreen> createState() => _FeaturedBoostPlansScreenState();
}

class _FeaturedBoostPlansScreenState extends State<FeaturedBoostPlansScreen> {
  int _selectedPlanIndex = 1; // Default to 3 days (₱25)

  @override
  Widget build(BuildContext context) {
    final plans = CampusConstants.boostPlans;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Featured Boost Plans',
          style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Highlight Your Listing',
                style: GoogleFonts.merriweather(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 6),
              Text(
                'Featured items appear at the top of the campus feed with a gold badge for maximum student reach.',
                style: GoogleFonts.carlito(fontSize: 13, color: AppColors.mutedGray),
              ),
              const SizedBox(height: 24),

              // Plans List
              Column(
                children: List.generate(plans.length, (index) {
                  final plan = plans[index];
                  final isSelected = _selectedPlanIndex == index;

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => setState(() => _selectedPlanIndex = index),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.lightMint : AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.accentGold : AppColors.borderLight,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                            color: isSelected ? AppColors.accentGold : AppColors.mutedGray,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  plan.name,
                                  style: GoogleFonts.merriweather(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Active for ${plan.durationDays} day(s)',
                                  style: const TextStyle(fontSize: 11, color: AppColors.mutedGray),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₱${plan.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDarkGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              const Spacer(),

              PrimaryButton(
                label: 'Continue to Payment',
                icon: Icons.arrow_forward_rounded,
                isAccent: true,
                onPressed: () {
                  final chosenPlan = plans[_selectedPlanIndex];
                  context.pushNamed(
                    RouteNames.boostPayment,
                    extra: {
                      'planName': chosenPlan.name,
                      'planPrice': chosenPlan.price,
                      'planDays': chosenPlan.durationDays,
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

