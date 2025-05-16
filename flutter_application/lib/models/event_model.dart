import 'package:flutter/material.dart';
import 'package:flutter_application/models/event_instance_model.dart';
import 'package:flutter_application/models/schedule_model.dart';
import 'package:flutter_application/models/proposal_model.dart';
import 'package:flutter_application/utils/string.dart';

export 'package:flutter_application/models/event_instance_model.dart';
export 'package:flutter_application/models/schedule_model.dart';

enum EventType {
  social,
  class_
}

enum DanceStyle {
  salsa,
  bachata
}

enum Frequency {
  once,
  weekly,
  monthly;

  static Frequency fromString(String? recurrenceType) {
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
}

enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday
}

class Location {
  final String venueName;
  final String city;
  final String? url;

  Location({
    required this.venueName,
    required this.city,
    this.url,
  });
}

class EventRating {
  final double rating;
  final String? comment;
  final DateTime createdAt;
  final String userId;
  EventRating({
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.userId,
  });
}

extension TimeOfDayString on String {
  TimeOfDay toTimeOfDay() {
    final parts = split(':');
    if (parts.length < 2) return const TimeOfDay(hour: 0, minute: 0);
    
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }
}

 TimeOfDay? parseTimeOfDay(String? timeStr) {
    if (timeStr == null) return null;
    
    final parts = timeStr.split(':');
    if (parts.length < 2) return const TimeOfDay(hour: 0, minute: 0);
    
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

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
}