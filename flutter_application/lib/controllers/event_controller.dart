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
      
      // First fetch events and their instances
      final eventsResponse = await _supabase
          .from('events')
          .select('*, event_instances(*)')
          .eq('is_archived', false)
          .order('start_date');

      // Get all event IDs
      final eventIds = eventsResponse.map((e) => e['event_id'] as String).toList();

      // Get ratings for these events using the function
      final ratingsResponse = await _supabase
          .rpc('get_event_ratings', params: {'event_ids': eventIds});

      // Create a map of event_id to ratings for easy lookup
      final ratingsMap = {
        for (var rating in ratingsResponse)
          rating['event_id']: {
            'average_rating': rating['average_rating'],
            'rating_count': rating['rating_count'],
          }
      };

      final List<EventOccurrence> occurrences = [];

      bool isFirst = true;
      
      for (final eventData in eventsResponse) {
        if (isFirst) {
          print('First event: ${eventData['name']} ${eventData['default_start_time']} ${eventData['default_end_time']}');
          isFirst = false;
        }
        try {
          // Convert dynamic lists to List<String>
          final eventTypes = (eventData['event_type'] as List<dynamic>).map((e) => e.toString()).toList();
          final eventCategories = (eventData['event_category'] as List<dynamic>).map((e) => e.toString()).toList();
          final weeklyDays = (eventData['weekly_days'] as List<dynamic>?)?.map((e) => e.toString()).toList();
          final monthlyPattern = (eventData['monthly_pattern'] as List<dynamic>?)?.map((e) => e.toString()).toList();

          // Get rating data from the map
          final ratingData = ratingsMap[eventData['event_id']];
          final rating = ratingData?['average_rating'] as double?;
          final ratingCount = ratingData?['rating_count'] as int? ?? 0;

          final event = Event(
            name: eventData['name'],
            type: eventTypes.contains('Social') ? EventType.social : EventType.class_,
            style: eventCategories.contains('Salsa') ? DanceStyle.salsa : DanceStyle.bachata,
            frequency: _parseFrequency(eventData['recurrence_type']),
            location: Location(
              venueName: eventData['default_venue_name'] ?? '',
              city: eventData['default_city'] ?? '',
              url: eventData['default_google_maps_link'] ?? '',
            ),
            linkToEvent: eventData['default_ticket_link'] ?? '',
            schedule: _createSchedulePattern(
              eventData['recurrence_type'],
              DateTime.parse(eventData['start_date']),
              weeklyDays,
              monthlyPattern,
            ),
            startTime: _parseTimeOfDay(eventData['default_start_time']) ?? const TimeOfDay(hour: 0, minute: 0),
            endTime: _parseTimeOfDay(eventData['default_end_time']) ?? const TimeOfDay(hour: 0, minute: 0),
            cost: eventData['default_cost'],
            description: eventData['default_description'],
            rating: ratingCount > 0 ? rating : null,
            ratingCount: ratingCount,
          );

          // Add instances
          final instances = eventData['event_instances'] as List;
          for (final instance in instances) {
            if (instance['is_cancelled'] == true) continue;
            
            final instanceDate = DateTime.parse(instance['instance_date']);
            occurrences.add(EventOccurrence(
              event: event,
              date: instanceDate,
              venueName: instance['venue_name'],
              city: instance['city'],
              url: instance['google_maps_link'],
              ticketLink: instance['ticket_link'],
              startTime: _parseTimeOfDay(instance['start_time']),
              endTime: _parseTimeOfDay(instance['end_time']),
              cost: instance['cost'],
              description: instance['description'],
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
    const dayMap = {
      'm': 0, 't': 1, 'w': 2, 'th': 3, 'f': 4, 'sa': 5, 'su': 6
    };
    return dayMap[day.toLowerCase().trim()] ?? 0;
  }

  TimeOfDay? _parseTimeOfDay(String? timeStr) {
    if (timeStr == null) return null;
    
    final parts = timeStr.split(':');
    if (parts.length < 2) return const TimeOfDay(hour: 0, minute: 0);
    
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }
} 