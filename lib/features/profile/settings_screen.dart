import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/campus_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifyRequests = true;
  bool _notifyMessages = true;
  bool _notifyBoosts = false;
  String _preferredBuilding = CampusConstants.meetUpBuildings.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications',
                style: GoogleFonts.merriweather(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryDarkGreen),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.cardShadow,
                ),
                clipBehavior: Clip.antiAlias,
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      SwitchListTile(
                        activeThumbColor: AppColors.primaryDarkGreen,
                        title: const Text('Trade and Buy Requests', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Notify when someone sends an offer', style: TextStyle(fontSize: 11, color: AppColors.mutedGray)),
                        value: _notifyRequests,
                        onChanged: (val) => setState(() => _notifyRequests = val),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        activeThumbColor: AppColors.primaryDarkGreen,
                        title: const Text('Chat Messages', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Notify when receiving new messages', style: TextStyle(fontSize: 11, color: AppColors.mutedGray)),
                        value: _notifyMessages,
                        onChanged: (val) => setState(() => _notifyMessages = val),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        activeThumbColor: AppColors.primaryDarkGreen,
                        title: const Text('Promotions & Featured Tips', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Tips on how to boost listing reach', style: TextStyle(fontSize: 11, color: AppColors.mutedGray)),
                        value: _notifyBoosts,
                        onChanged: (val) => setState(() => _notifyBoosts = val),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Campus Exchange Preferences',
                style: GoogleFonts.merriweather(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryDarkGreen),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Default Campus Meet-Up Location',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Preselected when sending or responding to meet-up requests.',
                      style: TextStyle(fontSize: 11, color: AppColors.mutedGray),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _preferredBuilding,
                          items: CampusConstants.meetUpBuildings.map((b) {
                            return DropdownMenuItem<String>(
                              value: b,
                              child: Text(b, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _preferredBuilding = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // DTC Notice
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightMint,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.midGreen.withAlpha(50)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shield_outlined, size: 20, color: AppColors.primaryDarkGreen),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Account Managed by ADSSU DTC',
                            style: GoogleFonts.carlito(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryDarkGreen),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Institutional email accounts, passwords, and identity credentials are authenticated and managed by the Agusan del Sur State University Digital Transformation Center.',
                      style: TextStyle(fontSize: 12, color: AppColors.textDark, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
