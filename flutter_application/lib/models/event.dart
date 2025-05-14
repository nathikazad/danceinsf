import 'package:flutter/material.dart';

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
  monthly
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

class SchedulePattern {
  final Frequency frequency;
  final DayOfWeek? dayOfWeek;  // For 'weekly' and 'monthly' frequency
  final int? weekOfMonth;      // For 'monthly' frequency (1-5)

  SchedulePattern({
    required this.frequency,
    this.dayOfWeek,
    this.weekOfMonth,
  }) {
    // Validate the pattern based on frequency
    switch (frequency) {
      case Frequency.once:
        assert(dayOfWeek == null && weekOfMonth == null, 'Day of week and week of month should be null for once frequency');
        break;
      case Frequency.weekly:
        assert(dayOfWeek != null, 'Day of week is required for weekly frequency');
        assert(weekOfMonth == null, 'Week of month should be null for weekly frequency');
        break;
      case Frequency.monthly:
        assert(dayOfWeek != null && weekOfMonth != null, 'Both day of week and week of month are required for monthly frequency');
        assert(weekOfMonth! >= 1 && weekOfMonth! <= 5, 'Week of month must be between 1 and 5');
        break;
    }
  }

  factory SchedulePattern.once() {
    return SchedulePattern(
      frequency: Frequency.once,
    );
  }

  factory SchedulePattern.weekly(DayOfWeek day) {
    return SchedulePattern(
      frequency: Frequency.weekly,
      dayOfWeek: day,
    );
  }

  factory SchedulePattern.monthly(DayOfWeek day, int weekOfMonth) {
    return SchedulePattern(
      frequency: Frequency.monthly,
      dayOfWeek: day,
      weekOfMonth: weekOfMonth,
    );
  }

  String get dayOfWeekString {
    return dayOfWeek?.toString().split('.').last ?? '';
  }

  String get weekOfMonthString {
    switch (weekOfMonth) {
      case 1:
        return 'First';
      case 2:
        return 'Second';
      case 3:
        return 'Third';
      case 4:
        return 'Fourth';
      case 5:
        return 'Last';
      default:
        return '';
    }
  }
  
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

  EventInstance({
    required this.eventInstanceId,
    required this.event,
    required this.date,
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
       isCancelled = isCancelled ?? false;

  // Helper method to get just the date part (without time)
  DateTime get dateOnly => DateTime(date.year, date.month, date.day);
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
  });

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