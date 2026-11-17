import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class AdminBottomNav extends StatelessWidget {
  final int currentIndex;

  const AdminBottomNav({
    super.key,
    required this.currentIndex,
  });

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;
    switch (index) {
      case 0:
        context.go('/admin/dashboard');
        break;
      case 1:
        context.go('/admin/verifications');
        break;
      case 2:
        context.go('/admin/reports');
        break;
      case 3:
        context.go('/admin/payments');
        break;
      case 4:
        context.go('/admin/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDarkGreen.withAlpha(20),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                index: 0,
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard_rounded,
                label: 'Dashboard',
              ),
              _buildNavItem(
                context,
                index: 1,
                icon: Icons.verified_user_outlined,
                activeIcon: Icons.verified_user_rounded,
                label: 'Verify',
              ),
              _buildNavItem(
                context,
                index: 2,
                icon: Icons.report_problem_outlined,
                activeIcon: Icons.report_problem_rounded,
                label: 'Reports',
              ),
              _buildNavItem(
                context,
                index: 3,
                icon: Icons.payments_outlined,
                activeIcon: Icons.payments_rounded,
                label: 'Payments',
              ),
              _buildNavItem(
                context,
                index: 4,
                icon: Icons.admin_panel_settings_outlined,
                activeIcon: Icons.admin_panel_settings_rounded,
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = index == currentIndex;
    final color = isSelected ? AppColors.primaryDarkGreen : AppColors.mutedGray;

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(context, index),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: color,
                size: 22,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

