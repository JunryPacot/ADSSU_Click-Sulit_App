import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/type_tag.dart';
import '../../data/mock/mock_database.dart';
import '../../data/models/item_model.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final currentUserId = db.currentUser.id;

    final allMyItems = db.items.where((i) => i.sellerId == currentUserId).toList();
    final activeItems = allMyItems.where((i) => i.status == 'active').toList();
    final reservedItems = allMyItems.where((i) => i.status == 'reserved').toList();
    final completedItems = allMyItems.where((i) => i.status == 'completed').toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          title: Text(
            'My Listings',
            style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          bottom: TabBar(
            indicatorColor: AppColors.primaryDarkGreen,
            labelColor: AppColors.primaryDarkGreen,
            unselectedLabelColor: AppColors.mutedGray,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            tabs: [
              Tab(text: 'Active (${activeItems.length})'),
              Tab(text: 'Reserved (${reservedItems.length})'),
              Tab(text: 'Completed (${completedItems.length})'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildListingsList(context, db, activeItems, isActive: true),
            _buildListingsList(context, db, reservedItems, isReserved: true),
            _buildListingsList(context, db, completedItems, isCompleted: true),
          ],
        ),
      ),
    );
  }

  Widget _buildListingsList(
    BuildContext context,
    MockDatabase db,
    List<ItemModel> items, {
    bool isActive = false,
    bool isReserved = false,
    bool isCompleted = false,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.mutedGray),
            const SizedBox(height: 12),
            const Text('No listings in this tab', style: TextStyle(color: AppColors.mutedGray)),
            if (isActive) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDarkGreen,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => context.pushNamed(RouteNames.postChooseType),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Post an Item'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  if (item.type == 'SELL') {
                    context.pushNamed(RouteNames.itemDetailSell, pathParameters: {'id': item.id});
                  } else if (item.type == 'EXCHANGE') {
                    context.pushNamed(RouteNames.itemDetailExchange, pathParameters: {'id': item.id});
                  } else {
                    context.pushNamed(RouteNames.itemDetailDonate, pathParameters: {'id': item.id});
                  }
                },
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AppImage(
                        imageSource: item.imageUrl ?? (item.images.isNotEmpty ? item.images.first : null),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TypeTag(type: item.type, isCompact: true),
                              if (item.isFeatured)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentGold,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'BOOSTED',
                                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.textDark),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            item.type == 'SELL'
                                ? '₱${item.price.toStringAsFixed(2)}'
                                : item.type == 'EXCHANGE'
                                    ? 'For Trade'
                                    : 'Free Donation',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: item.type == 'SELL' ? AppColors.primaryDarkGreen : AppColors.midGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (isActive || isReserved) ...[
                const Divider(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        context.pushNamed(RouteNames.editListing, pathParameters: {'id': item.id});
                      },
                      icon: const Icon(Icons.edit, size: 14, color: AppColors.primaryDarkGreen),
                      label: const Text('Edit', style: TextStyle(fontSize: 11, color: AppColors.primaryDarkGreen)),
                    ),
                    if (isActive && !item.isFeatured)
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          context.pushNamed(RouteNames.featuredBoostPlans);
                        },
                        icon: const Icon(Icons.bolt, size: 14, color: AppColors.accentGold),
                        label: const Text('Boost', style: TextStyle(fontSize: 11, color: AppColors.textDark)),
                      ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        context.pushNamed(RouteNames.markAsDone, pathParameters: {'id': item.id});
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 14, color: AppColors.midGreen),
                      label: const Text('Mark Done', style: TextStyle(fontSize: 11, color: AppColors.midGreen)),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        context.pushNamed(RouteNames.deleteListing, pathParameters: {'id': item.id});
                      },
                      icon: const Icon(Icons.delete_outline, size: 14, color: AppColors.statusError),
                      label: const Text('Delete', style: TextStyle(fontSize: 11, color: AppColors.statusError)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

