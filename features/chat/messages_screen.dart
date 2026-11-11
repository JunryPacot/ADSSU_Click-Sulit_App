import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/type_tag.dart';
import '../../core/widgets/user_bottom_nav.dart';
import '../../data/mock/mock_database.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final chats = db.chats;
    final requests = db.requests;
    final receivedRequests = requests.where((r) => r.sellerId == db.currentUser.id && r.status == 'pending').toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'Messages',
            style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          bottom: TabBar(
            indicatorColor: AppColors.primaryDarkGreen,
            labelColor: AppColors.primaryDarkGreen,
            unselectedLabelColor: AppColors.mutedGray,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Chats'),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.paleGreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${chats.length}',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryDarkGreen),
                      ),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Requests'),
                    if (receivedRequests.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.statusError,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${receivedRequests.length}',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Chats List
            chats.isEmpty
                ? const Center(
                    child: Text(
                      'No messages yet. Chat when initiating requests!',
                      style: TextStyle(color: AppColors.mutedGray),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: chats.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final chat = chats[index];
                      final timeStr = DateFormat('MMM d, h:mm a').format(chat.lastMessageTime);

                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          context.pushNamed(
                            RouteNames.chat,
                            pathParameters: {'id': chat.id},
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.cardWhite,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.primaryDarkGreen,
                                child: Text(
                                  chat.otherUserName.isNotEmpty ? chat.otherUserName[0] : 'U',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
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
                                            chat.otherUserName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          timeStr,
                                          style: const TextStyle(fontSize: 10, color: AppColors.mutedGray),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Item: ${chat.relatedItemTitle}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 11, color: AppColors.midGreen, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      chat.lastMessage,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12, color: AppColors.mutedGray),
                                    ),
                                  ],
                                ),
                              ),
                              if (chat.unreadCount > 0) ...[
                                const SizedBox(width: 8),
                                CircleAvatar(
                                  radius: 10,
                                  backgroundColor: AppColors.midGreen,
                                  child: Text(
                                    '${chat.unreadCount}',
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),

            // Tab 2: Requests Summary / Direct link to screen 39
            Padding(
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
                            const Icon(Icons.handshake_outlined, color: AppColors.primaryDarkGreen, size: 24),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Requests & Offers Hub',
                                style: GoogleFonts.merriweather(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Manage your buyer requests, exchange offers, and donation inquiries in one place.',
                          style: GoogleFonts.carlito(fontSize: 13, color: AppColors.mutedGray),
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          label: 'Open Requests and Offers',
                          icon: Icons.checklist_rtl_rounded,
                          onPressed: () {
                            context.pushNamed(RouteNames.requestsOffers);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Pending Received Requests (${receivedRequests.length})',
                    style: GoogleFonts.merriweather(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (receivedRequests.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: const Text('No pending requests to review right now.'),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: receivedRequests.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final req = receivedRequests[index];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.cardWhite,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Row(
                              children: [
                                TypeTag(type: req.itemType, isCompact: true),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        req.itemTitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      Text(
                                        'From ${req.buyerName} (${req.meetUpBuilding})',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 11, color: AppColors.mutedGray),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primaryDarkGreen),
                                  onPressed: () {
                                    context.pushNamed(RouteNames.requestsOffers);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: const UserBottomNav(currentIndex: 3),
      ),
    );
  }
}
