import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/hex_category_badge.dart';
import '../../core/widgets/item_card.dart';
import '../../core/widgets/user_bottom_nav.dart';
import '../../core/widgets/wave_header.dart';
import '../../data/mock/mock_database.dart';
import '../../data/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.promptPermissionIfNeeded(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final items = db.items;
    final featuredItems = items.where((i) => i.isFeatured && i.status == 'active' && i.quantity > 0).toList();
    final recentItems = items.where((i) => i.status == 'active' && i.quantity > 0).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top App Bar with Logo, Search, Bell, Heart
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              color: AppColors.background,
              child: Row(
                children: [
                  // Logo
                  GestureDetector(
                    onTap: () {},
                    child: Image.asset(
                      AppAssets.logo,
                      height: 38,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const Spacer(),

                  // Search Icon Button -> 19
                  IconButton(
                    icon: const Icon(Icons.search_rounded, color: AppColors.primaryDarkGreen, size: 24),
                    onPressed: () => context.push('/search'),
                    tooltip: 'Search Items',
                  ),

                  // Notification Bell -> 64
                  IconButton(
                    icon: Stack(
                      children: [
                        const Icon(Icons.notifications_none_rounded, color: AppColors.primaryDarkGreen, size: 24),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.accentGold,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () => context.push('/notifications'),
                    tooltip: 'Notifications',
                  ),

                  // Saved Items (Heart) -> 63
                  IconButton(
                    icon: const Icon(Icons.favorite_border_rounded, color: AppColors.primaryDarkGreen, size: 24),
                    onPressed: () => context.push('/saved-items'),
                    tooltip: 'Saved Items',
                  ),
                ],
              ),
            ),

            // Scrollable Body Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar Tap Action (also leads to 19)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      child: InkWell(
                        onTap: () => context.push('/search'),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                          decoration: BoxDecoration(
                            color: AppColors.cardWhite,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderLight),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.search_rounded, color: AppColors.mutedGray, size: 20),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Search textbooks, uniforms, gadgets...',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.mutedGray,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Wave Header Banner
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 120,
                          color: AppColors.primaryDarkGreen,
                          child: Stack(
                            children: [
                              const WaveHeader(height: 120),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentGold,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'CIRCULAR CAMPUS',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textDark,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'Click, Shop, Sulit!',
                                      style: TextStyle(
                                        color: AppColors.cardWhite,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Sell, exchange or donate reusable goods safely.',
                                      style: TextStyle(
                                        color: AppColors.paleGreen,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Categories Header & See All -> 13
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Categories',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go('/categories'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primaryDarkGreen,
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                            child: const Text(
                              'See all',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Hexagon Badges Row (14, 15, 16, 17, 18)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          HexCategoryBadge(
                            label: 'Books',
                            icon: Icons.menu_book_rounded,
                            onTap: () => context.push('/category/books'),
                          ),
                          const SizedBox(width: 14),
                          HexCategoryBadge(
                            label: 'Uniforms',
                            icon: Icons.checkroom_rounded,
                            onTap: () => context.push('/category/uniforms'),
                          ),
                          const SizedBox(width: 14),
                          HexCategoryBadge(
                            label: 'Gadgets',
                            icon: Icons.devices_rounded,
                            onTap: () => context.push('/category/gadgets'),
                          ),
                          const SizedBox(width: 14),
                          HexCategoryBadge(
                            label: 'Supplies',
                            icon: Icons.edit_note_rounded,
                            onTap: () => context.push('/category/supplies'),
                          ),
                          const SizedBox(width: 14),
                          HexCategoryBadge(
                            label: 'Others',
                            icon: Icons.recycling_rounded,
                            onTap: () => context.push('/category/others'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Featured Boosted Items Carousel
                    if (featuredItems.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.bolt, color: AppColors.accentGold, size: 18),
                            const SizedBox(width: 6),
                            const Text(
                              'Featured Listings',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.accentGold.withAlpha(40),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'BOOSTED',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 220,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: featuredItems.length,
                          itemBuilder: (context, index) {
                            final item = featuredItems[index];
                            return Container(
                              width: 160,
                              margin: const EdgeInsets.only(right: 12),
                              child: ItemCard(item: item),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Recent Listings Grid
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Fresh on Campus',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            '${recentItems.length} items',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.mutedGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (recentItems.isEmpty)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.storefront_outlined, size: 48, color: AppColors.mutedGray),
                            const SizedBox(height: 12),
                            const Text(
                              'No listings yet on campus',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Be the first Adssunian to post a book, uniform, gadget, or school supply!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.mutedGray,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => context.push('/post/type'),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Post First Item'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryDarkGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: recentItems.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemBuilder: (context, index) {
                            return ItemCard(item: recentItems[index]);
                          },
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const UserBottomNav(currentIndex: 0),
    );
  }
}
