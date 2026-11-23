import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/item_model.dart';
import '../../data/mock/mock_database.dart';

/// Screen 6: Add / Edit Listing Screen
/// Fulfills Task 1 (Screen Development), Task 2 (Stack Navigation & Back button),
/// and Task 2 of Lab 2 (Local Storage CRUD: Create & Update persisted to SharedPreferences).
class AddEditItemScreen extends StatefulWidget {
  /// PARAMETER PASSING: If provided, the screen enters Edit mode (CRUD Update).
  /// If null, the screen enters Create mode (CRUD Create).
  final ItemModel? itemToEdit;

  const AddEditItemScreen({
    super.key,
    this.itemToEdit,
  });

  @override
  State<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _exchangeForController;

  String _category = 'Books';
  String _type = 'SELL';
  String _condition = 'Good';

  final List<String> _categories = [
    'Books',
    'Uniforms',
    'Gadgets',
    'School Supplies',
  ];

  final List<String> _types = [
    'SELL',
    'EXCHANGE',
    'DONATE',
  ];

  final List<String> _conditions = [
    'Brand New',
    'Like New',
    'Good',
    'Fair',
  ];

  @override
  void initState() {
    super.initState();
    // PARAMETER PASSING: Pre-populate fields if editing an existing item
    final item = widget.itemToEdit;
    _titleController = TextEditingController(text: item?.title ?? '');
    _descriptionController = TextEditingController(text: item?.description ?? '');
    _priceController = TextEditingController(
      text: item != null && item.price > 0 ? item.price.toStringAsFixed(2) : '',
    );
    _exchangeForController = TextEditingController(text: item?.exchangeFor ?? '');

    if (item != null) {
      _category = item.category;
      _type = item.type;
      _condition = item.condition;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _exchangeForController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    final db = context.read<MockDatabase>();
    final double price = _type == 'SELL' ? (double.tryParse(_priceController.text) ?? 0.0) : 0.0;

    if (widget.itemToEdit == null) {
      // ==================== CRUD 1: CREATE ====================
      // Creates new listing and saves to device SharedPreferences
      await db.addItem(
        title: _titleController.text,
        description: _descriptionController.text,
        price: price,
        category: _category,
        type: _type,
        condition: _condition,
        exchangeFor: _type == 'EXCHANGE' ? _exchangeForController.text : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item successfully posted and saved to SharedPreferences!'),
            backgroundColor: AppColors.primaryDarkGreen,
          ),
        );
        context.pop();
      }
    } else {
      // ==================== CRUD 2: UPDATE ====================
      // Updates existing listing in device SharedPreferences
      final updated = widget.itemToEdit!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: price,
        category: _category,
        type: _type,
        condition: _condition,
        exchangeFor: _type == 'EXCHANGE' ? _exchangeForController.text.trim() : null,
      );

      await db.updateItem(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item successfully updated in SharedPreferences!'),
            backgroundColor: AppColors.primaryDarkGreen,
          ),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.itemToEdit != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDarkGreen,
        foregroundColor: AppColors.cardWhite,
        title: Text(
          isEditing ? 'Edit Listing (CRUD Update)' : 'Post New Item (CRUD Create)',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Banner explaining CRUD
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.storage, size: 20, color: AppColors.textDark),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isEditing
                            ? 'TASK 2 (UPDATE): Modifying this record updates data in local SharedPreferences.'
                            : 'TASK 2 (CREATE): Submitting this form saves the record to local SharedPreferences.',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textDark),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Title Field
              const Text('Item Title *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a title' : null,
                decoration: InputDecoration(
                  hintText: 'e.g. Scientific Calculator fx-991ES',
                  filled: true,
                  fillColor: AppColors.cardWhite,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 14),

              // Listing Type Dropdown
              const Text('Listing Type *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _type,
                items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _type = val);
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.cardWhite,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 14),

              // Price Field (if type == SELL)
              if (_type == 'SELL') ...[
                const Text('Price (PHP ₱) *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (val) {
                    if (_type != 'SELL') return null;
                    if (val == null || val.trim().isEmpty) return 'Please enter price';
                    if (double.tryParse(val) == null) return 'Enter a valid number';
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixText: '₱ ',
                    hintText: '0.00',
                    filled: true,
                    fillColor: AppColors.cardWhite,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Exchange For Field (if type == EXCHANGE)
              if (_type == 'EXCHANGE') ...[
                const Text('Preferred Item in Exchange *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _exchangeForController,
                  validator: (val) => _type == 'EXCHANGE' && (val == null || val.trim().isEmpty) ? 'Please specify what you want' : null,
                  decoration: InputDecoration(
                    hintText: 'e.g. Engineering Drafting Board or Uniform',
                    filled: true,
                    fillColor: AppColors.cardWhite,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Category Dropdown
              const Text('Category *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _category,
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _category = val);
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.cardWhite,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 14),

              // Condition Dropdown
              const Text('Condition *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _condition,
                items: _conditions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _condition = val);
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.cardWhite,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 14),

              // Description Field
              const Text('Description *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter description' : null,
                decoration: InputDecoration(
                  hintText: 'Provide details on the item condition, subject usage, etc.',
                  filled: true,
                  fillColor: AppColors.cardWhite,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDarkGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.check_circle_outline, size: 20),
                  label: Text(
                    isEditing ? 'Save Changes (Update SharedPreferences)' : 'Post Item (Save to SharedPreferences)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  onPressed: _saveItem,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
