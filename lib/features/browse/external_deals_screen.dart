import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/external_product_model.dart';
import '../../data/services/external_api_service.dart';
import '../../data/mock/mock_database.dart';

/// Screen demonstrating Laboratory Exercise 4:
/// - Task 1: External API Integration using HTTP (GET request, JSON parsing, loading, error handling, refresh)
/// - Task 2 & 3: Local Data Storage Integration (Saving/Bookmarking API data to SharedPreferences)
class ExternalDealsScreen extends StatefulWidget {
  const ExternalDealsScreen({super.key});

  @override
  State<ExternalDealsScreen> createState() => _ExternalDealsScreenState();
}

class _ExternalDealsScreenState extends State<ExternalDealsScreen> {
  final _apiService = ExternalApiService();
  final _searchController = TextEditingController();

  List<ExternalProductModel> _products = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Smartphones',
    'Laptops',
    'Accessories',
    'Groceries',
    'Furniture',
    'Tops',
    'Sunglasses',
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Sends HTTP request to external API and handles loading & errors
  Future<void> _loadProducts({String? search, String? category}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await _apiService.fetchProducts(
        search: search ?? _searchController.text.trim(),
        category: category ?? _selectedCategory,
      );

      if (!mounted) return;
      setState(() {
        _products = results;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _searchController.clear();
    });
    _loadProducts(category: category);
  }

  void _onSearchSubmitted(String value) {
    _loadProducts(search: value);
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'External Market Deals',
              style: GoogleFonts.merriweather(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Live REST API • DummyJSON / FakeStore',
              style: TextStyle(fontSize: 10, color: AppColors.mutedGray),
            ),
          ],
        ),
        actions: [
          // Wishlist / Saved Items shortcut
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.favorite_rounded, color: AppColors.statusError),
                if (db.savedExternalProducts.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryDarkGreen,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                      child: Text(
                        '${db.savedExternalProducts.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'View Saved External Items',
            onPressed: () => context.push('/saved-items'),
          ),

          // Reload data button
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh API Data',
            onPressed: () => _loadProducts(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Field
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: _onSearchSubmitted,
                decoration: InputDecoration(
                  hintText: 'Search external catalog...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.mutedGray),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _loadProducts();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.cardWhite,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                ),
              ),
            ),

            // Category Filter Chips
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory.toLowerCase() == cat.toLowerCase();
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) _onCategorySelected(cat);
                    },
                    selectedColor: AppColors.primaryDarkGreen,
                    backgroundColor: AppColors.cardWhite,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : AppColors.textDark,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppColors.primaryDarkGreen : AppColors.borderLight,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // Active content: Loading, Error, or Product Grid
            Expanded(
              child: _buildBody(context, db),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, MockDatabase db) {
    // 1. Loading Indicator State (Task 1 requirement)
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: AppColors.primaryDarkGreen,
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'Fetching live marketplace data from API...',
              style: TextStyle(
                color: AppColors.textDark.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Sending HTTP GET request to external servers',
              style: TextStyle(color: AppColors.mutedGray, fontSize: 12),
            ),
          ],
        ),
      );
    }

    // 2. Error State with Retry Button (Task 1 requirement)
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.statusError.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  size: 48,
                  color: AppColors.statusError,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Network Connection Error',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.mutedGray,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _loadProducts(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again / Retry Request'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDarkGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Empty results state
    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 54, color: AppColors.mutedGray),
            const SizedBox(height: 12),
            const Text(
              'No external products found.',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try adjusting your search keyword or category filter.',
              style: TextStyle(fontSize: 12, color: AppColors.mutedGray),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                _searchController.clear();
                _onCategorySelected('All');
              },
              child: const Text('Reset Filters'),
            ),
          ],
        ),
      );
    }

    // 3. Retrieved Data Display with Pull-to-Refresh (Task 1 & Task 2 requirement)
    return RefreshIndicator(
      color: AppColors.primaryDarkGreen,
      onRefresh: () => _loadProducts(),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.64,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          final isSaved = db.isExternalProductSaved(product.id);

          return _buildProductCard(context, product, isSaved, db);
        },
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    ExternalProductModel product,
    bool isSaved,
    MockDatabase db,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSaved ? AppColors.accentGold : AppColors.borderLight,
          width: isSaved ? 1.5 : 1.0,
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image & Action Badges
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: AspectRatio(
                  aspectRatio: 1.15,
                  child: product.thumbnail.isNotEmpty
                      ? Image.network(
                          product.thumbnail,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.paleGreen,
                            child: const Icon(Icons.image_not_supported_rounded, color: AppColors.mutedGray),
                          ),
                          loadingBuilder: (ctx, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: AppColors.paleGreen.withOpacity(0.3),
                              child: const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryDarkGreen),
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: AppColors.paleGreen,
                          child: const Icon(Icons.shopping_bag_rounded, color: AppColors.primaryDarkGreen),
                        ),
                ),
              ),

              // Category tag
              Positioned(
                left: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDarkGreen.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    product.category.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              // Save to Local Storage Bookmark Button (Task 2 requirement)
              Positioned(
                right: 6,
                top: 6,
                child: GestureDetector(
                  onTap: () async {
                    await db.toggleSaveExternalProduct(product);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isSaved
                              ? 'Removed "${product.title}" from local storage.'
                              : 'Saved "${product.title}" to local device storage!',
                        ),
                        backgroundColor: isSaved ? AppColors.mutedGray : AppColors.primaryDarkGreen,
                        duration: const Duration(seconds: 2),
                        action: SnackBarAction(
                          label: 'View Wishlist',
                          textColor: AppColors.accentGold,
                          onPressed: () => context.push('/saved-items'),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      size: 18,
                      color: isSaved ? AppColors.statusError : AppColors.mutedGray,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Product Details
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand & Rating
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.brand,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mutedGray,
                        ),
                      ),
                    ),
                    const Icon(Icons.star_rounded, size: 13, color: AppColors.accentGold),
                    const SizedBox(width: 2),
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Title
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),

                // Price (Converted to PHP & Original USD)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      product.formattedPricePhp,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDarkGreen,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(\$${product.price.toStringAsFixed(0)})',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.mutedGray,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Action: Save to Local Storage Button
                SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await db.toggleSaveExternalProduct(product);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isSaved
                                ? 'Removed from local storage.'
                                : 'Persisted to device local storage!',
                          ),
                          backgroundColor: isSaved ? AppColors.mutedGray : AppColors.primaryDarkGreen,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: Icon(
                      isSaved ? Icons.check_circle_rounded : Icons.bookmark_add_outlined,
                      size: 14,
                      color: isSaved ? AppColors.primaryDarkGreen : AppColors.primaryDarkGreen,
                    ),
                    label: Text(
                      isSaved ? 'Saved Locally' : 'Save Locally',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryDarkGreen,
                      side: BorderSide(
                        color: isSaved ? AppColors.primaryDarkGreen : AppColors.borderLight,
                      ),
                      padding: EdgeInsets.zero,
                      backgroundColor: isSaved ? AppColors.paleGreen.withOpacity(0.5) : Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
