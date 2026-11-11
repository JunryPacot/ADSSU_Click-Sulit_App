import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';

class MembershipPendingScreen extends StatelessWidget {
  const MembershipPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: AppColors.paleGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  size: 50,
                  color: AppColors.midGreen,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Payment Submitted!',
                textAlign: TextAlign.center,
                style: GoogleFonts.merriweather(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your ₱50 seller membership payment has been submitted and is currently pending verification by the ADSSU Administrator.',
                textAlign: TextAlign.center,
                style: GoogleFonts.carlito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, size: 16, color: AppColors.midGreen),
                        SizedBox(width: 6),
                        Text(
                          'One-Time Fee Verification',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDarkGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Once an admin verifies your GCash reference, your seller badge will be activated permanently, allowing you to post unlimited items for sale.\n\nIn the meantime, you can post unlimited Exchange and Donation listings completely free!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.carlito(
                        fontSize: 12,
                        color: AppColors.mutedGray,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Back to Home',
                icon: Icons.home_rounded,
                onPressed: () {
                  context.go('/home');
                },
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Post Free Exchange or Donate',
                isSecondary: true,
                icon: Icons.swap_horiz_rounded,
                onPressed: () {
                  context.goNamed(RouteNames.postChooseType);
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
