import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adssu_click_and_sulit/data/models/external_product_model.dart';
import 'package:adssu_click_and_sulit/data/models/user_model.dart';
import 'package:adssu_click_and_sulit/data/models/item_model.dart';
import 'package:adssu_click_and_sulit/data/services/local_storage_service.dart';
import 'package:adssu_click_and_sulit/data/services/external_api_service.dart';
import 'package:adssu_click_and_sulit/data/mock/mock_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Lab 4 - Task 1: External API Integration & Data Retrieval', () {
    test('ExternalProductModel parses JSON correctly with PHP currency calculation', () {
      final sampleJson = {
        'id': 101,
        'title': 'Scientific Calculator fx-991ES',
        'description': 'Advanced natural textbook display calculator.',
        'price': 25.0, // USD
        'discountPercentage': 12.5,
        'rating': 4.8,
        'stock': 15,
        'brand': 'Casio',
        'category': 'accessories',
        'thumbnail': 'https://dummyjson.com/image/101.png',
        'images': ['https://dummyjson.com/image/101.png'],
      };

      final product = ExternalProductModel.fromJson(sampleJson);

      expect(product.id, 101);
      expect(product.title, 'Scientific Calculator fx-991ES');
      expect(product.brand, 'Casio');
      expect(product.price, 25.0);
      expect(product.pricePhp, 25.0 * 58.0); // ₱1450.00
      expect(product.formattedPricePhp, '₱1450.00');
      expect(product.rating, 4.8);
      expect(product.isSavedLocally, false);
    });

    test('ExternalProductModel serializes to JSON correctly', () {
      const product = ExternalProductModel(
        id: 202,
        title: 'College Backpack',
        description: 'Waterproof laptop backpack',
        price: 30.0,
        category: 'accessories',
        thumbnail: 'https://dummyjson.com/bag.png',
        isSavedLocally: true,
      );

      final json = product.toJson();
      expect(json['id'], 202);
      expect(json['title'], 'College Backpack');
      expect(json['isSavedLocally'], true);
    });

    test('ExternalApiService provides available categories', () {
      final service = ExternalApiService();
      final categories = service.getAvailableCategories();
      expect(categories, contains('All'));
      expect(categories, contains('Smartphones'));
      expect(categories, contains('Laptops'));
      expect(categories, contains('Accessories'));
    });
  });

  group('Lab 4 - Task 2 & Task 3: Local Data Storage & CRUD Persistence', () {
    late LocalStorageService storageService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storageService = LocalStorageService();
    });

    test('CRUD 1 (Create & Read): User registration saves to local storage', () async {
      final user = const UserModel(
        id: 'user_local_1',
        name: 'Maria Santos',
        email: 'maria.santos@adssu.edu.ph',
        college: 'College of Agriculture (CA)',
        studentId: '2024-ADSSU-0089',
        isVerified: true,
      );

      // Create: Save user to device local storage
      await storageService.saveUser(user, 'SecurePass123!');

      // Read: Retrieve users from device storage
      final loadedUsers = await storageService.loadUsers();
      expect(loadedUsers.any((u) => u.email == 'maria.santos@adssu.edu.ph'), isTrue);

      final passwords = await storageService.loadPasswords();
      expect(passwords['maria.santos@adssu.edu.ph'], 'SecurePass123!');
    });

    test('CRUD 2 (Create & Read): Persist and restore active session', () async {
      await storageService.setCurrentUserEmail('maria.santos@adssu.edu.ph');
      final activeEmail = await storageService.getCurrentUserEmail();
      expect(activeEmail, 'maria.santos@adssu.edu.ph');

      await storageService.setCurrentUserEmail(null);
      final clearedEmail = await storageService.getCurrentUserEmail();
      expect(clearedEmail, isNull);
    });

    test('CRUD 3 (Create, Read, Delete): External API product bookmarking persistence', () async {
      const product = ExternalProductModel(
        id: 77,
        title: 'Drafting Board',
        description: 'A2 Architecture drafting board',
        price: 45.0,
        category: 'supplies',
        thumbnail: 'https://dummyjson.com/drafting.png',
      );

      // Create: Save external product locally
      await storageService.saveExternalProduct(product);

      // Read: Retrieve saved products
      var saved = await storageService.loadSavedExternalProducts();
      expect(saved.length, 1);
      expect(saved.first.id, 77);
      expect(saved.first.title, 'Drafting Board');
      expect(saved.first.isSavedLocally, isTrue);

      // Delete: Remove external product from local storage
      await storageService.deleteExternalProduct(77);
      saved = await storageService.loadSavedExternalProducts();
      expect(saved.isEmpty, isTrue);
    });

    test('CRUD 4 (Create, Update, Delete): Marketplace items local persistence', () async {
      final item = ItemModel(
        id: 'item_local_test',
        title: 'Used Medical Lab Coat',
        description: 'Clean size S lab coat',
        price: 150.0,
        category: 'Uniforms',
        type: 'SELL',
        condition: 'Good',
        sellerId: 'user_1',
        sellerName: 'Student Seller',
        sellerCollege: 'CAS',
        createdAt: DateTime.now(),
      );

      // Create: Save items list
      await storageService.saveItems([item]);

      // Read: Retrieve items list
      var loaded = await storageService.loadItems();
      expect(loaded.length, 1);
      expect(loaded.first.title, 'Used Medical Lab Coat');
      expect(loaded.first.price, 150.0);

      // Update: Modify item and re-persist
      final updated = item.copyWith(price: 120.0, condition: 'Like New');
      await storageService.saveItems([updated]);
      loaded = await storageService.loadItems();
      expect(loaded.first.price, 120.0);
      expect(loaded.first.condition, 'Like New');

      // Delete: Clear items
      await storageService.saveItems([]);
      loaded = await storageService.loadItems();
      expect(loaded.isEmpty, isTrue);
    });

    test('MockDatabase manages user registration and authentication locally', () async {
      final db = MockDatabase();

      // Register new student account
      await db.registerUser(
        name: 'Jose Rizal',
        email: 'jose.rizal@adssu.edu.ph',
        college: 'College of Arts and Sciences (CAS)',
        studentId: '2024-ADSSU-0101',
        password: 'HeroPassword123!',
      );

      expect(db.currentUser.name, 'Jose Rizal');
      expect(db.currentUser.email, 'jose.rizal@adssu.edu.ph');

      // Test login with valid credentials
      final loginSuccess = await db.login('jose.rizal@adssu.edu.ph', 'HeroPassword123!');
      expect(loginSuccess, isTrue);

      // Test login with invalid password
      expect(
        () => db.login('jose.rizal@adssu.edu.ph', 'WrongPassword!'),
        throwsException,
      );

      // Test non-institutional email rejection
      final invalidDomain = await db.login('intruder@gmail.com', 'password123');
      expect(invalidDomain, isFalse);
    });
  });
}
