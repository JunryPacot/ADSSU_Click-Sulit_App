import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/qr_download_helper.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/mock/mock_database.dart';

class MembershipPaymentScreen extends StatefulWidget {
  const MembershipPaymentScreen({super.key});

  @override
  State<MembershipPaymentScreen> createState() => _MembershipPaymentScreenState();
}

class _MembershipPaymentScreenState extends State<MembershipPaymentScreen> {
  final TextEditingController _refController = TextEditingController();
  String? _screenshotName;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _refController.dispose();
    super.dispose();
  }

  Future<void> _pickReceipt() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        setState(() {
          _screenshotName = file.name;
        });
      }
    } catch (_) {}
  }

  Future<void> _openGCashApp() async {
    final gcashUri = Uri.parse('gcash://');
    final playStoreUri = Uri.parse('https://play.google.com/store/apps/details?id=com.globe.gcash.android');
    try {
      final canLaunch = await canLaunchUrl(gcashUri);
      if (canLaunch) {
        await launchUrl(gcashUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      try {
        await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open GCash: $e')),
          );
        }
      }
    }
  }

  Future<void> _downloadQr() async {
    const assetPath = 'assets/images/gcash_membership_qr.png';
    const fileName = 'gcash_membership_qr.png';
    final savedPath = await QrDownloadHelper.downloadQrImage(
      assetPath: assetPath,
      fileName: fileName,
    );
    if (!mounted) return;
    if (savedPath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('QR Code saved successfully to device!\n$savedPath'),
          backgroundColor: AppColors.midGreen,
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not download QR code to this device.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showFullScreenQr() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF007DFE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'GCash / InstaPay QR',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              InteractiveViewer(
                minScale: 1.0,
                maxScale: 3.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/gcash_membership_qr.png',
                    width: 280,
                    height: 280,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Amount: ₱50.00',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF007DFE)),
              ),
              const SizedBox(height: 4),
              const Text(
                'Scan or upload this QR code in your GCash app to pay the seller verification fee.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.mutedGray),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007DFE),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _openGCashApp();
                },
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text('Open GCash App to Pay', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF007DFE),
                  side: const BorderSide(color: Color(0xFF007DFE)),
                  minimumSize: const Size(double.infinity, 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _downloadQr();
                },
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Download QR Code', style: TextStyle(fontWeight: FontWeight.bold)),
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
          'GCash Payment',
          style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // GCash QR Code Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF005CE6), Color(0xFF007DFE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(40),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'GCash / InstaPay',
                            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(40),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'OFFICIAL QR',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // QR Code Display Card
                    GestureDetector(
                      onTap: _showFullScreenQr,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(40),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/images/gcash_membership_qr.png',
                                width: 200,
                                height: 200,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.zoom_in_rounded, size: 15, color: Color(0xFF007DFE)),
                                SizedBox(width: 4),
                                Text(
                                  'Tap to view / expand QR',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF007DFE)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Amount badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(40),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Amount to Pay: ₱50.00',
                        style: TextStyle(color: AppColors.accentGold, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // QR Action Buttons
                    Column(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF005CE6),
                            minimumSize: const Size(double.infinity, 42),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: _openGCashApp,
                          icon: const Icon(Icons.open_in_new_rounded, size: 18),
                          label: const Text('Open GCash App to Pay', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white70),
                                  minimumSize: const Size(0, 38),
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: _downloadQr,
                                icon: const Icon(Icons.download_rounded, size: 16),
                                label: const Text('Download QR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white70),
                                  minimumSize: const Size(0, 38),
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: _showFullScreenQr,
                                icon: const Icon(Icons.visibility_outlined, size: 16),
                                label: const Text('View / Expand', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Payment Reference Number',
                style: GoogleFonts.merriweather(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _refController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter 12 or 13-digit GCash Reference Number',
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
                'Upload Payment Screenshot',
                style: GoogleFonts.merriweather(fontSize: 14, fontWeight: FontWeight.bold),
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
                    Expanded(
                      child: Text(
                        _screenshotName ?? 'receipt_screenshot.png',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, color: AppColors.textDark),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _pickReceipt,
                      icon: const Icon(Icons.upload_file, size: 18, color: AppColors.midGreen),
                      label: const Text(
                        'Upload',
                        style: TextStyle(color: AppColors.midGreen, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              PrimaryButton(
                label: 'Submit Payment Verification',
                icon: Icons.check_circle_rounded,
                onPressed: () {
                  final ref = _refController.text.trim();
                  if (ref.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter your GCash reference number.')),
                    );
                    return;
                  }
                  db.submitSellerMembershipPayment(ref);
                  context.goNamed(RouteNames.membershipPending);
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

