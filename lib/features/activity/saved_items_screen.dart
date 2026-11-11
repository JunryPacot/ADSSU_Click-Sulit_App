import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/item_card.dart';
import '../../data/mock/mock_database.dart';

class SavedItemsScreen extends StatelessWidget {
  const SavedItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final savedItems = db.items.where((i) => i.isSaved).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Saved Items (${savedItems.length})',
          style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: savedItems.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.favorite_border_rounded, size: 54, color: AppColors.mutedGray),
                    const SizedBox(height: 12),
                    const Text('No saved items yet.', style: TextStyle(color: AppColors.mutedGray)),
                    const SizedBox(height: 6),
                    const Text('Tap the heart icon on any item card to bookmark it.', style: TextStyle(fontSize: 12, color: AppColors.mutedGray)),
                  ],
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: savedItems.length,
                itemBuilder: (context, index) {
                  return ItemCard(item: savedItems[index]);
                },
              ),
      ),
    );
  }
}

