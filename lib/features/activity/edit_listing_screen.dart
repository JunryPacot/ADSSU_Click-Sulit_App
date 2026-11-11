import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/campus_constants.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/mock/mock_database.dart';
import '../../data/models/item_model.dart';

class EditListingScreen extends StatefulWidget {
  final String itemId;

  const EditListingScreen({super.key, required this.itemId});

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  ItemModel? _item;

  @override
  void initState() {
    super.initState();
    final db = Provider.of<MockDatabase>(context, listen: false);
    _item = db.getItemById(widget.itemId);
    _titleController = TextEditingController(text: _item?.title ?? '');
    _priceController = TextEditingController(text: _item?.price.toStringAsFixed(0) ?? '0');
    _descController = TextEditingController(text: _item?.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final item = _item;

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Listing')),
        body: const Center(child: Text('Listing not found.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Edit Listing',
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
                decoration: _inputDecoration(),
              ),
              const SizedBox(height: 16),

              if (item.type == CampusConstants.typeSell) ...[
                Text(
                  'Price (₱)',
                  style: GoogleFonts.merriweather(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(),
                ),
                const SizedBox(height: 16),
              ],

              Text(
                'Description',
                style: GoogleFonts.merriweather(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _descController,
                maxLines: 4,
                decoration: _inputDecoration(),
              ),
              const SizedBox(height: 32),

              PrimaryButton(
                label: 'Save Changes',
                icon: Icons.save_rounded,
                onPressed: () {
                  final newPrice = double.tryParse(_priceController.text) ?? item.price;
                  final updated = item.copyWith(
                    title: _titleController.text.trim(),
                    price: newPrice,
                    description: _descController.text.trim(),
                  );
                  db.updateItem(updated);
                  context.goNamed(RouteNames.myListings);
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

