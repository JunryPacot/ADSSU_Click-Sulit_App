import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/wave_header.dart';
import '../../data/mock/mock_database.dart';

class MyImpactScreen extends StatelessWidget {
  const MyImpactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final completedDeals = db.currentUser.dealsCompleted;
    final estimatedSavings = completedDeals * 280.0;
    final wasteDivertedKg = (completedDeals * 1.5).toStringAsFixed(1);
    final co2AvoidedKg = (completedDeals * 3.2).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'My Circular Impact',
          style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            WaveHeader(
              height: 180,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.eco_rounded, color: AppColors.accentGold, size: 28),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Sustainability Champion',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.merriweather(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your contributions to the ADSSU campus circular economy.',
                      style: GoogleFonts.carlito(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Stat Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$completedDeals',
                          style: GoogleFonts.carlito(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDarkGreen,
                          ),
                        ),
                        Text(
                          'Items Reused & Exchanged',
                          style: GoogleFonts.merriweather(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const Divider(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(child: _buildImpactMetric('₱${estimatedSavings.toStringAsFixed(0)}', 'Est. Saved')),
                            Expanded(child: _buildImpactMetric('$wasteDivertedKg kg', 'Diverted')),
                            Expanded(child: _buildImpactMetric('$co2AvoidedKg kg', 'CO₂ Avoided')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ADSSU Green Pledge
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.lightMint,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.midGreen.withAlpha(50)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.recycling_rounded, color: AppColors.midGreen),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'ADSSU Circular Mission',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.merriweather(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'By recirculating academic textbooks, uniform sets, and learning devices, students and faculty prevent landfill accumulation and reduce financial strain across colleges.',
                          style: GoogleFonts.carlito(fontSize: 13, color: AppColors.textDark, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactMetric(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.midGreen),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.mutedGray),
        ),
      ],
    );
  }
}
