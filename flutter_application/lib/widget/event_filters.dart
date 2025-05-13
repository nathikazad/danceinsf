import 'package:flutter/material.dart';

class FilterState {
  List<String> selectedStyles = [];
  List<String> selectedFrequencies = [];
  List<String> selectedCities = [];
  String searchText = '';

  void updateFilters({
    List<String>? styles,
    List<String>? frequencies,
    List<String>? cities,
    String? search,
  }) {
    if (styles != null) selectedStyles = styles;
    if (frequencies != null) selectedFrequencies = frequencies;
    if (cities != null) selectedCities = cities;
    if (search != null) searchText = search;
  }

  void resetFilters() {
    selectedStyles = [];
    selectedFrequencies = [];
    selectedCities = [];
    searchText = '';
  }
}

class FilterModalWidget extends StatefulWidget {
  final FilterState filterState;
  final void Function() onApply;
  
  const FilterModalWidget({
    super.key,
    required this.filterState,
    required this.onApply,
  });
  
  @override
  State<FilterModalWidget> createState() => _FilterModalWidgetState();

  static void show(BuildContext context, FilterState filterState, void Function() onApply) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return FilterModalWidget(
          filterState: filterState,
          onApply: onApply,
        );
      },
    );
  }
}

class _FilterModalWidgetState extends State<FilterModalWidget> {
  final List<String> _styles = ['Salsa', 'Bachata'];
  final List<String> _frequencies = ['Once', 'Weekly', 'Monthly'];
  final List<String> _cities = ['San Francisco', 'San Jose', 'Oakland'];

  void _resetFilters() {
    setState(() {
      widget.filterState.resetFilters();
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
                  onPressed: _resetFilters,
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    widget.onApply();
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            EventSearchBar(
              initialValue: widget.filterState.searchText,
              onChanged: (value) {
                setState(() {
                  widget.filterState.searchText = value;
                });
              },
            ),
            const SizedBox(height: 16),
            StyleFilterSection(
              styles: _styles,
              selectedStyles: widget.filterState.selectedStyles,
              onStyleSelected: (style, selected) {
                setState(() {
                  if (selected) {
                    widget.filterState.selectedStyles.add(style);
                  } else {
                    widget.filterState.selectedStyles.remove(style);
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            FrequencyFilterSection(
              frequencies: _frequencies,
              selectedFrequencies: widget.filterState.selectedFrequencies,
              onFrequencySelected: (freq, selected) {
                setState(() {
                  if (selected) {
                    widget.filterState.selectedFrequencies.add(freq);
                  } else {
                    widget.filterState.selectedFrequencies.remove(freq);
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            CityFilterSection(
              cities: _cities,
              selectedCities: widget.filterState.selectedCities,
              onCitySelected: (city, selected) {
                setState(() {
                  if (selected) {
                    widget.filterState.selectedCities.add(city);
                  } else {
                    widget.filterState.selectedCities.remove(city);
                  }
                });
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class StyleFilterSection extends StatelessWidget {
  final List<String> styles;
  final List<String> selectedStyles;
  final Function(String, bool) onStyleSelected;

  const StyleFilterSection({
    super.key,
    required this.styles,
    required this.selectedStyles,
    required this.onStyleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dance Style', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: styles.map((style) => ChoiceChip(
            label: Text(style),
            selected: selectedStyles.contains(style),
            onSelected: (selected) => onStyleSelected(style, selected),
          )).toList(),
        ),
      ],
    );
  }
}

class FrequencyFilterSection extends StatelessWidget {
  final List<String> frequencies;
  final List<String> selectedFrequencies;
  final Function(String, bool) onFrequencySelected;

  const FrequencyFilterSection({
    super.key,
    required this.frequencies,
    required this.selectedFrequencies,
    required this.onFrequencySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Frequency', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: frequencies.map((freq) => ChoiceChip(
            label: Text(freq),
            selected: selectedFrequencies.contains(freq),
            onSelected: (selected) => onFrequencySelected(freq, selected),
          )).toList(),
        ),
      ],
    );
  }
}

class CityFilterSection extends StatelessWidget {
  final List<String> cities;
  final List<String> selectedCities;
  final Function(String, bool) onCitySelected;

  const CityFilterSection({
    super.key,
    required this.cities,
    required this.selectedCities,
    required this.onCitySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('City', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: cities.map((city) => ChoiceChip(
            label: Text(city),
            selected: selectedCities.contains(city),
            onSelected: (selected) => onCitySelected(city, selected),
          )).toList(),
        ),
      ],
    );
  }
}

class EventSearchBar extends StatelessWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  
  const EventSearchBar({
    super.key, 
    required this.onChanged,
    this.initialValue = '',
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: TextField(
        controller: TextEditingController(text: initialValue),
        decoration: InputDecoration(
          hintText: 'Search',
          prefixIcon: const Icon(Icons.search, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        ),
        onChanged: onChanged,
      ),
    );
  }
} 