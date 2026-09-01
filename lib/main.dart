import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/database/database_service.dart';
import 'core/services/preference_service.dart';
import 'features/settings/presentation/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline services
  final prefService = await PreferenceService.init();
  await DatabaseService.instance.database;

  runApp(
    ProviderScope(
      overrides: [
        preferenceServiceProvider.overrideWithValue(prefService),
      ],
      child: const CookMateApp(),
    ),
  );
}
