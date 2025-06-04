import 'package:dance_sf/utils/string.dart';
import 'package:flutter/material.dart';
import 'package:dance_sf/models/event_model.dart';
import 'package:dance_sf/models/proposal_model.dart';

class EventInstance {
  final Event event;
  final DateTime date;
  final String venueName;
  final String city;
  final String? url;
  final String? linkToEvent;
  final String? ticketLink;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final double cost;
  final String? description;
  final List<EventRating> ratings;
  final bool isCancelled;
  final String eventInstanceId;
  final List<Proposal>? proposals;
  final String? flyerUrl;
  final String shortUrl;
  final List<String> excitedUsers;

  EventInstance({
    required this.eventInstanceId,
    required this.event,
    required this.date,
    required this.shortUrl,
    String? venueName,
    String? city,
    String? url,
    String? linkToEvent,
    String? ticketLink,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    double? cost,
    String? description,
    List<EventRating>? ratings,
    bool? isCancelled,
    this.proposals,
    String? flyerUrl,
    this.excitedUsers = const [],
  }) : venueName = venueName ?? event.location.venueName,
       city = city ?? event.location.city,
       url = url ?? event.location.url,
       linkToEvent = linkToEvent ?? event.linkToEvent,
       ticketLink = ticketLink ?? event.linkToEvent,
       startTime = startTime ?? event.startTime,
       endTime = endTime ?? event.endTime,
       cost = cost ?? event.cost,
       description = description ?? event.description,
       ratings = ratings ?? [],
       flyerUrl = flyerUrl ?? event.flyerUrl,
       isCancelled = isCancelled ?? false;

  // Helper method to get just the date part (without time)
  DateTime get dateOnly => DateTime(date.year, date.month, date.day);

  // Factory method to create EventInstance from map
  static EventInstance fromMap(Map instance, Event event, {List<EventRating>? ratings, List<Proposal>? proposals}) {
    return EventInstance(
      eventInstanceId: instance['instance_id'],
      event: event,
      date: DateTime.parse(instance['instance_date']),
      venueName: instance['venue_name'] ?? event.location.venueName,
      city: instance['city'] ?? event.location.city,
      url: instance['google_maps_link'] ?? event.location.url,
      ticketLink: instance['ticket_link'] ?? event.linkToEvent,
      startTime: parseTimeOfDay(instance['start_time']) ?? event.startTime,
      endTime: parseTimeOfDay(instance['end_time']) ?? event.endTime,
      cost: instance['cost'] ?? event.cost,
      description: instance['description'],
      ratings: ratings,
      isCancelled: instance['is_cancelled'] == true,
      proposals: proposals,
      excitedUsers: toStringList(instance['excited_users']),
      shortUrl: instance['short_url_prefix'],
    );
  }

  bool get hasStarted => DateTime.now().isAfter(DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute));

  EventInstance copyWith({
    String? eventInstanceId,
    Event? event,
    DateTime? date,
    String? venueName,
    String? city,
    String? url,
    String? linkToEvent,
    String? ticketLink,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    double? cost,
    String? description,
    List<EventRating>? ratings,
    bool? isCancelled,
    List<Proposal>? proposals,
    String? flyerUrl,
    List<String>? excitedUsers,
  }) {
    return EventInstance(
      shortUrl: shortUrl,
      eventInstanceId: eventInstanceId ?? this.eventInstanceId,
      event: event ?? this.event,
      date: date ?? this.date,
      venueName: venueName ?? this.venueName,
      city: city ?? this.city,
      url: url ?? this.url,
      linkToEvent: linkToEvent ?? this.linkToEvent,
      ticketLink: ticketLink ?? this.ticketLink,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      cost: cost ?? this.cost,
      description: description ?? this.description,
      ratings: ratings ?? this.ratings,
      isCancelled: isCancelled ?? this.isCancelled,
      proposals: proposals ?? this.proposals,
      flyerUrl: flyerUrl ?? this.flyerUrl,
      excitedUsers: excitedUsers ?? this.excitedUsers,
    );
  }

  /// Compares two EventInstance models and returns their differences as a Map.
  /// Returns null if the models are identical.
  static Map<String, dynamic>? getDifferences(EventInstance instance1, EventInstance instance2) {
    final differences = <String, dynamic>{};

    void addIfDifferent(String key, dynamic value1, dynamic value2) {
      if (value1 != value2) {
        differences[key] = {
          'old': value1,
          'new': value2,
        };
      }
    }

    addIfDifferent('eventInstanceId', instance1.eventInstanceId, instance2.eventInstanceId);
    addIfDifferent('date', instance1.date.toIso8601String(), instance2.date.toIso8601String());
    addIfDifferent('venueName', instance1.venueName, instance2.venueName);
    addIfDifferent('city', instance1.city, instance2.city);
    addIfDifferent('url', instance1.url, instance2.url);
    addIfDifferent('linkToEvent', instance1.linkToEvent, instance2.linkToEvent);
    addIfDifferent('ticketLink', instance1.ticketLink, instance2.ticketLink);
    
    // Compare TimeOfDay objects
    if (instance1.startTime.hour != instance2.startTime.hour || 
        instance1.startTime.minute != instance2.startTime.minute) {
      differences['startTime'] = {
        'old': '${instance1.startTime.hour}:${instance1.startTime.minute}',
        'new': '${instance2.startTime.hour}:${instance2.startTime.minute}',
      };
    }

    if (instance1.endTime.hour != instance2.endTime.hour || 
        instance1.endTime.minute != instance2.endTime.minute) {
      differences['endTime'] = {
        'old': '${instance1.endTime.hour}:${instance1.endTime.minute}',
        'new': '${instance2.endTime.hour}:${instance2.endTime.minute}',
      };
    }

    addIfDifferent('cost', instance1.cost, instance2.cost);
    addIfDifferent('description', instance1.description, instance2.description);
    addIfDifferent('isCancelled', instance1.isCancelled, instance2.isCancelled);
    addIfDifferent('flyerUrl', instance1.flyerUrl, instance2.flyerUrl);

    // Compare ratings if they exist
    if (instance1.ratings.length != instance2.ratings.length) {
      differences['ratings'] = {
        'old': instance1.ratings.length,
        'new': instance2.ratings.length,
      };
    }

    // Compare proposals if they exist
    if (instance1.proposals?.length != instance2.proposals?.length) {
      differences['proposals'] = {
        'old': instance1.proposals?.length,
        'new': instance2.proposals?.length,
      };
    }

    return differences.isEmpty ? null : differences;
  }
} 

