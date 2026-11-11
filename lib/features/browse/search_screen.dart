import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/campus_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/mock/mock_database.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();

  final List<String> _popularTags = [
    'Calculus',
    'CTE uniform',
    'Casio calculator',
    'Drafting board',
    'Bond paper',
    'Physics Vol 1',
    'Lab gown',
    'CCIS shirt',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _executeSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final db = context.read<MockDatabase>();
    final matches = db.items.where((i) {
      final q = trimmed.toLowerCase();
      return i.status == 'active' &&
          (i.title.toLowerCase().contains(q) ||
              i.description.toLowerCase().contains(q) ||
              i.category.toLowerCase().contains(q) ||
              i.sellerCollege.toLowerCase().contains(q));
    }).toList();

    // 19 Search → 20 (results) | 23 (no match)
    if (matches.isNotEmpty) {
      context.push('/search-results', extra: {'query': trimmed, 'results': matches});
    } else {
      context.push('/no-results', extra: {'query': trimmed});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onSubmitted: _executeSearch,
          decoration: InputDecoration(
            hintText: 'Search items, subjects, uniforms...',
            hintStyle: const TextStyle(fontSize: 14, color: AppColors.mutedGray),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
          ),
          onChanged: (_) => setState(() {}),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Action Button
              ElevatedButton.icon(
                onPressed: _searchController.text.trim().isNotEmpty
                    ? () => _executeSearch(_searchController.text)
                    : null,
                icon: const Icon(Icons.search_rounded),
                label: Text(
                  _searchController.text.trim().isEmpty
                      ? 'Type a keyword above'
                      : 'Search for "${_searchController.text.trim()}"',
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Popular Campus Searches',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _popularTags.map((tag) {
                  return ActionChip(
                    label: Text(tag, style: const TextStyle(fontSize: 12)),
                    backgroundColor: AppColors.cardWhite,
                    side: const BorderSide(color: AppColors.borderLight),
                    avatar: const Icon(Icons.trending_up_rounded, size: 14, color: AppColors.midGreen),
                    onPressed: () {
                      _searchController.text = tag;
                      _executeSearch(tag);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              const Text(
                'Explore by Category',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),

              ...CampusConstants.categories.map((cat) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.category_outlined, color: AppColors.primaryDarkGreen, size: 20),
                  title: Text(cat, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.mutedGray),
                  onTap: () {
                    _searchController.text = cat;
                    _executeSearch(cat);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
