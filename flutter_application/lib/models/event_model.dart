import 'package:flutter/material.dart';
import 'package:flutter_application/models/event_instance_model.dart';
import 'package:flutter_application/models/event_sub_models.dart';
import 'package:flutter_application/models/schedule_model.dart';
import 'package:flutter_application/models/proposal_model.dart';
import 'package:flutter_application/utils/string.dart';

export 'package:flutter_application/models/event_instance_model.dart';
export 'package:flutter_application/models/schedule_model.dart';
export 'package:flutter_application/models/event_sub_models.dart';
class Event {
  final String eventId;
  final String name;
  final EventType type;
  final DanceStyle style;
  final Frequency frequency;
  final Location location;
  final String? linkToEvent;
  final SchedulePattern schedule;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final double cost;
  final String? description;
  final double? rating;
  final int? ratingCount;
  List<Proposal>? proposals;
  final String? flyerUrl;

  Event({
    required this.eventId,
    required this.name,
    required this.type,
    required this.style,
    required this.frequency,
    required this.location,
    required this.schedule,
    required this.startTime,
    required this.endTime,
    this.linkToEvent,
    this.cost = 0.0,
    this.description,
    this.rating,
    this.ratingCount,
    this.proposals,
    this.flyerUrl,
  });

  // Factory method to create Event from map
  static Event fromMap(Map eventData, {double? rating, int ratingCount = 0, List<Proposal>? proposals}) {
    final eventTypes = toStringList(eventData['event_type']);
    final eventCategories = toStringList(eventData['event_category']);
    final weeklyDays = toStringList(eventData['weekly_days']);
    final monthlyPattern = toStringList(eventData['monthly_pattern']);

    return Event(
      eventId: eventData['event_id'],
      name: eventData['name'],
      type: eventTypes.contains('Social') ? EventType.social : EventType.class_,
      style: eventCategories.contains('Salsa') ? DanceStyle.salsa : DanceStyle.bachata,
      frequency: Frequency.fromString(eventData['recurrence_type']),
      location: Location(
        venueName: eventData['default_venue_name'] ?? '',
        city: eventData['default_city'] ?? '',
        url: eventData['default_google_maps_link'] ?? '',
      ),
      flyerUrl: eventData['default_flyer_url'] ?? '',
      linkToEvent: eventData['default_ticket_link'] ?? '',
      schedule: SchedulePattern.fromMap(
        eventData['recurrence_type'],
        weeklyDays,
        monthlyPattern,
      ),
      startTime: parseTimeOfDay(eventData['default_start_time']) ?? const TimeOfDay(hour: 0, minute: 0),
      endTime: parseTimeOfDay(eventData['default_end_time']) ?? const TimeOfDay(hour: 0, minute: 0),
      cost: eventData['default_cost'],
      description: eventData['default_description'],
      rating: ratingCount > 0 ? rating : null,
      ratingCount: ratingCount,
      proposals: proposals,
    );
  }

  Event copyWith({
    String? eventId,
    String? name,
    EventType? type,
    DanceStyle? style,
    Frequency? frequency,
    Location? location,
    String? linkToEvent,
    SchedulePattern? schedule,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    double? cost,
    String? description,
    double? rating,
    int? ratingCount,
    List<Proposal>? proposals,
  }) {
    return Event(
      eventId: eventId ?? this.eventId,
      name: name ?? this.name,
      type: type ?? this.type,
      style: style ?? this.style,
      frequency: frequency ?? this.frequency,
      location: location ?? this.location,
      linkToEvent: linkToEvent ?? this.linkToEvent,
      schedule: schedule ?? this.schedule,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      cost: cost ?? this.cost,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      proposals: proposals ?? this.proposals,
    );
  }

  static Map<DateTime, List<EventInstance>> groupEventInstancesByDate(List<EventInstance> eventInstances) {
    eventInstances.sort((a, b) {
      final dateComparison = a.dateOnly.compareTo(b.dateOnly);
      if (dateComparison != 0) return dateComparison;
      
      // If same date, compare by start time
      final aStartMinutes = a.event.startTime.hour * 60 + a.event.startTime.minute;
      final bStartMinutes = b.event.startTime.hour * 60 + b.event.startTime.minute;
      return aStartMinutes.compareTo(bStartMinutes);
    });

    // Group by date
    final Map<DateTime, List<EventInstance>> groupedEventInstances = {};
    
    for (final eventInstance in eventInstances) {
      final dateKey = eventInstance.dateOnly;
      groupedEventInstances.putIfAbsent(dateKey, () => []).add(eventInstance);
    }

    return groupedEventInstances;
  }

  /// Compares two Event models and returns their differences as a Map.
  /// Returns null if the models are identical.
  static Map<String, dynamic>? getDifferences(Event event1, Event event2) {
    final differences = <String, dynamic>{};

    void addIfDifferent(String key, dynamic value1, dynamic value2) {
      if (value1 != value2) {
        differences[key] = {
          'old': value1,
          'new': value2,
        };
      }
    }

    // Compare basic fields
    addIfDifferent('eventId', event1.eventId, event2.eventId);
    addIfDifferent('name', event1.name, event2.name);
    addIfDifferent('type', event1.type, event2.type);
    addIfDifferent('style', event1.style, event2.style);
    addIfDifferent('frequency', event1.frequency, event2.frequency);
    addIfDifferent('linkToEvent', event1.linkToEvent, event2.linkToEvent);
    addIfDifferent('cost', event1.cost, event2.cost);
    addIfDifferent('description', event1.description, event2.description);
    addIfDifferent('rating', event1.rating, event2.rating);
    addIfDifferent('ratingCount', event1.ratingCount, event2.ratingCount);
    addIfDifferent('flyerUrl', event1.flyerUrl, event2.flyerUrl);

    // Compare TimeOfDay objects
    if (event1.startTime.hour != event2.startTime.hour || 
        event1.startTime.minute != event2.startTime.minute) {
      differences['startTime'] = {
        'old': '${event1.startTime.hour}:${event1.startTime.minute}',
        'new': '${event2.startTime.hour}:${event2.startTime.minute}',
      };
    }

    if (event1.endTime.hour != event2.endTime.hour || 
        event1.endTime.minute != event2.endTime.minute) {
      differences['endTime'] = {
        'old': '${event1.endTime.hour}:${event1.endTime.minute}',
        'new': '${event2.endTime.hour}:${event2.endTime.minute}',
      };
    }

    // Compare Location
    if (event1.location.venueName != event2.location.venueName ||
        event1.location.city != event2.location.city ||
        event1.location.url != event2.location.url) {
      differences['location'] = {
        'old': {
          'venueName': event1.location.venueName,
          'city': event1.location.city,
          'url': event1.location.url,
        },
        'new': {
          'venueName': event2.location.venueName,
          'city': event2.location.city,
          'url': event2.location.url,
        },
      };
    }

    // Compare SchedulePattern
    if (event1.schedule.toString() != event2.schedule.toString()) {
      differences['schedule'] = {
        'old': event1.schedule.toString(),
        'new': event2.schedule.toString(),
      };
    }

    // Compare proposals if they exist
    if (event1.proposals?.length != event2.proposals?.length) {
      differences['proposals'] = {
        'old': event1.proposals?.length,
        'new': event2.proposals?.length,
      };
    }

    return differences.isEmpty ? null : differences;
  }
}