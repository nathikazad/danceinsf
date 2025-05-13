import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application/controllers/event_controller.dart';
import 'package:flutter_application/models/event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final filterControllerProvider = ChangeNotifierProvider<FilterController>((ref) => FilterController());

// Provider for filtered events
final filteredEventsProvider = Provider<AsyncValue<List<EventOccurrence>>>((ref) {
  final eventsAsync = ref.watch(eventControllerProvider);
  final filterController = ref.watch(filterControllerProvider);

  print('Filtering ${eventsAsync.value?.length} events');
  
  return eventsAsync.whenData((events) {
    return events.where((occurrence) {
      final event = occurrence.event;
      
      // Filter by search text
      if (filterController.searchText.isNotEmpty) {
        final searchLower = filterController.searchText.toLowerCase();
        if (!event.name.toLowerCase().contains(searchLower) &&
            !event.location.venueName.toLowerCase().contains(searchLower) &&
            !event.location.city.toLowerCase().contains(searchLower)) {
          return false;
        }
      }

      // Filter by dance style
      if (filterController.selectedStyles.isNotEmpty) {
        final styleMatches = filterController.selectedStyles.any((style) {
          switch (style) {
            case 'Salsa':
              return event.style == DanceStyle.salsa;
            case 'Bachata':
              return event.style == DanceStyle.bachata;
            default:
              return false;
          }
        });
        if (!styleMatches) return false;
      }

      // Filter by frequency
      if (filterController.selectedFrequencies.isNotEmpty) {
        final frequencyMatches = filterController.selectedFrequencies.any((freq) {
          switch (freq) {
            case 'Once':
              return event.frequency == Frequency.once;
            case 'Weekly':
              return event.frequency == Frequency.weekly;
            case 'Monthly':
              return event.frequency == Frequency.monthly;
            default:
              return false;
          }
        });
        if (!frequencyMatches) return false;
      }

      // Filter by city
      if (filterController.selectedCities.isNotEmpty) {
        if (!filterController.selectedCities.contains(occurrence.city)) {
          return false;
        }
      }

      return true;
    }).toList();
  });
});

class FilterController extends ChangeNotifier {
  List<String> _selectedStyles = [];
  List<String> _selectedFrequencies = [];
  List<String> _selectedCities = [];
  String _searchText = '';

  // Getters
  List<String> get selectedStyles => _selectedStyles;
  List<String> get selectedFrequencies => _selectedFrequencies;
  List<String> get selectedCities => _selectedCities;
  String get searchText => _searchText;

  // Methods for modifying state
  void updateSearchText(String text) {
    if (_searchText != text) {
      _searchText = text;
      notifyListeners();
    }
  }

  void toggleStyle(String style) {
    if (_selectedStyles.contains(style)) {
      _selectedStyles.remove(style);
    } else {
      _selectedStyles.add(style);
    }
    notifyListeners();
  }

  void toggleFrequency(String frequency) {
    if (_selectedFrequencies.contains(frequency)) {
      _selectedFrequencies.remove(frequency);
    } else {
      _selectedFrequencies.add(frequency);
    }
    notifyListeners();
  }

  void toggleCity(String city) {
    if (_selectedCities.contains(city)) {
      _selectedCities.remove(city);
    } else {
      _selectedCities.add(city);
    }
    notifyListeners();
  }

  void updateFilters({
    List<String>? styles,
    List<String>? frequencies,
    List<String>? cities,
    String? search,
  }) {
    bool hasChanges = false;

    if (styles != null && !listEquals(_selectedStyles, styles)) {
      _selectedStyles = styles;
      hasChanges = true;
    }
    if (frequencies != null && !listEquals(_selectedFrequencies, frequencies)) {
      _selectedFrequencies = frequencies;
      hasChanges = true;
    }
    if (cities != null && !listEquals(_selectedCities, cities)) {
      _selectedCities = cities;
      hasChanges = true;
    }
    if (search != null && _searchText != search) {
      _searchText = search;
      hasChanges = true;
    }

    if (hasChanges) {
      notifyListeners();
    }
  }

  void resetFilters() {
    _selectedStyles = [];
    _selectedFrequencies = [];
    _selectedCities = [];
    _searchText = '';
    notifyListeners();
  }

  bool hasActiveFilters() {
    return _selectedStyles.isNotEmpty ||
        _selectedFrequencies.isNotEmpty ||
        _selectedCities.isNotEmpty ||
        _searchText.isNotEmpty;
  }

  int countActiveFilters() {
    int count = 0;
    count += _selectedStyles.length;
    count += _selectedFrequencies.length;
    count += _selectedCities.length;
    // if (_searchText.isNotEmpty) count += 1;
    return count;
  }
}