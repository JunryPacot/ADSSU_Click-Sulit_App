import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/campus_constants.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/primary_button.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'About Click & Sulit',
          style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                AppAssets.logo,
                height: 80,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              Text(
                CampusConstants.appTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.merriweather(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDarkGreen,
                ),
              ),
              Text(
                CampusConstants.appTagline,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentGold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                CampusConstants.appDescription,
                textAlign: TextAlign.center,
                style: GoogleFonts.carlito(fontSize: 13, color: AppColors.mutedGray, height: 1.4),
              ),
              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Version 1.0.0 (Production Release)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    SizedBox(height: 6),
                    Text('Agusan del Sur State University (ADSSU)', style: TextStyle(fontSize: 12, color: AppColors.mutedGray)),
                    Text('Digital Transformation Center (DTC)', style: TextStyle(fontSize: 12, color: AppColors.mutedGray)),
                    Text('College of Computing and Information Sciences', style: TextStyle(fontSize: 12, color: AppColors.mutedGray)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              PrimaryButton(
                label: 'View Community Rules',
                icon: Icons.gavel_rounded,
                isSecondary: true,
                onPressed: () {
                  context.pushNamed(RouteNames.communityRules);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

