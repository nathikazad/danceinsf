
import 'package:flutter/material.dart';
import 'package:flutter_application/widget/event_list.dart';
import 'package:flutter_application/widget/week_navigator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/event_controller.dart';
import '../widget/app_drawer.dart';
import '../widget/event_filters.dart';
class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  DateTime? _weekStart;
  int _selectedWeekday = DateTime.now().weekday;
  final _weekNavigatorController = WeekNavigatorController();

  // Add state for event type and filters
  String _selectedType = 'Socials';
  // List<String> _selectedFilters = ['Salsa', 'Once', 'San Francisco'];

  String? _selectedStyle;
  String? _selectedFrequency;
  String? _selectedCity;
  final List<String> _cities = ['San Francisco', 'San Jose', 'Oakland'];

  // Add this variable
  Set<int> daysWithEventsForCurrentWeek = {};

  @override
  void dispose() {
    _weekNavigatorController.dispose();
    super.dispose();
  }

  void _handleDateUpdate(DateTime date) {
    setState(() {
      _selectedWeekday = date.weekday;
      _weekStart = date.subtract(Duration(days: (date.weekday - 1) % 7));
      _computeDaysWithEventsForCurrentWeek();
    });
  }

  // Add this method
  void _computeDaysWithEventsForCurrentWeek() {
    final eventsAsync = ref.read(eventControllerProvider);
    final weekStart = _weekStart ?? DateTime.now().subtract(Duration(days: (DateTime.now().weekday - 1) % 7));
    final weekEnd = weekStart.add(const Duration(days: 6));
    Set<int> days = {};
    if (eventsAsync.hasValue) {
      final events = eventsAsync.value!;
      for (final event in events) {
        final eventDate = event.date;
        if (eventDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
            eventDate.isBefore(weekEnd.add(const Duration(days: 1)))) {
          days.add(eventDate.weekday);
        }
      }
    }
    setState(() {
      daysWithEventsForCurrentWeek = days;
    });
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return FilterModalWidget(
          onApply: ({style, frequency, city}) {
            setState(() {
              _selectedStyle = style;
              _selectedFrequency = frequency;
              _selectedCity = city;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventControllerProvider);
    final weekStart = _weekStart ?? DateTime.now().subtract(Duration(days: (DateTime.now().weekday - 1) % 7));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dance Events'),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: const AppDrawer(),
      body: Column(
        children: [
          TopBar(
            selectedType: _selectedType,
            onTypeSelected: (type) => setState(() => _selectedType = type),
            onFilterPressed: () => _showFilterModal(context),
            onAddPressed: () => context.push('/add-event'),
          ),
          // if (_selectedFilters.isNotEmpty)
          //   SelectedFiltersRow(
          //     filters: _selectedFilters,
          //     onFilterRemoved: (filter) => setState(() => _selectedFilters.remove(filter)),
          //   ),
          WeekNavigator(
            weekStart: weekStart,
            selectedWeekday: _selectedWeekday,
            daysWithEventsForCurrentWeek: daysWithEventsForCurrentWeek,
            onWeekChanged: (newWeekStart) {
              setState(() {
                _weekStart = newWeekStart;
                _selectedWeekday = 1; // Set to Monday
                _computeDaysWithEventsForCurrentWeek();
              });
              _weekNavigatorController.scrollToClosestDate(newWeekStart);
            },
            onDaySelected: (weekday) {
              setState(() {
                _selectedWeekday = weekday;
              });
              final targetDate = _weekStart!.add(Duration(days: weekday - 1));
              _weekNavigatorController.scrollToClosestDate(targetDate);
            },
          ),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: EventsList(
              eventsAsync: eventsAsync,
              weekNavigatorController: _weekNavigatorController,
              handleDateUpdate: _handleDateUpdate,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-event'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// TopBar widget
class TopBar extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeSelected;
  final VoidCallback onFilterPressed;
  final VoidCallback onAddPressed;
  const TopBar({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
    required this.onFilterPressed,
    required this.onAddPressed,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: onFilterPressed,
          ),
          Expanded(
            child: SearchBar(
              onChanged: (value) {
                // TODO: implement search logic
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: onAddPressed,
          ),
        ],
      ),
    );
  }
}

// SelectedFiltersRow widget
class SelectedFiltersRow extends StatelessWidget {
  final List<String> filters;
  final ValueChanged<String> onFilterRemoved;
  const SelectedFiltersRow({
    super.key,
    required this.filters,
    required this.onFilterRemoved,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        spacing: 8,
        children: filters.map((filter) => Chip(
          label: Text(filter),
          deleteIcon: const Icon(Icons.close, size: 18),
          onDeleted: () => onFilterRemoved(filter),
        )).toList(),
      ),
    );
  }
}

// SearchBar widget
class SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const SearchBar({super.key, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: TextField(
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