import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dance_sf/models/event_instance_model.dart';
import 'package:dance_sf/models/event_sub_models.dart';
import 'package:dance_sf/models/schedule_model.dart';
import 'package:dance_sf/models/proposal_model.dart';
import 'package:dance_sf/utils/string.dart';

export 'package:dance_sf/models/event_instance_model.dart';
export 'package:dance_sf/models/schedule_model.dart';
export 'package:dance_sf/models/event_sub_models.dart';

class Event {
  final String eventId;
  final String name;
  final EventType type;
  final List<DanceStyle> styles;
  final Frequency frequency;
  final Location location;
  final List<String> linkToEvents;
  final SchedulePattern schedule;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final double cost;
  final Map<String, String>? description;
  final double? rating;
  final int? ratingCount;
  List<Proposal>? proposals;
  final String? flyerUrl;
  final String? organizerId;
  final String creatorId;
  final BankInfo? bankInfo;

  Event({
    required this.eventId,
    required this.name,
    required this.type,
    required this.styles,
    required this.frequency,
    required this.location,
    required this.schedule,
    required this.startTime,
    required this.endTime,
    required this.creatorId,
    List<String>? linkToEvents,
    this.cost = 0.0,
    this.description,
    this.rating,
    this.ratingCount,
    this.proposals,
    this.flyerUrl,
    this.organizerId,
    this.bankInfo,
  }) : linkToEvents = linkToEvents ?? [];

  // Factory method to create Event from map
  static Event fromMap(Map eventData, {double? rating, int ratingCount = 0, List<Proposal>? proposals}) {
    
    final eventTypes = toStringList(eventData['event_type']);
    final weeklyDays = toStringList(eventData['weekly_days']);
    final monthlyPattern = toStringList(eventData['monthly_pattern']);
    final eventCategories = toStringList(eventData['event_category']).map((category) => DanceStyleExtension.fromString(category)).toList();
    
    // Handle linkToEvents - convert to List<String>
    List<String> linkToEvents = [];
    final ticketLinkData = eventData['default_ticket_link'];
    if (ticketLinkData != null) {
      if (ticketLinkData is List) {
        linkToEvents = ticketLinkData.cast<String>();
      } else if (ticketLinkData is String && ticketLinkData.contains(',')) {
        // Handle comma-separated string
        linkToEvents = ticketLinkData.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      } else {
        linkToEvents = [ticketLinkData.toString()];
      }
    }

    BankInfo? bankInfo;
    if(eventData['extras'] != null && eventData['extras']['bank_info'] != null) {
      bankInfo = BankInfo.fromMap(eventData['extras']['bank_info']);
    }

    Map<String, String>? description;
    if(eventData['default_description'] != null) {
      final descMap = eventData['default_description'] as Map;
      description = {};
      if (descMap['en'] != null) description['en'] = descMap['en'].toString();
      if (descMap['es'] != null) description['es'] = descMap['es'].toString();
    }

    return Event(
      eventId: eventData['event_id'],
      name: eventData['name'].toString().capitalizeWords,
      type: eventTypes.contains('Social') ? EventType.social : EventType.class_,
      styles: eventCategories,
      frequency: Frequency.fromString(eventData['recurrence_type']),
      location: Location(
        venueName: eventData['default_venue_name'].toString().capitalizeWords,
        city: eventData['default_city'].toString().capitalizeWords,
        url: eventData['default_google_maps_link'],
        gpsPoint: eventData['gps'] != null ? GPSPoint(
          latitude: eventData['gps']['latitude'],
          longitude: eventData['gps']['longitude'],
        ) : null,
      ),
      flyerUrl: eventData['default_flyer_url'],
      linkToEvents: linkToEvents,
      schedule: SchedulePattern.fromMap(
        eventData['recurrence_type'],
        weeklyDays,
        monthlyPattern,
      ),
      startTime: parseTimeOfDay(eventData['default_start_time']) ?? const TimeOfDay(hour: 0, minute: 0),
      endTime: parseTimeOfDay(eventData['default_end_time']) ?? const TimeOfDay(hour: 0, minute: 0),
      cost: eventData['default_cost'],
      description: description,
      rating: ratingCount > 0 ? rating : null,
      ratingCount: ratingCount,
      proposals: proposals,
      organizerId: eventData['organizer_id'],
      creatorId: eventData['creator_id'],
      bankInfo: bankInfo,
    );
  }

  Event copyWith({
    String? eventId,
    String? name,
    EventType? type,
    List<DanceStyle>? styles,
    Frequency? frequency,
    Location? location,
    List<String>? linkToEvents,
    SchedulePattern? schedule,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    double? cost,
    Map<String, String>? description,
    double? rating,
    int? ratingCount,
    List<Proposal>? proposals,
    String? creatorId,
    String? organizerId,
    String? flyerUrl,
    String? ticketLink,
    BankInfo? bankInfo,
  }) {
    return Event(
      eventId: eventId ?? this.eventId,
      name: name ?? this.name,
      type: type ?? this.type,
      styles: styles ?? this.styles,
      frequency: frequency ?? this.frequency,
      location: location ?? this.location,
      linkToEvents: linkToEvents ?? this.linkToEvents,
      schedule: schedule ?? this.schedule,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      cost: cost ?? this.cost,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      proposals: proposals ?? this.proposals,
      creatorId: creatorId ?? this.creatorId,
      organizerId: organizerId ?? this.organizerId,
      flyerUrl: flyerUrl ?? this.flyerUrl,
      bankInfo: bankInfo ?? this.bankInfo,
    );
  }

  /// Converts the Event to a Map for database operations
  Map<String, dynamic> toMap() {
    final eventTypes = [type == EventType.social ? 'Social' : 'Class'];
    final eventCategories = styles.map((style) => style.name).toList();
    
    // Convert frequency to string
    final recurrenceType = frequency.toString().split('.').last.capitalize;
    
    // Convert TimeOfDay to string format
    final startTimeStr = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final endTimeStr = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

    // Extract weekly days or monthly pattern based on schedule
    List<String>? weeklyDays;
    List<String>? monthlyPattern;
    
    if (schedule.frequency == Frequency.weekly && schedule.dayOfWeek != null) {
      weeklyDays = [schedule.shortWeeklyPattern];
    } else if (schedule.frequency == Frequency.monthly && 
              schedule.dayOfWeek != null && 
              schedule.weeksOfMonth != null) {
      monthlyPattern = [schedule.shortMonthlyPattern];
    }

    final extras = {};
    if (bankInfo != null) {
      extras['bank_info'] = bankInfo!.toMap();
    }

    return {
      'name': name.capitalizeWords,
      'event_type': eventTypes,
      'event_category': eventCategories,
      'recurrence_type': recurrenceType,
      'default_venue_name': location.venueName.capitalizeWords,
      'default_city': location.city.capitalizeWords,
      'default_google_maps_link': location.url,
      'default_ticket_link': linkToEvents.isNotEmpty ? linkToEvents.join(',') : null,
      'default_start_time': startTimeStr,
      'default_end_time': endTimeStr,
      'default_cost': cost,
      'default_flyer_url': flyerUrl,
      'default_description': description,
      'weekly_days': weeklyDays,
      'monthly_pattern': monthlyPattern,
      'gps': location.gpsPoint != null ? {
        'latitude': location.gpsPoint!.latitude,
        'longitude': location.gpsPoint!.longitude,
      } : null,
      'extras': extras,
    };
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

    void addIfDifferentStyles(String key, List<DanceStyle> value1, List<DanceStyle> value2) {
      if (!listEquals(value1, value2)) {
        differences[key] = {
          'old': value1.map((style) => style.name).toList(),
          'new': value2.map((style) => style.name).toList(),
        };
      }
    }

    // Compare basic fields
    addIfDifferent('eventId', event1.eventId, event2.eventId);
    addIfDifferent('name', event1.name, event2.name);
    addIfDifferent('type', event1.type, event2.type);
    addIfDifferentStyles('styles', event1.styles, event2.styles);
    addIfDifferent('frequency', event1.frequency, event2.frequency);
    // Compare linkToEvents
    if (!listEquals(event1.linkToEvents, event2.linkToEvents)) {
      differences['linkToEvents'] = {
        'old': event1.linkToEvents,
        'new': event2.linkToEvents,
      };
    }
    // Compare bankInfo
    if (event1.bankInfo != event2.bankInfo) {
      differences['bankInfo'] = {
        'old': event1.bankInfo,
        'new': event2.bankInfo,
      };
    }
    
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