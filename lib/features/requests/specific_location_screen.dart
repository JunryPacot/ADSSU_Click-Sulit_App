import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/campus_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/mock/mock_database.dart';

class SpecificLocationScreen extends StatefulWidget {
  final Map<String, dynamic>? extraData;

  const SpecificLocationScreen({super.key, this.extraData});

  @override
  State<SpecificLocationScreen> createState() => _SpecificLocationScreenState();
}

class _SpecificLocationScreenState extends State<SpecificLocationScreen> {
  late String _building;
  late TextEditingController _locationController;
  String? _photoName;
  String? _photoData;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _building = widget.extraData?['building'] ?? CampusConstants.meetUpBuildings.first;
    _locationController = TextEditingController(
      text: widget.extraData?['currentLocation'] ?? '',
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        setState(() {
          _photoData = base64String;
          _photoName = file.name;
        });
      }
    } catch (_) {}
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Attach Photo of Meet-Up Spot',
                style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.paleGreen,
                  child: Icon(Icons.photo_library_rounded, color: AppColors.primaryDarkGreen),
                ),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.paleGreen,
                  child: Icon(Icons.camera_alt_rounded, color: AppColors.primaryDarkGreen),
                ),
                title: const Text('Take Photo with Camera'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Specific Location Details',
          style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Meet-Up Building: $_building',
                style: GoogleFonts.merriweather(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryDarkGreen),
              ),
              const SizedBox(height: 12),
              Text(
                'Type Exact Location',
                style: GoogleFonts.merriweather(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _locationController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'e.g., East Wing staircase, 2nd floor, beside the bulletin board',
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

              Text(
                'Attach Real Photo of Spot',
                style: GoogleFonts.merriweather(fontSize: 13, fontWeight: FontWeight.bold),
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
                    if (_photoData != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: AppImage(
                          imageSource: _photoData,
                          width: 44,
                          height: 44,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Text(
                        _photoName ?? 'No photo attached',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: _photoName != null ? AppColors.textDark : AppColors.mutedGray,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _showImagePickerOptions,
                      icon: const Icon(Icons.photo_camera_outlined, size: 18, color: AppColors.midGreen),
                      label: Text(
                        _photoName != null ? 'Change' : 'Choose',
                        style: const TextStyle(color: AppColors.midGreen, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              PrimaryButton(
                label: 'Save Location',
                icon: Icons.save_rounded,
                onPressed: () {
                  db.setMeetUpDetails(
                    building: _building,
                    specificLocation: _locationController.text.trim(),
                    photoPath: _photoData,
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
