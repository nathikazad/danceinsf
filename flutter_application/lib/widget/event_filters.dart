import 'package:flutter/material.dart';

class FilterModalWidget extends StatefulWidget {
  final void Function({String? style, String? frequency, String? city}) onApply;
  const FilterModalWidget({
    super.key,
    required this.onApply,
  });
  @override
  State<FilterModalWidget> createState() => _FilterModalWidgetState();
}

class _FilterModalWidgetState extends State<FilterModalWidget> {
    // Add state for filter modal
  final List<String> _types = ['Socials', 'Classes'];
  final List<String> _styles = ['Salsa', 'Bachata'];
  final List<String> _frequencies = ['Once', 'Weekly', 'Monthly'];
  final List<String> _cities = ['San Francisco', 'San Jose', 'Oakland'];
  String? _selectedStyle;
  String? _selectedFrequency;
  String? _selectedCity;
  String? _selectedType;
  @override
  void initState() {
    super.initState();
  }

  void _resetFilters() {
    setState(() {
      _selectedStyle = null;
      _selectedFrequency = null;
      _selectedCity = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tune, size: 28),
                const SizedBox(width: 8),
                const Text('Filters', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    _resetFilters();
                  },
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    widget.onApply(
                      style: _selectedStyle,
                      frequency: _selectedFrequency,
                      city: _selectedCity,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Styles
            Wrap(
              spacing: 8,
              children: _styles.map((style) => ChoiceChip(
                label: Text(style),
                selected: _selectedStyle == style,
                onSelected: (selected) {
                  setState(() {
                    _selectedStyle = selected ? style : null;
                  });
                },
              )).toList(),
            ),
            const SizedBox(height: 16),
            // Frequency
            Wrap(
              spacing: 8,
              children: _frequencies.map((freq) => ChoiceChip(
                label: Text(freq),
                selected: _selectedFrequency == freq,
                onSelected: (selected) {
                  setState(() {
                    _selectedFrequency = selected ? freq : null;
                  });
                },
              )).toList(),
            ),
            const SizedBox(height: 16),
            // Frequency
            Wrap(
              spacing: 8,
              children: _types.map((type) => ChoiceChip(
                label: Text(type),
                selected: _selectedType == type,
                onSelected: (selected) {
                  setState(() {
                    _selectedType = selected ? type : null;
                  });
                },
              )).toList(),
            ),
            const SizedBox(height: 16),
            // City dropdown
            Row(
              children: [
                DropdownButton<String>(
                  value: _selectedCity,
                  hint: const Text('City'),
                  items: _cities.map((city) => DropdownMenuItem(
                    value: city,
                    child: Text(city),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCity = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
} 