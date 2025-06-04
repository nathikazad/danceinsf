import 'package:dance_sf/models/event_model.dart';

class SchedulePattern {
  final Frequency frequency;
  final DayOfWeek? dayOfWeek;  // For 'weekly' and 'monthly' frequency
  final List<int>? weeksOfMonth;      // For 'monthly' frequency (1-4)

  SchedulePattern({
    required this.frequency,
    this.dayOfWeek,
    this.weeksOfMonth,
  }) {
    // Validate the pattern based on frequency
    switch (frequency) {
      case Frequency.once:
        assert(dayOfWeek == null && weeksOfMonth == null, 'Day of week and weeks of month should be null for once frequency');
        break;
      case Frequency.weekly:
        assert(dayOfWeek != null, 'Day of week is required for weekly frequency');
        assert(weeksOfMonth == null, 'Weeks of month should be null for weekly frequency');
        break;
      case Frequency.monthly:
        assert(dayOfWeek != null && weeksOfMonth != null, 'Both day of week and weeks of month are required for monthly frequency');
        assert(weeksOfMonth!.every((week) => week >= 1 && week <= 4), 'Weeks of month must be between 1 and 4');
        break;
    }
  }

  factory SchedulePattern.once() {
    return SchedulePattern(
      frequency: Frequency.once,
    );
  }

  factory SchedulePattern.weekly(DayOfWeek day) {
    return SchedulePattern(
      frequency: Frequency.weekly,
      dayOfWeek: day,
    );
  }

  factory SchedulePattern.monthly(DayOfWeek day, List<int> weeksOfMonth) {
    return SchedulePattern(
      frequency: Frequency.monthly,
      dayOfWeek: day,
      weeksOfMonth: weeksOfMonth,
    );
  }

  static int _parseDayOfWeek(String day) {
    const dayMap = {
      'm': 0, 't': 1, 'w': 2, 'th': 3, 'f': 4, 'sa': 5, 'su': 6
    };
    return dayMap[day.toLowerCase().trim()] ?? 0;
  }

  static SchedulePattern fromMap(
    String? recurrenceType,
    List<String>? weeklyDays,
    List<String>? monthlyPattern,
  ) {
    switch (recurrenceType?.toLowerCase()) {
      case 'weekly':
        if (weeklyDays?.isNotEmpty == true) {
          final dayIndex = _parseDayOfWeek(weeklyDays!.first);
          return SchedulePattern.weekly(DayOfWeek.values[dayIndex]);
        }
        return SchedulePattern.once();
      case 'monthly':
        if (monthlyPattern?.isNotEmpty == true) {
          final weekNumbers = <int>[];
          DayOfWeek? selectedDay;
          
          for (final pattern in monthlyPattern!) {
            final parts = pattern.split('-');
            if (parts.length == 2) {
              final weekNumber = int.tryParse(parts[0].replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
              final dayIndex = _parseDayOfWeek(parts[1]);
              
              // Store the day if not set yet
              selectedDay ??= DayOfWeek.values[dayIndex];
              
              // Only add week number if it's not already included
              if (!weekNumbers.contains(weekNumber)) {
                weekNumbers.add(weekNumber);
              }
            }
          }
          
          if (selectedDay != null && weekNumbers.isNotEmpty) {
            return SchedulePattern.monthly(selectedDay, weekNumbers);
          }
        }
        return SchedulePattern.once();
      default:
        return SchedulePattern.once();
    }
  }

  String get dayOfWeekString {
    return dayOfWeek?.toString().split('.').last ?? '';
  }

  String get shortDayOfWeekString {
    switch (dayOfWeek) {
      case DayOfWeek.monday: return 'M';
      case DayOfWeek.tuesday: return 'T';
      case DayOfWeek.wednesday: return 'W';
      case DayOfWeek.thursday: return 'Th';
      case DayOfWeek.friday: return 'F';
      case DayOfWeek.saturday: return 'Sa';
      case DayOfWeek.sunday: return 'Su';
      default: return '';
    }
  }

  String get shortMonthlyPattern {
    if (frequency != Frequency.monthly || dayOfWeek == null || weeksOfMonth == null) return '';
    final weekStrings = weeksOfMonth!.map((week) => switch (week) {
      1 => '1st',
      2 => '2nd',
      3 => '3rd',
      4 => '4th',
      _ => ''
    }).join(',');
    return '$weekStrings-$shortDayOfWeekString';
  }

  String get shortWeeklyPattern {
    if (frequency != Frequency.weekly || dayOfWeek == null) return '';
    return shortDayOfWeekString;
  }

  String get weekOfMonthString {
    if (weeksOfMonth == null) return '';
    return weeksOfMonth!.map((week) => switch (week) {
      1 => 'First',
      2 => 'Second',
      3 => 'Third',
      4 => 'Fourth',
      _ => ''
    }).join(', ');
  }
}