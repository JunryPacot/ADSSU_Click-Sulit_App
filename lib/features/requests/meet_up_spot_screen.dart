import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/campus_constants.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/mock/mock_database.dart';

class MeetUpSpotScreen extends StatefulWidget {
  final Map<String, dynamic>? extraData;

  const MeetUpSpotScreen({super.key, this.extraData});

  @override
  State<MeetUpSpotScreen> createState() => _MeetUpSpotScreenState();
}

class _MeetUpSpotScreenState extends State<MeetUpSpotScreen> {
  late String _selectedBuilding;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    final prefBuilding = widget.extraData?['meetUpBuilding'] as String?;
    _selectedBuilding = (prefBuilding != null && CampusConstants.meetUpBuildings.contains(prefBuilding))
        ? prefBuilding
        : CampusConstants.meetUpBuildings.first;

    _locationController = TextEditingController(
      text: widget.extraData?['exactLocation'] as String? ?? '',
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final extra = widget.extraData ?? {};
    final itemTitle = extra['itemTitle'] ?? 'Deal Meet-Up';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Confirm Meet-Up Spot',
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
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.handshake_rounded, color: AppColors.midGreen, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  itemTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.merriweather(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Agree on a designated campus location for the handoff.',
                            style: GoogleFonts.carlito(fontSize: 13, color: AppColors.mutedGray),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Designated Meet-Up Building',
                      style: GoogleFonts.merriweather(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

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

                    Text(
                      'Specific Location Description',
                      style: GoogleFonts.merriweather(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Near Dean\'s office entrance',
                        hintStyle: const TextStyle(fontSize: 12, color: AppColors.mutedGray),
                        filled: true,
                        fillColor: AppColors.cardWhite,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.borderLight),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Custom specific location button (Screen 82)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          context.pushNamed(
                            RouteNames.specificLocation,
                            extra: {
                              'building': _selectedBuilding,
                              'currentLocation': _locationController.text,
                            },
                          );
                        },
                        icon: const Icon(Icons.add_location_alt_outlined, size: 16, color: AppColors.midGreen),
                        label: const Text(
                          'Specify Other Details / Photo',
                          style: TextStyle(color: AppColors.midGreen, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Confirm Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.cardWhite,
                boxShadow: [
                  BoxShadow(color: AppColors.shadowTint, blurRadius: 10, offset: Offset(0, -2)),
                ],
              ),
              child: PrimaryButton(
                label: 'Confirm Meet-Up',
                icon: Icons.check_circle_outline_rounded,
                onPressed: () {
                  db.setMeetUpDetails(
                    building: _selectedBuilding,
                    specificLocation: _locationController.text.trim(),
                  );
                  final confirmedExtra = Map<String, dynamic>.from(extra);
                  confirmedExtra['meetUpBuilding'] = _selectedBuilding;
                  confirmedExtra['exactLocation'] = _locationController.text.trim();

                  context.goNamed(
                    RouteNames.meetUpConfirmed,
                    extra: confirmedExtra,
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

