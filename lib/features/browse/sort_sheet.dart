import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/mock/mock_database.dart';

class SortSheetScreen extends StatefulWidget {
  const SortSheetScreen({super.key});

  @override
  State<SortSheetScreen> createState() => _SortSheetScreenState();
}

class _SortSheetScreenState extends State<SortSheetScreen> {
  String _selectedSort = 'newest';

  final List<Map<String, dynamic>> _sortOptions = [
    {
      'id': 'newest',
      'label': 'Newest First',
      'subtitle': 'Recently posted listings on campus',
      'icon': Icons.schedule_rounded,
    },
    {
      'id': 'price_asc',
      'label': 'Price: Low to High',
      'subtitle': 'Best student bargains and free items',
      'icon': Icons.arrow_upward_rounded,
    },
    {
      'id': 'price_desc',
      'label': 'Price: High to Low',
      'subtitle': 'Premium calculators, boards and devices',
      'icon': Icons.arrow_downward_rounded,
    },
    {
      'id': 'rating',
      'label': 'Highest Rated Seller',
      'subtitle': 'Trusted students with 5-star ratings',
      'icon': Icons.star_outline_rounded,
    },
  ];

  void _applySort() {
    final db = context.read<MockDatabase>();
    final sorted = List.of(db.items.where((i) => i.status == 'active' && i.quantity > 0));

    switch (_selectedSort) {
      case 'newest':
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'price_asc':
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        sorted.sort((a, b) => b.sellerRating.compareTo(a.sellerRating));
        break;
    }

    // 22 Sort Sheet → Apply 20
    context.pushReplacement('/search-results', extra: {
      'query': 'Sorted Listings',
      'results': sorted,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Sort Listings'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sort Order',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: ListView.separated(
                  itemCount: _sortOptions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final opt = _sortOptions[index];
                    final isSelected = _selectedSort == opt['id'];

                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryDarkGreen : AppColors.borderLight,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: ListTile(
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.paleGreen : AppColors.background,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              opt['icon'] as IconData,
                              color: isSelected ? AppColors.primaryDarkGreen : AppColors.mutedGray,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            opt['label'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected ? AppColors.primaryDarkGreen : AppColors.textDark,
                            ),
                          ),
                          subtitle: Text(
                            opt['subtitle'] as String,
                            style: const TextStyle(fontSize: 11, color: AppColors.mutedGray),
                          ),
                          trailing: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? AppColors.primaryDarkGreen : AppColors.borderLight,
                                width: 2,
                              ),
                              color: isSelected ? AppColors.primaryDarkGreen : Colors.transparent,
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: AppColors.cardWhite,
                                  )
                                : null,
                          ),
                          onTap: () {
                            setState(() => _selectedSort = opt['id'] as String);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 22 Sort Sheet → Apply 20
              PrimaryButton(
                label: 'Apply Sort',
                icon: Icons.check_rounded,
                onPressed: _applySort,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
