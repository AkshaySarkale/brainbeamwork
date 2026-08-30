import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shopora/firebase_options.dart';
import 'package:shopora/app/routes/app_pages.dart';
import 'package:shopora/app/routes/app_routes.dart';
import 'package:shopora/app/theme/app_theme.dart';
import 'package:shopora/app/bindings/initial_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Failed to initialize Firebase: $e');
  }
  runApp(const ShoporaApp());
}

class ShoporaApp extends StatelessWidget {
  const ShoporaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Shopora',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      initialBinding: InitialBinding(),
      theme: AppTheme.lightTheme,
    );
  }
}
