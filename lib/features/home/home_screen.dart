import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/campus_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/item_model.dart';
import '../../data/mock/mock_database.dart';

/// Screen 1: Campus Marketplace (Home Screen)
/// Fulfills Task 1 (Screen Development), Task 2 (Navigation), & Task 3 (Data Passing).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Books',
    'Uniforms',
    'Gadgets',
    'School Supplies',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();

    // Filter items based on selected category and search query
    final filteredItems = db.items.where((item) {
      final matchesCategory = _selectedCategory == 'All' || item.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDarkGreen,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.accentGold,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.storefront_rounded, color: AppColors.textDark, size: 20),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    CampusConstants.appTitle,
                    style: TextStyle(
                      color: AppColors.cardWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Campus Peer-to-Peer Exchange',
                    style: TextStyle(
                      color: AppColors.accentGold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Saved Items',
            icon: Badge(
              label: Text('${db.savedItems.length + db.savedExternalProducts.length}'),
              child: const Icon(Icons.bookmark_rounded, color: AppColors.cardWhite),
            ),
            onPressed: () => context.push('/saved'),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Banner for Campus Partner Deals
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDarkGreen, AppColors.midGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDarkGreen.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.accentGold,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'PARTNER ESSENTIALS',
                            style: TextStyle(
                              color: AppColors.textDark,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'External Student Deals',
                          style: TextStyle(
                            color: AppColors.cardWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Special supplies & discounts for ADSSU community',
                          style: TextStyle(
                            color: AppColors.paleGreen,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGold,
                      foregroundColor: AppColors.textDark,
                      minimumSize: const Size(80, 36),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    icon: const Icon(Icons.public, size: 16),
                    label: const Text('Browse', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: () => context.push('/external-deals'),
                  ),
                ],
              ),
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search textbooks, uniforms, gadgets...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.midGreen),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.cardWhite,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.midGreen.withValues(alpha: 0.2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.midGreen.withValues(alpha: 0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.midGreen, width: 1.5),
                  ),
                ),
              ),
            ),
          ),

          // Category Chips
          SliverToBoxAdapter(
            child: SizedBox(
              height: 52,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = cat == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: AppColors.primaryDarkGreen,
                      backgroundColor: AppColors.cardWhite,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.cardWhite : AppColors.textDark,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 12,
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedCategory = cat);
                      },
                    ),
                  );
                },
              ),
            ),
          ),

          // Section Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Campus Listings (${filteredItems.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    'Tap card for details',
                    style: TextStyle(fontSize: 11, color: AppColors.textMedium),
                  ),
                ],
              ),
            ),
          ),

          // Items List
          if (filteredItems.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textMedium),
                    SizedBox(height: 12),
                    Text(
                      'No campus items found',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Try adjusting your search or category filter.',
                      style: TextStyle(fontSize: 12, color: AppColors.textMedium),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = filteredItems[index];
                    return _buildMarketplaceCard(context, item, db);
                  },
                  childCount: filteredItems.length,
                ),
              ),
            ),
        ],
      ),

      // Floating Action Button: Post new item (Task 2 Create)
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accentGold,
        foregroundColor: AppColors.textDark,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text('Post Item', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => context.push('/add-item'),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: AppColors.cardWhite,
        selectedItemColor: AppColors.primaryDarkGreen,
        unselectedItemColor: AppColors.textMedium,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        onTap: (index) {
          if (index == 1) context.push('/external-deals');
          if (index == 2) context.push('/saved');
          if (index == 3) context.push('/profile');
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_rounded),
            label: 'Marketplace',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.public_rounded),
            label: 'External Deals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_rounded),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  /// Campus marketplace item card
  /// Demonstrates Task 3: Parameter Passing when tapped!
  Widget _buildMarketplaceCard(BuildContext context, ItemModel item, MockDatabase db) {
    Color typeColor;
    if (item.type == 'SELL') {
      typeColor = AppColors.primaryDarkGreen;
    } else if (item.type == 'EXCHANGE') {
      typeColor = Colors.orange.shade800;
    } else {
      typeColor = Colors.blue.shade700;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        // PARAMETER PASSING: Passes the selected ItemModel to the detail screen!
        onTap: () {
          context.push('/item-detail', extra: item);
        },
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item Icon Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDarkGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getCategoryIcon(item.category),
                      color: AppColors.primaryDarkGreen,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Item Title & Tags
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: typeColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item.type,
                                style: TextStyle(
                                  color: typeColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.midGreen.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                item.category,
                                style: const TextStyle(fontSize: 10, color: AppColors.textDark),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              item.condition,
                              style: TextStyle(fontSize: 11, color: AppColors.textMedium),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Bookmark heart button (SharedPreferences Create/Delete)
                  IconButton(
                    icon: Icon(
                      item.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: item.isSaved ? AppColors.accentGold : AppColors.textMedium,
                    ),
                    onPressed: () => db.toggleSaveItem(item.id),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Description preview
              Text(
                item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: AppColors.textMedium, height: 1.3),
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 8),
              // Price and Seller Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 14, color: AppColors.textMedium),
                      const SizedBox(width: 4),
                      Text(
                        '${item.sellerName} (${item.sellerCollege})',
                        style: TextStyle(fontSize: 11, color: AppColors.textMedium),
                      ),
                    ],
                  ),
                  Text(
                    item.type == 'SELL' ? '₱${item.price.toStringAsFixed(2)}' : (item.type == 'DONATE' ? 'FREE' : 'EXCHANGE'),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: item.type == 'DONATE' ? Colors.blue.shade700 : AppColors.primaryDarkGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'books':
        return Icons.menu_book_rounded;
      case 'uniforms':
        return Icons.checkroom_rounded;
      case 'gadgets':
        return Icons.devices_rounded;
      case 'school supplies':
        return Icons.architecture_rounded;
      default:
        return Icons.shopping_bag_outlined;
    }
  }
}
