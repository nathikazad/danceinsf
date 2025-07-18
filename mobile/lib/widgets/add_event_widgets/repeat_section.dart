import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RepeatSection extends StatefulWidget {
  final SchedulePattern schedule;
  final Frequency frequency;
  final DateTime? selectedDate;
  final Function(SchedulePattern, Frequency, DateTime?) onScheduleChanged;

  const RepeatSection({
    super.key,
    required this.schedule,
    required this.frequency,
    required this.onScheduleChanged,
    this.selectedDate,
  });

  @override
  State<RepeatSection> createState() => _RepeatSectionState();
}

class _RepeatSectionState extends State<RepeatSection> {
  late Frequency _frequency;
  late DateTime? _selectedDate;
  late DayOfWeek? _selectedDay;
  late Set<int> _selectedWeeks;

  @override
  void initState() {
    super.initState();
    _frequency = widget.frequency;
    _selectedDate = widget.selectedDate ?? DateTime.now();
    _selectedDay = widget.schedule.dayOfWeek;
    _selectedWeeks = widget.schedule.weeksOfMonth?.toSet() ?? {1};
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _updateSchedule();
    }
  }

  void _updateSchedule() {
    SchedulePattern newSchedule;
    switch (_frequency) {
      case Frequency.once:
        newSchedule = SchedulePattern.once();
        break;
      case Frequency.weekly:
        _selectedDate = null;
        _selectedDay ??= DayOfWeek.monday;
        newSchedule = SchedulePattern.weekly(_selectedDay!);
        break;
      case Frequency.monthly:
        _selectedDate = null;
        _selectedDay ??= DayOfWeek.monday;
        if (_selectedWeeks.isEmpty) {
          _selectedWeeks = {1};
        }
        newSchedule = SchedulePattern.monthly(_selectedDay!, _selectedWeeks.toList()..sort());
        break;
    }
    widget.onScheduleChanged(newSchedule, _frequency, _selectedDate);
  }

  Widget _buildDatePicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l10n.date,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 14, color: Theme.of(context).colorScheme.secondary)),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => _pickDate(context),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                side: BorderSide(width: 0.5)),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedDate == null
                    ? l10n.date
                    : '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}',
                style: const TextStyle(fontSize: 16),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDaySelector() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.dayOfWeek,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 14, color: Theme.of(context).colorScheme.secondary)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: DayOfWeek.values.map((day) {
            final isSelected = _selectedDay == day;
            return ChoiceChip(
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side: BorderSide(
                      width: 1,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.tertiary)),
              label: Text(
                _dayAbbreviations[day]!,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontSize: 12,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.tertiary),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedDay = day);
                _updateSchedule();
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  static const Map<DayOfWeek, String> _dayAbbreviations = {
    DayOfWeek.monday: 'M',
    DayOfWeek.tuesday: 'T',
    DayOfWeek.wednesday: 'W',
    DayOfWeek.thursday: 'Th',
    DayOfWeek.friday: 'F',
    DayOfWeek.saturday: 'Sa',
    DayOfWeek.sunday: 'Su',
  };

  Widget _buildWeekSelector() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.weeksOfMonth,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 14, color: Theme.of(context).colorScheme.secondary)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [1, 2, 3, 4].map((week) {
            final isSelected = _selectedWeeks.contains(week);
            String label = [l10n.first, l10n.second, l10n.third, l10n.fourth][week - 1];
            return ChoiceChip(
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side: BorderSide(
                      width: 1,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.tertiary)),
              label: Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontSize: 12,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.tertiary),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedWeeks.add(week);
                  } else if (_selectedWeeks.length > 1) {
                    _selectedWeeks.remove(week);
                  }
                });
                _updateSchedule();
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.repeat,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 14, color: Theme.of(context).colorScheme.secondary)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  backgroundColor: _frequency == Frequency.once
                      ? Theme.of(context).colorScheme.secondaryContainer
                      : null,
                  side: BorderSide(
                      color: _frequency == Frequency.once
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.tertiary),
                ),
                onPressed: () {
                  setState(() => _frequency = Frequency.once);
                  _updateSchedule();
                },
                child: Text(l10n.once,
                    style: TextStyle(
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w500,
                        color: _frequency == Frequency.once
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.tertiary)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  backgroundColor: _frequency == Frequency.weekly
                      ? Theme.of(context).colorScheme.secondaryContainer
                      : null,
                  side: BorderSide(
                      color: _frequency == Frequency.weekly
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.tertiary),
                ),
                onPressed: () {
                  setState(() => _frequency = Frequency.weekly);
                  _updateSchedule();
                },
                child: Text(l10n.weekly,
                    style: TextStyle(
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w500,
                        color: _frequency == Frequency.weekly
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.tertiary)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  backgroundColor: _frequency == Frequency.monthly
                      ? Theme.of(context).colorScheme.secondaryContainer
                      : null,
                  side: BorderSide(
                      color: _frequency == Frequency.monthly
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.tertiary),
                ),
                onPressed: () {
                  setState(() => _frequency = Frequency.monthly);
                  _updateSchedule();
                },
                child: Text(l10n.monthly,
                    style: TextStyle(
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w500,
                        color: _frequency == Frequency.monthly
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.tertiary)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_frequency == Frequency.once)
          _buildDatePicker(context)
        else ...[
          if (_frequency == Frequency.monthly) ...[
            const SizedBox(height: 12),
            _buildWeekSelector(),
          ],
          _buildDaySelector(),
        ],
      ],
    );
  }
}
