import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/services/preference_service.dart';
import '../../../recipes/presentation/providers/recipe_providers.dart';

final preferenceServiceProvider = Provider<PreferenceService>((ref) {
  throw UnimplementedError('PreferenceService must be overridden in ProviderScope');
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final PreferenceService _prefService;

  ThemeModeNotifier(this._prefService) : super(_loadInitialMode(_prefService));

  static ThemeMode _loadInitialMode(PreferenceService prefs) {
    final index = prefs.getThemeModeIndex();
    switch (index) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    int index = 0;
    if (mode == ThemeMode.light) index = 1;
    if (mode == ThemeMode.dark) index = 2;
    await _prefService.setThemeModeIndex(index);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(preferenceServiceProvider);
  return ThemeModeNotifier(prefs);
});

// Settings Action Controller
class SettingsController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  SettingsController(this.ref) : super(const AsyncValue.data(null));

  Future<void> resetAllData() async {
    state = const AsyncValue.loading();
    try {
      final dbService = ref.read(databaseServiceProvider);
      await dbService.resetToSeedData();
      ref.read(recipeControllerProvider.notifier); // trigger refresh
      ref.invalidate(allRecipesProvider);
      ref.invalidate(quickLaunchRecipesProvider);
      ref.invalidate(favoriteRecipesProvider);
      ref.invalidate(customRecipesProvider);
      ref.invalidate(searchResultsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final settingsControllerProvider = StateNotifierProvider<SettingsController, AsyncValue<void>>((ref) {
  return SettingsController(ref);
});
