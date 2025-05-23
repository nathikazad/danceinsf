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

      // 5. Fetch all instance ratings for the parent event
      final eventRatingsResponse = await supabase
          .from('instance_ratings')
          .select('*, event_instances!inner(*)')
          .eq('event_instances.event_id', eventId)
          .order('created_at', ascending: false);

      final eventRatings = eventRatingsResponse
          .map<EventRating>((rating) => EventRating.fromMap(rating))
          .toList();

      final averageRating = eventRatings.isNotEmpty ? eventRatings.map((r) => r.rating).reduce((a, b) => a + b) / eventRatings.length : 0.0;
      final ratingCount = eventRatings.length;

      final event = Event.fromMap(eventData, rating: averageRating, ratingCount: ratingCount, proposals: eventProposals);

      // 6. Process instance proposals and ratings from the nested response
      final instanceProposals = (instanceResponse['proposals'] as List)
          .map<Proposal>((proposal) => Proposal.fromMap(proposal))
          .toList();

      // 7. Compose the EventInstance with proposals and ratings
      final eventInstance = EventInstance.fromMap(
        instanceResponse, 
        event, 
        ratings: eventRatings,
        proposals: instanceProposals,
      );
      
      return eventInstance;
    } catch (error, stackTrace) {
      print('Error fetching event: $error');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<EventRating?> rateEvent(String eventInstanceId, int rating, DateTime date, {String? comment}) async {
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
                'comment': comment,
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
                'comment': comment,
                'created_at': date.toIso8601String(),
              })
              .select()
              .single();

      // Convert to EventRating object
      return EventRating.fromMap(ratingResponse);
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

      var excitedUsers = toStringList(existingExcitedUsers['excited_users']);

      if (isExcited) {
        excitedUsers.add(userId);
      } else {
        excitedUsers.remove(userId);
      }
      // make the excited users unique
      excitedUsers = excitedUsers.toSet().toList();
      print('excitedUsers: $excitedUsers');

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

  static Future<Map<String, dynamic>?> getPreviousEvent(String eventId, DateTime instanceDate) async {
    try {
      final response = await supabase
          .from('event_instances')
          .select('instance_id, instance_date')
          .eq('event_id', eventId)
          .lt('instance_date', instanceDate.toIso8601String().split('T')[0])
          .order('instance_date', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;

      return {
        'instance_id': response['instance_id'],
        'instance_date': DateTime.parse(response['instance_date']),
      };
    } catch (error, stackTrace) {
      print('Error fetching previous event: $error');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
} 