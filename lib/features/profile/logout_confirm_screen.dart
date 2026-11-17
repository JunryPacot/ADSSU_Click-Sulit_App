import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/mock/mock_database.dart';

class LogoutConfirmScreen extends StatelessWidget {
  const LogoutConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Logout',
          style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.statusError.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded, color: AppColors.statusError, size: 48),
              ),
              const SizedBox(height: 24),
              Text(
                'Sign Out of Your Account?',
                style: GoogleFonts.merriweather(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 12),
              Text(
                'You will need to enter your institutional @adssu.edu.ph email credentials again to sign in.',
                textAlign: TextAlign.center,
                style: GoogleFonts.carlito(fontSize: 14, color: AppColors.mutedGray),
              ),
              const Spacer(),

              PrimaryButton(
                label: 'Logout',
                icon: Icons.logout_rounded,
                onPressed: () {
                  db.logout();
                  context.goNamed(RouteNames.login);
                },
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Cancel',
                isSecondary: true,
                onPressed: () {
                  context.pop();
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

