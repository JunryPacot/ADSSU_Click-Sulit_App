import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/mock/mock_database.dart';

class DeleteListingScreen extends StatelessWidget {
  final String itemId;

  const DeleteListingScreen({super.key, required this.itemId});

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
          'Delete Listing',
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
                decoration: BoxDecoration(
                  color: AppColors.statusError.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_forever_rounded, color: AppColors.statusError, size: 48),
              ),
              const SizedBox(height: 24),
              Text(
                'Delete This Listing?',
                style: GoogleFonts.merriweather(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to remove "${item?.title ?? 'this item'}"? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: GoogleFonts.carlito(fontSize: 14, color: AppColors.mutedGray),
              ),
              const SizedBox(height: 20),
              if (item != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined, color: AppColors.mutedGray),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(),

              PrimaryButton(
                label: 'Yes, Delete Listing',
                icon: Icons.delete_rounded,
                onPressed: () {
                  db.deleteItem(itemId);
                  context.goNamed(RouteNames.myListings);
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

