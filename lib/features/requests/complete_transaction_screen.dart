import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/campus_constants.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/type_tag.dart';
import '../../data/mock/mock_database.dart';

class CompleteTransactionScreen extends StatelessWidget {
  final Map<String, dynamic>? extraData;

  const CompleteTransactionScreen({super.key, this.extraData});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final extra = extraData ?? {};
    final requestId = extra['requestId'] as String? ?? 'req_sample';
    final itemTitle = extra['itemTitle'] as String? ?? 'Campus Exchange Item';
    final itemType = extra['itemType'] as String? ?? 'SELL';
    final price = (extra['itemPrice'] as num?)?.toDouble() ?? 250.0;
    final otherParty = extra['buyerName'] as String? ?? 'Counterpart';
    final targetUserId = extra['sellerId'] as String? ?? 'user_seller';

    final isSell = itemType.toUpperCase() == CampusConstants.typeSell;
    final commission = isSell ? price * CampusConstants.commissionRate : 0.0;
    final earnings = isSell ? price * CampusConstants.sellerEarningsRate : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Complete Deal',
          style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transaction Summary',
                style: GoogleFonts.merriweather(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 6),
              Text(
                'Please verify the details below before completing the deal.',
                style: GoogleFonts.carlito(fontSize: 13, color: AppColors.mutedGray),
              ),
              const SizedBox(height: 20),

              // Breakdown Card
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            itemTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.merriweather(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                        TypeTag(type: itemType, isCompact: true),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Exchanged with: $otherParty',
                      style: const TextStyle(fontSize: 11, color: AppColors.mutedGray),
                    ),
                    const Divider(height: 24),
                    if (isSell) ...[
                      _buildFeeRow('Item Price:', '₱${price.toStringAsFixed(2)}', isBold: false),
                      const SizedBox(height: 8),
                      _buildFeeRow('Platform Commission (3%):', '-₱${commission.toStringAsFixed(2)}', isBold: false, isMuted: true),
                      const Divider(height: 20),
                      _buildFeeRow('Seller Receives (97%):', '₱${earnings.toStringAsFixed(2)}', isBold: true, isGreen: true),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.lightMint,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: AppColors.midGreen, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'No fees for ${itemType.toUpperCase()} — 100% Free Campus Exchange!',
                                style: const TextStyle(color: AppColors.midGreen, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              PrimaryButton(
                label: 'Confirm Completed',
                icon: Icons.done_all_rounded,
                onPressed: () {
                  db.completeTransaction(requestId);
                  context.pushNamed(
                    RouteNames.rateReview,
                    extra: {
                      'targetUserId': targetUserId,
                      'itemTitle': itemTitle,
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeeRow(String label, String value, {bool isBold = false, bool isMuted = false, bool isGreen = false}) {
    Color color = AppColors.textDark;
    if (isMuted) color = AppColors.mutedGray;
    if (isGreen) color = AppColors.primaryDarkGreen;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            color: color,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
