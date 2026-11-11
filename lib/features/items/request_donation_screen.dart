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

class RequestDonationScreen extends StatefulWidget {
  final String itemId;

  const RequestDonationScreen({super.key, required this.itemId});

  @override
  State<RequestDonationScreen> createState() => _RequestDonationScreenState();
}

class _RequestDonationScreenState extends State<RequestDonationScreen> {
  late String _selectedBuilding;
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
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
    _noteController.dispose();
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
    final item = db.getItemById(widget.itemId);

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Item Not Found')),
        body: const Center(child: Text('Item does not exist.')),
      );
    }

    if (item.sellerId == db.currentUser.id) {
      return Scaffold(
        appBar: AppBar(title: const Text('Your Listing')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.volunteer_activism_rounded, size: 52, color: AppColors.accentGold),
                const SizedBox(height: 16),
                const Text(
                  'You listed this item for donation. You cannot request your own donation item.',
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Request Donation',
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
                    // Item Card Preview
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
                              imageSource: item.imageUrl ?? (item.images.isNotEmpty ? item.images.first : null),
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'FREE DONATION',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accentGold,
                                  ),
                                ),
                                Text(
                                  'Donated by: ${item.sellerName}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11, color: AppColors.mutedGray),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Note to Donor
                    Text(
                      'Short Note to Donor (Optional)',
                      style: GoogleFonts.merriweather(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _noteController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'e.g., Thank you so much! I am a 1st year student who really needs this.',
                        hintStyle: const TextStyle(fontSize: 12, color: AppColors.mutedGray),
                        filled: true,
                        fillColor: AppColors.cardWhite,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.borderLight),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Meet-Up Preferences Section
                    Text(
                      'Preferred Meet-Up Building',
                      style: GoogleFonts.merriweather(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Select where you can conveniently receive the item.',
                      style: GoogleFonts.carlito(fontSize: 13, color: AppColors.mutedGray),
                    ),
                    const SizedBox(height: 12),

                    // Building Dropdown
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

                    // Exact Location Field
                    Text(
                      'Specific Location (Optional)',
                      style: GoogleFonts.merriweather(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Main lobby or security guard desk',
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
                label: 'Send Donation Request',
                icon: Icons.volunteer_activism_rounded,
                isAccent: true,
                onPressed: () {
                  db.setMeetUpDetails(
                    building: _selectedBuilding,
                    specificLocation: _locationController.text.trim(),
                    photoPath: _pickedPhotoPath,
                  );
                  db.createRequest(item: item);
                  context.goNamed(
                    RouteNames.donationRequestSent,
                    extra: {'itemTitle': item.title, 'sellerId': item.sellerId},
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

