import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/mock/mock_database.dart';

class RateReviewScreen extends StatefulWidget {
  final Map<String, dynamic>? extraData;

  const RateReviewScreen({super.key, this.extraData});

  @override
  State<RateReviewScreen> createState() => _RateReviewScreenState();
}

class _RateReviewScreenState extends State<RateReviewScreen> {
  int _rating = 5;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final extra = widget.extraData ?? {};
    final targetUserId = extra['targetUserId'] as String? ?? 'user_seller';
    final itemTitle = extra['itemTitle'] as String? ?? 'Exchange Item';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Rate & Review',
          style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              Text(
                'How was your exchange?',
                style: GoogleFonts.merriweather(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 6),
              Text(
                'Your rating builds trust within the ADSSU campus circular community.',
                textAlign: TextAlign.center,
                style: GoogleFonts.carlito(fontSize: 13, color: AppColors.mutedGray),
              ),
              const SizedBox(height: 12),
              Text(
                'Item: $itemTitle',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.midGreen),
              ),
              const SizedBox(height: 24),

              // Star Rating Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starVal = index + 1;
                  return IconButton(
                    iconSize: 40,
                    icon: Icon(
                      starVal <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: AppColors.accentGold,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = starVal;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text(
                _getRatingLabel(_rating),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryDarkGreen),
              ),
              const SizedBox(height: 24),

              // Comment Field
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Write a short review',
                  style: GoogleFonts.merriweather(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _commentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'e.g., Punctual meet-up, item in great condition as described. Highly recommended!',
                  hintStyle: const TextStyle(fontSize: 12, color: AppColors.mutedGray),
                  filled: true,
                  fillColor: AppColors.cardWhite,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              PrimaryButton(
                label: 'Submit Review',
                icon: Icons.rate_review_rounded,
                onPressed: () {
                  final comment = _commentController.text.trim().isEmpty
                      ? 'Great transaction on campus! Accurate item description.'
                      : _commentController.text.trim();

                  db.addReview(
                    targetUserId: targetUserId,
                    itemTitle: itemTitle,
                    rating: _rating.toDouble(),
                    comment: comment,
                  );

                  context.goNamed(RouteNames.reviewSubmitted);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 5:
        return 'Excellent! (5/5)';
      case 4:
        return 'Very Good! (4/5)';
      case 3:
        return 'Average (3/5)';
      case 2:
        return 'Below Expectations (2/5)';
      case 1:
      default:
        return 'Poor (1/5)';
    }
  }
}

