import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/mock/mock_database.dart';

class MarkAsDoneScreen extends StatelessWidget {
  final String itemId;

  const MarkAsDoneScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final item = db.getItemById(itemId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(RouteNames.myListings);
            }
          },
        ),
        title: Text(
          'Mark as Done',
          style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.paleGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppColors.midGreen, size: 52),
              ),
              const SizedBox(height: 24),
              Text(
                'Complete This Exchange?',
                style: GoogleFonts.merriweather(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 12),
              Text(
                'Marking "${item?.title ?? 'this item'}" as completed moves it to your Transaction History and updates your campus circular impact stats.',
                textAlign: TextAlign.center,
                style: GoogleFonts.carlito(fontSize: 14, color: AppColors.mutedGray),
              ),
              const Spacer(),

              PrimaryButton(
                label: 'Confirm Completed Transaction',
                icon: Icons.done_all_rounded,
                onPressed: () {
                  if (item != null) {
                    db.markItemDone(item.id);
                    context.pushNamed(
                      RouteNames.completeTransaction,
                      extra: {
                        'requestId': 'req_${item.id}',
                        'itemTitle': item.title,
                        'itemType': item.type,
                        'itemPrice': item.price,
                        'buyerName': 'ADSSU Peer',
                        'sellerId': item.sellerId,
                      },
                    );
                  } else {
                    context.goNamed(RouteNames.myListings);
                  }
                },
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Cancel',
                isSecondary: true,
                onPressed: () {
                  context.goNamed(RouteNames.myListings);
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

