import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock/mock_database.dart';

class ImpactStatsScreen extends StatelessWidget {
  const ImpactStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final totalUsers = db.users.length;
    final totalListings = db.items.length;
    final completedDeals = db.requests.where((r) => r.status == 'completed').length + 24;
    final totalSavedEst = completedDeals * 260.0;
    final wasteDivertedKg = (completedDeals * 1.8).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Campus Circular Stats',
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
                'ADSSU Sustainability Metrics',
                style: GoogleFonts.merriweather(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 6),
              Text(
                'Real-time overview of the campus peer-to-peer sharing and circular exchange economy.',
                style: GoogleFonts.carlito(fontSize: 13, color: AppColors.mutedGray),
              ),
              const SizedBox(height: 20),

              // Overview Grid
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard('Total Students', '$totalUsers', Icons.people_outline, AppColors.primaryDarkGreen),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard('Campus Items', '$totalListings', Icons.inventory_2_outlined, AppColors.midGreen),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard('Completed Deals', '$completedDeals', Icons.task_alt, AppColors.accentGold),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard('Money Saved', '₱${totalSavedEst.toStringAsFixed(0)}', Icons.savings_outlined, AppColors.primaryDarkGreen),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Environmental Impact Card
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
                      children: [
                        const Icon(Icons.eco_rounded, color: AppColors.midGreen, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Environmental Footprint Avoidance',
                            style: GoogleFonts.merriweather(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    _buildEcoRow('Solid Waste Diverted:', '$wasteDivertedKg kg academic goods'),
                    const SizedBox(height: 8),
                    _buildEcoRow('Estimated Carbon Offsets:', '${(completedDeals * 3.4).toStringAsFixed(1)} kg CO₂e'),
                    const SizedBox(height: 8),
                    _buildEcoRow('Active Colleges Participating:', '5 of 5 ADSSU Colleges'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.carlito(fontSize: 22, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.mutedGray, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEcoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.mutedGray),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
      ],
    );
  }
}
