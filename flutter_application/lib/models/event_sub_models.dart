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

  static EventRating fromMap(Map ratingData) {
    return EventRating(
      rating: ratingData['rating'] is double ? ratingData['rating'] : double.tryParse(ratingData['rating'].toString()) ?? 0.0,
      comment: ratingData['comment'] as String?,
      userId: ratingData['user_id'] as String,
      createdAt: DateTime.parse(ratingData['created_at']),
    );
  }
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
