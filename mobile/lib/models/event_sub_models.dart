import 'package:flutter/material.dart';

enum EventType {
  social,
  class_
}

enum DanceStyle {
  salsa,
  bachata
}


extension EventTypeExtension on EventType {
  String get name {
    return switch (this) {
      EventType.social => 'Social',
      EventType.class_ => 'Class',
    };
  }
}

extension DanceStyleExtension on DanceStyle {
 
  static DanceStyle fromString(String style) {
    return DanceStyle.values.firstWhere(
      (e) => e.toString().split('.').last.toLowerCase() == style.toLowerCase()
    );
  }

  String get name {
    return switch (this) {
      DanceStyle.salsa => 'Salsa',
      DanceStyle.bachata => 'Bachata',
    };
  }
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

class GPSPoint {
  final double latitude;
  final double longitude;

  GPSPoint({required this.latitude, required this.longitude});
}

class Location {
  final String venueName;
  final String city;
  final String? url;
  final GPSPoint? gpsPoint;

  Location({
    required this.venueName,
    required this.city,
    this.url,
    this.gpsPoint,
  });
}

class EventRating {
  final double rating;
  final String? comment;
  final DateTime createdAt;
  final String userId;
  final String? eventInstanceId;
  EventRating({
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.userId,
    required this.eventInstanceId,
  });

  static EventRating fromMap(Map ratingData) {
    return EventRating(
      rating: ratingData['rating'] is double ? ratingData['rating'] : double.tryParse(ratingData['rating'].toString()) ?? 0.0,
      comment: ratingData['comment'] as String?,
      userId: ratingData['user_id'] as String,
      createdAt: DateTime.parse(ratingData['created_at']),
      eventInstanceId: ratingData['instance_id'] as String?,
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

class BankInfo {
  final String bankName;
  final String name;
  final String tarjeta;
  final String clabe;
  BankInfo({required this.bankName, required this.name, required this.tarjeta, required this.clabe});

  static BankInfo fromMap(Map bankData) {
    return BankInfo(
      bankName: bankData['bank_name'] as String,
      name: bankData['name'] as String,
      tarjeta: bankData['tarjeta'] as String,
      clabe: bankData['clabe'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bank_name': bankName,
      'name': name,
      'tarjeta': tarjeta,
      'clabe': clabe,
    };
  }
}