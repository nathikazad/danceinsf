import 'package:flutter/material.dart';

class FilterModalWidget extends StatefulWidget {
  final List<String> styles;
  final List<String> frequencies;
  final List<String> cities;
  final String? initialStyle;
  final String? initialFrequency;
  final String? initialCity;
  final void Function({String? style, String? frequency, String? city}) onApply;
  const FilterModalWidget({
    super.key,
    required this.styles,
    required this.frequencies,
    required this.cities,
    this.initialStyle,
    this.initialFrequency,
    this.initialCity,
    required this.onApply,
  });
  @override
  State<FilterModalWidget> createState() => _FilterModalWidgetState();
}

class _FilterModalWidgetState extends State<FilterModalWidget> {
  String? _selectedStyle;
  String? _selectedFrequency;
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    _selectedStyle = widget.initialStyle;
    _selectedFrequency = widget.initialFrequency;
    _selectedCity = widget.initialCity;
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
                GestureDetector(
                  onTap: _resetFilters,
                  child: const Text('Reset', style: TextStyle(color: Colors.blue, fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Styles
            Wrap(
              spacing: 8,
              children: widget.styles.map((style) => ChoiceChip(
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
              children: widget.frequencies.map((freq) => ChoiceChip(
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
            // City dropdown
            Row(
              children: [
                DropdownButton<String>(
                  value: _selectedCity,
                  hint: const Text('City'),
                  items: widget.cities.map((city) => DropdownMenuItem(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
          ],
        ),
      ),
    );
  }
} 