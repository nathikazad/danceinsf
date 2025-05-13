import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../models/event.dart';


class EventController {
  final _supabase = Supabase.instance.client;

  // Helper to convert dynamic lists to List<String>
  List<String> _toStringList(dynamic list) =>
      (list as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

  Future<List<EventOccurrence>> fetchEvents({DateTime? startDate, int windowDays = 90}) async {
    try {
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
      
      for (final eventData in eventsResponse) {
        try {
          // Get rating data from the map
          final ratingData = ratingsMap[eventData['event_id']];
          final rating = ratingData?['average_rating'] as double?;
          final ratingCount = ratingData?['rating_count'] as int? ?? 0;

          final event = _eventFromMap(eventData, rating: rating, ratingCount: ratingCount);

          // Add instances
          final instances = eventData['event_instances'] as List;
          for (final instance in instances) {
            occurrences.add(eventOccurrenceFromMap(instance, event));
          }
        } catch (e, stackTrace) {
          print('Error processing event: ${eventData['name']}');
          print('Error: $e');
          print('Stack trace: $stackTrace');
          continue;
        }
      }

      print('Processed ${occurrences.length} event occurrences');
      return occurrences;
    } catch (error, stackTrace) {
      print('Error fetching events');
      print('Error: $error');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<EventOccurrence?> fetchEvent(String eventId) async {
    try {
      // Fetch the event and its instances
      final eventResponse = await _supabase
          .from('events')
          .select('*, event_instances!inner(*)')
          .eq('event_id', eventId)
          .single();

      // Get ratings for this event using the function
      final ratingsResponse = await _supabase
          .rpc('get_event_ratings', params: {'event_ids': [eventId]});

      // Get the rating data
      final ratingData = ratingsResponse.isNotEmpty ? ratingsResponse.first : null;
      final rating = ratingData?['average_rating'] as double?;
      final ratingCount = ratingData?['rating_count'] as int? ?? 0;

      final event = _eventFromMap(eventResponse, rating: rating, ratingCount: ratingCount);

      // Get the first instance (since we're looking for a specific event)
      final instance = eventResponse['event_instances'][0];
      if (instance['is_cancelled'] == true) return null;

      // Fetch all ratings for this instance
      final instanceRatings = await _supabase
          .from('instance_ratings')
          .select('*')
          .eq('instance_id', instance['instance_id'])
          .order('created_at', ascending: false);


      final ratings = instanceRatings.map((rating) => EventRating(
        rating: rating['rating'] as double,
        comment: rating['comment'] as String?,
        userId: rating['user_id'] as String,
        createdAt: DateTime.parse(rating['created_at'])
      )).toList();

      final eventOccurrence = eventOccurrenceFromMap(instance, event, ratings: ratings);
      return eventOccurrence;
    } catch (error, stackTrace) {
      print('Error fetching event: $error');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // DRY: Build Event from map and rating info
  Event _eventFromMap(Map eventData, {double? rating, int ratingCount = 0}) {
    final eventTypes = _toStringList(eventData['event_type']);
    final eventCategories = _toStringList(eventData['event_category']);
    final weeklyDays = _toStringList(eventData['weekly_days']);
    final monthlyPattern = _toStringList(eventData['monthly_pattern']);

    return Event(
      eventId: eventData['event_id'],
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
  }

  EventOccurrence eventOccurrenceFromMap(Map instance, Event event, {List<EventRating>? ratings}) {
    return EventOccurrence(
      event: event,
      date: DateTime.parse(instance['instance_date']),
      venueName: instance['venue_name'],
      city: instance['city'],
      url: instance['google_maps_link'],
      ticketLink: instance['ticket_link'],
      startTime: _parseTimeOfDay(instance['start_time']),
      endTime: _parseTimeOfDay(instance['end_time']),
      cost: instance['cost'],
      description: instance['description'],
      ratings: ratings,
      isCancelled: instance['is_cancelled'] == true,
    );
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