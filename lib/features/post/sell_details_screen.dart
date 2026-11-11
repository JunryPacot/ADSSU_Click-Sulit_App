import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/campus_constants.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';

class SellDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? extraData;

  const SellDetailsScreen({super.key, this.extraData});

  @override
  State<SellDetailsScreen> createState() => _SellDetailsScreenState();
}

class _SellDetailsScreenState extends State<SellDetailsScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(text: '1');
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
    _priceController.dispose();
    _descController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Sell Details',
          style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Title',
                style: GoogleFonts.merriweather(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _titleController,
                decoration: _inputDecoration('e.g., Calculus 8th Edition Early Transcendentals'),
              ),
              const SizedBox(height: 16),

              Text(
                'Price (₱)',
                style: GoogleFonts.merriweather(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: _inputDecoration('e.g., 250'),
              ),
              const SizedBox(height: 16),

              Text(
                'Available Quantity',
                style: GoogleFonts.merriweather(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('e.g., 5 (default 1)'),
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
                'Description',
                style: GoogleFonts.merriweather(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _descController,
                maxLines: 4,
                decoration: _inputDecoration('Describe condition, highlights, edition, etc.'),
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
                label: 'Preview Post',
                icon: Icons.preview_rounded,
                onPressed: () {
                  final cleanPriceText = _priceController.text.replaceAll('₱', '').replaceAll(',', '').trim(); final price = double.tryParse(cleanPriceText) ?? 100.0;
                  final title = _titleController.text.trim().isEmpty
                      ? 'Pre-loved Campus Item'
                      : _titleController.text.trim();
                  final desc = _descController.text.trim().isEmpty
                      ? 'In good pre-loved condition, ready for the next student.'
                      : _descController.text.trim();

                  final cleanQtyText = _quantityController.text.trim();
                  final quantity = int.tryParse(cleanQtyText) ?? 1;

                  final postData = {
                    'type': CampusConstants.typeSell,
                    'title': title,
                    'price': price,
                    'category': _category,
                    'condition': _condition,
                    'description': desc,
                    'meetUpPreference': _meetUpPreference,
                    'photos': widget.extraData?['photos'] ?? <String>[],
                    'quantity': quantity > 0 ? quantity : 1,
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


