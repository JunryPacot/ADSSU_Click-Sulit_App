import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/type_tag.dart';
import '../../data/mock/mock_database.dart';
import '../../data/models/request_model.dart';

class RequestsOffersScreen extends StatelessWidget {
  const RequestsOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final currentUserId = db.currentUser.id;

    final receivedRequests = db.requests.where((r) => r.sellerId == currentUserId).toList();
    final sentRequests = db.requests.where((r) => r.buyerId == currentUserId).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'Requests & Offers',
            style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          bottom: const TabBar(
            indicatorColor: AppColors.primaryDarkGreen,
            labelColor: AppColors.primaryDarkGreen,
            unselectedLabelColor: AppColors.mutedGray,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: [
              Tab(text: 'Received'),
              Tab(text: 'Sent'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Received Requests Tab
            receivedRequests.isEmpty
                ? const Center(
                    child: Text(
                      'No requests received yet.',
                      style: TextStyle(color: AppColors.mutedGray),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: receivedRequests.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildReceivedCard(context, db, receivedRequests[index]);
                    },
                  ),

            // Sent Requests Tab
            sentRequests.isEmpty
                ? const Center(
                    child: Text(
                      'You haven\'t made any requests yet.',
                      style: TextStyle(color: AppColors.mutedGray),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: sentRequests.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildSentCard(context, sentRequests[index]);
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceivedCard(BuildContext context, MockDatabase db, RequestModel req) {
    final isPending = req.status == 'pending';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TypeTag(type: req.itemType, isCompact: true),
              _buildStatusBadge(req.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            req.itemTitle,
            style: GoogleFonts.merriweather(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          if (req.itemType == 'EXCHANGE' && req.offeredItemTitle != null) ...[
            const SizedBox(height: 4),
            Text(
              'Offered Item: ${req.offeredItemTitle}',
              style: const TextStyle(fontSize: 12, color: AppColors.midGreen, fontWeight: FontWeight.bold),
            ),
          ] else if (req.itemType == 'SELL') ...[
            const SizedBox(height: 4),
            Text(
              'Offered Price: ₱${req.itemPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 13, color: AppColors.primaryDarkGreen, fontWeight: FontWeight.bold),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 14, color: AppColors.mutedGray),
              const SizedBox(width: 4),
              Text(
                'Buyer: ${req.buyerName} (${req.buyerCollege})',
                style: const TextStyle(fontSize: 11, color: AppColors.mutedGray),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.midGreen),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${req.meetUpBuilding}${req.exactLocation.isNotEmpty ? ' • ${req.exactLocation}' : ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppColors.textDark),
                ),
              ),
              if (req.hasLocationPhoto) ...[
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.only(left: 4),
                  icon: const Icon(Icons.photo_camera_outlined, size: 18, color: AppColors.midGreen),
                  tooltip: 'View Location Photo',
                  onPressed: () {
                    context.pushNamed(
                      RouteNames.photoViewer,
                      extra: {
                        'title': '${req.meetUpBuilding} Meet-Up Spot',
                      },
                    );
                  },
                ),
              ],
            ],
          ),
          if (isPending) ...[
            const Divider(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.statusError,
                      side: const BorderSide(color: AppColors.statusError),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () {
                      _showDeclineConfirmDialog(context, db, req.id);
                    },
                    child: const Text('Decline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDarkGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () {
                      db.acceptRequest(req.id);
                      context.pushNamed(
                        RouteNames.meetUpSpot,
                        extra: {
                          'requestId': req.id,
                          'meetUpBuilding': req.meetUpBuilding,
                          'exactLocation': req.exactLocation,
                          'itemTitle': req.itemTitle,
                          'itemType': req.itemType,
                          'itemPrice': req.itemPrice,
                          'buyerName': req.buyerName,
                          'sellerId': req.sellerId,
                        },
                      );
                    },
                    child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSentCard(BuildContext context, RequestModel req) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TypeTag(type: req.itemType, isCompact: true),
              _buildStatusBadge(req.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            req.itemTitle,
            style: GoogleFonts.merriweather(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Seller: ${req.sellerName}',
            style: const TextStyle(fontSize: 11, color: AppColors.mutedGray),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.midGreen),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${req.meetUpBuilding}${req.exactLocation.isNotEmpty ? ' • ${req.exactLocation}' : ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppColors.textDark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String label;

    switch (status.toLowerCase()) {
      case 'accepted':
        bg = AppColors.lightMint;
        fg = AppColors.statusSuccess;
        label = 'Accepted';
        break;
      case 'declined':
        bg = AppColors.statusError.withAlpha(20);
        fg = AppColors.statusError;
        label = 'Declined';
        break;
      case 'completed':
        bg = AppColors.background;
        fg = AppColors.mutedGray;
        label = 'Completed';
        break;
      case 'pending':
      default:
        bg = AppColors.accentGold.withAlpha(40);
        fg = AppColors.accentGold;
        label = 'Pending';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showDeclineConfirmDialog(BuildContext context, MockDatabase db, String reqId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Decline Request?'),
        content: const Text('Are you sure you want to decline this request? The buyer will be notified.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              db.declineRequest(reqId);
              Navigator.pop(ctx);
            },
            child: const Text('Decline', style: TextStyle(color: AppColors.statusError)),
          ),
        ],
      ),
    );
  }
}
