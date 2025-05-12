import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeekNavigatorController {
  final ScrollController scrollController = ScrollController();
  final Map<DateTime, GlobalKey> dateKeys = {};

  void dispose() {
    scrollController.dispose();
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
      if (startY > 0) {
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

  const WeekNavigator({
    super.key,
    required this.weekStart,
    required this.selectedWeekday,
    required this.onWeekChanged,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final weekDays = ['M', 'T', 'W', 'Th', 'F', 'Sa', 'Su'];
    final dateFormat = DateFormat('MM/dd');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Text(
            dateFormat.format(weekStart),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(
            width: 32,
            child: IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => onWeekChanged(
                weekStart.subtract(const Duration(days: 7)),
              ),
            ),
          ),
          SizedBox(
            width: 32,
            child: IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => onWeekChanged(
                weekStart.add(const Duration(days: 7)),
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (index) {
                final weekday = index + 1;
                final isSelected = weekday == selectedWeekday;
                return SizedBox(
                  width: 32,
                  child: ElevatedButton(
                    onPressed: () => onDaySelected(weekday),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(32, 32),
                      backgroundColor: isSelected ? Colors.blue : null,
                      foregroundColor: isSelected ? Colors.white : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      weekDays[index],
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? Colors.white : null,
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