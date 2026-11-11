import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/mock/mock_database.dart';

class ReportDetailScreen extends StatelessWidget {
  final String reportId;

  const ReportDetailScreen({super.key, required this.reportId});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final report = db.reports.firstWhere(
      (r) => r.id == reportId,
      orElse: () => db.reports.first,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Report Inspection',
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
                      'Flagged Reason: ${report.reason}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.statusError),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Listing: ${report.itemTitle}',
                      style: GoogleFonts.merriweather(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text('Seller: ${report.sellerName}', style: const TextStyle(fontSize: 12, color: AppColors.mutedGray)),
                    Text('Reported By: ${report.reportedByUserName}', style: const TextStyle(fontSize: 12, color: AppColors.mutedGray)),
                    const Divider(height: 20),
                    const Text('Student Feedback / Details:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      report.details,
                      style: GoogleFonts.carlito(fontSize: 13, color: AppColors.textDark, height: 1.4),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              PrimaryButton(
                label: 'Remove Listing',
                icon: Icons.delete_forever_rounded,
                onPressed: () {
                  db.adminResolveReport(report.id, 'resolved_removed');
                  context.goNamed(RouteNames.adminReports);
                },
              ),
              const SizedBox(height: 10),
              PrimaryButton(
                label: 'Warn Seller',
                icon: Icons.warning_amber_rounded,
                isAccent: true,
                onPressed: () {
                  db.adminResolveReport(report.id, 'resolved_warned');
                  context.goNamed(RouteNames.adminReports);
                },
              ),
              const SizedBox(height: 10),
              PrimaryButton(
                label: 'Dismiss Report',
                icon: Icons.close_rounded,
                isSecondary: true,
                onPressed: () {
                  db.adminResolveReport(report.id, 'dismissed');
                  context.goNamed(RouteNames.adminReports);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

