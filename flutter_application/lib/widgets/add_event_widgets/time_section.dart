import 'package:flutter/material.dart';

class TimeSection extends StatelessWidget {
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final Function(TimeOfDay?) onStartTimeChanged;
  final Function(TimeOfDay?) onEndTimeChanged;

  const TimeSection({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
  });

  Future<void> _pickTime(BuildContext context, bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      if (isStart) {
        onStartTimeChanged(picked);
      } else {
        onEndTimeChanged(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Start Time',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 14, color: Theme.of(context).colorScheme.secondary)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pickTime(context, true),
                style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(width: 0.5),
                        borderRadius: BorderRadius.circular(5)),
                    padding: const EdgeInsets.symmetric(vertical: 18)),
                child: Text(startTime == null
                    ? 'Start Time'
                    : startTime!.format(context)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pickTime(context, false),
                style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(width: 0.5),
                        borderRadius: BorderRadius.circular(5)),
                    padding: const EdgeInsets.symmetric(vertical: 18)),
                child: Text(
                    endTime == null ? 'End Time' : endTime!.format(context)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
