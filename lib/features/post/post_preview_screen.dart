import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/type_tag.dart';
import '../../data/mock/mock_database.dart';

class PostPreviewScreen extends StatefulWidget {
  final Map<String, dynamic>? extraData;

  const PostPreviewScreen({super.key, this.extraData});

  @override
  State<PostPreviewScreen> createState() => _PostPreviewScreenState();
}

class _PostPreviewScreenState extends State<PostPreviewScreen> {
  bool _isPosting = false;

  Future<void> _handlePost({
    required MockDatabase db,
    required String title,
    required String description,
    required double price,
    required String category,
    required String type,
    required String condition,
    String? exchangeFor,
    String? meetUpPreference,
    List<String> photos = const [],
    int quantity = 1,
  }) async {
    if (_isPosting) return;
    setState(() => _isPosting = true);

    try {
      await db.addItem(
        title: title,
        description: description,
        price: price,
        category: category,
        type: type,
        condition: condition,
        exchangeFor: exchangeFor,
        meetUpPreference: meetUpPreference,
        imageUrl: photos.isNotEmpty ? photos.first : null,
        images: photos,
        quantity: quantity,
      );

      if (!mounted) return;
      context.goNamed(RouteNames.postedSuccessfully, extra: {'itemTitle': title});
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPosting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to post item: $e'),
          backgroundColor: AppColors.statusError,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final extra = widget.extraData ?? {};
    final type = extra['type'] as String? ?? 'SELL';
    final title = extra['title'] as String? ?? 'Item Preview';
    final price = (extra['price'] is num) ? (extra['price'] as num).toDouble() : (double.tryParse(extra['price']?.toString() ?? '') ?? 0.0);
    final category = extra['category'] as String? ?? 'Books';
    final condition = extra['condition'] as String? ?? 'Used - Good';
    final description = extra['description'] as String? ?? '';
    final exchangeFor = extra['exchangeFor'] as String?;
    final meetUpPreference = extra['meetUpPreference'] as String? ?? 'CA Building';
    final quantity = (extra['quantity'] is num) ? (extra['quantity'] as num).toInt() : (int.tryParse(extra['quantity']?.toString() ?? '1') ?? 1);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Post Preview',
          style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo Area
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: AppImage(
                              imageSource: (extra['photos'] as List?)?.isNotEmpty == true
                                  ? (extra['photos'] as List).first.toString()
                                  : null,
                              borderRadius: 16,
                              fallbackIcon: Icons.image_outlined,
                            ),
                          ),
                          Positioned(
                            top: 12,
                            left: 12,
                            child: TypeTag(type: type),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Price & Title Card
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
                          if (type == 'SELL') ...[
                            Text(
                              '₱${price.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryDarkGreen),
                            ),
                          ] else if (type == 'EXCHANGE') ...[
                            Text(
                              'Exchange for: ${exchangeFor ?? 'Similar item'}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.midGreen),
                            ),
                          ] else ...[
                            const Text(
                              'FREE DONATION',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.accentGold),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Text(
                            title,
                            style: GoogleFonts.merriweather(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              Chip(
                                label: Text(category, style: const TextStyle(fontSize: 11)),
                                backgroundColor: AppColors.paleGreen,
                                padding: EdgeInsets.zero,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              Chip(
                                label: Text(condition, style: const TextStyle(fontSize: 11)),
                                backgroundColor: AppColors.background,
                                padding: EdgeInsets.zero,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description Card
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
                            'Description',
                            style: GoogleFonts.merriweather(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            description.isEmpty ? 'No description provided.' : description,
                            style: GoogleFonts.carlito(fontSize: 13, color: AppColors.textDark),
                          ),
                          const Divider(height: 20),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 16, color: AppColors.midGreen),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Meet-up: $meetUpPreference',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.cardWhite,
                boxShadow: [
                  BoxShadow(color: AppColors.shadowTint, blurRadius: 10, offset: Offset(0, -2)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: PrimaryButton(
                      label: 'Edit',
                      icon: Icons.edit_outlined,
                      isSecondary: true,
                      onPressed: _isPosting
                          ? () {}
                          : () {
                              context.pop();
                            },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: PrimaryButton(
                      label: _isPosting ? 'Posting...' : 'Post Item',
                      icon: _isPosting ? Icons.hourglass_top_rounded : Icons.check_circle_rounded,
                      onPressed: _isPosting
                          ? () {}
                          : () => _handlePost(
                                db: db,
                                title: title,
                                description: description,
                                price: price,
                                category: category,
                                type: type,
                                condition: condition,
                                exchangeFor: exchangeFor,
                                meetUpPreference: meetUpPreference,
                                photos: (extra['photos'] as List?)?.map((e) => e.toString()).toList() ?? const [],
                                quantity: quantity,
                              ),
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
}
