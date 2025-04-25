// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_book/data/repositories/recipe_repository.dart';
import 'package:recipe_book/models/category.dart';
import 'package:recipe_book/models/recipe.dart';
import 'package:recipe_book/providers/providers.dart';
import 'package:recipe_book/screens/home/home_screen.dart';

// Mock classes
class MockRecipeRepository extends Mock implements RecipeRepository {}

void main() {
  setUpAll(() {
    // Register fallback value for any mocks that might need it
    registerFallbackValue(categoriesProvider);
  });
  
  testWidgets('HomeScreen should build without errors', (WidgetTester tester) async {
    // Create mocks
    final mockRepository = MockRecipeRepository();
    
    // Setup mock responses
    when(() => mockRepository.getCategories()).thenAnswer((_) async => [
      Category(
        id: '1', 
        name: 'Test Category', 
        thumbnailUrl: 'https://example.com/img.jpg',
        description: 'Test category description',
      ),
    ]);
    
    // Create a test recipe with all required fields
    final testRecipe = Recipe(
      id: '1',
      name: 'Test Recipe',
      category: 'Test Category',
      area: 'Test Area',
      instructions: 'Test instructions',
      thumbnailUrl: 'https://example.com/img.jpg',
      youtubeUrl: 'https://youtube.com/watch?v=123',
      ingredients: ['Test Ingredient'],
      measurements: ['1 cup'],
      ingredientsWithMeasurements: {'Test Ingredient': '1 cup'},
      tags: ['Test'],
      originalData: {'idMeal': '1', 'strMeal': 'Test Recipe'},
    );
    
    when(() => mockRepository.getRandomRecipe()).thenAnswer((_) async => testRecipe);
    when(() => mockRepository.getFavoriteIds()).thenAnswer((_) async => []);
    when(() => mockRepository.getFavoriteRecipes()).thenAnswer((_) async => []);
    when(() => mockRepository.getRecipesByCategory(any())).thenAnswer((_) async => [testRecipe]);
    
    // Build the HomeScreen directly instead of the full app
    // This avoids the splash screen with its timer
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recipeRepositoryProvider.overrideWithValue(mockRepository),
        ],
        child: MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // Pump once to allow the widget to build
    await tester.pump();

    // Verify that the HomeScreen builds without errors
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
