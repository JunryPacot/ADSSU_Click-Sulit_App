import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/item_model.dart';
import '../../data/mock/mock_database.dart';

/// Screen 2: Item Detail Screen
/// Fulfills Task 1 (Screen Development), Task 2 (Stack Navigation with Back button),
/// and Task 3 (Data Passing Between Screens - displays the exact item passed as parameter).
class ItemDetailScreen extends StatelessWidget {
  /// PARAMETER PASSING: Receives the selected ItemModel from the previous screen.
  final ItemModel item;

  const ItemDetailScreen({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    // Look up latest state of item from database to reflect any edits or save toggles
    final currentItem = db.getItemById(item.id) ?? item;
    final isMyListing = currentItem.sellerId == db.currentUser.id;

    Color typeColor;
    if (currentItem.type == 'SELL') {
      typeColor = AppColors.primaryDarkGreen;
    } else if (currentItem.type == 'EXCHANGE') {
      typeColor = Colors.orange.shade800;
    } else {
      typeColor = Colors.blue.shade700;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDarkGreen,
        foregroundColor: AppColors.cardWhite,
        title: const Text(
          'Item Details',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip: currentItem.isSaved ? 'Remove from Wishlist' : 'Save to Wishlist',
            icon: Icon(
              currentItem.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: currentItem.isSaved ? AppColors.accentGold : AppColors.cardWhite,
            ),
            onPressed: () {
              db.toggleSaveItem(currentItem.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    currentItem.isSaved
                        ? 'Removed from Wishlist'
                        : 'Saved to Wishlist!',
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
            // Item Title
            Text(
              currentItem.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            // Type, Category, and Condition Badges
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    currentItem.type,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.midGreen.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    currentItem.category,
                    style: const TextStyle(color: AppColors.textDark, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.midGreen.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    'Condition: ${currentItem.condition}',
                    style: const TextStyle(color: AppColors.textDark, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Price Card
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Listing Price:', style: TextStyle(fontSize: 14, color: AppColors.textMedium)),
                  Text(
                    currentItem.type == 'SELL'
                        ? '₱${currentItem.price.toStringAsFixed(2)}'
                        : (currentItem.type == 'DONATE' ? 'FREE (Donation)' : 'FOR EXCHANGE'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: currentItem.type == 'DONATE' ? Colors.blue.shade700 : AppColors.primaryDarkGreen,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Exchange preference if applicable
            if (currentItem.type == 'EXCHANGE' && currentItem.exchangeFor != null && currentItem.exchangeFor!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Preferred Exchange Item:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange.shade900)),
                    const SizedBox(height: 4),
                    Text(currentItem.exchangeFor!, style: const TextStyle(fontSize: 13, color: AppColors.textDark)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Item Description Card
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
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentItem.description,
                    style: const TextStyle(fontSize: 13, color: AppColors.textDark, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Seller Card
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
                  const Text('Seller Information', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.primaryDarkGreen,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(currentItem.sellerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(currentItem.sellerCollege, style: const TextStyle(fontSize: 12, color: AppColors.textMedium)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accentGold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 3),
                            Text('${currentItem.sellerRating}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            if (isMyListing) ...[
              // Edit Listing (Task 2 Update CRUD)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDarkGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit Listing (CRUD Update)', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    // Passes the item model to the edit screen
                    context.push('/edit-item', extra: currentItem);
                  },
                ),
              ),
              const SizedBox(height: 10),
              // Delete Listing (Task 2 Delete CRUD)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(color: Colors.red.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Delete Listing (CRUD Delete)', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Listing?'),
                        content: Text('Are you sure you want to delete "${currentItem.title}" from local storage?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await db.deleteItem(currentItem.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Item deleted from SharedPreferences.')),
                        );
                        context.pop();
                      }
                    }
                  },
                ),
              ),
            ] else ...[
              // Student Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGold,
                    foregroundColor: AppColors.textDark,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: Text(
                    currentItem.type == 'SELL' ? 'Request to Buy at Campus' : (currentItem.type == 'EXCHANGE' ? 'Propose Campus Exchange' : 'Request Donation'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Meet-up request sent to ${currentItem.sellerName} (${currentItem.sellerCollege})!'),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
