import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Language State Management ---

// Global ValueNotifier for the current locale. Initialized to null until loaded.
final ValueNotifier<Locale?> currentLocaleNotifier = ValueNotifier(null);

class L10n {
  // IMPORTANT: use proper (languageCode, countryCode?) constructors
  static final all = [
    const Locale('en'), // English
    const Locale('pt', 'PT'), // Portuguese (Portugal)
    // add more locales here like: Locale('es'), Locale('fr', 'FR'), ...
  ];
}

// Preference keys
const _kSelectedLanguageCodeKey = 'selected_language_code';
const _kSelectedCountryCodeKey = 'selected_country_code';

// Function to initialize/load the saved locale from local storage
Future<void> initializeLocale() async {
  final prefs = await SharedPreferences.getInstance();
  final savedLanguageCode = prefs.getString(_kSelectedLanguageCodeKey);
  final savedCountryCode = prefs.getString(_kSelectedCountryCodeKey);

  if (savedLanguageCode != null && savedLanguageCode.isNotEmpty) {
    // Construct Locale with optional country code
    final loadedLocale = savedCountryCode != null && savedCountryCode.isNotEmpty
        ? Locale(savedLanguageCode, savedCountryCode)
        : Locale(savedLanguageCode);
    currentLocaleNotifier.value = loadedLocale;
    return;
  }

  // Fallback: use the first supported locale
  currentLocaleNotifier.value = L10n.all.first;
}

// Function to change the locale and save it to SharedPreferences
Future<void> setAppLocale(Locale locale) async {
  // If the same language & country already set, skip
  final current = currentLocaleNotifier.value;
  final same =
      (current?.languageCode == locale.languageCode) &&
      (current?.countryCode == locale.countryCode);
  if (same) return;

  currentLocaleNotifier.value = locale;

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kSelectedLanguageCodeKey, locale.languageCode);
  // Save country code if present, or empty string to clear
  await prefs.setString(_kSelectedCountryCodeKey, locale.countryCode ?? '');
}
