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

  testWidgets('Screen 24: Item Detail (Sell) renders price, seller, and action buttons', (WidgetTester tester) async {
    setupViewport(tester);
    AppRouter.router.go('/item/sell/item_1');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Calculus textbook'), findsWidgets);
    expect(find.text('₱250.00'), findsOneWidget);
    expect(find.text('Buy Request'), findsOneWidget);
    expect(find.text('Message'), findsOneWidget);
  });

  testWidgets('Screen 25: Item Detail (Exchange) renders exchange info and offer button', (WidgetTester tester) async {
    setupViewport(tester);
    AppRouter.router.go('/item/exchange/item_2');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('CTE uniform size M'), findsWidgets);
    expect(find.text('FOR EXCHANGE'), findsOneWidget);
    expect(find.text('Offer Exchange'), findsOneWidget);
    expect(find.text('Message'), findsOneWidget);
  });

  testWidgets('Screen 26: Item Detail (Donate) renders free donation badge and request button', (WidgetTester tester) async {
    setupViewport(tester);
    AppRouter.router.go('/item/donate/item_4');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Bond paper, half ream'), findsWidgets);
    expect(find.text('FREE DONATION'), findsOneWidget);
    expect(find.text('Request Item'), findsOneWidget);
  });

  testWidgets('Screen 27: Photo Viewer renders', (WidgetTester tester) async {
    setupViewport(tester);
    AppRouter.router.go('/photo-viewer');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Photo Viewer'), findsOneWidget);
  });

  testWidgets('Screen 28: Seller Profile renders seller name and listings', (WidgetTester tester) async {
    setupViewport(tester);
    AppRouter.router.go('/seller/user_juan');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Juan Dela Cruz'), findsOneWidget);
    expect(find.text('About Seller'), findsOneWidget);
  });

  testWidgets('Screen 29 & 30: Report Item and Report Sent flow', (WidgetTester tester) async {
    setupViewport(tester);
    AppRouter.router.go('/report-item/item_1');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Report Listing'), findsOneWidget);
    expect(find.text('Why are you reporting this item?'), findsOneWidget);

    // Navigate to Report Sent (Screen 30)
    AppRouter.router.go('/report-sent');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Report Submitted'), findsOneWidget);
    expect(find.text('Back to Home'), findsOneWidget);
  });

  testWidgets('Screen 31 & 32: Buy Request and Request Sent screens render', (WidgetTester tester) async {
    setupViewport(tester);
    AppRouter.router.go('/buy-request/item_1');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Buy Request'), findsWidgets);
    expect(find.text('Select Meet-Up Building'), findsOneWidget);
    expect(find.text('Send Buy Request'), findsOneWidget);

    AppRouter.router.go('/buy-request-sent');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Buy Request Sent!'), findsOneWidget);
    expect(find.text('Open Chat'), findsOneWidget);
  });

  testWidgets('Screen 33 & 34: Offer Exchange and Sent screens render', (WidgetTester tester) async {
    setupViewport(tester);
    AppRouter.router.go('/offer-exchange/item_2');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Offer an Exchange'), findsOneWidget);
    expect(find.text('Item You Want'), findsOneWidget);

    AppRouter.router.go('/exchange-offer-sent');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Exchange Offer Sent!'), findsOneWidget);
  });

  testWidgets('Screen 35 & 36: Request Donation and Sent screens render', (WidgetTester tester) async {
    setupViewport(tester);
    AppRouter.router.go('/request-donation/item_4');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Request Donation'), findsOneWidget);
    expect(find.text('Send Donation Request'), findsOneWidget);

    AppRouter.router.go('/donation-sent');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Donation Request Sent!'), findsOneWidget);
  });

  testWidgets('Screen 37 & 38: Messages and Chat screens render', (WidgetTester tester) async {
    setupViewport(tester);
    AppRouter.router.go('/messages');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Messages'), findsWidgets);
    expect(find.text('Chats'), findsOneWidget);
    expect(find.text('Requests'), findsOneWidget);

    AppRouter.router.go('/chat/chat_juan');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Set Meet-up'), findsOneWidget);
  });

  testWidgets('Screen 39: Requests and Offers renders Received & Sent tabs', (WidgetTester tester) async {
    setupViewport(tester);
    AppRouter.router.go('/requests-offers');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Requests & Offers'), findsOneWidget);
    expect(find.text('Received'), findsOneWidget);
    expect(find.text('Sent'), findsOneWidget);
  });

  testWidgets('Screen 40 & 82: Meet-Up Spot and Specific Location render', (WidgetTester tester) async {
    setupViewport(tester);
    AppRouter.router.go('/meet-up-spot');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Confirm Meet-Up Spot'), findsOneWidget);
    expect(find.text('Designated Meet-Up Building'), findsOneWidget);

    AppRouter.router.go('/meet-up/specific');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Specific Location Details'), findsOneWidget);
    expect(find.text('Save Location'), findsOneWidget);
  });

  testWidgets('Screen 41: Meet-Up Confirmed renders actions', (WidgetTester tester) async {
    setupViewport(tester);
    AppRouter.router.go('/meet-up-confirmed');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Meet-Up Agreed!'), findsOneWidget);
    expect(find.text('Mark as Completed'), findsOneWidget);
    expect(find.text('Open Chat'), findsOneWidget);
  });

  testWidgets('Screen 42, 43, 44: Complete Transaction, Rate & Review, Submitted render', (WidgetTester tester) async {
    setupViewport(tester);
    AppRouter.router.go('/complete-deal');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Complete Deal'), findsOneWidget);
    expect(find.text('Confirm Completed'), findsOneWidget);

    AppRouter.router.go('/rate-review');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Rate & Review'), findsOneWidget);
    expect(find.text('How was your exchange?'), findsOneWidget);
    expect(find.text('Submit Review'), findsOneWidget);

    AppRouter.router.go('/review-submitted');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Review Submitted!'), findsOneWidget);
    expect(find.text('View My Impact'), findsOneWidget);
  });
}
