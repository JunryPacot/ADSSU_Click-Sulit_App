import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/primary_button.dart';

class MeetUpConfirmedScreen extends StatelessWidget {
  final Map<String, dynamic>? extraData;

  const MeetUpConfirmedScreen({super.key, this.extraData});

  @override
  Widget build(BuildContext context) {
    final extra = extraData ?? {};
    final building = extra['meetUpBuilding'] ?? 'CA Building';
    final location = extra['exactLocation'] ?? '';
    final itemTitle = extra['itemTitle'] ?? 'Deal Item';
    final otherParty = extra['buyerName'] ?? 'Counterpart';
    final sellerId = extra['sellerId'] ?? '';
    final hasPhoto = extra['hasLocationPhoto'] == true;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Meet-Up Confirmed',
          style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: AppColors.paleGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.place_rounded, size: 44, color: AppColors.midGreen),
              ),
              const SizedBox(height: 16),
              Text(
                'Meet-Up Agreed!',
                style: GoogleFonts.merriweather(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              Text(
                'Coordinate with $otherParty for the exchange at the confirmed ADSSU spot.',
                textAlign: TextAlign.center,
                style: GoogleFonts.carlito(fontSize: 13, color: AppColors.mutedGray),
              ),
              const SizedBox(height: 24),

              // Summary Card
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
                      'Exchange Summary',
                      style: GoogleFonts.merriweather(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 20),
                    _buildRow('Item:', itemTitle),
                    const SizedBox(height: 8),
                    _buildRow('Meet-Up Building:', building),
                    if (location.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildRow('Specific Spot:', location),
                    ],
                    if (hasPhoto) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          context.pushNamed(
                            RouteNames.photoViewer,
                            extra: {
                              'title': '$building Spot Photo',
                              'imageUrl': extra['locationPhoto'],
                            },
                          );
                        },
                        icon: const Icon(Icons.image, size: 16, color: AppColors.primaryDarkGreen),
                        label: const Text('View Spot Photo', style: TextStyle(color: AppColors.primaryDarkGreen, fontSize: 12)),
                      ),
                    ],
                  ],
                ),
              ),
              const Spacer(),

              // Mark as Completed (Screen 42)
              PrimaryButton(
                label: 'Mark as Completed',
                icon: Icons.task_alt_rounded,
                onPressed: () {
                  context.pushNamed(
                    RouteNames.completeTransaction,
                    extra: extra,
                  );
                },
              ),
              const SizedBox(height: 12),

              // Open Chat
              PrimaryButton(
                label: 'Open Chat',
                icon: Icons.chat_bubble_outline_rounded,
                isSecondary: true,
                onPressed: () {
                  context.pushNamed(
                    RouteNames.chat,
                    pathParameters: {'id': 'chat_$sellerId'},
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

  Widget _buildRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.mutedGray, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
        ),
      ],
    );
  }
}

