import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import '../utils/session/session.dart';

class LogController {
  static DateTime? currentDate;
  static int? currentDateId;
  static Map<String, dynamic>? currentActions;
  static final Map<String, String> _pendingLogs = {};
  static Timer? _syncTimer;
  static const syncInterval = Duration(seconds: 10);

  static void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(syncInterval, (_) => _syncToDatabase());
  }

  static Future<void> logNavigation(String text) async {
    final now = DateTime.now();
    final timeOnly = now.toIso8601String().split('T')[1].split('.')[0];
    _pendingLogs[timeOnly] = text;

    print('Logging $timeOnly: $text');
    if (_syncTimer == null) {
      _startSyncTimer();
    }
  }

  static Future<void> _syncToDatabase() async {
    if (_pendingLogs.isEmpty) return;

    try {
      final sessionId = await getSessionId();
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
          currentActions = existingLogs['actions'];
        } else {
          print('Creating new log');
          final currentUser = Supabase.instance.client.auth.currentUser;
          final newLog = await Supabase.instance.client.from('logs').insert({
            'session_id': sessionId,
            'created_at': dateOnly,
            'user_id': currentUser?.id,
            'device': kIsWeb ? 'web' : 'mobile',
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
      // print('Successfully synced logs to database');
      
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
    final sessionId = await getSessionId();
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      await Supabase.instance.client.from('logs').update({
        'user_id': currentUser.id,
      }).eq('session_id', sessionId);
    }
  }

  static Future<List<Map<String, dynamic>>> fetchLogs() async {
    try {
      final response = await Supabase.instance.client
          .from('logs')
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Failed to fetch logs: $e');
      return [];
    }
  }
}
