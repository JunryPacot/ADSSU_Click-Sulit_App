import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/campus_constants.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/qr_download_helper.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/mock/mock_database.dart';

class BoostPaymentScreen extends StatefulWidget {
  final Map<String, dynamic>? extraData;

  const BoostPaymentScreen({super.key, this.extraData});

  @override
  State<BoostPaymentScreen> createState() => _BoostPaymentScreenState();
}

class _BoostPaymentScreenState extends State<BoostPaymentScreen> {
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

  Future<void> _openPaymentApp(double price) async {
    // For ₱10 and ₱25 (InstaPay), open GCash as the common sender app
    // For ₱50 (GCash QR), open GCash directly
    final gcashUri = Uri.parse('gcash://');
    final playStoreUri = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.globe.gcash.android');
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

  Future<void> _downloadQr(String qrAsset, double price) async {
    final fileName = 'booster_qr_${price.toStringAsFixed(0)}php.png';
    final savedPath = await QrDownloadHelper.downloadQrImage(
      assetPath: qrAsset,
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

  void _showFullScreenQr(String qrAsset, double price, String provider) {
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
                        child: const Icon(Icons.qr_code_2_rounded,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$provider QR',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
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
                    qrAsset,
                    width: 280,
                    height: 280,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Amount: ₱${price.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF007DFE)),
              ),
              const SizedBox(height: 4),
              Text(
                'Scan this $provider QR code to pay the boost fee.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.mutedGray),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007DFE),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _openPaymentApp(price);
                },
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text('Open GCash App to Pay',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF007DFE),
                  side: const BorderSide(color: Color(0xFF007DFE)),
                  minimumSize: const Size(double.infinity, 40),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _downloadQr(qrAsset, price);
                },
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Download QR Code',
                    style: TextStyle(fontWeight: FontWeight.bold)),
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
    final extra = widget.extraData ?? {};
    final planName = extra['planName'] ?? '3 Days';
    final planPrice = (extra['planPrice'] as num?)?.toDouble() ?? 25.0;
    final planDays = (extra['planDays'] as num?)?.toInt() ?? 3;

    final qrAsset = AppAssets.qrForAmount(planPrice);
    final provider = AppAssets.providerForAmount(planPrice);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Boost Payment',
          style: GoogleFonts.merriweather(
              fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // QR Code Card
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
                          child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Colors.white,
                              size: 18),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Scan to Pay via $provider',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(40),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$provider QR',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // QR Code Display Card
                    GestureDetector(
                      onTap: () =>
                          _showFullScreenQr(qrAsset, planPrice, provider),
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
                                qrAsset,
                                width: 200,
                                height: 200,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.zoom_in_rounded,
                                    size: 15, color: Color(0xFF007DFE)),
                                SizedBox(width: 4),
                                Text(
                                  'Tap to view / expand QR',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF007DFE)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Plan & Amount badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(40),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$planName Boost — ₱${planPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: AppColors.accentGold,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
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
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: () => _openPaymentApp(planPrice),
                          icon: const Icon(Icons.open_in_new_rounded,
                              size: 18),
                          label: const Text('Open GCash App to Pay',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold)),
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
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () => _downloadQr(qrAsset, planPrice),
                                icon: const Icon(Icons.download_rounded, size: 16),
                                label: const Text('Download QR',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
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
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () => _showFullScreenQr(
                                    qrAsset, planPrice, provider),
                                icon: const Icon(Icons.visibility_outlined,
                                    size: 16),
                                label: const Text('View / Expand',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
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

              // Reference Number Input
              Text(
                'Payment Reference Number',
                style: GoogleFonts.merriweather(
                    fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Enter the reference number from your $provider transaction so the admin can verify your payment.',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.mutedGray),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _refController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g. 1234 5678 9012',
                  hintStyle: const TextStyle(
                      fontSize: 12, color: AppColors.mutedGray),
                  prefixIcon: const Icon(Icons.receipt_long_rounded,
                      color: AppColors.midGreen),
                  filled: true,
                  fillColor: AppColors.cardWhite,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.borderLight),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Upload Payment Screenshot
              Text(
                'Upload Payment Screenshot',
                style: GoogleFonts.merriweather(
                    fontSize: 14, fontWeight: FontWeight.bold),
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
                        _screenshotName ?? 'No file selected',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: _screenshotName != null
                              ? AppColors.textDark
                              : AppColors.mutedGray,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _pickReceipt,
                      icon: const Icon(Icons.upload_file,
                          size: 18, color: AppColors.midGreen),
                      label: const Text(
                        'Upload',
                        style: TextStyle(
                            color: AppColors.midGreen,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              PrimaryButton(
                label: 'Confirm Boost Payment',
                icon: Icons.bolt_rounded,
                isAccent: true,
                onPressed: () {
                  final ref = _refController.text.trim();
                  if (ref.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Please enter your payment reference number so the admin can verify.')),
                    );
                    return;
                  }
                  // Apply to first active user item or mock
                  final myItems = db.items
                      .where((i) => i.sellerId == db.currentUser.id)
                      .toList();
                  final targetItem =
                      myItems.isNotEmpty ? myItems.first : db.items.first;

                  db.submitBoostPayment(
                    itemId: targetItem.id,
                    itemTitle: targetItem.title,
                    plan: BoostPlan(
                        name: planName,
                        price: planPrice,
                        durationDays: planDays),
                    referenceNumber: ref,
                  );

                  context.goNamed(RouteNames.boostPending);
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
