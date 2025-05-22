import 'package:web/web.dart' as web;


Future<String?> getSessionId() async {
  try {
    // Get session ID from browser's localStorage using our platform-agnostic WebStorage
    final sessionId = web.window.localStorage.getItem('session');
    return sessionId;
  } catch (e) {
    print('Error getting session ID from browser: $e');
    // Fallback to a default session ID if browser call fails
    return 'default-session-id';
  }
}