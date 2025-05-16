import 'package:flutter/material.dart';
import 'package:flutter_application/widgets/list_event_widgets/event_filters/event_filters_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:flutter_application/widgets/list_event_widgets/event_filters/event_search_bar.dart';
export 'package:flutter_application/widgets/list_event_widgets/event_filters/event_filters_controller.dart';

class FilterModalWidget extends ConsumerStatefulWidget {
  final FilterController controller;

  const FilterModalWidget({
    super.key,
    required this.controller,
  });

  @override
  ConsumerState<FilterModalWidget> createState() => _FilterModalWidgetState();

  static void show(BuildContext context,
      {required FilterController controller}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return FilterModalWidget(
          controller: controller,
        );
      },
    );
  }
}

class _FilterModalWidgetState extends ConsumerState<FilterModalWidget> {
  final List<String> _styles = ['Salsa', 'Bachata'];
  final List<String> _frequencies = ['Once', 'Weekly', 'Monthly'];
  final List<String> _cities = ['San Francisco', 'San Jose', 'Oakland'];

  void _resetFilters() {
    widget.controller.resetFilters();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the controller to rebuild when it changes
    ref.watch(filterControllerProvider);

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
                Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(100)),
                  child: const Icon(Icons.tune, size: 28),
                ),
                const SizedBox(width: 8),
                const Text('Filters',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StyleFilterSection(
              styles: _styles,
              selectedStyles: widget.controller.selectedStyles,
              onStyleSelected: (style, selected) {
                widget.controller.toggleStyle(style);
              },
            ),
            const SizedBox(height: 16),
            FrequencyFilterSection(
              frequencies: _frequencies,
              selectedFrequencies: widget.controller.selectedFrequencies,
              onFrequencySelected: (freq, selected) {
                widget.controller.toggleFrequency(freq);
              },
            ),
            const SizedBox(height: 16),
            CityFilterSection(
              cities: _cities,
              selectedCities: widget.controller.selectedCities,
              onCitySelected: (city, selected) {
                widget.controller.toggleCity(city);
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
        const Text('Dance Style',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: styles
              .map((style) => ChoiceChip(
                    label: Text(style),
                    selected: selectedStyles.contains(style),
                    onSelected: (selected) => onStyleSelected(style, selected),
                  ))
              .toList(),
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
        const Text('Frequency',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: frequencies
              .map((freq) => ChoiceChip(
                    label: Text(freq),
                    selected: selectedFrequencies.contains(freq),
                    onSelected: (selected) =>
                        onFrequencySelected(freq, selected),
                  ))
              .toList(),
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
        const Text('City',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: cities
              .map((city) => ChoiceChip(
                    label: Text(city),
                    selected: selectedCities.contains(city),
                    onSelected: (selected) => onCitySelected(city, selected),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
