import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';

class ReportSentScreen extends StatelessWidget {
  const ReportSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                  Icons.check_circle_rounded,
                  size: 54,
                  color: AppColors.midGreen,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Report Submitted',
                textAlign: TextAlign.center,
                style: GoogleFonts.merriweather(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Thank you for keeping ADSSU Click & Sulit safe. Our admin team will inspect this listing and take appropriate action.',
                textAlign: TextAlign.center,
                style: GoogleFonts.carlito(
                  fontSize: 14,
                  color: AppColors.mutedGray,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Back to Home',
                icon: Icons.home_rounded,
                onPressed: () {
                  context.goNamed(RouteNames.home);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

