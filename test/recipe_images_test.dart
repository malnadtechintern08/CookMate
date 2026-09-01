import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookmate/core/database/seed_data.dart';

void main() {
  group('Recipe Unique Images Verification Suite', () {
    test('Verify exactly 200 recipes in SeedData with unique IDs and titles', () {
      final recipes = SeedData.recipes;
      expect(recipes.length, 200, reason: 'TOTAL RECIPES must equal 200');

      final ids = <String>{};
      final titles = <String>{};
      final duplicateIds = <String>[];
      final duplicateTitles = <String>[];

      for (final r in recipes) {
        final id = r['id'] as String;
        final title = r['title'] as String;

        if (ids.contains(id)) duplicateIds.add(id);
        ids.add(id);

        if (titles.contains(title)) duplicateTitles.add(title);
        titles.add(title);
      }

      expect(duplicateIds, isEmpty, reason: 'Duplicate recipe IDs detected: $duplicateIds');
      expect(duplicateTitles, isEmpty, reason: 'Duplicate recipe titles detected: $duplicateTitles');
      expect(ids.length, 200);
      expect(titles.length, 200);
    });

    test('Verify 200 unique image paths in SeedData', () {
      final recipes = SeedData.recipes;
      final imagePaths = <String>{};
      final duplicatePaths = <String>[];

      for (final r in recipes) {
        final img = r['image_url'] as String;
        if (imagePaths.contains(img)) {
          duplicatePaths.add(img);
        }
        imagePaths.add(img);
      }

      expect(duplicatePaths, isEmpty, reason: 'DUPLICATE IMAGE PATHS must be 0, found: $duplicatePaths');
      expect(imagePaths.length, 200, reason: 'VALID IMAGE PATHS must equal 200');
    });

    test('Verify all 200 image asset files exist on disk and are valid non-empty images', () {
      final recipes = SeedData.recipes;
      final missingFiles = <String>[];
      final emptyFiles = <String>[];

      for (final r in recipes) {
        final img = r['image_url'] as String;
        final file = File(img);

        if (!file.existsSync()) {
          missingFiles.add(img);
        } else if (file.lengthSync() < 5000) {
          emptyFiles.add(img);
        }
      }

      expect(missingFiles, isEmpty, reason: 'MISSING IMAGES must be 0, missing: $missingFiles');
      expect(emptyFiles, isEmpty, reason: 'RECIPES USING PLACEHOLDERS must be 0, tiny/empty: $emptyFiles');
    });

    test('Verify ZERO DUPLICATE IMAGE FILES (all 200 MD5 hashes are 100% unique)', () {
      final recipes = SeedData.recipes;
      final hashes = <String, String>{};
      final duplicateFiles = <String>[];

      for (final r in recipes) {
        final title = r['title'] as String;
        final img = r['image_url'] as String;
        final file = File(img);

        expect(file.existsSync(), isTrue, reason: 'File $img must exist');

        final bytes = file.readAsBytesSync();
        final digest = md5.convert(bytes).toString();

        if (hashes.containsKey(digest)) {
          duplicateFiles.add(
            'Duplicate hash between "$title" ($img) and "${hashes[digest]}" (hash: $digest)',
          );
        } else {
          hashes[digest] = title;
        }
      }

      expect(
        duplicateFiles,
        isEmpty,
        reason: 'DUPLICATE IMAGE FILES must be 0! Found duplicates:\n${duplicateFiles.join("\n")}',
      );
      expect(hashes.length, 200, reason: 'All 200 recipes must have 200 unique MD5 hashes');
    });

    test('Verify key traditional dishes have valid dish-specific filenames', () {
      final recipes = SeedData.recipes;
      final titleToImage = {
        for (final r in recipes) r['title'] as String: r['image_url'] as String,
      };

      expect(titleToImage['Masala Dosa'], 'assets/images/recipes/masala_dosa.jpg');
      expect(titleToImage['Akki Rotti'], 'assets/images/recipes/akki_rotti.jpg');
      expect(titleToImage['Kotte Kadubu'], 'assets/images/recipes/kotte_kadubu.jpg');
      expect(titleToImage['Kesuvina Pathrode'], 'assets/images/recipes/kesuvina_pathrode.jpg');
      expect(titleToImage['Neer Dosa'], 'assets/images/recipes/neer_dosa.jpg');
      expect(titleToImage['Chicken Biryani'], 'assets/images/recipes/chicken_biryani.jpg');
      expect(titleToImage['Butter Chicken'], 'assets/images/recipes/butter_chicken.jpg');
      expect(titleToImage['Gulab Jamun'], 'assets/images/recipes/gulab_jamun.jpg');
      expect(titleToImage['Filter Coffee'], 'assets/images/recipes/filter_coffee.jpg');
      expect(titleToImage['Mango Lassi'], 'assets/images/recipes/mango_lassi.jpg');
    });
  });
}
