import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _homeRouteCountKey = 'home_route_count';
  static const String _selectedStylesKey = 'selected_styles';
  static const String _selectedFrequenciesKey = 'selected_frequencies';
  static const String _selectedCitiesKey = 'selected_cities';
  static const String _searchTextKey = 'search_text';

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
} 