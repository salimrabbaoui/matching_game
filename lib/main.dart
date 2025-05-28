import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'core/services/storage_service.dart';
import 'core/services/ad_service.dart';
import 'heart_manager.dart';
import 'subscription_service.dart';
import 'features/menu/menu_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize core services
  await _initializeServices();

  runApp(const MyApp());
}

Future<void> _initializeServices() async {
  try {
    await StorageService().initialize();
    await HeartManager().initialize();
    await SubscriptionService().initialize();
    await AdService.instance.initialize();
  } catch (e) {
    debugPrint('Error initializing services: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sock Matching Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstants.primaryColor,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',

        // Custom theme components
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
          ),
        ),

        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          elevation: 4,
        ),

        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
          ),
        ),
      ),
      home: const MenuPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
