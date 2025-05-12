import 'package:flutter/material.dart';
import '../models/event.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application/widget/week_navigator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


// EventsList widget
class EventsList extends StatelessWidget {
  final AsyncValue<List<EventOccurrence>> eventsAsync;
  final WeekNavigatorController weekNavigatorController;
  final void Function(DateTime) handleDateUpdate;
  const EventsList({
    super.key,
    required this.eventsAsync,
    required this.weekNavigatorController,
    required this.handleDateUpdate,
  });
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMM d');
    return eventsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text('Error: ${error.toString()}'),
      ),
      data: (eventInstances) {
        final startDate = DateTime.now();
        final endDate = DateTime.now().add(const Duration(days: 30));
        final filteredInstances = eventInstances.where((occ) =>
          occ.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          occ.date.isBefore(endDate.add(const Duration(days: 1)))
        ).toList();
        final groupedInstances = Event.groupOccurrencesByDate(filteredInstances);
        final dateKeys = groupedInstances.keys.toList()..sort();
        if (dateKeys.isEmpty) {
          return const Center(
            child: Text('No events found in the next 7 days'),
          );
        }
        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification) {
              weekNavigatorController.updateVisibleDate(handleDateUpdate);
            }
            return true;
          },
          child: ListView.builder(
            controller: weekNavigatorController.scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: dateKeys.length,
            itemBuilder: (context, dateIndex) {
              final date = dateKeys[dateIndex];
              final eventInstancesForDate = groupedInstances[date]!;
              weekNavigatorController.dateKeys[date] = weekNavigatorController.dateKeys[date] ?? GlobalKey();
              return GroupedEventsForDate(
                date: date,
                eventInstancesForDate: eventInstancesForDate,
                dateFormat: dateFormat,
                isLast: dateIndex == dateKeys.length - 1,
                keyForDate: weekNavigatorController.dateKeys[date]!,
              );
            },
          ),
        );
      },
    );
  }
}

// GroupedEventsForDate widget
class GroupedEventsForDate extends StatelessWidget {
  final DateTime date;
  final List<EventOccurrence> eventInstancesForDate;
  final DateFormat dateFormat;
  final bool isLast;
  final GlobalKey keyForDate;
  const GroupedEventsForDate({
    required this.date,
    required this.eventInstancesForDate,
    required this.dateFormat,
    required this.isLast,
    required this.keyForDate,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      key: keyForDate,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            dateFormat.format(date),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        ...eventInstancesForDate.map((occurrence) {
          final event = occurrence.event;
          return EventCard(
            event: event,
            isFirst: eventInstancesForDate.first == occurrence,
          );
        }).toList(),
        if (!isLast)
          const Divider(height: 32, thickness: 3, color: Colors.grey),
      ],
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;
  final bool isFirst;

  const EventCard({
    super.key,
    required this.event,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    final start = event.startTime;
    final end = event.endTime;
    final location = event.location;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isFirst ? Colors.blue : Colors.transparent,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 18),
                      const SizedBox(width: 4),
                      Text(location.address, style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                  Text(
                    'San Francisco', // Placeholder for city
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${start.format(context)} to ${end.format(context)}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  '2415', // Placeholder for price
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

