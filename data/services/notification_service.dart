import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';

class NotificationService {
  NotificationService._();

  static const String _promptedKey = 'has_prompted_notifications';
  static const String _enabledKey = 'notifications_enabled';
  static const String _persistedNotifsKey = 'persisted_user_notifications';

  /// Returns true if device notification permission is currently granted.
  static Future<bool> isPermissionGranted() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (_) {
      return false;
    }
  }

  /// Directly requests device notification permission from the system.
  static Future<bool> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      final isGranted = status.isGranted;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_enabledKey, isGranted);
        await prefs.setBool(_promptedKey, true);
      } catch (_) {}
      return isGranted;
    } catch (_) {
      return false;
    }
  }

  /// Dispatches a notification across the app and saves it in the user's notification center.
  static Future<void> showNotification({
    required String title,
    required String body,
    String? route,
    String? iconCode,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_persistedNotifsKey);
      List<Map<String, dynamic>> list = [];
      if (jsonString != null) {
        final decoded = jsonDecode(jsonString);
        if (decoded is List) {
          list = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
      }
      list.insert(0, {
        'id': 'notif_${DateTime.now().millisecondsSinceEpoch}',
        'title': title,
        'body': body,
        'time': 'Just now',
        'iconCode': iconCode ?? 'handshake',
        'route': route ?? '',
      });
      await prefs.setString(_persistedNotifsKey, jsonEncode(list));
    } catch (e) {
      debugPrint('[NotificationService] Persist notification error: $e');
    }
  }

  /// Shows the university notification permission prompt once to the user.
  static Future<void> promptPermissionIfNeeded(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alreadyPrompted = prefs.getBool(_promptedKey) ?? false;
      if (alreadyPrompted) return;

      final isGranted = await isPermissionGranted();
      if (isGranted) {
        await prefs.setBool(_enabledKey, true);
        await prefs.setBool(_promptedKey, true);
        return;
      }

      if (!context.mounted) return;

      await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (ctx) => const _NotificationPermissionSheet(),
      );

      await prefs.setBool(_promptedKey, true);
    } catch (_) {}
  }
}

class _NotificationPermissionSheet extends StatelessWidget {
  const _NotificationPermissionSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.paleGreen,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.midGreen.withAlpha(50), width: 2),
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                size: 38,
                color: AppColors.primaryDarkGreen,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Never Miss a Campus Deal!',
              textAlign: TextAlign.center,
              style: GoogleFonts.merriweather(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Allow notifications to stay updated on your student exchange transactions in real-time:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.mutedGray,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: const Column(
                children: [
                  _BenefitRow(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Buy & Request Alerts',
                    description: 'Get notified when a student wants to buy your item or offers an exchange.',
                  ),
                  SizedBox(height: 12),
                  _BenefitRow(
                    icon: Icons.volunteer_activism_outlined,
                    title: 'Donation Claims',
                    description: 'Know immediately when a peer requests your donated school supplies.',
                  ),
                  SizedBox(height: 12),
                  _BenefitRow(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Chat & Meet-Up Updates',
                    description: 'Instant messages and campus location scheduling from buyers and sellers.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Allow Notifications',
              icon: Icons.check_circle_rounded,
              onPressed: () async {
                Navigator.of(context).pop();
                final granted = await NotificationService.requestNotificationPermission();
                if (context.mounted && granted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notifications enabled! You will now receive transaction alerts.'),
                      backgroundColor: AppColors.primaryDarkGreen,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Maybe Later',
                style: TextStyle(
                  color: AppColors.mutedGray,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _BenefitRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.paleGreen,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryDarkGreen, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.mutedGray,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
