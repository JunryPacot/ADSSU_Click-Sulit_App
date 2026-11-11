import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/campus_constants.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/mock/mock_database.dart';

class MembershipRequiredScreen extends StatelessWidget {
  const MembershipRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final isAlreadyMember = db.currentUser.isSellerMember;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Seller Membership',
          style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.paleGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isAlreadyMember ? Icons.verified_user_rounded : Icons.workspace_premium_rounded,
                  size: 48,
                  color: isAlreadyMember ? AppColors.statusSuccess : AppColors.accentGold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isAlreadyMember ? 'Seller Membership Active' : 'Seller Membership Required',
                textAlign: TextAlign.center,
                style: GoogleFonts.merriweather(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 10),
              Text(
                isAlreadyMember
                    ? 'Your one-time ₱50 seller membership is active! You can post unlimited items for sale without ever paying this fee again.'
                    : 'To maintain a trusted and accountable community, selling items for cash requires a one-time ₱50 membership verification.',
                textAlign: TextAlign.center,
                style: GoogleFonts.carlito(fontSize: 14, color: AppColors.mutedGray, height: 1.4),
              ),
              const SizedBox(height: 24),

              // Benefits Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  children: [
                    _buildBenefitRow(Icons.verified_user_rounded, 'Verified Student Seller Badge'),
                    const SizedBox(height: 12),
                    _buildBenefitRow(Icons.storefront_rounded, 'Post Unlimited Cash Listings'),
                    const SizedBox(height: 12),
                    _buildBenefitRow(Icons.support_agent_rounded, 'Priority Support & Dispute Protection'),
                  ],
                ),
              ),
              const Spacer(),

              if (isAlreadyMember) ...[
                PrimaryButton(
                  label: 'Post Item for Sale',
                  icon: Icons.add_circle_outline_rounded,
                  onPressed: () {
                    context.pushNamed(RouteNames.addPhotos, extra: {'type': CampusConstants.typeSell});
                  },
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Back to Choose Type',
                  isSecondary: true,
                  onPressed: () {
                    context.goNamed(RouteNames.postChooseType);
                  },
                ),
              ] else ...[
                PrimaryButton(
                  label: 'Pay ₱50 Membership Fee',
                  icon: Icons.payment_rounded,
                  isAccent: true,
                  onPressed: () {
                    context.pushNamed(RouteNames.membershipPayment);
                  },
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Not Now',
                  isSecondary: true,
                  onPressed: () {
                    context.goNamed(RouteNames.postChooseType);
                  },
                ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.midGreen, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark),
          ),
        ),
      ],
    );
  }
}


