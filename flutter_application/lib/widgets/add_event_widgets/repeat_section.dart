import 'package:flutter/material.dart';

class RepeatSection extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  const RepeatSection({
    super.key,
    required this.onDateSelected,
  });

  @override
  State<RepeatSection> createState() => _RepeatSectionState();
}

class _RepeatSectionState extends State<RepeatSection> {
  DateTime? _selectedDate;

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      widget.onDateSelected(picked);
    }
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
                  backgroundColor: Colors.orange.shade50,
                  side: BorderSide(color: Colors.orange),
                ),
                onPressed: () => _pickDate(context),
                child: const Text('Once', style: TextStyle(color: Colors.orange)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.orange.shade50,
                  side: BorderSide(color: Colors.orange),
                ),
                onPressed: () => _pickDate(context),
                child: const Text('Monthly', style: TextStyle(color: Colors.orange)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.orange.shade50,
                  side: BorderSide(color: Colors.orange),
                ),
                onPressed: () => _pickDate(context),
                child: const Text('Weekly', style: TextStyle(color: Colors.orange)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildDatePicker(context),
      ],
    );
  }
} 