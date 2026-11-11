import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock/mock_database.dart';

class MyReviewsScreen extends StatelessWidget {
  const MyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final currentUserId = db.currentUser.id;
    final myReviews = db.reviews.where((r) => r.targetUserId == currentUserId).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'My Reviews (${myReviews.length})',
          style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: myReviews.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star_outline_rounded, size: 54, color: AppColors.mutedGray),
                    const SizedBox(height: 12),
                    const Text('No reviews yet.', style: TextStyle(color: AppColors.mutedGray)),
                    const SizedBox(height: 6),
                    const Text('Complete meet-ups with peers to receive ratings and feedback.', style: TextStyle(fontSize: 12, color: AppColors.mutedGray)),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: myReviews.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final rev = myReviews[index];
                  final dateStr = DateFormat('MMM d, yyyy').format(rev.createdAt);

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              rev.reviewerName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Row(
                              children: List.generate(
                                5,
                                (starIdx) => Icon(
                                  starIdx < rev.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                  color: AppColors.accentGold,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Item: ${rev.itemTitle}',
                          style: const TextStyle(fontSize: 11, color: AppColors.midGreen, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          rev.comment,
                          style: GoogleFonts.carlito(fontSize: 13, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(dateStr, style: const TextStyle(fontSize: 10, color: AppColors.mutedGray)),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

