import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/type_tag.dart';
import '../../data/mock/mock_database.dart';

class ItemDetailSellScreen extends StatelessWidget {
  final String itemId;

  const ItemDetailSellScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final item = db.getItemById(itemId);

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Item Not Found')),
        body: const Center(child: Text('Item does not exist or was removed.')),
      );
    }

    final isSaved = item.isSaved;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isSaved ? Icons.favorite : Icons.favorite_border,
              color: isSaved ? AppColors.statusError : AppColors.mutedGray,
            ),
            onPressed: () => db.toggleSaveItem(item.id),
          ),
          IconButton(
            icon: const Icon(Icons.report_gmailerrorred_outlined, color: AppColors.statusError),
            tooltip: 'Report Item',
            onPressed: () {
              context.pushNamed(RouteNames.reportItem, pathParameters: {'id': item.id});
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo Area
                    GestureDetector(
                      onTap: () => context.pushNamed(
                        RouteNames.photoViewer,
                        extra: {
                          'title': item.title,
                          'imageUrl': item.imageUrl,
                          'images': item.images,
                        },
                      ),
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 220,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: AppTheme.cardShadow,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: AppImage(
                              imageSource: item.imageUrl ?? (item.images.isNotEmpty ? item.images.first : null),
                              borderRadius: 16,
                              fallbackIcon: Icons.sell_rounded,
                            ),
                          ),
                          Positioned(
                            top: 12,
                            left: 12,
                            child: TypeTag(type: item.type),
                          ),
                          if (item.isFeatured)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.accentGold,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.bolt, size: 12, color: AppColors.textDark),
                                    SizedBox(width: 4),
                                    Text(
                                      'FEATURED',
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
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.zoom_in, color: Colors.white, size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    'Tap to view',
                                    style: TextStyle(color: Colors.white, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Price & Title Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₱${item.price.toStringAsFixed(2)}',
                            style: GoogleFonts.carlito(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDarkGreen,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.title,
                            style: GoogleFonts.merriweather(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              Chip(
                                label: Text(
                                  item.category,
                                  style: const TextStyle(fontSize: 11, color: AppColors.primaryDarkGreen),
                                ),
                                backgroundColor: AppColors.paleGreen,
                                padding: EdgeInsets.zero,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              Chip(
                                label: Text(
                                  'Condition: ${item.condition}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.mutedGray),
                                ),
                                backgroundColor: AppColors.background,
                                padding: EdgeInsets.zero,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              Chip(
                                avatar: Icon(
                                  Icons.inventory_2_outlined,
                                  size: 14,
                                  color: item.quantity > 0 ? AppColors.primaryDarkGreen : AppColors.statusError,
                                ),
                                label: Text(
                                  item.quantity > 0 ? '${item.quantity} available' : 'Sold Out',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: item.quantity > 0 ? AppColors.primaryDarkGreen : AppColors.statusError,
                                  ),
                                ),
                                backgroundColor: item.quantity > 0 ? AppColors.paleGreen : AppColors.statusError.withAlpha(25),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description',
                            style: GoogleFonts.merriweather(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.description,
                            style: GoogleFonts.carlito(fontSize: 14, color: AppColors.textDark, height: 1.4),
                          ),
                          if (item.meetUpPreference != null && item.meetUpPreference!.isNotEmpty) ...[
                            const Divider(height: 24),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.place_outlined, size: 18, color: AppColors.midGreen),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Seller Preferred Meet-Up: ${item.meetUpPreference}',
                                    style: GoogleFonts.carlito(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Seller Card
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        context.pushNamed(
                          RouteNames.sellerProfile,
                          pathParameters: {'id': item.sellerId},
                          queryParameters: {'type': 'seller'},
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: Row(
                          children: [
                            ClipOval(
                              child: Container(
                                width: 48,
                                height: 48,
                                color: AppColors.primaryDarkGreen,
                                child: db.users.any((u) => u.id == item.sellerId && u.profilePhoto != null && u.profilePhoto!.isNotEmpty)
                                    ? AppImage(
                                        imageSource: db.users.firstWhere((u) => u.id == item.sellerId).profilePhoto,
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                        fallbackIcon: Icons.person_rounded,
                                      )
                                    : Center(
                                        child: Text(
                                          item.sellerName.isNotEmpty ? item.sellerName[0].toUpperCase() : 'U',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          item.sellerName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.merriweather(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.verified, size: 14, color: AppColors.midGreen),
                                    ],
                                  ),
                                  Text(
                                    item.sellerCollege,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 11, color: AppColors.mutedGray),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, size: 14, color: AppColors.accentGold),
                                      const SizedBox(width: 4),
                                      Text(
                                        item.sellerRating.toStringAsFixed(1),
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: AppColors.mutedGray),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Buttons Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.cardWhite,
                boxShadow: [
                  BoxShadow(color: AppColors.shadowTint, blurRadius: 10, offset: Offset(0, -2)),
                ],
              ),
              child: db.currentUser.id == item.sellerId
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.paleGreen,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.midGreen.withAlpha(40)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, color: AppColors.primaryDarkGreen, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'You listed this item for sale',
                            style: TextStyle(
                              color: AppColors.primaryDarkGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: PrimaryButton(
                            label: 'Message',
                            icon: Icons.chat_bubble_outline_rounded,
                            isSecondary: true,
                            onPressed: () {
                              context.pushNamed(
                                RouteNames.chat,
                                pathParameters: {'id': 'chat_${item.sellerId}'},
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: PrimaryButton(
                            label: (item.quantity > 0 && item.status == 'active') ? 'Buy Request' : 'Sold Out',
                            icon: (item.quantity > 0 && item.status == 'active')
                                ? Icons.shopping_cart_checkout_rounded
                                : Icons.remove_shopping_cart_rounded,
                            onPressed: (item.quantity > 0 && item.status == 'active')
                                ? () {
                                    context.pushNamed(
                                      RouteNames.buyRequest,
                                      pathParameters: {'id': item.id},
                                    );
                                  }
                                : null,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

