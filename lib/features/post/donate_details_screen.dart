import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/campus_constants.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';

class DonateDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? extraData;

  const DonateDetailsScreen({super.key, this.extraData});

  @override
  State<DonateDetailsScreen> createState() => _DonateDetailsScreenState();
}

class _DonateDetailsScreenState extends State<DonateDetailsScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  late String _category;
  String _condition = 'Used - Good';
  late String _meetUpPreference;

  final List<String> _conditions = [
    'Brand New',
    'Like New',
    'Used - Good',
    'Used - Fair',
  ];

  @override
  void initState() {
    super.initState();
    _category = CampusConstants.categories.first;
    _meetUpPreference = CampusConstants.meetUpBuildings.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Donation Details',
          style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.lightMint,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.midGreen.withAlpha(40)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.volunteer_activism_rounded, color: AppColors.midGreen, size: 24),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Donations are 100% free. You are helping promote circularity and peer support at ADSSU!',
                        style: TextStyle(color: AppColors.primaryDarkGreen, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              Text(
                'Item Title',
                style: GoogleFonts.merriweather(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _titleController,
                decoration: _inputDecoration('e.g., Short Bond Paper half ream (approx 250 sheets)'),
              ),
              const SizedBox(height: 16),

              Text(
                'Category',
                style: GoogleFonts.merriweather(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              _buildDropdown(
                value: _category,
                items: CampusConstants.categories,
                onChanged: (val) => setState(() => _category = val!),
              ),
              const SizedBox(height: 16),

              Text(
                'Condition',
                style: GoogleFonts.merriweather(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              _buildDropdown(
                value: _condition,
                items: _conditions,
                onChanged: (val) => setState(() => _condition = val!),
              ),
              const SizedBox(height: 16),

              Text(
                'Description & Pickup Note',
                style: GoogleFonts.merriweather(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _descController,
                maxLines: 4,
                decoration: _inputDecoration('Mention who might need this or special pickup instructions.'),
              ),
              const SizedBox(height: 16),

              Text(
                'Preferred Campus Meet-Up',
                style: GoogleFonts.merriweather(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              _buildDropdown(
                value: _meetUpPreference,
                items: CampusConstants.meetUpBuildings,
                onChanged: (val) => setState(() => _meetUpPreference = val!),
              ),
              const SizedBox(height: 28),

              PrimaryButton(
                label: 'Preview Donation Post',
                icon: Icons.preview_rounded,
                isAccent: true,
                onPressed: () {
                  final title = _titleController.text.trim().isEmpty
                      ? 'Free Donated Academic Supplies'
                      : _titleController.text.trim();
                  final desc = _descController.text.trim().isEmpty
                      ? 'Free to any student in need. Please pick up at the designated meet-up spot.'
                      : _descController.text.trim();

                  final postData = {
                    'type': CampusConstants.typeDonate,
                    'title': title,
                    'price': 0.0,
                    'category': _category,
                    'condition': _condition,
                    'description': desc,
                    'meetUpPreference': _meetUpPreference,
                    'photos': widget.extraData?['photos'] ?? <String>[],
                  };

                  context.pushNamed(RouteNames.postPreview, extra: postData);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: AppColors.mutedGray),
      filled: true,
      fillColor: AppColors.cardWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          items: items.map((i) {
            return DropdownMenuItem<String>(
              value: i,
              child: Text(i, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

