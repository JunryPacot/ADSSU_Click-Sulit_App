import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/item_model.dart';
import '../../data/models/external_product_model.dart';
import '../../data/mock/mock_database.dart';

/// Screen 5: Saved Items Screen
/// Fulfills Task 1 (Screen Development), Task 2 (Stack Navigation),
/// and Task 2 of Lab 2 (Local Data Storage: READ & DELETE from SharedPreferences).
class SavedItemsScreen extends StatefulWidget {
  const SavedItemsScreen({super.key});

  @override
  State<SavedItemsScreen> createState() => _SavedItemsScreenState();
}

class _SavedItemsScreenState extends State<SavedItemsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final savedCampus = db.savedItems;
    final savedApi = db.savedExternalProducts;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDarkGreen,
        foregroundColor: AppColors.cardWhite,
        title: const Text(
          'Saved Items (Local Storage)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accentGold,
          indicatorWeight: 3,
          labelColor: AppColors.accentGold,
          unselectedLabelColor: AppColors.cardWhite.withValues(alpha: 0.7),
          tabs: [
            Tab(text: 'Campus Items (${savedCampus.length})'),
            Tab(text: 'External Deals (${savedApi.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Banner explaining Local Storage Persistence
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.4)),
            ),
            child: const Row(
              children: [
                Icon(Icons.storage_rounded, size: 20, color: AppColors.textDark),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'TASK 2 (PERSISTENCE): Records here are stored in SharedPreferences and remain available even after you close and reopen the app.',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textDark),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Saved Campus Items
                _buildCampusItemsList(context, savedCampus, db),
                // Tab 2: Saved External Deals
                _buildExternalDealsList(context, savedApi, db),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampusItemsList(BuildContext context, List<ItemModel> list, MockDatabase db) {
    if (list.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border_rounded, size: 54, color: AppColors.textMedium),
            SizedBox(height: 12),
            Text(
              'No saved campus items yet.',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark),
            ),
            SizedBox(height: 6),
            Text(
              'Tap the bookmark icon on any marketplace item to save it locally.',
              style: TextStyle(fontSize: 12, color: AppColors.textMedium),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            // PARAMETER PASSING: Navigates to detail and passes the item model
            onTap: () => context.push('/item-detail', extra: item),
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryDarkGreen.withValues(alpha: 0.1),
              child: const Icon(Icons.inventory_2_outlined, color: AppColors.primaryDarkGreen),
            ),
            title: Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('${item.category} • ${item.sellerCollege}', style: const TextStyle(fontSize: 11)),
                const SizedBox(height: 2),
                Text(
                  item.type == 'SELL' ? '₱${item.price.toStringAsFixed(2)}' : item.type,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDarkGreen, fontSize: 13),
                ),
              ],
            ),
            // DELETE CRUD: Removes bookmark from SharedPreferences
            trailing: IconButton(
              tooltip: 'Delete from Local Storage',
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                db.toggleSaveItem(item.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Removed "${item.title}" from local storage.')),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildExternalDealsList(BuildContext context, List<ExternalProductModel> list, MockDatabase db) {
    if (list.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.public_off_rounded, size: 54, color: AppColors.textMedium),
            SizedBox(height: 12),
            Text(
              'No saved external deals yet.',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark),
            ),
            SizedBox(height: 6),
            Text(
              'Browse External Deals and tap "Save Locally" to persist them here.',
              style: TextStyle(fontSize: 12, color: AppColors.textMedium),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final product = list[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            // PARAMETER PASSING: Navigates to deal details with product parameter
            onTap: () => context.push('/deal-detail', extra: product),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 48,
                height: 48,
                color: Colors.white,
                child: product.thumbnail.isNotEmpty
                    ? Image.network(product.thumbnail, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.shopping_bag))
                    : const Icon(Icons.shopping_bag),
              ),
            ),
            title: Text(
              product.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(product.category.toUpperCase(), style: const TextStyle(fontSize: 10, color: AppColors.textMedium)),
                const SizedBox(height: 2),
                Text(
                  '${product.formattedPricePhp} (\$${product.price.toStringAsFixed(2)})',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDarkGreen, fontSize: 12),
                ),
              ],
            ),
            // DELETE CRUD: Removes external deal from SharedPreferences
            trailing: IconButton(
              tooltip: 'Delete from Local Storage',
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                db.toggleSaveExternalProduct(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Removed "${product.title}" from local storage.')),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
