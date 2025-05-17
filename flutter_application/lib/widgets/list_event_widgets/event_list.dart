import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_application/utils/theme/app_color.dart';
import 'package:flutter_application/widgets/list_event_widgets/week_navigator.dart';
import 'package:flutter_svg_icons/flutter_svg_icons.dart';
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
                final scrollController =
                    weekNavigatorController.scrollController;
                if (scrollController.position.pixels == 0) {
                  print('Top reached');
                  onRangeUpdate(true);
                } else if (scrollController.position.pixels ==
                    scrollController.position.maxScrollExtent) {
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
                weekNavigatorController.dateKeys[date] =
                    weekNavigatorController.dateKeys[date] ?? GlobalKey();
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
    return LayoutBuilder(builder: (context, constraints) {
      final screenWidth = constraints.maxWidth;
      final crossAxisCount = screenWidth > 600 ? 2 : 1;
      return Column(
        key: keyForDate,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                SvgIcon(icon: SvgIconData('assets/icons/calendar.svg')),
                SizedBox(
                  width: 10,
                ),
                Text(
                  dateFormat.format(date),
                  style: TextStyle(
                      fontFamily: "Inter",
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.secondary),
                ),
              ],
            ),
          ),
          GridView.builder(
              itemCount: eventInstancesForDate.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                height: 150.0,
              ),
              itemBuilder: (context, index) {
                return EventInstanceCard(
                    eventInstance: eventInstancesForDate[index]);
              }),
          // ...eventInstancesForDate.map((eventInstance) {
          //   return EventInstanceCard(
          //     eventInstance: eventInstance,
          //   );
          // }).toList(),
          // if (!isLast)
          //   const Divider(height: 32, thickness: 3, color: Colors.grey),
        ],
      );
    });
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
    final brightness = Theme.of(context).brightness;
    return InkWell(
      onTap: () {
        GoRouter.of(context).push('/event/${eventInstance.eventInstanceId}');
      },
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 120,
        child: Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          elevation: 0,
          color: brightness == Brightness.light
              ? Colors.white
              : Color.fromRGBO(43, 33, 28, 1),
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
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              eventInstance.event.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontFamily: "Inter",
                                fontSize: 19,
                                color: Theme.of(context).colorScheme.secondary,
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
                                width: 15,
                                height: 15,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                '${start.format(context)} - ${end.format(context)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/location.svg',
                                width: 15,
                                height: 15,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 7),
                              Flexible(
                                child: Text(
                                  '${eventInstance.venueName}, ${eventInstance.city}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: brightness == Brightness.light
                              ? const Color(0xFFFFF3EA)
                              : AppColors.darkBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          eventInstance.cost == 0.0
                              ? 'Free'
                              : '\$${eventInstance.cost.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 16,
                          ),
                        )),
                    if (rating != null) ...[
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/heart.svg',
                            width: 17,
                            height: 17,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontFamily: "Inter",
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onTertiary,
                              fontSize: 16,
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
      ),
    );
  }
}

class SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight
    extends SliverGridDelegate {
  final int crossAxisCount;
  final double height;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight({
    required this.crossAxisCount,
    required this.height,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
  });

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final double usableCrossAxisExtent =
        constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1);
    final double childCrossAxisExtent = usableCrossAxisExtent / crossAxisCount;
    return SliverGridRegularTileLayout(
      childCrossAxisExtent: childCrossAxisExtent,
      childMainAxisExtent: height,
      crossAxisCount: crossAxisCount,
      mainAxisStride: height + mainAxisSpacing,
      crossAxisStride: childCrossAxisExtent + crossAxisSpacing,
      reverseCrossAxis: false,
    );
  }

  @override
  bool shouldRelayout(covariant SliverGridDelegate oldDelegate) => true;
}
