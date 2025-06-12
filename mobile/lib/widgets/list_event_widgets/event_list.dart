import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:dance_sf/utils/theme/app_color.dart';
import 'package:dance_sf/widgets/list_event_widgets/week_navigator.dart';
import 'package:flutter_svg_icons/flutter_svg_icons.dart';
import 'package:go_router/go_router.dart';
import '../../models/event_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dance_sf/utils/string.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

String formatDateWithCapitalization(DateTime date, DateFormat dateFormat) {
  final formatted = dateFormat.format(date);
  // Split by spaces and capitalize each word
  return formatted.split(' ').map((word) {
    // Skip words like "de" in Spanish
    if (word.toLowerCase() == 'de') return word;
    return word.capitalize();
  }).join(' ');
}

// EventsList widget
class EventsList extends StatelessWidget {
  final AsyncValue<List<EventInstance>> eventsAsync;
  final WeekNavigatorController weekNavigatorController;
  final void Function(DateTime) handleDateUpdate;
  final Future<void> Function(bool) onRangeUpdate;  
  final Future<void> Function() fetchEvents;
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  EventsList({
    super.key,
    required this.eventsAsync,
    required this.weekNavigatorController,
    required this.handleDateUpdate,
    required this.onRangeUpdate,
    required this.fetchEvents,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final dateFormat = DateFormat(l10n.dateFormat, locale.languageCode);
    return Expanded(
      child: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(l10n.errorLoadingEvents(error.toString())),
        ),
        data: (eventInstances) {
          final groupedInstances = Event.groupEventInstancesByDate(eventInstances);
          final dateKeys = groupedInstances.keys.toList()..sort();
          if (dateKeys.isEmpty) {
            return Center(
              child: Text(l10n.noEventsFound),
            );
          }

          // Listen to item positions to update visible date
          itemPositionsListener.itemPositions.addListener(() {
            final positions = itemPositionsListener.itemPositions.value;
            if (positions.isEmpty) return;

            // Find the first visible item
            final firstVisible = positions.first;
            final index = firstVisible.index;
            if (index < dateKeys.length) {
              handleDateUpdate(dateKeys[index]);
            }
          });

          return RefreshIndicator(
            onRefresh: () async {
              await onRangeUpdate(true);
            },
            child: ScrollablePositionedList.builder(
              itemCount: dateKeys.length,
              itemScrollController: weekNavigatorController.itemScrollController,
              itemPositionsListener: itemPositionsListener,
              padding: const EdgeInsets.all(16),
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
                  fetchEvents: fetchEvents,
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
  final Future<void> Function() fetchEvents;
  const GroupedEventsForDate({
    required this.date,
    required this.eventInstancesForDate,
    required this.dateFormat,
    required this.isLast,
    required this.keyForDate,
    required this.fetchEvents,
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
                const SizedBox(
                  width: 10,
                ),
                Text(
                  formatDateWithCapitalization(date, dateFormat),
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
                    eventInstance: eventInstancesForDate[index],
                    fetchEvents: fetchEvents,
                  );
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
  final Future<void> Function() fetchEvents;
  const EventInstanceCard({
    super.key,
    required this.eventInstance,  
    required this.fetchEvents,
  });
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final start = eventInstance.startTime;
    final end = eventInstance.endTime;
    final rating = eventInstance.event.rating;
    // final ratingCount = eventInstance.event.ratingCount;
    final brightness = Theme.of(context).brightness;
    return InkWell(
      onTap: () async {
        final result = await GoRouter.of(context).push('/event/${eventInstance.eventInstanceId}', extra: eventInstance);
        if (result == true) {
          // Refresh events if edit was made
          fetchEvents();
        }
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
                          const SizedBox(width: 2),
                          SvgPicture.asset(
                            'assets/icons/dot.svg',
                            width: 12,
                            height: 12,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Text(
                                      eventInstance.event.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontFamily: "Inter",
                                        fontSize: 19,
                                        color: Theme.of(context).colorScheme.secondary,
                                      ),
                                    ),
                                    if (eventInstance.event.styles.contains(DanceStyle.salsa)) ...[
                                      const SizedBox(width: 6),
                                      Image.asset(
                                        'assets/images/salsa1.png',
                                        width: 20,
                                        height: 20,
                                        color: Theme.of(context).colorScheme.secondary,
                                      ),
                                    ],
                                    if (eventInstance.event.styles.contains(DanceStyle.bachata)) ...[
                                      const SizedBox(width: 6),
                                      Image.asset(
                                        'assets/images/bachata2.png',
                                        width: 20,
                                        height: 20,
                                        color: Theme.of(context).colorScheme.secondary,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
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
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const SizedBox(width: 2),
                              SvgPicture.asset(
                                'assets/icons/location.svg',
                                width: 15,
                                height: 15,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
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
                              ? l10n.free
                              : '\$${eventInstance.cost.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 16,
                          ),
                        )),
                    if (rating != null || eventInstance.excitedUsers.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (eventInstance.excitedUsers.isNotEmpty && !eventInstance.hasStarted) ...[
                            SvgIcon(
                              icon: SvgIconData('assets/icons/flame.svg'),
                              size: 16,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              eventInstance.excitedUsers.length.toString(),
                              style: TextStyle(
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onTertiary,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          if (rating != null) ...[
                              SvgIcon(
                              icon: SvgIconData('assets/icons/heart.svg'),
                              size: 16,
                              color: Colors.orange,
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


