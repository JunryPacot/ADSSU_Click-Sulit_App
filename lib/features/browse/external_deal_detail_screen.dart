import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/external_product_model.dart';
import '../../data/mock/mock_database.dart';

/// Screen 4: External Deal Detail Screen
/// Fulfills Task 1 (Screen Development), Task 2 (Stack Navigation with Back button),
/// and Task 3 (Data Passing Between Screens - displays the exact API product passed as parameter).
class ExternalDealDetailScreen extends StatelessWidget {
  /// PARAMETER PASSING: Receives the selected ExternalProductModel from ExternalDealsScreen
  final ExternalProductModel product;

  const ExternalDealDetailScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final isSaved = db.isExternalProductSaved(product.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDarkGreen,
        foregroundColor: AppColors.cardWhite,
        title: const Text(
          'Deal Details',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip: isSaved ? 'Remove from Wishlist' : 'Save to SharedPreferences',
            icon: Icon(
              isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: isSaved ? AppColors.accentGold : AppColors.cardWhite,
            ),
            onPressed: () {
              db.toggleSaveExternalProduct(product);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isSaved
                        ? 'Removed from Saved Items'
                        : 'Saved to Local Storage (SharedPreferences)!',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Parameter Passing Info Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.midGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.midGreen.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppColors.primaryDarkGreen),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'TASK 3: Displaying API product parameters passed from External Deals.',
                      style: TextStyle(fontSize: 11, color: AppColors.primaryDarkGreen, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 220,
                width: double.infinity,
                color: Colors.white,
                child: product.thumbnail.isNotEmpty
                    ? Image.network(
                        product.thumbnail,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.textMedium),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.textMedium),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Category & Brand Badges
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDarkGreen,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    product.category.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                if (product.brand.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Text(
                      'Brand: ${product.brand}',
                      style: const TextStyle(fontSize: 10, color: AppColors.textDark, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
                const Spacer(),
                if (product.rating > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Product Title
            Text(
              product.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 12),

            // Converted Price Card (Lab Task 1)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Converted Price (₱58.00 / \$1.00 USD):', style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.formattedPricePhp,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryDarkGreen),
                      ),
                      Text(
                        '(\$${product.price.toStringAsFixed(2)} USD)',
                        style: const TextStyle(fontSize: 13, color: AppColors.textMedium),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Description Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Product Description', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: const TextStyle(fontSize: 13, color: AppColors.textDark, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Save / Bookmark Action Button (Task 2 CRUD Create/Delete)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSaved ? Colors.grey.shade700 : AppColors.primaryDarkGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: Icon(isSaved ? Icons.bookmark_remove : Icons.bookmark_add, size: 20),
                label: Text(
                  isSaved ? 'Remove from Saved (Delete from SharedPreferences)' : 'Save to Wishlist (Save to SharedPreferences)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                onPressed: () {
                  db.toggleSaveExternalProduct(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isSaved ? 'Removed from local storage' : 'Saved to local storage (SharedPreferences)!',
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
