import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../models/event.dart';


class EventController {
  final _supabase = Supabase.instance.client;

  // Helper to convert dynamic lists to List<String>
  List<String> _toStringList(dynamic list) =>
      (list as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

  Future<List<EventInstance>> fetchEvents({DateTime? startDate, int windowDays = 90}) async {
    try {
      // First fetch events and their instances
      final eventsResponse = await _supabase
          .from('events')
          .select('*, event_instances(*)')
          .eq('is_archived', false);
          // .order('start_date');

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

      final List<EventInstance> eventInstances = [];
      
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
            eventInstances.add(eventInstanceFromMap(instance, event));
          }
        } catch (e, stackTrace) {
          print('Error processing event: ${eventData['name']}');
          print('Error: $e');
          print('Stack trace: $stackTrace');
          continue;
        }
      }

      print('Processed ${eventInstances.length} event eventInstances');
      return eventInstances;
    } catch (error, stackTrace) {
      print('Error fetching events');
      print('Error: $error');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<EventInstance?> fetchEvent(String eventInstanceId) async {
    try {
      // 1. Fetch the event instance by instance_id
      final instanceResponse = await _supabase
          .from('event_instances')
          .select('*')
          .eq('instance_id', eventInstanceId)
          .single();

      final eventId = instanceResponse['event_id'];

      // 2. Fetch the event by event_id
      final eventResponse = await _supabase
          .from('events')
          .select('*')
          .eq('event_id', eventId)
          .single();

      // 3. Get ratings for this event using the function
      final ratingsResponse = await _supabase
          .rpc('get_event_ratings', params: {'event_ids': [eventId]});

      // 4. Get the rating data
      final ratingData = ratingsResponse.isNotEmpty ? ratingsResponse.first : null;
      final rating = ratingData?['average_rating'] as double?;
      final ratingCount = ratingData?['rating_count'] as int? ?? 0;

      final event = _eventFromMap(eventResponse, rating: rating, ratingCount: ratingCount);

      // 5. Fetch all ratings for this instance
      final instanceRatings = await _supabase
          .from('instance_ratings')
          .select('*')
          .eq('instance_id', eventInstanceId)
          .order('created_at', ascending: false);

      final ratings = instanceRatings.map<EventRating>((rating) => EventRating(
        rating: rating['rating'] is double ? rating['rating'] : double.tryParse(rating['rating'].toString()) ?? 0.0,
        comment: rating['comment'] as String?,
        userId: rating['user_id'] as String,
        createdAt: DateTime.parse(rating['created_at'])
      )).toList();

      // 6. Compose the EventInstance
      final eventInstance = eventInstanceFromMap(instanceResponse, event, ratings: ratings);
      return eventInstance;
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

  EventInstance eventInstanceFromMap(Map instance, Event event, {List<EventRating>? ratings}) {
    return EventInstance(
      eventInstanceId: instance['instance_id'],
      event: event,
      date: DateTime.parse(instance['instance_date']),
      venueName: instance['venue_name'] ?? event.location.venueName,
      city: instance['city'] ?? event.location.city,
      url: instance['google_maps_link'] ?? event.location.url,
      ticketLink: instance['ticket_link'] ?? event.linkToEvent,
      startTime: _parseTimeOfDay(instance['start_time']) ?? event.startTime,
      endTime: _parseTimeOfDay(instance['end_time']) ?? event.endTime,
      cost: instance['cost'] ?? event.cost,
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
    List<String>? weeklyDays,
    List<String>? monthlyPattern,
  ) {
    switch (recurrenceType?.toLowerCase()) {
      case 'weekly':
        if (weeklyDays?.isNotEmpty == true) {
          // For simplicity, we'll use the first day in the weekly pattern
          final dayIndex = _parseDayOfWeek(weeklyDays!.first);
          return SchedulePattern.weekly(DayOfWeek.values[dayIndex]);
        }
        return SchedulePattern.once();
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
        return SchedulePattern.once();
      default:
        return SchedulePattern.once();
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

  Future<Event> createEvent(Event event, DateTime? selectedDate) async {
    try {
      // Convert event type and style to lists for database storage
      final eventTypes = [event.type == EventType.social ? 'Social' : 'Class'];
      final eventCategories = [event.style == DanceStyle.salsa ? 'Salsa' : 'Bachata'];
      
      // Convert frequency to string
      final recurrenceType = event.frequency.toString().split('.').last.toLowerCase();
      
      // Convert TimeOfDay to string format
      final startTimeStr = '${event.startTime.hour.toString().padLeft(2, '0')}:${event.startTime.minute.toString().padLeft(2, '0')}';
      final endTimeStr = '${event.endTime.hour.toString().padLeft(2, '0')}:${event.endTime.minute.toString().padLeft(2, '0')}';

      // Extract weekly days or monthly pattern based on schedule
      List<String>? weeklyDays;
      List<String>? monthlyPattern;
      
      if (event.schedule.frequency == Frequency.weekly && event.schedule.dayOfWeek != null) {
        weeklyDays = [event.schedule.dayOfWeekString];
      } else if (event.schedule.frequency == Frequency.monthly && 
                event.schedule.dayOfWeek != null && 
                event.schedule.weekOfMonth != null) {
        monthlyPattern = ['${event.schedule.weekOfMonth}-${event.schedule.dayOfWeekString}'];
      }

      final eventData = {
        'name': event.name,
        'event_type': eventTypes,
        'event_category': eventCategories,
        'recurrence_type': recurrenceType,
        'default_venue_name': event.location.venueName,
        'default_city': event.location.city,
        'default_google_maps_link': event.location.url,
        'default_ticket_link': event.linkToEvent,
        'default_start_time': startTimeStr,
        'default_end_time': endTimeStr,
        'default_cost': event.cost,
        'default_description': event.description,
        'weekly_days': weeklyDays,
        'monthly_pattern': monthlyPattern,
        'is_archived': false,
      };
      // print(eventData);

      // // Create the event in the database
      final response = await _supabase.from('events').insert(eventData).select().single();

      // Create the event instance in the database

      // // Create and return the Event object
      return _eventFromMap(response);
    } catch (error, stackTrace) {
      print('Error creating event: $error');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
} 