import 'package:flutter/material.dart';
import 'package:flutter_application/models/event_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class WeekNavigatorController {
  final ScrollController scrollController = ScrollController();
  final Map<DateTime, GlobalKey> dateKeys = {};

  void dispose() {
    scrollController.dispose();
  }

  Set<int> computeDaysWithEvents(
      AsyncValue<List<EventInstance>> eventsAsync, DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    Set<int> days = {};

    if (eventsAsync.hasValue) {
      final events = eventsAsync.value!;
      for (final event in events) {
        final eventDate = event.date;
        if (eventDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
            eventDate.isBefore(weekEnd.add(const Duration(days: 1)))) {
          days.add(eventDate.weekday);
        }
      }
    }
    return days;
  }

  void updateVisibleDate(Function(DateTime) onDateUpdate) {
    if (!scrollController.hasClients) return;

    DateTime? closestDate;

    for (final entry in dateKeys.entries) {
      final key = entry.value;
      final context = key.currentContext;
      if (context == null) continue;

      final RenderBox box = context.findRenderObject() as RenderBox;
      final position = box.localToGlobal(Offset.zero);
      final startY = position.dy;

      // Check if our reference point (topThreshold) falls within this card's bounds
      if (startY > 60) {
        closestDate = entry.key;
        break;
      }
    }

    if (closestDate != null) {
      onDateUpdate(closestDate);
    }
  }

  void scrollToClosestDate(DateTime targetDate) {
    if (!scrollController.hasClients) return;

    // Find the closest date key
    DateTime? closestDate;
    int? minDistance;

    for (final entry in dateKeys.entries) {
      final key = entry.value;
      final context = key.currentContext;
      if (context == null) continue;

      // Calculate distance from target date
      final daysDifference = entry.key.difference(targetDate).inDays.abs();

      if (minDistance == null || daysDifference < minDistance) {
        minDistance = daysDifference;
        closestDate = entry.key;
      }
    }

    if (closestDate != null) {
      final key = dateKeys[closestDate]!;
      final context = key.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }
}

class WeekNavigator extends StatelessWidget {
  final DateTime weekStart;
  final int selectedWeekday;
  final Function(DateTime) onWeekChanged;
  final Function(int) onDaySelected;
  final Set<int> daysWithEventsForCurrentWeek;
  const WeekNavigator({
    super.key,
    required this.weekStart,
    required this.selectedWeekday,
    required this.daysWithEventsForCurrentWeek,
    required this.onWeekChanged,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final weekDays = ['M', 'T', 'W', 'Th', 'F', 'Sa', 'Su'];
    final dateFormat = DateFormat('MM / dd');
    List<String> dateStr = dateFormat.format(weekStart).split("/");
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Text(
            dateStr.first,
            style: TextStyle(
                fontFamily: "Inter",
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Theme.of(context).colorScheme.primary),
          ),
          Text(
            " / ${dateStr.last}",
            style: TextStyle(
                fontFamily: "Inter",
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Theme.of(context).colorScheme.tertiary),
          ),
          Chevrons(
            weekStart: weekStart,
            onWeekChanged: onWeekChanged,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (index) {
                final weekday = index + 1;
                final isSelected = weekday == selectedWeekday;
                final hasEvents =
                    daysWithEventsForCurrentWeek.contains(weekday);
                final theme = Theme.of(context);
                final isDark = theme.brightness == Brightness.dark;
                final orange = const Color(0xFFFF7A00);
                final borderColor = isSelected
                    ? orange
                    : hasEvents
                        ? orange
                        : (isDark ? Colors.grey[700]! : Colors.grey[300]!);
                final textColor = isSelected
                    ? Colors.white
                    : hasEvents
                        ? orange
                        : (isDark ? Colors.grey[500]! : Colors.grey[400]!);
                final fillColor = isSelected ? orange : Colors.transparent;
                return SizedBox(
                  width: 40,
                  child: OutlinedButton(
                    onPressed: hasEvents ? () => onDaySelected(weekday) : null,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      minimumSize: const Size(40, 40),
                      backgroundColor: fillColor,
                      side: BorderSide(color: borderColor, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      weekDays[index],
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}


class Chevrons extends StatelessWidget {
  final DateTime weekStart;
  final Function(DateTime) onWeekChanged;

  const Chevrons({
    super.key,
    required this.weekStart,
    required this.onWeekChanged,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 450) {
      return Row(
        children: [
          SizedBox(
            child: IconButton(
              icon: Container(
                height: 30,
                width: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(100)),
                child: const Icon(
                  Icons.chevron_left,
                  size: 20,
                ),
              ),
              onPressed: () => onWeekChanged(
                weekStart.subtract(const Duration(days: 7)),
              ),
            ),
          ),
          SizedBox(
            child: IconButton(
              icon: Container(
                height: 30,
                width: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(100)),
                child: const Icon(
                  Icons.chevron_right,
                  size: 20,
                ),
              ),
              onPressed: () => onWeekChanged(
                weekStart.add(const Duration(days: 7)),
              ),
            ),
          ),
        ],
      );
    }
    return const SizedBox(width: 10);
  }
}
