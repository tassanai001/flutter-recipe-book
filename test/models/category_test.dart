import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_book/models/category.dart';

void main() {
  group('Category Model Tests', () {
    // Test data
    final Map<String, dynamic> testJson = {
      'idCategory': '1',
      'strCategory': 'Beef',
      'strCategoryThumb': 'https://www.themealdb.com/images/category/beef.png',
      'strCategoryDescription': 'Beef is the culinary name for meat from cattle...',
    };

    test('fromJson() should correctly parse JSON data', () {
      // Act
      final category = Category.fromJson(testJson);

      // Assert
      expect(category.id, '1');
      expect(category.name, 'Beef');
      expect(category.thumbnailUrl, 'https://www.themealdb.com/images/category/beef.png');
      expect(category.description, 'Beef is the culinary name for meat from cattle...');
    });

    test('toJson() should correctly convert Category to JSON', () {
      // Arrange
      final category = Category.fromJson(testJson);
      
      // Act
      final jsonResult = category.toJson();
      
      // Assert
      expect(jsonResult['idCategory'], '1');
      expect(jsonResult['strCategory'], 'Beef');
      expect(jsonResult['strCategoryThumb'], 'https://www.themealdb.com/images/category/beef.png');
      expect(jsonResult['strCategoryDescription'], 'Beef is the culinary name for meat from cattle...');
    });

    test('equality check should work correctly', () {
      // Arrange
      final category1 = Category.fromJson(testJson);
      final category2 = Category.fromJson(testJson);
      final category3 = Category.fromJson({
        ...testJson,
        'strCategory': 'Different Name'
      });
      
      // Assert
      expect(category1, category2); // Same data, should be equal
      expect(category1, isNot(category3)); // Different name, should not be equal
    });

    test('should handle null or empty values gracefully', () {
      // Arrange
      final incompleteJson = {
        'idCategory': '1',
        'strCategory': null,
        'strCategoryThumb': '',
      };
      
      // Act
      final category = Category.fromJson(incompleteJson);
      
      // Assert
      expect(category.id, '1');
      expect(category.name, '');
      expect(category.thumbnailUrl, '');
      expect(category.description, '');
    });
  });
}
