import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/campus_constants.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/mock/mock_database.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late String _selectedCollege;
  String? _profilePhoto;
  final ImagePicker _picker = ImagePicker();
  bool _isPickingPhoto = false;

  @override
  void initState() {
    super.initState();
    final db = Provider.of<MockDatabase>(context, listen: false);
    _nameController = TextEditingController(text: db.currentUser.name);
    _bioController = TextEditingController(text: db.currentUser.bio);
    _selectedCollege = CampusConstants.colleges.contains(db.currentUser.college)
        ? db.currentUser.college
        : CampusConstants.colleges.first;
    _profilePhoto = db.currentUser.profilePhoto;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      setState(() => _isPickingPhoto = true);
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        setState(() {
          _profilePhoto = base64String;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update profile photo: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingPhoto = false);
      }
    }
  }

  void _showPhotoOptions() {
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
                'Change Profile Photo',
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
                  _pickPhoto(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.paleGreen,
                  child: Icon(Icons.camera_alt_rounded, color: AppColors.primaryDarkGreen),
                ),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickPhoto(ImageSource.camera);
                },
              ),
              if (_profilePhoto != null && _profilePhoto!.isNotEmpty)
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.redAccent,
                    child: Icon(Icons.delete_outline_rounded, color: Colors.white),
                  ),
                  title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _profilePhoto = '');
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
    final user = db.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Photo Customization
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    InkWell(
                      onTap: _isPickingPhoto ? null : _showPhotoOptions,
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryDarkGreen, width: 2.5),
                        ),
                        child: ClipOval(
                          child: _isPickingPhoto
                              ? const Center(
                                  child: SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primaryDarkGreen),
                                  ),
                                )
                              : (_profilePhoto != null && _profilePhoto!.isNotEmpty
                                  ? AppImage(
                                      imageSource: _profilePhoto,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      fallbackIcon: Icons.person_rounded,
                                    )
                                  : Container(
                                      color: AppColors.paleGreen,
                                      child: Center(
                                        child: Text(
                                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                          style: const TextStyle(
                                            color: AppColors.primaryDarkGreen,
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )),
                        ),
                      ),
                    ),
                    PositionButton(onTap: _isPickingPhoto ? null : _showPhotoOptions),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: _isPickingPhoto ? null : _showPhotoOptions,
                  icon: const Icon(Icons.camera_alt_outlined, size: 16, color: AppColors.primaryDarkGreen),
                  label: const Text(
                    'Change Profile Picture',
                    style: TextStyle(
                      color: AppColors.primaryDarkGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Full Name',
                style: GoogleFonts.merriweather(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                decoration: _inputDecoration(),
              ),
              const SizedBox(height: 16),

              Text(
                'Institutional Email (Locked)',
                style: GoogleFonts.merriweather(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextField(
                enabled: false,
                controller: TextEditingController(text: user.email),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black.withAlpha(10),
                  suffixIcon: const Icon(Icons.lock_outline, size: 18, color: AppColors.mutedGray),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Managed by ADSSU Digital Transformation Center (DTC).',
                style: TextStyle(fontSize: 11, color: AppColors.mutedGray),
              ),
              const SizedBox(height: 16),

              Text(
                'College Affiliation',
                style: GoogleFonts.merriweather(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
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
                    value: _selectedCollege,
                    items: CampusConstants.colleges.map((c) {
                      return DropdownMenuItem<String>(
                        value: c,
                        child: Text(c, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCollege = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Bio / Academic Year',
                style: GoogleFonts.merriweather(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _bioController,
                maxLines: 3,
                decoration: _inputDecoration(),
              ),
              const SizedBox(height: 32),

              PrimaryButton(
                label: 'Save Changes',
                icon: Icons.save_rounded,
                onPressed: () {
                  db.updateProfile(
                    name: _nameController.text.trim(),
                    bio: _bioController.text.trim(),
                    college: _selectedCollege,
                    profilePhoto: _profilePhoto,
                  );
                  context.goNamed(RouteNames.profile);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.cardWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
    );
  }
}

class PositionButton extends StatelessWidget {
  final VoidCallback? onTap;
  const PositionButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: AppColors.primaryDarkGreen,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Icon(
          Icons.camera_alt_rounded,
          size: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}

