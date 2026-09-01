import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cookmate/app/app.dart';
import 'package:cookmate/core/localization/app_language.dart';
import 'package:cookmate/core/localization/language_provider.dart';
import 'package:cookmate/core/services/preference_service.dart';
import 'package:cookmate/features/settings/presentation/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('CookMateApp initializes and renders UI shell', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefService = await PreferenceService.init();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferenceServiceProvider.overrideWithValue(prefService),
        ],
        child: const CookMateApp(),
      ),
    );

    // Initial frame
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Dynamic language switching from English to Kannada updates locale instantly', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefService = await PreferenceService.init();
    late WidgetRef capturedRef;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferenceServiceProvider.overrideWithValue(prefService),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            capturedRef = ref;
            return const CookMateApp();
          },
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Default language is English
    expect(capturedRef.read(languageProvider), equals(AppLanguage.en));
    expect(capturedRef.read(localeProvider), equals(const Locale('en')));

    // Switch to Kannada dynamically
    capturedRef.read(languageProvider.notifier).setLanguage(AppLanguage.kn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(capturedRef.read(languageProvider), equals(AppLanguage.kn));
    expect(capturedRef.read(localeProvider), equals(const Locale('kn')));

    // Switch to Hindi dynamically
    capturedRef.read(languageProvider.notifier).setLanguage(AppLanguage.hi);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(capturedRef.read(languageProvider), equals(AppLanguage.hi));
    expect(capturedRef.read(localeProvider), equals(const Locale('hi')));
  });
}
