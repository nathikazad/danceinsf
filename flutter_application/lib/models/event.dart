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
  final DateTime? singleDate;  // For 'once' frequency
  final DayOfWeek? dayOfWeek;  // For 'weekly' and 'monthly' frequency
  final int? weekOfMonth;      // For 'monthly' frequency (1-5)

  SchedulePattern({
    required this.frequency,
    this.singleDate,
    this.dayOfWeek,
    this.weekOfMonth,
  }) {
    // Validate the pattern based on frequency
    switch (frequency) {
      case Frequency.once:
        assert(singleDate != null, 'Single date is required for once frequency');
        assert(dayOfWeek == null && weekOfMonth == null, 'Day of week and week of month should be null for once frequency');
        break;
      case Frequency.weekly:
        assert(dayOfWeek != null, 'Day of week is required for weekly frequency');
        assert(singleDate == null && weekOfMonth == null, 'Single date and week of month should be null for weekly frequency');
        break;
      case Frequency.monthly:
        assert(dayOfWeek != null && weekOfMonth != null, 'Both day of week and week of month are required for monthly frequency');
        assert(singleDate == null, 'Single date should be null for monthly frequency');
        assert(weekOfMonth! >= 1 && weekOfMonth! <= 5, 'Week of month must be between 1 and 5');
        break;
    }
  }

  factory SchedulePattern.once(DateTime date) {
    return SchedulePattern(
      frequency: Frequency.once,
      singleDate: date,
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

class EventOccurrence {
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

  EventOccurrence({
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

  static List<EventOccurrence> expandEvents(List<Event> events, DateTime startDate, DateTime endDate) {
    List<EventOccurrence> occurrences = [];
    
    for (final event in events) {
      switch (event.schedule.frequency) {
        case Frequency.once:
          // For one-time events, only add if the date falls within the range
          if (event.schedule.singleDate != null &&
              event.schedule.singleDate!.isAfter(startDate.subtract(const Duration(days: 1))) &&
              event.schedule.singleDate!.isBefore(endDate.add(const Duration(days: 1)))) {
            occurrences.add(EventOccurrence(
              event: event,
              date: event.schedule.singleDate!,
            ));
          }
          break;

        case Frequency.weekly:
          if (event.schedule.dayOfWeek != null) {
            // Convert DayOfWeek to int (1-7, where 1 is Monday)
            final targetDay = event.schedule.dayOfWeek!.index + 1;
            
            // Start from the first occurrence of the target day after startDate
            DateTime currentDate = startDate;
            while (currentDate.weekday != targetDay) {
              currentDate = currentDate.add(const Duration(days: 1));
            }
            
            // Add all weekly occurrences until endDate
            while (currentDate.isBefore(endDate.add(const Duration(days: 1)))) {
              occurrences.add(EventOccurrence(
                event: event,
                date: currentDate,
              ));
              currentDate = currentDate.add(const Duration(days: 7));
            }
          }
          break;

        case Frequency.monthly:
          if (event.schedule.dayOfWeek != null && event.schedule.weekOfMonth != null) {
            DateTime currentDate = startDate;
            
            // Find the first occurrence of the target day in the target week
            while (currentDate.isBefore(endDate.add(const Duration(days: 1)))) {
              // Get the first day of the current month
              final firstDayOfMonth = DateTime(currentDate.year, currentDate.month, 1);
              
              // Find the first occurrence of the target day
              int targetDay = event.schedule.dayOfWeek!.index + 1;
              DateTime firstOccurrence = firstDayOfMonth;
              while (firstOccurrence.weekday != targetDay) {
                firstOccurrence = firstOccurrence.add(const Duration(days: 1));
              }
              
              // Add weeks to get to the target week
              final targetDate = firstOccurrence.add(
                Duration(days: (event.schedule.weekOfMonth! - 1) * 7)
              );
              
              // Only add if it's within our date range
              if (targetDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
                  targetDate.isBefore(endDate.add(const Duration(days: 1)))) {
                occurrences.add(EventOccurrence(
                  event: event,
                  date: targetDate,
                ));
              }
              
              // Move to next month
              currentDate = DateTime(currentDate.year, currentDate.month + 1, 1);
            }
          }
          break;
      }
    }
    
    // Sort occurrences by date
    occurrences.sort((a, b) => a.date.compareTo(b.date));
    return occurrences;
  }

  /// Groups event occurrences by date and sorts them by time within each date.
  /// Returns a Map where:
  /// - Key is the date (DateTime with time set to 00:00:00)
  /// - Value is a list of EventOccurrences for that date, sorted by start time
  static Map<DateTime, List<EventOccurrence>> groupOccurrencesByDate(List<EventOccurrence> occurrences) {
    // First, sort all occurrences by date and time
    occurrences.sort((a, b) {
      // First compare by date
      final dateComparison = a.dateOnly.compareTo(b.dateOnly);
      if (dateComparison != 0) return dateComparison;
      
      // If same date, compare by start time
      final aStartMinutes = a.event.startTime.hour * 60 + a.event.startTime.minute;
      final bStartMinutes = b.event.startTime.hour * 60 + b.event.startTime.minute;
      return aStartMinutes.compareTo(bStartMinutes);
    });

    // Group by date
    final Map<DateTime, List<EventOccurrence>> groupedOccurrences = {};
    
    for (final occurrence in occurrences) {
      final dateKey = occurrence.dateOnly;
      groupedOccurrences.putIfAbsent(dateKey, () => []).add(occurrence);
    }

    return groupedOccurrences;
  }
} 