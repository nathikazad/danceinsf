import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppStorage {
  static const String _homeRouteCountKey = 'home_route_count';
  static const String _selectedStylesKey = 'selected_styles';
  static const String _selectedFrequenciesKey = 'selected_frequencies';
  static const String _selectedCitiesKey = 'selected_cities';
  static const String _searchTextKey = 'search_text';
  static const String _zoneKey = 'selected_zone';
  static const String _localeKey = 'selected_locale';

  static Future<void> incrementHomeRouteCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_homeRouteCountKey) ?? 0;
    await prefs.setInt(_homeRouteCountKey, count + 1);
  }

  static Future<int> getHomeRouteCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_homeRouteCountKey) ?? 0;
  }

  // clear route count
  static Future<void> clearHomeRouteCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_homeRouteCountKey);
  }

  // Save filter settings
  static Future<void> saveFilterSettings({
    required List<String> selectedStyles,
    required List<String> selectedFrequencies,
    required List<String> selectedCities,
    required String searchText,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_selectedStylesKey, selectedStyles);
    await prefs.setStringList(_selectedFrequenciesKey, selectedFrequencies);
    await prefs.setStringList(_selectedCitiesKey, selectedCities);
    await prefs.setString(_searchTextKey, searchText);
  }

  // Load filter settings
  static Future<Map<String, dynamic>> loadFilterSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'selectedStyles': prefs.getStringList(_selectedStylesKey) ?? [],
      'selectedFrequencies': prefs.getStringList(_selectedFrequenciesKey) ?? [],
      'selectedCities': prefs.getStringList(_selectedCitiesKey) ?? [],
      'searchText': prefs.getString(_searchTextKey) ?? '',
    };
  }
  static const defaultZone = 'Mexico';
  static const defaultLocale = 'es';
  
  static String _zone = defaultZone;
  static String _locale = defaultLocale;

  static String get zone => _zone;
  static String get locale => _locale;

  static Future<void> setZone(String zone) async {
    _zone = zone;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_zoneKey, zone);
  }

  static Future<void> setLocale(String locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale);
  }

  static Future<String> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    _locale = prefs.getString(_localeKey) ?? defaultLocale;
    return _locale;
  }

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _zone = prefs.getString(_zoneKey) ?? defaultZone;
    _locale = prefs.getString(_localeKey) ?? defaultLocale;
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(Locale(AppStorage.locale)) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final savedLocale = await AppStorage.loadLocale();
    state = Locale(savedLocale);
  }

  Future<void> setLocale(Locale locale) async {
    await AppStorage.setLocale(locale.languageCode);
    state = locale;
  }
} 