import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/mock/mock_database.dart';

class PaymentDetailScreen extends StatelessWidget {
  final String paymentId;

  const PaymentDetailScreen({super.key, required this.paymentId});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final payment = db.payments.firstWhere(
      (p) => p.id == paymentId,
      orElse: () => db.payments.first,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Payment Verification',
          style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                          '₱${payment.amount.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.primaryDarkGreen),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: payment.status == 'approved' ? AppColors.lightMint : AppColors.accentGold.withAlpha(30),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            payment.status.toUpperCase(),
                            style: TextStyle(
                              color: payment.status == 'approved' ? AppColors.statusSuccess : AppColors.accentGold,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildInfoRow('Payment Purpose:', payment.paymentType.toUpperCase()),
                    const SizedBox(height: 8),
                    _buildInfoRow('GCash Ref Number:', payment.referenceNumber),
                    const SizedBox(height: 8),
                    _buildInfoRow('Student / Payer:', payment.userName),
                    const SizedBox(height: 8),
                    _buildInfoRow('College:', payment.userCollege),
                    if (payment.relatedItemTitle != null) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow('Target Listing:', payment.relatedItemTitle!),
                    ],
                  ],
                ),
              ),
              const Spacer(),

              PrimaryButton(
                label: 'Approve Payment',
                icon: Icons.check_circle_rounded,
                onPressed: () {
                  db.adminApprovePayment(payment.id);
                  context.goNamed(RouteNames.paymentsReview);
                },
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Reject Payment',
                icon: Icons.cancel_outlined,
                isSecondary: true,
                onPressed: () {
                  db.adminRejectPayment(payment.id, 'Invalid or unrecognized GCash reference.');
                  context.goNamed(RouteNames.paymentsReview);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.mutedGray, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, color: AppColors.textDark, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

