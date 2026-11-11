import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/type_tag.dart';
import '../../data/mock/mock_database.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final currentUserId = db.currentUser.id;

    // Completed requests involving user + completed items
    final completedRequests = db.requests
        .where((r) => (r.sellerId == currentUserId || r.buyerId == currentUserId) && r.status == 'completed')
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Transaction History',
          style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: completedRequests.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.receipt_long_outlined, size: 54, color: AppColors.mutedGray),
                    const SizedBox(height: 12),
                    const Text('No completed transactions yet.', style: TextStyle(color: AppColors.mutedGray)),
                    const SizedBox(height: 8),
                    const Text('Completed meet-ups and trades will appear here.', style: TextStyle(fontSize: 12, color: AppColors.mutedGray)),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: completedRequests.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final req = completedRequests[index];
                  final isSeller = req.sellerId == currentUserId;
                  final dateStr = DateFormat('MMM d, yyyy').format(req.createdAt);

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      context.pushNamed(
                        RouteNames.completeTransaction,
                        extra: {
                          'requestId': req.id,
                          'itemTitle': req.itemTitle,
                          'itemType': req.itemType,
                          'itemPrice': req.itemPrice,
                          'buyerName': req.buyerName,
                          'sellerId': req.sellerId,
                        },
                      );
                    },
                    child: Container(
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
                              TypeTag(type: req.itemType, isCompact: true),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.lightMint,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'COMPLETED',
                                  style: TextStyle(color: AppColors.statusSuccess, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            req.itemTitle,
                            style: GoogleFonts.merriweather(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isSeller ? 'Sold to ${req.buyerName}' : 'Received from ${req.sellerName}',
                            style: const TextStyle(fontSize: 12, color: AppColors.mutedGray),
                          ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(dateStr, style: const TextStyle(fontSize: 11, color: AppColors.mutedGray)),
                              Text(
                                req.itemType == 'SELL'
                                    ? '₱${req.itemPrice.toStringAsFixed(2)}'
                                    : 'Free / Trade',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: req.itemType == 'SELL' ? AppColors.primaryDarkGreen : AppColors.midGreen,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

