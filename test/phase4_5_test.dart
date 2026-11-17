import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adssu_click_and_sulit/core/router/app_router.dart';
import 'package:adssu_click_and_sulit/core/theme/app_theme.dart';
import 'package:adssu_click_and_sulit/data/mock/mock_database.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });
  Widget createTestApp() {
    return ChangeNotifierProvider<MockDatabase>.value(
      value: MockDatabase(),
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }

  void setupViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(412 * 3, 917 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  testWidgets('Screens 45-51: Post flow screens render correctly', (WidgetTester tester) async {
    setupViewport(tester);
    
    // 45 Post Choose Type
    AppRouter.router.go('/post/type');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.text('What would you like to do?'), findsOneWidget);

    // 46 Add Photos
    AppRouter.router.go('/post/photos');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.text('Showcase Your Item'), findsOneWidget);

    // 47 Sell Details
    AppRouter.router.go('/post/sell-details');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.text('Sell Details'), findsOneWidget);

    // 48 Exchange Details
    AppRouter.router.go('/post/exchange-details');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.text('Exchange Details'), findsOneWidget);

    // 49 Donate Details
    AppRouter.router.go('/post/donate-details');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.text('Donation Details'), findsOneWidget);

    // 50 Post Preview
    AppRouter.router.go('/post/preview');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.text('Post Preview'), findsOneWidget);

    // 51 Posted Successfully
    AppRouter.router.go('/post/success');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.text('Posted Successfully!'), findsOneWidget);
  });

  testWidgets('Screens 52-57: Membership and Boost payment flows render correctly', (WidgetTester tester) async {
    setupViewport(tester);

    // 52 Membership Required
    AppRouter.router.go('/membership');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.text('Seller Membership Required'), findsOneWidget);

    // 53 Membership Payment
    AppRouter.router.go('/membership/pay');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.text('GCash Payment'), findsOneWidget);

    // 54 Membership Pending
    AppRouter.router.go('/membership/pending');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.text('Payment Submitted!'), findsOneWidget);

    // 55 Boost Plans
    AppRouter.router.go('/boost/plans');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.text('Featured Boost Plans'), findsOneWidget);

    // 56 Boost Payment
    AppRouter.router.go('/boost/pay');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.text('Boost Payment'), findsOneWidget);

    // 57 Boost Pending
    AppRouter.router.go('/boost/pending');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.text('Boost Activated!'), findsOneWidget);
  });

  testWidgets('Screens 58-65: My Activity screens render correctly', (WidgetTester tester) async {
    setupViewport(tester);

    // 58 My Listings
    AppRouter.router.go('/my-listings');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.text('My Listings'), findsOneWidget);

    // 59 Edit Listing
    AppRouter.router.go('/listing/edit/item_3');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.text('Edit Listing'), findsOneWidget);

    // 60 Delete Listing
    AppRouter.router.go('/listing/delete/item_3');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.text('Delete Listing'), findsOneWidget);

    // 61 Mark as Done
    AppRouter.router.go('/listing/done/item_3');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.text('Mark as Done'), findsOneWidget);

    // 62 Transaction History
    AppRouter.router.go('/transactions');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.text('Transaction History'), findsOneWidget);

    // 63 Saved Items
    AppRouter.router.go('/saved-items');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.textContaining('Saved Items'), findsOneWidget);

    // 64 Notifications
    AppRouter.router.go('/notifications');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.text('Notifications'), findsOneWidget);

    // 65 My Impact
    AppRouter.router.go('/my-impact');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.text('My Circular Impact'), findsOneWidget);
  });

  testWidgets('Screens 66-72: Profile screens render correctly', (WidgetTester tester) async {
    setupViewport(tester);

    // 66 Profile
    AppRouter.router.go('/profile');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.text('My Profile'), findsOneWidget);

    // 67 Edit Profile
    AppRouter.router.go('/profile/edit');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.text('Edit Profile'), findsOneWidget);

    // 68 My Reviews
    AppRouter.router.go('/my-reviews');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.textContaining('My Reviews'), findsOneWidget);

    // 69 Settings
    AppRouter.router.go('/settings');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);

    // 70 Help & FAQ
    AppRouter.router.go('/help');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.text('Help & FAQ'), findsOneWidget);

    // 71 About
    AppRouter.router.go('/about');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.text('About Click & Sulit'), findsOneWidget);

    // 72 Logout Confirm
    AppRouter.router.go('/logout-confirm');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.text('Logout'), findsWidgets);
  });

  testWidgets('Screens 73-81, 84: Admin screens render correctly', (WidgetTester tester) async {
    setupViewport(tester);

    // 73 Admin Dashboard
    AppRouter.router.go('/admin/dashboard');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.text('Admin Portal'), findsOneWidget);
    expect(find.text('Verifications'), findsOneWidget);
    expect(find.text('Item Reports'), findsOneWidget);

    // 74 Pending Verifications
    AppRouter.router.go('/admin/verifications');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.text('Pending Verifications'), findsOneWidget);

    // 75 Verification Detail
    AppRouter.router.go('/admin/verify/user_juan');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.text('Verification Review'), findsOneWidget);

    // 76 Reported Items
    AppRouter.router.go('/admin/reports');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.text('Reported Items'), findsOneWidget);

    // 77 Report Detail
    AppRouter.router.go('/admin/report/rep_1');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.text('Report Inspection'), findsOneWidget);

    // 78 Manage Listings
    AppRouter.router.go('/admin/listings');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.textContaining('Manage Campus Listings'), findsOneWidget);

    // 79 Payments Review
    AppRouter.router.go('/admin/payments');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.text('Payments Review'), findsOneWidget);

    // 80 Payment Detail
    AppRouter.router.go('/admin/payment/pay_1');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.text('Payment Verification'), findsOneWidget);

    // 81 Impact Stats
    AppRouter.router.go('/admin/stats');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.text('Campus Circular Stats'), findsOneWidget);

    // 84 Admin Profile
    AppRouter.router.go('/admin/profile');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.text('Admin Profile'), findsOneWidget);
  });
}

