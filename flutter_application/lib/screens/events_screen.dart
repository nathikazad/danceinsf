import 'package:flutter/material.dart';
import 'package:flutter_application/widget/event_card.dart';
import 'package:flutter_application/widget/week_navigator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth.dart';
import '../models/event.dart';
import '../controllers/event_controller.dart';
import 'package:intl/intl.dart';
import '../widget/app_drawer.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  DateTime? _weekStart;
  int _selectedWeekday = DateTime.now().weekday;
  final _weekNavigatorController = WeekNavigatorController();

  @override
  void dispose() {
    _weekNavigatorController.dispose();
    super.dispose();
  }

  void _handleDateUpdate(DateTime date) {
    setState(() {
      _selectedWeekday = date.weekday;
      _weekStart = date.subtract(Duration(days: (date.weekday - 1) % 7));
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventControllerProvider);
    final dateFormat = DateFormat('EEEE, MMM d');

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
          WeekNavigator(
            weekStart: weekStart,
            selectedWeekday: _selectedWeekday,
            onWeekChanged: (newWeekStart) {
              setState(() {
                _weekStart = newWeekStart;
                _selectedWeekday = 1; // Set to Monday
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
            child: eventsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Text('Error: ${error.toString()}'),
              ),
              data: (eventInstances) {
                final startDate = DateTime.now();
                final endDate = DateTime.now().add(const Duration(days: 30));
                
                final filteredInstances = eventInstances.where((occ) =>
                  occ.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
                  occ.date.isBefore(endDate.add(const Duration(days: 1)))
                ).toList();
                
                final groupedInstances = Event.groupOccurrencesByDate(filteredInstances);
                final dateKeys = groupedInstances.keys.toList()..sort();

                if (dateKeys.isEmpty) {
                  return const Center(
                    child: Text('No events found in the next 7 days'),
                  );
                }

                return NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollUpdateNotification) {
                      _weekNavigatorController.updateVisibleDate(_handleDateUpdate);
                    }
                    return true;
                  },
                  child: ListView.builder(
                    controller: _weekNavigatorController.scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: dateKeys.length,
                    itemBuilder: (context, dateIndex) {
                      final date = dateKeys[dateIndex];
                      final eventInstancesForDate = groupedInstances[date]!;
                      
                      // Create or get key for this date
                      _weekNavigatorController.dateKeys[date] = _weekNavigatorController.dateKeys[date] ?? GlobalKey();
                      
                      return Column(
                        key: _weekNavigatorController.dateKeys[date],
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              dateFormat.format(date),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          ...eventInstancesForDate.map((occurrence) {
                            final event = occurrence.event;
                            return EventCard(
                              event: event,
                              isFirst: eventInstancesForDate.first == occurrence,
                            );
                          }).toList(),
                          if (dateIndex != dateKeys.length - 1)
                            const Divider(height: 32, thickness: 3, color: Colors.grey),
                        ],
                      );
                    },
                  ),
                );
              },
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