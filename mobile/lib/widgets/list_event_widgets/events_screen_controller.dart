import 'package:dance_sf/controllers/event_controller.dart';
import 'package:dance_sf/models/event_model.dart';
import 'package:dance_sf/widgets/list_event_widgets/event_filters/event_filters_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dance_sf/widgets/list_event_widgets/week_navigator.dart';
import 'package:go_router/go_router.dart';
import 'package:dance_sf/auth.dart';
import 'package:dance_sf/screens/verify_screen.dart';

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

class EventsScreenState {
  final DateTime? weekStart;
  final int selectedWeekday;
  final WeekNavigatorController weekNavigatorController;
  final bool showTopBar;
  final DateTime startDate;
  final int daysWindow;
  // field for only date, not time
  final DateTime currentlyDisplayedDate;

  EventsScreenState({
    this.weekStart,
    required this.selectedWeekday,
    required this.weekNavigatorController,
    required this.showTopBar,
    required this.startDate,
    required this.daysWindow,
    required this.currentlyDisplayedDate,
  });

  EventsScreenState copyWith({
    DateTime? weekStart,
    int? selectedWeekday,
    WeekNavigatorController? weekNavigatorController,
    bool? showTopBar,
    DateTime? startDate,
    int? daysWindow,
    DateTime? currentlyDisplayedDate,
  }) {
    return EventsScreenState(
      weekStart: weekStart ?? this.weekStart,
      selectedWeekday: selectedWeekday ?? this.selectedWeekday,
      weekNavigatorController: weekNavigatorController ?? this.weekNavigatorController,
      showTopBar: showTopBar ?? this.showTopBar,
      startDate: startDate ?? this.startDate,
      daysWindow: daysWindow ?? this.daysWindow,
      currentlyDisplayedDate: currentlyDisplayedDate ?? this.currentlyDisplayedDate,
    );
  }
}

class EventsScreenController extends StateNotifier<EventsScreenState> {
  EventsScreenController()
      : super(EventsScreenState(
          selectedWeekday: DateTime.now().weekday,
          weekNavigatorController: WeekNavigatorController(),
          showTopBar: true,
          startDate: DateTime.now().subtract(Duration(days: 4)),
          daysWindow: 90,
          currentlyDisplayedDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
        ));

  @override
  void dispose() {
    state.weekNavigatorController.dispose();
    super.dispose();
  }

  Future<void> initialize(WidgetRef ref) async {
    // Initial fetch
    await ref.read(eventsStateProvider.notifier).fetchEvents(
      startDate: state.startDate, 
      windowDays: state.daysWindow
    );
    
    // After fetching events, scroll to today's date
    final today = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      state.weekNavigatorController.scrollToClosestDate(today);
    });
  }

  void handleDateUpdate(DateTime date) {
    final newWeekStart = date.subtract(Duration(days: (date.weekday - 1) % 7));
    state = state.copyWith(
      selectedWeekday: date.weekday,
      weekStart: newWeekStart,
      currentlyDisplayedDate: date,
    );
  }

  Set<int> computeDaysWithEventsForCurrentWeek(WidgetRef ref) {
    final eventsAsync = ref.read(filteredEventsProvider);
    final weekStart = state.weekStart ??
        DateTime.now().subtract(Duration(days: (DateTime.now().weekday - 1) % 7));
    return state.weekNavigatorController.computeDaysWithEvents(eventsAsync, weekStart);
  }

  Future<void> handleRangeUpdate(bool isTop, WidgetRef ref, BuildContext context) async {
    print('handleRangeUpdate called with isTop: $isTop');
    if (isTop) {
      // When reaching top, extend range backwards
      final newStartDate = state.startDate.subtract(Duration(days: 7));
      state = state.copyWith(startDate: newStartDate);
      await ref.read(eventsStateProvider.notifier).appendEvents(
        context,
        startDate: newStartDate,
        windowDays: 7,
      );
    } else {
      // When reaching bottom, extend range forwards
      await ref.read(eventsStateProvider.notifier).appendEvents(
        context,
        startDate: state.startDate.add(Duration(days: state.daysWindow)),
        windowDays: 14,
      );
      state = state.copyWith(daysWindow: state.daysWindow + 14);
    }
  }

  void toggleTopBarOrMap() {
    state = state.copyWith(showTopBar: !state.showTopBar);
  }

  void handleWeekChanged(DateTime newWeekStart, WidgetRef ref) {
    state = state.copyWith(
      weekStart: newWeekStart,
      selectedWeekday: 1, // Set to Monday
    );

    // Check if new week is beyond current date range
    final endDate = state.startDate.add(Duration(days: state.daysWindow));
    print('New Week: ${newWeekStart.toIso8601String().split('T')[0]}, Start: ${state.startDate.toIso8601String().split('T')[0]}, End: ${endDate.toIso8601String().split('T')[0]}');
    
    if (newWeekStart.isBefore(state.startDate)) {
      print('Extending backwards');
      handleRangeUpdate(true, ref, ref.context); // Extend backwards
    } else if (newWeekStart.add(const Duration(days: 7)).isAfter(endDate)) {
      print('Extending forwards');
      handleRangeUpdate(false, ref, ref.context); // Extend forwards
    }

    state.weekNavigatorController.scrollToClosestDate(newWeekStart);
  }

  void handleDaySelected(int weekday) {
    state = state.copyWith(selectedWeekday: weekday);
    final weekStart = state.weekStart ??
        DateTime.now().subtract(Duration(days: (DateTime.now().weekday - 1) % 7));
    final targetDate = weekStart.add(Duration(days: weekday - 1));
    state.weekNavigatorController.scrollToClosestDate(targetDate);
  }

  void onFilterPressed(BuildContext context, WidgetRef ref, FilterController filterController) {
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
  }

  Future<void> onAddPressed(BuildContext context, WidgetRef ref) async {
    if (ref.read(authProvider).state.user != null) {
      await GoRouter.of(context).push('/add-event');
    } else {
      await GoRouter.of(context).push('/verify',
       extra: {
        'nextRoute': '/add-event', 
        'verifyScreenType': VerifyScreenType.addEvent});
    }
    ref.read(eventsStateProvider.notifier).fetchEvents();
  }

  DateTime get weekStart => state.weekStart ??
      DateTime.now().subtract(Duration(days: (DateTime.now().weekday - 1) % 7));
}

final eventsScreenControllerProvider = StateNotifierProvider<EventsScreenController, EventsScreenState>((ref) {
  return EventsScreenController();
}); 