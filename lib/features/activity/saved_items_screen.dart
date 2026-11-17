import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/item_card.dart';
import '../../data/mock/mock_database.dart';
import '../../data/models/external_product_model.dart';

/// Screen displaying items saved in local storage (Wishlist).
/// Fulfills Laboratory Exercise 4 Task 2 & Task 3:
/// - Retrieve saved records from device storage (READ)
/// - Delete saved records on request (DELETE)
class SavedItemsScreen extends StatelessWidget {
  const SavedItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final savedCampusItems = db.items.where((i) => i.isSaved).toList();
    final savedExternal = db.savedExternalProducts;
    final totalCount = savedCampusItems.length + savedExternal.length;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'Saved Items ($totalCount)',
            style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          bottom: TabBar(
            indicatorColor: AppColors.primaryDarkGreen,
            labelColor: AppColors.primaryDarkGreen,
            unselectedLabelColor: AppColors.mutedGray,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: [
              Tab(
                text: 'Campus Items (${savedCampusItems.length})',
                icon: const Icon(Icons.school_rounded, size: 18),
              ),
              Tab(
                text: 'External Deals (${savedExternal.length})',
                icon: const Icon(Icons.public_rounded, size: 18),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              // Tab 1: Campus Marketplace Saved Items
              _buildCampusTab(context, db, savedCampusItems),

              // Tab 2: External REST API Products Saved in Local Storage
              _buildExternalTab(context, db, savedExternal),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCampusTab(BuildContext context, MockDatabase db, List items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border_rounded, size: 54, color: AppColors.mutedGray),
            const SizedBox(height: 12),
            const Text(
              'No saved campus items yet.',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap the heart icon on any campus listing to bookmark it.',
              style: TextStyle(fontSize: 12, color: AppColors.mutedGray),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDarkGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () => context.go('/home'),
              child: const Text('Browse Campus Items'),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ItemCard(item: items[index]);
      },
    );
  }

  Widget _buildExternalTab(
    BuildContext context,
    MockDatabase db,
    List<ExternalProductModel> products,
  ) {
    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bookmark_border_rounded, size: 54, color: AppColors.mutedGray),
              const SizedBox(height: 12),
              const Text(
                'No saved external API deals.',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 6),
              const Text(
                'Browse items retrieved from the external REST API and tap "Save Locally" to persist them to local device storage.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.mutedGray),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDarkGreen,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => context.push('/external-deals'),
                icon: const Icon(Icons.public_rounded, size: 18),
                label: const Text('Browse External API Deals'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final product = products[index];

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: product.thumbnail.isNotEmpty
                      ? Image.network(
                          product.thumbnail,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.paleGreen,
                            child: const Icon(Icons.image_not_supported_rounded, color: AppColors.mutedGray),
                          ),
                        )
                      : Container(
                          color: AppColors.paleGreen,
                          child: const Icon(Icons.shopping_bag_rounded, color: AppColors.primaryDarkGreen),
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Title, Category & Price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.paleGreen,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.category.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDarkGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          product.formattedPricePhp,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDarkGreen,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(\$${product.price.toStringAsFixed(0)})',
                          style: const TextStyle(fontSize: 10, color: AppColors.mutedGray),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Delete button (DELETE CRUD from local storage)
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.statusError),
                tooltip: 'Remove from Local Storage',
                onPressed: () async {
                  await db.deleteExternalProduct(product.id);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Removed "${product.title}" from local storage.'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
