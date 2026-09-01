import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookmate/core/theme/app_theme.dart';
import 'package:cookmate/features/recipes/domain/entities/recipe.dart';
import 'package:cookmate/features/recipes/presentation/widgets/recipe_card.dart';
import 'package:cookmate/l10n/app_localizations.dart';

void main() {
  final sampleRecipe = Recipe(
    id: 'recipe_1',
    title: 'Akki Rotti',
    description: 'Crispy rice flour flatbread with onions and coriander',
    chefName: 'Traditional Chef',
    imageUrl: 'assets/images/recipes/akki_rotti.jpg',
    cuisine: 'Malnad',
    region: 'Malnad, Karnataka',
    prepTimeMinutes: 10,
    cookTimeMinutes: 20,
    servings: 4,
    difficulty: RecipeDifficulty.easy,
    isVegetarian: true,
    rating: 4.8,
    tags: const ['Breakfast', 'Malnad'],
    createdAt: DateTime.now(),
    ingredients: const [],
    instructions: const [],
    categoryId: 'cat_malnad',
  );

  final longNameRecipe = Recipe(
    id: 'recipe_2',
    title: 'Halasina Hannina Idli with Steamed Coconut Chutney',
    description: 'Traditional jackfruit steamed cakes',
    chefName: 'Malnad Amma',
    imageUrl: 'assets/images/recipes/halasina_hannina_idli.jpg',
    cuisine: 'Malnad Heritage',
    region: 'Thirthahalli, Malnad',
    prepTimeMinutes: 15,
    cookTimeMinutes: 25,
    servings: 4,
    difficulty: RecipeDifficulty.medium,
    isVegetarian: true,
    rating: 4.9,
    tags: const ['Heritage', 'Malnad'],
    createdAt: DateTime.now(),
    ingredients: const [],
    instructions: const [],
    categoryId: 'cat_malnad',
  );

  Widget createWidgetUnderTest(Widget child, {Size screenSize = const Size(390, 844)}) {
    return ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.darkTheme,
        home: MediaQuery(
          data: MediaQueryData(size: screenSize),
          child: Scaffold(
            body: Center(
              child: SizedBox(
                width: 175,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('Compact RecipeCard Widget Tests', () {
    testWidgets('RecipeCard renders compact layout without overflow for standard recipe', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          RecipeCard(
            recipe: sampleRecipe,
            onTap: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Akki Rotti'), findsOneWidget);
      expect(find.text('Malnad, Karnataka'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
      expect(find.text('30 mins'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('RecipeCard renders 2-line long title without overflow', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          RecipeCard(
            recipe: longNameRecipe,
            onTap: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Halasina Hannina Idli with Steamed Coconut Chutney'), findsOneWidget);
      expect(find.text('Thirthahalli, Malnad'), findsOneWidget);
      expect(find.text('4.9'), findsOneWidget);
      expect(find.text('40 mins'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('RecipeCard renders inside 2-column GridView without overflow on small and large screens', (tester) async {
      for (final width in [320.0, 375.0, 390.0, 414.0, 768.0]) {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: AppTheme.darkTheme,
              home: MediaQuery(
                data: MediaQueryData(size: Size(width, 800)),
                child: Scaffold(
                  body: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: 4,
                    itemBuilder: (ctx, idx) {
                      return RecipeCard(
                        recipe: idx.isEven ? sampleRecipe : longNameRecipe,
                        onTap: () {},
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'Must have 0 overflows on width $width');
      }
    });

    testWidgets('RecipeCard horizontal mode renders properly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: SizedBox(
                width: 350,
                child: RecipeCard(
                  recipe: sampleRecipe,
                  isHorizontal: true,
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Akki Rotti'), findsOneWidget);
      expect(find.text('Malnad, Karnataka'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
