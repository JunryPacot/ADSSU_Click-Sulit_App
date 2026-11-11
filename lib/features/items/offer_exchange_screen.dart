import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/campus_constants.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/mock/mock_database.dart';
import '../../data/models/item_model.dart';

class OfferExchangeScreen extends StatefulWidget {
  final String itemId;

  const OfferExchangeScreen({super.key, required this.itemId});

  @override
  State<OfferExchangeScreen> createState() => _OfferExchangeScreenState();
}

class _OfferExchangeScreenState extends State<OfferExchangeScreen> {
  ItemModel? _selectedOfferItem;
  late String _selectedBuilding;
  final TextEditingController _locationController = TextEditingController();
  String? _pickedPhotoName;
  String? _pickedPhotoPath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _selectedBuilding = CampusConstants.meetUpBuildings.first;
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        setState(() {
          _pickedPhotoPath = file.path;
          _pickedPhotoName = file.name;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final targetItem = db.getItemById(widget.itemId);

    if (targetItem == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Item Not Found')),
        body: const Center(child: Text('Target item does not exist.')),
      );
    }

    if (targetItem.sellerId == db.currentUser.id) {
      return Scaffold(
        appBar: AppBar(title: const Text('Your Listing')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.swap_horiz_rounded, size: 52, color: AppColors.midGreen),
                const SizedBox(height: 16),
                const Text(
                  'You listed this item. You cannot offer an exchange for your own listing.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.textDark),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDarkGreen,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => context.pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final myExchangeItems = db.items
        .where((i) => i.sellerId == db.currentUser.id && i.status == 'active')
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Offer an Exchange',
          style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Target Item Card
                    Text(
                      'Item You Want',
                      style: GoogleFonts.merriweather(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: AppImage(
                              imageSource: targetItem.imageUrl ?? (targetItem.images.isNotEmpty ? targetItem.images.first : null),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  targetItem.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                if (targetItem.exchangeFor != null) ...[
                                  Text(
                                    'Wants: ${targetItem.exchangeFor}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 11, color: AppColors.midGreen),
                                  ),
                                ],
                                Text(
                                  'Owner: ${targetItem.sellerName}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.mutedGray),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Choose My Item
                    Text(
                      'Choose Item You are Offering',
                      style: GoogleFonts.merriweather(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (myExchangeItems.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'You have no active listings available to offer for exchange.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13, color: AppColors.mutedGray),
                            ),
                            const SizedBox(height: 12),
                            PrimaryButton(
                              label: 'Post an Item First',
                              icon: Icons.add_circle_outline,
                              onPressed: () {
                                context.pushNamed(RouteNames.postChooseType);
                              },
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: myExchangeItems.map((item) {
                          final isSelected = _selectedOfferItem?.id == item.id;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedOfferItem = item;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.lightMint : AppColors.cardWhite,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppColors.midGreen : AppColors.borderLight,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                    color: isSelected ? AppColors.midGreen : AppColors.mutedGray,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    item.condition,
                                    style: const TextStyle(fontSize: 11, color: AppColors.mutedGray),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 20),

                    // Meet-Up Preferences Section
                    Text(
                      'Preferred Meet-Up Building',
                      style: GoogleFonts.merriweather(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedBuilding,
                          items: CampusConstants.meetUpBuildings.map((b) {
                            return DropdownMenuItem<String>(
                              value: b,
                              child: Text(
                                b,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedBuilding = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Specific Location
                    Text(
                      'Specific Location (Optional)',
                      style: GoogleFonts.merriweather(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Bench outside Library entrance',
                        hintStyle: const TextStyle(fontSize: 12, color: AppColors.mutedGray),
                        filled: true,
                        fillColor: AppColors.cardWhite,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.borderLight),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Photo Attachment Area
                    Text(
                      'Location Photo (Optional)',
                      style: GoogleFonts.merriweather(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _pickedPhotoName ?? 'No photo attached',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: _pickedPhotoName != null ? AppColors.textDark : AppColors.mutedGray,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.add_a_photo_outlined, size: 18, color: AppColors.midGreen),
                            label: Text(
                              _pickedPhotoName != null ? 'Change' : 'Attach',
                              style: const TextStyle(color: AppColors.midGreen, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Submit Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.cardWhite,
                boxShadow: [
                  BoxShadow(color: AppColors.shadowTint, blurRadius: 10, offset: Offset(0, -2)),
                ],
              ),
              child: PrimaryButton(
                label: 'Send Exchange Offer',
                icon: Icons.swap_horiz_rounded,
                onPressed: _selectedOfferItem != null
                    ? () {
                        db.setMeetUpDetails(
                          building: _selectedBuilding,
                          specificLocation: _locationController.text.trim(),
                          photoPath: _pickedPhotoPath,
                        );
                        db.createRequest(
                          item: targetItem,
                          offeredItemId: _selectedOfferItem!.id,
                          offeredItemTitle: _selectedOfferItem!.title,
                        );
                        context.goNamed(
                          RouteNames.exchangeOfferSent,
                          extra: {'itemTitle': targetItem.title, 'sellerId': targetItem.sellerId},
                        );
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

