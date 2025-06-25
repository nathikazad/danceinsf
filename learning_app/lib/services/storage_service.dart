import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _expandedAccordionKey = 'expanded_accordion_index';
  static const String _selectedThumbnailKey = 'selected_thumbnail_index';
  static const String _sidebarVisibleKey = 'sidebar_visible';

  // Save expanded accordion index
  static Future<void> saveExpandedAccordionIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_expandedAccordionKey, index);
  }

  // Get expanded accordion index
  static Future<int> getExpandedAccordionIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_expandedAccordionKey) ?? 0; // Default to 0 if not found
  }

  // Save selected thumbnail index
  static Future<void> saveSelectedThumbnailIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_selectedThumbnailKey, index);
  }

  // Get selected thumbnail index
  static Future<int> getSelectedThumbnailIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_selectedThumbnailKey) ?? 0; // Default to 0 if not found
  }

  // Save sidebar visibility state
  static Future<void> saveSidebarVisible(bool isVisible) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sidebarVisibleKey, isVisible);
  }

  // Get sidebar visibility state
  static Future<bool> getSidebarVisible() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_sidebarVisibleKey) ?? true; // Default to true if not found
  }

  // Clear all stored data
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
} 