import 'package:dance_sf/utils/string.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dance_sf/models/event_model.dart';
import 'package:dance_sf/models/proposal_model.dart';

class EventInstance {
  final Event event;
  final DateTime date;
  final String venueName;
  final String city;
  final String? url;
  final List<String> linkToEvents;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  double? cost;
  final Map<String, String>? description;
  final List<EventRating> ratings;
  final bool isCancelled;
  final String eventInstanceId;
  final List<Proposal>? proposals;
  final String? flyerUrl;
  final String shortUrl;
  final List<String> excitedUsers;
  final Map<DateTime, double>? ticketPrices;
  final bool canBuyTickets;

  EventInstance({
    required this.eventInstanceId,
    required this.event,
    required this.date,
    required this.shortUrl,
    String? venueName,
    String? city,
    String? url,
    List<String>? linkToEvents,
    String? ticketLink,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    double? cost,
    Map<String, String>? description,
    List<EventRating>? ratings,
    bool? isCancelled,
    this.proposals,
    String? flyerUrl,
    this.excitedUsers = const [],
    this.ticketPrices, 
    bool? canBuyTickets,
  }) : venueName = venueName ?? event.location.venueName,
       city = city ?? event.location.city,
       url = url ?? event.location.url,
       linkToEvents = linkToEvents ?? event.linkToEvents,
       startTime = startTime ?? event.startTime,
       endTime = endTime ?? event.endTime,
       cost = cost ?? event.cost,
       description = description ?? event.description,
       ratings = ratings ?? [],
       flyerUrl = flyerUrl ?? event.flyerUrl,
       isCancelled = isCancelled ?? false,
       canBuyTickets = canBuyTickets ?? false;

  // Helper method to get just the date part (without time)
  DateTime get dateOnly => DateTime(date.year, date.month, date.day);

  // Factory method to create EventInstance from map
  static EventInstance fromMap(Map instance, Event event, {List<EventRating>? ratings, List<Proposal>? proposals}) {
    // Handle linkToEvents - convert to List<String>
    List<String>? linkToEvents;
    final ticketLinkData = instance['ticket_link'];
    if (ticketLinkData is List) {
      linkToEvents = ticketLinkData.cast<String>();
    } else if (ticketLinkData is String && ticketLinkData.contains(',')) {
      // Handle comma-separated string
      linkToEvents = ticketLinkData.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    } else if (ticketLinkData != null) {
      linkToEvents = [ticketLinkData.toString()];
    }

    final extras = instance['extras'];
    double? cost;
    bool? canBuyTickets;
    Map<DateTime, double>? ticketPrices;
    if (extras != null) {
      print('extras: $extras');
      if (extras['ticket_costs'] is Map<String, dynamic>) {
        ticketPrices = extras['ticket_costs'].map<DateTime, double>((key, value) => MapEntry(DateTime.parse(key), (value as num).toDouble()));
        if (ticketPrices?.entries.isNotEmpty ?? false) {
        // update cost based on current time, sort the ticket prices by date time, then find the first date that is after current time
          // final now = DateTime.now();
          final now = DateTime.parse("2025-08-01T02:00:00-08:00");
          final sortedTicketPrices = ticketPrices!.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key));
          final firstDateAfterNow = sortedTicketPrices.firstWhere((entry) => entry.key.isAfter(now));
          print('firstDateAfterNow: $firstDateAfterNow');
          print('ticketPrices: $ticketPrices');
          print('cost: ${firstDateAfterNow.value}');
          cost = firstDateAfterNow.value;
        }
      }
      if (extras['can_buy_tickets'] == true) {
        canBuyTickets = true;
      }
    }
    return EventInstance(
      eventInstanceId: instance['instance_id'],
      event: event,
      date: DateTime.parse(instance['instance_date']),
      venueName: instance['venue_name']?.toString().capitalizeWords ?? event.location.venueName.capitalizeWords,
      city: instance['city']?.toString().capitalizeWords ?? event.location.city.capitalizeWords,
      url: instance['google_maps_link'] ?? event.location.url,
      linkToEvents: [
        ...(linkToEvents ?? []),
        ...(event.linkToEvents)
      ].where((e) => e.isNotEmpty).toSet().toList().cast<String>(),
      startTime: parseTimeOfDay(instance['start_time']) ?? event.startTime,
      endTime: parseTimeOfDay(instance['end_time']) ?? event.endTime,
      cost: cost ?? instance['cost'] ?? event.cost,
      description: instance['description'],
      ratings: ratings,
      isCancelled: instance['is_cancelled'] == true,
      proposals: proposals,
      excitedUsers: toStringList(instance['excited_users']),
      shortUrl: instance['short_url_prefix'],
      flyerUrl: instance['flyer_url'],
      ticketPrices: ticketPrices,
      canBuyTickets: canBuyTickets ?? false,
    );
  }

  bool get hasStarted => DateTime.now().isAfter(DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute));

  String getCost() {
    double cost = this.cost ?? event.cost;
    return cost.toStringAsFixed(0) == "0" ? "Free" : '\$${cost.toStringAsFixed(0)}';
  }

  EventInstance copyWith({
    String? eventInstanceId,
    Event? event,
    DateTime? date,
    String? venueName,
    String? city,
    String? url,
    List<String>? linkToEvents,
    String? ticketLink,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    double? cost,
    Map<String, String>? description,
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
      linkToEvents: linkToEvents ?? this.linkToEvents,
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
    // Compare linkToEvents
    if (!listEquals(instance1.linkToEvents, instance2.linkToEvents)) {
      differences['linkToEvents'] = {
        'old': instance1.linkToEvents,
        'new': instance2.linkToEvents,
      };
    }
    
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

