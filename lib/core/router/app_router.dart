import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/item_model.dart';
import '../../data/models/external_product_model.dart';
import '../../data/mock/seed_data.dart';
import '../../features/auth/login_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/items/item_detail_screen.dart';
import '../../features/items/add_edit_item_screen.dart';
import '../../features/browse/external_deals_screen.dart';
import '../../features/browse/external_deal_detail_screen.dart';
import '../../features/activity/saved_items_screen.dart';
import '../../features/profile/profile_screen.dart';
import 'route_names.dart';

/// Central application navigation configuration using GoRouter.
/// Fulfills Task 2 (Stack Navigation) and Task 3 (Data Passing Between Screens).
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // 1. Campus Marketplace (Home Screen)
      GoRoute(
        path: '/',
        name: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
      ),

      // 2. Student Login Screen
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // 3. Item Detail Screen (TASK 3: Parameter Passing Demonstration)
      GoRoute(
        path: '/item-detail',
        name: RouteNames.itemDetail,
        builder: (context, state) {
          // PARAMETER PASSING: Retrieves the ItemModel passed via 'extra'
          final item = state.extra as ItemModel? ?? SeedData.initialItems.first;
          return ItemDetailScreen(item: item);
        },
      ),

      // 4. External REST API Deals Screen (LAB TASK 1)
      GoRoute(
        path: '/external-deals',
        name: RouteNames.externalDeals,
        builder: (context, state) => const ExternalDealsScreen(),
      ),

      // 5. External Deal Detail Screen (TASK 3: Parameter Passing Demonstration for API Products)
      GoRoute(
        path: '/deal-detail',
        name: RouteNames.dealDetail,
        builder: (context, state) {
          // PARAMETER PASSING: Retrieves the ExternalProductModel passed via 'extra'
          final product = state.extra as ExternalProductModel? ??
              const ExternalProductModel(
                id: 1,
                title: 'Scientific Calculator fx-991ES',
                description: 'Advanced student calculator from external API.',
                price: 25.0,
                category: 'Gadgets',
                thumbnail: '',
              );
          return ExternalDealDetailScreen(product: product);
        },
      ),

      // 6. Saved Items Screen (LAB TASK 2: SharedPreferences READ & DELETE)
      GoRoute(
        path: '/saved',
        name: RouteNames.saved,
        builder: (context, state) => const SavedItemsScreen(),
      ),

      // 7. Post New Item Screen (LAB TASK 2: SharedPreferences CREATE)
      GoRoute(
        path: '/add-item',
        name: RouteNames.addItem,
        builder: (context, state) => const AddEditItemScreen(),
      ),

      // 8. Edit Item Screen (LAB TASK 2: SharedPreferences UPDATE with Parameter Passing)
      GoRoute(
        path: '/edit-item',
        name: RouteNames.editItem,
        builder: (context, state) {
          final item = state.extra as ItemModel?;
          return AddEditItemScreen(itemToEdit: item);
        },
      ),

      // 9. Student Profile Screen
      GoRoute(
        path: '/profile',
        name: RouteNames.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Text('Page not found: ${state.uri.path}'),
      ),
    ),
  );
}
