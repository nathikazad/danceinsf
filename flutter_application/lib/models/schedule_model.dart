import 'package:flutter_application/models/event_model.dart';

class SchedulePattern {
  final Frequency frequency;
  final DayOfWeek? dayOfWeek;  // For 'weekly' and 'monthly' frequency
  final int? weekOfMonth;      // For 'monthly' frequency (1-5)

  SchedulePattern({
    required this.frequency,
    this.dayOfWeek,
    this.weekOfMonth,
  }) {
    // Validate the pattern based on frequency
    switch (frequency) {
      case Frequency.once:
        assert(dayOfWeek == null && weekOfMonth == null, 'Day of week and week of month should be null for once frequency');
        break;
      case Frequency.weekly:
        assert(dayOfWeek != null, 'Day of week is required for weekly frequency');
        assert(weekOfMonth == null, 'Week of month should be null for weekly frequency');
        break;
      case Frequency.monthly:
        assert(dayOfWeek != null && weekOfMonth != null, 'Both day of week and week of month are required for monthly frequency');
        assert(weekOfMonth! >= 1 && weekOfMonth! <= 5, 'Week of month must be between 1 and 5');
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

  factory SchedulePattern.monthly(DayOfWeek day, int weekOfMonth) {
    return SchedulePattern(
      frequency: Frequency.monthly,
      dayOfWeek: day,
      weekOfMonth: weekOfMonth,
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
          final pattern = monthlyPattern!.first.split('-');
          if (pattern.length == 2) {
            final weekNumber = int.tryParse(pattern[0].replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
            final dayIndex = _parseDayOfWeek(pattern[1]);
            return SchedulePattern.monthly(
              DayOfWeek.values[dayIndex],
              weekNumber,
            );
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
    if (frequency != Frequency.monthly || dayOfWeek == null || weekOfMonth == null) return '';
    final string = switch (weekOfMonth) {
      1 => '1st',
      2 => '2nd',
      3 => '3rd',
      4 => '4th',
      _ => ''
    };
    return '$string-$shortDayOfWeekString';
  }

  String get shortWeeklyPattern {
    if (frequency != Frequency.weekly || dayOfWeek == null) return '';
    return shortDayOfWeekString;
  }

  String get weekOfMonthString {
    return switch (weekOfMonth) {
      1 => 'First',
      2 => 'Second',
      3 => 'Third',
      4 => 'Fourth',
      _ => ''
    };
  }
}