import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/type_tag.dart';
import '../../data/mock/mock_database.dart';

class ManageListingsScreen extends StatelessWidget {
  const ManageListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final items = db.items;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Manage Campus Listings (${items.length})',
          style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: items.isEmpty
            ? const Center(child: Text('No active listings found.'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = items[index];

                  return Container(
                    padding: const EdgeInsets.all(14),
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
                            TypeTag(type: item.type, isCompact: true),
                            Text(
                              item.type == 'SELL'
                                  ? '₱${item.price.toStringAsFixed(2)}'
                                  : item.type == 'EXCHANGE'
                                      ? 'For Trade'
                                      : 'Donation',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryDarkGreen),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.title,
                          style: GoogleFonts.merriweather(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Seller: ${item.sellerName} (${item.sellerCollege})',
                          style: const TextStyle(fontSize: 11, color: AppColors.mutedGray),
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                if (item.type == 'SELL') {
                                  context.pushNamed(RouteNames.itemDetailSell, pathParameters: {'id': item.id});
                                } else if (item.type == 'EXCHANGE') {
                                  context.pushNamed(RouteNames.itemDetailExchange, pathParameters: {'id': item.id});
                                } else {
                                  context.pushNamed(RouteNames.itemDetailDonate, pathParameters: {'id': item.id});
                                }
                              },
                              icon: const Icon(Icons.visibility_outlined, size: 16, color: AppColors.primaryDarkGreen),
                              label: const Text('View', style: TextStyle(color: AppColors.primaryDarkGreen, fontSize: 12)),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () {
                                db.deleteItem(item.id);
                              },
                              icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.statusError),
                              label: const Text('Remove', style: TextStyle(color: AppColors.statusError, fontSize: 12)),
                            ),
                          ],
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

