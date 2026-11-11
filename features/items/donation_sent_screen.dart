import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';

class DonationSentScreen extends StatelessWidget {
  final Map<String, dynamic>? extraData;

  const DonationSentScreen({super.key, this.extraData});

  @override
  Widget build(BuildContext context) {
    final itemTitle = extraData?['itemTitle'] ?? 'the item';
    final sellerId = extraData?['sellerId'] ?? 'donor';

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
                  Icons.volunteer_activism_rounded,
                  size: 50,
                  color: AppColors.midGreen,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Donation Request Sent!',
                textAlign: TextAlign.center,
                style: GoogleFonts.merriweather(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your request for "$itemTitle" has been sent to the donor. They will receive your proposed meet-up spot and message.',
                textAlign: TextAlign.center,
                style: GoogleFonts.carlito(
                  fontSize: 14,
                  color: AppColors.mutedGray,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Open Chat',
                icon: Icons.chat_bubble_outline_rounded,
                onPressed: () {
                  context.pushNamed(
                    RouteNames.chat,
                    pathParameters: {'id': 'chat_$sellerId'},
                  );
                },
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Back to Home',
                icon: Icons.home_rounded,
                isSecondary: true,
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

