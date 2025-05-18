import 'package:flutter/material.dart';

class DateField extends StatelessWidget {
  final DateTime date;
  final Function(DateTime) onDateChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const DateField({
    required this.date,
    required this.onDateChanged,
    this.firstDate,
    this.lastDate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: firstDate ?? DateTime.now(),
              lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) {
              onDateChanged(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${date.month}/${date.day}/${date.year}',
                  style: const TextStyle(fontSize: 16),
                ),
                const Icon(Icons.calendar_today, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
} 