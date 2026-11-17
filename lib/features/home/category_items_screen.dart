import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/item_card.dart';
import '../../data/mock/mock_database.dart';

class CategoryItemsScreen extends StatelessWidget {
  final String categoryName;
  final IconData icon;

  const CategoryItemsScreen({
    super.key,
    required this.categoryName,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final items = db.items
        .where((i) =>
            i.category.toLowerCase() == categoryName.toLowerCase() &&
            i.status == 'active' &&
            i.quantity > 0)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: AppColors.primaryDarkGreen),
            const SizedBox(width: 8),
            Text(categoryName),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter and Sort Bar (14-18 → filter 21 | sort 22)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              color: AppColors.background,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${items.length} items',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mutedGray,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Filter Button -> 21
                  OutlinedButton.icon(
                    onPressed: () => context.push('/filter'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textDark,
                      side: const BorderSide(color: AppColors.borderLight),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.filter_list_rounded, size: 14, color: AppColors.primaryDarkGreen),
                    label: const Text('Filter', style: TextStyle(fontSize: 11)),
                  ),
                  const SizedBox(width: 6),

                  // Sort Button -> 22
                  OutlinedButton.icon(
                    onPressed: () => context.push('/sort'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textDark,
                      side: const BorderSide(color: AppColors.borderLight),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.swap_vert_rounded, size: 14, color: AppColors.primaryDarkGreen),
                    label: const Text('Sort', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ),

            // Item Grid
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(icon, size: 48, color: AppColors.mutedGray.withAlpha(120)),
                          const SizedBox(height: 12),
                          Text(
                            'No items currently listed in $categoryName',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.mutedGray,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => context.push('/post/type'),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Be the first to list!'),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: items.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) {
                        return ItemCard(item: items[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
