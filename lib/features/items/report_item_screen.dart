import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/mock/mock_database.dart';

class ReportItemScreen extends StatefulWidget {
  final String itemId;

  const ReportItemScreen({super.key, required this.itemId});

  @override
  State<ReportItemScreen> createState() => _ReportItemScreenState();
}

class _ReportItemScreenState extends State<ReportItemScreen> {
  String? _selectedReason;
  final TextEditingController _detailsController = TextEditingController();

  final List<String> _reasons = [
    'Prohibited item / contraband',
    'Suspicious pricing or scam attempt',
    'Incorrect category or description',
    'Offensive or inappropriate content',
    'Duplicate or spam listing',
    'Other concern',
  ];

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
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

    final isValid = _selectedReason != null && _detailsController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Report Listing',
          style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.paleGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.report_problem_outlined, color: AppColors.statusError),
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
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            'Seller: ${item.sellerName} (${item.sellerCollege})',
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

              Text(
                'Why are you reporting this item?',
                style: GoogleFonts.merriweather(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Please select the reason that best describes the issue. Reports are reviewed by ADSSU moderators.',
                style: GoogleFonts.carlito(fontSize: 13, color: AppColors.mutedGray),
              ),
              const SizedBox(height: 16),

              // Reason Dropdown
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
                    value: _selectedReason,
                    hint: const Text('Select a reason', style: TextStyle(color: AppColors.mutedGray, fontSize: 13)),
                    items: _reasons.map((r) {
                      return DropdownMenuItem<String>(
                        value: r,
                        child: Text(r, style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedReason = val;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Additional Details',
                style: GoogleFonts.merriweather(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _detailsController,
                maxLines: 4,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Provide more context to help us review this report...',
                  hintStyle: const TextStyle(fontSize: 13, color: AppColors.mutedGray),
                  filled: true,
                  fillColor: AppColors.cardWhite,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              PrimaryButton(
                label: 'Submit Report',
                icon: Icons.send_rounded,
                onPressed: isValid
                    ? () {
                        db.addReport(
                          itemId: item.id,
                          itemTitle: item.title,
                          sellerId: item.sellerId,
                          sellerName: item.sellerName,
                          reason: _selectedReason!,
                          details: _detailsController.text.trim(),
                        );
                        context.goNamed(RouteNames.reportSent);
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

