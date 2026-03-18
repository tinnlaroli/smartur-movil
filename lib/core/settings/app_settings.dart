import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

@immutable
class AppSettings {
  final ThemeMode themeMode;
  final Locale locale;
  final bool colorblindMode;

  const AppSettings({
    required this.themeMode,
    required this.locale,
    required this.colorblindMode,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? colorblindMode,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      colorblindMode: colorblindMode ?? this.colorblindMode,
    );
  }
}

class AppSettingsNotifier extends ValueNotifier<AppSettings> {
  static const String _darkModeKey = 'dark_mode';
  static const String _colorblindModeKey = 'colorblind_mode';
  static const String _languageKey = 'language';

  final SharedPreferences _prefs;

  AppSettingsNotifier._(this._prefs, AppSettings initial) : super(initial);

  static Future<AppSettingsNotifier> load() async {
    final prefs = await SharedPreferences.getInstance();

    final dark = prefs.getBool(_darkModeKey) ?? false;
    final colorblind = prefs.getBool(_colorblindModeKey) ?? false;
    final languageName = prefs.getString(_languageKey) ?? 'Español';

    final locale = _localeFromLegacyLanguageName(languageName);

    return AppSettingsNotifier._(
      prefs,
      AppSettings(
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        locale: locale,
        colorblindMode: colorblind,
      ),
    );
  }

  bool get isDarkMode => value.themeMode == ThemeMode.dark;

  Future<void> setDarkMode(bool enabled) async {
    value = value.copyWith(themeMode: enabled ? ThemeMode.dark : ThemeMode.light);
    await _prefs.setBool(_darkModeKey, enabled);
  }

  Future<void> toggleDarkMode() => setDarkMode(!isDarkMode);

  Future<void> setColorblindMode(bool enabled) async {
    value = value.copyWith(colorblindMode: enabled);
    await _prefs.setBool(_colorblindModeKey, enabled);
  }

  Future<void> toggleColorblind() => setColorblindMode(!value.colorblindMode);

  Future<void> setLocale(Locale locale) async {
    value = value.copyWith(locale: locale);
    await _prefs.setString(_languageKey, _legacyLanguageNameFromLocale(locale));
  }

  static Locale _localeFromLegacyLanguageName(String languageName) {
    switch (languageName) {
      case 'English':
        return const Locale('en');
      case 'Français':
        return const Locale('fr');
      case 'Português':
        return const Locale('pt');
      case 'Español':
      default:
        return const Locale('es');
    }
  }

  static String _legacyLanguageNameFromLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      case 'pt':
        return 'Português';
      case 'es':
      default:
        return 'Español';
    }
  }
}

