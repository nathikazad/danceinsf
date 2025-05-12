import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../models/event.dart';

final eventControllerProvider = StateNotifierProvider<EventController, AsyncValue<List<EventOccurrence>>>((ref) {
  return EventController();
});

class EventController extends StateNotifier<AsyncValue<List<EventOccurrence>>> {
  EventController() : super(const AsyncValue.loading()) {
    fetchEvents();
  }

  final _supabase = Supabase.instance.client;

  Future<void> fetchEvents({DateTime? startDate, int windowDays = 90}) async {
    try {
      state = const AsyncValue.loading();
      
      // Fetch events and their instances
      final eventsResponse = await _supabase
          .from('events')
          .select('*, event_instances(*)')
          .eq('is_archived', false)
          .order('start_date');

      // print('Fetched events: $eventsResponse');

      final List<EventOccurrence> occurrences = [];
      
      for (final eventData in eventsResponse) {
        try {
          // Convert dynamic lists to List<String>
          final eventTypes = (eventData['event_type'] as List<dynamic>).map((e) => e.toString()).toList();
          final eventCategories = (eventData['event_category'] as List<dynamic>).map((e) => e.toString()).toList();
          final weeklyDays = (eventData['weekly_days'] as List<dynamic>?)?.map((e) => e.toString()).toList();
          final monthlyPattern = (eventData['monthly_pattern'] as List<dynamic>?)?.map((e) => e.toString()).toList();

          final event = Event(
            name: eventData['name'],
            type: eventTypes.contains('Social') ? EventType.social : EventType.class_,
            style: eventCategories.contains('Salsa') ? DanceStyle.salsa : DanceStyle.bachata,
            frequency: _parseFrequency(eventData['recurrence_type']),
            location: Location(
              address: eventData['default_venue_name'] ?? '',
              url: eventData['default_google_maps_link'],
              latitude: 0,
              longitude: 0,
            ),
            linkToEvent: eventData['default_ticket_link'] ?? '',
            schedule: _createSchedulePattern(
              eventData['recurrence_type'],
              DateTime.parse(eventData['start_date']),
              weeklyDays,
              monthlyPattern,
            ),
            startTime: _parseTimeOfDay(eventData['default_start_time']),
            endTime: _parseTimeOfDay(eventData['default_end_time']),
          );

          // Add instances
          final instances = eventData['event_instances'] as List;
          for (final instance in instances) {
            if (instance['is_cancelled'] == true) continue;
            
            final instanceDate = DateTime.parse(instance['instance_date']);
            occurrences.add(EventOccurrence(
              event: event,
              date: instanceDate,
            ));
          }
        } catch (e, stackTrace) {
          print('Error processing event: ${eventData['name']}');
          print('Error: $e');
          print('Stack trace: $stackTrace');
          // Continue with next event instead of failing completely
          continue;
        }
      }

      print('Processed ${occurrences.length} event occurrences');
      state = AsyncValue.data(occurrences);
    } catch (error, stackTrace) {
      print('Error fetching events');
      print('Error: $error');
      print('Stack trace: $stackTrace');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Frequency _parseFrequency(String? recurrenceType) {
    switch (recurrenceType?.toLowerCase()) {
      case 'once':
        return Frequency.once;
      case 'weekly':
        return Frequency.weekly;
      case 'monthly':
        return Frequency.monthly;
      default:
        return Frequency.once;
    }
  }

  SchedulePattern _createSchedulePattern(
    String? recurrenceType,
    DateTime startDate,
    List<String>? weeklyDays,
    List<String>? monthlyPattern,
  ) {
    switch (recurrenceType?.toLowerCase()) {
      case 'once':
        return SchedulePattern.once(startDate);
      case 'weekly':
        if (weeklyDays?.isNotEmpty == true) {
          // For simplicity, we'll use the first day in the weekly pattern
          final dayIndex = _parseDayOfWeek(weeklyDays!.first);
          return SchedulePattern.weekly(DayOfWeek.values[dayIndex]);
        }
        return SchedulePattern.once(startDate);
      case 'monthly':
        if (monthlyPattern?.isNotEmpty == true) {
          // For simplicity, we'll use the first pattern
          final pattern = monthlyPattern!.first.split('-');
          if (pattern.length == 2) {
            final weekNumber = int.tryParse(pattern[0].replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
            final dayIndex = _parseDayOfWeek(pattern[1]);
            return SchedulePattern.monthly(
              DayOfWeek.values[dayIndex],
              weekNumber,
            );
          }
        }
        return SchedulePattern.once(startDate);
      default:
        return SchedulePattern.once(startDate);
    }
  }

  int _parseDayOfWeek(String day) {
    final normalizedDay = day.toLowerCase().trim();
    switch (normalizedDay) {
      case 'm':
      case 'mon':
      case 'monday':
        return 0;
      case 't':
      case 'tue':
      case 'tuesday':
        return 1;
      case 'w':
      case 'wed':
      case 'wednesday':
        return 2;
      case 'th':
      case 'thu':
      case 'thursday':
        return 3;
      case 'f':
      case 'fri':
      case 'friday':
        return 4;
      case 'sa':
      case 'sat':
      case 'saturday':
        return 5;
      case 'su':
      case 'sun':
      case 'sunday':
        return 6;
      default:
        return 0;
    }
  }

  TimeOfDay _parseTimeOfDay(String? timeStr) {
    if (timeStr == null) return const TimeOfDay(hour: 0, minute: 0);
    
    final parts = timeStr.split(':');
    if (parts.length != 2) return const TimeOfDay(hour: 0, minute: 0);
    
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    
    return TimeOfDay(hour: hour, minute: minute);
  }
} 