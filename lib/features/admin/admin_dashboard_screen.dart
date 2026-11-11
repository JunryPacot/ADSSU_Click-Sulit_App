import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/admin_bottom_nav.dart';
import '../../core/widgets/wave_header.dart';
import '../../data/mock/mock_database.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final pendingVerifications = db.users.where((u) => !u.isVerified).length;
    final pendingReports = db.reports.where((r) => r.status == 'pending').length;
    final pendingPayments = db.payments.where((p) => p.status == 'pending').length;
    final totalListings = db.items.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Admin Portal',
          style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            WaveHeader(
              height: 180,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.admin_panel_settings_rounded, color: AppColors.accentGold, size: 28),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Campus Moderation',
                            style: GoogleFonts.merriweather(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'ADSSU DTC Operations & Platform Governance',
                      style: GoogleFonts.carlito(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Operational Hub',
                    style: GoogleFonts.merriweather(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 12),

                  // 2x2 Grid of Actions
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionTile(
                          context,
                          title: 'Verifications',
                          count: '$pendingVerifications',
                          icon: Icons.how_to_reg_outlined,
                          color: AppColors.primaryDarkGreen,
                          onTap: () => context.pushNamed(RouteNames.adminVerifications),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionTile(
                          context,
                          title: 'Item Reports',
                          count: '$pendingReports',
                          icon: Icons.report_problem_outlined,
                          color: AppColors.statusError,
                          onTap: () => context.pushNamed(RouteNames.adminReports),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionTile(
                          context,
                          title: 'Payments',
                          count: '$pendingPayments',
                          icon: Icons.payments_outlined,
                          color: AppColors.accentGold,
                          onTap: () => context.pushNamed(RouteNames.paymentsReview),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionTile(
                          context,
                          title: 'Listings',
                          count: '$totalListings',
                          icon: Icons.inventory_2_outlined,
                          color: AppColors.midGreen,
                          onTap: () => context.pushNamed(RouteNames.manageListings),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Impact Stats Tile (Screen 81)
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => context.pushNamed(RouteNames.impactStats),
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
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: AppColors.paleGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.analytics_outlined, color: AppColors.primaryDarkGreen, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Campus Impact Analytics',
                                  style: GoogleFonts.merriweather(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                const Text(
                                  'Metrics on student circular economy reuse and savings.',
                                  style: TextStyle(fontSize: 11, color: AppColors.mutedGray),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.mutedGray),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 0),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String title,
    required String count,
    required IconData icon,
    required Color color,
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Text(
                  count,
                  style: GoogleFonts.carlito(fontSize: 22, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.merriweather(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
          ],
        ),
      ),
    );
  }
}

