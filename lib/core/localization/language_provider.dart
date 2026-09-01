import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/preference_service.dart';
import '../../features/settings/presentation/providers/settings_provider.dart';
import 'app_language.dart';

class LanguageNotifier extends StateNotifier<AppLanguage> {
  final PreferenceService _prefService;

  LanguageNotifier(this._prefService)
      : super(AppLanguage.fromCode(_prefService.getLanguageCode()));

  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    await _prefService.setLanguageCode(language.code);
  }

  Future<void> setLocale(Locale locale) async {
    final language = AppLanguage.fromCode(locale.languageCode);
    await setLanguage(language);
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, AppLanguage>((ref) {
  final prefs = ref.watch(preferenceServiceProvider);
  return LanguageNotifier(prefs);
});

final localeProvider = Provider<Locale>((ref) {
  final language = ref.watch(languageProvider);
  return language.locale;
});
