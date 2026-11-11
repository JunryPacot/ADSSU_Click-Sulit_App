import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class HelpFaqScreen extends StatelessWidget {
  const HelpFaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'q': 'Who can use ADSSU Click & Sulit?',
        'a': 'Only bona fide students, faculty, and administrative staff of Agusan del Sur State University with an official @adssu.edu.ph email address can register and trade.'
      },
      {
        'q': 'How does exchanging works?',
        'a': 'Exchanging is 100% free! You propose one of your pre-loved active items to trade with another student\'s listing. If both agree, set a meet-up at any designated campus landmark.'
      },
      {
        'q': 'Why is there a ₱50 seller membership fee?',
        'a': 'To prevent spam, commercial abuse, and fraud in cash transactions, sellers pay a one-time ₱50 membership verification via GCash. Exchanges and donations are always free.'
      },
      {
        'q': 'Where do meet-ups take place?',
        'a': 'All exchanges must occur at designated ADSSU campus buildings (e.g., CA, CAS, CTE, CEIT/CCIS, ICT Building, Library, MPB, etc.) during official daytime university hours.'
      },
      {
        'q': 'What is the platform fee on completed sales?',
        'a': 'A 3% platform commission is automatically deducted upon completing a sale to maintain the student circular platform, while 97% goes directly to the seller.'
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Help & FAQ',
          style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: faqs.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final faq = faqs[index];

            return Container(
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.cardShadow,
              ),
              child: ExpansionTile(
                shape: const RoundedRectangleBorder(side: BorderSide.none),
                collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
                title: Text(
                  faq['q']!,
                  style: GoogleFonts.merriweather(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      faq['a']!,
                      style: GoogleFonts.carlito(fontSize: 13, color: AppColors.mutedGray, height: 1.4),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

