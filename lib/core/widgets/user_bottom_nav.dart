import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import 'hex_category_badge.dart';

class UserBottomNav extends StatelessWidget {
  final int currentIndex;

  const UserBottomNav({
    super.key,
    required this.currentIndex,
  });

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/categories');
        break;
      case 2:
        context.push('/post/type');
        break;
      case 3:
        context.go('/messages');
        break;
      case 4:
        context.go('/profile');
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
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
              ),
              _buildNavItem(
                context,
                index: 1,
                icon: Icons.grid_view_outlined,
                activeIcon: Icons.grid_view_rounded,
                label: 'Categories',
              ),
              // Center Post Gold Hexagon Button
              Expanded(
                child: InkWell(
                  onTap: () => _onItemTapped(context, 2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.accentGold,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x3DC9A227),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipPath(
                          clipper: HexagonClipper(),
                          child: Container(
                            color: AppColors.accentGold,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.add,
                              size: 24,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Post',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildNavItem(
                context,
                index: 3,
                icon: Icons.chat_bubble_outline_rounded,
                activeIcon: Icons.chat_bubble_rounded,
                label: 'Messages',
              ),
              _buildNavItem(
                context,
                index: 4,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
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

