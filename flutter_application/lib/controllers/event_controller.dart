import 'package:flutter_application/widgets/add_event_widgets/repeat_section.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event_model.dart';
import 'package:flutter_application/models/proposal_model.dart';


class EventController {
  final _supabase = Supabase.instance.client;


  Future<List<EventInstance>> fetchEvents({DateTime? startDate, required int windowDays}) async {
    startDate ??= DateTime.now();
    final endDate = startDate.add(Duration(days: windowDays));
    try {
      print('Fetching events from ${startDate.toIso8601String().split('T')[0]} to ${endDate.toIso8601String().split('T')[0]}');
      
      // First fetch event instances within the date range along with their events
      final instancesResponse = await _supabase
          .from('event_instances')
          .select('*, events!inner(*)')
          .gte('instance_date', startDate.toIso8601String().split('T')[0])
          .lte('instance_date', endDate.toIso8601String().split('T')[0])
          .eq('events.is_archived', false);
      
      // Extract unique event IDs from the instances
      final eventIds = instancesResponse
          .map((instance) => instance['events']['event_id'] as String)
          .toSet()
          .toList();


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
      
      for (final instanceData in instancesResponse) {
        try {
          final eventData = instanceData['events'];
          // Get rating data from the map
          final ratingData = ratingsMap[eventData['event_id']];
          final rating = ratingData?['average_rating'] as num?;
          final ratingCount = ratingData?['rating_count'] as int? ?? 0;

          final event = Event.fromMap(eventData, rating: rating?.toDouble() ?? 0.0, ratingCount: ratingCount);
          final instance = EventInstance.fromMap(instanceData, event);
          print('Processing instance: ${instance.date.toIso8601String().split('T')[0]}');
          eventInstances.add(instance);
        } catch (e, stackTrace) {
          print('Error processing event instance: ${instanceData['instance_id']}');
          print('Error: $e');
          print('Stack trace: $stackTrace');
          continue;
        }
      }

      print('Processed ${eventInstances.length} event instances');
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
      // 1. Fetch the event instance with its event, unresolved proposals, and ratings in a single query
      final instanceResponse = await _supabase
          .from('event_instances')
          .select('''
            *,
            events!inner(*),
            proposals!event_instance_id(*),
            instance_ratings(*)
          ''')
          .eq('instance_id', eventInstanceId)
          .eq('proposals.resolved', false)
          .single();

      final eventId = instanceResponse['event_id'];
      final eventData = instanceResponse['events'];

      // 2. Get ratings for this event using the function
      final ratingsResponse = await _supabase
          .rpc('get_event_ratings', params: {'event_ids': [eventId]});

      // 3. Get the rating data
      final ratingData = ratingsResponse.isNotEmpty ? ratingsResponse.first : null;
      final rating = ratingData?['average_rating'] as num?;
      final ratingCount = ratingData?['rating_count'] as int? ?? 0;

      // 4. Fetch unresolved event-level proposals
      final eventProposalsResponse = await _supabase
          .from('proposals')
          .select('*')
          .eq('event_id', eventId)
          .eq('resolved', false)
          .order('created_at', ascending: false);

      final eventProposals = eventProposalsResponse
          .map<Proposal>((proposal) => Proposal.fromMap(proposal))
          .toList();

      final event = Event.fromMap(eventData, rating: rating?.toDouble() ?? 0.0, ratingCount: ratingCount, proposals: eventProposals);

      // 5. Process instance proposals and ratings from the nested response
      final instanceProposals = (instanceResponse['proposals'] as List)
          .map<Proposal>((proposal) => Proposal.fromMap(proposal))
          .toList();

      final ratings = (instanceResponse['instance_ratings'] as List)
          .map<EventRating>((rating) => EventRating(
            rating: rating['rating'] is double ? rating['rating'] : double.tryParse(rating['rating'].toString()) ?? 0.0,
            comment: rating['comment'] as String?,
            userId: rating['user_id'] as String,
            createdAt: DateTime.parse(rating['created_at'])
          ))
          .toList();

      // 6. Compose the EventInstance with proposals and ratings
      final eventInstance = EventInstance.fromMap(
        instanceResponse, 
        event, 
        ratings: ratings,
        proposals: instanceProposals,
      );
      
      return eventInstance;
    } catch (error, stackTrace) {
      print('Error fetching event: $error');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<String?> createEvent(Event event, DateTime? selectedDate) async {
    try {
      // Convert event type and style to lists for database storage
      final eventTypes = [event.type == EventType.social ? 'Social' : 'Class'];
      final eventCategories = [event.style == DanceStyle.salsa ? 'Salsa' : 'Bachata'];
      
      // Convert frequency to string
      final recurrenceType = event.frequency.toString().split('.').last.capitalize();
      
      // Convert TimeOfDay to string format
      final startTimeStr = '${event.startTime.hour.toString().padLeft(2, '0')}:${event.startTime.minute.toString().padLeft(2, '0')}';
      final endTimeStr = '${event.endTime.hour.toString().padLeft(2, '0')}:${event.endTime.minute.toString().padLeft(2, '0')}';

      // Extract weekly days or monthly pattern based on schedule
      List<String>? weeklyDays;
      List<String>? monthlyPattern;
      
      if (event.schedule.frequency == Frequency.weekly && event.schedule.dayOfWeek != null) {
        weeklyDays = [event.schedule.shortWeeklyPattern];
      } else if (event.schedule.frequency == Frequency.monthly && 
                event.schedule.dayOfWeek != null && 
                event.schedule.weekOfMonth != null) {
        monthlyPattern = [event.schedule.shortMonthlyPattern];
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

      // Create the event in the database
      final eventResponse = await _supabase.from('events').insert(eventData).select().single();
      if (eventResponse.isEmpty) {
        print('Warning: Failed to create event');
        return null;
      }
      print('Event created: ${eventResponse['event_id']}');

      
      final functionResponse = await _supabase.functions.invoke(
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
      

      // Create and return the Event object
      return eventResponse['event_id'];
    } catch (error, stackTrace) {
      print('Error creating event: $error');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<String?> createProposal({
    required String text,
    required bool forAllEvents,
    String? eventId,
    String? eventInstanceId,
  }) async {
    final supabase = Supabase.instance.client;
    if (forAllEvents && eventId == null) {
      throw Exception('eventId should not be null if forAllEvents is true');
    }
    if (!forAllEvents && eventInstanceId == null) {
      throw Exception('eventInstanceId should not be null if forAllEvents is false');
    }
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');
      final data = {
        'user_id': user.id,
        'text': text,
        'event_id': forAllEvents ? eventId : null,
        'event_instance_id': forAllEvents ? null : eventInstanceId,
      };
      final response = await supabase
          .from('proposals')
          .insert(data)
          .select('id')
          .single();
      return response['id'].toString();
    } catch (e, st) {
      print('Error creating proposal: $e');
      print(st);
      return null;
    }
  }
} 
// https://swsvvoysafsqsgtvpnqg.supabase.co/functions/v1/generate_event_instances