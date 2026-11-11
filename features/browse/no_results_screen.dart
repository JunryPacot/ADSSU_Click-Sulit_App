import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';

class NoResultsScreen extends StatelessWidget {
  final String? query;

  const NoResultsScreen({super.key, this.query});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Search Results'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Illustration Circle
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.paleGreen.withAlpha(120),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: AppColors.cardWhite,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.search_off_rounded,
                        size: 38,
                        color: AppColors.mutedGray,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'No Matches Found',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                if (query != null && query!.isNotEmpty)
                  Text(
                    'We couldn\'t find anything for "$query"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDarkGreen,
                    ),
                  ),
                const SizedBox(height: 10),

                const Text(
                  'Try searching for different keywords like "textbook", "uniform", or browse our campus categories.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.mutedGray,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 36),

                // 23 No Results → Clear filters 20 | Post an item 45
                PrimaryButton(
                  label: 'Clear Filters & View All',
                  icon: Icons.refresh_rounded,
                  onPressed: () => context.go('/search-results'),
                ),
                const SizedBox(height: 12),

                PrimaryButton(
                  label: 'Post This Item Yourself',
                  isAccent: true,
                  icon: Icons.add_circle_outline_rounded,
                  onPressed: () => context.push('/post/type'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
