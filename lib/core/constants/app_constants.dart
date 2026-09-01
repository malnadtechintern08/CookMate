class AppConstants {
  static const String appName = 'CookMate';
  static const String appTagline = 'Your Personal Kitchen Companion';
  static const String dbName = 'cookmate.db';
  static const int dbVersion = 4;

  // Shared Preferences Keys
  static const String keyThemeMode = 'cookmate_theme_mode';
  static const String keyFirstLaunch = 'cookmate_first_launch_done';
  static const String keyDefaultServings = 'cookmate_default_servings';
  static const String keyLanguageCode = 'cookmate_language_code';
  static const String keyRecentlyViewed = 'cookmate_recently_viewed_recipes';
  static const String keyShoppingList = 'cookmate_shopping_list_items';

  // Recipe Difficulty Levels
  static const String difficultyEasy = 'Easy';
  static const String difficultyMedium = 'Medium';
  static const String difficultyHard = 'Hard';

  // Quick Launch Filter threshold
  static const int quickLaunchMaxMinutes = 30;
  static const int maxRecentlyViewed = 10;
}
