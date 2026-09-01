import 'package:flutter/material.dart';

enum AppLanguage {
  en('en', 'English', 'English', '🌐'),
  kn('kn', 'ಕನ್ನಡ', 'Kannada', '🌐'),
  hi('hi', 'हिन्दी', 'Hindi', '🌐');

  final String code;
  final String nativeName;
  final String englishName;
  final String flag;

  const AppLanguage(this.code, this.nativeName, this.englishName, this.flag);

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String? code) {
    if (code == null) return AppLanguage.en;
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code.toLowerCase(),
      orElse: () => AppLanguage.en,
    );
  }
}
