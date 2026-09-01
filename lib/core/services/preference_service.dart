import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class PreferenceService {
  final SharedPreferences _prefs;

  PreferenceService(this._prefs);

  static Future<PreferenceService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferenceService(prefs);
  }

  // Theme Mode (system = 0, light = 1, dark = 2)
  int getThemeModeIndex() {
    return _prefs.getInt(AppConstants.keyThemeMode) ?? 0;
  }

  Future<void> setThemeModeIndex(int mode) async {
    await _prefs.setInt(AppConstants.keyThemeMode, mode);
  }

  bool isFirstLaunch() {
    return !(_prefs.getBool(AppConstants.keyFirstLaunch) ?? false);
  }

  Future<void> markFirstLaunchDone() async {
    await _prefs.setBool(AppConstants.keyFirstLaunch, true);
  }

  int getDefaultServings() {
    return _prefs.getInt(AppConstants.keyDefaultServings) ?? 2;
  }

  Future<void> setDefaultServings(int servings) async {
    await _prefs.setInt(AppConstants.keyDefaultServings, servings);
  }

  String getLanguageCode() {
    return _prefs.getString(AppConstants.keyLanguageCode) ?? 'en';
  }

  Future<void> setLanguageCode(String code) async {
    await _prefs.setString(AppConstants.keyLanguageCode, code);
  }
}
