import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/item_card.dart';
import '../../core/widgets/wave_header.dart';
import '../../data/mock/mock_database.dart';

class SellerProfileScreen extends StatelessWidget {
  final String sellerId;
  final String? profileType;

  const SellerProfileScreen({
    super.key,
    required this.sellerId,
    this.profileType,
  });

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final seller = db.users.firstWhere(
      (u) => u.id == sellerId,
      orElse: () => db.currentUser,
    );

    final type = (profileType ?? '').toLowerCase();
    final bool isDonor = type.contains('donat') || type.contains('donor');
    final bool isExchange = type.contains('exchange') || type.contains('swap') || type.contains('trade');

    final String screenTitle = isDonor
        ? 'Donor Profile'
        : isExchange
            ? 'Exchange Profile'
            : 'Seller Profile';

    final String aboutTitle = isDonor
        ? 'About Donor'
        : isExchange
            ? 'About Trader'
            : 'About Seller';

    final String defaultBio = isDonor
        ? 'ADSSU Community donor.'
        : isExchange
            ? 'ADSSU Student item trader.'
            : 'ADSSU Student community member.';

    final String roleBadge = isDonor
        ? 'CAMPUS DONOR'
        : isExchange
            ? 'CAMPUS TRADER'
            : 'VERIFIED SELLER';

    final Color badgeColor = isDonor
        ? AppColors.midGreen
        : isExchange
            ? AppColors.primaryDarkGreen
            : AppColors.accentGold;

    final sellerItems = isDonor
        ? db.items.where((i) => i.sellerId == sellerId && i.type == 'DONATE' && i.status == 'active').toList()
        : isExchange
            ? db.items.where((i) => i.sellerId == sellerId && i.type == 'EXCHANGE' && i.status == 'active').toList()
            : db.items.where((i) => i.sellerId == sellerId && (profileType == null || i.type == 'SELL') && i.status == 'active').toList();

    final String listingsTitle = isDonor
        ? 'Donation Items (${sellerItems.length})'
        : isExchange
            ? 'Items for Exchange (${sellerItems.length})'
            : 'Active Listings (${sellerItems.length})';

    final String emptyListingsText = isDonor
        ? 'No active donation items from this donor.'
        : isExchange
            ? 'No active exchange items from this trader.'
            : 'No active listings from this seller.';

    final String emptyReviewsText = isDonor
        ? 'No reviews yet for this donor.'
        : isExchange
            ? 'No reviews yet for this trader.'
            : 'No reviews yet for this seller.';

    final sellerReviews = db.reviews.where((r) => r.targetUserId == sellerId).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          screenTitle,
          style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wave Header with Profile Info
            WaveHeader(
              height: 180,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    ClipOval(
                      child: Container(
                        width: 72,
                        height: 72,
                        color: AppColors.cardWhite,
                        child: seller.profilePhoto != null && seller.profilePhoto!.isNotEmpty
                            ? AppImage(
                                imageSource: seller.profilePhoto,
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                                fallbackIcon: Icons.person_rounded,
                              )
                            : Center(
                                child: Text(
                                  seller.name.isNotEmpty ? seller.name[0].toUpperCase() : 'S',
                                  style: const TextStyle(
                                    color: AppColors.primaryDarkGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  seller.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.merriweather(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (seller.isVerified) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.verified, color: AppColors.accentGold, size: 16),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            seller.college,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              roleBadge,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.star, color: AppColors.accentGold, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${seller.rating.toStringAsFixed(1)} (${seller.totalReviews} reviews)',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bio & Stats Card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          aboutTitle,
                          style: GoogleFonts.merriweather(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          seller.bio.isNotEmpty ? seller.bio : defaultBio,
                          style: GoogleFonts.carlito(fontSize: 13, color: AppColors.textDark),
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('Listings', '${sellerItems.length}'),
                            _buildStatItem('Completed', '${seller.dealsCompleted}'),
                            _buildStatItem('Rating', seller.rating.toStringAsFixed(1)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Listings Section
                  Text(
                    listingsTitle,
                    style: GoogleFonts.merriweather(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (sellerItems.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Text(emptyListingsText),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: sellerItems.length,
                      itemBuilder: (context, index) {
                        return ItemCard(item: sellerItems[index]);
                      },
                    ),

                  const SizedBox(height: 24),

                  // Reviews Section
                  Text(
                    'Reviews & Ratings (${sellerReviews.length})',
                    style: GoogleFonts.merriweather(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (sellerReviews.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Text(emptyReviewsText),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sellerReviews.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final rev = sellerReviews[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.cardWhite,
                            borderRadius: BorderRadius.circular(12),
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
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  Row(
                                    children: List.generate(
                                      5,
                                      (starIdx) => Icon(
                                        starIdx < rev.rating ? Icons.star : Icons.star_border,
                                        size: 14,
                                        color: AppColors.accentGold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                rev.comment,
                                style: GoogleFonts.carlito(fontSize: 13, color: AppColors.textDark),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.carlito(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDarkGreen,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.mutedGray),
        ),
      ],
    );
  }
}
