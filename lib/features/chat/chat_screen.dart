import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_image.dart';
import '../../data/mock/mock_database.dart';
import '../../data/models/chat_model.dart';
import '../../data/models/item_model.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  const ChatScreen({super.key, required this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();

    // 1. Locate or create chat thread
    ChatThread? thread;
    try {
      thread = db.chats.firstWhere((c) => c.id == widget.chatId);
    } catch (_) {
      try {
        final targetUserId = widget.chatId.replaceFirst('chat_', '');
        thread = db.chats.firstWhere((c) => c.otherUserId == targetUserId);
      } catch (_) {
        thread = null;
      }
    }

    final targetUserId = widget.chatId.replaceFirst('chat_', '');
    final otherUser = db.users.firstWhere(
      (u) => u.id == (thread?.otherUserId ?? targetUserId),
      orElse: () => db.currentUser,
    );

    final otherUserName = thread?.otherUserName ?? (otherUser.id != db.currentUser.id ? otherUser.name : 'ADSSU Member');
    final otherUserCollege = thread?.otherUserCollege ?? otherUser.college;

    // 2. Find associated item (Shopee-style product banner)
    ItemModel? relatedItem;
    final rItemId = thread?.relatedItemId;
    if (rItemId != null && rItemId.isNotEmpty) {
      try {
        relatedItem = db.items.firstWhere((i) => i.id == rItemId);
      } catch (_) {}
    }
    if (relatedItem == null) {
      final userItems = db.items.where((i) => i.sellerId == otherUser.id || i.sellerId == db.currentUser.id).toList();
      if (userItems.isNotEmpty) {
        relatedItem = userItems.first;
      }
    }

    final relatedItemTitle = relatedItem?.title ?? (thread?.relatedItemTitle ?? 'Campus Listing');
    final messages = thread?.messages ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryDarkGreen,
              child: otherUser.profilePhoto != null && otherUser.profilePhoto!.isNotEmpty
                  ? ClipOval(
                      child: AppImage(
                        imageSource: otherUser.profilePhoto,
                        width: 36,
                        height: 36,
                        fallbackIcon: Icons.person_rounded,
                      ),
                    )
                  : Text(
                      otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : 'U',
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherUserName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.merriweather(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$otherUserCollege • Online',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: AppColors.mutedGray),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              context.pushNamed(
                RouteNames.meetUpSpot,
                extra: {
                  'itemTitle': relatedItemTitle,
                  'otherUserName': otherUserName,
                },
              );
            },
            icon: const Icon(Icons.place, size: 16, color: AppColors.primaryDarkGreen),
            label: const Text(
              'Set Meet-up',
              style: TextStyle(
                color: AppColors.primaryDarkGreen,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Shopee-style Product Header Banner
            if (relatedItem != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: AppColors.shadowTint, blurRadius: 4, offset: Offset(0, 1)),
                  ],
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 48,
                        height: 48,
                        color: AppColors.paleGreen,
                        child: AppImage(
                          imageSource: relatedItem.imageUrl ?? (relatedItem.images.isNotEmpty ? relatedItem.images.first : null),
                          width: 48,
                          height: 48,
                          fallbackIcon: Icons.shopping_bag_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            relatedItem.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                relatedItem.type == 'SELL'
                                    ? '₱${relatedItem.price.toStringAsFixed(2)}'
                                    : (relatedItem.type == 'EXCHANGE' ? 'FOR EXCHANGE' : 'FREE DONATION'),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: relatedItem.type == 'SELL'
                                      ? AppColors.primaryDarkGreen
                                      : (relatedItem.type == 'EXCHANGE' ? AppColors.midGreen : AppColors.accentGold),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.paleGreen,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  relatedItem.type,
                                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primaryDarkGreen),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Messages List
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.forum_outlined, size: 48, color: AppColors.mutedGray),
                          const SizedBox(height: 8),
                          Text(
                            'Start your discussion regarding $relatedItemTitle',
                            style: const TextStyle(fontSize: 13, color: AppColors.mutedGray),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMe = msg.isFromMe;
                        final timeStr = DateFormat('h:mm a').format(msg.timestamp);

                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.75,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isMe ? AppColors.primaryDarkGreen : AppColors.cardWhite,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(isMe ? 16 : 4),
                                bottomRight: Radius.circular(isMe ? 4 : 16),
                              ),
                              boxShadow: const [
                                BoxShadow(color: AppColors.shadowTint, blurRadius: 4, offset: Offset(0, 1)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg.text,
                                  style: TextStyle(
                                    color: isMe ? Colors.white : AppColors.textDark,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  timeStr,
                                  style: TextStyle(
                                    color: isMe ? Colors.white70 : AppColors.mutedGray,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Message Input Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                color: AppColors.cardWhite,
                boxShadow: [
                  BoxShadow(color: AppColors.shadowTint, blurRadius: 6, offset: Offset(0, -2)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: const TextStyle(fontSize: 13, color: AppColors.mutedGray),
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (text) {
                        if (text.trim().isNotEmpty) {
                          db.sendMessage(thread?.id ?? widget.chatId, text.trim());
                          _msgController.clear();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.primaryDarkGreen,
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                      onPressed: () {
                        final text = _msgController.text.trim();
                        if (text.isNotEmpty) {
                          db.sendMessage(thread?.id ?? widget.chatId, text);
                          _msgController.clear();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
