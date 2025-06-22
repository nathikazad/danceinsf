import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class LogController {
  static DateTime? currentDate;
  static int? currentDateId;
  static Map<String, dynamic>? currentActions;
  static final Map<String, String> _pendingLogs = {};
  static Timer? _syncTimer;
  static const syncInterval = Duration(seconds: 10);
  static String zone = 'San Francisco';

  static void setZone(String zone) {
    zone = zone;
  }

  static void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(syncInterval, (_) => _syncToDatabase());
  }

  static Future<void> logNavigation(String text) async {
    final now = DateTime.now();
    final timeOnly = now.toIso8601String().split('T')[1].split('.')[0];
    _pendingLogs[timeOnly] = text;

    if (_syncTimer == null) {
      _startSyncTimer();
    }
  }

  static Future<void> _syncToDatabase() async {
    if (_pendingLogs.isEmpty) return;
    
    // Skip database operations in debug mode
    if (kDebugMode) {
      print('Debug mode: Skipping database sync');
      _pendingLogs.clear();
      return;
    }

    try {
      final sessionId = await _getSessionId();
      var now = DateTime.now();
      
      if (_isNewSession() || _isNewDay(now)) {
        currentDate = now;
        final dateOnly = DateTime(now.year, now.month, now.day).toIso8601String().split('T')[0];
        final existingLogs = await Supabase.instance.client
            .from('logs')
            .select()
            .eq('session_id', sessionId)
            .eq('created_at', dateOnly)
            .maybeSingle();
            
        if (existingLogs != null) {
          print('Updating existing log');
          currentDateId = existingLogs['id'];
          currentActions = Map<String, String>.from(existingLogs['actions']);
        } else {
          print('Creating new log');
          final currentUser = Supabase.instance.client.auth.currentUser;
          final newLog = await Supabase.instance.client.from('logs').insert({
            'session_id': sessionId,
            'created_at': dateOnly,
            'user_id': currentUser?.id,
            'device': kIsWeb ? 'web' : 'mobile',
            'zone': zone,
          }).select().single();
          currentDateId = newLog['id'];
          currentActions = {};
        }
      }

      // Merge pending logs with current actions
      currentActions ??= {};
      currentActions!.addAll(_pendingLogs);
      
      // Write to database
      await Supabase.instance.client.from('logs').update({
        'actions': currentActions,
      }).eq('id', currentDateId!);

      // Clear pending logs only after successful write
      _pendingLogs.clear();
      
    } catch (e) {
      print('Failed to sync logs to Supabase: $e');
    }
  }

  static bool _isNewSession() {
    return currentDate == null || 
           currentActions == null ||
           currentDateId == null;
  }

  static bool _isNewDay(DateTime now) {
    return currentDate!.year != now.year || 
           currentDate!.month != now.month || 
           currentDate!.day != now.day;
  }

  static Future<void> signedInCallback() async {
    // Skip database operations in debug mode
    if (kDebugMode) {
      print('Debug mode: Skipping signedInCallback database update');
      return;
    }

    final sessionId = await _getSessionId();
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      await Supabase.instance.client.from('logs').update({
        'user_id': currentUser.id,
      }).eq('session_id', sessionId);
    }
  }

  static Future<String> _getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    String? sessionId = prefs.getString('session_id');
    if (sessionId == null) {
      sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      await prefs.setString('session_id', sessionId);
    }
    return sessionId;
  }
} 