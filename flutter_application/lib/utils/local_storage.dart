import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _homeRouteCountKey = 'home_route_count';

  static Future<void> incrementHomeRouteCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_homeRouteCountKey) ?? 0;
    await prefs.setInt(_homeRouteCountKey, count + 1);
  }

  static Future<int> getHomeRouteCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_homeRouteCountKey) ?? 0;
  }
} 