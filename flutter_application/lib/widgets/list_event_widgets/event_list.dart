import 'package:flutter/material.dart';
import 'package:flutter_application/widgets/list_event_widgets/week_navigator.dart';
import 'package:go_router/go_router.dart';
import '../../models/event_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';


// EventsList widget
class EventsList extends StatelessWidget {
  final AsyncValue<List<EventInstance>> eventsAsync;
  final WeekNavigatorController weekNavigatorController;
  final void Function(DateTime) handleDateUpdate;
  final void Function(bool) onRangeUpdate;
  const EventsList({
    super.key,
    required this.eventsAsync,
    required this.weekNavigatorController,
    required this.handleDateUpdate,
    required this.onRangeUpdate,
  });
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMM d');
    return Expanded(
      child: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
        data: (eventInstances) {
          final groupedInstances = Event.groupEventInstancesByDate(eventInstances);
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
              if (notification is ScrollEndNotification) {
                final scrollController = weekNavigatorController.scrollController;
                if (scrollController.position.pixels == 0) {
                  print('Top reached');
                  onRangeUpdate(true);
                } else if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
                  print('Bottom reached');
                  onRangeUpdate(false);
                }
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
      ),
    );
  }
}

// GroupedEventsForDate widget
class GroupedEventsForDate extends StatelessWidget {
  final DateTime date;
  final List<EventInstance> eventInstancesForDate;
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
        ...eventInstancesForDate.map((eventInstance) {
          return EventInstanceCard(
            eventInstance: eventInstance,
          );
        }).toList(),
        if (!isLast)
          const Divider(height: 32, thickness: 3, color: Colors.grey),
      ],
    );
  }
}

class EventInstanceCard extends StatelessWidget {
  final EventInstance eventInstance;

  const EventInstanceCard({
    super.key,
    required this.eventInstance,
  });

  @override
  Widget build(BuildContext context) {
    final start = eventInstance.startTime;
    final end = eventInstance.endTime;
    final rating = eventInstance.event.rating;
    final ratingCount = eventInstance.event.ratingCount;
    return InkWell(
      onTap: () {
        GoRouter.of(context).push('/event/${eventInstance.eventInstanceId}');
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side: Event info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/dot.svg',
                          width: 12,
                          height: 12,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            eventInstance.event.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 19,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/clock.svg',
                              width: 18,
                              height: 18,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              '${start.format(context)} - ${end.format(context)}',
                              style: const TextStyle(fontSize: 15, color: Color(0xFF8A8A8A)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/location.svg',
                              width: 18,
                              height: 18,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 7),
                            Flexible(
                              child: Text(
                                '${eventInstance.venueName}, ${eventInstance.city}',
                                style: const TextStyle(fontSize: 15, color: Color(0xFF8A8A8A)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Right side: Cost and rating
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3EA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      eventInstance.cost == 0.0 ? 'Free' : '\$${eventInstance.cost.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  if (rating != null && ratingCount != null && ratingCount > 0) ...[
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/heart.svg',
                          width: 20,
                          height: 20,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

