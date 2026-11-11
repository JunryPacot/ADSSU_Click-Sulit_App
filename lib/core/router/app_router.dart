import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/item_model.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/onboarding_screens.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/login_error_screen.dart';
import '../../features/auth/register_step1_screen.dart';
import '../../features/auth/register_step2_screen.dart';
import '../../features/auth/verify_code_screen.dart';
import '../../features/auth/account_submitted_screen.dart';
import '../../features/auth/community_rules_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/home/all_categories_screen.dart';
import '../../features/home/category_items_screen.dart';
import '../../features/browse/search_screen.dart';
import '../../features/browse/search_results_screen.dart';
import '../../features/browse/filter_sheet.dart';
import '../../features/browse/sort_sheet.dart';
import '../../features/browse/no_results_screen.dart';
import '../../features/items/item_detail_sell_screen.dart';
import '../../features/items/item_detail_exchange_screen.dart';
import '../../features/items/item_detail_donate_screen.dart';
import '../../features/items/photo_viewer_screen.dart';
import '../../features/items/seller_profile_screen.dart';
import '../../features/items/report_item_screen.dart';
import '../../features/items/report_sent_screen.dart';
import '../../features/items/buy_request_screen.dart';
import '../../features/items/buy_request_sent_screen.dart';
import '../../features/items/offer_exchange_screen.dart';
import '../../features/items/exchange_offer_sent_screen.dart';
import '../../features/items/request_donation_screen.dart';
import '../../features/items/donation_sent_screen.dart';
import '../../features/chat/messages_screen.dart';
import '../../features/chat/chat_screen.dart';
import '../../features/requests/requests_offers_screen.dart';
import '../../features/requests/meet_up_spot_screen.dart';
import '../../features/requests/meet_up_confirmed_screen.dart';
import '../../features/requests/complete_transaction_screen.dart';
import '../../features/requests/rate_review_screen.dart';
import '../../features/requests/review_submitted_screen.dart';
import '../../features/requests/specific_location_screen.dart';
import '../../features/post/post_choose_type_screen.dart';
import '../../features/post/add_photos_screen.dart';
import '../../features/post/sell_details_screen.dart';
import '../../features/post/exchange_details_screen.dart';
import '../../features/post/donate_details_screen.dart';
import '../../features/post/post_preview_screen.dart';
import '../../features/post/posted_successfully_screen.dart';
import '../../features/post/membership_required_screen.dart';
import '../../features/post/membership_payment_screen.dart';
import '../../features/post/membership_pending_screen.dart';
import '../../features/post/featured_boost_plans_screen.dart';
import '../../features/post/boost_payment_screen.dart';
import '../../features/post/boost_pending_screen.dart';
import '../../features/activity/my_listings_screen.dart';
import '../../features/activity/edit_listing_screen.dart';
import '../../features/activity/delete_listing_screen.dart';
import '../../features/activity/mark_as_done_screen.dart';
import '../../features/activity/transaction_history_screen.dart';
import '../../features/activity/saved_items_screen.dart';
import '../../features/activity/notifications_screen.dart';
import '../../features/activity/my_impact_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/edit_profile_screen.dart';
import '../../features/profile/my_reviews_screen.dart';
import '../../features/profile/settings_screen.dart';
import '../../features/profile/help_faq_screen.dart';
import '../../features/profile/about_screen.dart';
import '../../features/profile/logout_confirm_screen.dart';
import '../../features/admin/admin_dashboard_screen.dart';
import '../../features/admin/pending_verifications_screen.dart';
import '../../features/admin/verification_detail_screen.dart';
import '../../features/admin/reported_items_screen.dart';
import '../../features/admin/report_detail_screen.dart';
import '../../features/admin/manage_listings_screen.dart';
import '../../features/admin/payments_review_screen.dart';
import '../../features/admin/payment_detail_screen.dart';
import '../../features/admin/impact_stats_screen.dart';
import '../../features/admin/admin_profile_screen.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // 1 Splash
      GoRoute(
        path: '/',
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      // 2 Onboarding Sell
      GoRoute(
        path: '/onboarding-sell',
        name: RouteNames.onboardingSell,
        builder: (context, state) => OnboardingScreen.sell(context),
      ),
      // 3 Onboarding Exchange
      GoRoute(
        path: '/onboarding-exchange',
        name: RouteNames.onboardingExchange,
        builder: (context, state) => OnboardingScreen.exchange(context),
      ),
      // 4 Onboarding Donate
      GoRoute(
        path: '/onboarding-donate',
        name: RouteNames.onboardingDonate,
        builder: (context, state) => OnboardingScreen.donate(context),
      ),
      // 5 Login
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      // 6 Forgot Password
      GoRoute(
        path: '/forgot-password',
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      // 7 Login Error
      GoRoute(
        path: '/login-error',
        name: RouteNames.loginError,
        builder: (context, state) => const LoginErrorScreen(),
      ),
      // 8 Register Step 1
      GoRoute(
        path: '/register-1',
        name: RouteNames.registerStep1,
        builder: (context, state) => const RegisterStep1Screen(),
      ),
      // 9 Register Step 2
      GoRoute(
        path: '/register-2',
        name: RouteNames.registerStep2,
        builder: (context, state) => RegisterStep2Screen(
          initialData: state.extra as Map<String, dynamic>?,
        ),
      ),
      // 10 Verify Email Code
      GoRoute(
        path: '/verify-code',
        name: RouteNames.verifyEmailCode,
        builder: (context, state) => VerifyCodeScreen(
          registrationData: state.extra as Map<String, dynamic>?,
        ),
      ),
      // 11 Account Submitted
      GoRoute(
        path: '/account-submitted',
        name: RouteNames.accountSubmitted,
        builder: (context, state) => const AccountSubmittedScreen(),
      ),
      // 12 Home
      GoRoute(
        path: '/home',
        name: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
      ),
      // 13 All Categories
      GoRoute(
        path: '/categories',
        name: RouteNames.allCategories,
        builder: (context, state) => const AllCategoriesScreen(),
      ),
      // 14 Books
      GoRoute(
        path: '/category/books',
        name: RouteNames.categoryBooks,
        builder: (context, state) => const CategoryItemsScreen(
          categoryName: 'Books',
          icon: Icons.menu_book_rounded,
        ),
      ),
      // 15 Uniforms
      GoRoute(
        path: '/category/uniforms',
        name: RouteNames.categoryUniforms,
        builder: (context, state) => const CategoryItemsScreen(
          categoryName: 'Uniforms',
          icon: Icons.checkroom_rounded,
        ),
      ),
      // 16 Gadgets
      GoRoute(
        path: '/category/gadgets',
        name: RouteNames.categoryGadgets,
        builder: (context, state) => const CategoryItemsScreen(
          categoryName: 'Gadgets',
          icon: Icons.devices_rounded,
        ),
      ),
      // 17 School Supplies
      GoRoute(
        path: '/category/supplies',
        name: RouteNames.categorySupplies,
        builder: (context, state) => const CategoryItemsScreen(
          categoryName: 'School Supplies',
          icon: Icons.edit_note_rounded,
        ),
      ),
      // 18 Other Reusable Goods
      GoRoute(
        path: '/category/others',
        name: RouteNames.categoryOthers,
        builder: (context, state) => const CategoryItemsScreen(
          categoryName: 'Other Reusable Goods',
          icon: Icons.recycling_rounded,
        ),
      ),
      // 19 Search
      GoRoute(
        path: '/search',
        name: RouteNames.search,
        builder: (context, state) => const SearchScreen(),
      ),
      // 20 Search Results
      GoRoute(
        path: '/search-results',
        name: RouteNames.searchResults,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return SearchResultsScreen(
            query: extra?['query'] as String?,
            initialResults: extra?['results'] as List<ItemModel>?,
          );
        },
      ),
      // 21 Filter Sheet
      GoRoute(
        path: '/filter',
        name: RouteNames.filterSheet,
        builder: (context, state) => const FilterSheetScreen(),
      ),
      // 22 Sort Sheet
      GoRoute(
        path: '/sort',
        name: RouteNames.sortSheet,
        builder: (context, state) => const SortSheetScreen(),
      ),
      // 23 No Results
      GoRoute(
        path: '/no-results',
        name: RouteNames.noResults,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return NoResultsScreen(
            query: extra?['query'] as String?,
          );
        },
      ),
      // 24 Item Detail (Sell)
      GoRoute(
        path: '/item/sell/:id',
        name: RouteNames.itemDetailSell,
        builder: (context, state) => ItemDetailSellScreen(
          itemId: state.pathParameters['id'] ?? '',
        ),
      ),
      // 25 Item Detail (Exchange)
      GoRoute(
        path: '/item/exchange/:id',
        name: RouteNames.itemDetailExchange,
        builder: (context, state) => ItemDetailExchangeScreen(
          itemId: state.pathParameters['id'] ?? '',
        ),
      ),
      // 26 Item Detail (Donate)
      GoRoute(
        path: '/item/donate/:id',
        name: RouteNames.itemDetailDonate,
        builder: (context, state) => ItemDetailDonateScreen(
          itemId: state.pathParameters['id'] ?? '',
        ),
      ),
      // 27 Photo Viewer
      GoRoute(
        path: '/photo-viewer',
        name: RouteNames.photoViewer,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return PhotoViewerScreen(
            title: extra['title'] as String?,
            imageUrl: extra['imageUrl'] as String?,
            images: (extra['images'] as List?)?.map((e) => e.toString()).toList() ?? const [],
          );
        },
      ),
      // 28 Seller / Trader / Donor Profile
      GoRoute(
        path: '/seller/:id',
        name: RouteNames.sellerProfile,
        builder: (context, state) => SellerProfileScreen(
          sellerId: state.pathParameters['id'] ?? '',
          profileType: state.uri.queryParameters['type'] ??
              (state.extra is Map ? (state.extra as Map)['type']?.toString() : null),
        ),
      ),
      // 29 Report Item
      GoRoute(
        path: '/report-item/:id',
        name: RouteNames.reportItem,
        builder: (context, state) => ReportItemScreen(
          itemId: state.pathParameters['id'] ?? '',
        ),
      ),
      // 30 Report Sent
      GoRoute(
        path: '/report-sent',
        name: RouteNames.reportSent,
        builder: (context, state) => const ReportSentScreen(),
      ),
      // 31 Buy Request
      GoRoute(
        path: '/buy-request/:id',
        name: RouteNames.buyRequest,
        builder: (context, state) => BuyRequestScreen(
          itemId: state.pathParameters['id'] ?? '',
        ),
      ),
      // 32 Buy Request Sent
      GoRoute(
        path: '/buy-request-sent',
        name: RouteNames.buyRequestSent,
        builder: (context, state) => BuyRequestSentScreen(
          extraData: state.extra as Map<String, dynamic>?,
        ),
      ),
      // 33 Offer an Exchange
      GoRoute(
        path: '/offer-exchange/:id',
        name: RouteNames.offerExchange,
        builder: (context, state) => OfferExchangeScreen(
          itemId: state.pathParameters['id'] ?? '',
        ),
      ),
      // 34 Exchange Offer Sent
      GoRoute(
        path: '/exchange-offer-sent',
        name: RouteNames.exchangeOfferSent,
        builder: (context, state) => ExchangeOfferSentScreen(
          extraData: state.extra as Map<String, dynamic>?,
        ),
      ),
      // 35 Request Donation
      GoRoute(
        path: '/request-donation/:id',
        name: RouteNames.requestDonation,
        builder: (context, state) => RequestDonationScreen(
          itemId: state.pathParameters['id'] ?? '',
        ),
      ),
      // 36 Donation Request Sent
      GoRoute(
        path: '/donation-sent',
        name: RouteNames.donationRequestSent,
        builder: (context, state) => DonationSentScreen(
          extraData: state.extra as Map<String, dynamic>?,
        ),
      ),
      // 37 Messages
      GoRoute(
        path: '/messages',
        name: RouteNames.messages,
        builder: (context, state) => const MessagesScreen(),
      ),
      // 38 Chat
      GoRoute(
        path: '/chat/:id',
        name: RouteNames.chat,
        builder: (context, state) => ChatScreen(
          chatId: state.pathParameters['id'] ?? '',
        ),
      ),
      // 39 Requests and Offers
      GoRoute(
        path: '/requests-offers',
        name: RouteNames.requestsOffers,
        builder: (context, state) => const RequestsOffersScreen(),
      ),
      // 40 Meet-Up Spot
      GoRoute(
        path: '/meet-up-spot',
        name: RouteNames.meetUpSpot,
        builder: (context, state) => MeetUpSpotScreen(
          extraData: state.extra as Map<String, dynamic>?,
        ),
      ),
      // 41 Meet-Up Confirmed
      GoRoute(
        path: '/meet-up-confirmed',
        name: RouteNames.meetUpConfirmed,
        builder: (context, state) => MeetUpConfirmedScreen(
          extraData: state.extra as Map<String, dynamic>?,
        ),
      ),
      // 42 Complete Transaction
      GoRoute(
        path: '/complete-deal',
        name: RouteNames.completeTransaction,
        builder: (context, state) => CompleteTransactionScreen(
          extraData: state.extra as Map<String, dynamic>?,
        ),
      ),
      // 43 Rate and Review
      GoRoute(
        path: '/rate-review',
        name: RouteNames.rateReview,
        builder: (context, state) => RateReviewScreen(
          extraData: state.extra as Map<String, dynamic>?,
        ),
      ),
      // 44 Review Submitted
      GoRoute(
        path: '/review-submitted',
        name: RouteNames.reviewSubmitted,
        builder: (context, state) => const ReviewSubmittedScreen(),
      ),
      // 45 Post: Choose Type
      GoRoute(
        path: '/post/step1',
        builder: (context, state) => const PostChooseTypeScreen(),
      ),
      GoRoute(
        path: '/post/type',
        name: RouteNames.postChooseType,
        builder: (context, state) => const PostChooseTypeScreen(),
      ),
      // 46 Add Photos
      GoRoute(
        path: '/post/photos',
        name: RouteNames.addPhotos,
        builder: (context, state) => AddPhotosScreen(
          extraData: state.extra as Map<String, dynamic>?,
        ),
      ),
      // 47 Sell Details
      GoRoute(
        path: '/post/sell-details',
        name: RouteNames.sellDetails,
        builder: (context, state) => SellDetailsScreen(
          extraData: state.extra as Map<String, dynamic>?,
        ),
      ),
      // 48 Exchange Details
      GoRoute(
        path: '/post/exchange-details',
        name: RouteNames.exchangeDetails,
        builder: (context, state) => ExchangeDetailsScreen(
          extraData: state.extra as Map<String, dynamic>?,
        ),
      ),
      // 49 Donate Details
      GoRoute(
        path: '/post/donate-details',
        name: RouteNames.donateDetails,
        builder: (context, state) => DonateDetailsScreen(
          extraData: state.extra as Map<String, dynamic>?,
        ),
      ),
      // 50 Preview
      GoRoute(
        path: '/post/preview',
        name: RouteNames.postPreview,
        builder: (context, state) => PostPreviewScreen(
          extraData: state.extra as Map<String, dynamic>?,
        ),
      ),
      // 51 Posted Successfully
      GoRoute(
        path: '/post/success',
        name: RouteNames.postedSuccessfully,
        builder: (context, state) => PostedSuccessfullyScreen(
          extraData: state.extra as Map<String, dynamic>?,
        ),
      ),
      // 52 Membership Required
      GoRoute(
        path: '/membership',
        name: RouteNames.membershipRequired,
        builder: (context, state) => const MembershipRequiredScreen(),
      ),
      // 53 Membership Payment
      GoRoute(
        path: '/membership/pay',
        name: RouteNames.membershipPayment,
        builder: (context, state) => const MembershipPaymentScreen(),
      ),
      // 54 Membership Pending
      GoRoute(
        path: '/membership/pending',
        name: RouteNames.membershipPending,
        builder: (context, state) => const MembershipPendingScreen(),
      ),
      // 55 Featured Boost Plans
      GoRoute(
        path: '/boost/plans',
        name: RouteNames.featuredBoostPlans,
        builder: (context, state) => FeaturedBoostPlansScreen(
          extraData: state.extra as Map<String, dynamic>?,
        ),
      ),
      // 56 Boost Payment
      GoRoute(
        path: '/boost/pay',
        name: RouteNames.boostPayment,
        builder: (context, state) => BoostPaymentScreen(
          extraData: state.extra as Map<String, dynamic>?,
        ),
      ),
      // 57 Boost Pending
      GoRoute(
        path: '/boost/pending',
        name: RouteNames.boostPending,
        builder: (context, state) => const BoostPendingScreen(),
      ),
      // 58 My Listings
      GoRoute(
        path: '/my-listings',
        name: RouteNames.myListings,
        builder: (context, state) => const MyListingsScreen(),
      ),
      // 59 Edit Listing
      GoRoute(
        path: '/listing/edit/:id',
        name: RouteNames.editListing,
        builder: (context, state) => EditListingScreen(
          itemId: state.pathParameters['id'] ?? '',
        ),
      ),
      // 60 Delete Listing
      GoRoute(
        path: '/listing/delete/:id',
        name: RouteNames.deleteListing,
        builder: (context, state) => DeleteListingScreen(
          itemId: state.pathParameters['id'] ?? '',
        ),
      ),
      // 61 Mark as Done
      GoRoute(
        path: '/listing/done/:id',
        name: RouteNames.markAsDone,
        builder: (context, state) => MarkAsDoneScreen(
          itemId: state.pathParameters['id'] ?? '',
        ),
      ),
      // 62 Transaction History
      GoRoute(
        path: '/transactions',
        name: RouteNames.transactionHistory,
        builder: (context, state) => const TransactionHistoryScreen(),
      ),
      // 63 Saved Items
      GoRoute(
        path: '/saved-items',
        name: RouteNames.savedItems,
        builder: (context, state) => const SavedItemsScreen(),
      ),
      // 64 Notifications
      GoRoute(
        path: '/notifications',
        name: RouteNames.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      // 65 My Impact
      GoRoute(
        path: '/my-impact',
        name: RouteNames.myImpact,
        builder: (context, state) => const MyImpactScreen(),
      ),
      // 66 Profile
      GoRoute(
        path: '/profile',
        name: RouteNames.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      // 67 Edit Profile
      GoRoute(
        path: '/profile/edit',
        name: RouteNames.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      // 68 My Reviews
      GoRoute(
        path: '/my-reviews',
        name: RouteNames.myReviews,
        builder: (context, state) => const MyReviewsScreen(),
      ),
      // 69 Settings
      GoRoute(
        path: '/settings',
        name: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      // 70 Help and FAQ
      GoRoute(
        path: '/help',
        name: RouteNames.helpFaq,
        builder: (context, state) => const HelpFaqScreen(),
      ),
      // 71 About
      GoRoute(
        path: '/about',
        name: RouteNames.about,
        builder: (context, state) => const AboutScreen(),
      ),
      // 72 Logout Confirm
      GoRoute(
        path: '/logout-confirm',
        name: RouteNames.logoutConfirm,
        builder: (context, state) => const LogoutConfirmScreen(),
      ),
      // 73 Admin Dashboard
      GoRoute(
        path: '/admin/dashboard',
        name: RouteNames.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      // 74 Pending Verifications
      GoRoute(
        path: '/admin/verifications',
        name: RouteNames.adminVerifications,
        builder: (context, state) => const PendingVerificationsScreen(),
      ),
      // 75 Verification Detail
      GoRoute(
        path: '/admin/verify/:id',
        name: RouteNames.verificationDetail,
        builder: (context, state) => VerificationDetailScreen(
          userId: state.pathParameters['id'] ?? '',
        ),
      ),
      // 76 Reported Items
      GoRoute(
        path: '/admin/reports',
        name: RouteNames.adminReports,
        builder: (context, state) => const ReportedItemsScreen(),
      ),
      // 77 Report Detail
      GoRoute(
        path: '/admin/report/:id',
        name: RouteNames.reportDetail,
        builder: (context, state) => ReportDetailScreen(
          reportId: state.pathParameters['id'] ?? '',
        ),
      ),
      // 78 Manage Listings
      GoRoute(
        path: '/admin/listings',
        name: RouteNames.manageListings,
        builder: (context, state) => const ManageListingsScreen(),
      ),
      // 79 Payments Review
      GoRoute(
        path: '/admin/payments',
        name: RouteNames.paymentsReview,
        builder: (context, state) => const PaymentsReviewScreen(),
      ),
      // 80 Payment Detail
      GoRoute(
        path: '/admin/payment/:id',
        name: RouteNames.paymentDetail,
        builder: (context, state) => PaymentDetailScreen(
          paymentId: state.pathParameters['id'] ?? '',
        ),
      ),
      // 81 Impact Stats
      GoRoute(
        path: '/admin/stats',
        name: RouteNames.impactStats,
        builder: (context, state) => const ImpactStatsScreen(),
      ),
      // 82 Specific Location
      GoRoute(
        path: '/meet-up/specific',
        name: RouteNames.specificLocation,
        builder: (context, state) => SpecificLocationScreen(
          extraData: state.extra as Map<String, dynamic>?,
        ),
      ),
      // 83 Community Rules
      GoRoute(
        path: '/community-rules',
        name: RouteNames.communityRules,
        builder: (context, state) => const CommunityRulesScreen(),
      ),
      // 84 Admin Profile
      GoRoute(
        path: '/admin/profile',
        name: RouteNames.adminProfile,
        builder: (context, state) => const AdminProfileScreen(),
      ),
    ],
  );
}
