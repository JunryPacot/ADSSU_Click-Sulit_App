import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/constants/campus_constants.dart';
import 'data/mock/mock_database.dart';
import 'data/services/firebase_service.dart';
import 'data/firebase_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with robust error handling to prevent crash-on-launch
  try {
    final isFirebaseConnected = await FirebaseService().initialize();
    if (isFirebaseConnected) {
      try {
        await FirebaseSeeder().seedInitialData();
      } catch (_) {
        // Seeder failure is non-fatal — app works without seed data
      }
      try {
        MockDatabase().bindRealtimeFirebase();
      } catch (_) {
        // Stream binding failure is non-fatal — falls back to local data
      }
    }
  } catch (_) {
    // Firebase init failure is non-fatal — app runs in offline/local mode
  }

  runApp(const AdssuClickAndSulitApp());
}

class AdssuClickAndSulitApp extends StatelessWidget {
  const AdssuClickAndSulitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MockDatabase>.value(
      value: MockDatabase(),
      child: MaterialApp.router(
        title: CampusConstants.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
