import 'package:flutter/material.dart';
import 'package:dance_sf/auth.dart';
import 'package:dance_sf/models/event_model.dart';
import 'package:dance_sf/screens/verify_screen.dart';
import 'package:dance_sf/utils/theme/app_color.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dance_sf/controllers/event_controller.dart';

import 'package:dance_sf/widgets/list_event_widgets/app_drawer.dart';
import 'package:dance_sf/widgets/list_event_widgets/event_filters/event_filters_widget.dart';
import 'package:dance_sf/widgets/list_event_widgets/event_list.dart';
import 'package:dance_sf/widgets/list_event_widgets/week_navigator.dart';

final eventsStateProvider =
    StateNotifierProvider<EventsStateNotifier, AsyncValue<List<EventInstance>>>(
        (ref) => EventsStateNotifier());

class EventsStateNotifier
    extends StateNotifier<AsyncValue<List<EventInstance>>> {
  EventsStateNotifier() : super(const AsyncValue.loading());

  Future<void> fetchEvents({DateTime? startDate, int windowDays = 90}) async {
    state = const AsyncValue.loading();
    try {
      final events = await EventController.fetchEvents(
        startDate: startDate,
        windowDays: windowDays,
      );
      state = AsyncValue.data(events);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> appendEvents(BuildContext context, {DateTime? startDate, int windowDays = 90}) async {
    if (state is! AsyncData) return;
    
    try {
      final currentEvents = (state as AsyncData<List<EventInstance>>).value;
      final newEvents = await EventController.fetchEvents(
        startDate: startDate,
        windowDays: windowDays,
      );
      
      // Create a map of current events by ID
      final currentEventsMap = {
        for (var e in currentEvents) e.eventInstanceId: e
      };

      // Update or add new events
      for (var newEvent in newEvents) {
        currentEventsMap[newEvent.eventInstanceId] = newEvent;
      }

      final allEvents = currentEventsMap.values.toList();

      if (allEvents.length == currentEvents.length) {
        // No new events were added
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No more new events'), duration: Duration(seconds: 2)),
          );
        }
      }

      state = AsyncValue.data(allEvents);
    } catch (error) {
      print('Error appending events: $error');
    }
  }
}

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
    ref.read(eventsStateProvider.notifier).fetchEvents();
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
    final weekStart = _weekStart ??
        DateTime.now()
            .subtract(Duration(days: (DateTime.now().weekday - 1) % 7));
    return _weekNavigatorController.computeDaysWithEvents(
        eventsAsync, weekStart);
  }

  Future<void> _handleRangeUpdate(bool isTop) async {
    if (isTop) {
      // When reaching top, extend range backwards
      _startDate = _startDate.subtract(Duration(days: _daysWindow));
      await ref.read(eventsStateProvider.notifier).appendEvents(
        context,
        startDate: _startDate,
        windowDays: _daysWindow,
      );
    } else {
      // When reaching bottom, extend range forwards
      _daysWindow += 30;
      await ref.read(eventsStateProvider.notifier).appendEvents(
        context,
        startDate: _startDate.add(Duration(days: _daysWindow - 30)),
        windowDays: 30,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(filteredEventsProvider);
    final filterController = ref.watch(filterControllerProvider);
    final weekStart = _weekStart ??
        DateTime.now()
            .subtract(Duration(days: (DateTime.now().weekday - 1) % 7));
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Dance Events'),
        actions: [
          Builder(
            builder: (context) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(100)),
                child: IconButton(
                  color: AppColors.darkPrimary,
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                ),
              ),
            ),
          ),
        ],
      ),
      endDrawer: const AppDrawer(),
      body: Column(
        children: [
          TopBar(
            onFilterPressed: () {
              final eventsAsync = ref.read(eventsStateProvider);
              final cities = eventsAsync.when(
                data: (events) => events
                    .map((e) => e.event.location.city)
                    .where((city) => city.isNotEmpty)
                    .toSet()
                    .toList()
                  ..sort(),
                loading: () => <String>[],
                error: (_, __) => <String>[],
              );
              FilterModalWidget.show(
                context,
                controller: filterController,
                cities: cities,
              );
            },
            onAddPressed: () async {
              if (ref.read(authProvider).state.user != null) {
                await GoRouter.of(context).push('/add-event');
              } else {
                await GoRouter.of(context).push('/verify',
                 extra: {
                  'nextRoute': '/add-event', 
                  'verifyScreenType': VerifyScreenType.addEvent});
              }
              ref.read(eventsStateProvider.notifier).fetchEvents();
            },
            filterController: filterController,
          ),
          WeekNavigator(
            weekStart: weekStart,
            selectedWeekday: _selectedWeekday,
            daysWithEventsForCurrentWeek:
                _computeDaysWithEventsForCurrentWeek(),
            onWeekChanged: (newWeekStart) {
              setState(() {
                _weekStart = newWeekStart;
                _selectedWeekday = 1; // Set to Monday
                _computeDaysWithEventsForCurrentWeek();
              });

              // Check if new week is beyond current date range
              final endDate = _startDate.add(Duration(days: _daysWindow));
              print('New Week: ${newWeekStart.toIso8601String().split('T')[0]}, Start: ${_startDate.toIso8601String().split('T')[0]}, End: ${endDate.toIso8601String().split('T')[0]}');
              if (newWeekStart.isBefore(_startDate)) {
                print('Extending backwards');
                _handleRangeUpdate(true); // Extend backwards
              } else if (newWeekStart.add(const Duration(days: 7)).isAfter(endDate)) {
                print('Extending forwards');
                _handleRangeUpdate(false); // Extend forwards
              }

              _weekNavigatorController.scrollToClosestDate(newWeekStart);
            },
            onDaySelected: (weekday) {
              setState(() {
                _selectedWeekday = weekday;
              });
              final weekStart = _weekStart ??
                  DateTime.now().subtract(
                      Duration(days: (DateTime.now().weekday - 1) % 7));
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
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(100)),
                child: IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: onFilterPressed,
                ),
              ),
              Consumer(
                builder: (context, ref, child) {
                  final filterCount =
                      ref.watch(filterControllerProvider).countActiveFilters();
                  if (filterCount == 0) return const SizedBox.shrink();
                  return Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        filterCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          Expanded(
            child: EventSearchBar(
              initialValue: filterController.searchText,
              onChanged: filterController.updateSearchText,
            ),
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Theme.of(context).colorScheme.secondaryContainer),
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: onAddPressed,
            ),
          ),
        ],
      ),
    );
  }
}
