import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

String _generateUUID() {
  final random = Random();
  final values = List<int>.generate(16, (i) => random.nextInt(256));
  
  // Set version (4) and variant bits
  values[6] = (values[6] & 0x0F) | 0x40; // version 4
  values[8] = (values[8] & 0x3F) | 0x80; // variant 1
  
  // Convert to hex string
  final hex = values.map((v) => v.toRadixString(16).padLeft(2, '0')).join();
  
  // Format as UUID
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}

Future<String?> getSessionId() async {
  const String sessionKey = 'session_id';
  final prefs = await SharedPreferences.getInstance();
  
  // Try to get existing session ID
  String? sessionId = prefs.getString(sessionKey);
  
  if (sessionId == null) {
    // Generate new session ID if none exists
    sessionId = _generateUUID();
    await prefs.setString(sessionKey, sessionId);
  }
  
  return sessionId;
}