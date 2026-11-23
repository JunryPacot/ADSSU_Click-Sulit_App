import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adssu_click_and_sulit/core/theme/app_theme.dart';
import 'package:adssu_click_and_sulit/data/mock/mock_database.dart';
import 'package:adssu_click_and_sulit/data/mock/seed_data.dart';
import 'package:adssu_click_and_sulit/data/models/item_model.dart';
import 'package:adssu_click_and_sulit/features/home/home_screen.dart';
import 'package:adssu_click_and_sulit/features/items/item_detail_screen.dart';
import 'package:adssu_click_and_sulit/features/items/add_edit_item_screen.dart';
import 'package:adssu_click_and_sulit/features/activity/saved_items_screen.dart';
import 'package:adssu_click_and_sulit/features/profile/profile_screen.dart';

Widget _createTestWidget(Widget child, MockDatabase db) {
  return ChangeNotifierProvider<MockDatabase>.value(
    value: db,
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Lab 1 - Task 1 & Task 4: Screen Development & Consistent UI', () {
    testWidgets('Screen 1 (Marketplace) renders app title, categories, and items', (tester) async {
      final db = MockDatabase();
      await tester.pumpWidget(_createTestWidget(const HomeScreen(), db));
      await tester.pumpAndSettle();

      expect(find.text('ADSSU Click & Sulit'), findsOneWidget);
      expect(find.text('External Student Deals'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Books'), findsAtLeastNWidgets(1));
      expect(find.text('Uniforms'), findsAtLeastNWidgets(1));
      expect(find.text('Post Item'), findsOneWidget);
    });

    testWidgets('Screen 5 (Saved Items) renders tabs and local storage message', (tester) async {
      final db = MockDatabase();
      await tester.pumpWidget(_createTestWidget(const SavedItemsScreen(), db));
      await tester.pumpAndSettle();

      expect(find.text('Saved Items (Local Storage)'), findsOneWidget);
      expect(find.textContaining('Campus Items'), findsOneWidget);
      expect(find.textContaining('External Deals'), findsOneWidget);
    });

    testWidgets('Screen 7 (Profile) renders student details and edit button', (tester) async {
      final db = MockDatabase();
      await tester.pumpWidget(_createTestWidget(const ProfileScreen(), db));
      await tester.pumpAndSettle();

      expect(find.text('Student Profile'), findsOneWidget);
      expect(find.text('Maria Santos'), findsOneWidget);
      expect(find.text('student@adssu.edu.ph'), findsOneWidget);
      expect(find.textContaining('Edit Profile'), findsOneWidget);
    });
  });

  group('Lab 1 - Task 2 & Task 3: Navigation & Parameter Passing', () {
    testWidgets('Task 3: Parameter Passing renders the exact selected item information', (tester) async {
      final db = MockDatabase();
      final testItem = SeedData.initialItems.first; // Scientific Calculator fx-991ES Plus

      // Pass testItem directly as parameter to ItemDetailScreen
      await tester.pumpWidget(_createTestWidget(ItemDetailScreen(item: testItem), db));
      await tester.pumpAndSettle();

      // Verify that the screen displays the passed item's exact fields
      expect(find.text(testItem.title), findsOneWidget);
      expect(find.text(testItem.description), findsOneWidget);
      expect(find.text(testItem.category), findsOneWidget);
      expect(find.text(testItem.type), findsOneWidget);
      expect(find.text('₱${testItem.price.toStringAsFixed(2)}'), findsOneWidget);
      expect(find.text(testItem.sellerName), findsOneWidget);
      expect(find.text(testItem.sellerCollege), findsOneWidget);
    });

    testWidgets('Task 3: Parameter Passing for Edit Item pre-fills form fields', (tester) async {
      final db = MockDatabase();
      final testItem = ItemModel(
        id: 'test_edit_1',
        title: 'Algorithms in C++',
        description: 'Computer Science Textbook',
        price: 320.0,
        category: 'Books',
        type: 'SELL',
        condition: 'Good',
        sellerId: 'user_student',
        sellerName: 'Maria Santos',
        sellerCollege: 'CCIS',
        createdAt: DateTime.now(),
      );

      // Pass testItem as parameter to AddEditItemScreen
      await tester.pumpWidget(_createTestWidget(AddEditItemScreen(itemToEdit: testItem), db));
      await tester.pumpAndSettle();

      expect(find.text('Edit Listing (CRUD Update)'), findsOneWidget);
      expect(find.text('Algorithms in C++'), findsOneWidget);
      expect(find.text('Computer Science Textbook'), findsOneWidget);
    });
  });
}
