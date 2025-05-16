import 'package:flutter/material.dart';
import 'package:flutter_application/models/event_model.dart';
import 'package:flutter_application/models/proposal_model.dart';

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
    this.proposals,
    String? flyerUrl,
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
    );
  }

  bool get hasStarted => DateTime.now().isAfter(DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute));
} 