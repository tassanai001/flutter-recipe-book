import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_book/providers/theme_provider.dart';
import 'package:recipe_book/screens/splash/splash_screen.dart';
import 'package:recipe_book/utils/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: RecipeBookApp()));
}

/// The main app widget that sets up the theme and initial route
class RecipeBookApp extends ConsumerWidget {
  const RecipeBookApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the theme provider to update the app theme when it changes
    final themeMode = ref.watch(themeProvider);
    
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
