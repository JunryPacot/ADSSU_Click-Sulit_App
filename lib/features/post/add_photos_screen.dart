import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/campus_constants.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/primary_button.dart';

class AddPhotosScreen extends StatefulWidget {
  final Map<String, dynamic>? extraData;

  const AddPhotosScreen({super.key, this.extraData});

  @override
  State<AddPhotosScreen> createState() => _AddPhotosScreenState();
}

class _AddPhotosScreenState extends State<AddPhotosScreen> {
  final List<String> _photos = [];
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      setState(() => _isProcessing = true);
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
          _photos.add(base64String);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load photo: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showImageSourceDialog() {
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
                'Upload Item Photo',
                style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.paleGreen,
                  child: Icon(Icons.photo_library_rounded, color: AppColors.primaryDarkGreen),
                ),
                title: const Text('Choose from Gallery'),
                subtitle: const Text('Select a pre-existing photo of your item'),
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
                title: const Text('Take a Photo with Camera'),
                subtitle: const Text('Capture the current condition right now'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickPhoto(ImageSource.camera);
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
    final type = widget.extraData?['type'] ?? CampusConstants.typeSell;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Add Photos',
          style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Showcase Your Item',
                style: GoogleFonts.merriweather(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 6),
              Text(
                'Add actual photos of the item taken in good lighting so buyers can inspect its condition.',
                style: GoogleFonts.carlito(fontSize: 13, color: AppColors.mutedGray),
              ),
              const SizedBox(height: 20),

              // Photo Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _photos.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _photos.length) {
                      return InkWell(
                        onTap: _isProcessing ? null : _showImageSourceDialog,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.cardWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.midGreen, width: 1.5),
                          ),
                          child: Center(
                            child: _isProcessing
                                ? const CircularProgressIndicator(color: AppColors.primaryDarkGreen)
                                : const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo_outlined, size: 36, color: AppColors.midGreen),
                                      SizedBox(height: 8),
                                      Text(
                                        'Add Photo',
                                        style: TextStyle(color: AppColors.midGreen, fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      );
                    }

                    final photo = _photos[index];

                    return Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: AppImage(
                            imageSource: photo,
                            borderRadius: 16,
                            fallbackIcon: Icons.image_outlined,
                          ),
                        ),
                        if (index == 0)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryDarkGreen,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'COVER PHOTO',
                                style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.close, color: Colors.white, size: 14),
                              onPressed: () {
                                setState(() {
                                  _photos.removeAt(index);
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              PrimaryButton(
                label: 'Next: Item Details',
                icon: Icons.arrow_forward_rounded,
                onPressed: () {
                  if (_photos.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please upload at least one real photo of your item before proceeding.'),
                        backgroundColor: AppColors.statusError,
                        duration: Duration(seconds: 3),
                      ),
                    );
                    return;
                  }
                  final data = {
                    'type': type,
                    'photos': _photos,
                  };
                  if (type == CampusConstants.typeSell) {
                    context.pushNamed(RouteNames.sellDetails, extra: data);
                  } else if (type == CampusConstants.typeExchange) {
                    context.pushNamed(RouteNames.exchangeDetails, extra: data);
                  } else {
                    context.pushNamed(RouteNames.donateDetails, extra: data);
                  }
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
