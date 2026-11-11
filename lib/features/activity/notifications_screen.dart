import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const String _notifsStorageKey = 'persisted_user_notifications';

  List<Map<String, dynamic>> _notifications = [
    {
      'id': 'notif_1',
      'title': 'New Request Received',
      'body': 'Bea Alonzo-Tan sent an offer for your Calculus textbook.',
      'time': '10 mins ago',
      'iconCode': 'handshake',
      'route': RouteNames.requestsOffers,
    },
    {
      'id': 'notif_2',
      'title': 'Meet-Up Reminder',
      'body': 'Upcoming meet-up at CEIT Building lobby today at 2:00 PM.',
      'time': '1 hour ago',
      'iconCode': 'place',
      'route': RouteNames.meetUpConfirmed,
    },
    {
      'id': 'notif_3',
      'title': 'Listing Approved',
      'body': 'Your listing "Casio fx-991 calculator" is active.',
      'time': '3 hours ago',
      'iconCode': 'check',
      'route': RouteNames.myListings,
    },
    {
      'id': 'notif_4',
      'title': 'Seller Membership Active',
      'body': 'Your GCash payment verification was approved. You can post sell items!',
      'time': 'Yesterday',
      'iconCode': 'premium',
      'route': RouteNames.membershipRequired,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_notifsStorageKey);
      if (jsonString != null && mounted) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        setState(() {
          _notifications = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_notifications);
      await prefs.setString(_notifsStorageKey, jsonString);
    } catch (_) {}
  }

  void _deleteNotification(int index) {
    final deleted = _notifications[index];
    setState(() {
      _notifications.removeAt(index);
    });
    _saveNotifications();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed "${deleted['title']}"'),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.accentGold,
          onPressed: () {
            setState(() {
              _notifications.insert(index, deleted);
            });
            _saveNotifications();
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _clearAllNotifications() {
    if (_notifications.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Notifications?'),
        content: const Text('Are you sure you want to remove all notifications?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusError,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _notifications.clear();
              });
              _saveNotifications();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications cleared')),
              );
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  IconData _resolveIcon(dynamic iconData, dynamic iconCode) {
    if (iconData is IconData) return iconData;
    switch (iconCode) {
      case 'handshake':
        return Icons.handshake_outlined;
      case 'place':
        return Icons.place_outlined;
      case 'check':
        return Icons.check_circle_outline;
      case 'premium':
        return Icons.workspace_premium_outlined;
      default:
        return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              tooltip: 'Clear All',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: _clearAllNotifications,
            ),
          IconButton(
            tooltip: 'Device Notification Permissions',
            icon: const Icon(Icons.notifications_active_outlined),
            onPressed: () async {
              final granted = await NotificationService.requestNotificationPermission();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      granted
                          ? 'Device notifications enabled for item requests and messages!'
                          : 'Notification permissions were not granted in system settings.',
                    ),
                    backgroundColor: granted ? AppColors.statusSuccess : AppColors.mutedGray,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _notifications.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              color: AppColors.paleGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_none_rounded,
                              size: 40,
                              color: AppColors.primaryDarkGreen,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Notifications',
                            style: GoogleFonts.merriweather(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'You are all caught up! Updates regarding your transactions, meet-ups, and messages will appear here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: AppColors.mutedGray),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final n = _notifications[index];
                      final icon = _resolveIcon(n['icon'], n['iconCode']);

                      return Dismissible(
                        key: Key(n['id'] as String),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppColors.statusError,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(Icons.delete_outline, color: Colors.white),
                              SizedBox(width: 6),
                              Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        onDismissed: (_) => _deleteNotification(index),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            final route = n['route'] as String?;
                            if (route != null && route.isNotEmpty) {
                              context.pushNamed(route);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.cardWhite,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: AppTheme.cardShadow,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: AppColors.paleGreen,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(icon, color: AppColors.primaryDarkGreen, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              (n['title'] ?? '') as String,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                            ),
                                          ),
                                          Text(
                                            (n['time'] ?? '') as String,
                                            style: const TextStyle(fontSize: 10, color: AppColors.mutedGray),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        (n['body'] ?? '') as String,
                                        style: GoogleFonts.carlito(fontSize: 12, color: AppColors.textDark),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.mutedGray),
                                  tooltip: 'Delete notification',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () => _deleteNotification(index),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
