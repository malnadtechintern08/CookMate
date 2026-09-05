import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookmate/core/theme/app_theme.dart';
import 'package:cookmate/features/categories/domain/entities/category.dart';
import 'package:cookmate/features/categories/presentation/widgets/category_card_widget.dart';
import 'package:cookmate/features/recipes/domain/entities/recipe.dart';
import 'package:cookmate/features/recipes/presentation/screens/home_screen.dart';
import 'package:cookmate/features/recipes/presentation/widgets/featured_recipe_card.dart';
import 'package:cookmate/features/recipes/presentation/widgets/recipe_card.dart';
import 'package:cookmate/features/recipes/presentation/widgets/recipe_filter_bottom_sheet.dart';
import 'package:cookmate/features/rating/presentation/screens/rate_us_screen.dart';
import 'package:cookmate/features/splash/presentation/screens/splash_screen.dart';
import 'package:cookmate/features/support/presentation/screens/contact_us_screen.dart';
import 'package:cookmate/features/support/presentation/screens/safety_guidelines_screen.dart';
import 'package:cookmate/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sampleRecipe = Recipe(
    id: 'recipe_test_1',
    title: 'Halasina Hannina Idli with Steamed Coconut Chutney and Filter Coffee',
    description: 'Crispy rice flour flatbread with onions and coriander and authentic spices',
    chefName: 'Traditional Heritage Chef Amma',
    imageUrl: 'assets/images/recipes/akki_rotti.jpg',
    cuisine: 'Malnad Heritage Cuisine',
    region: 'Thirthahalli, Malnad, Karnataka',
    prepTimeMinutes: 15,
    cookTimeMinutes: 25,
    servings: 4,
    difficulty: RecipeDifficulty.medium,
    isVegetarian: true,
    rating: 4.8,
    tags: const ['Breakfast', 'Malnad', 'Traditional'],
    createdAt: DateTime.now(),
    ingredients: const [],
    instructions: const [],
    categoryId: 'cat_malnad',
  );

  final sampleCategory = Category(
    id: 'cat_test_1',
    name: 'Malnad Traditional Breakfast',
    iconName: 'restaurant_menu',
    colorHex: '0xFF2E7D32',
    recipeCount: 50,
    description: 'Authentic heritage dishes crafted with local Western Ghats ingredients',
  );

  group('Small Screen Device Compatibility & Zero Overflow Tests', () {
    final testSizes = [
      const Size(320, 568), // iPhone SE 1st gen / ultra small Android
      const Size(360, 640), // Most common budget Android
      const Size(375, 667), // iPhone SE 2/3 / iPhone 8
      const Size(390, 844), // Modern iPhone 13/14/15
      const Size(412, 915), // Google Pixel / Galaxy S21
    ];

    for (final size in testSizes) {
      testWidgets('HomeScreen zero overflow on ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: AppTheme.darkTheme,
              home: const HomeScreen(),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(tester.takeException(), isNull, reason: 'HomeScreen overflow on ${size.width}x${size.height}');
      });

      testWidgets('RecipeCard 2-col grid card zero overflow on ${size.width} width', (tester) async {
        final cardWidth = (size.width - 32 - 14) / 2;
        final childRatio = size.width < 360 ? 0.70 : 0.76;
        final cardHeight = cardWidth / childRatio;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: AppTheme.darkTheme,
              home: Scaffold(
                body: SizedBox(
                  width: cardWidth,
                  height: cardHeight,
                  child: RecipeCard(
                    recipe: sampleRecipe,
                    onTap: () {},
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'RecipeCard overflow on card width $cardWidth');
      });

      testWidgets('CategoryCardWidget zero overflow on ${size.width} width', (tester) async {
        final cardWidth = (size.width - 32 - 14) / 2;
        final cardHeight = cardWidth / (size.width < 360 ? 0.94 : 1.05);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: CategoryCardWidget(
                  category: sampleCategory,
                  onTap: () {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'CategoryCardWidget overflow on card width $cardWidth');
      });

      testWidgets('FeaturedRecipeCard zero overflow on ${size.width} width', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: Scaffold(
                body: SizedBox(
                  width: size.width,
                  height: 240,
                  child: FeaturedRecipeCard(
                    recipe: sampleRecipe,
                    onTap: () {},
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'FeaturedRecipeCard overflow on ${size.width}');
      });

      testWidgets('RecipeFilterBottomSheet zero overflow on ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: AppTheme.darkTheme,
              home: const Scaffold(
                body: RecipeFilterBottomSheet(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'RecipeFilterBottomSheet overflow on ${size.width}x${size.height}');
      });

      testWidgets('ContactUsScreen zero overflow on ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              themeMode: ThemeMode.dark,
              home: ContactUsScreen(),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(tester.takeException(), isNull, reason: 'ContactUsScreen overflow on ${size.width}x${size.height}');
      });

      testWidgets('SafetyGuidelinesScreen zero overflow on ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              themeMode: ThemeMode.dark,
              home: SafetyGuidelinesScreen(),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(tester.takeException(), isNull, reason: 'SafetyGuidelinesScreen overflow on ${size.width}x${size.height}');
      });

      testWidgets('RateUsScreen zero overflow on ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const MaterialApp(
            themeMode: ThemeMode.dark,
            home: RateUsScreen(initialStars: 2),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(tester.takeException(), isNull, reason: 'RateUsScreen overflow on ${size.width}x${size.height}');
      });

      testWidgets('SplashScreen zero overflow on ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const MaterialApp(
            home: SplashScreen(),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(tester.takeException(), isNull, reason: 'SplashScreen overflow on ${size.width}x${size.height}');
      });
    }
  });
}
