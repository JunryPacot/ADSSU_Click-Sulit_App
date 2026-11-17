import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adssu_click_and_sulit/core/constants/campus_constants.dart';
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

  testWidgets('Screen 1 Splash renders app title', (WidgetTester tester) async {
    setupViewport(tester);
    AppRouter.router.go('/');
    await tester.pumpWidget(createTestApp());
    await tester.pump();
    expect(find.text('ADSSU Click & Sulit'), findsOneWidget);
    expect(find.text('Click, Shop, Sulit!'), findsOneWidget);
  });

  testWidgets('Screen 2, 3, 4 Onboarding flow renders correctly', (WidgetTester tester) async {
    setupViewport(tester);
    AppRouter.router.go('/onboarding-sell');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Sell What You No Longer Need'), findsOneWidget);
    expect(find.text('Next: Exchange'), findsOneWidget);

    // Tap Next to go to Exchange
    await tester.tap(find.text('Next: Exchange'));
    await tester.pumpAndSettle();

    expect(find.text('Exchange Items Hassle-Free'), findsOneWidget);
    expect(find.text('Next: Donate'), findsOneWidget);

    // Tap Next to go to Donate
    await tester.tap(find.text('Next: Donate'));
    await tester.pumpAndSettle();

    expect(find.text('Give Back and Donate'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('Screen 5 Login validates institutional email and navigates', (WidgetTester tester) async {
    setupViewport(tester);
    AppRouter.router.go('/login');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back, Adssunian!'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);

    // Enter valid institutional email and password
    final textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), CampusConstants.demoStudentEmail);
    await tester.enterText(textFields.at(1), 'password123');
    await tester.pumpAndSettle();

    final signInBtn = find.text('Sign In');
    await tester.ensureVisible(signInBtn);
    await tester.tap(signInBtn);
    await tester.pumpAndSettle();

    // Should navigate to Home (Screen 12)
    expect(find.text('Categories'), findsWidgets);
  });

  testWidgets('Screen 7 Login Error renders restricted access', (WidgetTester tester) async {
    setupViewport(tester);
    AppRouter.router.go('/login-error');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Access Restricted'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
    expect(find.text('Contact ADSSU DTC'), findsOneWidget);
  });

  testWidgets('Screen 6 Forgot Password renders DTC info', (WidgetTester tester) async {
    setupViewport(tester);
    AppRouter.router.go('/forgot-password');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Password Management'), findsOneWidget);
    expect(find.text('Managed by ADSSU DTC'), findsOneWidget);
  });

  testWidgets('Screen 8, 9, 10, 11 Registration flow works', (WidgetTester tester) async {
    setupViewport(tester);
    AppRouter.router.go('/register-1');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Tell us about yourself'), findsOneWidget);

    // Enter name, ID, and invalid email
    final textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), 'Test Student');
    await tester.enterText(textFields.at(1), '2024-TEST-0001');
    await tester.enterText(textFields.at(2), 'invalid@gmail.com');
    await tester.pumpAndSettle();

    expect(find.text('Must be an official @adssu.edu.ph institutional address'), findsOneWidget);

    // Enter valid email
    await tester.enterText(textFields.at(2), 'test.student@adssu.edu.ph');
    await tester.pumpAndSettle();

    // Now button is enabled
    final continueBtn = find.text('Continue to Step 2');
    await tester.ensureVisible(continueBtn);
    await tester.tap(continueBtn);
    await tester.pumpAndSettle();

    expect(find.text('Select your college'), findsOneWidget);
  });

  testWidgets('Screen 12 Home renders categories and item cards', (WidgetTester tester) async {
    setupViewport(tester);
    AppRouter.router.go('/home');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Categories'), findsWidgets);
    expect(find.text('Fresh on Campus'), findsOneWidget);
    expect(find.text('Books'), findsWidgets);
    expect(find.text('Uniforms'), findsWidgets);
  });

  testWidgets('Screen 13 All Categories renders category list', (WidgetTester tester) async {
    setupViewport(tester);
    AppRouter.router.go('/categories');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('All Categories'), findsOneWidget);
    expect(find.text('School Supplies'), findsOneWidget);
    expect(find.text('Other Reusable Goods'), findsOneWidget);
  });

  testWidgets('Screen 14 Category Books renders books list', (WidgetTester tester) async {
    setupViewport(tester);
    AppRouter.router.go('/category/books');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Books'), findsWidgets);
    expect(find.text('Filter'), findsOneWidget);
    expect(find.text('Sort'), findsOneWidget);
  });

  testWidgets('Screen 19 Search and Screen 20 Search Results work', (WidgetTester tester) async {
    setupViewport(tester);
    AppRouter.router.go('/search');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Popular Campus Searches'), findsOneWidget);

    // Tap tag "Calculus"
    await tester.tap(find.text('Calculus'));
    await tester.pumpAndSettle();

    expect(find.text('Search Results'), findsOneWidget);
    expect(find.textContaining('Calculus textbook'), findsWidgets);
  });

  testWidgets('Screen 21 Filter Sheet and Screen 22 Sort Sheet render', (WidgetTester tester) async {
    setupViewport(tester);
    AppRouter.router.go('/filter');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Filter Listings'), findsOneWidget);
    expect(find.text('Apply Filters'), findsOneWidget);

    AppRouter.router.go('/sort');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Sort Listings'), findsOneWidget);
    expect(find.text('Apply Sort'), findsOneWidget);
  });

  testWidgets('Screen 23 No Results renders fallback actions', (WidgetTester tester) async {
    setupViewport(tester);
    AppRouter.router.go('/no-results');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('No Matches Found'), findsOneWidget);
    expect(find.text('Clear Filters & View All'), findsOneWidget);
    expect(find.text('Post This Item Yourself'), findsOneWidget);
  });

  testWidgets('Screen 83 Community Rules renders', (WidgetTester tester) async {
    setupViewport(tester);
    AppRouter.router.go('/community-rules');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Community Rules'), findsOneWidget);
    expect(find.text('Exclusively for Adssunians'), findsOneWidget);
  });
}
