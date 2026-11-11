import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/item_card.dart';
import '../../data/models/item_model.dart';
import '../../data/mock/mock_database.dart';

class SearchResultsScreen extends StatelessWidget {
  final String? query;
  final List<ItemModel>? initialResults;

  const SearchResultsScreen({
    super.key,
    this.query,
    this.initialResults,
  });

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();

    // Calculate results based on query if not explicitly passed
    List<ItemModel> results;
    if (initialResults != null && initialResults!.isNotEmpty) {
      // Re-fetch current state of initial results from DB
      results = initialResults!
          .map((item) => db.getItemById(item.id) ?? item)
          .where((item) => item.status == 'active' && item.quantity > 0)
          .toList();
    } else if (query != null && query!.trim().isNotEmpty) {
      final q = query!.trim().toLowerCase();
      results = db.items
          .where((i) =>
              i.status == 'active' &&
              i.quantity > 0 &&
              (i.title.toLowerCase().contains(q) ||
                  i.description.toLowerCase().contains(q) ||
                  i.category.toLowerCase().contains(q) ||
                  i.type.toLowerCase().contains(q)))
          .toList();
    } else {
      results = db.items.where((i) => i.status == 'active' && i.quantity > 0).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search Results',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (query != null && query!.isNotEmpty)
              Text(
                'for "$query"',
                style: const TextStyle(fontSize: 11, color: AppColors.mutedGray),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.primaryDarkGreen),
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter and Sort Actions (20 Search Results → 21 | 22)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              color: AppColors.background,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${results.length} found',
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

            // Results Grid
            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off_rounded, size: 54, color: AppColors.mutedGray),
                          const SizedBox(height: 12),
                          const Text(
                            'No items match your filter criteria',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.mutedGray),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context.go('/search-results'),
                            child: const Text('View All Items'),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: results.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) {
                        return ItemCard(item: results[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
