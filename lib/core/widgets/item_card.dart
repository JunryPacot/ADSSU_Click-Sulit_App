import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../data/models/item_model.dart';
import '../../data/mock/mock_database.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'app_image.dart';
import 'type_tag.dart';

class ItemCard extends StatelessWidget {
  final ItemModel item;
  final VoidCallback? onTap;

  const ItemCard({
    super.key,
    required this.item,
    this.onTap,
  });

  void _defaultNavigate(BuildContext context) {
    if (onTap != null) {
      onTap!();
      return;
    }
    // Rule: Any item card opens 24 (SELL), 25 (EXCHANGE), or 26 (DONATE)
    switch (item.type.toUpperCase()) {
      case 'SELL':
        context.push('/item/sell/${item.id}');
        break;
      case 'EXCHANGE':
        context.push('/item/exchange/${item.id}');
        break;
      case 'DONATE':
      default:
        context.push('/item/donate/${item.id}');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final isSaved = item.isSaved;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1),
        boxShadow: AppTheme.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _defaultNavigate(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Area
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1.2,
                    child: AppImage(
                      imageSource: item.imageUrl ?? (item.images.isNotEmpty ? item.images.first : null),
                      borderRadius: 0,
                      fallbackIcon: _getCategoryIcon(item.category),
                    ),
                  ),
                  // Type Tag top-left
                  Positioned(
                    top: 8,
                    left: 8,
                    child: TypeTag(type: item.type, isCompact: true),
                  ),
                  // Featured badge if boosted
                  if (item.isFeatured)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accentGold,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bolt, size: 10, color: AppColors.textDark),
                            SizedBox(width: 2),
                            Text(
                              'FEATURED',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Heart button top-right
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: Icon(
                        isSaved ? Icons.favorite : Icons.favorite_border,
                        color: isSaved ? AppColors.statusError : AppColors.mutedGray,
                        size: 20,
                      ),
                      onPressed: () {
                        db.toggleSaveItem(item.id);
                      },
                    ),
                  ),
                ],
              ),
              // Metadata Area
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.sellerCollege.replaceAll('College of ', ''),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.mutedGray,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.type == 'SELL'
                                ? '₱${item.price.toStringAsFixed(0)}'
                                : item.type == 'EXCHANGE'
                                    ? 'For Swap'
                                    : 'FREE',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: item.type == 'SELL'
                                  ? AppColors.primaryDarkGreen
                                  : item.type == 'EXCHANGE'
                                      ? AppColors.midGreen
                                      : AppColors.accentGold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.condition,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.mutedGray,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Books':
        return Icons.menu_book_rounded;
      case 'Uniforms':
        return Icons.checkroom_rounded;
      case 'Gadgets':
        return Icons.devices_rounded;
      case 'School Supplies':
        return Icons.edit_note_rounded;
      case 'Other Reusable Goods':
      default:
        return Icons.recycling_rounded;
    }
  }
}

