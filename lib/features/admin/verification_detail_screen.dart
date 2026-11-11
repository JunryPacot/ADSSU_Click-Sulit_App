import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/mock/mock_database.dart';

class VerificationDetailScreen extends StatelessWidget {
  final String userId;

  const VerificationDetailScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final user = db.users.firstWhere(
      (u) => u.id == userId,
      orElse: () => db.currentUser,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Verification Review',
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
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primaryDarkGreen,
                          child: Text(
                            user.name.isNotEmpty ? user.name[0] : 'U',
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: GoogleFonts.merriweather(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                user.email,
                                style: const TextStyle(fontSize: 12, color: AppColors.primaryDarkGreen),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildInfoRow('Student / Faculty ID:', user.studentId),
                    const SizedBox(height: 8),
                    _buildInfoRow('College Affiliation:', user.college),
                    const SizedBox(height: 8),
                    _buildInfoRow('Verification Status:', user.isVerified ? 'Verified' : 'Pending Review'),
                  ],
                ),
              ),
              const Spacer(),

              PrimaryButton(
                label: 'Approve Verification',
                icon: Icons.check_circle_rounded,
                onPressed: () {
                  db.adminApproveVerification(user.id);
                  context.goNamed(RouteNames.adminVerifications);
                },
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Reject Verification',
                icon: Icons.cancel_outlined,
                isSecondary: true,
                onPressed: () {
                  db.adminRejectVerification(user.id);
                  context.goNamed(RouteNames.adminVerifications);
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

