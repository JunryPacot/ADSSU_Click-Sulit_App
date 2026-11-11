import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/admin_bottom_nav.dart';
import '../../data/mock/mock_database.dart';

class ReportedItemsScreen extends StatelessWidget {
  const ReportedItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final reports = db.reports;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Reported Items',
          style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: reports.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shield_rounded, size: 54, color: AppColors.midGreen),
                    const SizedBox(height: 12),
                    const Text('No active reports', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 6),
                    const Text('Campus marketplace is clean and in good standing.', style: TextStyle(fontSize: 12, color: AppColors.mutedGray)),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: reports.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final rep = reports[index];
                  final isPending = rep.status == 'pending';

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      context.pushNamed(RouteNames.reportDetail, pathParameters: {'id': rep.id});
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
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.statusError.withAlpha(20),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  rep.reason,
                                  style: const TextStyle(color: AppColors.statusError, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                isPending ? 'PENDING' : rep.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isPending ? AppColors.accentGold : AppColors.mutedGray,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            rep.itemTitle,
                            style: GoogleFonts.merriweather(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Reported by: ${rep.reportedByUserName} • Seller: ${rep.sellerName}',
                            style: const TextStyle(fontSize: 11, color: AppColors.mutedGray),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            rep.details,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.carlito(fontSize: 12, color: AppColors.textDark),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 2),
    );
  }
}

