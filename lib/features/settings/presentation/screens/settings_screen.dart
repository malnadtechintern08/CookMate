import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/language_selector_modal.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.resetCatalog),
        content: Text(l10n.resetCatalogDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.nonVegRed),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(settingsControllerProvider.notifier).resetAllData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.databaseResetSuccess),
                    backgroundColor: AppColors.vegGreen,
                  ),
                );
              }
            },
            child: Text(l10n.reset),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentThemeMode = ref.watch(themeModeProvider);
    final currentLanguage = ref.watch(languageProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Personal Notes Shortcut
          Text(
            l10n.notes.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryOrange,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.border : AppColors.lightBorder,
              ),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit_note_rounded, color: AppColors.primaryOrange),
              ),
              title: Text(l10n.myNotes, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(l10n.notesSubtitle),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () => context.pushNamed(RouteNames.notes),
            ),
          ),
          const SizedBox(height: 28),

          // Language Selection Section
          Text(
            l10n.chooseLanguage.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryOrange,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.border : AppColors.lightBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.translate_rounded, color: AppColors.primaryOrange, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          l10n.chooseLanguage,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        side: const BorderSide(color: AppColors.primaryOrange),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.language_rounded, size: 16, color: AppColors.primaryOrange),
                      label: Text(
                        currentLanguage.nativeName,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryOrange),
                      ),
                      onPressed: () => LanguageSelectorModal.show(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: AppLanguage.values.map((lang) {
                    final isSelected = currentLanguage == lang;
                    return ChoiceChip(
                      selected: isSelected,
                      onSelected: (_) {
                        ref.read(languageProvider.notifier).setLanguage(lang);
                      },
                      avatar: Text(lang.flag, style: const TextStyle(fontSize: 14)),
                      label: Text(
                        '${lang.nativeName} (${lang.englishName})',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary),
                        ),
                      ),
                      selectedColor: AppColors.primaryOrange,
                      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Appearance Section
          Text(
            l10n.chooseTheme.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryOrange,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.border : AppColors.lightBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.palette_outlined, color: AppColors.primaryOrange, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      l10n.chooseTheme,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SegmentedButton<ThemeMode>(
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: AppColors.primaryOrange,
                    selectedForegroundColor: Colors.white,
                    backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
                    foregroundColor: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                    side: BorderSide(
                      color: isDark ? AppColors.border : AppColors.lightBorder,
                    ),
                  ),
                  segments: [
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.system,
                      icon: const Icon(Icons.settings_brightness_rounded, size: 18),
                      label: Text(l10n.systemTheme),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.light,
                      icon: const Icon(Icons.light_mode_rounded, size: 18),
                      label: Text(l10n.lightTheme),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.dark,
                      icon: const Icon(Icons.dark_mode_rounded, size: 18),
                      label: Text(l10n.darkTheme),
                    ),
                  ],
                  selected: {currentThemeMode},
                  onSelectionChanged: (newSelection) {
                    ref.read(themeModeProvider.notifier).setThemeMode(newSelection.first);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Offline Database Section
          Text(
            l10n.offlineStorageTitle.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryOrange,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.border : AppColors.lightBorder,
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cloud_off_rounded, color: AppColors.vegGreen),
                  title: const Text('100% Offline-First Architecture'),
                  subtitle: Text(l10n.offlineModeDesc),
                ),
                Divider(color: isDark ? AppColors.border : AppColors.lightBorder),
                ListTile(
                  leading: const Icon(Icons.restore_rounded, color: AppColors.nonVegRed),
                  title: Text(l10n.resetCatalog),
                  subtitle: Text(l10n.resetCatalogDesc),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () => _showResetDialog(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // About App Section
          Text(
            l10n.about.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryOrange,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.border : AppColors.lightBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/app_icon.png',
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppColors.lightTextPrimary,
                            ),
                            children: [
                              TextSpan(text: 'Cook', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                              const TextSpan(text: 'Mate', style: TextStyle(color: AppColors.nonVegRed)),
                            ],
                          ),
                        ),
                        const Text(
                          'Version 2.0.0 • Indian Culinary Edition',
                          style: TextStyle(fontSize: 12, color: AppColors.lightTextMuted),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.appTagline,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
