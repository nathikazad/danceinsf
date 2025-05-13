import 'package:flutter/material.dart';
import 'package:flutter_application/widget/event_filters/event_filters_widget.dart';
import 'package:flutter_application/widget/event_list.dart';
import 'package:flutter_application/widget/week_navigator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/event_controller.dart';
import '../widget/app_drawer.dart';
import '../widget/event_filters/event_filters_controller.dart';
import '../models/event.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  DateTime? _weekStart;
  int _selectedWeekday = DateTime.now().weekday;
  final _weekNavigatorController = WeekNavigatorController();

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
    final eventsAsync = ref.read(filteredEventsProvider);
    final weekStart = _weekStart ?? DateTime.now().subtract(Duration(days: (DateTime.now().weekday - 1) % 7));
    return _weekNavigatorController.computeDaysWithEvents(eventsAsync, weekStart);
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
    // ref.read(eventControllerProvider.notifier).fetchEvents(
    //   startDate: _startDate,
    //   windowDays: _daysWindow,
    // );
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(filteredEventsProvider);
    final filterController = ref.watch(filterControllerProvider);
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
            onFilterPressed: () => FilterModalWidget.show(
              context, 
              controller: filterController,
            ),
            onAddPressed: () => context.push('/add-event'),
            filterController: filterController,
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
  final FilterController filterController;
  
  const TopBar({
    super.key,
    required this.onFilterPressed,
    required this.onAddPressed,
    required this.filterController,
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
            child: EventSearchBar(
              initialValue: filterController.searchText,
              onChanged: filterController.updateSearchText,
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
