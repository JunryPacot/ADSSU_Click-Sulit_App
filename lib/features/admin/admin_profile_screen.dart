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

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final admin = db.users.firstWhere(
      (u) => u.email == 'admin@adssu.edu.ph',
      orElse: () => db.currentUser,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Admin Profile',
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
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.security_rounded, size: 40, color: AppColors.primaryDarkGreen),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            admin.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.merriweather(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            admin.email,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentGold,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'DTC SUPERADMIN',
                              style: TextStyle(color: AppColors.textDark, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
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
                          ListTile(
                            leading: const Icon(Icons.dashboard_outlined, color: AppColors.primaryDarkGreen),
                            title: const Text('Admin Dashboard', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            trailing: const Icon(Icons.chevron_right, color: AppColors.mutedGray),
                            onTap: () => context.goNamed(RouteNames.adminDashboard),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.rule_rounded, color: AppColors.primaryDarkGreen),
                            title: const Text('Community Rules & Regulations', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            trailing: const Icon(Icons.chevron_right, color: AppColors.mutedGray),
                            onTap: () => context.pushNamed(RouteNames.communityRules),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.logout_rounded, color: AppColors.statusError),
                            title: const Text('Sign Out', style: TextStyle(color: AppColors.statusError, fontSize: 13, fontWeight: FontWeight.bold)),
                            trailing: const Icon(Icons.chevron_right, color: AppColors.mutedGray),
                            onTap: () => context.pushNamed(RouteNames.logoutConfirm),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 4),
    );
  }
}
