import 'package:dance_sf/utils/string.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event_model.dart';
import 'package:dance_sf/models/proposal_model.dart';

class EventInstanceController {
  static final supabase = Supabase.instance.client;

  static Future<EventInstance?> fetchEventInstance(String eventInstanceId) async {
    try {
      // 1. Fetch the event instance with its event, unresolved proposals, and ratings in a single query
      final instanceResponse = await supabase
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
      final ratingsResponse = await supabase
          .rpc('get_event_ratings', params: {'event_ids': [eventId]});

      // 3. Get the rating data
      final ratingData = ratingsResponse.isNotEmpty ? ratingsResponse.first : null;
      final rating = ratingData?['average_rating'] as num?;
      final ratingCount = ratingData?['rating_count'] as int? ?? 0;

      // 4. Fetch unresolved event-level proposals
      final eventProposalsResponse = await supabase
          .from('proposals')
          .select('*')
          .eq('event_id', eventId)
          .eq('resolved', false)
          .order('created_at', ascending: false);

      final eventProposals = eventProposalsResponse
          .map<Proposal>((proposal) => Proposal.fromMap(proposal))
          .toList();

      print('Event data: ${eventData['default_flyer_url']}');
      final event = Event.fromMap(eventData, rating: rating?.toDouble() ?? 0.0, ratingCount: ratingCount, proposals: eventProposals);

      // 5. Process instance proposals and ratings from the nested response
      final instanceProposals = (instanceResponse['proposals'] as List)
          .map<Proposal>((proposal) => Proposal.fromMap(proposal))
          .toList();

      final ratings = (instanceResponse['instance_ratings'] as List)
          .map<EventRating>((rating) => EventRating.fromMap(rating))
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

  static Future<EventRating?> rateEvent(String eventInstanceId, int rating) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Validate rating is between 0 and 5
      if (rating < 0 || rating > 5) {
        throw Exception('Rating must be between 0 and 5');
      }

      // Check if user has already rated this instance
      final existingRating = await supabase
          .from('instance_ratings')
          .select()
          .eq('instance_id', eventInstanceId)
          .eq('user_id', user.id)
          .maybeSingle();

      final ratingResponse = existingRating != null
          ? await supabase
              .from('instance_ratings')
              .update({
                'rating': rating,
              })
              .eq('instance_id', eventInstanceId)
              .eq('user_id', user.id)
              .select()
              .single()
          : await supabase
              .from('instance_ratings')
              .insert({
                'instance_id': eventInstanceId,
                'user_id': user.id,
                'rating': rating,
                'created_at': DateTime.now().toIso8601String(),
              })
              .select()
              .single();

      // Convert to EventRating object
      return EventRating(
        rating: ratingResponse['rating'] is double ? ratingResponse['rating'] : double.tryParse(ratingResponse['rating'].toString()) ?? 0.0,
        comment: ratingResponse['comment'] as String?,
        userId: ratingResponse['user_id'] as String,
        createdAt: DateTime.parse(ratingResponse['created_at']),
      );
    } catch (e) {
      print('Error rating event: $e');
      return null;
    }
  }

  static Future<void> updateEventInstance(EventInstance instance) async {
    try {
      // Convert TimeOfDay to string format
      final startTimeStr = '${instance.startTime.hour.toString().padLeft(2, '0')}:${instance.startTime.minute.toString().padLeft(2, '0')}';
      final endTimeStr = '${instance.endTime.hour.toString().padLeft(2, '0')}:${instance.endTime.minute.toString().padLeft(2, '0')}';

      final instanceData = {
        'instance_date': instance.date.toIso8601String().split('T')[0],
        'description': instance.description,
        'start_time': startTimeStr,
        'end_time': endTimeStr,
        'cost': instance.cost,
        'venue_name': instance.venueName,
        'city': instance.city,
        'google_maps_link': instance.url,
        'ticket_link': instance.ticketLink,
        'flyer_url': instance.flyerUrl,
      };

      await supabase
          .from('event_instances')
          .update(instanceData)
          .eq('instance_id', instance.eventInstanceId);
    } catch (error, stackTrace) {
      print('Error updating event instance: $error');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<void> changeExcitedUser(String eventInstanceId, String userId, bool isExcited) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final existingExcitedUsers = await supabase
          .from('event_instances')
          .select('excited_users')
          .eq('instance_id', eventInstanceId)
          .single();

      final excitedUsers = toStringList(existingExcitedUsers['excited_users']);

      if (isExcited) {
        excitedUsers.add(userId);
      } else {
        excitedUsers.remove(userId);
      }

      await supabase
          .from('event_instances')
          .update({'excited_users': excitedUsers})
          .eq('instance_id', eventInstanceId);
    } catch (error, stackTrace) {
      print('Error changing excited user: $error');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
} 