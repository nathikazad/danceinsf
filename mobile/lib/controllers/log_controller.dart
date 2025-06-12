import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import '../utils/session/session.dart';
import '../models/log.dart';
import '../utils/app_storage.dart';

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
    
    // Skip database operations in debug mode
    if (kDebugMode) {
      print('Debug mode: Skipping database sync');
      _pendingLogs.clear();
      return;
    }

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
          currentActions = Map<String, String>.from(existingLogs['actions']);
        } else {
          print('Creating new log');
          final currentUser = Supabase.instance.client.auth.currentUser;
          final newLog = await Supabase.instance.client.from('logs').insert({
            'session_id': sessionId,
            'created_at': dateOnly,
            'user_id': currentUser?.id,
            'device': kIsWeb ? 'web' : 'mobile',
            'zone': AppStorage.zone,
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

    final sessionId = await getSessionId();
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      await Supabase.instance.client.from('logs').update({
        'user_id': currentUser.id,
      }).eq('session_id', sessionId);
    }
  }

  static Future<List<Log>> fetchLogs() async {
    try {
      final response = await Supabase.instance.client
          .from('logs')
          .select()
          .eq('zone', AppStorage.zone)
          .order('created_at', ascending: false);
      return (response as List).map((json) => Log.fromJson(json)).toList();
    } catch (e) {
      print('Failed to fetch logs: $e');
      return [];
    }
  }

  static Future<({
    List<Log> logs,
    Map<String, int> userIdCounts,
    Map<String, int> sessionIdCounts
  })> fetchByDate(String date) async {
    try {
      final response = await Supabase.instance.client
          .from('logs')
          .select()
          .eq('created_at', date)
          .eq('zone', AppStorage.zone)
          .order('created_at', ascending: false);
      
      final logs = (response as List).map((json) => Log.fromJson(json)).toList();
      
      // Extract unique user IDs and session IDs from the logs
      final userIds = logs
          .map((log) => log.userId)
          .where((id) => id != null)
          .map((id) => id!)
          .toSet()
          .toList();
      
      final sessionIds = logs
          .map((log) => log.sessionId)
          .toSet()
          .toList();
      
      // Get total counts for the specific IDs
      final userIdCounts = await _fetchTotalUserCounts(userIds);
      final sessionIdCounts = await _fetchTotalSessionCounts(sessionIds);
      
      return (
        logs: logs,
        userIdCounts: userIdCounts,
        sessionIdCounts: sessionIdCounts
      );
    } catch (e) {
      print('Failed to fetch logs by date: $e');
      return (
        logs: <Log>[],
        userIdCounts: <String, int>{},
        sessionIdCounts: <String, int>{}
      );
    }
  }

  static Future<Map<String, int>> _fetchTotalUserCounts(List<String> userIds) async {
    if (userIds.isEmpty) return {};
    
    try {
      final response = await Supabase.instance.client
          .rpc('get_user_counts', params: {'user_ids': userIds});
      
      final counts = <String, int>{};
      for (final row in response) {
        counts[row['user_id'] as String] = (row['count'] as num).toInt();
      }
      return counts;
    } catch (e) {
      print('Failed to fetch total user counts: $e');
      return {};
    }
  }

  static Future<Map<String, int>> _fetchTotalSessionCounts(List<String> sessionIds) async {
    if (sessionIds.isEmpty) return {};
    
    try {
      final response = await Supabase.instance.client
          .rpc('get_session_counts', params: {'session_ids': sessionIds});
      
      final counts = <String, int>{};
      for (final row in response) {
        counts[row['session_id'] as String] = (row['count'] as num).toInt();
      }
      return counts;
    } catch (e) {
      print('Failed to fetch total session counts: $e');
      return {};
    }
  }

  static Future<List<Log>> fetchLogsByUserOrSession(String id, {bool isUserId = true}) async {
    try {
      final response = await Supabase.instance.client
          .from('logs')
          .select()
          .eq(isUserId ? 'user_id' : 'session_id', id)
          .order('created_at', ascending: false);
      return (response as List).map((json) => Log.fromJson(json)).toList();
    } catch (e) {
      print('Failed to fetch logs by ${isUserId ? 'user' : 'session'}: $e');
      return [];
    }
  }
}
