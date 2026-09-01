import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookmate/core/theme/app_colors.dart';
import 'package:cookmate/core/services/preference_service.dart';
import 'package:cookmate/features/settings/presentation/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CookMate Theme Mode Tests', () {
    test('ThemeModeNotifier toggles between System, Light, and Dark modes', () async {
      SharedPreferences.setMockInitialValues({});
      final prefService = await PreferenceService.init();

      final notifier = ThemeModeNotifier(prefService);

      // Default is ThemeMode.system
      expect(notifier.state, equals(ThemeMode.system));

      // Switch to Light Mode
      await notifier.setThemeMode(ThemeMode.light);
      expect(notifier.state, equals(ThemeMode.light));
      expect(prefService.getThemeModeIndex(), equals(1));

      // Switch to Dark Mode
      await notifier.setThemeMode(ThemeMode.dark);
      expect(notifier.state, equals(ThemeMode.dark));
      expect(prefService.getThemeModeIndex(), equals(2));

      // Switch back to System Mode
      await notifier.setThemeMode(ThemeMode.system);
      expect(notifier.state, equals(ThemeMode.system));
      expect(prefService.getThemeModeIndex(), equals(0));
    });

    testWidgets('AppColors helper responds to widget theme brightness correctly', (tester) async {
      late BuildContext lightCtx;
      late BuildContext darkCtx;

      await tester.pumpWidget(
        Theme(
          data: ThemeData.light(),
          child: Builder(
            builder: (ctx) {
              lightCtx = ctx;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(lightCtx.isDarkMode, isFalse);
      expect(AppColors.backgroundOf(lightCtx), equals(AppColors.lightBackground));
      expect(AppColors.cardBackgroundOf(lightCtx), equals(AppColors.lightSurfaceCard));
      expect(AppColors.textPrimaryOf(lightCtx), equals(AppColors.lightTextPrimary));

      await tester.pumpWidget(
        Theme(
          data: ThemeData.dark(),
          child: Builder(
            builder: (ctx) {
              darkCtx = ctx;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(darkCtx.isDarkMode, isTrue);
      expect(AppColors.backgroundOf(darkCtx), equals(AppColors.background));
      expect(AppColors.cardBackgroundOf(darkCtx), equals(AppColors.cardBackground));
      expect(AppColors.textPrimaryOf(darkCtx), equals(AppColors.white));
    });
  });
}
