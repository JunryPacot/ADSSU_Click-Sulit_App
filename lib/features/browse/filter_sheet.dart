import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/campus_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/mock/mock_database.dart';

class FilterSheetScreen extends StatefulWidget {
  const FilterSheetScreen({super.key});

  @override
  State<FilterSheetScreen> createState() => _FilterSheetScreenState();
}

class _FilterSheetScreenState extends State<FilterSheetScreen> {
  String _selectedType = 'ALL'; // ALL, SELL, EXCHANGE, DONATE
  String? _selectedCategory;
  String? _selectedCondition;
  RangeValues _priceRange = const RangeValues(0, 1500);

  final List<String> _conditions = [
    'All Conditions',
    'New',
    'Like New',
    'Used - Good',
    'Fair',
  ];

  void _applyFilter() {
    final db = context.read<MockDatabase>();
    final filtered = db.items.where((i) {
      if (i.status != 'active' || i.quantity <= 0) return false;

      // Type
      if (_selectedType != 'ALL' && i.type.toUpperCase() != _selectedType) {
        return false;
      }
      // Category
      if (_selectedCategory != null && i.category != _selectedCategory) {
        return false;
      }
      // Condition
      if (_selectedCondition != null &&
          _selectedCondition != 'All Conditions' &&
          i.condition != _selectedCondition) {
        return false;
      }
      // Price
      if (i.type == 'SELL' && (i.price < _priceRange.start || i.price > _priceRange.end)) {
        return false;
      }

      return true;
    }).toList();

    // 21 Filter Sheet → Apply 20
    context.pushReplacement('/search-results', extra: {
      'query': _selectedType != 'ALL' ? _selectedType : 'Filtered',
      'results': filtered,
    });
  }

  void _resetFilter() {
    setState(() {
      _selectedType = 'ALL';
      _selectedCategory = null;
      _selectedCondition = null;
      _priceRange = const RangeValues(0, 1500);
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
        title: const Text('Filter Listings'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _resetFilter,
            child: const Text('Reset', style: TextStyle(color: AppColors.mutedGray)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction Type
              const Text(
                'Listing Type',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildTypeChip('ALL', 'All Items'),
                  const SizedBox(width: 8),
                  _buildTypeChip('SELL', 'For Sale'),
                  const SizedBox(width: 8),
                  _buildTypeChip('EXCHANGE', 'Swap'),
                  const SizedBox(width: 8),
                  _buildTypeChip('DONATE', 'Free'),
                ],
              ),
              const SizedBox(height: 24),

              // Category
              const Text(
                'Category',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: CampusConstants.categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat, style: const TextStyle(fontSize: 12)),
                    selected: isSelected,
                    selectedColor: AppColors.paleGreen,
                    backgroundColor: AppColors.cardWhite,
                    side: BorderSide(
                      color: isSelected ? AppColors.primaryDarkGreen : AppColors.borderLight,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? cat : null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Condition
              const Text(
                'Condition',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _conditions.map((cond) {
                  final isSelected = _selectedCondition == cond;
                  return ChoiceChip(
                    label: Text(cond, style: const TextStyle(fontSize: 12)),
                    selected: isSelected,
                    selectedColor: AppColors.paleGreen,
                    backgroundColor: AppColors.cardWhite,
                    side: BorderSide(
                      color: isSelected ? AppColors.primaryDarkGreen : AppColors.borderLight,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCondition = selected ? cond : null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Price Range (for items for sale)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Price Range (₱)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  Text(
                    '₱${_priceRange.start.round()} - ₱${_priceRange.end.round()}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDarkGreen,
                    ),
                  ),
                ],
              ),
              RangeSlider(
                values: _priceRange,
                min: 0,
                max: 1500,
                divisions: 30,
                activeColor: AppColors.primaryDarkGreen,
                inactiveColor: AppColors.paleGreen,
                onChanged: (vals) {
                  setState(() => _priceRange = vals);
                },
              ),
              const SizedBox(height: 32),

              // 21 Filter Sheet → Apply 20
              PrimaryButton(
                label: 'Apply Filters',
                icon: Icons.check_rounded,
                onPressed: _applyFilter,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String type, String label) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedType = type),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryDarkGreen : AppColors.cardWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primaryDarkGreen : AppColors.borderLight,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.cardWhite : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }
}

