import 'package:flutter_test/flutter_test.dart';
import 'package:cookmate/features/recipes/domain/entities/ingredient.dart';
import 'package:cookmate/features/recipes/domain/entities/instruction_step.dart';
import 'package:cookmate/features/recipes/domain/entities/recipe.dart';

void main() {
  group('Recipe Domain Unit Tests', () {
    test('Ingredient scaling calculates scaled amounts correctly', () {
      const ingredient = Ingredient(
        name: 'Spaghetti',
        amount: 200.0,
        unit: 'g',
      );

      final scaledFor4 = ingredient.scale(2.0);
      expect(scaledFor4.amount, equals(400.0));
      expect(scaledFor4.unit, equals('g'));

      final scaledFor1 = ingredient.scale(0.5);
      expect(scaledFor1.amount, equals(100.0));
    });

    test('InstructionStep properly identifies timer presence', () {
      const stepWithTimer = InstructionStep(
        stepNumber: 1,
        instruction: 'Boil water for 10 minutes',
        timerSeconds: 600,
      );
      expect(stepWithTimer.hasTimer, isTrue);

      const stepWithoutTimer = InstructionStep(
        stepNumber: 2,
        instruction: 'Season with salt and pepper',
        timerSeconds: null,
      );
      expect(stepWithoutTimer.hasTimer, isFalse);
    });

    test('Recipe totalTimeMinutes sums prep and cook time', () {
      final recipe = Recipe(
        id: 'test-1',
        title: 'Test Pasta',
        description: 'Delicious pasta recipe',
        chefName: 'Chef Luigi',
        cuisine: 'Italian',
        imageUrl: 'https://example.com/pasta.jpg',
        prepTimeMinutes: 15,
        cookTimeMinutes: 20,
        servings: 4,
        difficulty: RecipeDifficulty.easy,
        categoryId: 'cat_italian',
        tags: const ['Italian', 'Pasta'],
        createdAt: DateTime.now(),
      );

      expect(recipe.totalTimeMinutes, equals(35));
    });

    test('RecipeDifficulty fromString maps correctly', () {
      expect(RecipeDifficulty.fromString('easy'), equals(RecipeDifficulty.easy));
      expect(RecipeDifficulty.fromString('Medium'), equals(RecipeDifficulty.medium));
      expect(RecipeDifficulty.fromString('HARD'), equals(RecipeDifficulty.hard));
      expect(RecipeDifficulty.fromString('unknown'), equals(RecipeDifficulty.medium));
    });
  });
}
