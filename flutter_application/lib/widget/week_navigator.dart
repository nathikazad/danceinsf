import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


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
