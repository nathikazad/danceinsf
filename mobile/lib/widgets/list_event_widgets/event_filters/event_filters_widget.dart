import 'package:flutter/material.dart';
import 'package:dance_sf/widgets/list_event_widgets/event_filters/event_filters_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:dance_sf/widgets/list_event_widgets/event_filters/event_search_bar.dart';
export 'package:dance_sf/widgets/list_event_widgets/event_filters/event_filters_controller.dart';

class FilterModalWidget extends ConsumerStatefulWidget {
  final FilterController controller;
  final List<String> cities;

  const FilterModalWidget({
    super.key,
    required this.controller,
    required this.cities,
  });
 

  @override
  ConsumerState<FilterModalWidget> createState() => _FilterModalWidgetState();

  static void show(BuildContext context,
      {required FilterController controller, required List<String> cities}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return FilterModalWidget(
          controller: controller,
          cities: cities,
        );
      },
    );
  }
}

class _FilterModalWidgetState extends ConsumerState<FilterModalWidget> {
  final List<String> _styles = ['Salsa', 'Bachata'];
  final List<String> _frequencies = ['Once', 'Weekly', 'Monthly'];
  late final List<String> _cities;
  final List<String> _eventTypes = ['Social', 'Class'];

  @override
  void initState() {
    super.initState();
    _cities = widget.cities;
  }

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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Icon(Icons.tune, size: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  'Filters',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(fontSize: 14),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Apply',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StyleFilterSection(
              name: 'Dance Style',
              styles: _styles,
              selectedStyles: widget.controller.selectedStyles,
              onStyleSelected: (style, selected) {
                widget.controller.toggleStyle(style);
              },
            ),
            const SizedBox(height: 16),
            StyleFilterSection(
              name: 'Event Type',
              styles: _eventTypes,
              selectedStyles: widget.controller.selectedEventTypes,
              onStyleSelected: (eventType, selected) {
                widget.controller.toggleEventType(eventType);
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
  final String name;
  final List<String> styles;
  final List<String> selectedStyles;
  final Function(String, bool) onStyleSelected;

  const StyleFilterSection({
    super.key,
    required this.name,
    required this.styles,
    required this.selectedStyles,
    required this.onStyleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontSize: 12),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children:
              styles
                  .map(
                    (style) => ChoiceChip(
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: BorderSide(
                          width: 1.5,
                          color:
                              selectedStyles.contains(style)
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      label: Text(
                        style,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color:
                              selectedStyles.contains(style)
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      selected: selectedStyles.contains(style),
                      onSelected:
                          (selected) => onStyleSelected(style, selected),
                    ),
                  )
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
        Text(
          'Frequency',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontSize: 12),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children:
              frequencies
                  .map(
                    (freq) => ChoiceChip(
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: BorderSide(
                          width: 1.5,
                          color:
                              selectedFrequencies.contains(freq)
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      label: Text(
                        freq,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          fontSize: 12,
                          color:
                              selectedFrequencies.contains(freq)
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      selected: selectedFrequencies.contains(freq),
                      onSelected:
                          (selected) => onFrequencySelected(freq, selected),
                    ),
                  )
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
        Text(
          'City',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontSize: 12),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              cities
                  .map(
                    (city) => ChoiceChip(
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: BorderSide(
                          width: 1.5,
                          color:
                              selectedCities.contains(city)
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      label: Text(
                        city,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          fontSize: 12,
                          color:
                              selectedCities.contains(city)
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      selected: selectedCities.contains(city),
                      onSelected: (selected) => onCitySelected(city, selected),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }
}
