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
  final _filterState = FilterState();

  // Add state for date range
  DateTime _startDate = DateTime.now();
  int _daysWindow = 30;

  @override
  void initState() {
    super.initState();
    // Initial fetch
    ref.read(eventControllerProvider.notifier).fetchEvents(
      startDate: _startDate,
      windowDays: _daysWindow,
    );
  }

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

  Set<int> _computeDaysWithEventsForCurrentWeek() {
    final eventsAsync = ref.read(eventControllerProvider);
    final weekStart = _weekStart ?? DateTime.now().subtract(Duration(days: (DateTime.now().weekday - 1) % 7));
    return _weekNavigatorController.computeDaysWithEvents(eventsAsync, weekStart);
  }

  void _applyFilters() {
    setState(() {
      // The filter state is already updated by the modal
      // TODO: Implement filtering logic here
    });
  }

  void _handleRangeUpdate(bool isTop) {
    setState(() {
      if (isTop) {
        // When reaching top, extend range backwards
        _startDate = _startDate.subtract(Duration(days: _daysWindow));
      } else {
        // When reaching bottom, extend range forwards
        _daysWindow += 30;
      }
    });
    // Fetch events with new range
    ref.read(eventControllerProvider.notifier).fetchEvents(
      startDate: _startDate,
      windowDays: _daysWindow,
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
            onFilterPressed: () => FilterModalWidget.show(context, _filterState, _applyFilters),
            onAddPressed: () => context.push('/add-event'),
          ),
          WeekNavigator(
            weekStart: weekStart,
            selectedWeekday: _selectedWeekday,
            daysWithEventsForCurrentWeek: _computeDaysWithEventsForCurrentWeek(),
            onWeekChanged: (newWeekStart) {
              setState(() {
                _weekStart = newWeekStart;
                _selectedWeekday = 1; // Set to Monday
                _computeDaysWithEventsForCurrentWeek();
              });

              // Check if new week is beyond current date range
              final endDate = _startDate.add(Duration(days: _daysWindow));
              if (newWeekStart.isBefore(_startDate)) {
                _handleRangeUpdate(true); // Extend backwards
              } else if (newWeekStart.add(const Duration(days: 7)).isAfter(endDate)) {
                _handleRangeUpdate(false); // Extend forwards
              }

              _weekNavigatorController.scrollToClosestDate(newWeekStart);
            },
            onDaySelected: (weekday) {
              setState(() {
                _selectedWeekday = weekday;
              });
              final weekStart = _weekStart ?? DateTime.now().subtract(Duration(days: (DateTime.now().weekday - 1) % 7));
              final targetDate = weekStart.add(Duration(days: weekday - 1));
              _weekNavigatorController.scrollToClosestDate(targetDate);
            },
          ),
          const Divider(height: 1, thickness: 1),
          EventsList(
            eventsAsync: eventsAsync,
            weekNavigatorController: _weekNavigatorController,
            handleDateUpdate: _handleDateUpdate,
            onRangeUpdate: _handleRangeUpdate,
          ),
        ],
      ),
    );
  }
}

// TopBar widget
class TopBar extends StatelessWidget {
  final VoidCallback onFilterPressed;
  final VoidCallback onAddPressed;
  
  const TopBar({
    super.key,
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