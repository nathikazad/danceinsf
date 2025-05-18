import 'package:flutter/material.dart';
import '../../models/event_model.dart';

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
  late int? _selectedWeek;

  @override
  void initState() {
    super.initState();
    _frequency = widget.frequency;
    _selectedDate = widget.selectedDate ?? DateTime.now();
    _selectedDay = widget.schedule.dayOfWeek;
    _selectedWeek = widget.schedule.weekOfMonth;
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
        _selectedWeek ??= 1;
        newSchedule = SchedulePattern.monthly(_selectedDay!, _selectedWeek!);
        break;
    }
    widget.onScheduleChanged(newSchedule, _frequency, _selectedDate);
  }

  Widget _buildDatePicker(BuildContext context) {
    return OutlinedButton(
      onPressed: () => _pickDate(context),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _selectedDate == null
                ? 'Date'
                : '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}',
            style: const TextStyle(fontSize: 16),
          ),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Day of Week', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: DayOfWeek.values.map((day) {
            final isSelected = _selectedDay == day;
            return ChoiceChip(
              label: Text(_dayAbbreviations[day]!),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Week of Month', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [1, 2, 3, 4].map((week) {
            final isSelected = _selectedWeek == week;
            String label = ['1st', '2nd', '3rd', '4th'][week - 1];
            return ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedWeek = week);
                _updateSchedule();
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Repeat', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: _frequency == Frequency.once ? Colors.orange.shade50 : null,
                  side: BorderSide(color: _frequency == Frequency.once ? Colors.orange : Colors.grey.shade300),
                ),
                onPressed: () {
                  setState(() => _frequency = Frequency.once);
                  _updateSchedule();
                },
                child: Text('Once', style: TextStyle(color: _frequency == Frequency.once ? Colors.orange : Colors.black)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: _frequency == Frequency.weekly ? Colors.orange.shade50 : null,
                  side: BorderSide(color: _frequency == Frequency.weekly ? Colors.orange : Colors.grey.shade300),
                ),
                onPressed: () {
                  setState(() => _frequency = Frequency.weekly);
                  _updateSchedule();
                },
                child: Text('Weekly', style: TextStyle(color: _frequency == Frequency.weekly ? Colors.orange : Colors.black)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: _frequency == Frequency.monthly ? Colors.orange.shade50 : null,
                  side: BorderSide(color: _frequency == Frequency.monthly ? Colors.orange : Colors.grey.shade300),
                ),
                onPressed: () {
                  setState(() => _frequency = Frequency.monthly);
                  _updateSchedule();
                },
                child: Text('Monthly', style: TextStyle(color: _frequency == Frequency.monthly ? Colors.orange : Colors.black)),
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