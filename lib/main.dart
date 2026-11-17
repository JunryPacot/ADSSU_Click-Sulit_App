import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/constants/campus_constants.dart';
import 'data/mock/mock_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize and restore persistent local storage
  final db = MockDatabase();
  await db.restorePersistedData();

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
