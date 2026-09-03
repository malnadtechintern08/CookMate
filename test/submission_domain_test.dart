import 'package:flutter_test/flutter_test.dart';
import 'package:cookmate/features/submissions/domain/entities/recipe_submission.dart';
import 'package:cookmate/features/submissions/data/models/recipe_submission_model.dart';

void main() {
  group('Recipe Submission Domain & Model Tests', () {
    test('SubmissionStatus fromString parses all states accurately', () {
      expect(SubmissionStatus.fromString('pending'), equals(SubmissionStatus.pending));
      expect(SubmissionStatus.fromString('under_review'), equals(SubmissionStatus.underReview));
      expect(SubmissionStatus.fromString('changes_requested'), equals(SubmissionStatus.changesRequested));
      expect(SubmissionStatus.fromString('approved'), equals(SubmissionStatus.approved));
      expect(SubmissionStatus.fromString('rejected'), equals(SubmissionStatus.rejected));
      expect(SubmissionStatus.fromString('published'), equals(SubmissionStatus.published));
      expect(SubmissionStatus.fromString('unknown_value'), equals(SubmissionStatus.pending));
      expect(SubmissionStatus.fromString(null), equals(SubmissionStatus.pending));
    });

    test('RecipeSubmissionModel parses complete JSON correctly', () {
      final json = {
        'id': 101,
        'recipe_name': 'Akki Roti with Chutney',
        'description': 'Traditional Malnad rice flour roti served with coconut chutney.',
        'category_id': 'cat_malnad',
        'category_name': 'Malnad Special',
        'category_color': '0xFF2E7D32',
        'image': 'uploads/recipe-submissions/sub_101.jpg',
        'preparation_time': 15,
        'cooking_time': 25,
        'difficulty': 'Medium',
        'servings': 4,
        'cuisine': 'Malnad',
        'food_type': 'Vegetarian',
        'notes': 'Best served hot with fresh butter.',
        'status': 'published',
        'allow_publication': 1,
        'show_author_name': 1,
        'author_display_name': 'Asha Rao',
        'admin_notes': 'Exemplary authentic recipe.',
        'rejection_reason': null,
        'published_recipe_id': 'recipe_c_101_abc123',
        'submitted_at': '2026-09-03T10:00:00Z',
        'reviewed_at': '2026-09-03T10:30:00Z',
        'tags': ['akki_roti', 'breakfast', 'malnad'],
        'ingredient_count': 2,
        'step_count': 2,
        'ingredients': [
          {'name': 'Rice Flour', 'quantity': '2', 'unit': 'cups', 'position': 1},
          {'name': 'Grated Coconut', 'quantity': '0.5', 'unit': 'cup', 'position': 2},
        ],
        'steps': [
          {'step_number': 1, 'instruction': 'Mix flour with warm water and herbs.', 'timer_seconds': 300},
          {'step_number': 2, 'instruction': 'Pat onto skillet and cook with ghee until golden.', 'timer_seconds': 480},
        ],
      };

      final model = RecipeSubmissionModel.fromJson(json);

      expect(model.id, equals(101));
      expect(model.recipeName, equals('Akki Roti with Chutney'));
      expect(model.totalTime, equals(40)); // 15 + 25
      expect(model.isVegetarian, isTrue);
      expect(model.isPublished, isTrue);
      expect(model.allowPublication, isTrue);
      expect(model.showAuthorName, isTrue);
      expect(model.authorDisplayName, equals('Asha Rao'));
      expect(model.publishedRecipeId, equals('recipe_c_101_abc123'));
      expect(model.tags.length, equals(3));
      expect(model.ingredients.length, equals(2));
      expect(model.steps.length, equals(2));
      expect(model.steps[0].timerSeconds, equals(300));
    });

    test('RecipeSubmission privacy: anonymous publication sets showAuthorName to false', () {
      final json = {
        'id': 102,
        'recipe_name': 'Secret Malnad Herbal Kashaya',
        'description': 'Family herbal tonic.',
        'category_id': 'cat_drinks',
        'food_type': 'Vegetarian',
        'status': 'pending',
        'allow_publication': 1,
        'show_author_name': 0,
        'author_display_name': null,
        'submitted_at': '2026-09-03T12:00:00Z',
      };

      final model = RecipeSubmissionModel.fromJson(json);

      expect(model.showAuthorName, isFalse);
      expect(model.allowPublication, isTrue);
      expect(model.isPending, isTrue);
      expect(model.isPublished, isFalse);
    });
  });
}
