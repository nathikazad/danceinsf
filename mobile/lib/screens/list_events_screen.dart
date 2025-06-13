import 'package:dance_sf/utils/map_view/map_view.dart' deferred as map_view;
import 'package:dance_sf/widgets/list_event_widgets/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:dance_sf/utils/theme/app_color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dance_sf/widgets/list_event_widgets/app_drawer.dart';
import 'package:dance_sf/widgets/list_event_widgets/event_filters/event_filters_widget.dart';
import 'package:dance_sf/widgets/list_event_widgets/event_list.dart';
import 'package:dance_sf/widgets/list_event_widgets/week_navigator.dart';
import 'package:dance_sf/widgets/list_event_widgets/events_screen_controller.dart';
import 'package:dance_sf/models/event_model.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(eventsScreenControllerProvider.notifier).initialize(ref);
  }

  @override
  void dispose() {
    ref.read(eventsScreenControllerProvider.notifier).dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filteredEventsState = ref.watch(filteredEventsProvider);
    final filterController = ref.watch(filterControllerProvider);
    final screenState = ref.watch(eventsScreenControllerProvider);
    final screenController = ref.read(eventsScreenControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.danceEvents),
        actions: [
          _ToggleEventsButton(
            showTopBar: screenState.showTopBar,
            onPressed: () => screenController.toggleTopBarOrMap(),
          ),
          const SizedBox(width: 8),
          const _MenuButton(),
        ],
      ),
      endDrawer: const AppDrawer(),
      body: Column(
        children: [
          _AnimatedViewSwitcher(
            showTopBar: screenState.showTopBar,
            topBar: TopBar(
              key: const ValueKey('top_bar'),
              onFilterPressed: () => screenController.onFilterPressed(context, ref, filterController),
              onAddPressed: () => screenController.onAddPressed(context, ref),
              filterController: filterController,
            ),
            eventsToShowOnMap: filteredEventsState.when(
              data: (events) => events.where((event) => 
                event.dateOnly == screenState.currentlyDisplayedDate
              ).toList(),
              loading: () => [],
              error: (_, __) => [],
            ),
          ),
          WeekNavigator(
            weekStart: screenController.weekStart,
            selectedWeekday: screenState.selectedWeekday,
            daysWithEventsForCurrentWeek:
                screenController.computeDaysWithEventsForCurrentWeek(ref),
            onWeekChanged: (newWeekStart) {
              screenController.handleWeekChanged(newWeekStart, ref);
            },
            onDaySelected: (weekday) {
              screenController.handleDaySelected(weekday);
            },
          ),
          Divider(height: 1, thickness: 1),
          Expanded(
            child: EventsList(
              eventsAsync: filteredEventsState,
              weekNavigatorController: screenState.weekNavigatorController,
              handleDateUpdate: screenController.handleDateUpdate,
              onRangeUpdate: (isTop) => screenController.handleRangeUpdate(isTop, ref, context),
              fetchEvents: ref.read(eventsStateProvider.notifier).fetchEvents,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleEventsButton extends StatelessWidget {
  final bool showTopBar;
  final VoidCallback onPressed;

  const _ToggleEventsButton({
    required this.showTopBar,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(100),
      ),
      child: IconButton(
        color: AppColors.darkPrimary,
        icon: Icon(showTopBar ? Icons.map : Icons.search),
        onPressed: onPressed,
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton();

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(100),
          ),
          child: IconButton(
            color: AppColors.darkPrimary,
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ),
      ),
    );
  }
}

class _AnimatedViewSwitcher extends StatelessWidget {
  final bool showTopBar;
  final TopBar topBar;
  final List<EventInstance> eventsToShowOnMap;

  const _AnimatedViewSwitcher({
    required this.showTopBar,
    required this.topBar,
    required this.eventsToShowOnMap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            axis: Axis.vertical,
            child: child,
          ),
        );
      },
      child: showTopBar 
        ? topBar 
        : DeferredMapView(
            key: const ValueKey('map_view'),
            events: eventsToShowOnMap,
          ),
    );
  }
}

class DeferredMapView extends StatefulWidget {
  final List<EventInstance> events;

  const DeferredMapView({
    required this.events,
    super.key,
  });

  @override
  State<DeferredMapView> createState() => _DeferredMapViewState();
}

class _DeferredMapViewState extends State<DeferredMapView> {
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = map_view.loadLibrary();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return map_view.MapViewWidget(events: widget.events);
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}