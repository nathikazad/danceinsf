import 'package:web/web.dart' as web;

class BrowserDetection {
  static bool isSafariOnMac() {
    try {
      final userAgent = web.window.navigator.userAgent.toLowerCase();
      final platform = web.window.navigator.platform.toLowerCase();
      
      // Check if it's Safari on Mac
      final isSafari = userAgent.contains('safari') && !userAgent.contains('chrome');
      final isMac = platform.contains('mac');
      
      return isSafari && isMac;
    } catch (e) {
      // If we can't detect (e.g., not on web), return false
      return false;
    }
  }
} 