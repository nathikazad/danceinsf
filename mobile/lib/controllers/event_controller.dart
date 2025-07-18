import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event_model.dart';
import '../utils/app_storage.dart';

class EventController {
  static final supabase = Supabase.instance.client;

  static Future<List<EventInstance>> _processEventInstances(List<dynamic> instancesResponse) async {
    // Extract unique event IDs from the instances
    final eventIds = instancesResponse
        .map((instance) => instance['events']['event_id'] as String)
        .toSet()
        .toList();

    // Get ratings for these events using the function
    final ratingsResponse = await supabase
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
    
    for (final instanceData in instancesResponse) {
      try {
        final eventData = instanceData['events'];
        // Get rating data from the map
        final ratingData = ratingsMap[eventData['event_id']];
        final rating = ratingData?['average_rating'] as num?;
        final ratingCount = ratingData?['rating_count'] as int? ?? 0;

        final event = Event.fromMap(eventData, rating: rating?.toDouble() ?? 0.0, ratingCount: ratingCount);
        final instance = EventInstance.fromMap(instanceData, event);
        eventInstances.add(instance);
      } catch (e, stackTrace) {
        print('Error processing event instance: ${instanceData['instance_id']}');
        print('Error: $e');
        print('Stack trace: $stackTrace');
        continue;
      }
    }

    return eventInstances;
  }

  static Future<List<EventInstance>> fetchEventsBySearch(String searchQuery) async {
    try {
      // First fetch event instances with events that match the search query
      final instancesResponse = await supabase
          .from('event_instances')
          .select('*, events!inner(*)')
          .ilike('events.name', '%$searchQuery%')
          .eq('events.is_archived', false)
          .eq('events.zone', AppStorage.zone);

      print("instancesResponse: ${instancesResponse.length}");
      
      return _processEventInstances(instancesResponse);
    } catch (error, stackTrace) {
      print('Error fetching events by search');
      print('Error: $error');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<EventInstance>> fetchEvents({DateTime? startDate, required int windowDays}) async {
    startDate ??= DateTime.now();
    final endDate = startDate.add(Duration(days: windowDays));
    try {
      // First fetch event instances within the date range along with their events
      final instancesResponse = await supabase
          .from('event_instances')
          .select('*, events!inner(*)')
          .gte('instance_date', startDate.toIso8601String().split('T')[0])
          .lte('instance_date', endDate.toIso8601String().split('T')[0])
          .eq('events.is_archived', false)
          .eq('events.zone', AppStorage.zone);

      print("instancesResponse: ${instancesResponse.length}");
      
      return _processEventInstances(instancesResponse);
    } catch (error, stackTrace) {
      print('Error fetching events');
      print('Error: $error');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<String?> createEvent(Event event, DateTime? selectedDate) async {
    try {


      final eventData = event.toMap();
      eventData['zone'] = AppStorage.zone;
      eventData['is_archived'] = false;
      eventData['creator_id'] = Supabase.instance.client.auth.currentUser!.id;

      // Create the event in the database
      final eventResponse = await supabase.from('events').insert(eventData).select().single();
      if (eventResponse.isEmpty) {
        print('Warning: Failed to create event');
        return null;
      }
      print('Event created: ${eventResponse['event_id']}');

      final functionResponse = await supabase.functions.invoke(
        'generate_event_instances',
        body: {
          'event_ids': [eventResponse['event_id']],
          if (selectedDate != null) 'date': selectedDate.toIso8601String(),
        },
      );

      if (functionResponse.status != 200) {
        print('Warning: Failed to generate event instances: ${functionResponse.data}');
        return null;
      }

      return eventResponse['event_id'];
    } catch (error, stackTrace) {
      print('Error creating event: $error');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<void> updateEvent(Event event) async {
    try {
      final eventData = event.toMap();

      await supabase
          .from('events')
          .update(eventData)
          .eq('event_id', event.eventId);

      // After updating the event, regenerate instances for the next 30 days
      await supabase.functions.invoke(
        'generate_event_instances',
        body: {
          'event_ids': [event.eventId],
        },
      );
    } catch (error, stackTrace) {
      print('Error updating event: $error');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<Event?> fetchEvent(String eventId) async {
    try {
      final response = await supabase
          .from('events')
          .select()
          .eq('event_id', eventId)
          .single();

      return Event.fromMap(response);
    } catch (e) {
      print('Error fetching event: $e');
      return null;
    }
  }
} 
// https://swsvvoysafsqsgtvpnqg.supabase.co/functions/v1/generate_event_instances