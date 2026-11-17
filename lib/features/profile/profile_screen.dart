import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/user_bottom_nav.dart';
import '../../core/widgets/wave_header.dart';
import '../../data/mock/mock_database.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final user = db.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with Avatar and Basic Info
            WaveHeader(
              height: 180,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    ClipOval(
                      child: Container(
                        width: 72,
                        height: 72,
                        color: Colors.white,
                        child: user.profilePhoto != null && user.profilePhoto!.isNotEmpty
                            ? AppImage(
                                imageSource: user.profilePhoto,
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                                fallbackIcon: Icons.person,
                              )
                            : Center(
                                child: Text(
                                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                  style: const TextStyle(
                                    color: AppColors.primaryDarkGreen,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  user.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.merriweather(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (user.isVerified) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.verified, color: AppColors.accentGold, size: 16),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                          Text(
                            user.college,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white60, fontSize: 10),
                          ),
                          if (user.isSellerMember) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.accentGold,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'SELLER MEMBER',
                                style: TextStyle(color: AppColors.textDark, fontSize: 8, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Menu Items Card
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Material(
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          _buildTile(Icons.edit_outlined, 'Edit Profile', () => context.pushNamed(RouteNames.editProfile)),
                          _buildDivider(),
                          _buildTile(Icons.list_alt_rounded, 'My Listings', () => context.pushNamed(RouteNames.myListings)),
                          _buildDivider(),
                          _buildTile(Icons.favorite_outline_rounded, 'Saved Items', () => context.pushNamed(RouteNames.savedItems)),
                          _buildDivider(),
                          _buildTile(Icons.receipt_long_outlined, 'Transaction History', () => context.pushNamed(RouteNames.transactionHistory)),
                          _buildDivider(),
                          _buildTile(Icons.star_outline_rounded, 'My Reviews', () => context.pushNamed(RouteNames.myReviews)),
                          _buildDivider(),
                          _buildTile(Icons.eco_outlined, 'My Circular Impact', () => context.pushNamed(RouteNames.myImpact)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Settings & Info Card
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Material(
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          _buildTile(Icons.settings_outlined, 'Settings', () => context.pushNamed(RouteNames.settings)),
                          _buildDivider(),
                          _buildTile(Icons.help_outline_rounded, 'Help and FAQ', () => context.pushNamed(RouteNames.helpFaq)),
                          _buildDivider(),
                          _buildTile(Icons.info_outline_rounded, 'About Click & Sulit', () => context.pushNamed(RouteNames.about)),
                          _buildDivider(),
                          _buildTile(
                            Icons.logout_rounded,
                            'Logout',
                            () => context.pushNamed(RouteNames.logoutConfirm),
                            color: AppColors.statusError,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const UserBottomNav(currentIndex: 4),
    );
  }

  Widget _buildTile(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primaryDarkGreen, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color ?? AppColors.textDark,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.mutedGray),
      onTap: onTap,
    );
  }

  Widget _buildDivider() => const Divider(height: 1, indent: 56, endIndent: 16);
}
