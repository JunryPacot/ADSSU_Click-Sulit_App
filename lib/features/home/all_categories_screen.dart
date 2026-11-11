import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/user_bottom_nav.dart';
import '../../data/mock/mock_database.dart';

class AllCategoriesScreen extends StatelessWidget {
  const AllCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final items = db.items.where((i) => i.status == 'active' && i.quantity > 0).toList();

    final categoriesData = [
      {
        'name': 'Books',
        'route': '/category/books',
        'icon': Icons.menu_book_rounded,
        'desc': 'Textbooks, course references, and review manuals',
        'count': items.where((i) => i.category == 'Books').length,
      },
      {
        'name': 'Uniforms',
        'route': '/category/uniforms',
        'icon': Icons.checkroom_rounded,
        'desc': 'College department polo, P.E. shirts, and lab gowns',
        'count': items.where((i) => i.category == 'Uniforms').length,
      },
      {
        'name': 'Gadgets',
        'route': '/category/gadgets',
        'icon': Icons.devices_rounded,
        'desc': 'Scientific calculators, mice, chargers, and tech tools',
        'count': items.where((i) => i.category == 'Gadgets').length,
      },
      {
        'name': 'School Supplies',
        'route': '/category/supplies',
        'icon': Icons.edit_note_rounded,
        'desc': 'Drafting boards, bond papers, markers, and rulers',
        'count': items.where((i) => i.category == 'School Supplies').length,
      },
      {
        'name': 'Other Reusable Goods',
        'route': '/category/others',
        'icon': Icons.recycling_rounded,
        'desc': 'Desk fans, dorm electric kettles, and campus lifestyle items',
        'count': items.where((i) => i.category == 'Other Reusable Goods').length,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('All Categories'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          itemCount: categoriesData.length,
          itemBuilder: (context, index) {
            final cat = categoriesData[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => context.push(cat['route'] as String),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Hex Badge Container
                        Container(
                          width: 52,
                          height: 52,
                          decoration: const BoxDecoration(
                            color: AppColors.paleGreen,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            cat['icon'] as IconData,
                            color: AppColors.primaryDarkGreen,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Title, desc, count
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      cat['name'] as String,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${cat['count']} items',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryDarkGreen,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                cat['desc'] as String,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.mutedGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.mutedGray,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const UserBottomNav(currentIndex: 1),
    );
  }
}
