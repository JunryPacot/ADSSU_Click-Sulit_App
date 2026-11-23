import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/item_model.dart';
import '../../data/models/external_product_model.dart';
import '../../data/mock/seed_data.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/onboarding_screens.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_step1_screen.dart';
import '../../features/auth/register_step2_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/items/item_detail_screen.dart';
import '../../features/items/add_edit_item_screen.dart';
import '../../features/browse/external_deals_screen.dart';
import '../../features/browse/external_deal_detail_screen.dart';
import '../../features/activity/saved_items_screen.dart';
import '../../features/profile/profile_screen.dart';
import 'route_names.dart';

/// Central application navigation configuration using GoRouter.
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // 1. Animated Splash Screen
      GoRoute(
        path: '/',
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // 2. Onboarding Steps (1, 2, 3)
      GoRoute(
        path: '/onboarding-sell',
        name: RouteNames.onboardingSell,
        builder: (context, state) => OnboardingScreen.sell(context),
      ),
      GoRoute(
        path: '/onboarding-exchange',
        name: RouteNames.onboardingExchange,
        builder: (context, state) => OnboardingScreen.exchange(context),
      ),
      GoRoute(
        path: '/onboarding-donate',
        name: RouteNames.onboardingDonate,
        builder: (context, state) => OnboardingScreen.donate(context),
      ),

      // 3. Login Screen
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // 4. Registration Flow
      GoRoute(
        path: '/register-1',
        name: RouteNames.register1,
        builder: (context, state) => const RegisterStep1Screen(),
      ),
      GoRoute(
        path: '/register-2',
        name: RouteNames.register2,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;
          return RegisterStep2Screen(initialData: data);
        },
      ),

      // 5. Campus Marketplace (Home Screen)
      GoRoute(
        path: '/home',
        name: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
      ),

      // 6. Item Detail Screen (Parameter Passing)
      GoRoute(
        path: '/item-detail',
        name: RouteNames.itemDetail,
        builder: (context, state) {
          final item = state.extra as ItemModel? ?? SeedData.initialItems.first;
          return ItemDetailScreen(item: item);
        },
      ),

      // 7. External Deals Screen (REST API Integration)
      GoRoute(
        path: '/external-deals',
        name: RouteNames.externalDeals,
        builder: (context, state) => const ExternalDealsScreen(),
      ),

      // 8. External Deal Detail Screen (Parameter Passing for API products)
      GoRoute(
        path: '/deal-detail',
        name: RouteNames.dealDetail,
        builder: (context, state) {
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

      // 9. Saved Items Screen (SharedPreferences Persistence)
      GoRoute(
        path: '/saved',
        name: RouteNames.saved,
        builder: (context, state) => const SavedItemsScreen(),
      ),
      GoRoute(
        path: '/saved-items',
        name: RouteNames.savedItems,
        builder: (context, state) => const SavedItemsScreen(),
      ),

      // 10. Post New Item Screen (Local Storage Create)
      GoRoute(
        path: '/add-item',
        name: RouteNames.addItem,
        builder: (context, state) => const AddEditItemScreen(),
      ),

      // 11. Edit Item Screen (Local Storage Update)
      GoRoute(
        path: '/edit-item',
        name: RouteNames.editItem,
        builder: (context, state) {
          final item = state.extra as ItemModel?;
          return AddEditItemScreen(itemToEdit: item);
        },
      ),

      // 12. Student Profile Screen
      GoRoute(
        path: '/profile',
        name: RouteNames.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}
