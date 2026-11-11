import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/admin_bottom_nav.dart';
import '../../data/mock/mock_database.dart';
import '../../data/models/payment_model.dart';

class PaymentsReviewScreen extends StatelessWidget {
  const PaymentsReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final payments = db.payments;
    final memberships = payments.where((p) => p.paymentType == 'membership').toList();
    final boosts = payments.where((p) => p.paymentType == 'boost').toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'Payments Review',
            style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          bottom: TabBar(
            indicatorColor: AppColors.primaryDarkGreen,
            labelColor: AppColors.primaryDarkGreen,
            unselectedLabelColor: AppColors.mutedGray,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: [
              Tab(text: 'Memberships (${memberships.length})'),
              Tab(text: 'Boosts (${boosts.length})'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPaymentsList(context, memberships),
            _buildPaymentsList(context, boosts),
          ],
        ),
        bottomNavigationBar: const AdminBottomNav(currentIndex: 3),
      ),
    );
  }

  Widget _buildPaymentsList(BuildContext context, List<PaymentModel> list) {
    if (list.isEmpty) {
      return const Center(
        child: Text('No payments found in this category.', style: TextStyle(color: AppColors.mutedGray)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final pay = list[index];

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.pushNamed(RouteNames.paymentDetail, pathParameters: {'id': pay.id});
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFF007DFE),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'G',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₱${pay.amount.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryDarkGreen),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: pay.status == 'approved' ? AppColors.lightMint : AppColors.accentGold.withAlpha(30),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              pay.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: pay.status == 'approved' ? AppColors.statusSuccess : AppColors.accentGold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Payer: ${pay.userName} (${pay.userCollege})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Ref: ${pay.referenceNumber}',
                        style: const TextStyle(fontSize: 11, color: AppColors.mutedGray),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.mutedGray),
              ],
            ),
          ),
        );
      },
    );
  }
}

