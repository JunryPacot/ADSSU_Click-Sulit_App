import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/campus_constants.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock/mock_database.dart';

class PostChooseTypeScreen extends StatelessWidget {
  const PostChooseTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final isSellerMember = db.currentUser.isSellerMember;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Post an Item',
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
                'What would you like to do?',
                style: GoogleFonts.merriweather(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              Text(
                'Select the transaction model for your item. Exchange and donations are 100% free.',
                style: GoogleFonts.carlito(fontSize: 14, color: AppColors.mutedGray),
              ),
              const SizedBox(height: 24),

              // Option 1: SELL
              _buildTypeCard(
                context,
                title: 'SELL',
                subtitle: 'Sell pre-loved books, uniforms, or gadgets for cash.',
                badge: isSellerMember ? 'MEMBER ACTIVATED' : '₱50 MEMBERSHIP',
                badgeColor: isSellerMember ? AppColors.statusSuccess : AppColors.accentGold,
                icon: Icons.sell_rounded,
                iconBg: AppColors.primaryDarkGreen,
                onTap: () {
                  if (isSellerMember) {
                    context.pushNamed(RouteNames.addPhotos, extra: {'type': CampusConstants.typeSell});
                  } else {
                    context.pushNamed(RouteNames.membershipRequired);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Option 2: EXCHANGE
              _buildTypeCard(
                context,
                title: 'EXCHANGE',
                subtitle: 'Trade goods with peers without exchanging money.',
                badge: 'FREE FOREVER',
                badgeColor: AppColors.midGreen,
                icon: Icons.swap_horiz_rounded,
                iconBg: AppColors.midGreen,
                onTap: () {
                  context.pushNamed(RouteNames.addPhotos, extra: {'type': CampusConstants.typeExchange});
                },
              ),
              const SizedBox(height: 16),

              // Option 3: DONATE
              _buildTypeCard(
                context,
                title: 'DONATE',
                subtitle: 'Give away items to fellow students who need them most.',
                badge: 'CIRCULAR IMPACT',
                badgeColor: AppColors.accentGold,
                icon: Icons.volunteer_activism_rounded,
                iconBg: AppColors.accentGold,
                onTap: () {
                  context.pushNamed(RouteNames.addPhotos, extra: {'type': CampusConstants.typeDonate});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required IconData icon,
    required Color iconBg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow,
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.merriweather(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(color: badgeColor, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.carlito(fontSize: 12, color: AppColors.mutedGray),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.mutedGray),
          ],
        ),
      ),
    );
  }
}

