import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';

class BoostPendingScreen extends StatelessWidget {
  const BoostPendingScreen({super.key});

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
                  Icons.bolt_rounded,
                  size: 56,
                  color: AppColors.accentGold,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Boost Activated!',
                textAlign: TextAlign.center,
                style: GoogleFonts.merriweather(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your featured boost payment has been logged. Your item now shines on top of the campus feed for all students!',
                textAlign: TextAlign.center,
                style: GoogleFonts.carlito(
                  fontSize: 14,
                  color: AppColors.mutedGray,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'View in My Listings',
                icon: Icons.list_alt_rounded,
                onPressed: () {
                  context.goNamed(RouteNames.myListings);
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

